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

#define TDC_EIC_EIC_IMR_TDC_DMA_MASK (TDC_EIC_EIC_ISR_TDC_DMA1 | \
				      TDC_EIC_EIC_ISR_TDC_DMA2 |  \
				      TDC_EIC_EIC_ISR_TDC_DMA3 |  \
				      TDC_EIC_EIC_ISR_TDC_DMA4 |  \
				      TDC_EIC_EIC_ISR_TDC_DMA5)

#define TDC_EIC_EIC_IMR_TDC_FIFO_MASK (TDC_EIC_EIC_ISR_TDC_FIFO1 | \
				       TDC_EIC_EIC_ISR_TDC_FIFO2 | \
				       TDC_EIC_EIC_ISR_TDC_FIFO3 | \
				       TDC_EIC_EIC_ISR_TDC_FIFO4 | \
				       TDC_EIC_EIC_ISR_TDC_FIFO5)


/**
 * It converts a channel bitmask into an IRQ bitmask according to
 * the acquisition mode
 * @ft FmcTdc device instance
 * @chan_mask channel bitmask, a bit to one will enable the corresponding
 *            IRQ channel line
 *
 * Return: an IRQ bitmask
 */
static inline uint32_t ft_chan_to_irq_mask(struct fmctdc_dev *ft, uint32_t chan_mask)
{
	uint32_t mask = 0;

	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		mask = (chan_mask << 0) & TDC_EIC_EIC_IMR_TDC_FIFO_MASK;
		break;
	case FT_ACQ_TYPE_DMA:
		mask = (chan_mask << 5) & TDC_EIC_EIC_IMR_TDC_DMA_MASK;
		break;
	default:
		break;
	}
	return mask;
}

/**
 * It disbles interrupts on specific channels according to the given mask
 * @ft FmcTdc device instance
 * @chan_mask channel bitmask, a bit to one will disable the corresponding
 *            IRQ channel line
 */
static void ft_irq_disable_save(struct fmctdc_dev *ft)
{
	ft->irq_imr = ft_ioread(ft, ft->ft_irq_base + TDC_EIC_REG_EIC_IMR);
	ft_iowrite(ft, ft->irq_imr, ft->ft_irq_base + TDC_EIC_REG_EIC_IDR);
}

/**
 * It restores the previous known IRQ status
 * @ft FmcTdc device instance
 */
static void ft_irq_enable_restore(struct fmctdc_dev *ft)
{
	ft_iowrite(ft, ft->irq_imr, ft->ft_irq_base + TDC_EIC_REG_EIC_IER);
}

/**
 * It applies all calibration offsets to the givne timestamp
 * @ft FmcTdc device instance
 * @ts timestamp
 */
static void ft_timestamp_apply_offsets(struct fmctdc_dev *ft,
				       struct ft_hw_timestamp *hwts)
{
	unsigned int chan = FT_HW_TS_META_CHN(hwts->metadata);
	struct ft_channel_state *st = &ft->channels[chan];

	ft_ts_apply_offset(hwts, ft->calib.zero_offset[chan]);
	ft_ts_apply_offset(hwts, -ft->calib.wr_offset);
	if (st->user_offset)
		ft_ts_apply_offset(hwts, st->user_offset);
}

/**
 * It puts the given timestamp in the ZIO control
 * @cset ZIO cset instant
 * @hwts the timestamp to convert
 */
static void ft_zio_update_ctrl(struct zio_cset *cset,
			       struct ft_hw_timestamp *hwts)
{
	struct fmctdc_dev *ft = cset->zdev->priv_d;
	struct zio_control *ctrl;
	uint32_t *v;
	struct ft_channel_state *st;

	st = &ft->channels[cset->index];
	ctrl = cset->chan->current_ctrl;
	v = ctrl->attr_channel.ext_val;

	/* Write the timestamp in the trigger, it will reach the control */
	cset->ti->tstamp.tv_sec = hwts->seconds;
	cset->ti->tstamp.tv_nsec = hwts->coarse; /* we use 8ns steps */
	cset->ti->tstamp_extra = hwts->frac;

	/* Synchronize ZIO sequence number with ours (ZIO does +1 on this) */
	ctrl->seq_num = FT_HW_TS_META_SEQ(hwts->metadata) - 1;

	v[FT_ATTR_TDC_ZERO_OFFSET] = ft->calib.zero_offset[cset->index];
	v[FT_ATTR_TDC_USER_OFFSET] = st->user_offset;
}

/**
 * It changes the current acquisition buffer
 * @ft FmcTdc instance
 * @chan channel number [0, N-1]
 *
 * Return: it returns buffer index that needs to be transfered
 *
 * It stops acquisition to the 'current' buffer and switch to the 'next'
 * buffer. This works with the assumption that buffers are properly configured
 * with valid address and size.
 */
static unsigned int ft_buffer_switch(struct fmctdc_dev *ft, int chan)
{
	struct ft_channel_state *st = &ft->channels[chan];
	uint32_t base = ft->ft_dma_base + chan * 0x40;
	uint32_t csr, base_cur, base_next;
	unsigned int transfer_buffer;

	csr = ft_ioread(ft, base + TDC_BUF_REG_CSR);
	csr |= TDC_BUF_CSR_SWITCH_BUFFERS;
	ft_iowrite(ft, csr, base + TDC_BUF_REG_CSR);

	/*
	 * It waits until all pending DDR memory transactions from the active
	 * buffer are committed to the memory.
	 * This is almost instant (e.g. < 1us), but we never know with
	 * the PCs going ever faster
	 */
	while (!(ft_ioread(ft, base + TDC_BUF_REG_CSR) & TDC_BUF_CSR_DONE))
		;

	/* clear CSR.DONE flag (write 1) */
	csr = ft_ioread(ft, base + TDC_BUF_REG_CSR);
	csr |= TDC_BUF_CSR_DONE;
	ft_iowrite(ft, csr, base + TDC_BUF_REG_CSR);

	/*
	 * we have two buffers in the hardware: the current one and the 'next'
	 * one. From the point of view of this interrupt handler, the current
	 * one is to be read out and switched to the 'next' buffer.,
	 */
	transfer_buffer = st->active_buffer;
	base_cur = st->buf_addr[st->active_buffer];

	st->active_buffer = 1 - st->active_buffer;
	base_next = st->buf_addr[st->active_buffer];


	/* update the pointer to the next buffer */
	ft_iowrite(ft, base_cur, base + TDC_BUF_REG_NEXT_BASE);
	ft_iowrite(ft, st->buf_size | TDC_BUF_NEXT_SIZE_VALID,
		   base + TDC_BUF_REG_NEXT_SIZE);

	return transfer_buffer;
}

/**
 * It gets the current number of timestamps in the buffer
 * @ft FmcTdc instance
 * @chan channel number [0, N -1]
 *
 * Please note that the returned value refers to the last 'acquired'
 * buffer. In other words, after ft_buffer_switch() the acquisition will
 * continue on the next buffer and we get the sample counter from the current
 * buffer
 */
static unsigned int ft_buffer_count(struct fmctdc_dev *ft, unsigned int chan)
{
	uint32_t base = ft->ft_dma_base + chan * 0x40;

	return ft_ioread(ft,  base + TDC_BUF_REG_CUR_COUNT);
}

static void ft_readout_dma_run(struct zio_cset *cset,
			       unsigned int base_cur,
			       unsigned int start,
			       unsigned int count)
{
	struct fmctdc_dev *ft = cset->zdev->priv_d;
	struct ft_hw_timestamp *dma_buf;
	unsigned int len = count * sizeof(*dma_buf);
	unsigned int devmem = base_cur + (start * sizeof(*dma_buf));
	int i;

	if (unlikely(!(cset->ti->flags & ZIO_TI_ARMED))) {
		dev_info(&cset->head.dev,
			 "ZIO trigger not armed\n");
		return;
	}
	if (unlikely(cset->chan->active_block == NULL)) {
		dev_info(&cset->head.dev,
			 "ZIO not armed properly, block missing\n");
		return;
	}

	dev_dbg(&cset->head.dev,
		 "0x%x(0x%x + %ld), %d(%d * %ld) %d\n",
		 devmem, base_cur, (start * sizeof(*dma_buf)),
		 len, count, sizeof(*dma_buf),
		 start);

	dma_buf = cset->chan->active_block->data;
	dma_buf += start;
	gn4124_dma_read(ft, devmem, dma_buf, len);
	gn4124_dma_wait_done(ft);

	for(i = start; i < start + count; ++i) {
		dev_dbg(&cset->head.dev, "TS%d %d.%d.%d 0x%x\n", i,
			dma_buf[i].seconds, dma_buf[i].coarse,
			dma_buf[i].frac, dma_buf[i].metadata);
		ft_timestamp_apply_offsets(ft, &dma_buf[i]);
	}

	ft_zio_update_ctrl(cset, &dma_buf[0]);
}

/**
 * @ft FmcTdc instance
 * @chan channel number [0, N -1]
 */
static void ft_readout_dma_start(struct fmctdc_dev *ft, int channel)
{
	struct ft_channel_state *st = &ft->channels[channel];
	uint32_t base_cur;
	struct zio_cset *cset = &ft->zdev->cset[channel];
	unsigned long flags;
	unsigned int transfer;
	unsigned int count; /* number of timestamps currently transfered */
	unsigned int total; /* total number of timestamps to transfer */

	transfer = ft_buffer_switch(ft, channel);
	total = ft_buffer_count(ft, channel);
	base_cur = st->buf_addr[transfer];

	count = 0;
	while (total > 0) {
		cset->ti->nsamples  = min((unsigned long)total,
					  KMALLOC_MAX_SIZE);
		zio_arm_trigger(cset->ti);
		ft_readout_dma_run(cset, base_cur, count, cset->ti->nsamples);
		zio_trigger_data_done(cset);

		spin_lock_irqsave(&cset->lock, flags);
		/* set in cset->raw_io (within ARM) */
		cset->flags &= ~ZIO_CSET_HW_BUSY;
		spin_unlock_irqrestore(&cset->lock, flags);

		count += cset->ti->nsamples;
		total -= cset->ti->nsamples;
	}
}

/**
 * It transfers timestamps from the DDR
 */
static void ft_dma_work(struct work_struct *work)
{
	struct fmctdc_dev *ft = container_of(work, struct fmctdc_dev,
					     ts_work);
	uint32_t irq_stat;
	int i;
	unsigned long *loop;

	irq_stat = ft_ioread(ft, ft->ft_irq_base + TDC_EIC_REG_EIC_ISR);
	if (!(irq_stat & TDC_EIC_EIC_IMR_TDC_DMA_MASK)) {
		dev_warn(&ft->fmc->dev,
			 "Expected DMA interrupt but got 0x%x\n", irq_stat);
		return;
	}

	loop = (unsigned long *) &irq_stat;
	for_each_set_bit(i, loop, FT_NUM_CHANNELS)
		ft_readout_dma_start(ft, i);

	/* Re-Enable interrupts that where disabled in the IRQ handler */
	ft_irq_enable_restore(ft);
}

/**
 * Get a time stamp from the fifo, if you set the 'last' flag it takes the last
 * recorded time-stamp
 */
static int ft_timestap_get(struct zio_cset *cset, struct ft_hw_timestamp *hwts,
			   unsigned int last)
{
	struct fmctdc_dev *ft = cset->zdev->priv_d;
	uint32_t fifo_addr = ft->ft_fifo_base + TDC_FIFO_OFFSET * cset->index;
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
	struct fmctdc_dev *ft = cset->zdev->priv_d;
	struct ft_hw_timestamp *hwts;

	cset->ti->nsamples = 1;
	zio_arm_trigger(cset->ti);
	if (!cset->chan->active_block)
		goto out;
	hwts = cset->chan->active_block->data;

	ft_timestap_get(cset, hwts, 0);
	ft_timestamp_apply_offsets(ft, hwts);

	ft_zio_update_ctrl(cset, hwts);
out:
	zio_trigger_data_done(cset);
}

static void ft_fifo_work(struct work_struct *work)
{
	struct fmctdc_dev *ft = container_of(work, struct fmctdc_dev,
					     ts_work);
	uint32_t irq_stat, tmp_irq_stat, fifo_stat, fifo_csr_addr;
	unsigned long *loop;
	struct zio_cset *cset;
	int i;

	irq_stat = ft_ioread(ft, ft->ft_irq_base + TDC_EIC_REG_EIC_ISR);
	if (!(irq_stat & TDC_EIC_EIC_IMR_TDC_FIFO_MASK)) {
		dev_warn(&ft->fmc->dev,
			 "Expected FIFO interrupt but got 0x%x\n", irq_stat);
		return;
	}

irq:
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
		loop = (unsigned long *) &tmp_irq_stat;
		for_each_set_bit(i, loop, FT_NUM_CHANNELS) {
			cset = &ft->zdev->cset[i];
			ft_readout_fifo_one(cset);
			fifo_csr_addr = ft->ft_fifo_base +
				TDC_FIFO_OFFSET * cset->index + TDC_FIFO_CSR;
			fifo_stat = ft_ioread(ft, fifo_csr_addr);
			if (!(fifo_stat & TDC_FIFO_CSR_EMPTY))
				continue; /* Still something to read */

			/* Ack the interrupt, nothing to read anymore */
			ft_iowrite(ft, 1 << i,
				   ft->ft_irq_base + TDC_EIC_REG_EIC_ISR);
			tmp_irq_stat &= (~(1 << i));
		}
	} while (tmp_irq_stat);

	/* Meanwhile we got another interrupt? then repeat */
	irq_stat = ft_ioread(ft, ft->ft_irq_base + TDC_EIC_REG_EIC_ISR);
	if (irq_stat)
		goto irq;

	/* Re-Enable interrupts that where disabled in the IRQ handler */
	ft_irq_enable_restore(ft);
	return;
}



static irqreturn_t ft_irq_handler_dma_complete(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct fmctdc_dev *ft = fmc->mezzanine_data;
	uint32_t irq_stat;

	irq_stat = ft_ioread(ft, ft->ft_dma_eic_base + DMA_EIC_REG_EIC_ISR);
	if (!irq_stat)
		return IRQ_NONE;
	ft_iowrite(ft, irq_stat, ft->ft_irq_base + TDC_EIC_REG_EIC_ISR);

	fmc_irq_ack(fmc);

	dev_info(&ft->fmc->dev, "DMA interupt %x %x\n",
		 ft->ft_dma_eic_base, irq_stat);



	return IRQ_HANDLED;
}


static irqreturn_t ft_irq_handler_ts(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct fmctdc_dev *ft = fmc->mezzanine_data;
	uint32_t irq_stat;

	irq_stat = ft_ioread(ft, ft->ft_irq_base + TDC_EIC_REG_EIC_ISR);
	if (!irq_stat)
		return IRQ_NONE;

	/* Disable interrupts until we fetch all stored samples */
	ft_irq_disable_save(ft);

	queue_work(ft_workqueue, &ft->ts_work);

	/* Ack the FMC signal, we have finished */
	fmc_irq_ack(fmc);

	return IRQ_HANDLED;
}


int ft_irq_init(struct fmctdc_dev *ft)
{
	int ret;

	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		ft_writel(ft, 40, TDC_REG_IRQ_THRESHOLD);
		ft_writel(ft, 40, TDC_REG_IRQ_TIMEOUT);

		INIT_WORK(&ft->ts_work, ft_fifo_work);
		break;
	case FT_ACQ_TYPE_DMA:
		INIT_WORK(&ft->ts_work, ft_dma_work);
		break;
	}

	ft->fmc->irq = ft->ft_irq_base;
	ret = fmc_irq_request(ft->fmc, ft_irq_handler_ts,
			      "fmc-tdc", 0);
	if (ret < 0) {
		dev_err(&ft->fmc->dev,
			"Request interrupt failed: %d\n",
			ret);
		return ret;
	}

	if (ft->mode == FT_ACQ_TYPE_DMA) {
		/*
		 * DMA completion interrupt (from the GN4124 core), like in
		 * the FMCAdc design
		 */
		ft->fmc->irq = ft->ft_irq_base + 1;
		ret = fmc_irq_request(ft->fmc, ft_irq_handler_dma_complete,
				      "fmc-tdc-dma", 0);
	}

	/* kick off the interrupts (fixme: possible issue with the HDL) */
	fmc_irq_ack(ft->fmc);

	/*
	 * We enable interrupts on all channel. but if we do not enable
	 * the channel, we should not receive anything. So, even if ZIO is
	 * not ready to receive data at this time we should not see any trouble.
	 * If we have problems here, the HDL is broken!
	 */
	if (ft->mode == FT_ACQ_TYPE_DMA) {
		ft_iowrite(ft,
			   DMA_EIC_EIC_IER_DMA_DONE | DMA_EIC_EIC_IER_DMA_ERROR,
			   ft->ft_dma_eic_base + DMA_EIC_REG_EIC_IER);

	}
	ft_iowrite(ft, ft_chan_to_irq_mask(ft, 0x1F),
		   ft->ft_irq_base + TDC_EIC_REG_EIC_IER);

	return 0;
}

void ft_irq_exit(struct fmctdc_dev *ft)
{
	ft_iowrite(ft, ~0, ft->ft_irq_base + TDC_EIC_REG_EIC_IDR);
	if (ft->mode == FT_ACQ_TYPE_DMA) {
		ft_iowrite(ft,
			   DMA_EIC_EIC_IDR_DMA_DONE | DMA_EIC_EIC_IDR_DMA_ERROR,
			   ft->ft_dma_eic_base + DMA_EIC_REG_EIC_IER);
	}

	ft->fmc->irq = ft->ft_irq_base;
	fmc_irq_free(ft->fmc);

	if (ft->mode == FT_ACQ_TYPE_DMA) {
		ft->fmc->irq = ft->ft_irq_base + 1;
		fmc_irq_free(ft->fmc);
	}
}
