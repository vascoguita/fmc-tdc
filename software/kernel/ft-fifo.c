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

#include <linux/zio.h>
#include <linux/zio-trigger.h>
#include <linux/zio-buffer.h>

#include "fmc-tdc.h"
#include "hw/timestamp_fifo_regs.h"

#define TDC_EIC_EIC_IMR_TDC_FIFO_SHIFT 0
#define TDC_EIC_EIC_IMR_TDC_FIFO_MASK (TDC_EIC_EIC_ISR_TDC_FIFO1 | \
				       TDC_EIC_EIC_ISR_TDC_FIFO2 | \
				       TDC_EIC_EIC_ISR_TDC_FIFO3 | \
				       TDC_EIC_EIC_ISR_TDC_FIFO4 | \
				       TDC_EIC_EIC_ISR_TDC_FIFO5)

/**
 * Get a time stamp from the fifo, if you set the 'last' flag it takes the last
 * recorded time-stamp
 */
static int ft_timestamp_get(struct zio_cset *cset, struct ft_hw_timestamp *hwts)
{
	struct fmctdc_dev *ft = cset->zdev->priv_d;
	void *fifo_addr = ft->ft_fifo_base + TDC_FIFO_OFFSET * cset->index;

	hwts->seconds = ft_ioread(ft, fifo_addr + TSF_REG_FIFO_R0);
	hwts->coarse = ft_ioread(ft, fifo_addr + TSF_REG_FIFO_R1);
	hwts->frac = ft_ioread(ft, fifo_addr + TSF_REG_FIFO_R2);
	hwts->metadata = ft_ioread(ft, fifo_addr + TSF_REG_FIFO_R3);

	return 1;
}

static void ft_timestamp_get_n(struct zio_cset *cset,
			       struct ft_hw_timestamp *hwts,
			       unsigned int n)
{
	int i;

	for (i = 0; i < n; ++i)
		ft_timestamp_get(cset, &hwts[i]);
}

static void ft_fifo_flush(struct fmctdc_dev *ft, unsigned int n)
{
	void *fifo_csr_addr = ft->ft_fifo_base
		+ TDC_FIFO_OFFSET * n
		+ TSF_REG_FIFO_CSR;

	ft_iowrite(ft, TSF_FIFO_CSR_CLEAR_BUS, fifo_csr_addr);
}


/**
 * Extract a timestamp from the FIFO
 */
static void ft_readout_fifo_n(struct zio_cset *cset, unsigned int n)
{
	struct fmctdc_dev *ft;
	struct ft_channel_state *st;
	int trans = 0;

	ft = cset->zdev->priv_d;
	st = &ft->channels[cset->index];

	st->stats.received += n;
	cset->ti->nsamples = n;
	zio_arm_trigger(cset->ti);
	if (likely(cset->chan->active_block)) {
		ft_timestamp_get_n(cset, cset->chan->active_block->data, n);
		trans = n;
	}

	zio_trigger_data_done(cset);
	st->stats.transferred += trans;
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


static irqreturn_t ft_irq_handler_ts_fifo(int irq, void *dev_id)
{
	struct fmctdc_dev *ft = dev_id;
	uint32_t irq_stat_orig, fifo_stat, irq_stat;
	void *fifo_csr_addr;
	unsigned long *loop;
	struct zio_cset *cset;
	int i, n;
	int redo = 10;

	irq_stat_orig = ft_irq_fifo_status(ft);
	if (!irq_stat_orig)
		return IRQ_NONE;

	irq_stat = irq_stat_orig;
	loop = (unsigned long *) &irq_stat;
	do {
		for_each_set_bit(i, loop, FT_NUM_CHANNELS) {
			cset = &ft->zdev->cset[i];
			fifo_csr_addr = ft->ft_fifo_base +
				TDC_FIFO_OFFSET * cset->index + TSF_REG_FIFO_CSR;

			fifo_stat = ft_ioread(ft, fifo_csr_addr);
			n = TSF_FIFO_CSR_USEDW_R(fifo_stat);
			if (n == 0)
				continue; /* Still something to read */

			if (fifo_stat & TSF_FIFO_CSR_FULL) { /* We are loosing TS */
				ft_fifo_flush(ft, cset->index);
			} else {
				ft_readout_fifo_n(cset, n);
				/*
				 * If the FIFO is more than half full,
				 * read again for a maximum of 'redo'
				 * times. OPTIMIZATION.
				 */
				if (n < FT_FIFO_MAX / 2)
					irq_stat &= ~BIT(i);
				else
					redo--;
			}
		}
	} while(irq_stat && redo);
	ft_iowrite(ft, irq_stat_orig, ft->ft_irq_base + TDC_EIC_REG_EIC_ISR);

	return IRQ_HANDLED;
}


int ft_fifo_init(struct fmctdc_dev *ft)
{
	struct resource *r;
	int ret;

	ft_irq_coalescing_timeout_set(ft, -1, irq_timeout_ms_default);
	ft_irq_coalescing_size_set(ft, -1, 40);

	r = platform_get_resource(ft->pdev, IORESOURCE_IRQ, TDC_IRQ);
	ret = request_any_context_irq(r->start, ft_irq_handler_ts_fifo, 0,
				      r->name, ft);
	if (ret < 0) {
		dev_err(&ft->pdev->dev,
			"Request interrupt 'FIFO' failed: %d\n",
			ret);
		return ret;
	}

	ft_iowrite(ft, TDC_EIC_EIC_IMR_TDC_FIFO_MASK,
		   ft->ft_irq_base + TDC_EIC_REG_EIC_IER);

	return 0;
}


void ft_fifo_exit(struct fmctdc_dev *ft)
{
	ft_iowrite(ft, ~0, ft->ft_irq_base + TDC_EIC_REG_EIC_IDR);

	free_irq(platform_get_irq(ft->pdev, TDC_IRQ), ft);
}
