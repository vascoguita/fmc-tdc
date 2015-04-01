/*
 * ZIO interface for the fmc-tdc driver.
 *
 * Copyright (C) 2012-2013 CERN (www.cern.ch)
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation or, at your
 * option, any later version.
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/init.h>
#include <linux/timer.h>
#include <linux/jiffies.h>
#include <linux/bitops.h>
#include <linux/io.h>

#include <linux/zio.h>
#include <linux/zio-buffer.h>
#include <linux/zio-trigger.h>

#include <linux/fmc.h>

#include "fmc-tdc.h"

#define _RW_ (S_IRUGO | S_IWUGO)    /* I want 80-col lines so this lazy thing */

/* The sample size. Mandatory, device-wide */
ZIO_ATTR_DEFINE_STD(ZIO_DEV, ft_zattr_dev_std) = {
	ZIO_ATTR(zdev, ZIO_ATTR_NBITS, ZIO_RO_PERM, 0, 32),	/* 32 bits. Really? */
	ZIO_SET_ATTR_VERSION(ZIO_HEX_VERSION(FT_VERSION_MAJ, FT_VERSION_MIN, 0)),
};

/* Extended attributes for the device */
static struct zio_attribute ft_zattr_dev[] = {
	ZIO_ATTR_EXT("seconds", ZIO_RW_PERM, FT_ATTR_DEV_SECONDS, 0),
	ZIO_ATTR_EXT("coarse", ZIO_RW_PERM, FT_ATTR_DEV_COARSE, 0),
	ZIO_ATTR_EXT("command", ZIO_WO_PERM, FT_ATTR_DEV_COMMAND, 0),
	ZIO_ATTR_EXT("enable_inputs", ZIO_RW_PERM, FT_ATTR_DEV_ENABLE_INPUTS, 0),
	ZIO_ATTR_EXT("sequence", ZIO_RW_PERM, FT_ATTR_DEV_SEQUENCE, 0),
	ZIO_ATTR_EXT("wr-offset", ZIO_RO_PERM, FT_ATTR_TDC_WR_OFFSET, 0),
	ZIO_PARAM_EXT("temperature", ZIO_RO_PERM, FT_ATTR_PARAM_TEMP, 0),
};

/* Extended attributes for the TDC (== input) cset */
static struct zio_attribute ft_zattr_input[] = {
	ZIO_ATTR_EXT("termination", ZIO_RW_PERM, FT_ATTR_TDC_TERMINATION, 0),
	ZIO_ATTR_EXT("zero-offset", ZIO_RO_PERM, FT_ATTR_TDC_ZERO_OFFSET, 0),
	ZIO_ATTR_EXT("user-offset", ZIO_RW_PERM, FT_ATTR_TDC_USER_OFFSET, 0),
	ZIO_ATTR_EXT("diff-reference", ZIO_RW_PERM, FT_ATTR_TDC_DELAY_REF, 0),
	ZIO_ATTR_EXT("diff-reference-seq", ZIO_RO_PERM, FT_ATTR_TDC_DELAY_REF_SEQ, 0),
	ZIO_PARAM_EXT("last_seconds", ZIO_RO_PERM, FT_ATTR_TDC_SECONDS, 0),
	ZIO_PARAM_EXT("last_coarse", ZIO_RO_PERM, FT_ATTR_TDC_COARSE, 0),
	ZIO_PARAM_EXT("last_frac", ZIO_RO_PERM, FT_ATTR_TDC_FRAC, 0),
};

/* This identifies if our "struct device" is device, input, output */
enum ft_devtype {
	FT_TYPE_WHOLEDEV,
	FT_TYPE_INPUT
};

static enum ft_devtype __ft_get_type(struct device *dev)
{
	struct zio_obj_head *head = to_zio_head(dev);

	if (head->zobj_type == ZIO_DEV)
		return FT_TYPE_WHOLEDEV;
	return FT_TYPE_INPUT;
}

void ft_zio_kill_buffer(struct fmctdc_dev *ft, int channel)
{
	if (ft->zdev)
		return;
	zio_trigger_abort_disable(&ft->zdev->cset[channel - FT_CH_1], 0);
}

/* TDC input attributes: only the user offset is special */
static int ft_zio_info_channel(struct device *dev, struct zio_attribute *zattr,
			       uint32_t *usr_val)
{
	struct zio_cset *cset;
	struct fmctdc_dev *ft;
	struct ft_channel_state *st;

	cset = to_zio_cset(dev);
	ft = cset->zdev->priv_d;
	st = &ft->channels[cset->index];

	switch (zattr->id) {
	case FT_ATTR_TDC_USER_OFFSET:
		*usr_val = st->user_offset;
		break;
	case FT_ATTR_TDC_ZERO_OFFSET:
		*usr_val = ft->calib.zero_offset[cset->index];
		break;
	case FT_ATTR_TDC_TERMINATION:
		*usr_val = test_bit(FT_FLAG_CH_TERMINATED, &st->flags);
		break;
	case FT_ATTR_TDC_DELAY_REF:
		*usr_val = st->delay_reference;
		break;
	/* Parameters */
	case FT_ATTR_TDC_SECONDS:
		*usr_val = st->last_ts.seconds;
		break;
	case FT_ATTR_TDC_COARSE:
		*usr_val = st->last_ts.coarse;
		break;
	case FT_ATTR_TDC_FRAC:
		*usr_val = st->last_ts.frac;
		break;
	}

	return 0;
}

/* Overall and device-wide attributes: only get_time is special */
static int ft_zio_info_get(struct device *dev, struct zio_attribute *zattr,
			     uint32_t *usr_val)
{
	struct zio_device *zdev;
	struct fmctdc_dev *ft;
	struct zio_attribute *attr;

	if (__ft_get_type(dev) == FT_TYPE_INPUT)
		return ft_zio_info_channel(dev, zattr, usr_val);

	zdev = to_zio_dev(dev);
	attr = zdev->zattr_set.ext_zattr;
	ft = zdev->priv_d;

	switch (zattr->id) {
	case FT_ATTR_DEV_SEQUENCE:
		*usr_val = ft->sequence;
		break;
	case FT_ATTR_PARAM_TEMP:
		ft_read_temp(ft, ft->verbose);
		*usr_val = ft->temp;
		break;
	case FT_ATTR_DEV_COARSE:
	case FT_ATTR_DEV_SECONDS:
		{
			uint64_t seconds;
			uint32_t coarse;

			if (ft_get_tai_time(ft, &seconds, &coarse) < 0)
				return -EAGAIN;

			attr[FT_ATTR_DEV_COARSE].value = coarse;
			attr[FT_ATTR_DEV_SECONDS].value = (uint32_t) seconds;

			*usr_val =
			    (zattr->id ==
			     FT_ATTR_DEV_COARSE ? coarse : (uint32_t) seconds);
			break;
		}
	case FT_ATTR_DEV_ENABLE_INPUTS:
		attr[FT_ATTR_DEV_ENABLE_INPUTS].value =
		    ft->acquisition_on ? 1 : 0;
		*usr_val = ft->acquisition_on ? 1 : 0;
		break;
	case FT_ATTR_TDC_WR_OFFSET:
		*usr_val = ft->calib.wr_offset;
		break;
	}
	return 0;
}

static int ft_zio_conf_channel(struct device *dev, struct zio_attribute *zattr,
			       uint32_t usr_val)
{
	struct zio_cset *cset;
	struct fmctdc_dev *ft;
	struct ft_channel_state *st;
	int32_t user_offs;

	cset = to_zio_cset(dev);
	ft = cset->zdev->priv_d;
	st = &ft->channels[cset->index];

	switch (zattr->id) {
	case FT_ATTR_TDC_TERMINATION:
		ft_enable_termination(ft, cset->index + 1, usr_val);
		break;

	case FT_ATTR_TDC_USER_OFFSET:
		user_offs = usr_val;
		if (user_offs < -FT_USER_OFFSET_RANGE
		    || user_offs > FT_USER_OFFSET_RANGE)
			return -EINVAL;
		spin_lock(&ft->lock);
		st->user_offset = usr_val;
		spin_unlock(&ft->lock);
		break;
	case FT_ATTR_TDC_DELAY_REF:
		if (usr_val > FT_NUM_CHANNELS)
			return -EINVAL;
		st->delay_reference = usr_val;
		break;
	default:
		return -EINVAL;
	}

	return 0;
}

/*
 * The input method may return immediately, because input is
 * asynchronous. The data_done callback is invoked when the block is
 * full.
 */

static int ft_zio_input(struct zio_cset *cset)
{
	struct fmctdc_dev *ft;
	struct ft_channel_state *st;

	ft = cset->zdev->priv_d;

	if (!ft->initialized)
		return -EAGAIN;

	st = &ft->channels[cset->index];

	/* Ready for input. If there's already something, return it now */
	if (ft_read_sw_fifo(ft, cset->index + 1, cset->chan) == 0)
		return 0;	/* don't call data_done, let the caller do it */

	return -EAGAIN;
}

/* conf_set dispatcher and  and device-wide attributes */
static int ft_zio_conf_set(struct device *dev, struct zio_attribute *zattr,
			   uint32_t usr_val)
{
	struct zio_device *zdev;
	struct fmctdc_dev *ft;
	struct zio_attribute *attr;

	if (__ft_get_type(dev) == FT_TYPE_INPUT)
		return ft_zio_conf_channel(dev, zattr, usr_val);

	/* Remains: wholedev */
	zdev = to_zio_dev(dev);
	attr = zdev->zattr_set.ext_zattr;
	ft = zdev->priv_d;

	if (zattr->id == FT_ATTR_DEV_SECONDS) {
		attr[FT_ATTR_DEV_SECONDS].value = usr_val;

		return ft_set_tai_time(ft,
				       attr[FT_ATTR_DEV_SECONDS].value,
				       attr[FT_ATTR_DEV_COARSE].value);
		return -ENOTSUPP;
	} else if (zattr->id == FT_ATTR_DEV_ENABLE_INPUTS) {
		attr[FT_ATTR_DEV_ENABLE_INPUTS].value = usr_val ? 1 : 0;

		ft_enable_acquisition(ft, usr_val);
	}

	/* Not command, nothing to do */
	if (zattr->id != FT_ATTR_DEV_COMMAND)
		return 0;

	switch (usr_val) {
	case FT_CMD_SET_HOST_TIME:
		return ft_set_host_time(ft);
	case FT_CMD_WR_ENABLE:
		return ft_wr_mode(ft, 1);
	case FT_CMD_WR_DISABLE:
		return ft_wr_mode(ft, 0);
	case FT_CMD_WR_QUERY:
		return ft_wr_query(ft);
	default:
		return -EINVAL;
	}
}



/*
 * The probe function receives a new zio_device, which is different from
 * what we allocated (that one is the "hardwre" device) but has the
 * same private data. So we make the link and return success.
 */
static int ft_zio_probe(struct zio_device *zdev)
{
	struct fmctdc_dev *ft;

	/* link the new device from the fd structure */
	ft = zdev->priv_d;
	ft->zdev = zdev;

	/* We don't have csets at this point, so don't do anything more */
	return 0;
}

/* Our sysfs operations to access internal settings */
static const struct zio_sysfs_operations ft_zio_sysfs_ops = {
	.conf_set = ft_zio_conf_set,
	.info_get = ft_zio_info_get,
};

#define DECLARE_CHANNEL(ch_name) \
	{\
		ZIO_SET_OBJ_NAME(ch_name),\
		.raw_io =	ft_zio_input,\
		.n_chan =	1,\
		.ssize =	4, /* FIXME: 0? */\
		.flags =	ZIO_DIR_INPUT | ZIO_CSET_TYPE_TIME | \
				ZIO_CSET_SELF_TIMED, \
		.zattr_set = {\
			.ext_zattr = ft_zattr_input,\
			.n_ext_attr = ARRAY_SIZE(ft_zattr_input),\
		},\
	}

/* We have 5 csets, since each output triggers separately */
static struct zio_cset ft_cset[] = {
	DECLARE_CHANNEL("ft-ch1"),
	DECLARE_CHANNEL("ft-ch2"),
	DECLARE_CHANNEL("ft-ch3"),
	DECLARE_CHANNEL("ft-ch4"),
	DECLARE_CHANNEL("ft-ch5"),
};

static struct zio_device ft_tmpl = {
	.owner = THIS_MODULE,
	.preferred_trigger = "user",
	.s_op = &ft_zio_sysfs_ops,
	.cset = ft_cset,
	.n_cset = ARRAY_SIZE(ft_cset),
	.zattr_set = {
		      .std_zattr = ft_zattr_dev_std,
		      .ext_zattr = ft_zattr_dev,
		      .n_ext_attr = ARRAY_SIZE(ft_zattr_dev),
		      },
};

static const struct zio_device_id ft_table[] = {
	{"tdc-1n5c", &ft_tmpl},
	{},
};

static struct zio_driver ft_zdrv = {
	.driver = {
		   .name = "tdc-1n5c",
		   .owner = THIS_MODULE,
		   },
	.id_table = ft_table,
	.probe = ft_zio_probe,
};

/* Register and unregister are used to set up the template driver */
int ft_zio_register(void)
{
	int err;

	err = zio_register_driver(&ft_zdrv);
	if (err)
		return err;

	return 0;
}

void ft_zio_unregister(void)
{
	zio_unregister_driver(&ft_zdrv);
	/* FIXME */
}

/* Init and exit are called for each FD card we have */
int ft_zio_init(struct fmctdc_dev *ft)
{
	int err = 0;
	int dev_id;

	ft->hwzdev = zio_allocate_device();
	if (IS_ERR(ft->hwzdev))
		return PTR_ERR(ft->hwzdev);

	/* Mandatory fields */
	ft->hwzdev->owner = THIS_MODULE;
	ft->hwzdev->priv_d = ft;

	dev_id = ft->fmc->device_id;

	err = zio_register_device(ft->hwzdev, "tdc-1n5c", dev_id);
	if (err) {
		zio_free_device(ft->hwzdev);
		return err;
	}

	return 0;
}

void ft_zio_exit(struct fmctdc_dev *ft)
{
	zio_unregister_device(ft->hwzdev);
	zio_free_device(ft->hwzdev);
}
