/*
 * fmc-tdc (a.k.a) FmcTdc1ns5cha main header.
 *
 * Copyright (C) 2018 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/bitops.h>
#include <linux/io.h>
#include <linux/moduleparam.h>
#include <linux/interrupt.h>
#include <linux/dmaengine.h>
#include <linux/workqueue.h>

#include <linux/zio.h>
#include <linux/zio-trigger.h>
#include <linux/zio-buffer.h>

#include "fmc-tdc.h"
#include "ft-compat.h"
#include "hw/timestamp_fifo_regs.h"

#define TDC_EIC_EIC_IMR_TDC_DMA_SHIFT 5
#define TDC_EIC_EIC_IMR_TDC_DMA_MASK (TDC_EIC_EIC_ISR_TDC_DMA1 | \
				      TDC_EIC_EIC_ISR_TDC_DMA2 |  \
				      TDC_EIC_EIC_ISR_TDC_DMA3 |  \
				      TDC_EIC_EIC_ISR_TDC_DMA4 |  \
				      TDC_EIC_EIC_ISR_TDC_DMA5)


static int dma_buf_ddr_burst_size_default = 16;
module_param_named(dma_buf_ddr_burst_size, dma_buf_ddr_burst_size_default,
		   int, 0444);
MODULE_PARM_DESC(dma_buf_ddr_burst_size,
		 "DDR size coalesing timeout (default: 16 timestamps).");


static void ft_buffer_burst_size_set(struct fmctdc_dev *ft,
				     unsigned int chan,
				     uint32_t size)
{
	void *base = ft->ft_dma_base + (0x40 * chan);
	uint32_t tmp;

	tmp = ft_ioread(ft, base + TDC_BUF_REG_CSR);
	tmp &= ~TDC_BUF_CSR_BURST_SIZE_MASK;
	tmp |= TDC_BUF_CSR_BURST_SIZE_W(size);
	ft_iowrite(ft, tmp, base + TDC_BUF_REG_CSR);
}

static void ft_buffer_burst_enable(struct fmctdc_dev *ft,
				   unsigned int chan)
{
	void *base = ft->ft_dma_base + (0x40 * chan);
	uint32_t tmp;

	tmp = ft_ioread(ft, base + TDC_BUF_REG_CSR);
	tmp |= TDC_BUF_CSR_ENABLE;
	ft_iowrite(ft, tmp, base + TDC_BUF_REG_CSR);

}

static void ft_buffer_burst_disable(struct fmctdc_dev *ft,
				    unsigned int chan)
{
	void *base = ft->ft_dma_base + (0x40 * chan);
	uint32_t tmp;

	tmp = ft_ioread(ft, base + TDC_BUF_REG_CSR);
	tmp &= ~TDC_BUF_CSR_ENABLE;
	ft_iowrite(ft, tmp, base + TDC_BUF_REG_CSR);

}


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
	void *base = ft->ft_dma_base + chan * 0x40;
	uint32_t csr, base_cur;
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
	void *base = ft->ft_dma_base + chan * 0x40;

	return ft_ioread(ft,  base + TDC_BUF_REG_CUR_COUNT);
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

	return !WARN((chan_stat & irq_stat) == 0,
		    "Received an unexpected interrupt: 0x%X 0x%X\n",
		    chan_stat, irq_stat);
}

static int ft_zio_block_dma_map_sg(struct fmctdc_dev *ft, unsigned int ch,
				   struct zio_block *block,
				   enum dma_data_direction dir)
{
	struct ft_channel_state *st = &ft->channels[ch];
	struct page **pages;
	unsigned int nr_pages;
	size_t max_segment_size;
	long kaddr = (long)block->data;
	void *data = (void *) block->data;
	int i;
	int err;
	int sg_len;

	nr_pages = ((kaddr & ~PAGE_MASK) + block->datalen + ~PAGE_MASK);
	nr_pages >>= PAGE_SHIFT;

	pages = kcalloc(nr_pages, sizeof(struct page *), GFP_KERNEL);
	if (!pages)
		return -ENOMEM;

	if (is_vmalloc_addr(data)) {
		for (i = 0; i < nr_pages; ++i)
			pages[i] = vmalloc_to_page(data + PAGE_SIZE * i);
	} else {
		for (i = 0; i < nr_pages; ++i)
			pages[i] = virt_to_page(data + PAGE_SIZE * i);
	}

	max_segment_size = dma_get_max_seg_size(ft->dchan->device->dev);
	max_segment_size &= PAGE_MASK; /* to make alloc_table happy */
	err = __sg_alloc_table_from_pages(&st->sgt, pages, nr_pages,
					  offset_in_page(block->data),
					  block->datalen,
					  max_segment_size, GFP_KERNEL);
	if (err)
		goto err_alloc;

	sg_len = dma_map_sg(&ft->pdev->dev,
			    st->sgt.sgl, st->sgt.nents, dir);
	if (sg_len <= 0) {
		err = sg_len;
		goto err_map;
	}

	kfree(pages);

	return sg_len;

err_map:
	sg_free_table(&st->sgt);
err_alloc:
	kfree(pages);
	return err;
}

static void ft_zio_block_dma_unmap_sg(struct fmctdc_dev *ft, unsigned int ch,
				      enum dma_data_direction dir)
{
	struct ft_channel_state *st = &ft->channels[ch];

	dma_unmap_sg(&ft->pdev->dev,
		     st->sgt.sgl, st->sgt.nents, dir);
	sg_free_table(&st->sgt);
}

static void ft_dma_complete(void *arg)
{
	struct zio_cset *cset = arg;
	struct fmctdc_dev *ft =  cset->zdev->priv_d;
	unsigned long flags;

	if (WARN(!ft->dchan, "Channel unavailable\n"))
		return;

	ft_zio_block_dma_unmap_sg(ft, cset->index, DMA_DEV_TO_MEM);

	spin_lock_irqsave(&ft->lock, flags);
	ft->pending_dma--;
	if (!ft->pending_dma)
		ft_irq_enable_restore(ft);
	spin_unlock_irqrestore(&ft->lock, flags);

	spin_lock(&cset->lock);
	cset->flags &= ~ZIO_CSET_HW_BUSY;
	spin_unlock(&cset->lock);

	zio_trigger_data_done(cset);
}

/**
 * It matches a valid DMA channel
 */
static bool ft_dmaengine_filter(struct dma_chan *dchan, void *arg)
{
	struct dma_device *ddev = dchan->device;
	int dev_id = (*((int *)arg) >> 16) & 0xFFFF;
	int chan_id = *((int *)arg) & 0xFFFF;

	return ddev->dev_id == dev_id && dchan->chan_id == chan_id;
}

static int ft_dma_config(struct fmctdc_dev *ft, unsigned int ch)
{
	struct zio_cset *cset = &ft->zdev->cset[ch];
	struct ft_channel_state *st = &ft->channels[ch];
	struct dma_async_tx_descriptor *tx;
	unsigned int transfer;
	int sg_len;
	struct dma_slave_config sconfig;
	int err;


	transfer = ft_buffer_switch(ft, ch);
	cset->ti->nsamples = ft_buffer_count(ft, ch);
	ft->channels[ch].stats.received += cset->ti->nsamples;

	zio_arm_trigger(cset->ti); /* actually arm'n'fire */
	if (!zio_cset_can_acquire(cset)) {
		dev_warn(&ft->pdev->dev,
			 "DMA failed for channel %i: can't arm ZIO trigger\n",
			 ch);
		return -EBUSY;
	}

	memset(&sconfig, 0, sizeof(sconfig));
	sconfig.direction = DMA_DEV_TO_MEM;
	sconfig.src_addr = st->buf_addr[transfer];
	err = dmaengine_slave_config(ft->dchan, &sconfig);
	if (err) {
		dev_err(&ft->pdev->dev,
			"DMA failed for channel %i: can't config %d\n",
			ch, err);
		return err;
	}

	sg_len = ft_zio_block_dma_map_sg(ft, ch, cset->chan->active_block,
					 DMA_DEV_TO_MEM);
	if (sg_len <= 0) {
		err = sg_len;
		dev_err(&ft->pdev->dev,
			"DMA failed for channel %i: can't map host memory %d\n",
			ch, err);
		goto err_map;
	}

	tx = dmaengine_prep_slave_sg(ft->dchan,
				     st->sgt.sgl, sg_len, DMA_DEV_TO_MEM, 0);
	if (!tx) {
		dev_err(&ft->pdev->dev,
			"DMA failed for channel %i: can't prepare transfer\n",
			ch);
		err = -EINVAL;
		goto err_prep;
	}
	tx->callback = ft_dma_complete;
	tx->callback_param = (void *)cset;

	st->cookie = dmaengine_submit(tx);
	if (st->cookie < 0) {
		dev_err(&ft->pdev->dev,
			"DMA failed for channel %i: can't submit %d\n",
			ch, st->cookie);
		err = st->cookie;
		goto err_submit;
	}

	return 0;

err_submit:
err_prep:
	dma_unmap_sg(&ft->pdev->dev,
		     st->sgt.sgl, st->sgt.nents, DMA_DEV_TO_MEM);
err_map:
	sg_free_table(&st->sgt);
	pr_info("%s:%d err %d\n", __func__, __LINE__, err);
	return err;
}


static void ft_irq_work(struct work_struct *work)
{
	struct fmctdc_dev *ft = container_of(work, struct fmctdc_dev,
					     irq_work);
	unsigned int n_transfers = 0;
	unsigned long flags;
	unsigned int i;

	pr_info("%s:%d mask %ld\n", __func__, __LINE__, ft->dma_chan_mask);
	for_each_set_bit(i, &ft->dma_chan_mask, ft->zdev->n_cset) {
		int err = ft_dma_config(ft, i);

		if (err)
			continue;
		n_transfers++;
	}

	if (likely(n_transfers)) {
		pr_info("%s:%d\n", __func__, __LINE__);
		spin_lock_irqsave(&ft->lock, flags);
		ft->pending_dma = n_transfers;
		spin_unlock_irqrestore(&ft->lock, flags);
		dma_async_issue_pending(ft->dchan);
	} else {
		pr_info("%s:%d\n", __func__, __LINE__);
		ft_irq_enable_restore(ft);
	}
}

static irqreturn_t ft_irq_handler_ts_dma(int irq, void *dev_id)
{
	struct fmctdc_dev *ft = dev_id;
	uint32_t irq_stat;

	WARN(ft->pending_dma,
	     "Possible data loss: IRQ arrived while pending DMA");

	irq_stat = ft_irq_buff_status(ft);
	irq_stat &= TDC_EIC_EIC_IMR_TDC_DMA_MASK;
	irq_stat >>= TDC_EIC_EIC_IMR_TDC_DMA_SHIFT;

	if (!irq_stat || !ft_irq_status_is_valid(ft, irq_stat))
		return IRQ_NONE;

	ft_irq_disable_save(ft);
	ft->dma_chan_mask = irq_stat;
	queue_work(system_highpri_wq, &ft->irq_work);

	return IRQ_HANDLED;
}


/**
 * It configure the double buffers for a given channel
 * @param[in] ft FmcTdc device instance
 * @param[in] channel range [0, N-1]
 */
static void ft_buffer_size_set(struct fmctdc_dev *ft, int channel)
{
	void *base = ft->ft_dma_base + (0x40 * channel);
	uint32_t val;
	struct ft_channel_state *st;

	if (ft->mode != FT_ACQ_TYPE_DMA)
		return;

	st = &ft->channels[channel];

	st->buf_size = TDC_CHANNEL_BUFFER_SIZE_BYTES / sizeof(struct ft_hw_timestamp);
	st->active_buffer = 0;

	ft_buffer_burst_disable(ft, channel);

	/* Buffer 1 */
	st->buf_addr[0] = TDC_CHANNEL_BUFFER_SIZE_BYTES * (2 * channel);
	ft_iowrite(ft, st->buf_addr[0], base + TDC_BUF_REG_CUR_BASE);
	val = (st->buf_size << TDC_BUF_CUR_SIZE_SIZE_SHIFT);
	val |= TDC_BUF_CUR_SIZE_VALID;
	ft_iowrite(ft, val, base + TDC_BUF_REG_CUR_SIZE);

	/* Buffer 2 */
	st->buf_addr[1] = TDC_CHANNEL_BUFFER_SIZE_BYTES * (2 * channel + 1);
	ft_iowrite(ft, st->buf_addr[1], base + TDC_BUF_REG_NEXT_BASE);
	val = (st->buf_size << TDC_BUF_NEXT_SIZE_SIZE_SHIFT);
	val |= TDC_BUF_NEXT_SIZE_VALID;
	ft_iowrite(ft, val, base + TDC_BUF_REG_NEXT_SIZE);

	ft_buffer_burst_size_set(ft, channel, dma_buf_ddr_burst_size_default);
	ft_buffer_burst_enable(ft, channel);

	dev_vdbg(&ft->pdev->dev,
		 "Config channel %d: base = %p buf[0] = 0x%08x, buf[1] = 0x%08x, %d timestamps per buffer\n",
		 channel, base, st->buf_addr[0], st->buf_addr[1],
		 st->buf_size);
	dev_vdbg(&ft->pdev->dev, "CSR: %08x\n",
		 ft_ioread(ft, base + TDC_BUF_REG_CSR));
}

/**
 * It clears the double buffers configuration for a given channel
 * @param[in] ft FmcTdc device instance
 * @param[in] channel range [0, N-1]
 */
static void ft_buffer_size_clr(struct fmctdc_dev *ft, int channel)
{
	void *base = ft->ft_dma_base + (0x40 * channel);

	ft_iowrite(ft, 0, base + TDC_BUF_REG_CUR_SIZE);
	ft_iowrite(ft, 0, base + TDC_BUF_REG_NEXT_SIZE);
	ft_buffer_burst_disable(ft, channel);
}


int ft_buf_init(struct fmctdc_dev *ft)
{
	struct resource *r;
	int dma_dev_id;
	dma_cap_mask_t dma_mask;
	unsigned int i;
	int ret;

	ft_irq_coalescing_timeout_set(ft, -1, irq_timeout_ms_default);
	ft_irq_coalescing_size_set(ft, -1, 40);

	INIT_WORK(&ft->irq_work, ft_irq_work);

	r = platform_get_resource(ft->pdev, IORESOURCE_DMA, TDC_DMA);
	if (!r) {
		dev_err(&ft->pdev->dev, "Can't set find DMA channel\n");
		return -ENODEV;
	}
	dma_dev_id = r->start;

	r = platform_get_resource(ft->pdev, IORESOURCE_IRQ, TDC_IRQ);
	ret = request_any_context_irq(r->start, ft_irq_handler_ts_dma, 0,
				      r->name, ft);
	if (ret < 0) {
		dev_err(&ft->pdev->dev,
			"Request interrupt 'DMA Start' failed: %d\n",
			ret);
		return ret;
	}

	dma_cap_zero(dma_mask);
	dma_cap_set(DMA_SLAVE, dma_mask);
	dma_cap_set(DMA_PRIVATE, dma_mask);
	ft->dchan = dma_request_channel(dma_mask, ft_dmaengine_filter,
					&dma_dev_id);
	if (!ft->dchan) {
		dev_dbg(&ft->pdev->dev,
			"DMA transfer Failed: can't request channel\n");
		ret = -EINVAL;
		goto err_dma;
	}

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

	ft_iowrite(ft, TDC_EIC_EIC_IMR_TDC_DMA_MASK,
		   ft->ft_irq_base + TDC_EIC_REG_EIC_IER);

	for (i = 0; i < FT_NUM_CHANNELS; i++)
		ft_buffer_size_set(ft, i);

	return 0;

err_dma:
	free_irq(platform_get_irq(ft->pdev, TDC_IRQ), ft);
	return ret;
}

void ft_buf_exit(struct fmctdc_dev *ft)
{
	unsigned int i;

	ft_iowrite(ft, ~0, ft->ft_irq_base + TDC_EIC_REG_EIC_IDR);

	ft_iowrite(ft,
		   DMA_EIC_EIC_IDR_DMA_DONE | DMA_EIC_EIC_IDR_DMA_ERROR,
		   ft->ft_dma_eic_base + DMA_EIC_REG_EIC_IER);

	dma_release_channel(ft->dchan);
	free_irq(platform_get_irq(ft->pdev, TDC_IRQ), ft);

	for (i = 0; i < FT_NUM_CHANNELS; i++)
		ft_buffer_size_clr(ft, i);
}
