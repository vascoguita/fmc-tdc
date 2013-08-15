/*
 * SVEC-specific workarounds for the fmc-tdc driver.
 *
 * Copyright (C) 2012-2013 CERN (http://www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation.
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/slab.h>
#include <linux/delay.h>
#include <linux/fmc.h>

#include "fmc-tdc.h"

#include "hw/tdc_regs.h"

static int ft_poll_interval = 200;
module_param_named(poll_interval, ft_poll_interval, int, 0444);
MODULE_PARM_DESC(poll_interval,
		 "Buffer polling interval in milliseconds. Applies to SVEC version only.");

/* SVEC-specific private data structure */
struct ft_svec_data {
	irq_handler_t fake_irq_handler;
	struct timer_list poll_timer;
};

static void ft_poll_timer_handler(unsigned long arg)
{
	struct fmctdc_dev *ft = (struct fmctdc_dev *)arg;
	struct ft_svec_data *cdata = ft->carrier_data;
	uint32_t irq_stat;

	irq_stat = fmc_readl(ft->fmc, ft->ft_irq_base + TDC_REG_IRQ_STATUS);
	irq_stat >>= ft->irq_shift;

	/* irq status bit set for the TS buffer irq? call the "real" handler */
	if (irq_stat & TDC_IRQ_TDC_TSTAMP)
		cdata->fake_irq_handler(TDC_IRQ_TDC_TSTAMP, ft->fmc);

	mod_timer(&cdata->poll_timer, jiffies + (ft_poll_interval * HZ / 1000));
}

static int ft_svec_init(struct fmctdc_dev *ft)
{
	struct ft_svec_data *cdata;;
	ft->carrier_data = kzalloc(sizeof(struct ft_svec_data), GFP_KERNEL);

	if (!ft->carrier_data)
		return -ENOMEM;

	/* FIXME: use SDB (after fixing the HDL) */
	cdata = ft->carrier_data;

	return 0;
}

static int ft_svec_reset(struct fmctdc_dev *ft)
{
	unsigned long tmo;

	/* FIXME: An UGLY hack: ft_svec_reset() executed on slot 0 (first mezzanine to
	   be initialized) resets BOTH cards. The reason is that we need both mezzanines PLLs
	   running to read the entire SDB tree (parts of the system interconnect are clocked from
	   FMC clock lines. */

	if (ft->fmc->slot_id != 0)
		return 0;

	dev_info(&ft->fmc->dev, "Resetting FMCs...\n");
	fmc_writel(ft->fmc, TDC_CARRIER_CTL1_RSTN_FMC0 |
		   TDC_CARRIER_CTL1_RSTN_FMC1,
		   TDC_SVEC_CARRIER_BASE + TDC_REG_CARRIER_CTL1);

	tmo = jiffies + 2 * HZ;
	while (time_before(jiffies, tmo)) {
		uint32_t stat;
		stat =
		    fmc_readl(ft->fmc,
			      TDC_SVEC_CARRIER_BASE + TDC_REG_CARRIER_CTL0);

		if ((stat & TDC_CARRIER_CTL0_PLL_STAT_FMC0) &&
		    (stat & TDC_CARRIER_CTL0_PLL_STAT_FMC1))
			return 0;
		msleep(10);
	}

	dev_err(&ft->fmc->dev, "PLL lock timeout.\n");
	return -EIO;
}

static int ft_svec_copy_timestamps(struct fmctdc_dev *ft, int base_addr,
				   int size, void *dst)
{
	int i;
	uint32_t addr;
	uint32_t *dptr;

	if (unlikely(size & 3 || base_addr & 3))	/* no unaligned reads, please. */
		return -EIO;

	/* FIXME: use SDB to determine buffer base address (after fixing the HDL) */
	addr = ft->ft_core_base + 0x4000 + base_addr;

	for (i = 0, dptr = (uint32_t *) dst; i < size / 4; i++, dptr++)
		*dptr = fmc_readl(ft->fmc, addr + i * 4);

	return 0;
}

static int ft_svec_setup_irqs(struct fmctdc_dev *ft, irq_handler_t handler)
{
	struct ft_svec_data *cdata = ft->carrier_data;

/* FIXME: The code below doesn't work because current SVEC driver... does not support 
   interrupts. We use a timer instead. */
#if 0
	ret = fmc->op->irq_request(fmc, handler, "fmc-tdc", IRQF_SHARED);

	if (ret < 0) {
		dev_err(&fmc->dev, "Request interrupt failed: %d\n", ret);
		return ret;
	}
#endif

	cdata->fake_irq_handler = handler;

	setup_timer(&cdata->poll_timer, ft_poll_timer_handler,
		    (unsigned long)ft);
	mod_timer(&cdata->poll_timer, jiffies + (ft_poll_interval * HZ / 1000));

	return 0;
}

static int ft_svec_disable_irqs(struct fmctdc_dev *ft)
{
	struct ft_svec_data *cdata = ft->carrier_data;

	del_timer_sync(&cdata->poll_timer);

/*	fmc->op->irq_free(fmc);*/

	return 0;
}

static int ft_svec_ack_irq(struct fmctdc_dev *ft, int irq_id)
{
	return 0;
}

static void ft_svec_exit(struct fmctdc_dev *ft)
{
	kfree(ft->carrier_data);
}

struct ft_carrier_specific ft_carrier_svec = {
	FT_GATEWARE_SVEC,
	ft_svec_init,
	ft_svec_reset,
	ft_svec_copy_timestamps,
	ft_svec_setup_irqs,
	ft_svec_disable_irqs,
	ft_svec_ack_irq,
	ft_svec_exit
};
