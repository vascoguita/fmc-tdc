/*
 * EEPROM calibration block retreival code for fmc-tdc.
 *
 * Copyright (C) 2013 CERN (www.cern.ch)
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include <linux/moduleparam.h>
#include <linux/time.h>
#include <linux/firmware.h>
#include <linux/jhash.h>
#include <linux/slab.h>
#include <linux/fmc.h>
#include <linux/ipmi/fru.h>
#include <linux/zio.h>

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
#define IPMI_FRU_SIZE 256

/**
 * HACK area to get the calibration year
 */
static u32 __get_ipmi_fru_id_year(struct fmctdc_dev *ft)
{
	struct fru_board_info_area *bia;
	struct fru_type_length *tmp;
	unsigned long year = 0;
	char year_ascii[5];
	void *fru = NULL;
	int err, i;

	fru = kmalloc(IPMI_FRU_SIZE, GFP_KERNEL);
	if (!fru)
		goto out_mem;
	err = fmc_slot_eeprom_read(ft->slot, fru, 0x0, IPMI_FRU_SIZE);
	if (err)
		goto out_read;
	bia = fru_get_board_area((const struct fru_common_header *)fru);
	tmp = bia->tl;
	for (i = 0; i < 4; ++i) {
		tmp = fru_next_tl(tmp);
		if (!tmp)
			goto out_fru;
	}
	if (!fru_length(tmp))
		goto out_fru;
	if (fru_type(tmp) != FRU_TYPE_ASCII)
		goto out_fru;
	memcpy(year_ascii, tmp->data, 4);
	year_ascii[4] = '\0';
	err = kstrtoul(year_ascii, 10, &year);
	if (err)
		year = 0;

out_fru:
out_read:
	kfree(fru);
out_mem:
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

#define FT_EEPROM_CALIB_OFFSET 0x100

int ft_calib_init(struct fmctdc_dev *ft)
{
	struct ft_calibration_raw calib;
	int ret;

	ret = fmc_slot_eeprom_read(ft->slot, &calib,
				   FT_EEPROM_CALIB_OFFSET, sizeof(calib));
	if (ret < 0) {
		dev_warn(&ft->pdev->dev,
			 "Failed to read calibration from EEPROM: using identity calibration %d\n",
			 ret);
		memcpy(&calib, &default_calibration, sizeof(calib));
		goto out;
	}

	ft_calib_cpy_from_raw(&ft->calib, &calib);
	/* FIX wrong calibration on old FMC-TDC mezzanine */
	if (__get_ipmi_fru_id_year(ft) < WR_OFFSET_FIX_YEAR)
		ft->calib.wr_offset = wr_calibration_offset;

out:
	ft->calib.wr_offset += wr_calibration_offset_carrier;
	return 0;
}

void ft_calib_exit(struct fmctdc_dev *ft)
{

}
