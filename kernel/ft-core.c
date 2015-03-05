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
#include <linux/kfifo.h>

#include <linux/fmc.h>
#include <linux/fmc-sdb.h>

#include "fmc-tdc.h"
#include "hw/tdc_regs.h"

/* Module parameters */
static int ft_verbose;
module_param_named(verbose, ft_verbose, int, 0444);
MODULE_PARM_DESC(verbose, "Print a lot of debugging messages.");

static struct fmc_driver ft_drv;	/* forward declaration */
FMC_PARAM_BUSID(ft_drv);
FMC_PARAM_GATEWARE(ft_drv);

static int ft_show_sdb;
module_param_named(show_sdb, ft_show_sdb, int, 0444);
MODULE_PARM_DESC(verbose, "Print a dump of the gateware's SDB tree.");

static int ft_buffer_size = 64;
module_param_named(buffer_size, ft_buffer_size, int, 0444);
MODULE_PARM_DESC(verbose,
		 "Number of timestamps in each channel's software FIFO buffer (It must be a power of 2).");

static int ft_init_channel(struct fmctdc_dev *ft, int channel)
{
	struct ft_channel_state *st = &ft->channels[channel - 1];

	st->expected_edge = 1;
	st->fifo_len = ft_buffer_size;
	return kfifo_alloc(&st->fifo,
			   sizeof(struct ft_wr_timestamp) * st->fifo_len,
			   GFP_KERNEL);
}

static void ft_reset_channel(struct fmctdc_dev *ft, int channel)
{
	struct ft_channel_state *st = &ft->channels[channel - FT_CH_1];

	st->cur_seq_id = 0;
	st->expected_edge = 1;
	clear_bit(FT_FLAG_CH_INPUT_READY, &st->flags);
	ft_zio_kill_buffer(ft, channel);

	kfifo_reset(&st->fifo);
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
	uint32_t ien, cmd;
	int i;

	if (ft->acquisition_on == (enable ? 1 : 0))
		return;

	ien = ft_readl(ft, TDC_REG_INPUT_ENABLE);

	if (enable) {
		ien |= TDC_INPUT_ENABLE_FLAG;
		cmd = TDC_CTRL_EN_ACQ;
	} else {
		ien &= ~TDC_INPUT_ENABLE_FLAG;
		cmd = TDC_CTRL_DIS_ACQ;
	}

	spin_lock(&ft->lock);

	ft_writel(ft, ien, TDC_REG_INPUT_ENABLE);
	ft_writel(ft, TDC_CTRL_CLEAR_DACAPO_FLAG, TDC_REG_CTRL);
	ft_writel(ft, cmd, TDC_REG_CTRL);

	ft->acquisition_on = enable;

	if (!enable) {
		/* when disabling acquisition, clear the FIFOs,
		   reset width validation state machine and
		   sequence IDs */

		for (i = FT_CH_1; i <= FT_NUM_CHANNELS; i++)
			ft_reset_channel(ft, i);

		ft->prev_wr_ptr = ft->cur_wr_ptr = 0;
	}

	spin_unlock(&ft->lock);

	if (ft->verbose)
		dev_info(&ft->fmc->dev, "acquisition is %s\n",
			 enable ? "on" : "off");
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
	int i;

	for (i = FT_CH_1; i <= FT_NUM_CHANNELS; i++)
		kfifo_free(&ft->channels[i - 1].fifo);
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
	struct device *dev = fmc->hwdev;
	char *fwname;
	int i, index, ret, ord;

	ft = kzalloc(sizeof(struct fmctdc_dev), GFP_KERNEL);
	if (!ft) {
		dev_err(dev, "can't allocate device\n");
		return -ENOMEM;
	}

	index = fmc->op->validate(fmc, &ft_drv);
	if (index < 0) {
		dev_info(dev, "not using \"%s\" according to modparam\n",
			 KBUILD_MODNAME);
		return -ENODEV;
	}

	fmc->mezzanine_data = ft;
	ft->fmc = fmc;
	ft->verbose = ft_verbose;

	/* apply carrier-specific hacks and workarounds */
	if (!strcmp(fmc->carrier_name, "SPEC"))
		ft->carrier_specific = &ft_carrier_spec;
	else if (!strcmp(fmc->carrier_name, "SVEC"))
		ft->carrier_specific = &ft_carrier_svec;
	else {
		dev_err(dev, "unsupported carrier '%s'\n",
			fmc->carrier_name);
		return -ENODEV;
	}

	if (ft_drv.gw_n)
		fwname = "";	/* reprogram will pick from module parameter */
	else
		fwname = ft->carrier_specific->gateware_name;

	/* reprogram the card, but do not try to read the SDB.
	   Everything (including the SDB descriptor/bus logic) is clocked
	   from the FMC oscillator which needs to be bootstrapped by
	   the gateware with no possibility for the driver to check if
	   something went wrong... */

	ret = fmc_reprogram(fmc, &ft_drv, fwname, -1);
	if (ret < 0) {
		if (ret == -ESRCH) {
			dev_info(dev, "%s: no gateware at index %i\n",
				 KBUILD_MODNAME, index);
			return -ENODEV;
		}
		return ret;	/* other error: pass over */
	}

	dev_info(dev, "Gateware successfully loaded\n");

	ret = ft->carrier_specific->reset_core(ft);
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
	ft->ft_core_base = fmc_sdb_find_nth_device(fmc->sdb, 0xce42, 0x604, &ord, NULL);

	ft->ft_irq_base = ft->ft_core_base + TDC_MEZZ_EIC_OFFSET;
	ft->ft_owregs_base = ft->ft_core_base + TDC_MEZZ_ONEWIRE_OFFSET;
	ft->ft_buffer_base = ft->ft_core_base + TDC_MEZZ_MEM_OFFSET;

	if (ft_verbose) {
		dev_info(dev,
			 "Base addrs: core 0x%x, carrier_csr 0x%x, irq 0x%x, 1wire 0x%x, buffer/DMA 0x%X\n",
			 ft->ft_core_base, ft->ft_carrier_base, ft->ft_irq_base,
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

	return 0;
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

CERN_SUPER_MODULE;
