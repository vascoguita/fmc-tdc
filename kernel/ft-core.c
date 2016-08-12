/*
 * Main fmc-tdc driver module.
 *
 * Copyright (C) 2012-2013 CERN (www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation or, at your
 * option, any later version.
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/interrupt.h>
#include <linux/spinlock.h>
#include <linux/bitops.h>
#include <linux/delay.h>
#include <linux/slab.h>
#include <linux/init.h>
#include <linux/list.h>
#include <linux/io.h>

#include <linux/fmc.h>
#include <linux/fmc-sdb.h>

#include <linux/zio.h>
#include <linux/zio-trigger.h>

#include "fmc-tdc.h"
#include "hw/tdc_regs.h"

/* Module parameters */
static int ft_verbose;
module_param_named(verbose, ft_verbose, int, 0444);
MODULE_PARM_DESC(verbose, "Print a lot of debugging messages.");

static struct fmc_driver ft_drv;	/* forward declaration */
FMC_PARAM_BUSID(ft_drv);
FMC_PARAM_GATEWARE(ft_drv);

static char bitstream_name[32];

static int ft_reset_core(struct fmctdc_dev *ft)
{
	uint32_t val, shift = 0, addr;

	if (!strcmp(ft->fmc->carrier_name, "SVEC")) {
		shift = 1;
		addr = TDC_SVEC_CARRIER_BASE;
	} else {
		addr = TDC_SPEC_CARRIER_BASE;
	}
	addr += TDC_REG_CARRIER_RST;

	dev_dbg(&ft->fmc->dev, "Un-resetting FMCs...\n");

	/* Reset - reset bits are shifted by 1 */
	ft_iowrite(ft, ~(1 << (ft->fmc->slot_id + shift)), addr);

	udelay(5000);

	val = ft_ioread(ft, addr);
	val |= (1 << (ft->fmc->slot_id + shift));

	/* Un-Reset */
	ft_iowrite(ft, val, addr);

	return 0;
}

static int ft_init_channel(struct fmctdc_dev *ft, int channel)
{
	struct ft_channel_state *st = &ft->channels[channel - 1];

	st->expected_edge = 1;
	return 0;
}


int ft_enable_termination(struct fmctdc_dev *ft, int channel, int enable)
{
	struct ft_channel_state *st;
	uint32_t ien;

	if (channel < FT_CH_1 || channel > FT_NUM_CHANNELS)
		return -EINVAL;

	st = &ft->channels[channel - 1];

	ien = ft_readl(ft, TDC_REG_INPUT_ENABLE);

	if (enable)
		ien |= (1 << (channel - 1));
	else
		ien &= ~(1 << (channel - 1));

	ft_writel(ft, ien, TDC_REG_INPUT_ENABLE);

	if (enable)
		set_bit(FT_FLAG_CH_TERMINATED, &st->flags);
	else
		clear_bit(FT_FLAG_CH_TERMINATED, &st->flags);

	return 0;
}

void ft_enable_acquisition(struct fmctdc_dev *ft, int enable)
{
	uint32_t ien;

	ien = ft_readl(ft, TDC_REG_INPUT_ENABLE);
	if (enable) {
		/* Enable TDC acquisition */
		ft_writel(ft, ien | TDC_INPUT_ENABLE_CH_ALL | TDC_INPUT_ENABLE_FLAG,
			  TDC_REG_INPUT_ENABLE);
		/* Enable ACAM acquisition */
		ft_writel(ft, TDC_CTRL_EN_ACQ, TDC_REG_CTRL);
	} else {
		/* Disable ACAM acquisition */
		ft_writel(ft, TDC_CTRL_DIS_ACQ, TDC_REG_CTRL);
		/* Disable TDC acquisition */
		ft_writel(ft, ien & ~(TDC_INPUT_ENABLE_CH_ALL | TDC_INPUT_ENABLE_FLAG),
			  TDC_REG_INPUT_ENABLE);
	}
}


static int ft_channels_init(struct fmctdc_dev *ft)
{
	int i, ret;

	for (i = FT_CH_1; i <= FT_NUM_CHANNELS; i++) {
		ret = ft_init_channel(ft, i);
		if (ret < 0)
			return ret;
		/* termination is off by default */
		ft_enable_termination(ft, i, 0);
	}
	return 0;
}

static void ft_channels_exit(struct fmctdc_dev *ft)
{
	return;
}

struct ft_modlist {
	char *name;

	int (*init)(struct fmctdc_dev *);
	void (*exit)(struct fmctdc_dev *);
};

static struct ft_modlist init_subsystems[] = {
	{"acam-tdc", ft_acam_init, ft_acam_exit},
	{"onewire", ft_onewire_init, ft_onewire_exit},
	{"time", ft_time_init, ft_time_exit},
	{"channels", ft_channels_init, ft_channels_exit},
	{"zio", ft_zio_init, ft_zio_exit}
};

/* probe and remove are called by the FMC bus core */
int ft_probe(struct fmc_device *fmc)
{
	struct ft_modlist *m;
	struct fmctdc_dev *ft;
	struct device *dev = &fmc->dev;
	char *fwname;
	int i, index, ret, ord;

	ft = kzalloc(sizeof(struct fmctdc_dev), GFP_KERNEL);
	if (!ft) {
		dev_err(dev, "can't allocate device\n");
		return -ENOMEM;
	}

	index = fmc_validate(fmc, &ft_drv);
	if (index < 0) {
		dev_info(dev, "not using \"%s\" according to modparam\n",
			 KBUILD_MODNAME);
		return -ENODEV;
	}

	fmc->mezzanine_data = ft;
	ft->fmc = fmc;
	ft->verbose = ft_verbose;

	/* apply carrier-specific hacks and workarounds */
	if (!strcmp(ft->fmc->carrier_name, "SVEC")) {
	        sprintf(bitstream_name, FT_GATEWARE_SVEC);
	} else if (!strcmp(fmc->carrier_name, "SPEC")) {
		sprintf(bitstream_name, FT_GATEWARE_SPEC);
	} else {
		dev_err(dev, "unsupported carrier '%s'\n", fmc->carrier_name);
		return -ENODEV;
	}

	/*
	 * If the carrier is still using the golden bitstream or the user is
	 * asking for a particular one, then program our bistream, otherwise
	 * we already have our bitstream
	 */
	if (fmc->flags & FMC_DEVICE_HAS_GOLDEN || ft_drv.gw_n) {
		if (ft_drv.gw_n)
			fwname = ""; /* reprogram will pick from module parameter */
		else
			fwname = bitstream_name;
		dev_info(fmc->hwdev, "Gateware (%s)\n", fwname);

		ret = fmc_reprogram(fmc, &ft_drv, fwname, -1);
		if (ret < 0) {
			dev_err(fmc->hwdev, "write firmware \"%s\": error %i\n",
				fwname, ret);
			if (ret == -ESRCH) {
				dev_err(dev, "no gateware at index %i\n",
					index);
				return -ENODEV;
			}
			return ret;	/* other error: pass over */
		}

		dev_dbg(dev, "Gateware successfully loaded\n");
	} else {
		dev_info(fmc->hwdev,
			 "Gateware already there. Set the \"gateware\" parameter to overwrite the current gateware\n");
	}

	ret = ft_reset_core(ft);
	if (ret < 0)
		return ret;

	/* Now that the PLL is locked, we can read the SDB info */
	ret = fmc_scan_sdb_tree(fmc, 0);
	if (ret < 0 && ret != -EBUSY) {
		dev_err(dev,
			"%s: no SDB in the bitstream. Are you sure you've provided the correct one?\n",
			KBUILD_MODNAME);
		return ret;
	}

	/* Now use SDB to find the base addresses */
	ord = fmc->slot_id;
	ft->ft_core_base = fmc_sdb_find_nth_device(fmc->sdb, 0xce42, 0x604,
						   &ord, NULL);

	ft->ft_irq_base = ft->ft_core_base + TDC_MEZZ_EIC_OFFSET;
	ft->ft_owregs_base = ft->ft_core_base + TDC_MEZZ_ONEWIRE_OFFSET;
	ft->ft_buffer_base = ft->ft_core_base + TDC_MEZZ_MEM_OFFSET;

	if (ft_verbose) {
		dev_info(dev,
			 "Base addrs: core 0x%x, irq 0x%x, 1wire 0x%x, buffer/DMA 0x%X\n",
			 ft->ft_core_base, ft->ft_irq_base,
			 ft->ft_owregs_base, ft->ft_buffer_base);
	}

	spin_lock_init(&ft->lock);

	/* Retrieve calibration from the eeprom, and validate */
	ret = ft_handle_eeprom_calibration(ft);
	if (ret < 0)
		return ret;

	/* init all subsystems */
	for (i = 0, m = init_subsystems; i < ARRAY_SIZE(init_subsystems);
	     i++, m++) {
		ret = m->init(ft);
		if (ret < 0)
			goto err;
	}

	ret = ft_irq_init(ft);
	if (ret < 0)
		goto err;

	ft_enable_acquisition(ft, 1);
	ft->initialized = 1;
	ft->sequence = 0;

	/* Pin the carrier */
	if (!try_module_get(fmc->owner))
		goto out_mod;

	return 0;

out_mod:
	ft_irq_exit(ft);
err:
	while (--m, --i >= 0)
		if (m->exit)
			m->exit(ft);
	return ret;
}

int ft_remove(struct fmc_device *fmc)
{
	struct ft_modlist *m;
	struct fmctdc_dev *ft = fmc->mezzanine_data;

	int i = ARRAY_SIZE(init_subsystems);

	if (!ft->initialized)
		return 0;	/* No init, no exit */

	ft_enable_acquisition(ft, 0);
	ft_irq_exit(ft);

	while (--i >= 0) {
		m = init_subsystems + i;
		if (m->exit)
			m->exit(ft);
	}

	/* Release the carrier */
	module_put(fmc->owner);

	return 0;
}

static struct fmc_fru_id ft_fru_id[] = {
	{
	 .product_name = "FmcTdc1ns5cha",
	 },
};

static struct fmc_driver ft_drv = {
	.version = FMC_VERSION,
	.driver.name = KBUILD_MODNAME,
	.probe = ft_probe,
	.remove = ft_remove,
	.id_table = {
		     .fru_id = ft_fru_id,
		     .fru_id_nr = ARRAY_SIZE(ft_fru_id),
		     },
};

static int ft_init(void)
{
	int ret;

	ret = ft_zio_register();
	if (ret < 0)
		return ret;

	ret = fmc_driver_register(&ft_drv);
	if (ret < 0) {
		ft_zio_unregister();
		return ret;
	}
	return 0;
}

static void ft_exit(void)
{
	fmc_driver_unregister(&ft_drv);
	ft_zio_unregister();
}

module_init(ft_init);
module_exit(ft_exit);

MODULE_VERSION(GIT_VERSION);
MODULE_LICENSE("GPL and additional rights");	/* LGPL */

ADDITIONAL_VERSIONS;
