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
#include <linux/moduleparam.h>

#include <linux/zio.h>
#include <linux/zio-trigger.h>
#include <linux/zio-buffer.h>

#include "fmc-tdc.h"
#include "hw/timestamp_fifo_regs.h"

/* Module parameters */
static int irq_timeout_ms_default = 10;
module_param_named(irq_timeout_ms, irq_timeout_ms_default, int, 0444);
MODULE_PARM_DESC(irq_timeout_ms, "IRQ coalesing timeout (default: 10ms).");

#define TDC_EIC_EIC_IMR_TDC_DMA_SHIFT 5
#define TDC_EIC_EIC_IMR_TDC_DMA_MASK (TDC_EIC_EIC_ISR_TDC_DMA1 | \
				      TDC_EIC_EIC_ISR_TDC_DMA2 |  \
				      TDC_EIC_EIC_ISR_TDC_DMA3 |  \
				      TDC_EIC_EIC_ISR_TDC_DMA4 |  \
				      TDC_EIC_EIC_ISR_TDC_DMA5)

#define TDC_EIC_EIC_IMR_TDC_FIFO_SHIFT 0
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
 *
 * NOTE Use it **only** in the DMA Buffer IRQ handler
 *
 * We do not use any spinlock here. This function should be called
 * only by ft_irq_handler_ts_dma() and nobody else. Since this piece
 * of code disables interrupts, there is no risk that it can run because
 * of ft_irq_handler_ts_dma().
 */
static void ft_irq_disable_save(struct fmctdc_dev *ft)
{
	ft->irq_imr = ft_ioread(ft, ft->ft_irq_base + TDC_EIC_REG_EIC_IMR);
	ft_iowrite(ft, ft->irq_imr, ft->ft_irq_base + TDC_EIC_REG_EIC_IDR);
}

/**
 * It restores the previous known IRQ status
 * @ft FmcTdc device instance
 *
 * NOTE: Use it only in the DMA completion handler
 *
 * We do not use any spinlock here. This function should be called
 * only by ft_irq_handler_dma_complete() and nobody else. This handler can
 * run only after ft_irq_handler_ts_dma() successfully complete; within this
 * time IRQ are disabled, so nobody can touch ``irq_imr``
 */
static void ft_irq_enable_restore(struct fmctdc_dev *ft)
{
	ft_iowrite(ft, ft->irq_imr, ft->ft_irq_base + TDC_EIC_REG_EIC_IER);
	ft->irq_imr = 0;
}


/**
 * It configures the gennum to run a DMA transfer
 */
static int gennum_dma_fill(struct zio_dma_sg *zsg)
{
	struct gncore_dma_item *item = (struct gncore_dma_item *)zsg->page_desc;
	struct scatterlist *sg = zsg->sg;
	struct zio_channel *chan = zsg->zsgt->chan;
	struct fmctdc_dev *ft = chan->cset->zdev->priv_d;
	dma_addr_t tmp;

	/* Prepare DMA item */
	item->start_addr = zsg->dev_mem_off;
	item->dma_addr_l = sg_dma_address(sg) & 0xFFFFFFFF;
	item->dma_addr_h = (uint64_t)sg_dma_address(sg) >> 32;
	item->dma_len = sg_dma_len(sg);

	if (!sg_is_last(sg)) {/* more transfers */
		/* uint64_t so it works on 32 and 64 bit */
		tmp = zsg->zsgt->dma_page_desc_pool;
		tmp += (zsg->zsgt->page_desc_size * (zsg->page_idx + 1));
		item->next_addr_l = ((uint64_t)tmp) & 0xFFFFFFFF;
		item->next_addr_h = ((uint64_t)tmp) >> 32;
		item->attribute = GENNUM_DMA_ATTR_MORE; /* more items */
	} else {
		item->attribute = 0x0;	/* last item */
	}

	/* The first item is written on the device */
	if (zsg->page_idx == 0)
		gn4124_dma_config(ft, item);

	dev_dbg(ft->fmc->hwdev, "DMA item %d (block %d)\n"
		"    pool   0x%llx\n"
		"    addr   0x%x\n"
		"    addr_l 0x%x\n"
		"    addr_h 0x%x\n"
		"    length %d\n"
		"    next_l 0x%x\n"
		"    next_h 0x%x\n"
		"    attr   0x%x\n",
		zsg->page_idx, zsg->block_idx,
		zsg->zsgt->dma_page_desc_pool + (zsg->zsgt->page_desc_size * zsg->page_idx),
		item->start_addr, item->dma_addr_l, item->dma_addr_h,
		item->dma_len, item->next_addr_l, item->next_addr_h,
		item->attribute);

	return 0;
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

/**
 * Get a time stamp from the fifo, if you set the 'last' flag it takes the last
 * recorded time-stamp
 */
static int ft_timestamp_get(struct zio_cset *cset, struct ft_hw_timestamp *hwts)
{
	struct fmctdc_dev *ft = cset->zdev->priv_d;
	uint32_t fifo_addr = ft->ft_fifo_base + TDC_FIFO_OFFSET * cset->index;

	hwts->seconds = ft_ioread(ft, fifo_addr + TSF_REG_FIFO_R0);
	hwts->coarse = ft_ioread(ft, fifo_addr + TSF_REG_FIFO_R1);
	hwts->frac = ft_ioread(ft, fifo_addr + TSF_REG_FIFO_R2);
	hwts->metadata = ft_ioread(ft, fifo_addr + TSF_REG_FIFO_R3);

	return 1;
}

/**
 * Extract a timestamp from the FIFO
 */
static void ft_readout_fifo_one(struct zio_cset *cset)
{
	struct fmctdc_dev *ft;
	struct ft_hw_timestamp *hwts;
	struct ft_channel_state *st;

	ft = cset->zdev->priv_d;
	st = &ft->channels[cset->index];

	cset->ti->nsamples = 1;
	zio_arm_trigger(cset->ti);
	if (!cset->chan->active_block)
		goto out;
	hwts = cset->chan->active_block->data;

	ft_timestamp_get(cset, hwts);
out:
	zio_trigger_data_done(cset);
	st->stats.received++;
	st->stats.transferred++;
}


/**
 * It aborts a running acquisition
 * @cset ZIO channel set
 */
static void ft_abort_acquisition(struct zio_cset *cset)
{
	struct fmctdc_dev *ft = cset->zdev->priv_d;

	gn4124_dma_abort(ft);
	zio_cset_busy_clear(cset, 1);
	zio_trigger_abort_disable(cset, 0);
}

static irqreturn_t ft_irq_handler_dma_complete(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct fmctdc_dev *ft = fmc->mezzanine_data;
	uint32_t irq_stat;
	unsigned long *loop;
	int i;

	irq_stat = ft_ioread(ft, ft->ft_dma_eic_base + DMA_EIC_REG_EIC_ISR);
	if (!irq_stat)
		return IRQ_NONE;
	ft_iowrite(ft, irq_stat, ft->ft_dma_eic_base + TDC_EIC_REG_EIC_ISR);

	loop = (unsigned long *) &ft->dma_chan_mask;

	if (WARN(!ft->zdma, "DMA not programmed correctly ")) {
		for_each_set_bit(i, loop, FT_NUM_CHANNELS)
			ft_abort_acquisition(&ft->zdev->cset[i]);
		goto out;
	}

	zio_dma_unmap_sg(ft->zdma);
	zio_dma_free_sg(ft->zdma);

	for_each_set_bit(i, loop, FT_NUM_CHANNELS)
		zio_cset_busy_clear(&ft->zdev->cset[i], 1);

	if (irq_stat & DMA_EIC_EIC_IDR_DMA_ERROR) {
		dev_err(ft->fmc->hwdev, "0x%X 0x%X",
			irq_stat, dma_readl(ft, GENNUM_DMA_STA));

		for_each_set_bit(i, loop, FT_NUM_CHANNELS)
			ft_abort_acquisition(&ft->zdev->cset[i]);
		goto out;
	}

	/* perhpas WQ: it processes data */
	for_each_set_bit(i, loop, FT_NUM_CHANNELS) {
		zio_trigger_data_done(&ft->zdev->cset[i]);
		ft->channels[i].stats.transferred += ft->zdev->cset[i].ti->nsamples;
	}

out:
	fmc_irq_ack(fmc);

	/* Re-Enable interrupts that were disabled in the IRQ handler */
	ft_irq_enable_restore(ft);

	return IRQ_HANDLED;
}

/**
 * It gets the IRQ buffer status
 * @ft FmcTdc instance
 *
 * Return: IRQ buffer status
 */
static inline uint32_t ft_irq_buff_status(struct fmctdc_dev *ft)
{
	uint32_t irq_stat, imr;

	irq_stat = ft_ioread(ft, ft->ft_irq_base + TDC_EIC_REG_EIC_ISR);
	imr = ft_ioread(ft, ft->ft_irq_base + TDC_EIC_REG_EIC_IMR);

	return irq_stat & imr;
}

/**
 * It gets the IRQ buffer status
 * @ft FmcTdc instance
 *
 * Return: IRQ buffer status
 */
static inline uint32_t ft_irq_fifo_status(struct fmctdc_dev *ft)
{
	uint32_t irq_stat;

	irq_stat = ft_ioread(ft, ft->ft_irq_base + TDC_EIC_REG_EIC_ISR);
	return irq_stat & TDC_EIC_EIC_IMR_TDC_FIFO_MASK;
}

/**
 * It validates the IRQ status
 * @ft FmcTdc instance
 *
 * This is a paranoiac check, but experience tells that with this design
 * it is better to double check
 *
 * Return: 1 if it is valid, otherwise 0
 */
static inline unsigned int ft_irq_status_is_valid(struct fmctdc_dev *ft,
						  uint32_t irq_stat)
{
	uint32_t chan_stat;

	chan_stat = ft_readl(ft, TDC_REG_INPUT_ENABLE);
	chan_stat &= TDC_INPUT_ENABLE_CH_ALL;
	chan_stat >>= TDC_INPUT_ENABLE_CH1_SHIFT;
	chan_stat = ft_chan_to_irq_mask(ft, chan_stat);

	return !WARN((chan_stat & irq_stat) == 0,
		    "Received an unexpected interrupt: 0x%X 0x%X\n",
		    chan_stat, irq_stat);
}

static irqreturn_t ft_irq_handler_ts_fifo(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct fmctdc_dev *ft = fmc->mezzanine_data;
	uint32_t irq_stat, tmp_irq_stat, fifo_stat, fifo_csr_addr;
	unsigned long *loop;
	struct zio_cset *cset;
	int i;

	irq_stat = ft_irq_fifo_status(ft);
	if (!irq_stat || !ft_irq_status_is_valid(ft, irq_stat))
		return IRQ_NONE;

irq:
	/*
	 * Go through all FIFOs and read data. Democracy is a complicated thing,
	 * the following loop is a democratic loop, so it goes trough all
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
				TDC_FIFO_OFFSET * cset->index + TSF_REG_FIFO_CSR;
			fifo_stat = ft_ioread(ft, fifo_csr_addr);
			if (!(fifo_stat & TSF_FIFO_CSR_EMPTY))
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

	/* Ack the FMC signal, we have finished */
	fmc_irq_ack(fmc);

	return IRQ_HANDLED;
}


static irqreturn_t ft_irq_handler_ts_dma(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct fmctdc_dev *ft = fmc->mezzanine_data;
	struct ft_channel_state *st;
	struct zio_cset *cset;
	struct zio_block *blocks[ft->zdev->n_cset];
	uint32_t base_cur[ft->zdev->n_cset];
	uint32_t irq_stat;
	int i, err, transfer, n_block;
	unsigned long *loop;

	irq_stat = ft_irq_buff_status(ft);
	if (!irq_stat || !ft_irq_status_is_valid(ft, irq_stat))
		return IRQ_NONE;

	/* Disable interrupts until we fetch all stored samples */
	ft_irq_disable_save(ft);

	irq_stat &= TDC_EIC_EIC_IMR_TDC_DMA_MASK;
	irq_stat >>= TDC_EIC_EIC_IMR_TDC_DMA_SHIFT;
	ft->dma_chan_mask = irq_stat;
	loop = (unsigned long *) &irq_stat;
	/* arm all csets */
	n_block = 0;
	for_each_set_bit(i, loop, ft->zdev->n_cset) {
		st = &ft->channels[i];
		cset = &ft->zdev->cset[i];
		transfer = ft_buffer_switch(ft, i);
		base_cur[n_block] = st->buf_addr[transfer];

		cset->ti->nsamples = ft_buffer_count(ft, i);
		st->stats.received += cset->ti->nsamples;

		zio_arm_trigger(cset->ti); /* actually arm'n'fire */
		if (!zio_cset_can_acquire(cset)) {
			dev_warn(&cset->head.dev,
				 "ZIO trigger not armed, or missing block\n");
			continue;
		}
		blocks[n_block] = cset->chan->active_block;
		n_block++;
	}

	cset = &ft->zdev->cset[0]; /* ZIO is not really using the channel,
				      and probably it should not */
	ft->zdma = zio_dma_alloc_sg(cset->chan, ft->fmc->hwdev,
				    blocks, n_block, GFP_ATOMIC);
	if (IS_ERR_OR_NULL(ft->zdma))
		goto err_alloc;
	for (i = 0; i < n_block; ++i)
		ft->zdma->sg_blocks[i].dev_mem_off = base_cur[i];

	err = zio_dma_map_sg(ft->zdma, sizeof(struct gncore_dma_item),
			     gennum_dma_fill);
	if (err)
		goto err_map;


	for_each_set_bit(i, loop, ft->zdev->n_cset)
		zio_cset_busy_set(&ft->zdev->cset[i], 1);
	dma_sync_single_for_device(ft->fmc->hwdev, ft->zdma->dma_page_desc_pool,
				   sizeof(struct gncore_dma_item) * ft->zdma->sgt.nents,
				   DMA_TO_DEVICE);
	gn4124_dma_start(ft);

	fmc_irq_ack(fmc);

	return IRQ_HANDLED;

err_map:
	zio_dma_free_sg(ft->zdma);
err_alloc:
	dev_err(ft->fmc->hwdev, "Cannot execute DMA\n");
	ft->zdma = NULL;
	for_each_set_bit(i, loop, ft->zdev->n_cset) {
		zio_cset_busy_clear(&ft->zdev->cset[i], 1);
		zio_trigger_abort_disable(&ft->zdev->cset[i], 0);
	}

	ft_irq_enable_restore(ft);

	/* Ack the FMC signal, we have finished */
	fmc_irq_ack(fmc);

	return IRQ_HANDLED;
}

/**
 * It sets the coalescing timeout for the DMA buffers
 * @ft FmcTdc instance
 * @chan channel buffer -1 for all channels, otherwise [0, 4]
 * @timeout timeout in milliseconds
 */
static void ft_dma_irq_coalescing_timeout_set(struct fmctdc_dev *ft,
					      unsigned int chan,
					      uint32_t timeout)
{
	uint32_t base, tmp;
	int i;

	for (i = (chan == -1 ? 0 : chan);
	     i < (chan == -1 ? ft->zdev->n_cset : chan + 1);
	     ++i) {
		base = ft->ft_dma_base + (0x40 * i);
		tmp = ft_ioread(ft, base + TDC_BUF_REG_CSR);
		tmp &= ~TDC_BUF_CSR_IRQ_TIMEOUT_MASK;
		tmp |= TDC_BUF_CSR_IRQ_TIMEOUT_W(timeout);
		ft_iowrite(ft, tmp, base + TDC_BUF_REG_CSR);
	}
}

/**
 * It gets the coalescing timeout for the DMA buffers
 * @ft FmcTdc instance
 * @chan channel buffer [0, 4]
 *
 * Return: timeout in milliseconds
 */
static uint32_t ft_dma_irq_coalescing_timeout_get(struct fmctdc_dev *ft,
						  unsigned int chan)
{
	const uint32_t base = ft->ft_dma_base + (0x40 * chan);
	uint32_t tmp;

	tmp = ft_ioread(ft, base + TDC_BUF_REG_CSR);

	return TDC_BUF_CSR_IRQ_TIMEOUT_R(tmp);
}


/**
 * It sets the coalescing timeout according to the acquisition mode
 * @ft FmcTdc instance
 * @chan channe [0, 4] (used only for DMA acquisition mode)
 * @timeout_ms timeout in milliseconds to trigger IRQ
 */
void ft_irq_coalescing_timeout_set(struct fmctdc_dev *ft,
				   unsigned int chan,
				   uint32_t timeout_ms)
{
	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		if (unlikely(chan != -1)) {
			dev_warn(&ft->fmc->dev,
				 "%s: FIFO acquisition mode has a gobal coalesing timeout. Ignore channel %d, set global value\n",
				 __func__, chan);
		}
		ft_writel(ft, timeout_ms, TDC_REG_IRQ_TIMEOUT);
		break;
	case FT_ACQ_TYPE_DMA:
		ft_dma_irq_coalescing_timeout_set(ft, chan, timeout_ms);
		break;
	}
}

/**
 * It sets the coalescing size according to the acquisition mode
 * @ft FmcTdc instance
 * @chan channe [0, 4] (used only for DMA acquisition mode)
 *
 * Return: timeout in milliseconds
 */
uint32_t ft_irq_coalescing_timeout_get(struct fmctdc_dev *ft,
				       unsigned int chan)
{
	uint32_t timeout = 0;

	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		if (unlikely(chan != -1)) {
			dev_warn(&ft->fmc->dev,
				 "%s: FIFO acquisition mode has a gobal coalesing timeout. Ignore channel %d, get global value\n",
				 __func__, chan);
		}
		timeout = ft_readl(ft, TDC_REG_IRQ_THRESHOLD);
		break;
	case FT_ACQ_TYPE_DMA:

		timeout = ft_dma_irq_coalescing_timeout_get(ft, chan);
		break;
	default:
		dev_err(&ft->fmc->dev, "%s: unknown acquisition mode %d\n",
			__func__, ft->mode);
	}

	return timeout;
}

/**
 * It sets the coalescing size according to the acquisition mode
 * @ft FmcTdc instance
 * @chan channe [0, 4] (used only for DMA acquisition mode)
 * @size number of samples to trigger IRQ
 */
void ft_irq_coalescing_size_set(struct fmctdc_dev *ft,
				unsigned int chan,
				uint32_t size)
{
	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		if (unlikely(chan != -1)) {
			dev_warn(&ft->fmc->dev,
				 "FIFO acquisition mode has a gobal coalesing size. Ignore channel %d, apply globally\n",
				 chan);
		}
		ft_writel(ft, size, TDC_REG_IRQ_THRESHOLD);
		break;
	case FT_ACQ_TYPE_DMA:
		/* There is none */
		break;
	}
}

int ft_irq_init(struct fmctdc_dev *ft)
{
	int ret;

	ft_irq_coalescing_timeout_set(ft, -1, irq_timeout_ms_default);
	ft_irq_coalescing_size_set(ft, -1, 40);

	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		ft->fmc->irq = ft->ft_irq_base;
		ret = fmc_irq_request(ft->fmc, ft_irq_handler_ts_fifo,
				      "fmc-tdc-fifo", 0);
		if (ret < 0) {
			dev_err(&ft->fmc->dev,
				"Request interrupt 'FIFO' failed: %d\n",
				ret);
			return ret;
		}
		break;
	case FT_ACQ_TYPE_DMA:
		ft->fmc->irq = ft->ft_irq_base;
		ret = fmc_irq_request(ft->fmc, ft_irq_handler_ts_dma,
				      "fmc-tdc-dma-start", 0);
		if (ret < 0) {
			dev_err(&ft->fmc->dev,
				"Request interrupt 'DMA Start' failed: %d\n",
				ret);
			return ret;
		}
		/*
		 * DMA completion interrupt (from the GN4124 core), like in
		 * the FMCAdc design
		 */
		ft->fmc->irq = ft->ft_irq_base + 1;
		ret = fmc_irq_request(ft->fmc, ft_irq_handler_dma_complete,
				      "fmc-tdc-dma-over", 0);
		if (ret < 0) {
			dev_err(&ft->fmc->dev,
				"Request interrupt 'DMA Over' failed: %d\n",
				ret);
			ft->fmc->irq = ft->ft_irq_base;
			fmc_irq_free(ft->fmc);
		}
		/* kick off the interrupts (fixme: possible issue with the HDL) */
		fmc_irq_ack(ft->fmc);
		/*
		 * We enable interrupts on all channel. but if we do not enable
		 * the channel, we should not receive anything. So, even if
		 * ZIO is not ready to receive data at this time we should not
		 * see any trouble.
		 * If we have problems here, the HDL is broken!
		 */
		ft_iowrite(ft,
			   DMA_EIC_EIC_IER_DMA_DONE | DMA_EIC_EIC_IER_DMA_ERROR,
			   ft->ft_dma_eic_base + DMA_EIC_REG_EIC_IER);
		break;
	}

	/* Enable interrupts */
	ft_iowrite(ft, ft_chan_to_irq_mask(ft, 0x1F),
		   ft->ft_irq_base + TDC_EIC_REG_EIC_IER);

	return 0;
}

void ft_irq_exit(struct fmctdc_dev *ft)
{
	ft_iowrite(ft, ~0, ft->ft_irq_base + TDC_EIC_REG_EIC_IDR);

	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		ft->fmc->irq = ft->ft_irq_base;
		fmc_irq_free(ft->fmc);
		break;
	case FT_ACQ_TYPE_DMA:
		ft_iowrite(ft,
			   DMA_EIC_EIC_IDR_DMA_DONE | DMA_EIC_EIC_IDR_DMA_ERROR,
			   ft->ft_dma_eic_base + DMA_EIC_REG_EIC_IER);

		ft->fmc->irq = ft->ft_irq_base;
		fmc_irq_free(ft->fmc);
		ft->fmc->irq = ft->ft_irq_base + 1;
		fmc_irq_free(ft->fmc);
		break;
	}
}
