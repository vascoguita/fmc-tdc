/*
 * ZIO interface for the fmc-tdc driver.
 *
 * Copyright (C) 2012-2013 CERN (www.cern.ch)
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
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
	ZIO_ATTR_EXT("wr-offset", ZIO_RO_PERM, FT_ATTR_TDC_WR_OFFSET, 0),
	ZIO_PARAM_EXT("temperature", ZIO_RO_PERM, FT_ATTR_PARAM_TEMP, 0),
	ZIO_PARAM_EXT("test_dma_sg", ZIO_WO_PERM, FT_ATTR_PARAM_DMA_SG, 0),
	ZIO_PARAM_EXT("test_dma", ZIO_WO_PERM, FT_ATTR_PARAM_DMA, 0),
};

/* Extended attributes for the TDC (== input) cset */
static struct zio_attribute ft_zattr_input[] = {
	ZIO_ATTR_EXT("termination", ZIO_RW_PERM, FT_ATTR_TDC_TERMINATION, 0),
	ZIO_ATTR_EXT("zero-offset", ZIO_RO_PERM, FT_ATTR_TDC_ZERO_OFFSET, 0),
	ZIO_ATTR_EXT("user-offset", ZIO_RW_PERM, FT_ATTR_TDC_USER_OFFSET, 0),
	ZIO_ATTR_EXT("diff-reference", ZIO_RW_PERM, FT_ATTR_TDC_DELAY_REF, 0),
	ZIO_ATTR_EXT("transfer-mode", ZIO_RO_PERM, FT_ATTR_TDC_TRANSFER_MODE, 0),
	ZIO_ATTR_EXT("irq_coalescing_time", ZIO_RW_PERM,
		     FT_ATTR_TDC_COALESCING_TIME, 10),
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
		/* FIXME read from HW */
		break;
	case FT_ATTR_TDC_TRANSFER_MODE:
		*usr_val = ft->mode;
		break;
	case FT_ATTR_TDC_COALESCING_TIME:
		*usr_val = ft_irq_coalescing_timeout_get(ft, cset->index);
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
	case FT_ATTR_PARAM_TEMP:
		ft_read_temp(ft, ft->verbose);
		*usr_val = ft->temp;
		break;
	case FT_ATTR_DEV_COARSE:
	case FT_ATTR_DEV_SECONDS:
		{
			uint64_t seconds;
			uint32_t coarse;

			ft_get_tai_time(ft, &seconds, &coarse);

			attr[FT_ATTR_DEV_COARSE].value = coarse;
			attr[FT_ATTR_DEV_SECONDS].value = (uint32_t) seconds;

			*usr_val =
			    (zattr->id ==
			     FT_ATTR_DEV_COARSE ? coarse : (uint32_t) seconds);
			break;
		}
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
		/* FIXME write on HW */
		break;
	case FT_ATTR_TDC_COALESCING_TIME:
		ft_irq_coalescing_timeout_set(ft, cset->index, usr_val);
		break;
	default:
		return -EINVAL;
	}

	return 0;
}

/*
 * The input is asynchronous, but we know that from this point on
 * our hardware will be busy in transfering data to the host.
 * For this reason we need to flag the cset as BUSY
 */
static int ft_zio_input(struct zio_cset *cset)
{
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

		ft_set_tai_time(ft,
				attr[FT_ATTR_DEV_SECONDS].value,
				attr[FT_ATTR_DEV_COARSE].value);
		return 0;
	}

	switch (zattr->id) {
	case FT_ATTR_PARAM_DMA_SG:
		return test_dma(ft, usr_val, 1);
	case FT_ATTR_PARAM_DMA:
		return test_dma(ft, usr_val, 0);
	case FT_ATTR_DEV_COMMAND:
		switch (usr_val) {
		case FT_CMD_SET_HOST_TIME:
			ft_set_host_time(ft);
			return 0;
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

/**
 * It enables/disables interrupts according to the enable/disable
 * status of the correspondent channel
 */
static void ft_change_flags(struct zio_obj_head *head, unsigned long mask)
{
	struct zio_channel *chan;
	struct ft_channel_state *st;
	struct fmctdc_dev *ft;
	uint32_t ien;

	/* We manage only status flag */
	if (!(mask & ZIO_STATUS))
		return;

	chan = to_zio_chan(&head->dev);
	ft = chan->cset->zdev->priv_d;
	st = &ft->channels[chan->cset->index];

	ien = ft_readl(ft, TDC_REG_INPUT_ENABLE);
	if (chan->flags & ZIO_STATUS) {
		/* DISABLED */
		ft_disable(ft, chan->cset->index);

		zio_trigger_abort_disable(chan->cset, 0);
		/* Reset last time-stamp (seq number and valid)*/
		//ft_iowrite(ft, TDC_FIFO_LAST_CSR_VALID | TDC_FIFO_LAST_CSR_RST_SEQ,
		//	  TDC_FIFO_LAST_CSR);
	} else {
		/* ENABLED */
		ft_enable(ft, chan->cset->index);
	}
	/*
	 * NOTE: above we have a little HACK. According to ZIO v1.1, ZIO invokes
	 * this function in a spin-lock context. The TDC assigns this function to
	 * the channel, so ZIO will take the channel lock. Then on arm() and
	 * abort() ZIO takes the cset flag. So this will not fail, but bear in
	 * mind that if you do this when it is assigned to a cset it wont work
	 */
}

static struct zio_channel ft_chan_tmpl = {
	.change_flags = ft_change_flags,
	.flags = ZIO_DISABLED,
};

#define DECLARE_CHANNEL(ch_name) \
	{\
		ZIO_SET_OBJ_NAME(ch_name),\
		.raw_io =	ft_zio_input,\
		.chan_template = &ft_chan_tmpl,\
		.n_chan =	1,\
		.ssize =	sizeof(struct ft_hw_timestamp), \
		.flags =	ZIO_DISABLED | \
				ZIO_DIR_INPUT,\
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
	.preferred_trigger = FT_ZIO_TRIG_TYPE_NAME,
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
	/* Take the version from ZIO git sub-module */
	.min_version = ZIO_VERSION(__ZIO_MIN_MAJOR_VERSION,
				   __ZIO_MIN_MINOR_VERSION,
				   0), /* Change it if you use new features from
					  a specific patch */
};

#define FT_TRIG_POST_DEFAULT 1
enum ft_trig_options {
	FT_TRIG_POST = 0,
};


/**
 * It applies all calibration offsets to the givne timestamp
 * @ft FmcTdc device instance
 * @ts timestamp
 */
static void ft_timestamp_apply_offsets(struct fmctdc_dev *ft,
				       struct ft_hw_timestamp *hwts)
{
	unsigned int chan = FT_HW_TS_META_CHN(hwts->metadata);
	struct ft_channel_state *st = &ft->channels[chan];

	ft_ts_apply_offset(hwts, ft->calib.zero_offset[chan]);
	ft_ts_apply_offset(hwts, -ft->calib.wr_offset);
	if (st->user_offset)
		ft_ts_apply_offset(hwts, st->user_offset);
}

/**
 * It puts the given timestamp in the ZIO control
 * @cset ZIO cset instant
 * @hwts the timestamp to convert
 */
static void ft_zio_update_ctrl(struct zio_cset *cset,
			       struct ft_hw_timestamp *hwts)
{
	struct fmctdc_dev *ft = cset->zdev->priv_d;
	struct zio_control *ctrl;
	uint32_t *v;
	struct ft_channel_state *st;

	st = &ft->channels[cset->index];
	ctrl = cset->chan->current_ctrl;
	v = ctrl->attr_channel.ext_val;

	/* Write the timestamp in the trigger, it will reach the control */
	cset->ti->tstamp.tv_sec = hwts->seconds;
	cset->ti->tstamp.tv_nsec = hwts->coarse; /* we use 8ns steps */
	cset->ti->tstamp_extra = hwts->frac;

	/* Synchronize ZIO sequence number with ours (ZIO does +1 on this) */
	ctrl->seq_num = FT_HW_TS_META_SEQ(hwts->metadata) - 1;

	v[FT_ATTR_TDC_ZERO_OFFSET] = ft->calib.zero_offset[cset->index];
	v[FT_ATTR_TDC_USER_OFFSET] = st->user_offset;
}

static ZIO_ATTR_DEFINE_STD(ZIO_TRG, ft_trig_std_zattr) = {
	/* Number of shots */
	ZIO_ATTR(trig, ZIO_ATTR_TRIG_POST_SAMP, ZIO_RW_PERM, FT_TRIG_POST,
		 FT_TRIG_POST_DEFAULT),
};

static int ft_trig_conf_set(struct device *dev, struct zio_attribute *zattr,
			 uint32_t usr_val)
{
	return 0;
}

static int ft_trig_info_get(struct device *dev, struct zio_attribute *zattr,
			 uint32_t *usr_val)
{
	return 0;
}

static const struct zio_sysfs_operations ft_trig_s_op = {
	.conf_set = ft_trig_conf_set,
	.info_get = ft_trig_info_get,
};

static struct zio_ti *ft_trig_create(struct zio_trigger_type *trig,
				 struct zio_cset *cset,
				 struct zio_control *ctrl, fmode_t flags)
{
	struct fmctdc_trig *tti;

	tti = kzalloc(sizeof(*tti), GFP_KERNEL);
	if (!tti)
		return ERR_PTR(-ENOMEM);

	tti->ti.flags = ZIO_DISABLED;
	tti->ti.cset = cset;

	return &tti->ti;
}

static void ft_trig_destroy(struct zio_ti *ti)
{
	struct fmctdc_trig *tti = to_fmctdc_trig(ti);

	kfree(tti);
}

/**
 * It completes an acquisition.
 * @cset the ZIO channel set that completed the acquisition
 *
 * Rembember that here the cset->lock is taken and we can do
 * what we want with the cset
 */
static int ft_trig_data_done(struct zio_cset *cset)
{
	struct fmctdc_dev *ft = cset->zdev->priv_d;
	struct ft_hw_timestamp *ts;
	int i, ret;

	if (!cset->chan->active_block)
		goto out;

	ts = cset->chan->active_block->data;

	dev_dbg(&cset->head.dev, "%s TS 0/%d %d.%d.%d %d\n",
		__func__, cset->ti->nsamples,
		ts[0].seconds,ts[0].coarse, ts[0].frac,
		FT_HW_TS_META_SEQ(ts[0].metadata));
	dev_dbg(&cset->head.dev, "%s TS %d/%d %d.%d.%d %d\n",
		__func__, cset->ti->nsamples - 1, cset->ti->nsamples,
		ts[cset->ti->nsamples - 1].seconds,
		ts[cset->ti->nsamples - 1].coarse,
		ts[cset->ti->nsamples - 1].frac,
		FT_HW_TS_META_SEQ(ts[cset->ti->nsamples - 1].metadata));


	for(i = 0; i < cset->ti->nsamples; ++i) {
		dev_vdbg(&cset->head.dev, "%s TS  %d/%d %d.%d.%d %d\n",
			__func__, i, cset->ti->nsamples,
			ts[i].seconds,ts[i].coarse,
			ts[i].frac, FT_HW_TS_META_SEQ(ts[i].metadata));
		ft_timestamp_apply_offsets(ft, &ts[i]);
	}
	ft_zio_update_ctrl(cset, &ts[0]);

out:
	ret = zio_generic_data_done(cset);

	return ret;
}

static int ft_trig_push(struct zio_ti *ti, struct zio_channel *chan,
		     struct zio_block *block)
{
	dev_err(&ti->head.dev, "output not supported\n");
	return -EIO;
}

static const struct zio_trigger_operations ft_trig_ops = {
	.create = ft_trig_create,
	.destroy = ft_trig_destroy,
	.change_status = NULL,
	.data_done = ft_trig_data_done,
	.arm = NULL,
	.abort = NULL,
	.push_block = ft_trig_push,
};

/* Definition of the trigger type -- can't be static */
struct zio_trigger_type ft_trig_type = {
	.owner = THIS_MODULE,
	.zattr_set = {
		.std_zattr = ft_trig_std_zattr,
		.ext_zattr = NULL,
		.n_ext_attr = 0,
	},
	.s_op = &ft_trig_s_op,
	.t_op = &ft_trig_ops,
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
	if (err)
		goto err_dev_reg;

	return 0;

err_dev_reg:
	zio_free_device(ft->hwzdev);
	return err;
}

void ft_zio_exit(struct fmctdc_dev *ft)
{
	zio_unregister_device(ft->hwzdev);
	zio_free_device(ft->hwzdev);
}
