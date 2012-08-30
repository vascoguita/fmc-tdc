/*
 * FMC support for tdc driver 
 *
 * Copyright (C) 2012 CERN (http://www.cern.ch)
 * Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation.
 */

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt 

#include <linux/delay.h>

#include "spec.h"
#include "tdc.h"
#include "hw/tdc_regs.h"

static struct fmc_driver tdc_fmc_driver;

static void tdc_fmc_gennum_setup_local_clock(struct spec_tdc *tdc, int freq)
{	
	unsigned int divot;
	unsigned int data;

	/* Setup local clock */
	divot = 800/freq - 1;
        data = 0xE001F00C + (divot << 4);
	writel(0x0001F04C, tdc->gn412x_regs + TDC_PCI_CLK_CSR);
}

static void tdc_fmc_fw_reset(struct spec_tdc *tdc)
{
	/* Reset FPGA. Assert ~RSTOUT33 and de-assert it. BAR 4.*/
	writel(0x00021040, tdc->gn412x_regs + TDC_PCI_SYS_CFG_SYSTEM);
	mdelay(10);
	writel(0x00025000, tdc->gn412x_regs + TDC_PCI_SYS_CFG_SYSTEM);
	/* Allow the FW to initialize the PLLs */
	mdelay(600);
}

irqreturn_t tdc_fmc_irq_handler(int irq, void *dev_id)
{
	struct fmc_device *fmc = dev_id;
	struct spec_dev *spec = fmc->carrier_data;
	struct spec_tdc *tdc = spec->sub_priv;

	/* TODO: fill with everything  */
	pr_err("tdc: IRQ is coming\n");
	
	/* Acknowledge the IRQ and exit */
	fmc->op->irq_ack(fmc);
	return IRQ_HANDLED;
}

int tdc_fmc_probe(struct fmc_device *dev)
{
	struct spec_tdc *tdc;
	struct spec_dev *spec;
	int ret;

	if(strcmp(dev->carrier_name, "SPEC") != 0)
		return -ENODEV;

	ret = dev->op->reprogram(dev, &tdc_fmc_driver, "fmc/eva_tdc_for_v2.bin");
	if (ret < 0) {
		pr_err("%s: error reprogramming the FPGA\n", __func__);
		return -ENODEV;
	}

	tdc = kzalloc(sizeof(struct spec_tdc), GFP_KERNEL);
	if (!tdc) {
		pr_err("%s: can't allocate device\n", __func__);
		return -ENOMEM;
	}

	spec = dev->carrier_data;
	tdc->spec = spec;
	spec->sub_priv = tdc;
	tdc->fmc = dev;
	tdc->base = spec->remap[0]; // XXX: or fmc->base ?? 		/* BAR 0 */
	tdc->regs = tdc->base; 			/* BAR 0 */
	tdc->gn412x_regs = spec->remap[2]; 	/* BAR 4  */
	tdc->wr_pointer = 0;
	
	/* Setup the Gennum 412x local clock frequency */
	tdc_fmc_gennum_setup_local_clock(tdc, 160);
	/* Reset FPGA to load the firmware */
	tdc_fmc_fw_reset(tdc);
	/* Setup default config to ACAM chip */
	tdc_acam_set_default_config(tdc);
	/* Reset ACAM chip */
	tdc_acam_reset(tdc);
	/* Request the IRQ */
	dev->op->irq_request(dev, tdc_fmc_irq_handler, "spec-tdc", IRQF_SHARED);

	return tdc_zio_register_device(tdc);
}

int tdc_fmc_remove(struct fmc_device *dev)
{
	struct spec_dev *spec = dev->carrier_data;
	struct spec_tdc *tdc = spec->sub_priv;

	tdc->fmc->op->irq_free(tdc->fmc);
	tdc_zio_remove(tdc);
	kfree(tdc);
	return 0;
}


int tdc_fmc_init(void)
{
	tdc_fmc_driver.probe = tdc_fmc_probe;
	tdc_fmc_driver.remove = tdc_fmc_remove;
	fmc_driver_register(&tdc_fmc_driver);
	return 0;
}

void tdc_fmc_exit(void)
{
	fmc_driver_unregister(&tdc_fmc_driver);
}


