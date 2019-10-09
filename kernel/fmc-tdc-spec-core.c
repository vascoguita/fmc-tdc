// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * Copyright (C) 2019 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 */

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mfd/core.h>

enum ft_spec_dev_offsets {
	FT_SPEC_TDC_MEM_START = 0x00001E000,
	FT_SPEC_TDC_MEM_END = 0x000030000,
};

/* MFD devices */
enum spec_fpga_mft_devs_enum {
	FT_SPEC_MFD_TDC = 0,
};

static struct resource ft_spec_fdt_res[] = {
	{
		.name = "fmc-tdc-mem",
		.flags = IORESOURCE_MEM,
		.start = FT_SPEC_TDC_MEM_START,
		.end = FT_SPEC_TDC_MEM_END,
	}, {
		.name = "fmc-tdc-irq",
		.flags = IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHLEVEL,
		.start = 0,
		.end = 0,
	},
};

static const struct mfd_cell ft_spec_mfd_devs[] = {
	[FT_SPEC_MFD_TDC] = {
		.name = "fmc-tdc-pci",
		.platform_data = NULL,
		.pdata_size = 0,
		.num_resources = ARRAY_SIZE(ft_spec_fdt_res),
		.resources = ft_spec_fdt_res,
	},
};


static int ft_spec_probe(struct platform_device *pdev)
{
	struct resource *rmem;
	int irq;

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

	/*
	 * We know that this design uses the HTVIC IRQ controller.
	 * This IRQ controller has a linear mapping, so it is enough
	 * to give the first one as input
	 */

	return mfd_add_devices(&pdev->dev, PLATFORM_DEVID_AUTO,
			       ft_spec_mfd_devs,
			       ARRAY_SIZE(ft_spec_mfd_devs),
			       rmem, irq, NULL);
}

static int ft_spec_remove(struct platform_device *pdev)
{
	mfd_remove_devices(&pdev->dev);

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
