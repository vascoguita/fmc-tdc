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

	/* it takes a while for the PLL to bootstrap.... or not!
	   We have no possibility to check, as the PLL status register is driven
	   by the clock from this PLL :( */
	msleep(3000);

	return 0;
}

struct ft_carrier_specific ft_carrier_spec = {
	FT_GATEWARE_SPEC,
	ft_spec_reset
};
