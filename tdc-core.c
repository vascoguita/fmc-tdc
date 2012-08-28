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
#include <asm/io.h>

#include "spec.h"
#include "tdc.h"
#include "hw/tdc_regs.h"

static void tdc_gennum_setup_local_clock(struct spec_dev *dev, int freq)
{	
	unsigned int divot;
	unsigned int data;

	/* Setup local clock */
	divot = 800/freq - 1;
        data = 0xe001f00c + (divot << 4);
	writel(0x0001F04C, dev->remap[2] + 0x808);
}

static void tdc_fw_reset(struct spec_dev *dev)
{
	/* Reset FPGA. Assert ~RSTOUT33 and de-assert it. BAR 4.*/
	writel(0x00021040, dev->remap[2] + TDC_PCI_SYS_CFG_SYSTEM);
	mdelay(10);
	writel(0x00025000, dev->remap[2] + TDC_PCI_SYS_CFG_SYSTEM);
	mdelay(5000);
}


int tdc_probe(struct spec_dev *dev)
{
	struct spec_tdc *tdc;

	tdc = kzalloc(sizeof(struct spec_tdc), GFP_KERNEL);
	if (!tdc) {
		pr_err("%s: can't allocate device\n", __func__);
		return -ENOMEM;
	}

	dev->sub_priv = tdc;
	tdc->spec = dev;
	tdc->base = dev->remap[0]; 		/* BAR 0 */
	tdc->regs = tdc->base; 			/* BAR 0 */
	tdc->gn412x_regs = dev->remap[2]; 	/* BAR 4  */
	
	/* Setup the Gennum 412x local clock frequency */
	tdc_gennum_setup_local_clock(dev, 160);

	/* Reset FPGA to load the firmware */
	tdc_fw_reset(dev);

#if 0
	/* Load ACAM configuration */
	tdc_acam_load_config(tdc);

	/* Reset ACAM configuration */
	tdc_acam_reset(tdc);

#endif

#if 0
	/* XXX: Delete this part as it is for testing the FW */
	pr_err("SIG: tdc->base 0x%p\n", tdc->base);
	pr_err("SIG: current UTC 0x%x\n", readl(tdc->base + TDC_CURRENT_UTC));
#endif
	/* TODO: */
	return tdc_zio_register_device(tdc);
}

void tdc_remove(struct spec_dev *dev)
{
	struct spec_tdc *tdc = dev->sub_priv;

	tdc_zio_remove(tdc);
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
