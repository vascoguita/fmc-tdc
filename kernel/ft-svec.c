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

/*
static int ft_poll_interval = 200;
module_param_named(poll_interval, ft_poll_interval, int, 0444);
MODULE_PARM_DESC(poll_interval,
		 "Buffer polling interval in milliseconds. Applies to SVEC version only.");
*/

static int ft_svec_init(struct fmctdc_dev *ft)
{
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
	int ret;

	/* pass the core's base addr as the VIC IRQ vector. */
	
	/* fixme: vector table points to the bridge instead of the core's base address */
	ft->fmc->irq = ft->ft_core_base - 0x10000;
	ret = ft->fmc->op->irq_request(ft->fmc, handler, "fmc-tdc", 0);

	if (ret < 0) {
		dev_err(&ft->fmc->dev, "Request interrupt failed: %d\n", ret);
		return ret;
	}

	return 0;
}

static int ft_svec_disable_irqs(struct fmctdc_dev *ft)
{
	return ft->fmc->op->irq_free(ft->fmc);
}

static int ft_svec_ack_irq(struct fmctdc_dev *ft, int irq_id)
{
	ft->fmc->op->irq_ack(ft->fmc);

	return 0;
}

static void ft_svec_exit(struct fmctdc_dev *ft)
{
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
