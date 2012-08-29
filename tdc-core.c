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
#include <linux/delay.h>
#include <asm/io.h>

#include "spec.h"
#include "tdc.h"
#include "hw/tdc_regs.h"

static void tdc_gennum_setup_local_clock(struct spec_tdc *tdc, int freq)
{	
	unsigned int divot;
	unsigned int data;

	/* Setup local clock */
	divot = 800/freq - 1;
        data = 0xE001F00C + (divot << 4);
	writel(0x0001F04C, tdc->gn412x_regs + TDC_PCI_CLK_CSR);
}

static void tdc_fw_reset(struct spec_tdc *tdc)
{
	/* Reset FPGA. Assert ~RSTOUT33 and de-assert it. BAR 4.*/
	writel(0x00021040, tdc->gn412x_regs + TDC_PCI_SYS_CFG_SYSTEM);
	mdelay(10);
	writel(0x00025000, tdc->gn412x_regs + TDC_PCI_SYS_CFG_SYSTEM);
	mdelay(5000);
}

/* XXX: Check that the value is properly written? */
int tdc_set_utc_time(struct spec_tdc *tdc)
{
	struct timeval utc_time;	
	
	do_gettimeofday(&utc_time);
	
	writel(utc_time.tv_sec, tdc->base + TDC_START_UTC);
	writel(TDC_CTRL_LOAD_UTC, tdc->base + TDC_CTRL_REG);
	return 0;
}

u32 tdc_get_utc_time(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_CURRENT_UTC);
}

/* XXX: void-function or I should check that the value is properly written? */
void tdc_set_irq_tstamp_thresh(struct spec_tdc *tdc, u32 val)
{
	writel(val, tdc->base + TDC_IRQ_TSTAMP_THRESH);
}

u32 tdc_get_irq_tstamp_thresh(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_IRQ_TSTAMP_THRESH);
}

/* XXX: void-function or I should check that the value is properly written? */
void tdc_set_irq_time_thresh(struct spec_tdc *tdc, u32 val)
{
	writel(val, tdc->base + TDC_IRQ_TIME_THRESH);
}

u32 tdc_get_irq_time_thresh(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_IRQ_TIME_THRESH);
}

/* XXX: void-function or I should check that the value is properly written? */
void tdc_set_dac_word(struct spec_tdc *tdc, u32 val)
{
	writel(val, tdc->base + TDC_DAC_WORD);
	writel(TDC_CTRL_CONFIG_DAC, tdc->base + TDC_CTRL_REG);
}

void tdc_clear_da_capo_flag(struct spec_tdc *tdc)
{
	writel(TDC_CTRL_CLEAR_DACAPO_FLAG, tdc->base + TDC_CTRL_REG);
}

void tdc_activate_adquisition(struct spec_tdc *tdc)
{
	/* Before activate the adquisition is required to reset the ACAM chip */
	tdc_acam_reset(tdc);
	writel(TDC_CTRL_EN_ACQ, tdc->base + TDC_CTRL_REG);
}

void tdc_deactivate_adquisition(struct spec_tdc *tdc)
{
	writel(TDC_CTRL_DIS_ACQ, tdc->base + TDC_CTRL_REG);
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
	tdc_gennum_setup_local_clock(tdc, 160);

	/* Reset FPGA to load the firmware */
	tdc_fw_reset(tdc);

#if 0
	/* Load ACAM configuration */
	tdc_acam_load_config(tdc);

	/* Reset ACAM configuration */
	tdc_acam_reset(tdc);

#endif

#if 1
	/* XXX: Delete this part as it is for testing the FW */
	pr_err("SIG: tdc->base 0x%p\n", tdc->base);
	tdc_set_utc_time(tdc);
	mdelay(20);
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
