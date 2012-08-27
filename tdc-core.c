/*
 * core tdc driver 
 *
 * Copyright (C) 2012 CERN (http://www.cern.ch)
 * Author: Samuel Iglesias Gonsalvez <siglesias@igalia.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation.
 */

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt 

#include <linux/kernel.h>
#include <linux/module.h>

#include <linux/zio.h>
#include <linux/zio-buffer.h>
#include <linux/zio-trigger.h>

#include "spec.h"
#include "tdc.h"
#include "hw/tdc_regs.h"


/* The sample size. Mandatory, device-wide */
DEFINE_ZATTR_STD(ZDEV, tdc_zattr_dev_std) = {
	ZATTR_REG(zdev, ZATTR_NBITS, S_IRUGO, 0, 32), /* FIXME: 32 bits. Really? */
};

static struct zio_cset tdc_cset[] = {
	{
		SET_OBJECT_NAME("tdc-test"), /* TODO: change name and complete */
		.raw_io =	NULL,
		.n_chan =	1,
		.ssize =	4, /* FIXME: 0? */
		.flags =	ZIO_DIR_INPUT | ZCSET_TYPE_TIME,
		.zattr_set = {
			.ext_zattr = NULL,
			.n_ext_attr = 0,
		},
	},
};

static const struct zio_sysfs_operations tdc_zio_s_op = {
	.conf_set = NULL,	/* TODO: */
	.info_get = NULL,	/* TODO: */
};

static struct zio_device tdc_tmpl = {
	.owner = THIS_MODULE,
	.preferred_trigger = "user", /* FIXME: put other trigger */
	.s_op = &tdc_zio_s_op,
	.cset = tdc_cset,
	.n_cset = ARRAY_SIZE(tdc_cset),
	.zattr_set = {
		.std_zattr = tdc_zattr_dev_std,
		.ext_zattr = NULL,	/* TODO: */
	},
};

static const struct zio_device_id tdc_table[] = {
	{"tdc", &tdc_tmpl},
	{},
};

static int tdc_zio_probe(struct zio_device *zdev)
{
	/* TODO */
	pr_err("%s: register new device\n", __func__);
	return 0;

}

static struct zio_driver tdc_zdrv = {
	.driver = {
		.name = "tdc",
		.owner = THIS_MODULE,
	},
	.id_table = tdc_table,
	.probe = tdc_zio_probe,	/* TODO: */
};

static int tdc_is_valid(int bus, int devfn)
{
	/* FIXME: restrict to some of the spec devices with moduleparam */
	/* TODO: */
	return 1;
}

void tdc_zio_exit(struct spec_tdc *tdc)
{
	zio_unregister_device(tdc->hwzdev);
	zio_free_device(tdc->hwzdev);
}

int tdc_probe(struct spec_dev *dev)
{
	int err = 0;
	struct pci_dev *pdev;
	struct spec_tdc *tdc;
	int dev_id;

	/* FIXME: create a new function to do this... */
	int freq = 160;
	int divot;
	int data;

	tdc = kzalloc(sizeof(struct spec_tdc), GFP_KERNEL);
	if (!tdc) {
		pr_err("%s: can't allocate device\n", __func__);
		return -ENOMEM;
	}

	dev->sub_priv = tdc;
	tdc->spec = dev;
	tdc->base = dev->remap[0];
	tdc->regs = tdc->base; 	/* FIXME: */
	tdc->ow_regs = tdc->base; /* FIXME:  */
	
	/* FIXME:  */

	/* Setup local clock */

	divot = 800/freq - 1;
        data = 0xe001f00c + (divot << 4);
	writel(data, dev->remap[2] + 0x808);

	msleep(100);
	/* Reset */
	writel(readl(dev->remap[2] + 0x800) & ~(1<<14 || 1 << 15), dev->remap[2] + 0x800);
	msleep(100);

	tdc->hwzdev = zio_allocate_device();
	if (IS_ERR(tdc->hwzdev))
		return PTR_ERR(tdc->hwzdev);

	/* Mandatory fields */
	tdc->hwzdev->owner = THIS_MODULE;
	tdc->hwzdev->private_data = tdc;

	/* Our dev_id is bus+devfn */
	pdev = tdc->spec->pdev;
	dev_id = (pdev->bus->number << 8) | pdev->devfn;

	err = zio_register_device(tdc->hwzdev, "tdc", dev_id);
	if (err) {
		zio_free_device(tdc->hwzdev);
		return err;
	}

	/* TODO: */
	return 0;
}

void tdc_remove(struct spec_dev *dev)
{
	struct spec_tdc *tdc = dev->sub_priv;

	tdc_zio_exit(tdc);

	/* TODO: */
}

int tdc_spec_init(void)
{
	struct spec_dev *dev;
	int ret, success = 0, retsave = 0, err = 0;

	/* Scan the list and see what is there. Take hold of everything */
	list_for_each_entry(dev, &spec_list, list) {
		if (!tdc_is_valid(dev->pdev->bus->number, dev->pdev->devfn))
			continue;
		pr_debug("%s: init %04x:%04x (%pR - %p)\n", __func__,
		       dev->pdev->bus->number, dev->pdev->devfn,
		       dev->area[0], dev->remap[0]);
		ret = tdc_probe(dev);
		if (ret < 0) {
			retsave = ret;
			err++;
		} else {
			success++;
		}
	}
	if (err) {
		pr_err("%s: Setup of %i boards failed (%i succeeded)\n",
		       KBUILD_MODNAME, err, success);
		pr_err("%s: last error: %i\n", KBUILD_MODNAME, retsave);
	}
	if (success) {
		/* At least one board has been successfully initialized */
		return 0;
	}
	return retsave; /* last error code */
}

void tdc_spec_exit(void)
{
	struct spec_dev *dev;

	list_for_each_entry(dev, &spec_list, list) {
		if (!tdc_is_valid(dev->pdev->bus->number, dev->pdev->devfn))
			continue;
		pr_debug("%s: release %04x:%04x (%pR - %p)\n", __func__,
		       dev->pdev->bus->number, dev->pdev->devfn,
		       dev->area[0], dev->remap[0]);
		tdc_remove(dev);
	}
}

static int tdc_init(void)
{
	int err;

	err = zio_register_driver(&tdc_zdrv);
	if (err < 0)
		return err;

	err = tdc_spec_init();
	if (err < 0) {
		zio_unregister_driver(&tdc_zdrv);
		return err;
	}
	
	return 0;
}

static void tdc_exit(void)
{
	tdc_spec_exit();
	zio_unregister_driver(&tdc_zdrv);
}

module_init(tdc_init);
module_exit(tdc_exit);

MODULE_LICENSE("GPL"); 		/* FIXME? Fine delay driver has LGPL (GPL and additional rights) */
