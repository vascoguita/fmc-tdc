/*
 * ACAM TDC-GPX routines support for fmc-tdc driver.
 *
 * Copyright (C) 2013 CERN (http://www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation.
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/delay.h>
#include <linux/io.h>

#include "fmc-tdc.h"

#include "hw/tdc_regs.h"
#include "hw/acam_gpx.h"

#define NB_ACAM_REGS 11

static struct {
	int reg;
	u32 value;
} acam_config[NB_ACAM_REGS] = {
	{
	0, AR0_ROsc | AR0_HQSel | AR0_TRiseEn(0) |
		    AR0_TRiseEn(1) | AR0_TRiseEn(2) |
		    AR0_TRiseEn(3) | AR0_TRiseEn(4) |
		    AR0_TRiseEn(5) |
		    AR0_TFallEn(1) | AR0_TFallEn(2) |
		    AR0_TFallEn(3) | AR0_TFallEn(4) | AR0_TFallEn(5)}, {
	1, 0}, {
	2, AR2_IMode | AR2_Disable(6) | AR2_Disable(7) | AR2_Disable(8)}, {
	3, 0}, {
	4, AR4_StartTimer(15) | AR4_EFlagHiZN}, {
	5, AR5_StartOff1(2000)}, {
	6, AR6_Fill(0xfc)}, {
	7, AR7_RefClkDiv(7) | AR7_HSDiv(234) | AR7_NegPhase | AR7_ResAdj}, {
	11, AR11_HFifoErrU(0) | AR11_HFifoErrU(1) |
		    AR11_HFifoErrU(2) | AR11_HFifoErrU(3) |
		    AR11_HFifoErrU(4) | AR11_HFifoErrU(5) |
		    AR11_HFifoErrU(6) | AR11_HFifoErrU(7)}, {
	12, AR12_StartNU | AR12_HFifoE}, {
	14, 0}
};

static inline int acam_is_pll_locked(struct fmctdc_dev *ft)
{
	uint32_t status;

	ft_writel(ft, TDC_CTRL_READ_ACAM_CFG, TDC_REG_CTRL);
	udelay(100);

	status = ft_readl(ft, TDC_REG_ACAM_READBACK(12));

	return !(status & AR12_NotLocked);
}

int ft_acam_init(struct fmctdc_dev *ft)
{
	int i;
	unsigned long tmo;

	pr_debug("%s: initializing ACAM TDC...\n", __func__);

	ft_writel(ft, TDC_CTRL_RESET_ACAM, TDC_REG_CTRL);

	udelay(100);

	for (i = 0; i < NB_ACAM_REGS; i++) {
		ft_writel(ft, acam_config[i].value,
			  TDC_REG_ACAM_CONFIG(acam_config[i].reg));
	}

	/* commit ACAM config regs */
	ft_writel(ft, TDC_CTRL_LOAD_ACAM_CFG, TDC_REG_CTRL);
	udelay(100);

	/* and reset the chip (keeps configuration) */
	ft_writel(ft, TDC_CTRL_RESET_ACAM, TDC_REG_CTRL);
	udelay(100);

	/* wait for the ACAM's PLL to lock (2 seconds) */
	tmo = jiffies + 2 * HZ;
	while (time_before(jiffies, tmo)) {
		if (acam_is_pll_locked(ft)) {
			dev_info(&ft->fmc->dev, "%s: ACAM initialization OK.\n",
				 __func__);
			return 0;
		}
	}

	dev_err(&ft->fmc->dev, "%s: ACAM PLL doesn't lock\n", __func__);
	return -EIO;
}

void ft_acam_exit(struct fmctdc_dev *ft)
{
	/* Disable ACAM inputs and PLL */

	ft_writel(ft, TDC_CTRL_DIS_ACQ, TDC_REG_CTRL);
	ft_writel(ft, 0, TDC_REG_ACAM_CONFIG(0));
	ft_writel(ft, 0, TDC_REG_ACAM_CONFIG(7));
	ft_writel(ft, TDC_CTRL_LOAD_ACAM_CFG, TDC_REG_CTRL);
	udelay(100);
}
