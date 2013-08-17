/*
 * Time-related routines for fmc-tdc driver.
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
#include <asm/io.h>

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

int ft_set_tai_time(struct fmctdc_dev *ft, uint64_t seconds, uint32_t coarse)
{
	if (ft->acquisition_on) /* can't change time when inputs are enabled */
	    return -EAGAIN;

	if (ft->verbose)
		dev_info(&ft->fmc->dev, "Setting TAI time to %lld:%d\n",
			 seconds, coarse);

	if(coarse != 0)
	    dev_warn(&ft->fmc->dev, "Warning: ignoring sub-second part (%d) when setting time.\n", coarse);

	ft_writel(ft, seconds & 0xffffffff, TDC_REG_START_UTC);
	ft_writel(ft, TDC_CTRL_LOAD_UTC, TDC_REG_CTRL);
	return 0;
}

int ft_get_tai_time(struct fmctdc_dev *ft, uint64_t * seconds,
		    uint32_t * coarse)
{
	*seconds = ft_readl(ft, TDC_REG_CURRENT_UTC);
	*coarse = 0;
	return 0;
}

int ft_set_host_time (struct fmctdc_dev *ft)
{
	struct timespec local_ts;

	if (ft->acquisition_on) /* can't change time when inputs are enabled */
	    return -EAGAIN;

	getnstimeofday(&local_ts);

	ft_writel(ft, local_ts.tv_sec & 0xffffffff, TDC_REG_START_UTC);
	ft_writel(ft, TDC_CTRL_LOAD_UTC, TDC_REG_CTRL);
	return 0;
}

int ft_enable_wr_mode(struct fmctdc_dev *ft, int enable)
{
	return -ENOTSUPP;
}

int ft_check_wr_mode(struct fmctdc_dev *ft)
{
	return -ENOTSUPP;
}

int ft_time_init(struct fmctdc_dev *ft)
{
	/* program the VCXO DAC to the default calibration value */
	ft_writel(ft, ft->calib.vcxo_default_tune, TDC_REG_DAC_TUNE);
	ft_writel(ft, TDC_CTRL_CONFIG_DAC, TDC_REG_CTRL);

	return ft_set_tai_time(ft, 0, 0);
}

void ft_time_exit(struct fmctdc_dev *ft)
{
}
