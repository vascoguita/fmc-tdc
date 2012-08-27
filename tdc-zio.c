/*
 * ZIO support for tdc driver 
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

int tdc_zio_register_device(struct spec_tdc *tdc)
{
	int err = 0;
	struct pci_dev *pdev;
	int dev_id;

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
	return 0;
}

void tdc_zio_remove(struct spec_tdc *tdc)
{
	zio_unregister_device(tdc->hwzdev);
	zio_free_device(tdc->hwzdev);
}

int tdc_zio_init(void)
{
	return zio_register_driver(&tdc_zdrv);
}

void tdc_zio_exit(void)
{
	zio_unregister_driver(&tdc_zdrv);
}

