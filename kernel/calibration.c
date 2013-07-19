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

#include "libsdbfs.h"
#include "fmc-tdc.h"

/* dummy calibration data - used in case of empty/corrupted EEPROM */
static struct ft_calibration default_calibration = {
	{ 0, 86, 609, 572, 335}, /* zero_offset */
	43343                    /* vcxo_default_tune */
};

/* sdbfs-related function */
static int ft_read_calibration_eeprom(struct fmc_device *fmc, void *buf, int length)
				      
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
	ret = sdbfs_open_id(&fs, 0x61746144656c6946LL, 0x696c6163);
	if (ret)
		return ret;

	ret = sdbfs_fread(&fs, 0, buf, length);
	sdbfs_dev_destroy(&fs);
	return ret;
}

/* This is the only thing called by outside */
int ft_handle_eeprom_calibration(struct fmctdc_dev *ft)
{
	struct ft_calibration *calib;
	struct device *d = &ft->fmc->dev;
	int i;
	u32 raw_calib[5];

	/* Retrieve and validate the calibration */
	calib = &ft->calib;
	memcpy(calib, &default_calibration, sizeof(struct ft_calibration));

	i = ft_read_calibration_eeprom(ft->fmc, raw_calib, sizeof(raw_calib));

	/* fixme: there is no calibration validation. Change format?  */

	/* Translate offsets (they are referenced to channel 0 and in 1/100s of picosecond) to 
	   offsets that could be added to TDC timestamps right away (picoseconds, referenced to WR) */

	calib->zero_offset[0] = 0;
	for(i = FT_CH_1 + 1; i < FT_NUM_CHANNELS; i++)
		calib->zero_offset[i] = le32_to_cpu(raw_calib[i - 1]) / 100 - calib->zero_offset[0];

	calib->vcxo_default_tune = le32_to_cpu(raw_calib[4]);
	
	for (i = 0; i < ARRAY_SIZE(calib->zero_offset); i++)
			dev_info(d, "calib: zero_offset[%i] = %li\n", i,
				 (long)calib->zero_offset[i]);
	
	dev_info(d, "calib: vcxo_default_tune %i\n", calib->vcxo_default_tune);

	return 0;	
}
