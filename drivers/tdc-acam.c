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

static void __tdc_acam_do_load_config(struct spec_tdc *tdc)
{
	writel(TDC_CTRL_LOAD_ACAM_CFG, tdc->base + TDC_CTRL_REG);
}

static void __tdc_acam_do_read_config(struct spec_tdc *tdc)
{
	writel(TDC_CTRL_READ_ACAM_CFG, tdc->base + TDC_CTRL_REG);
}

u32 tdc_acam_status(struct spec_tdc *tdc)
{
	/* Send the command to read acam status */
	writel(TDC_CTRL_READ_ACAM_STAT, tdc->base + TDC_CTRL_REG);

	/* TODO: Where to read it? */
	return 0;
}

u32 tdc_acam_read_ififo1(struct spec_tdc *tdc)
{
	/* Send the command to read acam status */
	writel(TDC_CTRL_READ_ACAM_IFIFO1, tdc->base + TDC_CTRL_REG);
	return readl(tdc->base + TDC_ACAM_RDBACK_REG_8);
}

u32 tdc_acam_read_ififo2(struct spec_tdc *tdc)
{
	/* Send the command to read acam status */
	writel(TDC_CTRL_READ_ACAM_IFIFO2, tdc->base + TDC_CTRL_REG);
	return readl(tdc->base + TDC_ACAM_RDBACK_REG_9);
}

u32 tdc_acam_read_start01(struct spec_tdc *tdc)
{
	/* Send the command to read acam status */
	writel(TDC_CTRL_READ_ACAM_START01_R, tdc->base + TDC_CTRL_REG);
	return readl(tdc->base + TDC_ACAM_RDBACK_REG_10);
}

int tdc_acam_load_config(struct spec_tdc *tdc, struct tdc_acam_cfg *cfg)
{

	/* Write the configuration parameters to the registers */
	writel(cfg->edge_config, tdc->base + TDC_ACAM_CFG_REG_0);
	writel(cfg->channel_adj, tdc->base + TDC_ACAM_CFG_REG_1);
	writel(cfg->mode_enable, tdc->base + TDC_ACAM_CFG_REG_2);
	writel(cfg->resolution, tdc->base + TDC_ACAM_CFG_REG_3);
	writel(cfg->start_timer_set, tdc->base + TDC_ACAM_CFG_REG_4);
	writel(cfg->start_retrigger, tdc->base + TDC_ACAM_CFG_REG_5);
	writel(cfg->lf_flags_level, tdc->base + TDC_ACAM_CFG_REG_6);
	writel(cfg->pll, tdc->base + TDC_ACAM_CFG_REG_7);
	writel(cfg->err_flag_cfg, tdc->base + TDC_ACAM_CFG_REG_11);
	writel(cfg->int_flag_cfg, tdc->base + TDC_ACAM_CFG_REG_12);
	writel(cfg->ctrl_16_bit_mode, tdc->base + TDC_ACAM_CFG_REG_14);

	/* Send the load command to the firmware */
	__tdc_acam_do_load_config(tdc);
	return 0;
}

int tdc_acam_get_config(struct spec_tdc *tdc, struct tdc_acam_cfg *cfg)
{
	/* Send read config command to retrieve the data to the registers */
	__tdc_acam_do_read_config(tdc);

	/* Read the configuration values from the read-back registers */
	cfg->edge_config = readl(tdc->base + TDC_ACAM_RDBACK_REG_0);
	cfg->channel_adj = readl(tdc->base + TDC_ACAM_RDBACK_REG_1);
	cfg->mode_enable = readl(tdc->base + TDC_ACAM_RDBACK_REG_2);
	cfg->resolution = readl(tdc->base + TDC_ACAM_RDBACK_REG_3);
	cfg->start_timer_set = readl(tdc->base + TDC_ACAM_RDBACK_REG_4);
	cfg->start_retrigger = readl(tdc->base + TDC_ACAM_RDBACK_REG_5);
	cfg->lf_flags_level = readl(tdc->base + TDC_ACAM_RDBACK_REG_6);
	cfg->pll = readl(tdc->base + TDC_ACAM_RDBACK_REG_7);
	cfg->err_flag_cfg = readl(tdc->base + TDC_ACAM_RDBACK_REG_11);
	cfg->int_flag_cfg = readl(tdc->base + TDC_ACAM_RDBACK_REG_12);
	cfg->ctrl_16_bit_mode = readl(tdc->base + TDC_ACAM_RDBACK_REG_14);

	return 0;
}

int tdc_acam_set_default_config(struct spec_tdc *tdc)
{
	struct tdc_acam_cfg cfg;

	/* Default setup as indicated in the datasheet */
	cfg.edge_config = 0x01F0FC81;
	cfg.channel_adj = 0x0;
	cfg.mode_enable = 0xE02;
	cfg.resolution = 0x0;
	cfg.start_timer_set = 0x0200000F;
	cfg.start_retrigger = 0x07D0;
	cfg.lf_flags_level = 0x03;
	cfg.pll = 0x001FEA;
	cfg.err_flag_cfg = 0x00FF0000;
	cfg.int_flag_cfg = 0x04000000;
	cfg.ctrl_16_bit_mode = 0x0;

	return tdc_acam_load_config(tdc, &cfg);
}
