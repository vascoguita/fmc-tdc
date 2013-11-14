/*
 * SPEC-specific workarounds for the fmc-tdc driver.
 *
 * Copyright (C) 2012-2013 CERN (http://www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation.
 */

#include <linux/kernel.h>
#include <linux/delay.h>
#include <linux/fmc.h>

#include "fmc-tdc.h"
#include "spec.h"

#include "hw/tdc_regs.h"

struct ft_spec_data {
	void *buffer;
	dma_addr_t dma_addr;
	size_t buffer_size;
};

static inline uint32_t dma_readl(struct fmctdc_dev *ft, unsigned long reg)
{
	return fmc_readl(ft->fmc, ft->ft_dma_base + reg);
}

static inline void dma_writel(struct fmctdc_dev *ft, uint32_t v,
			      unsigned long reg)
{
	fmc_writel(ft->fmc, v, ft->ft_dma_base + reg);
}

static int ft_spec_init(struct fmctdc_dev *ft)
{
	ft->carrier_data = kzalloc(sizeof(struct ft_spec_data), GFP_KERNEL);

	if (!ft->carrier_data)
		return -ENOMEM;
	return 0;
}

static int ft_spec_reset(struct fmctdc_dev *ft)
{
	struct spec_dev *spec = (struct spec_dev *)ft->fmc->carrier_data;

	dev_info(&ft->fmc->dev, "%s: resetting TDC core through Gennum.\n",
		 __func__);

	/* set local bus clock to 160 MHz. The FPGA can't handle more. */
	gennum_writel(spec, 0xE001F04C, 0x808);

	/* fixme: there is no possibility of doing a software reset of the TDC core on the SPEC
	   other than through a Gennum config register. This begs for a fix in the
	   gateware! */

	gennum_writel(spec, 0x00021040, GNPCI_SYS_CFG_SYSTEM);
	mdelay(10);
	gennum_writel(spec, 0x00025000, GNPCI_SYS_CFG_SYSTEM);

	msleep(3000);		/* it takes a while for the PLL to bootstrap.... or not! 
				   We have no possibility to check, as the PLL status register is driven
				   by the clock from this PLL :( */

	return 0;
}

static int ft_spec_copy_timestamps(struct fmctdc_dev *ft, int base_addr,
				   int size, void *dst)
{
	struct ft_spec_data *cspec = ft->carrier_data;
	uint32_t status;
	int i, ret = 0;

	cspec->dma_addr =
	    dma_map_single(ft->fmc->hwdev, (char *)dst, size, DMA_FROM_DEVICE);

#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,29)
	if (dma_mapping_error(cspec->dma_addr)) {
#else
	if (dma_mapping_error(ft->fmc->hwdev, cspec->dma_addr)) {
#endif
		dev_err(&ft->fmc->dev, "dma_map_single failed\n");
		return -ENOMEM;
	}

	dma_writel(ft, 0, TDC_REG_DMA_CTRL);
	dma_writel(ft, base_addr, TDC_REG_DMA_C_START);

	dma_writel(ft, cspec->dma_addr & 0xffffffff, TDC_REG_DMA_H_START_L);
	dma_writel(ft, ((uint64_t) cspec->dma_addr >> 32) & 0x00ffffffff,
		   TDC_REG_DMA_H_START_H);

	dma_writel(ft, 0, TDC_REG_DMA_NEXT_L);
	dma_writel(ft, 0, TDC_REG_DMA_NEXT_H);

	/* Write the DMA length */
	dma_writel(ft, size, TDC_REG_DMA_LEN);

	/* No chained xfers, PCIe to host */
	dma_writel(ft, 0, TDC_REG_DMA_ATTRIB);

	/* Start the transfer */
	dma_writel(ft, 1, TDC_REG_DMA_CTRL);
	udelay(1);
	dma_writel(ft, 0, TDC_REG_DMA_CTRL);

	/* Don't bother about end-of-DMA IRQ, it only makes the driver unnecessarily complicated. */
	for (i = 0; i < 1000; i++) {
		status = dma_readl(ft, TDC_REG_DMA_STAT) & TDC_DMA_STAT_MASK;

		if (status == TDC_DMA_STAT_DONE) {
			ret = 0;
			break;
		} else if (status == TDC_DMA_STAT_ERROR) {
			ret = -EIO;
			break;
		}

		udelay(1);
	}

	if (i == 1000) {
		dev_err(&ft->fmc->dev,
			"%s: DMA transfer taking way too long. Something's really weird.\n",
			__func__);
		ret = -EIO;
	}

	dma_sync_single_for_cpu(ft->fmc->hwdev, cspec->dma_addr, size,
				DMA_FROM_DEVICE);
	dma_unmap_single(ft->fmc->hwdev, cspec->dma_addr, size,
			 DMA_FROM_DEVICE);
	return ret;
}

/* Unfortunately, on the spec this is GPIO9, i.e. IRQ(1) */
static struct fmc_gpio ft_gpio_on[] = {
	{
	 .gpio = FMC_GPIO_IRQ(1),
	 .mode = GPIOF_DIR_IN,
	 .irqmode = IRQF_TRIGGER_RISING,
	 }
};

static struct fmc_gpio ft_gpio_off[] = {
	{
	 .gpio = FMC_GPIO_IRQ(1),
	 .mode = GPIOF_DIR_IN,
	 .irqmode = 0,
	 }
};

static int ft_spec_setup_irqs(struct fmctdc_dev *ft, irq_handler_t handler)
{
	struct fmc_device *fmc = ft->fmc;
	int ret;

	ret = fmc->op->irq_request(fmc, handler, "fmc-tdc", IRQF_SHARED);

	if (ret < 0) {
		dev_err(&fmc->dev, "Request interrupt failed: %d\n", ret);
		return ret;
	}
	fmc->op->gpio_config(fmc, ft_gpio_on, ARRAY_SIZE(ft_gpio_on));

	return 0;
}

static int ft_spec_disable_irqs(struct fmctdc_dev *ft)
{
	struct fmc_device *fmc = ft->fmc;

	fmc->op->gpio_config(fmc, ft_gpio_off, ARRAY_SIZE(ft_gpio_off));
	fmc->op->irq_free(fmc);

	return 0;
}

static int ft_spec_ack_irq(struct fmctdc_dev *ft, int irq_id)
{
	return 0;
}

static void ft_spec_exit(struct fmctdc_dev *ft)
{
	kfree(ft->carrier_data);
}

struct ft_carrier_specific ft_carrier_spec = {
	FT_GATEWARE_SPEC,
	ft_spec_init,
	ft_spec_reset,
	ft_spec_copy_timestamps,
	ft_spec_setup_irqs,
	ft_spec_disable_irqs,
	ft_spec_ack_irq,
	ft_spec_exit,
};
