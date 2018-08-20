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
 * It tells if the trigger is armed or not
 * @ti trigger instance
 *
 * Return 1 when armed, 0 when un-armed
 */
static inline int zio_trigger_is_armed(struct zio_ti *ti)
{
	return !!(ti->flags & ZIO_TI_ARMED);
}

/**
 * It tells if the channel has an active block
 * @chan channel instance
 *
 * Return 1 when it has an active block, 0 when it has not an active block
 */
static inline int zio_chan_has_active_block(struct zio_channel *chan)
{
	return !!(chan->active_block);
}

/**
 * It tells if the acquisition can be done.
 * @cset channel set instance
 *
 * It returns 1, if at least 1 channel is ready for acquisition
 *
 * Return: 1 when it is possible to acquire, 0 when it is not possible
 *         to acquire
 */
static int zio_cset_can_acquire(struct zio_cset *cset)
{
	int i;

	if (!zio_trigger_is_armed(cset->ti))
		return 0;

	for (i = 0; i < cset->n_chan; ++i) {
		if (zio_chan_has_active_block(&cset->chan[i]))
			break;
	}
	if (i == cset->n_chan)
		return 0;

	return 1;
}


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
	gn4124_dma_read(ft, devmem, dma_buf, len);
	gn4124_dma_wait_done(ft);
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
		zio_cset_busy_set(cset, 1);
		zio_arm_trigger(cset->ti); /* actually a fire */
		ft_readout_dma_run(cset, base_cur, count, cset->ti->nsamples);
		zio_cset_busy_clear(cset, 1);
		zio_trigger_data_done(cset);

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
		goto out;
	}

	loop = (unsigned long *) &irq_stat;
	for_each_set_bit(i, loop, FT_NUM_CHANNELS)
		ft_readout_dma_start(ft, i);
out:
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
	struct ft_hw_timestamp *hwts;

	cset->ti->nsamples = 1;
	zio_arm_trigger(cset->ti);
	if (!cset->chan->active_block)
		goto out;
	hwts = cset->chan->active_block->data;

	ft_timestap_get(cset, hwts, 0);
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
	ft_iowrite(ft, irq_stat, ft->ft_dma_eic_base + TDC_EIC_REG_EIC_ISR);

	if (unlikely(irq_stat & DMA_EIC_EIC_ISR_DMA_ERROR))
		dev_info(&ft->fmc->dev, "DMA interrupt ERROR %x\n",
			 irq_stat);

	fmc_irq_ack(fmc);

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
