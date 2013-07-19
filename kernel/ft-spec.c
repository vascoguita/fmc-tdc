/*
 * SPEC-specific workarounds for the fmc-tdc driver.
 *
 * Copyright (C) 2012-2013 CERN (http://www.cern.ch)
 * Author: Tomasz Wlostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
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
  uint32_t rv = fmc_readl(ft->fmc, ft->ft_dma_base + reg);
 //printk("dma_readl: addr %x val %x\n", ft->ft_dma_base + reg, rv);
 return rv;

}

static inline void dma_writel(struct fmctdc_dev *ft, uint32_t v, unsigned long reg)
{
  
	//printk("dma_writel: addr %x val %x\n", ft->ft_dma_base + reg, v);
	fmc_writel(ft->fmc, v, ft->ft_dma_base + reg);
}

static int spec_ft_init ( struct fmctdc_dev *ft )
{
	ft->carrier_data = kzalloc(sizeof(struct ft_spec_data), GFP_KERNEL );

	if(!ft->carrier_data)
		return -ENOMEM;
	return 0;
}

static int spec_ft_reset( struct fmctdc_dev *dev )
{
	struct spec_dev *spec = (struct spec_dev *) dev->fmc->carrier_data;

	dev_info(&dev->fmc->dev, "%s: resetting TDC core through Gennum.\n", __func__);

	/* set local bus clock to 160 MHz. The FPGA can't handle more. */	   
	gennum_writel(spec, 0xE001F04C, 0x808);

	/* fixme: there is no possibility of doing a software reset of the TDC core
	   other than through a Gennum config register. This begs for a fix in the
	   gateware! */

	gennum_writel(spec, 0x00021040, GNPCI_SYS_CFG_SYSTEM);
	mdelay(10);
	gennum_writel(spec, 0x00025000, GNPCI_SYS_CFG_SYSTEM);

	msleep(3000); /* it takes a while for the PLL to bootstrap.... or not! 
					 We have no possibility to check :( */

	return 0;
}

static int spec_ft_copy_timestamps (struct fmctdc_dev *dev, int base_addr, int size, void *dst )
{
	struct ft_spec_data *hw = dev->carrier_data;
	uint32_t status;
	int i, ret;
	
	hw->dma_addr = dma_map_single(dev->fmc->hwdev, (char *)dst, size, DMA_FROM_DEVICE);
	
	if (dma_mapping_error(dev->fmc->hwdev, hw->dma_addr)) {
		dev_err(&dev->fmc->dev, "dma_map_single failed\n");
		return -ENOMEM;
	}

	dma_writel(dev, 0, TDC_REG_DMA_CTRL);
	dma_writel(dev, base_addr, TDC_REG_DMA_C_START);
	
	dma_writel(dev, hw->dma_addr & 0xffffffff, TDC_REG_DMA_H_START_L);
	dma_writel(dev, ((uint64_t)hw->dma_addr >> 32) & 0x00ffffffff, TDC_REG_DMA_H_START_H);
	
	dma_writel(dev, 0, TDC_REG_DMA_NEXT_L);
	dma_writel(dev, 0, TDC_REG_DMA_NEXT_H);
	
	/* Write the DMA length */
	dma_writel(dev, size, TDC_REG_DMA_LEN);
	
	/* No chained xfers, PCIe to host */
	dma_writel(dev, 0, TDC_REG_DMA_ATTRIB);

	/* Start the transfer */
	dma_writel(dev, 1, TDC_REG_DMA_CTRL);
	udelay(50);
	dma_writel(dev, 0, TDC_REG_DMA_CTRL);
	
	/* Don't bother about end-of-DMA IRQ, it only makes the driver unnecessarily complicated. */
	for(i = 0; i < 1000; i++)
	{
		status = dma_readl (dev, TDC_REG_DMA_STAT) & TDC_DMA_STAT_MASK;

		if(status == TDC_DMA_STAT_DONE)
		{
			ret = 0;
			break;
		} else if (status == TDC_DMA_STAT_ERROR) {
			ret = -EIO;
			break;
		}

		udelay(1);
	}

	if(i == 1000)
	{
		dev_err(&dev->fmc->dev, "%s: DMA transfer taking way too long. Something's really weird.\n", __func__);
		ret = -EIO;
	}
	
	dma_sync_single_for_cpu(dev->fmc->hwdev, hw->dma_addr, size, DMA_FROM_DEVICE);
	dma_unmap_single(dev->fmc->hwdev, hw->dma_addr, size, DMA_FROM_DEVICE);
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

static int spec_ft_setup_irqs (struct fmctdc_dev *ft, irq_handler_t handler)
{
	struct fmc_device *fmc = ft->fmc;
	int ret;

	ret = fmc->op->irq_request(fmc, handler, "fmc-tdc", IRQF_SHARED);

	if(ret < 0)
	{
		dev_err(&fmc->dev, "Request interrupt failed: %d\n", ret);
		return ret;
	}
	fmc->op->gpio_config(fmc, ft_gpio_on, ARRAY_SIZE(ft_gpio_on));

	return 0;
}

static int spec_ft_disable_irqs (struct fmctdc_dev *ft)
{
	struct fmc_device *fmc = ft->fmc;

	fmc->op->gpio_config(fmc, ft_gpio_off, ARRAY_SIZE(ft_gpio_off));
	fmc->op->irq_free(fmc);

	return 0;
}


static int spec_ft_ack_irq (struct fmctdc_dev *ft)
{
	return 0;
}

struct ft_carrier_specific ft_carrier_spec = {
	FT_GATEWARE_SPEC,
	spec_ft_init,
	spec_ft_reset,
	spec_ft_copy_timestamps,
	spec_ft_setup_irqs,
	spec_ft_disable_irqs,
	spec_ft_ack_irq
};