/*
 * SPEC-specific workarounds for the fmc-tdc driver.
 *
 * Copyright (C) 2012-2013 CERN (http://www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation.
 */

#include <linux/kernel.h>
#include <linux/delay.h>
#include <linux/fmc.h>

#include "fmc-tdc.h"
#include "spec.h"

#include "hw/tdc_regs.h"

static int ft_spec_reset(struct fmctdc_dev *ft)
{
	struct spec_dev *spec = (struct spec_dev *)ft->fmc->carrier_data;

	dev_info(&ft->fmc->dev, "%s: resetting TDC core through Gennum.\n",
		 __func__);

	/* set local bus clock to 160 MHz. The FPGA can't handle more. */
	gennum_writel(spec, 0xE001F04C, 0x808);

	/* fixme: there is no possibility of doing a software reset of the TDC core on the SPEC
	   other than through a Gennum config register. This begs for a fix in the
	   gateware! */

	gennum_writel(spec, 0x00021040, GNPCI_SYS_CFG_SYSTEM);
	mdelay(10);
	gennum_writel(spec, 0x00025000, GNPCI_SYS_CFG_SYSTEM);

	msleep(3000);		/* it takes a while for the PLL to bootstrap.... or not! 
				   We have no possibility to check, as the PLL status register is driven
				   by the clock from this PLL :( */

	return 0;
}

struct ft_carrier_specific ft_carrier_spec = {
	FT_GATEWARE_SPEC,
	ft_spec_reset
};
