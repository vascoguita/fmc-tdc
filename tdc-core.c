/*
 * core tdc driver 
 *
 * Copyright (C) 2012 CERN (http://www.cern.ch)
 * Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation.
 */

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt 

#include <linux/kernel.h>
#include <linux/module.h>

#include "spec.h"
#include "tdc.h"
#include "hw/tdc_regs.h"

int tdc_probe(struct spec_dev *dev)
{
	struct spec_tdc *tdc;

	/* FIXME: create a new function to do this... */
	int freq = 160;
	int divot;
	int data;

	tdc = kzalloc(sizeof(struct spec_tdc), GFP_KERNEL);
	if (!tdc) {
		pr_err("%s: can't allocate device\n", __func__);
		return -ENOMEM;
	}

	dev->sub_priv = tdc;
	tdc->spec = dev;
	tdc->base = dev->remap[0];
	tdc->regs = tdc->base; 	/* FIXME: */
	tdc->ow_regs = tdc->base; /* FIXME:  */
	
	/* FIXME:  */

	/* Setup local clock */

	divot = 800/freq - 1;
        data = 0xe001f00c + (divot << 4);
	writel(data, dev->remap[2] + 0x808);

	msleep(100);
	/* Reset FPGA */
	writel(0x00021040, dev->remap[2] + 0x800);
	msleep(1);
	writel(0x00025000, dev->remap[2] + 0x800);
	msleep(600);

	writel(0x33, tdc->base + TDC_MEZZANINE_1WIRE);
	pr_err("SIG: termometro family code value ->  0x%x\n", readl(tdc->base + TDC_MEZZANINE_1WIRE));
	pr_err("SIG: termometro serial number value 0 -> 0x%x\n", readl(tdc->base + TDC_MEZZANINE_1WIRE));

	pr_err("SIG: termometro serial number value 1 -> 0x%x\n", readl(tdc->base + TDC_MEZZANINE_1WIRE));
	pr_err("SIG: termometro serial number value 2 -> 0x%x\n", readl(tdc->base + TDC_MEZZANINE_1WIRE));
	pr_err("SIG: termometro serial number value 3 -> 0x%x\n", readl(tdc->base + TDC_MEZZANINE_1WIRE));
	pr_err("SIG: termometro serial number value 4 -> 0x%x\n", readl(tdc->base + TDC_MEZZANINE_1WIRE));

	pr_err("SIG: termometro serial number value 5 -> 0x%x\n", readl(tdc->base + TDC_MEZZANINE_1WIRE));

	tdc_zio_register_device(tdc);

	/* TODO: */
	return 0;
}

void tdc_remove(struct spec_dev *dev)
{
	struct spec_tdc *tdc = dev->sub_priv;

	tdc_zio_remove(tdc);

	/* TODO: */
}

static int tdc_init(void)
{
	int err;

	err = tdc_zio_init();
	if (err < 0)
		return err;

	err = tdc_spec_init();
	if (err < 0) {
		tdc_zio_exit();
		return err;
	}
	
	return 0;
}

static void tdc_exit(void)
{
	tdc_spec_exit();
	tdc_zio_exit();
}

module_init(tdc_init);
module_exit(tdc_exit);

MODULE_LICENSE("GPL"); 		/* FIXME? Fine delay driver has LGPL (GPL and additional rights) */
