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

#include <linux/fmc.h>
#include <linux/fmc-sdb.h>

#include <linux/zio.h>
#include <linux/zio-trigger.h>

#include "fmc-tdc.h"
#include "hw/tdc_regs.h"

/* Module parameters */
static int irq_timeout_ms_default = 10;
module_param_named(irq_timeout_ms, irq_timeout_ms_default, int, 0444);
MODULE_PARM_DESC(irq_timeout_ms, "IRQ coalesing timeout (default: 10ms).");


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


/**
 * It configure the double buffers for a given channel
 * @param[in] ft FmcTdc device instance
 * @param[in] channel range [0, N-1]
 */
static void ft_buffer_init(struct fmctdc_dev *ft, int channel)
{
	const int ddr_burst_size = 16;
	const uint32_t base = ft->ft_buffer_base + (0x40 * channel);
	uint32_t val;
	struct ft_channel_state *st;

	st = &ft->channels[channel];

	st->buf_size = TDC_CHANNEL_BUFFER_SIZE_BYTES / TDC_BYTES_PER_TIMESTAMP;
	st->active_buffer = 0;

	ft_iowrite(ft, 0, base + TDC_BUF_REG_CSR);

	/* Buffer 1 */
	st->buf_addr[0] = TDC_CHANNEL_BUFFER_SIZE_BYTES * (2 * channel);
	ft_iowrite(ft, st->buf_addr[0], base + TDC_BUF_REG_CUR_BASE);
	val = (st->buf_size << TDC_BUF_CUR_SIZE_SIZE_SHIFT);
	val |= TDC_BUF_CUR_SIZE_VALID;
	ft_iowrite(ft, val, base + TDC_BUF_REG_CUR_SIZE);

	/* Buffer 2 */
	st->buf_addr[1] = TDC_CHANNEL_BUFFER_SIZE_BYTES * (2 * channel + 1);
	ft_iowrite(ft, st->buf_addr[1], base + TDC_BUF_REG_NEXT_BASE);
	val = (st->buf_size << TDC_BUF_NEXT_SIZE_SIZE_SHIFT);
	val |= TDC_BUF_NEXT_SIZE_VALID;
	ft_iowrite(ft, val, base + TDC_BUF_REG_NEXT_SIZE);

	/* Ready to run */
	val = TDC_BUF_CSR_ENABLE;
	val |= (ddr_burst_size << TDC_BUF_CSR_BURST_SIZE_SHIFT);
	val |= (irq_timeout_ms_default << TDC_BUF_CSR_IRQ_TIMEOUT_SHIFT);
	ft_iowrite(ft, val, base + TDC_BUF_REG_CSR);

	dev_info(&ft->fmc->dev,
		 "Config channel %d: base = 0x%x buf[0] = 0x%08x, buf[1] = 0x%08x, %d timestamps per buffer\n",
		 channel, base, st->buf_addr[0], st->buf_addr[1],
		 st->buf_size);
	dev_info(&ft->fmc->dev, "CSR: %08x\n",
		 ft_ioread(ft, base + TDC_BUF_REG_CSR));
}


/**
 * It clears the double buffers configuration for a given channel
 * @param[in] ft FmcTdc device instance
 * @param[in] channel range [0, N-1]
 */
static void ft_buffer_exit(struct fmctdc_dev *ft, int channel)
{
	const uint32_t base = ft->ft_buffer_base + (0x40 * channel);

	ft_iowrite(ft, 0, base + TDC_BUF_REG_CUR_SIZE);
	ft_iowrite(ft, 0, base + TDC_BUF_REG_NEXT_SIZE);
	ft_iowrite(ft, 0, base + TDC_BUF_REG_CSR);
}

void ft_enable_acquisition(struct fmctdc_dev *ft, int enable)
{
	uint32_t ien;
	int i;


	ien = ft_readl(ft, TDC_REG_INPUT_ENABLE);
	if (enable) {
		for (i = 0; i < FT_NUM_CHANNELS; i++)
			ft_buffer_init(ft, i);
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

		for (i = 0; i < FT_NUM_CHANNELS; i++)
			ft_buffer_exit(ft, i);
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

}

struct ft_modlist {
	char *name;

	int (*init)(struct fmctdc_dev *ft);
	void (*exit)(struct fmctdc_dev *ft);
};

static struct ft_modlist init_subsystems[] = {
	{"acam-tdc", ft_acam_init, ft_acam_exit},
	{"onewire", ft_onewire_init, ft_onewire_exit},
	{"time", ft_time_init, ft_time_exit},
	{"channels", ft_channels_init, ft_channels_exit},
	{"zio", ft_zio_init, ft_zio_exit}
};


static uint32_t dma_readl(struct fmctdc_dev *ft, uint32_t reg)
{
	return ft_ioread(ft, TDC_SPEC_DMA_BASE + reg);
}

static void dma_writel(struct fmctdc_dev *ft, uint32_t data, uint32_t reg)
{
	dev_vdbg(&ft->fmc->dev, "%s %x %x\n",
		 __func__, data, TDC_SPEC_DMA_BASE + reg);
	ft_iowrite(ft, data, TDC_SPEC_DMA_BASE + reg);
}

void gn4124_dma_write(struct fmctdc_dev *ft, uint32_t dst, void *src, int len)
{
	memcpy(ft->dmabuf_virt, src, len);

	dma_writel(ft, dst, GENNUM_DMA_ADDR);
	dma_writel(ft, ft->dmabuf_phys >> 32, GENNUM_DMA_ADDR_H);
	dma_writel(ft, ft->dmabuf_phys & 0xffffffffULL,
		   GENNUM_DMA_ADDR_L);
	dma_writel(ft, len,  GENNUM_DMA_LEN);
	dma_writel(ft, GENNUM_DMA_ATTR_LAST | GENNUM_DMA_ATTR_DIR,
		   GENNUM_DMA_ATTR);
	dma_writel(ft, GENNUM_DMA_CTL_START,  GENNUM_DMA_CTL);

	while (!(dma_readl(ft, GENNUM_DMA_STA) & GENNUM_DMA_STA_DONE))
		;
}

void gn4124_dma_read(struct fmctdc_dev *ft, uint32_t src, void *dst, int len)
{
	dma_writel(ft, src, GENNUM_DMA_ADDR);
	dma_writel(ft, ft->dmabuf_phys >> 32, GENNUM_DMA_ADDR_H);
	dma_writel(ft, ft->dmabuf_phys & 0xffffffffULL,
		   GENNUM_DMA_ADDR_L);
	dma_writel(ft, len,  GENNUM_DMA_LEN);
	dma_writel(ft, GENNUM_DMA_ATTR_LAST,  GENNUM_DMA_ATTR);
	dma_writel(ft, GENNUM_DMA_CTL_START,  GENNUM_DMA_CTL);

	while (!(dma_readl(ft, GENNUM_DMA_STA) & GENNUM_DMA_STA_DONE))
		;

	memcpy(dst, ft->dmabuf_virt, len);
}

#if 1
void test_dma(struct fmctdc_dev *ft)
{
	const int buf_size = 16;
	uint8_t buf1[buf_size], buf2[buf_size];
	int i;

	dev_info(&ft->fmc->dev, "Test DMA\n");
	dev_info(&ft->fmc->dev, "R0 = %08x R4 = %08x\n",
	       dma_readl(ft, 0), dma_readl(ft, 4));

	/* mdelay(5000); */

	for (i = 0; i < buf_size; i++) {
		buf1[i] = i * 31011 + 12312;
		buf2[i] = 0xff;
	}

	gn4124_dma_write(ft, 0, buf1, 16);
	gn4124_dma_read(ft, 0, buf2, 16);

	for (i = 0; i < buf_size; i++)
		dev_info(&ft->fmc->dev, "%02x %02x ", buf1[i], buf2[i]);
	dev_info(&ft->fmc->dev, "\n");
}
#endif

/* probe and remove are called by the FMC bus core */
int ft_probe(struct fmc_device *fmc)
{
	struct ft_modlist *m;
	struct fmctdc_dev *ft;
	struct device *dev = &fmc->dev;
	char *fwname;
	int i, index, ret, ord;

	ft = kzalloc(sizeof(struct fmctdc_dev), GFP_KERNEL);
	if (!ft)
		return -ENOMEM;

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

	ft->dmabuf_virt = __vmalloc(PAGE_SIZE, GFP_KERNEL | __GFP_ZERO,
				    PAGE_KERNEL);
	ft->dmabuf_phys = page_to_pfn(vmalloc_to_page(ft->dmabuf_virt));
	ft->dmabuf_phys *= PAGE_SIZE;

	test_dma(ft);

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

	vfree(ft->dmabuf_virt);

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
