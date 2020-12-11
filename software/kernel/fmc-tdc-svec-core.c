// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * Copyright (C) 2020 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 */

#include <linux/module.h>
#include <linux/dma-mapping.h>
#include <linux/platform_device.h>
#include <linux/mfd/core.h>
#include <linux/fmc.h>

#include "platform_data/fmc-tdc.h"

enum ft_svec_dev_offsets {
	FT_SVEC_TDC1_MEM_START = 0x00000E000,
	FT_SVEC_TDC1_MEM_END = 0x0001DFFF,
	FT_SVEC_TDC2_MEM_START = 0x0001E000,
	FT_SVEC_TDC2_MEM_END = 0x000030000,
};

static struct fmc_tdc_platform_data fmc_tdc_pdata = {
	.flags = FMC_TDC_BIG_ENDIAN,
	.wr_calibration_offset_carrier = 3000,
};

/* MFD devices */
enum svec_fpga_mfd_devs_enum {
	FT_SVEC_MFD_FT1 = 0,
	FT_SVEC_MFD_FT2,
};

static struct resource ft_svec_fdt_res1[] = {
	{
		.name = "fmc-tdc-mem.1",
		.flags = IORESOURCE_MEM,
		.start = FT_SVEC_TDC1_MEM_START,
		.end = FT_SVEC_TDC1_MEM_END,
	}, {
		.name = "fmc-tdc-irq.1",
		.flags = IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHLEVEL,
		.start = 0,
		.end = 0,
	},
};
static struct resource ft_svec_fdt_res2[] = {
    {
        .name = "fmc-tdc-mem.2",
        .flags = IORESOURCE_MEM,
        .start = FT_SVEC_TDC2_MEM_START,
        .end = FT_SVEC_TDC2_MEM_END,
    },
    {
        .name = "fmc-tdc-irq.2",
        .flags = IORESOURCE_IRQ | IORESOURCE_IRQ_HIGHLEVEL,
        .start = 1,
        .end = 1,
    },
};


#define MFD_TDC(_n)                                               \
	{                                                         \
		.name = "fmc-tdc",                                \
		.platform_data = &fmc_tdc_pdata,                  \
		.pdata_size = sizeof(fmc_tdc_pdata),              \
		.num_resources = ARRAY_SIZE(ft_svec_fdt_res##_n), \
		.resources = ft_svec_fdt_res##_n,                 \
	}

static const struct mfd_cell ft_svec_mfd_devs1[] = {
	MFD_TDC(1),
};
static const struct mfd_cell ft_svec_mfd_devs2[] = {
	MFD_TDC(2),
};
static const struct mfd_cell ft_svec_mfd_devs3[] = {
	MFD_TDC(1),
	MFD_TDC(2),
};

static const struct mfd_cell *ft_svec_mfd_devs[] = {
	ft_svec_mfd_devs1,
	ft_svec_mfd_devs2,
	ft_svec_mfd_devs3,
};

static int ft_svec_probe(struct platform_device *pdev)
{
	struct resource *rmem;
	int idev = 0;
	int ndev;
	int irq;
	int i;

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

	for (i = 1; i <= 2; ++i) {
		struct fmc_slot *slot = fmc_slot_get(pdev->dev.parent, i);
		int present;

                if (IS_ERR(slot)) {
			dev_err(&pdev->dev,
				"Can't find FMC slot %d err: %ld\n",
				i, PTR_ERR(slot));
			return PTR_ERR(slot);
		}

		present = fmc_slot_present(slot);
		fmc_slot_put(slot);
		dev_dbg(&pdev->dev, "FMC-TDC slot: %d, present: %d\n",
			i, present);
		if (present)
			idev |= BIT(i - 1);
	}

	if (idev == 0)
		return -ENODEV;
	idev--;

	/*
	 * We know that this design uses the HTVIC IRQ controller.
	 * This IRQ controller has a linear mapping, so it is enough
	 * to give the first one as input
	 */
	ndev = 1 + !!(idev & 0x2);
	dev_dbg(&pdev->dev, "Found %d, point to mfd_cell %d\n", ndev, idev);
	return mfd_add_devices(&pdev->dev, PLATFORM_DEVID_AUTO,
			       ft_svec_mfd_devs[idev], ndev,
			       rmem, irq, NULL);
}

static int ft_svec_remove(struct platform_device *pdev)
{
	mfd_remove_devices(&pdev->dev);

	return 0;
}

/**
 * List of supported platform
 */
enum ft_svec_version {
	FT_SVEC_VER = 0,
};

static const struct platform_device_id ft_svec_id_table[] = {
	{
		.name = "fmc-tdc-svec",
		.driver_data = FT_SVEC_VER,
	}, {
		.name = "id:000010DC574E0002",
		.driver_data = FT_SVEC_VER,
	}, {
		.name = "id:000010dc574e0002",
		.driver_data = FT_SVEC_VER,
	},
	{},
};

static struct platform_driver ft_svec_driver = {
	.driver = {
		.name = "fmc-tdc-svec",
		.owner = THIS_MODULE,
	},
	.id_table = ft_svec_id_table,
	.probe = ft_svec_probe,
	.remove = ft_svec_remove,
};
module_platform_driver(ft_svec_driver);

MODULE_AUTHOR("Federico Vaga <federico.vaga@cern.ch>");
MODULE_LICENSE("GPL");
MODULE_VERSION(VERSION);
MODULE_DESCRIPTION("Driver for the SVEC TDC 1 ns 5 channels");
MODULE_DEVICE_TABLE(platform, ft_svec_id_table);

MODULE_SOFTDEP("pre: svec_fmc_carrier fmc-tdc");
