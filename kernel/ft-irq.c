/*
 * Interrupt handling and timestamp readout for fmc-tdc driver.
 *
 * Copyright (C) 2012-2013 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 * Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
 * Author: Miguel Angel Gomez Sexto <magomez@igalia.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation or, at your
 * option, any later version.
 */

#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/timer.h>
#include <linux/jiffies.h>
#include <linux/bitops.h>
#include <linux/spinlock.h>
#include <linux/io.h>
#include <linux/kfifo.h>

#include <linux/zio.h>
#include <linux/zio-trigger.h>
#include <linux/zio-buffer.h>

#include "fmc-tdc.h"
#include "hw/tdc_regs.h"


static void ft_read_sw_fifo(struct zio_cset *cset, struct ft_wr_timestamp *wrts)
{
	struct zio_device *zdev = cset->zdev;
	struct fmctdc_dev *ft = zdev->priv_d;
	struct zio_control *ctrl;
	struct zio_ti *ti = cset->ti;
	uint32_t *v;
	struct ft_wr_timestamp ts = *wrts, *reflast;
	struct ft_channel_state *st;

	dev_dbg(&ft->fmc->dev,
		"Set in ZIO block ch %d: hseq %u: dseq %u: gseq %llu %llu %u %u\n",
		ts.channel, ts.hseq_id, ts.dseq_id, ts.gseq_id,
		ts.seconds, ts.coarse, ts.frac);

	st = &ft->channels[cset->index];

	ctrl = cset->chan->current_ctrl;
	v = ctrl->attr_channel.ext_val;

	/* Update last time stamp of the current channel,
	   with the current time-stamp */
	memcpy(&st->last_ts, &ts, sizeof(struct ft_wr_timestamp));

	/*
	 * If we are in delay mode, replace the time stamp with the delay from
	 * the reference
	 */
	if (st->delay_reference) {
		reflast = &ft->channels[st->delay_reference - 1].last_ts;
		if (likely(ts.gseq_id > reflast->gseq_id)) {
			ft_ts_sub(&ts, reflast);
			v[FT_ATTR_TDC_DELAY_REF_SEQ] = reflast->gseq_id;
		} else {
			/*
			 * It seems that we are not able to compute the delay.
			 * Inform the user by setting the time stamp to 0
			 */
			memset(&ts, 0 , sizeof(struct ft_wr_timestamp));
		}
	} else {
		v[FT_ATTR_TDC_DELAY_REF_SEQ] = ts.gseq_id;
	}

	/* Write the timestamp in the trigger, it will reach the control */
	ti->tstamp.tv_sec = ts.seconds;
	ti->tstamp.tv_nsec = ts.coarse; /* we use 8ns steps */
	ti->tstamp_extra = ts.frac;

	/*
	 * This is different than it was. We used to fill the active block,
	 * but now zio copies chan->current_ctrl at a later time, so we
	 * must fill _those_ attributes instead
	 */
	ctrl->nsamples = 1;

	/*
	 * In order to propagate the "dacapo" flag, we have to force our
	 * sequence number insted of using the ZIO one. decrement because
	 * zio will increment it.
	 */
	ctrl->seq_num = ts.dseq_id--;

	v[FT_ATTR_DEV_SEQUENCE] = ts.gseq_id;
	v[FT_ATTR_TDC_ZERO_OFFSET] = ft->calib.zero_offset[cset->index];
	v[FT_ATTR_TDC_USER_OFFSET] = st->user_offset;
}


/**
 * It proccess a given timestamp and when it correspond to a pulse it
 * converts the timestamp from the hardware format to the white rabbit format
 */
static inline int process_timestamp(struct zio_cset *cset,
				    struct ft_hw_timestamp *hwts,
				    struct ft_wr_timestamp *wrts,
				    int dacapo_flag)
{
	struct zio_device *zdev = cset->zdev;
	struct fmctdc_dev *ft = zdev->priv_d;
	struct ft_channel_state *st;
	struct ft_wr_timestamp ts;
	struct ft_wr_timestamp diff;
	int channel, edge, frac, ret = 0;

	st = &ft->channels[cset->index];

	dev_vdbg(&ft->fmc->dev, "process TS(%p): 0x%x 0x%x 0x%x 0x%x\n",
		hwts, hwts->metadata, hwts->utc, hwts->coarse, hwts->bins);
	channel = (hwts->metadata & 0x7);
	/* channel from 1 to 5, cset is from 0 to 4 */
	if (channel != cset->index) {
		dev_err(&ft->fmc->dev,
			"reading from the wrong channel (expected %d, given %d)\n",
			channel, cset->index);
		return 0;
	}
	edge = hwts->metadata & (1 << 4) ? 1 : 0;

	/* first, convert the timestamp from the HDL units (81 ps bins)
	   to the WR format (where fractional part is 8 ns rescaled to
	   4096 units) */
	ts.channel = channel + 1; /* We want to see channels starting from 1*/
	ts.seconds = hwts->utc;
	/* 64/125 = 4096/8000: reduce fraction to avoid 64-bit division */
	frac = hwts->bins * 81 * 64 / 125;

	ts.coarse = hwts->coarse + frac / 4096;
	ts.frac = frac % 4096;

	/* the addition above may result with the coarse counter going
	   out of range: */
	if (unlikely(ts.coarse >= 125000000)) {
		ts.coarse -= 125000000;
		ts.seconds++;
	}

	/* A trivial state machine to remove glitches, react on rising edge only
	   and drop pulses that are narrower than 100 ns.

	   We are waiting for a falling edge,
	   but a rising one occurs - ignore it.
	 */
	if (unlikely(edge != st->expected_edge)) {
		/* wait unconditionally for next rising edge */
		st->expected_edge = 1;
		return 0;
	}


	/* From this point we are working with the expected EDGE */

	if (st->expected_edge == 1) {
		/* We received a raising edge, save the time stamp and
		   wait for the falling edge */
		st->prev_ts = ts;
		st->expected_edge = 0;
		return 0;
	}


	/* got a falling edge after a rising one */
	diff = ts;
	ft_ts_sub(&diff, &st->prev_ts);

	/* Check timestamp width. Must be at least 100 ns
	   (coarse = 12, frac = 2048) */
	if (likely(diff.seconds || diff.coarse > 12
	     || (diff.coarse == 12 && diff.frac >= 2048))) {
		ts = st->prev_ts;
		ft_ts_apply_offset(&ts, ft->calib.zero_offset[channel - 1]);

		ft_ts_apply_offset(&ts, -ft->calib.wr_offset);
		if (st->user_offset)
			ft_ts_apply_offset(&ts, st->user_offset);

		ts.gseq_id = ft->sequence++;
		/* Got a dacapo flag? make a gap in the sequence ID to indicate
		   an unknown loss of timestamps */

		ts.dseq_id = st->cur_seq_id++;
		if (dacapo_flag) {
			ts.dseq_id++;
			st->cur_seq_id++;
		}

		ts.hseq_id = hwts->metadata >> 5;

		/* Return a valid timestamp */
		*wrts = ts;
		ret = 1;
	}

	/* Wait for the next raising edge */
	st->expected_edge = 1;

	dev_vdbg(&cset->head.dev,
		 "processed TS: ch %d: hseq_id %u:  dseq %u: gseq %llu %llu %u %u\n",
		 wrts->channel, wrts->hseq_id, wrts->dseq_id, wrts->gseq_id,
		 wrts->seconds, wrts->coarse, wrts->frac);

	return ret;
}

/**
 * Get a time stamp from the fifo, if you set the 'last' flag it takes the last
 * recorded time-stamp
 */
static int ft_timestap_get(struct zio_cset *cset, struct ft_hw_timestamp *hwts,
			   unsigned int last)
{
	struct fmctdc_dev *ft = cset->zdev->priv_d;
	uint32_t fifo_addr = ft->ft_buffer_base + TDC_FIFO_OFFSET * cset->index;
	uint32_t data[TDC_FIFO_OUT_N - 1];
	int i, valid = 1;

	fifo_addr += last ? TDC_FIFO_LAST : TDC_FIFO_OUT;
	for (i = 0; i < TDC_FIFO_OUT_N; ++i) {
		data[i] = fmc_readl(ft->fmc, fifo_addr + i * 4);
		dev_vdbg(&cset->head.dev, "FIFO read 0x%x from 0x%x\n",
			 data[i], fifo_addr + i * 4);
	}

	if (last) {
		valid = !!(fmc_readl(ft->fmc, fifo_addr + TDC_FIFO_LAST_CSR) &
			   TDC_FIFO_LAST_CSR_VALID);
	}

	memcpy(hwts, data, TDC_FIFO_OUT_N * 4);
	return valid;
}

/**
 * Extract a timestamp from the FIFO
 */
static void ft_readout_fifo_one(struct zio_cset *cset)
{
	struct ft_hw_timestamp hwts;
	struct ft_wr_timestamp wrts;
	int ret, dacapo = 0; 	/* FIXME dacapo flag */

	ft_timestap_get(cset, &hwts, 0);

	ret = process_timestamp(cset, &hwts, &wrts, dacapo);
	if (!ret)
		return; /* Nothing to do, is not the right pulse */

	if (!(ZIO_TI_ARMED & cset->ti->flags)) {
		dev_warn(&cset->head.dev,
			 "Time stamp lost, trigger was not armed\n");
		return; /* Nothing to do, ZIO was not ready */
	}
	/* there is an active block, store data there */
	ft_read_sw_fifo(cset, &wrts);
	zio_trigger_data_done(cset);
}


/**
 * An interrupt is ready, get time stamps from the FIFOs
 */
static irqreturn_t ft_irq_handler(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct fmctdc_dev *ft = fmc->mezzanine_data;
	uint32_t irq_stat, tmp_irq_stat, fifo_stat, fifo_csr_addr;
	struct zio_cset *cset;
	int i;

	irq_stat = fmc_readl(ft->fmc, ft->ft_irq_base + TDC_REG_EIC_ISR);
	if (!irq_stat)
		return IRQ_NONE;

irq:
	dev_vdbg(&ft->fmc->dev, "pending IRQ 0x%x\n", irq_stat);
	/*
	 * Go through all FIFOs and read data. Democracy is a complicated thing,
	 * the following loops is a democratic loop, so it goes trough all
	 * channels without any priority. This avoid to be late to read the last
	 * channel on high frequency where the risk is to have an oligarchy
	 * where the first and second channel are read, but not the others.
	 */
	tmp_irq_stat = 0xFF;
	do {
		tmp_irq_stat &= irq_stat;
		for (i = 0; i < FT_NUM_CHANNELS; i++) {
			cset = &ft->zdev->cset[i];
			if (!(tmp_irq_stat & (1 << i)))
				continue; /* Nothing to do for this FIFO */

			ft_readout_fifo_one(cset);
			fifo_csr_addr = ft->ft_buffer_base +
				TDC_FIFO_OFFSET * cset->index + TDC_FIFO_CSR;
			fifo_stat = fmc_readl(ft->fmc, fifo_csr_addr);
			if (!(fifo_stat & TDC_FIFO_CSR_EMPTY))
				continue; /* Still something to read */

			/* Ack the interrupt, nothing to read anymore */
			fmc_writel(ft->fmc, 1 << i,
				   ft->ft_irq_base + TDC_REG_EIC_ISR);
			tmp_irq_stat &= (~(1 << i));
		}
	} while (tmp_irq_stat);

	/* Meanwhile we got another interrupt? then repeat */
	irq_stat = fmc_readl(ft->fmc, ft->ft_irq_base + TDC_REG_EIC_ISR);
	if (irq_stat)
		goto irq;

	/* Ack the FMC signal, we have finished */
	fmc->op->irq_ack(fmc);

	return IRQ_HANDLED;
}


int ft_irq_init(struct fmctdc_dev *ft)
{
	int ret;

	/* IRQ coalescing: 40 timestamps or 40 milliseconds */
	ft_writel(ft, 40, TDC_REG_IRQ_THRESHOLD);
	ft_writel(ft, 40, TDC_REG_IRQ_TIMEOUT);

	/* disable timestamp readout IRQ, user will enable it manually */
	fmc_writel(ft->fmc, 0x1F, ft->ft_irq_base + TDC_REG_EIC_IDR);

	/* pass the core's base addr as the VIC IRQ vector. */
	/* fixme: vector table points to the bridge instead of
	   the core's base address */
	ft->fmc->irq = ft->ft_irq_base;
	ret = ft->fmc->op->irq_request(ft->fmc, ft_irq_handler, "fmc-tdc", 0);

	if (ret < 0) {
		dev_err(&ft->fmc->dev, "Request interrupt failed: %d\n", ret);
		return ret;
	}

	/* kick off the interrupts (fixme: possible issue with the HDL) */
	ft->fmc->op->irq_ack(ft->fmc);

	return 0;
}

void ft_irq_exit(struct fmctdc_dev *ft)
{
	fmc_writel(ft->fmc, ~0, ft->ft_irq_base + TDC_REG_EIC_IDR);
	ft->fmc->op->irq_free(ft->fmc);
}
