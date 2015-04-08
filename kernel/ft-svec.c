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

static int ft_svec_reset(struct fmctdc_dev *ft)
{
	uint32_t val;

	dev_dbg(&ft->fmc->dev, "Un-resetting FMCs...\n");

	/* Reset - reset bits are shifted by 1 */
	fmc_writel(ft->fmc, ~(1 << (ft->fmc->slot_id + 1)),
		   TDC_SVEC_CARRIER_BASE + TDC_REG_CARRIER_RST);

	udelay(5000);

	val = fmc_readl(ft->fmc, TDC_SVEC_CARRIER_BASE + TDC_REG_CARRIER_RST);
	val |= (1 << (ft->fmc->slot_id + 1));

	/* Un-Reset */
	fmc_writel(ft->fmc, val, TDC_SVEC_CARRIER_BASE + TDC_REG_CARRIER_RST);

	return 0;
}

struct ft_carrier_specific ft_carrier_svec = {
	FT_GATEWARE_SVEC,
	ft_svec_reset
};
