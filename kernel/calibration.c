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


/* This is the only thing called by outside */
int ft_handle_eeprom_calibration(struct fmctdc_dev *ft)
{
	struct ft_calibration *calib;
	struct device *d = &ft->fmc->dev;
	int i;
	u32 raw_calib[7], year;

	/* Retrieve and validate the calibration */
	calib = &ft->calib;
	memcpy(calib, &default_calibration, sizeof(struct ft_calibration));

	i = ft_read_calibration_eeprom(ft->fmc, raw_calib, sizeof(raw_calib));

	if (i < 0) {
		dev_err(d,
			"Failed to read calibration EEPROM. Using default.\n");
		for (i = 0; i < FT_NUM_CHANNELS; i++)
			calib->zero_offset[i] = 0;
			calib->vcxo_default_tune = 32000;
	} else {
		calib->zero_offset[0] = 0;
		for (i = FT_CH_1 + 1; i < FT_NUM_CHANNELS; i++)
			calib->zero_offset[i] =
				le32_to_cpu(raw_calib[i - 1]) / 100;

		calib->vcxo_default_tune = le32_to_cpu(raw_calib[4]);
	}

	calib->calibration_temp = le32_to_cpu(raw_calib[5]);
	calib->wr_offset = le32_to_cpu(raw_calib[6]) / 100;

	year = __get_ipmi_fru_id_year(ft);
	if (year < WR_OFFSET_FIX_YEAR) {
		calib->wr_offset = wr_calibration_offset;
		dev_warn(d,
			 "Apply default calibration correction to White-Rabbit offset if done before 2018 (%d)\n",
			 year);
	}

	calib->wr_offset += wr_calibration_offset_carrier;

	if (ft->verbose) {
		/* Print verbose messages */
		for (i = 0; i < ARRAY_SIZE(calib->zero_offset); i++)
			dev_info(d, "calib: zero_offset[%i] = %i ps\n",
				 i, calib->zero_offset[i]);

		dev_info(d, "calib: vcxo_default_tune %i\n",
			 calib->vcxo_default_tune);
		dev_info(d, "calib: wr offset = %i ps\n",
			 calib->wr_offset);
	}
	return 0;
}
