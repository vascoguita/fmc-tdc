/*
 * Time-related routines for fmc-tdc driver.
 *
 * Copyright (C) 2013 CERN (http://www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/delay.h>
#include <linux/io.h>

#include "fmc-tdc.h"

#include "hw/tdc_regs.h"

/* WARNING: the seconds register name is a bit misleading - it is not UTC time
   as the core is not aware of leap seconds, making it TAI time. */

void ft_ts_from_picos(uint32_t picos, struct ft_wr_timestamp *result)
{
	result->frac = (picos % 8000) * 4096 / 8000;
	result->coarse = (picos / 8000);
	result->seconds = 0;
}

void ft_ts_add(struct ft_wr_timestamp *a, struct ft_wr_timestamp *b)
{
	a->frac += b->frac;

	if (unlikely(a->frac >= 4096)) {
		a->frac -= 4096;
		a->coarse++;
	}

	a->coarse += b->coarse;

	if (unlikely(a->coarse >= 125000000)) {
		a->coarse -= 125000000;
		a->seconds++;
	}

	a->seconds += b->seconds;
}

void ft_ts_sub(struct ft_wr_timestamp *a, struct ft_wr_timestamp *b)
{
	int32_t d_frac, d_coarse = 0;

	d_frac = a->frac - b->frac;

	if (unlikely(d_frac < 0)) {
		d_frac += 4096;
		d_coarse--;
	}

	d_coarse += a->coarse - b->coarse;

	if (unlikely(d_coarse < 0)) {
		d_coarse += 125000000;
		a->seconds--;
	}

	a->coarse = d_coarse;
	a->frac = d_frac;
	a->seconds -= b->seconds;
}

void ft_ts_apply_offset(struct ft_wr_timestamp *ts, int32_t offset_picos)
{
	struct ft_wr_timestamp offset_ts;

	ft_ts_from_picos(offset_picos < 0 ? -offset_picos : offset_picos,
			 &offset_ts);

	if (offset_picos < 0)
		ft_ts_sub(ts, &offset_ts);
	else
		ft_ts_add(ts, &offset_ts);
}

void ft_set_tai_time(struct fmctdc_dev *ft, uint64_t seconds, uint32_t coarse)
{
	uint32_t ien;

	/* can't change time when inputs are enabled */
	ien = ft_readl(ft, TDC_REG_INPUT_ENABLE);
	ft_writel(ft, ien & ~TDC_INPUT_ENABLE_FLAG, TDC_REG_INPUT_ENABLE);


	if (ft->verbose)
		dev_info(&ft->fmc->dev, "Setting TAI time to %lld:%d\n",
			 seconds, coarse);

	if (coarse != 0)
		dev_warn(&ft->fmc->dev,
			 "Warning: ignoring sub-second part (%d) when setting time.\n",
			 coarse);

	ft_writel(ft, seconds & 0xffffffff, TDC_REG_START_UTC);
	ft_writel(ft, TDC_CTRL_LOAD_UTC, TDC_REG_CTRL);

	ft_writel(ft, ien | TDC_INPUT_ENABLE_FLAG, TDC_REG_INPUT_ENABLE);
}

void ft_get_tai_time(struct fmctdc_dev *ft, uint64_t *seconds,
		      uint32_t *coarse)
{
	*seconds = ft_readl(ft, TDC_REG_CURRENT_UTC);
	*coarse = 0;
}

void ft_set_host_time(struct fmctdc_dev *ft)
{
	struct timespec local_ts;
	uint32_t ien;

	/* can't change time when inputs are enabled */
	ien = ft_readl(ft, TDC_REG_INPUT_ENABLE);
	ft_writel(ft, ien & ~TDC_INPUT_ENABLE_FLAG, TDC_REG_INPUT_ENABLE);

	getnstimeofday(&local_ts);

	ft_writel(ft, local_ts.tv_sec & 0xffffffff, TDC_REG_START_UTC);
	ft_writel(ft, TDC_CTRL_LOAD_UTC, TDC_REG_CTRL);

	ft_writel(ft, ien | TDC_INPUT_ENABLE_FLAG, TDC_REG_INPUT_ENABLE);

}

void ft_set_vcxo_tune(struct fmctdc_dev *ft, int value)
{
	ft_writel(ft, value, TDC_REG_DAC_TUNE);
	ft_writel(ft, TDC_CTRL_CONFIG_DAC, TDC_REG_CTRL);
}

int ft_wr_mode(struct fmctdc_dev *ft, int on)
{
	unsigned long flags;
	uint32_t wr_stat;

	spin_lock_irqsave(&ft->lock, flags);

	if (on) {
		ft_writel(ft, TDC_WR_CTRL_ENABLE, TDC_REG_WR_CTRL);
		ft->wr_mode = 1;
	} else {
		ft_writel(ft, 0, TDC_REG_WR_CTRL);
		ft->wr_mode = 0;
		ft_set_vcxo_tune(ft, ft->calib.vcxo_default_tune & 0xffff);
	}

	spin_unlock_irqrestore(&ft->lock, flags);

	wr_stat = ft_readl(ft, TDC_REG_WR_STAT);
	if (!(wr_stat & TDC_WR_STAT_LINK))
		return -ENOLINK;
	return 0;
}

int ft_wr_query(struct fmctdc_dev *ft)
{
	uint32_t wr_stat;

	wr_stat = ft_readl(ft, TDC_REG_WR_STAT);

	if (!ft->wr_mode)
		return -ENODEV;
	if (!(wr_stat & TDC_WR_STAT_LINK))
		return -ENOLINK;
	if (wr_stat & TDC_WR_STAT_AUX_LOCKED)
		return 0;
	return -EAGAIN;
}

int ft_time_init(struct fmctdc_dev *ft)
{
	/* program the VCXO DAC to the default calibration value */
	ft_set_vcxo_tune(ft, ft->calib.vcxo_default_tune);
	ft_set_tai_time(ft, 0, 0);
	return 0;
}

void ft_time_exit(struct fmctdc_dev *ft)
{
}
