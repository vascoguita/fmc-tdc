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


/* XXX: Check that the value is properly written? */
void tdc_set_utc_time(struct spec_tdc *tdc)
{
	struct timeval utc_time;	
	
	do_gettimeofday(&utc_time);
	
	writel(utc_time.tv_sec, tdc->base + TDC_START_UTC_R);
	writel(TDC_CTRL_LOAD_UTC, tdc->base + TDC_CTRL_REG);
}

u32 tdc_get_current_utc_time(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_CURRENT_UTC_R);
}

/* XXX: void-function or I should check that the value is properly written? */
void tdc_set_irq_tstamp_thresh(struct spec_tdc *tdc, u32 val)
{
	writel(val, tdc->base + TDC_IRQ_TSTAMP_THRESH_R);
}

u32 tdc_get_irq_tstamp_thresh(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_IRQ_TSTAMP_THRESH_R);
}

/* XXX: void-function or I should check that the value is properly written? */
void tdc_set_irq_time_thresh(struct spec_tdc *tdc, u32 val)
{
	writel(val, tdc->base + TDC_IRQ_TIME_THRESH_R);
}

u32 tdc_get_irq_time_thresh(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_IRQ_TIME_THRESH_R);
}

/* XXX: void-function or I should check that the value is properly written? */
void tdc_set_dac_word(struct spec_tdc *tdc, u32 val)
{
	writel(val, tdc->base + TDC_DAC_WORD_R);
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

void tdc_set_input_enable(struct spec_tdc *tdc, u32 value)
{
	writel(value, tdc->base + TDC_INPUT_ENABLE_R);
}

u32 tdc_get_input_enable(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_INPUT_ENABLE_R);
}

/* FIXME: This functions is likely to be inline! */
u32 tdc_get_circular_buffer_wr_pointer(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_CIRCULAR_BUF_PTR_R);
}

static int tdc_init(void)
{
	int err;

	err = tdc_zio_init();
	if (err < 0)
		return err;

	err = tdc_fmc_init();
	if (err < 0) {
		tdc_zio_exit();
		return err;
	}
	
	return 0;
}

static void tdc_exit(void)
{
	tdc_fmc_exit();
	tdc_zio_exit();
}

module_init(tdc_init);
module_exit(tdc_exit);

MODULE_LICENSE("GPL"); 		/* FIXME? Fine delay driver has LGPL (GPL and additional rights) */
