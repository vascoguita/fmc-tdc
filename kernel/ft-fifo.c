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
	struct fmc_device *fmc = dev_id;
	struct fmctdc_dev *ft = fmc->mezzanine_data;
	uint32_t irq_stat, tmp_irq_stat, fifo_stat, fifo_csr_addr;
	unsigned long *loop;
	struct zio_cset *cset;
	int i;

	irq_stat = ft_irq_fifo_status(ft);
	if (!irq_stat)
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


int ft_fifo_init(struct fmctdc_dev *ft)
{
	int ret;

	ft_irq_coalescing_timeout_set(ft, -1, irq_timeout_ms_default);
	ft_irq_coalescing_size_set(ft, -1, 40);

	ft->fmc->irq = ft->ft_irq_base;
	ret = fmc_irq_request(ft->fmc, ft_irq_handler_ts_fifo,
			      "fmc-tdc-fifo", 0);
	if (ret < 0) {
		dev_err(&ft->fmc->dev,
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

	ft->fmc->irq = ft->ft_irq_base;
	fmc_irq_free(ft->fmc);
}
