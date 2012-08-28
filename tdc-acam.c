/*
 * ACAM support for tdc driver 
 *
 * Copyright (C) 2012 CERN (http://www.cern.ch)
 * Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation.
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <asm/io.h>

#include "tdc.h"
#include "hw/acam_gpx.h"
#include "hw/tdc_regs.h"

void tdc_acam_reset(struct spec_tdc *tdc)
{
	writel(TDC_CTRL_RESET_ACAM, tdc->base + TDC_CTRL_REG);
}

void tdc_acam_load_config(struct spec_tdc *tdc)
{
	writel(TDC_CTRL_LOAD_ACAM_CFG, tdc->base + TDC_CTRL_REG);
}
