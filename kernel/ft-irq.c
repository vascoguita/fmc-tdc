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
 * SPDX-License-Identifier: GPL-2.0-or-later
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

static void start_readout(struct fmctdc_dev *ft, int channel)
{
	struct ft_channel_state *st = &ft->channels[channel - 1];
	uint32_t base_cur, base_next, csr, count;
	uint32_t base = ft->ft_buffer_base + (channel - 1) * 0x40;
	struct ft_hw_timestamp *dma_buf;
	const int ts_per_page = PAGE_SIZE / TDC_BYTES_PER_TIMESTAMP;

	/*
	 * we have two buffers in the hardware: the current one and the 'next'
	 * one. From the point of view of this interrupt handler, the current
	 * one is to be read out and switched to the 'next' buffer.,
	 */
	base_cur = st->buf_addr[st->active_buffer];
	base_next = st->buf_addr[1 - st->active_buffer];

	/* ugly hack to check if readout is correct */
	dma_buf = kmalloc(4096, GFP_ATOMIC);

	// after the readout, the next buffer will be the one we've just read
	st->active_buffer = 1 - st->active_buffer;


	/*
	 * stop acquisition to the 'current' buffer and switch to the 'next'
	 * buffer. Note that this handler assumes the TDC_BUF_REG_NEXT contain
	 * valid buffer address/size.
	 */
	csr = ft_ioread(ft, base + TDC_BUF_REG_CSR);
	ft_iowrite(ft, csr | TDC_BUF_CSR_SWITCH_BUFFERS,
		   base + TDC_BUF_REG_CSR);

	csr = ft_ioread(ft, base + TDC_BUF_REG_CSR);

	/*
	 * wait until all pending DDR memory transactions from the active
	 * buffer are committed to the memory.
	 * this is almost instant (e.g. < 1us), but we never know with
	 * the PCs going ever faster
	 */
	while (!(csr & TDC_BUF_CSR_DONE))
		csr = ft_ioread(ft, base + TDC_BUF_REG_CSR);

	/* clear CSR.DONE flag (write 1) */
	ft_iowrite(ft, csr | TDC_BUF_CSR_DONE, base + TDC_BUF_REG_CSR);

	/* read the number of the timetamps in the current buffer */
	count = ft_ioread(ft,  base + TDC_BUF_REG_CUR_COUNT);

	/* update the pointer to the next buffer */
	ft_iowrite(ft, base_cur, base + TDC_BUF_REG_NEXT_BASE);
	ft_iowrite(ft, st->buf_size | TDC_BUF_NEXT_SIZE_VALID,
		   base + TDC_BUF_REG_NEXT_SIZE);

	/*
	 * now we DMA the data. use a workqueue or something, the DMA call
	 * below is blocking and is there just to validate the bitstream
	 */
	while (count > 0) {
		int i, n = (count > ts_per_page ? ts_per_page : count);

		dev_info(&ft->fmc->dev, "dma_read: %x %p %d\n",
			 base_cur, dma_buf,
			 n * TDC_BYTES_PER_TIMESTAMP);

		gn4124_dma_read(ft, base_cur, dma_buf,
				n * TDC_BYTES_PER_TIMESTAMP);

		/* gn4124_dma_read(ft->fmc, 0, dma_buf, 16); */

		for (i = 0; i < n; i++)
			dev_info(&ft->fmc->dev, "Ts %x %x %x %x\n",
			       dma_buf[i].utc, dma_buf[i].coarse,
				 dma_buf[i].frac, dma_buf[i].metadata);

		base_cur += n * TDC_BYTES_PER_TIMESTAMP;
		count -= n;
	}
	kfree(dma_buf);
}

static irqreturn_t ft_irq_handler_dma_complete(int irq, void *dev_id)
{

	return IRQ_HANDLED;
}


/*
 * Interrupt handler called when the active buffer has some timestamps
 * (at least one) and the IRQ timeout has expired (default= 10ms, set
 * in the TDC_BUF_CSR register).
 */
static irqreturn_t ft_irq_handler_dma(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct fmctdc_dev *ft = fmc->mezzanine_data;
	uint32_t irq_stat, tmp_irq_stat, fifo_stat, fifo_csr_addr;
	struct zio_cset *cset;
	int i;

	irq_stat = ft_ioread(ft, ft->ft_irq_base + TDC_REG_EIC_ISR);

	if (!irq_stat)
		return IRQ_NONE;

	dev_info(&fmc->dev, "pending IRQ 0x%x\n", irq_stat);

	for (i = FT_CH_1; i <= FT_NUM_CHANNELS; i++) {
		if (!(irq_stat & (1 << (i - 1))))
			continue;

		/* trigger readout from the channel that has some data */
		start_readout(ft, i);

		/* clear the interrupt */
		ft_iowrite(ft, 1 << (i-1),
			   ft->ft_irq_base + TDC_REG_EIC_ISR);

	}

	/* Ack the FMC signal, we have finished */
	fmc_irq_ack(fmc);

	return IRQ_HANDLED;
}


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

	/*
	 * Update last time stamp of the current channel, with the current
	 * time-stamp
	 */
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
			memset(&ts, 0, sizeof(struct ft_wr_timestamp));
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
				    struct ft_wr_timestamp *wrts)
{
	struct zio_device *zdev = cset->zdev;
	struct fmctdc_dev *ft = zdev->priv_d;
	struct ft_channel_state *st;
	struct ft_wr_timestamp ts;
	struct ft_wr_timestamp diff;
	int channel, edge, frac, ret = 0;

	st = &ft->channels[cset->index];

	dev_info(&ft->fmc->dev, "process TS(%p): 0x%x 0x%x 0x%x 0x%x\n",
		hwts, hwts->metadata, hwts->utc, hwts->coarse, hwts->frac);
	channel = (hwts->metadata & 0x7);
	/* channel from 1 to 5, cset is from 0 to 4 */
	if (channel != cset->index) {
		dev_err(&ft->fmc->dev,
			"reading from the wrong channel (expected %d, given %d)\n",
			channel, cset->index);
		return 0;
	}

	ts.channel = channel + 1; /* We want to see channels starting from 1*/
	ts.seconds = hwts->utc;
	ts.coarse = hwts->coarse;
	ts.frac = hwts->frac;

	ft_ts_apply_offset(&ts, ft->calib.zero_offset[channel - 1]);

	ft_ts_apply_offset(&ts, -ft->calib.wr_offset);
	if (st->user_offset)
		ft_ts_apply_offset(&ts, st->user_offset);

	ts.gseq_id = ft->sequence++;
	ts.hseq_id = hwts->metadata >> 5;

	*wrts = ts;
	ret = 1;

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
	uint32_t data[TDC_FIFO_OUT_N];
	int i, valid = 1;

	fifo_addr += last ? TDC_FIFO_LAST : TDC_FIFO_OUT;
	for (i = 0; i < TDC_FIFO_OUT_N; ++i) {
		data[i] = ft_ioread(ft, fifo_addr + i * 4);
		dev_vdbg(&cset->head.dev, "FIFO read 0x%x from 0x%x\n",
			 data[i], fifo_addr + i * 4);
	}

	if (last) {
		valid = !!(ft_ioread(ft, fifo_addr + TDC_FIFO_LAST_CSR) &
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
	int ret;

	ft_timestap_get(cset, &hwts, 0);

	ret = process_timestamp(cset, &hwts, &wrts);
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
static irqreturn_t ft_irq_handler_fifo(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct fmctdc_dev *ft = fmc->mezzanine_data;
	uint32_t irq_stat, tmp_irq_stat, fifo_stat, fifo_csr_addr;
	struct zio_cset *cset;
	int i;

	irq_stat = ft_ioread(ft, ft->ft_irq_base + TDC_REG_EIC_ISR);
	if (!irq_stat)
		return IRQ_NONE;

irq:
	dev_vdbg(&ft->fmc->dev, "pending IRQ 0x%x\n", irq_stat);
	/*
	 * Go through all FIFOs and read data. Democracy is a complicated
	 * thing, the following loops is a democratic loop, so it goes trough
	 * all channels without any priority. This avoid to be late to read
	 * the last channel on high frequency where the risk is to have an
	 * oligarchy where the first and second channel are read, but not the
	 * others.
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
			fifo_stat = ft_ioread(ft, fifo_csr_addr);
			if (!(fifo_stat & TDC_FIFO_CSR_EMPTY))
				continue; /* Still something to read */

			/* Ack the interrupt, nothing to read anymore */
			ft_iowrite(ft, 1 << i,
				   ft->ft_irq_base + TDC_REG_EIC_ISR);
			tmp_irq_stat &= (~(1 << i));
		}
	} while (tmp_irq_stat);

	/* Meanwhile we got another interrupt? then repeat */
	irq_stat = ft_ioread(ft, ft->ft_irq_base + TDC_REG_EIC_ISR);
	if (irq_stat)
		goto irq;

	/* Ack the FMC signal, we have finished */
	fmc_irq_ack(fmc);

	return IRQ_HANDLED;
}



int ft_irq_init(struct fmctdc_dev *ft)
{
	int ret;

	/* IRQ coalescing: 40 timestamps or 40 milliseconds */
	/* fixme : only applicable to FIFO readout */
	ft_writel(ft, 40, TDC_REG_IRQ_THRESHOLD);
	ft_writel(ft, 40, TDC_REG_IRQ_TIMEOUT);

	/* disable timestamp readout IRQ, user will enable it manually */
	ft_iowrite(ft, 0x1F, ft->ft_irq_base + TDC_REG_EIC_IDR);

	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		ft->fmc->irq = ft->ft_irq_base;
		ret = fmc_irq_request(ft->fmc, ft_irq_handler_fifo,
				      "fmc-tdc", 0);
		if (ret < 0) {
			dev_err(&ft->fmc->dev,
				"Request interrupt failed: %d\n",
				ret);
			return ret;
		}

		break;

	case FT_ACQ_TYPE_DMA:
		ft->fmc->irq = ft->ft_irq_base;
		ret = fmc_irq_request(ft->fmc, ft_irq_handler_dma, "fmc-tdc", 0);
		if (ret < 0) {
			dev_err(&ft->fmc->dev,
				"Request interrupt failed: %d\n",
				ret);
			return ret;
		}
#if 0
		/*
		 * DMA completion interrupt (from the GN4124 core), like in
		 * the FMCAdc design
		 */
		ft->fmc->irq = ft->ft_irq_base + 1;
		ret = fmc_irq_request(ft->fmc, ft_irq_handler_dma_complete,
				      "fmc-tdc-dma", 0);
#endif
		break;
	default:
		WARN(1, "Uknonw acquisition type\n");
		break;
	}


	/* kick off the interrupts (fixme: possible issue with the HDL) */
	fmc_irq_ack(ft->fmc);

	return 0;
}

void ft_irq_exit(struct fmctdc_dev *ft)
{
	ft_iowrite(ft, ~0, ft->ft_irq_base + TDC_REG_EIC_IDR);
	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		ft->fmc->irq = ft->ft_irq_base;
		fmc_irq_free(ft->fmc);
		break;
	case FT_ACQ_TYPE_DMA:
		ft->fmc->irq = ft->ft_irq_base;
		fmc_irq_free(ft->fmc);

		ft->fmc->irq = ft->ft_irq_base + 1;
		fmc_irq_free(ft->fmc);
		break;
	default:
		WARN(1, "Uknonw acquisition type\n");
		break;
	}
}
