/*
 * EEPROM calibration block retreival code for fmc-tdc.
 *
 * Copyright (C) 2013 CERN (www.cern.ch)
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation or, at your
 * option, any later version.
 */

#include <linux/moduleparam.h>
#include <linux/time.h>
#include <linux/firmware.h>
#include <linux/jhash.h>
#include <linux/slab.h>
#include <linux/ipmi-fru.h>
#include <linux/zio.h>

#include "libsdbfs.h"
#include "fmc-tdc.h"

#define WR_CALIB_OFFSET 229460
static u32 wr_calibration_offset = WR_CALIB_OFFSET;
module_param_named(wr_offset_fix, wr_calibration_offset, int, 0444);
MODULE_PARM_DESC(wr_offset_fix,
		 "Overwrite the White-Rabbit calibration offset for calibration value computer before 2018. (Default: 229460 [ps])");

static u32 wr_calibration_offset_carrier = 0;
module_param_named(wr_offset_carrier, wr_calibration_offset_carrier, int, 0444);
MODULE_PARM_DESC(wr_offset_carrier,
		 "White-Rabbit carrier calibration offset. (Default SPEC: 0 [ps])");


/* dummy calibration data - used in case of empty/corrupted EEPROM */
static struct ft_calibration default_calibration = {
	{0, 86, 609, 572, 335},	/* zero_offset */
	43343,			/* vcxo_default_tune */
	0,
	WR_CALIB_OFFSET, /* white-rabbit offset */
};

#define WR_OFFSET_FIX_YEAR (2018)

/* sdbfs-related function */
static int ft_read_calibration_eeprom(struct fmc_device *fmc, void *buf,
				      int length)
{
	int i, ret = 0;
	static struct sdbfs fs;

	fs.data = fmc->eeprom;
	fs.datalen = fmc->eeprom_len;

	/* Look for sdb entry point */
	for (i = 0x40; i < fmc->eeprom_len - 0x40; i += 0x40) {
		fs.entrypoint = i;
		ret = sdbfs_dev_create(&fs, 0);
		if (ret == 0)
			break;
	}
	if (ret)
		return ret;
	/* Open "cali" as a device id, vendor is "FileData" -- big endian */
	ret = sdbfs_open_name(&fs, "calib");
	if (ret)
		return ret;

	ret = sdbfs_fread(&fs, 0, buf, length);

	sdbfs_dev_destroy(&fs);
	return ret;
}

/**
 * HACK area to get the calibration year
 */
static u32 __get_ipmi_fru_id_year(struct fmctdc_dev *ft)
{
	struct fru_board_info_area *bia;
	struct fru_type_length *tmp;
	unsigned long year = 0;
	char *buf = NULL;
	int err, i;

	bia = fru_get_board_area((const struct fru_common_header *)ft->fmc->eeprom);
	tmp = bia->tl;
	for (i = 0; i < 4; ++i) {
		tmp = fru_next_tl(tmp);
		if (!tmp)
			goto out;
	}
	if (!fru_length(tmp))
		goto out;
	if (fru_type(tmp) != FRU_TYPE_ASCII)
		goto out;
	buf = kmalloc(fru_length(tmp), GFP_ATOMIC);
	if (!buf)
		goto out;
	buf = fru_strcpy(buf, tmp);
	buf[4] = '\0';
	err = kstrtoul(buf, 10, &year);
	if (err)
		goto out;

out:
	kfree(buf);
	return year;
}

/**
 * @calib: calibration data
 *
 * We know for sure that our structure is only made of 32bit fields
 */
static void ft_calib_le32_to_cpus(struct ft_calibration_raw *calib)
{
	int i;
	uint32_t *p = (uint32_t *)calib;

	for (i = 0; i < sizeof(*calib) / sizeof(uint32_t); i++)
		le32_to_cpus(p + i); /* s == in situ */
}

/**
 * @calib: calibration data
 *
 * We know for sure that our structure is only made of 32bit fields
 */
static void ft_calib_cpu_to_le32s(struct ft_calibration_raw *calib)
{
	int i;
	uint32_t *p = (uint32_t *)calib;

	for (i = 0; i < sizeof(*calib) / sizeof(uint32_t); i++)
		cpu_to_le32s(p + i); /* s == in situ */
}

static void ft_calib_cpy_from_raw(struct ft_calibration *calib,
				  struct ft_calibration_raw *calib_raw)
{
	int i;

	ft_calib_le32_to_cpus(calib_raw);
	calib->zero_offset[0] = 0;
	for (i = 1; i < FT_NUM_CHANNELS; i++)
		calib->zero_offset[i] = calib_raw->zero_offset[i - 1] / 100;
	calib->vcxo_default_tune = calib_raw->vcxo_default_tune / 100;
	calib->calibration_temp = calib_raw->calibration_temp;
	calib->wr_offset = calib_raw->wr_offset / 100;
	calib->wr_offset += wr_calibration_offset_carrier;
}

static void ft_calib_cpy_to_raw(struct ft_calibration_raw *calib_raw,
				struct ft_calibration *calib)
{
	int i;

	for (i = 1; i < FT_NUM_CHANNELS; i++)
		calib_raw->zero_offset[i - 1] = calib->zero_offset[i] * 100;
	calib_raw->vcxo_default_tune = calib->vcxo_default_tune * 100;
	calib_raw->calibration_temp = calib->calibration_temp;
	calib_raw->wr_offset = (calib->wr_offset - wr_calibration_offset_carrier) * 100;

	ft_calib_cpu_to_le32s(calib_raw);
}


/* This is the only thing called by outside */
int ft_handle_eeprom_calibration(struct fmctdc_dev *ft)
{
	struct ft_calibration *calib;
	struct ft_calibration_raw calib_raw;
	struct device *d = &ft->fmc->dev;
	int i;

	/* Retrieve and validate the calibration */
	calib = &ft->calib;
	i = ft_read_calibration_eeprom(ft->fmc, &calib_raw, sizeof(calib_raw));
	if (i >= 0) {
		u32 year;

		ft_calib_cpy_from_raw(calib, &calib_raw);
		year = __get_ipmi_fru_id_year(ft);
		if (year < WR_OFFSET_FIX_YEAR) {
			calib->wr_offset = wr_calibration_offset;
			calib->wr_offset += wr_calibration_offset_carrier;
			dev_warn(d,
				 "Apply default calibration correction to White-Rabbit offset if done before 2018 (%d)\n",
				 year);
		}
	} else {
		dev_err(d,
			"Failed to read calibration EEPROM. Using default.\n");
		memcpy(calib, &default_calibration, sizeof(*calib));
		calib->wr_offset += wr_calibration_offset_carrier;
	}

	return 0;
}


static ssize_t ft_write_eeprom(struct file *file, struct kobject *kobj,
			       struct bin_attribute *attr,
			       char *buf, loff_t off, size_t count)
{
	struct device *dev = container_of(kobj, struct device, kobj);
	struct fmctdc_dev *ft = to_zio_dev(dev)->priv_d;
	struct ft_calibration_raw *calib_raw = (struct ft_calibration_raw *) buf;

	if (off != 0 || count != sizeof(*calib_raw))
		return -EINVAL;

	ft_calib_cpy_from_raw(&ft->calib, calib_raw);

	return count;
}

static ssize_t ft_read_eeprom(struct file *file, struct kobject *kobj,
			      struct bin_attribute *attr,
			      char *buf, loff_t off, size_t count)
{
	struct device *dev = container_of(kobj, struct device, kobj);
	struct fmctdc_dev *ft = to_zio_dev(dev)->priv_d;
	struct ft_calibration_raw *calib_raw = (struct ft_calibration_raw *) buf;

	if (off != 0 || count < sizeof(*calib_raw))
		return -EINVAL;

	ft_calib_cpy_to_raw(calib_raw, &ft->calib);

	return count;
}

struct bin_attribute dev_attr_calibration = {
	.attr = {
		.name = "calibration_data",
		.mode = 0644,
	},
	.size = sizeof(struct ft_calibration_raw),
	.write = ft_write_eeprom,
	.read = ft_read_eeprom,
};
