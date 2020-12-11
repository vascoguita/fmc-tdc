// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * Copyright (C) 2019 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 */

#include <linux/module.h>
#include <linux/dma-mapping.h>
#include <linux/platform_device.h>
#include <linux/mfd/core.h>

#include "platform_data/fmc-tdc.h"

enum ft_spec_dev_offsets {
	FT_SPEC_TDC_MEM_START = 0x00001E000,
	FT_SPEC_TDC_MEM_END = 0x000030000,
};

static const struct fmc_tdc_platform_data fmc_tdc_pdata = {
	.flags = 0,
	.wr_calibration_offset_carrier = 0,
};

static int ft_spec_probe(struct platform_device *pdev)
{
	static struct resource ft_spec_fdt_res[] = {
		{
			.name = "fmc-tdc-mem",
			.flags = IORESOURCE_MEM,
		},
		{
			.name = "fmc-tdc-dma",
			.flags = IORESOURCE_DMA,
		}, {
			.name = "fmc-tdc-irq",
			.flags = IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHLEVEL,
		}
	};
	struct platform_device_info pdevinfo = {
		.parent = &pdev->dev,
		.name = "fmc-tdc",
		.id = PLATFORM_DEVID_AUTO,
		.res = ft_spec_fdt_res,
		.num_res = ARRAY_SIZE(ft_spec_fdt_res),
		.data = &fmc_tdc_pdata,
		.size_data = sizeof(fmc_tdc_pdata),
		.dma_mask = DMA_BIT_MASK(32),
	};
	struct platform_device *pdev_child;
	struct resource *rmem;
	struct resource *r;
	int irq;
	int dma_dev_chan;

	rmem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!rmem) {
		dev_err(&pdev->dev, "Missing memory resource\n");
		return -EINVAL;
	}

	irq = platform_get_irq(pdev, 0);
	if (irq < 0) {
		dev_err(&pdev->dev, "Missing IRQ number\n");
		return -EINVAL;
	}

	r = platform_get_resource(pdev, IORESOURCE_DMA, 0);
	if (!r) {
		dev_err(&pdev->dev, "Missing DMA engine\n");
		return -EINVAL;
	}
	dma_dev_chan = r->start;

	ft_spec_fdt_res[0].parent = rmem;
	ft_spec_fdt_res[0].start = rmem->start + FT_SPEC_TDC_MEM_START;
	ft_spec_fdt_res[0].end = rmem->start + FT_SPEC_TDC_MEM_END;
	ft_spec_fdt_res[1].start = dma_dev_chan;
	ft_spec_fdt_res[2].start = irq;

	pdev_child = platform_device_register_full(&pdevinfo);
	if (IS_ERR(pdev_child))
		return PTR_ERR(pdev_child);
	platform_set_drvdata(pdev, pdev_child);
	return 0;
}

static int ft_spec_remove(struct platform_device *pdev)
{
	struct platform_device *pdev_child = platform_get_drvdata(pdev);

	platform_device_unregister(pdev_child);

	return 0;
}

/**
 * List of supported platform
 */
enum ft_spec_version {
	FT_SPEC_VER = 0,
};

static const struct platform_device_id ft_spec_id_table[] = {
	{
		.name = "fmc-tdc-spec",
		.driver_data = FT_SPEC_VER,
	}, {
		.name = "id:000010DC574E0001",
		.driver_data = FT_SPEC_VER,
	}, {
		.name = "id:000010dc574e0001",
		.driver_data = FT_SPEC_VER,
	},
	{},
};

static struct platform_driver ft_spec_driver = {
	.driver = {
		.name = "fmc-tdc-spec",
		.owner = THIS_MODULE,
	},
	.id_table = ft_spec_id_table,
	.probe = ft_spec_probe,
	.remove = ft_spec_remove,
};
module_platform_driver(ft_spec_driver);

MODULE_AUTHOR("Federico Vaga <federico.vaga@cern.ch>");
MODULE_LICENSE("GPL");
MODULE_VERSION(VERSION);
MODULE_DESCRIPTION("Driver for the SPEC TDC 1 ns 5 channels");
MODULE_DEVICE_TABLE(platform, ft_spec_id_table);

MODULE_SOFTDEP("pre: spec_fmc_carrier fmc-tdc");
