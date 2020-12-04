/*
 * Main fmc-tdc driver module.
 *
 * Copyright (C) 2012-2013 CERN (www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
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
#include <linux/platform_device.h>
#include <linux/ipmi/fru.h>
#include <linux/fmc.h>

#include <linux/zio.h>
#include <linux/zio-trigger.h>

#include "fmc-tdc.h"
#include "platform_data/fmc-tdc.h"
#include "hw/tdc_regs.h"

int irq_timeout_ms_default = 10;
module_param_named(irq_timeout_ms, irq_timeout_ms_default, int, 0444);
MODULE_PARM_DESC(irq_timeout_ms, "IRQ coalesing timeout (default: 10ms).");

static int test_data_period = 0;
module_param_named(test_data_period, test_data_period, int, 0444);
MODULE_PARM_DESC(test_data_period,
		 "It sets how many fake timestamps to generate every seconds on the first channel, 0 to disable (default: 0)");

#define FT_EEPROM_TYPE "at24c64"

/**
 * It sets the coalescing timeout for the DMA buffers
 * @ft FmcTdc instance
 * @chan channel buffer -1 for all channels, otherwise [0, 4]
 * @timeout timeout in milliseconds
 */
static void ft_dma_irq_coalescing_timeout_set(struct fmctdc_dev *ft,
					      unsigned int chan,
					      uint32_t timeout)
{
	int i;

	for (i = (chan == -1 ? 0 : chan);
	     i < (chan == -1 ? ft->zdev->n_cset : chan + 1);
	     ++i) {
		uint32_t tmp;
		void *base;

		base = ft->ft_dma_base + (0x40 * i);
		tmp = ft_ioread(ft, base + TDC_BUF_REG_CSR);
		tmp &= ~TDC_BUF_CSR_IRQ_TIMEOUT_MASK;
		tmp |= TDC_BUF_CSR_IRQ_TIMEOUT_W(timeout);
		ft_iowrite(ft, tmp, base + TDC_BUF_REG_CSR);
	}
}

/**
 * It gets the coalescing timeout for the DMA buffers
 * @ft FmcTdc instance
 * @chan channel buffer [0, 4]
 *
 * Return: timeout in milliseconds
 */
static uint32_t ft_dma_irq_coalescing_timeout_get(struct fmctdc_dev *ft,
						  unsigned int chan)
{
	void *base = ft->ft_dma_base + (0x40 * chan);
	uint32_t tmp;

	tmp = ft_ioread(ft, base + TDC_BUF_REG_CSR);

	return TDC_BUF_CSR_IRQ_TIMEOUT_R(tmp);
}


/**
 * It sets the coalescing timeout according to the acquisition mode
 * @ft FmcTdc instance
 * @chan channe [0, 4] (used only for DMA acquisition mode)
 * @timeout_ms timeout in milliseconds to trigger IRQ
 */
void ft_irq_coalescing_timeout_set(struct fmctdc_dev *ft,
				   unsigned int chan,
				   uint32_t timeout_ms)
{
	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		if (unlikely(chan != -1)) {
			dev_dbg(&ft->pdev->dev,
				 "%s: FIFO acquisition mode has a gobal coalesing timeout. Ignore channel %d, set global value\n",
				 __func__, chan);
		}
		ft_writel(ft, timeout_ms, TDC_REG_IRQ_TIMEOUT);
		break;
	case FT_ACQ_TYPE_DMA:
		ft_dma_irq_coalescing_timeout_set(ft, chan, timeout_ms);
		break;
	}
}

/**
 * It sets the coalescing size according to the acquisition mode
 * @ft FmcTdc instance
 * @chan channe [0, 4] (used only for DMA acquisition mode)
 *
 * Return: timeout in milliseconds
 */
uint32_t ft_irq_coalescing_timeout_get(struct fmctdc_dev *ft,
				       unsigned int chan)
{
	uint32_t timeout = 0;

	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		if (unlikely(chan != -1)) {
			dev_dbg(&ft->pdev->dev,
				 "%s: FIFO acquisition mode has a gobal coalesing timeout. Ignore channel %d, get global value\n",
				 __func__, chan);
		}
		timeout = ft_readl(ft, TDC_REG_IRQ_THRESHOLD);
		break;
	case FT_ACQ_TYPE_DMA:

		timeout = ft_dma_irq_coalescing_timeout_get(ft, chan);
		break;
	default:
		dev_err(&ft->pdev->dev, "%s: unknown acquisition mode %d\n",
			__func__, ft->mode);
	}

	return timeout;
}

/**
 * It sets the coalescing size according to the acquisition mode
 * @ft FmcTdc instance
 * @chan channe [0, 4] (used only for DMA acquisition mode)
 * @size number of samples to trigger IRQ
 */
void ft_irq_coalescing_size_set(struct fmctdc_dev *ft,
				unsigned int chan,
				uint32_t size)
{
	switch (ft->mode) {
	case FT_ACQ_TYPE_FIFO:
		if (unlikely(chan != -1)) {
			dev_warn(&ft->pdev->dev,
				 "FIFO acquisition mode has a gobal coalesing size. Ignore channel %d, apply globally\n",
				 chan);
		}
		ft_writel(ft, size, TDC_REG_IRQ_THRESHOLD);
		break;
	case FT_ACQ_TYPE_DMA:
		/* There is none */
		break;
	}
}


static int ft_init_channel(struct fmctdc_dev *ft, int channel)
{
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

static int ft_channels_init(struct fmctdc_dev *ft)
{
	int i;

	for (i = FT_CH_1; i <= FT_NUM_CHANNELS; i++) {
		int ret = ft_init_channel(ft, i);
		if (ret < 0)
			return ret;
		/* termination is off by default */
		ft_enable_termination(ft, i, 0);
	}
	return 0;
}

static void ft_channels_exit(struct fmctdc_dev *ft)
{

}

struct ft_modlist {
	char *name;

	int (*init)(struct fmctdc_dev *ft);
	void (*exit)(struct fmctdc_dev *ft);
};

static struct ft_modlist init_subsystems[] = {
	{"acam-tdc", ft_acam_init, ft_acam_exit},
	{"time", ft_time_init, ft_time_exit},
	{"channels", ft_channels_init, ft_channels_exit},
	{"zio", ft_zio_init, ft_zio_exit}
};

/**
 * It configures the test data
 * @chan channel number [0, 4]
 * @period period in 125Mhz ticks (125000000 -1 = 1Hz)
 * @enable enable or disable
 */
void ft_test_data(struct fmctdc_dev *ft,
		  unsigned int chan,
		  unsigned int period,
		  bool enable)
{
	uint32_t tmp = 0;

	ft_writel(ft, 0, TDC_REG_FAKE_TS_CSR);

	if (!enable)
		return;

	if (chan >= ft->zdev->n_cset) {
		dev_err(&ft->pdev->dev, "%s Invalid channel %d\n",
			__func__, chan);
		return;
	}

	if (period == 0) {
		dev_err(&ft->pdev->dev, "%s Invalid period %d\n",
			__func__, period);
		return;
	}

	tmp |= TDC_FAKE_TS_EN;
	tmp |= ((chan << TDC_FAKE_TS_CHAN_SHIFT) & TDC_FAKE_TS_CHAN_MASK);
	tmp |= ((period << TDC_FAKE_TS_PERIOD_SHIFT) & TDC_FAKE_TS_PERIOD_MASK);
	ft_writel(ft, tmp, TDC_REG_FAKE_TS_CSR);

	dev_warn(&ft->pdev->dev,
		 "Channel 0 is running in test mode 0x%x\n",
		 tmp);
}

static int ft_resource_validation(struct platform_device *pdev)
{
	struct resource *r;

	r = platform_get_resource(pdev, IORESOURCE_IRQ, TDC_IRQ);
	if (!r) {
		dev_err(&pdev->dev,
			"The TDC needs an interrupt number\n");
		return -ENXIO;
	}

	r = platform_get_resource(pdev, IORESOURCE_MEM, TDC_MEM_BASE);
	if (!r) {
		dev_err(&pdev->dev,
			"The TDC needs base address\n");
		return -ENXIO;
	}

	return 0;
}

#define FT_FMC_NAME "FmcTdc1ns5cha"

static bool ft_fmc_slot_is_valid(struct fmctdc_dev *ft)
{
	int ret;
	void *fru = NULL;
	char *fmc_name = NULL;

	if (!fmc_slot_fru_valid(ft->slot)) {
		dev_err(&ft->pdev->dev,
			"Can't identify FMC card: invalid FRU\n");
		return -EINVAL;
	}

	fru = kmalloc(FRU_SIZE_MAX, GFP_KERNEL);
	if (!fru)
		return -ENOMEM;

	ret = fmc_slot_eeprom_read(ft->slot, fru, 0x0, FRU_SIZE_MAX);
	if (ret != FRU_SIZE_MAX) {
		dev_err(&ft->pdev->dev, "Failed to read FRU header\n");
		goto err;
	}

	fmc_name = fru_get_product_name(fru);
	ret = strcmp(fmc_name, FT_FMC_NAME);
	if (ret) {
		dev_err(&ft->pdev->dev,
			"Invalid FMC card: expectd '%s', found '%s'\n",
			FT_FMC_NAME, fmc_name);
		goto err;
	}

	kfree(fmc_name);
	kfree(fru);

	return true;
err:
	kfree(fmc_name);
	kfree(fru);
	return false;
}

static int ft_endianess(struct fmctdc_dev *ft)
{
	const struct fmc_tdc_platform_data *fmc_tdc_pdata;

	fmc_tdc_pdata = ft->pdev->dev.platform_data;

	return !!(fmc_tdc_pdata->flags & FMC_TDC_BIG_ENDIAN);
}
static int ft_memops_detect(struct fmctdc_dev *ft)
{
	int ret;

	ret = ft_endianess(ft);
	if (ret < 0) {
		dev_err(&ft->pdev->dev, "Failed to detect endianess\n");
		return -EINVAL;
	}

	if (ret) {
		ft->memops.read = ioread32be;
		ft->memops.write = iowrite32be;
	} else {
		ft->memops.read = ioread32;
		ft->memops.write = iowrite32;
	}

	return 0;
}

/**
 * probe and remove are called by the FMC bus core
 */
int ft_probe(struct platform_device *pdev)
{
	struct ft_modlist *m;
	struct fmctdc_dev *ft;
	struct device *dev = &pdev->dev;
	struct resource *r;
	int i, ret, err;
	uint32_t stat;
	uint32_t slot_nr;

	err = ft_resource_validation(pdev);
	if (err)
		return err;

	ft = kzalloc(sizeof(struct fmctdc_dev), GFP_KERNEL);
	if (!ft)
		return -ENOMEM;

	platform_set_drvdata(pdev, ft);
	ft->pdev = pdev;
	r = platform_get_resource(pdev, IORESOURCE_MEM, TDC_MEM_BASE);
	ft->ft_base = ioremap(r->start, resource_size(r));
	ft->ft_core_base = ft->ft_base + TDC_MEZZ_CORE_OFFSET;
	ft->ft_irq_base = ft->ft_base + TDC_MEZZ_EIC_OFFSET;
	ft->ft_owregs_base = ft->ft_base + TDC_MEZZ_ONEWIRE_OFFSET;
	ft->ft_fifo_base = ft->ft_base + TDC_MEZZ_MEM_OFFSET;
	ft->ft_dma_base = ft->ft_base + TDC_MEZZ_MEM_DMA_OFFSET;
	ft->ft_dma_eic_base = ft->ft_base + TDC_MEZZ_MEM_DMA_EIC_OFFSET;
	spin_lock_init(&ft->lock);
	ret = ft_memops_detect(ft);
	if (ret)
		goto err_memops;

	/*
	 * Even if the HDL supports both acquisition mechanism at the same
	 * time, here for the time being we don't.
	 */
	stat = ft_ioread(ft, ft->ft_core_base + TDC_REG_STAT);
	if (stat & TDC_STAT_DMA) {
		ft->mode = FT_ACQ_TYPE_DMA;
	} else if (stat & TDC_STAT_FIFO) {
		ft->mode = FT_ACQ_TYPE_FIFO;
	} else {
		dev_err(dev,
			"Unsupported acquisition type, tdc_reg_stat 0x%x\n",
			stat);
		ret = -ENODEV;
		goto err_mode_selection;
	}

	slot_nr = stat & TDC_STAT_FMC_SLOT ? 2 : 1;
	ft->slot = fmc_slot_get(pdev->dev.parent->parent, slot_nr);
	if (IS_ERR(ft->slot)) {
		dev_err(&ft->pdev->dev,
			"Can't find FMC slot %d err: %ld\n",
			slot_nr, PTR_ERR(ft->slot));
		goto out_fmc;
	}

	if (!fmc_slot_present(ft->slot)) {
		dev_err(&ft->pdev->dev,
			"Can't identify FMC card: missing card\n");
		goto out_fmc_pre;
	}

	if (strcmp(fmc_slot_eeprom_type_get(ft->slot), FT_EEPROM_TYPE)) {
		dev_warn(&ft->pdev->dev,
			 "use non standard EERPOM type \"%s\"\n",
			 FT_EEPROM_TYPE);
		ret = fmc_slot_eeprom_type_set(ft->slot, FT_EEPROM_TYPE);
		if (ret < 0) {
			dev_err(&ft->pdev->dev,
				"Failed to change EEPROM type to \"%s\"",
				FT_EEPROM_TYPE);
			goto out_fmc_eeprom;
		}
	}

	if(!ft_fmc_slot_is_valid(ft))
		goto out_fmc_err;

	err = sysfs_create_link(&ft->pdev->dev.kobj, &ft->slot->dev.kobj,
				dev_name(&ft->slot->dev));
	if (err) {
		dev_err(&ft->pdev->dev, "Failed to create FMC symlink to %s\n",
			dev_name(&ft->slot->dev));
		goto err_fmc_link;
	}

        ret = ft_calib_init(ft);
	if (ret < 0)
		goto err_calib;

	/* init all subsystems */
	for (i = 0, m = init_subsystems; i < ARRAY_SIZE(init_subsystems);
	     i++, m++) {
		ret = m->init(ft);
		if (ret < 0)
			goto err;
	}

	ft_test_data(ft, 0, test_data_period, !!test_data_period);

	switch (ft->mode) {
	case FT_ACQ_TYPE_DMA:
		ret = ft_buf_init(ft);
		break;
	case FT_ACQ_TYPE_FIFO:
		ret = ft_fifo_init(ft);
		break;
	}
	if (ret < 0)
		goto err;

	ft_debug_init(ft);
	ft_writel(ft, TDC_INPUT_ENABLE_FLAG, TDC_REG_INPUT_ENABLE);
	ft_writel(ft, TDC_CTRL_EN_ACQ, TDC_REG_CTRL);

	platform_set_drvdata(pdev, ft);
	return 0;

err:
	while (--m, --i >= 0)
		if (m->exit)
			m->exit(ft);
	ft_calib_exit(ft);
err_calib:
	sysfs_remove_link(&ft->pdev->dev.kobj, dev_name(&ft->slot->dev));
err_fmc_link:
out_fmc_err:
out_fmc_eeprom:
out_fmc_pre:
	fmc_slot_put(ft->slot);
out_fmc:
err_mode_selection:
err_memops:
	iounmap(ft->ft_base);
	kfree(ft);
	platform_set_drvdata(pdev, NULL);
	return ret;
}

int ft_remove(struct platform_device *pdev)
{
	struct fmctdc_dev *ft = platform_get_drvdata(pdev);
	int i;

	if (!ft)
		return 0;	/* No init, no exit */

	ft_writel(ft, TDC_CTRL_DIS_ACQ, TDC_REG_CTRL);
	ft_writel(ft, 0, TDC_REG_INPUT_ENABLE);

	ft_debug_exit(ft);

	switch (ft->mode) {
	case FT_ACQ_TYPE_DMA:
		ft_buf_exit(ft);
		break;
	case FT_ACQ_TYPE_FIFO:
		ft_fifo_exit(ft);
		break;
	}

	i = ARRAY_SIZE(init_subsystems);
	while (--i >= 0) {
		struct ft_modlist *m = init_subsystems + i;
		if (m->exit)
			m->exit(ft);
	}
	ft_calib_exit(ft);
	sysfs_remove_link(&ft->pdev->dev.kobj, dev_name(&ft->slot->dev));
	fmc_slot_put(ft->slot);
	iounmap(ft->ft_base);
	kfree(ft);

	return 0;
}


static const struct platform_device_id ft_id[] = {
	{
		.name = "fmc-tdc",
		.driver_data = TDC_VER,
	},
};

static struct platform_driver ft_platform_driver = {
	.driver = {
		.name = KBUILD_MODNAME,
	},
	.probe = ft_probe,
	.remove = ft_remove,
	.id_table = ft_id,
};

static int ft_init(void)
{
	int ret;

	ret = zio_register_trig(&ft_trig_type, FT_ZIO_TRIG_TYPE_NAME);
	if (ret) {
		pr_err("fmc-tdc: cannot register ZIO trigger type \"%s\" (error %i)\n",
		       FT_ZIO_TRIG_TYPE_NAME, ret);
		goto err_zio_trg;
	}

	ret = ft_zio_register();
	if (ret < 0)
		goto err_zio;

	ret = platform_driver_register(&ft_platform_driver);
	if (ret < 0)
		goto err_plat;
	return 0;

err_plat:
	ft_zio_unregister();
err_zio:
	zio_unregister_trig(&ft_trig_type);
err_zio_trg:
	return ret;
}

static void ft_exit(void)
{
	platform_driver_unregister(&ft_platform_driver);
	ft_zio_unregister();
	zio_unregister_trig(&ft_trig_type);
}

module_init(ft_init);
module_exit(ft_exit);

MODULE_VERSION(VERSION);
MODULE_LICENSE("GPL and additional rights");	/* LGPL */

MODULE_SOFTDEP("pre: zio fmc zio-buf-vmalloc");

ADDITIONAL_VERSIONS;
