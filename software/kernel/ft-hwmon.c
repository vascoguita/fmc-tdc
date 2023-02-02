// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2023 CERN (home.cern)

/*
 * Author: Vaibhav Gupta <vaibhav.gupta@cern.ch>
 */

#include <linux/hwmon.h>
#include "fmc-tdc.h"

#if LINUX_VERSION_CODE >= KERNEL_VERSION(5,10,0)

static umode_t ft_hwmon_temp_is_visible(const void *_data,
				  enum hwmon_sensor_types type, u32 attr,
				  int channel)
{
	return 0444;
}

static int ft_hwmon_temp_read(struct device *dev, enum hwmon_sensor_types type,
				u32 attr, int channel, long *val)
{
	struct fmctdc_dev *ft = dev_get_drvdata(dev);

	*val = ft_temperature_get(ft);

	if(*val < 0)
		dev_err(dev, "Could not read temperature: %d", -EIO);

	return 0;
}

static char *ft_hwmon_temp_sensor_id;

static int ft_hwmon_temp_sensor_id_read(struct device *dev,
				   enum hwmon_sensor_types type,
				   u32 attr, int channel, const char **str)
{
	int size;
	char device_type[] = "Temperature - FMC TDC - ";
	struct fmctdc_dev *ft = dev_get_drvdata(dev);

	size = strlen(dev_name(&ft->slot->dev));
	size += strlen(device_type);
	size++;

	ft_hwmon_temp_sensor_id = kzalloc(size, GFP_KERNEL);

	if(!ft_hwmon_temp_sensor_id)
		return -ENOMEM;

	snprintf(ft_hwmon_temp_sensor_id, size, "%s%s",
		 device_type, dev_name(&ft->slot->dev));

	*str = ft_hwmon_temp_sensor_id;

	return 0;
}

static const struct hwmon_channel_info *ft_hwmon_info[] = {
	HWMON_CHANNEL_INFO(temp, HWMON_T_INPUT | HWMON_T_LABEL),
	NULL
};

static const struct hwmon_ops ft_hwmon_temp_ops = {
	.is_visible = ft_hwmon_temp_is_visible,
	.read = ft_hwmon_temp_read,
	.read_string = ft_hwmon_temp_sensor_id_read
};

static const struct hwmon_chip_info ft_hwmon_temp_chip_info = {
	.ops = &ft_hwmon_temp_ops,
	.info = ft_hwmon_info,
};

int ft_hwmon_init(struct fmctdc_dev *ft)
{
	struct device *dev = &ft->pdev->dev;
	ft->hwmon_dev = devm_hwmon_device_register_with_info(dev,
							     "ft_temperature",
							     ft,
							     &ft_hwmon_temp_chip_info,
							     NULL);
	return PTR_ERR_OR_ZERO(ft->hwmon_dev);
}

#endif /* LINUX_VERSION_CODE >= KERNEL_VERSION(5,10,0) */
