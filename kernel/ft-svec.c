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
	/* FIXME: An UGLY hack: ft_svec_reset() executed on slot 0
	   (first mezzanine to be initialized) resets BOTH cards. The reason is
	   that we need both mezzanines PLLs running to read the entire
	   SDB tree (parts of the system interconnect are clocked from
	   FMC clock lines. */

	if (ft->fmc->slot_id != 0)
		return 0;

	dev_dbg(&ft->fmc->dev, "Un-resetting FMCs...\n");

	fmc_writel(ft->fmc, 0xff, TDC_SVEC_CARRIER_BASE + TDC_REG_CARRIER_RST);

	msleep(3000);
	return 0;
}

struct ft_carrier_specific ft_carrier_svec = {
	FT_GATEWARE_SVEC,
	ft_svec_reset
};
