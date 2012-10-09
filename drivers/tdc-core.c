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

int lun[MAX_DEVICES];
unsigned int nlun;
module_param_array(lun, int, &nlun, S_IRUGO);

int bus[MAX_DEVICES];
unsigned int nbus;
module_param_array(bus, int, &nbus, S_IRUGO);

int slot[MAX_DEVICES];
unsigned int nslot;
module_param_array(slot, int, &nslot, S_IRUGO);

char *gateware = "eva_tdc_for_v2.bin";
module_param(gateware, charp, S_IRUGO);

void tdc_set_utc_time(struct spec_tdc *tdc, u32 value)
{
	writel(value, tdc->base + TDC_START_UTC_R);
	writel(TDC_CTRL_LOAD_UTC, tdc->base + TDC_CTRL_REG);
}

void tdc_set_local_utc_time(struct spec_tdc *tdc)
{
	struct timeval utc_time;

	do_gettimeofday(&utc_time);
	tdc_set_utc_time(tdc, utc_time.tv_sec);
}

u32 tdc_get_current_utc_time(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_CURRENT_UTC_R);
}

void tdc_set_irq_tstamp_thresh(struct spec_tdc *tdc, u32 val)
{
	writel(val, tdc->base + TDC_IRQ_TSTAMP_THRESH_R);
}

u32 tdc_get_irq_tstamp_thresh(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_IRQ_TSTAMP_THRESH_R);
}

void tdc_set_irq_time_thresh(struct spec_tdc *tdc, u32 val)
{
	writel(val, tdc->base + TDC_IRQ_TIME_THRESH_R);
}

u32 tdc_get_irq_time_thresh(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_IRQ_TIME_THRESH_R);
}

void tdc_set_dac_word(struct spec_tdc *tdc, u32 val)
{
	writel(val, tdc->base + TDC_DAC_WORD_R);
	writel(TDC_CTRL_CONFIG_DAC, tdc->base + TDC_CTRL_REG);
}

u32 tdc_get_dac_word(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_DAC_WORD_R);
}

void tdc_clear_da_capo_flag(struct spec_tdc *tdc)
{
	writel(TDC_CTRL_CLEAR_DACAPO_FLAG, tdc->base + TDC_CTRL_REG);
}

int tdc_activate_acquisition(struct spec_tdc *tdc)
{
	u32 acam_status_test;
	/* Before activate the adquisition is required to reset the ACAM chip */
	tdc_acam_reset(tdc);

	acam_status_test = tdc_acam_status(tdc)-0xC4000800;
	if (acam_status_test != 0) {
        	pr_err( "ACAM status: not ready! 0x%x\n", acam_status_test);
		return -EBUSY;
	}

	writel(TDC_CTRL_EN_ACQ, tdc->base + TDC_CTRL_REG);
	return 0;
}

void tdc_deactivate_acquisition(struct spec_tdc *tdc)
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

inline u32 tdc_get_circular_buffer_wr_pointer(struct spec_tdc *tdc)
{
	return readl(tdc->base + TDC_CIRCULAR_BUF_PTR_R);
}

static int check_parameters(void)
{
	if (nlun < 0 || nlun > MAX_DEVICES) {
		pr_err("Invalid number of devices (%d)", nlun);
		return -EINVAL;
	}

	if ((nlun != nbus) || (nlun != nslot)) {
		pr_err("Parameter mismatch: %d luns, %d buses and %d slots\n",
		       nlun, nbus, nslot);
		return -EINVAL;
	}

	if (nlun == 0) {
		pr_err("No LUNs provided. The driver won't match any device");
	}

	return 0;
}

static int tdc_init(void)
{
	int err;

	err = check_parameters();
	if (err < 0)
		return err;

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

MODULE_LICENSE("GPL");
