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
#include <linux/delay.h>

#include <linux/zio.h>
#include <linux/zio-buffer.h>
#include <linux/zio-trigger.h>

#include "spec.h"
#include "tdc.h"
#include "hw/tdc_regs.h"

#define _RW_ (S_IRUGO | S_IWUGO) /* I want 80-col lines so this lazy thing */

static int tdc_zio_raw_io(struct zio_cset *cset);

/* The sample size. Mandatory, device-wide */
DEFINE_ZATTR_STD(ZDEV, tdc_zattr_dev_std) = {
	ZATTR_REG(zdev, ZATTR_NBITS, S_IRUGO, 0, 32), /* FIXME: 32 bits. Really? */
};

static struct zio_attribute tdc_zattr_dev[] = {
	ZATTR_EXT_REG("version", S_IRUGO, TDC_ATTR_DEV_VERSION, TDC_VERSION),
	ZATTR_EXT_REG("tstamp_thresh", _RW_, TDC_ATTR_DEV_TSTAMP_THRESH, 100),
	ZATTR_EXT_REG("time_thresh", _RW_, TDC_ATTR_DEV_TIME_THRESH, 100),
	ZATTR_EXT_REG("current_utc_time", S_IRUGO, TDC_ATTR_DEV_CURRENT_UTC, 0),
	ZATTR_EXT_REG("set_utc_time", S_IWUGO, TDC_ATTR_DEV_SET_UTC, 0),
	ZATTR_EXT_REG("channel_term", _RW_, TDC_ATTR_DEV_INPUT_ENABLED, 0x1F),
	ZATTR_EXT_REG("dac_word", _RW_, TDC_ATTR_DEV_DAC_WORD, 0),
	ZATTR_EXT_REG("activate_acquisition", _RW_,
		      TDC_ATTR_DEV_ACTIVATE_ACQUISITION, 0),
	ZATTR_EXT_REG("get_wr_pointer", _RW_,
		      TDC_ATTR_DEV_GET_POINTER, 0),
	ZATTR_EXT_REG("lun", S_IRUGO, TDC_ATTR_DEV_LUN, 1),
	ZATTR_EXT_REG("clear_dacapo_flag", _RW_,
		      TDC_ATTR_DEV_CLEAR_DACAPO_FLAG, 0),
	ZATTR_EXT_REG("reset_acam", _RW_,
		      TDC_ATTR_DEV_RESET_ACAM, 0),
};

static struct zio_cset tdc_cset[] = {
	{
		SET_OBJECT_NAME("tdc-cset0"),
		.raw_io =	tdc_zio_raw_io,
		.n_chan =	1,
		.ssize =	4, /* FIXME: 0? */
		.flags =	ZIO_DIR_INPUT | ZCSET_TYPE_TIME,
		.zattr_set = {
			.ext_zattr = NULL,
			.n_ext_attr = 0,
		},
	},
	{
		SET_OBJECT_NAME("tdc-cset1"),
		.raw_io =	tdc_zio_raw_io,
		.n_chan =	1,
		.ssize =	4, /* FIXME: 0? */
		.flags =	ZIO_DIR_INPUT | ZCSET_TYPE_TIME,
		.zattr_set = {
			.ext_zattr = NULL,
			.n_ext_attr = 0,
		},
	},
	{
		SET_OBJECT_NAME("tdc-cset2"),
		.raw_io =	tdc_zio_raw_io,
		.n_chan =	1,
		.ssize =	4, /* FIXME: 0? */
		.flags =	ZIO_DIR_INPUT | ZCSET_TYPE_TIME,
		.zattr_set = {
			.ext_zattr = NULL,
			.n_ext_attr = 0,
		},
	},
	{
		SET_OBJECT_NAME("tdc-cset3"),
		.raw_io =	tdc_zio_raw_io,
		.n_chan =	1,
		.ssize =	4, /* FIXME: 0? */
		.flags =	ZIO_DIR_INPUT | ZCSET_TYPE_TIME,
		.zattr_set = {
			.ext_zattr = NULL,
			.n_ext_attr = 0,
		},
	},
	{
		SET_OBJECT_NAME("tdc-cset4"),
		.raw_io =	tdc_zio_raw_io,
		.n_chan =	1,
		.ssize =	4, /* FIXME: 0? */
		.flags =	ZIO_DIR_INPUT | ZCSET_TYPE_TIME,
		.zattr_set = {
			.ext_zattr = NULL,
			.n_ext_attr = 0,
		},
	},
};

static int tdc_zio_conf_set(struct device *dev,
			    struct zio_attribute *zattr,
			    uint32_t usr_val)
{
	struct zio_device *zdev;
	struct zio_attribute *attr;
	struct spec_tdc *tdc;

	zdev = to_zio_dev(dev);
	attr = zdev->zattr_set.ext_zattr;
	tdc = zdev->priv_d;

	switch (zattr->priv.addr) {
	case TDC_ATTR_DEV_TSTAMP_THRESH:
		tdc_set_irq_tstamp_thresh(tdc, usr_val);
		break;
	case TDC_ATTR_DEV_TIME_THRESH:
		tdc_set_irq_time_thresh(tdc, usr_val);
		break;
	case TDC_ATTR_DEV_CURRENT_UTC:
		break;
	case TDC_ATTR_DEV_SET_UTC:
		if (usr_val == -1)
			tdc_set_local_utc_time(tdc);
		else
			tdc_set_utc_time(tdc, usr_val);
		break;
	case TDC_ATTR_DEV_INPUT_ENABLED:
		tdc_set_input_enable(tdc, usr_val);
		break;
	case TDC_ATTR_DEV_DAC_WORD:
		tdc_set_dac_word(tdc, usr_val);
		break;
	case TDC_ATTR_DEV_ACTIVATE_ACQUISITION:
		if (usr_val) {
			atomic_set(&tdc->busy, 1);
			return tdc_activate_acquisition(tdc);
		} else {
			atomic_set(&tdc->busy, 0);
			tdc_deactivate_acquisition(tdc);
		}
		break;
	case TDC_ATTR_DEV_CLEAR_DACAPO_FLAG:
		tdc_clear_da_capo_flag(tdc);
		break;
	case TDC_ATTR_DEV_RESET_ACAM:
		tdc_acam_set_default_config(tdc);
		tdc_acam_reset(tdc);
		break;
	default:
		return -EINVAL;
	}

	return 0;
}

static int tdc_zio_info_get(struct device *dev,
			    struct zio_attribute *zattr,
			    uint32_t *usr_val)
{
	struct zio_device *zdev;
	struct zio_attribute *attr;
	struct spec_tdc *tdc;

	zdev = to_zio_dev(dev);
	attr = zdev->zattr_set.ext_zattr;
	tdc = zdev->priv_d;

	switch (zattr->priv.addr) {
	case TDC_ATTR_DEV_TSTAMP_THRESH:
		*usr_val = tdc_get_irq_tstamp_thresh(tdc);
		break;
	case TDC_ATTR_DEV_TIME_THRESH:
		*usr_val = tdc_get_irq_time_thresh(tdc);
		break;
	case TDC_ATTR_DEV_CURRENT_UTC:
		*usr_val = tdc_get_current_utc_time(tdc);
		break;
	case TDC_ATTR_DEV_SET_UTC:
		break;
	case TDC_ATTR_DEV_INPUT_ENABLED:
		*usr_val = tdc_get_input_enable(tdc);
		break;
	case TDC_ATTR_DEV_DAC_WORD:
		*usr_val = tdc_get_dac_word(tdc);
		break;
	case TDC_ATTR_DEV_ACTIVATE_ACQUISITION:
		*usr_val = atomic_read(&tdc->busy);
		break;
	case TDC_ATTR_DEV_GET_POINTER:
		*usr_val = tdc_get_circular_buffer_wr_pointer(tdc);
		break;
	case TDC_ATTR_DEV_LUN:
		*usr_val = tdc->lun;
		break;

	default:
		return -EINVAL;
	}

	return 0;
}

static const struct zio_sysfs_operations tdc_zio_s_op = {
	.conf_set = tdc_zio_conf_set,
	.info_get = tdc_zio_info_get,
};

static struct zio_device tdc_tmpl = {
	.owner = THIS_MODULE,
	.preferred_trigger = "tdc",
	.s_op = &tdc_zio_s_op,
	.cset = tdc_cset,
	.n_cset = ARRAY_SIZE(tdc_cset),
	.zattr_set = {
		.std_zattr = tdc_zattr_dev_std,
		.ext_zattr = tdc_zattr_dev,
		.n_ext_attr = ARRAY_SIZE(tdc_zattr_dev),
	},
};

static const struct zio_device_id tdc_table[] = {
	{"tdc", &tdc_tmpl},
	{},
};

static int tdc_zio_raw_io(struct zio_cset *cset)
{
	struct spec_tdc *tdc;
	struct zio_channel *zio_chan;
	struct zio_control *ctrl;
	struct zio_device *zdev = cset->zdev;
	struct zio_ti *ti = cset->ti;
	int chan;

	zio_chan = cset->chan;
	tdc = zdev->priv_d;
	chan = cset->index;

	/* Process the data */
	ctrl = zio_chan->current_ctrl;
	ctrl->ssize = 1;		/* one event */
	ctrl->nbits = 0;		/* no sample data. Only metadata */
	ti->tstamp.tv_sec = tdc->event[chan].data.local_utc;
	ti->tstamp.tv_nsec = tdc->event[chan].data.coarse_time;
	ti->tstamp_extra = tdc->event[chan].data.fine_time;
	ctrl->flags = tdc->event[chan].dacapo_flag; /* XXX: Is it OK here? */
	ctrl->reserved = tdc->event[chan].data.metadata;
	return 0;
}

static int tdc_zio_probe(struct zio_device *zdev)
{
	/* TODO: implement something if needed. If not, delete this function */
	pr_err("%s: register new device\n", __func__);
	return 0;

}

static struct zio_driver tdc_zdrv = {
	.driver = {
		.name = "tdc",
		.owner = THIS_MODULE,
	},
	.id_table = tdc_table,
	.probe = tdc_zio_probe,
};

/* Copied from zio-sys.c. This works because ZIO only supports one children */
static int __tdc_match_child(struct device *dev, void *data)
{
//      if (dev->type == &zobj_device_type)
                return 1;
//      return 0;
}

int tdc_zio_register_device(struct spec_tdc *tdc)
{
	int err = 0;
	struct pci_dev *pdev;
	int dev_id;
	struct device *dev;

	tdc->hwzdev = zio_allocate_device();
	if (IS_ERR(tdc->hwzdev))
		return PTR_ERR(tdc->hwzdev);

	/* Mandatory fields */
	tdc->hwzdev->owner = THIS_MODULE;
	tdc->hwzdev->priv_d = tdc;

	/* Our dev_id is bus+devfn */
	pdev = tdc->spec->pdev;
	dev_id = (pdev->bus->number << 8) | pdev->devfn;

	err = zio_register_device(tdc->hwzdev, "tdc", dev_id);
	if (err) {
		zio_free_device(tdc->hwzdev);
		return err;
	}

	dev = device_find_child(&tdc->hwzdev->head.dev, NULL, __tdc_match_child);
        if (!dev) {
                pr_err("Child device not found!!\n");
		return -ENODEV;
	}
	tdc->zdev = to_zio_dev(dev);

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

