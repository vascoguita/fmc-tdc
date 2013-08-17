/*
 * Interrupt handling and timestamp readout for fmc-tdc driver.
 *
 * Copyright (C) 2012-2013 CERN (www.cern.ch)
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

#include <linux/zio.h>
#include <linux/zio-trigger.h>

#include "fmc-tdc.h"
#include "hw/tdc_regs.h"

static void ft_readout_tasklet(unsigned long arg);

int ft_read_sw_fifo(struct fmctdc_dev *ft, int channel,
		    struct zio_channel *chan)
{
	struct zio_control *ctrl;
	struct zio_ti *ti = chan->cset->ti;
	uint32_t *v;
	struct ft_wr_timestamp ts;
	struct ft_channel_state *st;
	unsigned long flags;

	st = &ft->channels[channel - 1];

	if (!chan->active_block)
		return -EAGAIN;

	if (!st->fifo.count)
		return -EAGAIN;

	/* Copy the sample to local storage */
	spin_lock_irqsave(&ft->lock, flags);
	ts = st->fifo.t[st->fifo.tail];
	st->fifo.tail++;
	if (st->fifo.tail == st->fifo.size)
		st->fifo.tail = 0;
	st->fifo.count--;

	spin_unlock_irqrestore(&ft->lock, flags);

	/* Write the timestamp in the trigger, it will reach the control */
	ti->tstamp.tv_sec = ts.seconds;
	ti->tstamp.tv_nsec = ts.coarse * 8;
	ti->tstamp_extra = ts.frac;

	/*
	 * This is different than it was. We used to fill the active block,
	 * but now zio copies chan->current_ctrl at a later time, so we
	 * must fill _those_ attributes instead
	 */
	/* The input data is written to attribute values in the active block. */
	ctrl = chan->current_ctrl;

	ctrl->tstamp.secs = ts.seconds;
	ctrl->tstamp.ticks = ts.coarse;
	ctrl->tstamp.bins = ts.frac;
	ctrl->nsamples = 1;

	v = ctrl->attr_channel.ext_val;

	v[FT_ATTR_TDC_SECONDS] = ts.seconds;
	v[FT_ATTR_TDC_COARSE] = ts.coarse;
	v[FT_ATTR_TDC_FRAC] = ts.frac;
	v[FT_ATTR_TDC_SEQ] = ts.seq_id;
	v[FT_ATTR_TDC_OFFSET] = ft->calib.zero_offset[channel - 1];
	v[FT_ATTR_TDC_USER_OFFSET] = st->user_offset;

	return 0;
}

static inline void enqueue_timestamp(struct fmctdc_dev *ft, int channel,
				     struct ft_wr_timestamp *ts)
{
	struct ft_sw_fifo *fifo = &ft->channels[channel - 1].fifo;
	unsigned long flags;

	/* fixme: consider independent locks for each channel. */
	spin_lock_irqsave(&ft->lock, flags);
	fifo->t[fifo->head] = *ts;
	fifo->head = (fifo->head + 1) % fifo->size;
	if (fifo->count < fifo->size)
		fifo->count++;
	else {
		fifo->tail = (fifo->tail + 1) % fifo->size;
	}
	spin_unlock_irqrestore(&ft->lock, flags);
}

static inline void process_timestamp(struct fmctdc_dev *ft,
				     struct ft_hw_timestamp *hwts,
				     int dacapo_flag)
{
	struct ft_channel_state *st;
	struct ft_wr_timestamp ts;

	int channel, edge, frac;

	channel = (hwts->metadata & 0x7) + 1;
	edge = hwts->metadata & (1 << 4) ? 1 : 0;

	st = &ft->channels[channel - 1];

	/* first, convert the timestamp from the HDL units (81 ps bins)
	   to the WR format (where fractional part is 8 ns rescaled to 4096 units) */

	ts.channel = channel;
	ts.seconds = hwts->utc;
	frac = hwts->bins * 81 * 64 / 125;	/* 64/125 = 4096/8000: reduce fraction to avoid 64-bit division */

	ts.coarse = hwts->coarse + frac / 4096;
	ts.frac = frac % 4096;

	/* the addition above may result with the coarse counter goint out of range: */
	if (unlikely(ts.coarse >= 125000000)) {
		ts.coarse -= 125000000;
		ts.seconds++;
	}

	/* A trivial state machine to remove glitches, react on rising edge only
	   and drop pulses that are narrower than 100 ns.

	   We are waiting for a falling edge, but a rising one occurs - ignore it. 
	 */
	if (unlikely(edge != st->expected_edge))
		st->expected_edge = 1;	/* wait unconditionally for next rising edge */
	else {

		if (st->expected_edge == 0) {	/* got a falling edge after a rising one */
			struct ft_wr_timestamp diff = ts;
			ft_ts_sub(&diff, &st->prev_ts);

			/* Check timestamp width. Must be at least 100 ns (coarse = 12, frac = 2048) */
			if (likely
			    (diff.seconds || diff.coarse > 12
			     || (diff.coarse == 12 && diff.frac >= 2048))) {
				ft_ts_apply_offset(&ts,
						   ft->
						   calib.zero_offset[channel -
								     1]);

				if (st->user_offset)
					ft_ts_apply_offset(&ts,
							   st->user_offset);

				/* Got a dacapo flag? make a gap in the sequence ID to indicate
				   an unknown loss of timestamps */

				ts.seq_id = st->cur_seq_id++;

				if (dacapo_flag) {
					ts.seq_id++;
					st->cur_seq_id++;
				}

				/* Put the timestamp in the FIFO */
				enqueue_timestamp(ft, channel, &ts);
			}
		} else
			st->prev_ts = ts;

		st->expected_edge = 1 - st->expected_edge;
	}
}

static irqreturn_t ft_irq_handler(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct fmctdc_dev *ft = fmc->mezzanine_data;

	/* called outside an IRQ context - probably from the polling timer simulating
	   the not-yet-supported IRQs on the SVEC */
	if (unlikely(!in_interrupt())) {
		ft_readout_tasklet((unsigned long)ft);
	} else
		tasklet_schedule(&ft->readout_tasklet);

	return IRQ_HANDLED;
}

static inline int check_lost_events(uint32_t curr_wr_ptr, uint32_t prev_wr_ptr,
				    int *count)
{
	uint32_t dacapo_prev, dacapo_curr;
	int dacapo_diff, ptr_diff = 0;

	dacapo_prev = prev_wr_ptr >> 12;
	dacapo_curr = curr_wr_ptr >> 12;
	curr_wr_ptr &= 0x00fff;	/* Pick last 12 bits */
	curr_wr_ptr >>= 4;	/* Remove last 4 bits. */
	prev_wr_ptr &= 0x00fff;	/* Pick last 12 bits */
	prev_wr_ptr >>= 4;	/* Remove last 4 bits. */
	dacapo_diff = dacapo_curr - dacapo_prev;

	switch (dacapo_diff) {

	case 1:
		ptr_diff = curr_wr_ptr - prev_wr_ptr;
		if (ptr_diff > 0) {
			*count = FT_BUFFER_EVENTS;
			return 1;	/* We lost data */
		}
		*count = curr_wr_ptr - prev_wr_ptr + FT_BUFFER_EVENTS;
		break;
	case 0:
		/* We didn't lose data */
		*count = curr_wr_ptr - prev_wr_ptr;
		break;
	default:
		/* We lost data for sure. Notify to the user */
		*count = FT_BUFFER_EVENTS;
		return 1;
	}

	return 0;
}

static void ft_readout_tasklet(unsigned long arg)
{
	struct fmctdc_dev *ft = (struct fmctdc_dev *)arg;
	struct fmc_device *fmc = ft->fmc;
	struct zio_device *zdev = ft->zdev;
	uint32_t rd_ptr;
	int count, dacapo, i;

	ft->prev_wr_ptr = ft->cur_wr_ptr;
	ft->cur_wr_ptr = ft_readl(ft, TDC_REG_BUFFER_PTR);

	/* read the timestamps via DMA - we read the whole buffer, it doesn't really matter
	   for the HW if it's 16 bytes or a 4k page */

	if (ft->carrier_specific->copy_timestamps(ft, 0,
						  FT_BUFFER_EVENTS *
						  sizeof(struct
							 ft_hw_timestamp),
						  ft->raw_events) < 0)
		return;		/* we can do nothing about this */

	dacapo = check_lost_events(ft->cur_wr_ptr, ft->prev_wr_ptr, &count);

	/* Start reading from the oldest event */
	if (count == FT_BUFFER_EVENTS)
		rd_ptr = (ft->cur_wr_ptr >> 4) & 0x000ff;	/* The oldest is curr_wr_ptr */
	else
		rd_ptr = (ft->prev_wr_ptr >> 4) & 0x000ff;	/* The oldest is prev_wr_ptr */

	for (; count > 0; count--) {
		process_timestamp(ft, &ft->raw_events[rd_ptr], dacapo);
		rd_ptr = (rd_ptr + 1) % FT_BUFFER_EVENTS;
	}

	if (!zdev)
		goto out;

	for (i = FT_CH_1; i <= FT_NUM_CHANNELS; i++) {
		struct ft_channel_state *st = &ft->channels[i - 1];
		/* FIXME: race condition */
		if (test_bit(FT_FLAG_CH_INPUT_READY, &st->flags)) {
			struct zio_cset *cset = &zdev->cset[i - 1];
			/* there is an active block, try reading an accumulated sample */
			if (ft_read_sw_fifo(ft, i, cset->chan) == 0) {
				clear_bit(FT_FLAG_CH_INPUT_READY, &st->flags);
				zio_trigger_data_done(cset);
			}
		}
	}

out:
	/* ack the irq */
	fmc_writel(ft->fmc, TDC_IRQ_TDC_TSTAMP << ft->irq_shift,
		   ft->ft_irq_base + TDC_REG_IRQ_STATUS);
	fmc->op->irq_ack(fmc);
}

int ft_irq_init(struct fmctdc_dev *ft)
{
	uint32_t irq_en;

	tasklet_init(&ft->readout_tasklet, ft_readout_tasklet,
		     (unsigned long)ft);

	/* disable coalescing, it's currently broken */
	ft_writel(ft, 1, TDC_REG_IRQ_THRESHOLD);
	ft_writel(ft, 0, TDC_REG_IRQ_TIMEOUT);

	/* enable timestamp readout irq */
	irq_en = fmc_readl(ft->fmc, ft->ft_irq_base + TDC_REG_IRQ_ENABLE);
	fmc_writel(ft->fmc, irq_en | (TDC_IRQ_TDC_TSTAMP << ft->irq_shift),
		   ft->ft_irq_base + TDC_REG_IRQ_ENABLE);

	/* configure the actual handler via a carrier-specific mechanism */
	return ft->carrier_specific->setup_irqs(ft, ft_irq_handler);
}

void ft_irq_exit(struct fmctdc_dev *ft)
{
	fmc_writel(ft->fmc, 0, ft->ft_irq_base + TDC_REG_IRQ_ENABLE);

	ft->carrier_specific->disable_irqs(ft);
}
