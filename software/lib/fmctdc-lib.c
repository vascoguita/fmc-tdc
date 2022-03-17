/*
 * The fmc-tdc (a.k.a. FmcTdc1ns5cha) library.
 *
 * Copyright (C) 2012-2018 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <errno.h>
#include <assert.h>
#include <fcntl.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <linux/zio.h>
#include <linux/zio-user.h>

#include "fmctdc-lib.h"
#include "fmctdc-lib-private.h"

const char * const libfmctdc_version_s = "libfmctdc version: " GIT_VERSION;
const char * const libfmctdc_zio_version_s = "libfmctdc is using zio version: " ZIO_GIT_VERSION;

#define NSAMPLE 1 /* fake number of samples for the TDC */
#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

static char *names[] = { "seconds", "coarse" }; /**< names used to retrive
						   time-stamps from sysfs */

static const char *fmctdc_error_string[] = {
	[FMCTDC_ERR_VMALLOC - __FMCTDC_ERR_MIN] =
		"Missing ZIO vmalloc support",
	[FMCTDC_ERR_UNKNOWN_BUFFER_TYPE - __FMCTDC_ERR_MIN] =
		"Unknown buffer type",
	[FMCTDC_ERR_NOT_CONSISTENT_BUFFER_TYPE - __FMCTDC_ERR_MIN] =
		"Buffer type configuration not consistent",
	[FMCTDC_ERR_VERSION_MISMATCH - __FMCTDC_ERR_MIN] =
		"Incompatible version driver-library",
};

/**
 * It returns the error message associated to the given error code
 * @param[in] err error code
 */
const char *fmctdc_strerror(int err)
{
	if (err < __FMCTDC_ERR_MIN || err > __FMCTDC_ERR_MAX)
		return strerror(err);
	return fmctdc_error_string[err - __FMCTDC_ERR_MIN];
}


/**
 * Init the library. You must call this function before use any other
 * library function.
 * @return 0 on success, otherwise -1 and errno is appropriately set
 */
int fmctdc_init(void)
{
	return 0;
}


/**
 * It releases all the resources used by the library and allocated
 * by fmctdc_init().
 */
void fmctdc_exit(void)
{

}


/**
 * It opens one specific device. -1 arguments mean "not installed"
 * @param[in] dev_id FMC device id. -1 to ignore it and use only the offset
 * @return an instance token, otherwise NULL and errno is appripriately set.
 *         ENODEV if the device was not found. EINVAL there is a mismatch with
 *         the arguments
 */
#define __FMCTDC_OPEN_PATH_MAX 128
struct fmctdc_board *fmctdc_open(int dev_id)
{
	struct __fmctdc_board *b = NULL;
	uint32_t nsamples = NSAMPLE;
	char path[__FMCTDC_OPEN_PATH_MAX];
	uint32_t v;
	int i;
	int ret;
	struct stat sb;

	if (dev_id < 0) {
		errno = EINVAL;
		return NULL;
	}

	b = malloc(sizeof(*b));
	if (!b)
		return NULL;

	b->dev_id = dev_id;
	/* get sysfs */
	snprintf(path, sizeof(path),
		 "/sys/bus/zio/devices/tdc-1n5c-%04x", b->dev_id);
	ret = stat(path, &sb);
	if (ret < 0)
		goto err_stat_s;
	if (!S_ISDIR(sb.st_mode))
		goto err_stat_s;
	b->sysbase = strdup(path);
	if (!b->sysbase)
		goto err_dup_sys;

	/* get dev */
	snprintf(path, sizeof(path),
		 "/dev/zio/tdc-1n5c-%04x-0-0-ctrl", b->dev_id);
	ret = stat(path, &sb);
	if (ret < 0)
		goto err_stat_d;
	if (!S_ISCHR(sb.st_mode))
		goto err_stat_d;
	b->devbase = strndup(path, strlen(path) - strlen("-0-0-ctrl"));
	if (!b->sysbase)
		goto err_dup_dev;

	ret = fmctdc_sysfs_get(b, "version", &v);
	if (ret)
		goto err_version;

	if (v != FT_VERSION_MAJ) {
		errno = FMCTDC_ERR_VERSION_MISMATCH;
		goto err_version;
	}

	ret = fmctdc_get_buffer_type((struct fmctdc_board *)b);
	if (ret < 0)
		goto err_buf;
	/* Trim all block sizes to 1 sample (i.e. 4 bytes) */
	fmctdc_sysfs_set(b, "ft-ch1/trigger/post-samples", &nsamples);
	fmctdc_sysfs_set(b, "ft-ch2/trigger/post-samples", &nsamples);
	fmctdc_sysfs_set(b, "ft-ch3/trigger/post-samples", &nsamples);
	fmctdc_sysfs_set(b, "ft-ch4/trigger/post-samples", &nsamples);
	fmctdc_sysfs_set(b, "ft-ch5/trigger/post-samples", &nsamples);

	for (i = 0; i < FMCTDC_NUM_CHANNELS; i++) {
		b->fdc[i] = -1;
		b->fdd[i] = -1;
		b->fdcc[i] = -1;

		/* Open Control */
		snprintf(path, sizeof(path), "%s-%d-0-ctrl",
			 b->devbase, i);
		b->fdc[i] = open(path, O_RDONLY | O_NONBLOCK);
		if (b->fdc[i] < 0)
			goto error;
		/* Open Data - even if not really used for the time being */
		snprintf(path, sizeof(path), "%s-%d-0-data",
			 b->devbase, i);
		b->fdd[i] = open(path, O_RDONLY | O_NONBLOCK);
		if (b->fdd[i] < 0)
			goto error;
		/* Open Current Control */
		snprintf(path, sizeof(path), "%s/ft-ch%d/chan0/current-control",
			 b->sysbase, i + 1);
		b->fdcc[i] = open(path, O_RDONLY);
		if (b->fdcc[i] < 0)
			goto error;
	}

	return (void *)b;

error:
	while (i--) {
		if (b->fdc[i] >= 0)
			close(b->fdc[i]);
		if (b->fdd[i] >= 0)
			close(b->fdd[i]);
		if (b->fdcc[i] >= 0)
			close(b->fdcc[i]);
	}
err_buf:
err_version:
	free(b->devbase);
err_stat_d:
err_dup_dev:
	free(b->sysbase);
err_dup_sys:
err_stat_s:
	free(b);
	return NULL;
}


/**
 * It opens one specific device by logical unit number (CERN/BE-CO-like).
 * The function uses a symbolic link in /dev that points to the standard device.
 * The link is created by the local installation procedure, and it allows to get
 * the device id according to the LUN.
 * Read also fmctdc_open() documentation.
 * @param[in] lun Logical Unit Number
 * @return an instance token, otherwise NULL and errno is appripriately set
 */
struct fmctdc_board *fmctdc_open_by_lun(int lun)
{
	ssize_t ret;
	char dev_id_str[4];
	char path_pattern[] = "/dev/tdc-1n5c.%d";
	char path[sizeof(path_pattern) + 1];
	uint32_t dev_id;

	ret = snprintf(path, sizeof(path), path_pattern, lun);
	if (ret < 0 || ret >= sizeof(path)) {
		errno = EINVAL;
		return NULL;
	}
	ret = readlink(path, dev_id_str, sizeof(dev_id_str));
	if (ret != 4) { /* 4 digits */
		errno = ENODEV;
		return NULL;
	}
	if (sscanf(dev_id_str, "%4x", &dev_id) != 1) {
		errno = ENODEV;
		return NULL;
	}
	return fmctdc_open(dev_id);
}


/**
 * It closes a TDC instance opened with fmctdc_open() or fmctdc_open_by_lun()
 * @param[in] userb TDC board instance token
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_close(struct fmctdc_board *userb)
{
	__define_board(b, userb);
	int j;

	if (!b) {
		errno = EINVAL;
		return -1;
	}

	for (j = 0; j < ARRAY_SIZE(b->fdc); j++) {
		if (b->fdc[j] >= 0)
			close(b->fdc[j]);
		if (b->fdd[j] >= 0)
			close(b->fdd[j]);
		if (b->fdcc[j] >= 0)
			close(b->fdcc[j]);
	}

	free(b->devbase);
	free(b->sysbase);
	free(b);
	return 0;

}


/**
 * It reads the current temperature of a TDC device
 * @param[in] userb TDC board instance token
 * @return temperature
 */
float fmctdc_read_temperature(struct fmctdc_board *userb)
{
	uint32_t t;
	__define_board(b, userb);

	fmctdc_sysfs_get(b, "temperature", &t);
	return (float)t / 16.0;
}


/**
 * The function enables/disables the 50 Ohm termination of the given channel.
 * Termination may be changed anytime.
 * @param[in] userb TDC board instance token
 * @param[in] channel to use
 * @param[in] on status of the termination to set
 * @return 0 on success, otherwise a negative errno code is set
 *         appropriately
 */
int fmctdc_set_termination(struct fmctdc_board *userb, unsigned int channel,
			   int on)
{
	__define_board(b, userb);
	uint32_t val;
	char attr[32];

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(attr, sizeof(attr), "ft-ch%u/termination", channel + 1);

	val = on ? 1 : 0;
	return fmctdc_sysfs_set(b, attr, &val);
}


/**
 * The function returns current temrmination status: 0 if the given channel
 * is high-impedance and positive if it is 50 Ohm-terminated.
 * @param[in] userb TDC board instance token
 * @param[in] channel to use
 * @return termination status, otherwise a negative errno code is set
 *         appropriately
 */
int fmctdc_get_termination(struct fmctdc_board *userb, unsigned int channel)
{
	__define_board(b, userb);
	uint32_t val;
	char attr[32];
	int ret;

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(attr, sizeof(attr), "ft-ch%u/termination", channel + 1);

	ret = fmctdc_sysfs_get(b, attr, &val);
	if (ret)
		return ret;
	return val;
}


/**
 * It gets the acquisition status of a TDC channel
 * @param[in] userb TDC board instance token
 * @param[in] channel channel to which we want read the status
 * @return the acquisition status (0 disabled, 1 enabled), otherwise -1 and
 *         errno is set appropriately
 */
int fmctdc_channel_status_get(struct fmctdc_board *userb, unsigned int channel)
{
	__define_board(b, userb);
	uint32_t val;
	char attr[64];
	int ret;

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(attr, sizeof(attr), "ft-ch%u/enable", channel + 1);

	ret = fmctdc_sysfs_get(b, attr, &val);
	if (ret)
		return ret;
	return val;
}


/**
 * The function enables/disables timestamp acquisition for the given channel.
 * @param[in] userb TDC board instance token
 * @param[in] channel channel to which we want change status
 * @param[in] status enable status to set
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_channel_status_set(struct fmctdc_board *userb, unsigned int channel,
			      enum fmctdc_channel_status status)
{
	__define_board(b, userb);
	uint32_t val = status;
	char attr[64];

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(attr, sizeof(attr), "ft-ch%u/enable", channel + 1);

	return fmctdc_sysfs_set(b, attr, &val);
}

/**
 * It enables a given channel.
 * NOTE: it is just a wrapper of fmctdc_channel_status_set()
 * @param[in] userb TDC board instance token
 * @param[in] channel channel to which we want change status
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_channel_enable(struct fmctdc_board *userb, unsigned int channel)
{
	return fmctdc_channel_status_set(userb, channel, FMCTDC_STATUS_ENABLE);
}

/**
 * It disable a given channel.
 * NOTE: it is just a wrapper of fmctdc_channel_status_set()
 * @param[in] userb TDC board instance token
 * @param[in] channel channel to which we want change status
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_channel_disable(struct fmctdc_board *userb, unsigned int channel)
{
	return fmctdc_channel_status_set(userb, channel, FMCTDC_STATUS_DISABLE);
}

/**
 * The function sets the buffer type for a channel
 * @param[in] userb TDC board instance token
 * @param[in] ch to use
 * @param[in] type buffer type to use
 * @return 0 on success, otherwise a negative errno code is set
 *         appropriately
 */
static int fmctdc_set_buffer_type_chan(struct fmctdc_board *userb,
				       unsigned int ch,
				       enum fmctdc_buffer_type type)
{
	struct __fmctdc_board *b = (struct __fmctdc_board *)userb;
	char path[128];
	int fd;
	int ret;

	snprintf(path, sizeof(path),
		 "%s/ft-ch%u/current_buffer", b->sysbase, ch + 1);
	fd = open(path, O_WRONLY);
	if (!fd)
		return -1;
	switch (type) {
	case FMCTDC_BUFFER_KMALLOC:
		ret = write(fd, "kmalloc", 7);
		break;
	case FMCTDC_BUFFER_VMALLOC:
		ret = write(fd, "vmalloc", 7);
		break;
	default:
		ret = -1;
		break;
	}
	close(fd);

	return ret != 7 ? -1 : 0;
}

static int fmctdc_get_buffer_type_chan(struct fmctdc_board *userb,
				       unsigned int ch,
				       enum fmctdc_buffer_type *type)
{
	struct __fmctdc_board *b = (struct __fmctdc_board *)userb;
	char path[128];
	char buffer_type[8];
	int fd;
	int ret;

	snprintf(path, sizeof(path),
		 "%s/ft-ch%u/current_buffer", b->sysbase, ch + 1);
	fd = open(path, O_RDONLY);
	if (!fd)
		return -1;
	ret = read(fd, buffer_type, sizeof(buffer_type));
	close(fd);
	if (ret < 0)
		return -1;

	if (strncmp("kmalloc", buffer_type, 7) == 0) {
		*type = FMCTDC_BUFFER_KMALLOC;
	} else if (strncmp("vmalloc", buffer_type, 7) == 0) {
		*type = FMCTDC_BUFFER_VMALLOC;
	} else {
		errno = FMCTDC_ERR_UNKNOWN_BUFFER_TYPE;
		return -1;
	}

	return 0;
}


/**
 * The function sets the buffer type for a device
 * @param[in] userb TDC board instance token
 * @param[in] type buffer type to use
 * @return 0 on success, otherwise a negative errno code is set
 *         appropriately
 */
int fmctdc_set_buffer_type(struct fmctdc_board *userb,
			   enum fmctdc_buffer_type type)
{
	int i;
	int err = 0;

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		err = fmctdc_set_buffer_type_chan(userb, i, type);
		if (err) {
			errno = FMCTDC_ERR_NOT_CONSISTENT_BUFFER_TYPE;
			break;
		}
	}

	return err;
}


/**
 * The function returns current buffer type: 0 for kmallo, 1 for vmalloc.
 * @param[in] userb TDC board instance token
 * @return buffer type, otherwise a negative errno code is set
 *         appropriately
 */
int fmctdc_get_buffer_type(struct fmctdc_board *userb)
{
	int i;
	int err = 0;
	enum fmctdc_buffer_type type_prev =  -1, type_cur;

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		err = fmctdc_get_buffer_type_chan(userb, i, &type_cur);
		if (err) {
			errno = FMCTDC_ERR_NOT_CONSISTENT_BUFFER_TYPE;
			break;
		}

		if (i == 0) {
			type_prev = type_cur;
			continue;
		}
		if (type_prev != type_cur) {
			/* There are channels with a different configuration */
			err = -1;
			errno = FMCTDC_ERR_NOT_CONSISTENT_BUFFER_TYPE;
			break;
		}
		type_prev = type_cur;
	}

	return err ? err : type_prev;
}

/**
 * The function returns current buffer mode: 0 for FIFO, 1 for circular buffer.
 * @param[in] userb TDC board instance token
 * @param[in] channel to use
 * @return buffer mode, otherwise a negative errno code is set
 *         appropriately
 */
int fmctdc_get_buffer_mode(struct fmctdc_board *userb, unsigned int channel)
{
	__define_board(b, userb);
	uint32_t val;
	char attr[64];
	int ret;

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(attr, sizeof(attr), "ft-ch%u/chan0/buffer/prefer-new",
		 channel + 1);

	ret = fmctdc_sysfs_get(b, attr, &val);
	if (ret)
		return ret;
	return val;
}

/**
 * The function sets the buffer mode for a channel
 * @param[in] userb TDC board instance token
 * @param[in] channel to use
 * @param[in] mode buffer mode to use
 * @return 0 on success, otherwise a negative errno code is set
 *         appropriately
 */
int fmctdc_set_buffer_mode(struct fmctdc_board *userb, unsigned int channel,
			   enum fmctdc_buffer_mode mode)
{
	__define_board(b, userb);
	uint32_t val;
	char attr[64];

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(attr, sizeof(attr), "ft-ch%u/chan0/buffer/prefer-new",
		 channel + 1);

	val = mode;
	return fmctdc_sysfs_set(b, attr, &val);
}

/**
 * The function returns current driver buffer length (number of timestamps)
 * @param[in] userb TDC board instance token
 * @param[in] channel to use
 * @return buffer lenght, otherwise a negative errno code is set
 *         appropriately
 */
int fmctdc_get_buffer_len(struct fmctdc_board *userb, unsigned int channel)
{
	__define_board(b, userb);
	uint32_t val;
	char attr[64];
	int ret;
	char path[64];

	snprintf(path, sizeof(path), "%s/ft-ch%u/chan0/buffer/max-buffer-kb",
		 b->sysbase, channel + 1);
	if (access(path, R_OK | W_OK)) {
		errno = FMCTDC_ERR_VMALLOC;
		return -1;
	}

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(attr, sizeof(attr), "ft-ch%u/chan0/buffer/max-buffer-kb",
		 channel + 1);

	ret = fmctdc_sysfs_get(b, attr, &val);
	if (ret)
		return ret;

	val = (val * 1024) / sizeof(struct ft_hw_timestamp);

	return val;
}

/**
 * The function set the buffer length
 * @param[in] userb TDC board instance token
 * @param[in] channel to use
 * @param[in] length maximum number of timestamps to store (min: 64)
 * @return 0 on success, otherwise a negative errno code is set
 *         appropriately
 *
 * Internally, the buffer allocates memory in chunks of minimun 1KiB. This
 * means, for example, that if you ask for 65 timestamp the buffer will
 * allocate space for 128. This because 64 timestamps fit in 1KiB, to store
 * 65 we need 2KiB (128 timestamps).
 *
 * NOTE: it works only with the VMALLOC allocator.
 */
int fmctdc_set_buffer_len(struct fmctdc_board *userb, unsigned int channel,
			  unsigned int length)
{
	__define_board(b, userb);
	uint32_t val;
	char attr[64];
	char path[128];

	snprintf(path, sizeof(path), "%s/ft-ch%u/chan0/buffer/max-buffer-kb",
		 b->sysbase, channel + 1);
	if (access(path, R_OK | W_OK)) {
		errno = FMCTDC_ERR_VMALLOC;
		return -1;
	}

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}
	if (length < 64) {
		errno = EINVAL;
		return -1;
	}

	snprintf(attr, sizeof(attr), "ft-ch%u/chan0/buffer/max-buffer-kb",
		 channel + 1);

	val = ((length * sizeof(struct ft_hw_timestamp)) / 1024) + 1;
	return fmctdc_sysfs_set(b, attr, &val);
}


/**
 * It get the file descriptor of a TDC channel. So, for example, you can
 * poll(2) and select(2).
 * Note that, the file descriptor is the file-descriptor of a
 * ZIO control char-device.
 * @param[in] userb TDC board instance token
 * @param[in] channel channel to use
 * @return a file descriptor, otherwise -1 and errno is set appropriately
 */
int fmctdc_fileno_channel(struct fmctdc_board *userb, unsigned int channel)
{
	__define_board(b, userb);

	return b->fdc[channel];
}

static void fmctdc_ts_convert(struct fmctdc_time *t, struct ft_hw_timestamp *o)
{
	t->seconds = o->seconds;
	t->coarse = o->coarse;
	t->frac = o->frac & 0xfff;
	t->debug = o->metadata;
	t->seq_id = FT_HW_TS_META_SEQ(o->metadata);
}

static void fmctdc_ts_convert_n(struct fmctdc_time *t,
				struct ft_hw_timestamp *o,
				unsigned int n)
{
	int i;

	for (i = 0; i < n; ++i)
		fmctdc_ts_convert(&t[i], &o[i]);
}

/**
 * It reads up to *max* timestamps from the buffer
 * @param[in] userb TDC board instance token
 * @param[in] channel channel to use [0, 4]
 * @param[out] t array of time-stamps
 * @param[in] max maximum number of elements to save in the array
 * @return the number of samples read
 */
static int __fmctdc_read(struct fmctdc_board *userb, unsigned int channel,
			 struct fmctdc_time *t, int max)
{
	__define_board(b, userb);
	struct ft_hw_timestamp *data;
	int n;

	data = calloc(max, sizeof(*data));
	if (!data) {
		errno = ENOMEM;
		return -1;
	}

	n = read(b->fdd[channel], data, sizeof(*data) * max);
	if (n < 0)
		goto err;
	if (n % sizeof(*data) != 0) {
		errno = EIO;
		goto err;
	}

	n /= sizeof(*data); /* convert to number of samples */
	fmctdc_ts_convert_n(t, data, n);
	free(data);

	return n;

err:
	free(data);
	return -1;
}

/**
 * It reads a given number of time-stamps from the driver. It will wait at
 * most once and return the number of samples that it received from a given
 * input channel.
 *
 * Timestamps are to the base time.
 *
 * This "read" behaves like the system call and obeys O_NONBLOCK
 * @param[in] userb TDC board instance token
 * @param[in] channel channel to use [0, 4]
 * @param[out] t array of time-stamps
 * @param[in] n number of elements to save in the array
 * @param[in] flags tune the behaviour of the function.
 *                      O_NONBLOCK - do not block
 * @return number of acquired time-stamps, otherwise -1 and errno is set
 *         appropriately.
 *         - EINVAL for invalid arguments
 *         - EIO for invalid IO transfer
 *         - EAGAIN if nothing ready to read in NONBLOCK mode
 */
int fmctdc_read(struct fmctdc_board *userb, unsigned int channel,
		struct fmctdc_time *t, int n, int flags)
{
	__define_board(b, userb);
	int i;
	fd_set set;

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	i = 0;
	while (i < n) {
		int n_ts = __fmctdc_read(userb, channel, &t[i], 1);

		if (n_ts < 0 && errno != EAGAIN) {
			if (i == 0)
				return -1;
			else
				break;
		}

		if (n_ts > 0) {
			i += n_ts;
			continue;
		}

		if (i) /* error but before we got something */
			break;

		/* EAGAIN at first sample */
		if (n_ts < 0 && flags == O_NONBLOCK)
			return -1;

		/* So, first sample and blocking read. Wait.. */
		FD_ZERO(&set);
		FD_SET(b->fdc[channel], &set);
		if (select(b->fdc[channel] + 1, &set, NULL, NULL, NULL) < 0)
			return -1;
	}

	return i;
}


/**
 * this "fread" behaves like stdio: it reads all the samples. Read fmctdc_read()
 * for more details about the function.
 * @param[in] userb TDC board instance token
 * @param[in] channel channel to use
 * @param[out] t array of time-stamps
 * @param[in] n number of elements to save in the array
 * @return number of acquired time-stamps, otherwise -1 and errno is set
 *         appropriately
 */
int fmctdc_fread(struct fmctdc_board *userb, unsigned int channel,
		 struct fmctdc_time *t, int n)
{
	int i;

	for (i = 0; i < n;) {
		int loop = fmctdc_read(userb, channel, t + i, n - i, 0);
		if (loop < 0)
			return -1;
		i += loop;
	}
	return i;
}


/**
 * It sets the TDC base-time according to the given time-stamp.
 * Note that, for the time being, it sets only seconds.
 * Note that, you can set the time only when the acquisition is disabled.
 * @param[in] userb TDC board instance token
 * @param[in] t time-stamp
 * @return 0 on success, otherwise -1 and errno is set
 */
int fmctdc_set_time(struct fmctdc_board *userb, const struct fmctdc_time *t)
{
	__define_board(b, userb);
	uint32_t attrs[ARRAY_SIZE(names)];
	int i;

	attrs[0] = t->seconds & 0xffffffff;
	attrs[1] = t->coarse;

	for (i = ARRAY_SIZE(names) - 1; i >= 0; i--) {
		int ret = fmctdc_sysfs_set(b, names[i], attrs + i);
		if (ret < 0)
			return ret;
	}
	return 0;
}


/**
 * It gets the base-time of a TDC device.
 * Note that, for the time being, it gets only seconds.
 * @param[in] userb TDC board instance token
 * @param[out] t time-stamp
 * @return 0 on success, otherwise -1 and errno is set
 */
int fmctdc_get_time(struct fmctdc_board *userb, struct fmctdc_time *t)
{
	__define_board(b, userb);
	uint32_t attrs[ARRAY_SIZE(names)];
	int i;

	for (i = 0; i < ARRAY_SIZE(names); i++) {
		int ret = fmctdc_sysfs_get(b, names[i], attrs + i);
		if (ret < 0)
			return ret;
	}

	t->seconds = attrs[0];
	t->coarse = attrs[1];
	t->frac = 0;

	return 0;
}


/**
 * It sets the TDC base-time according to the host time
 * @param[in] userb TDC board instance token
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_set_host_time(struct fmctdc_board *userb)
{
	__define_board(b, userb);

	return __fmctdc_command(b, FT_CMD_SET_HOST_TIME);
}


/**
 * It enables/disables the WhiteRabbit timing system on a TDC device
 * @param[in] userb TDC board instance token
 * @param[in] on white-rabbit status to set
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_wr_mode(struct fmctdc_board *userb, int on)
{
	__define_board(b, userb);

	return __fmctdc_command(b, on ? FT_CMD_WR_ENABLE : FT_CMD_WR_DISABLE);
}


/**
 * It check the current status of the WhiteRabbit timing system on a TDC device
 * @param[in] userb TDC board instance token
 * @return 0 if it properly works, -1 on error and errno is set appropriately.
 *         - ENOLINK if it is not synchronized and
 *         - ENODEV if it is not enabled
 */
extern int fmctdc_check_wr_mode(struct fmctdc_board *userb)
{
	__define_board(b, userb);

	if (__fmctdc_command(b, FT_CMD_WR_QUERY) == 0)
		return 0;
	return -1;
}

/**
 * It removes all samples from the channel buffer. In order to doing this,
 * the function temporary disable any active acquisition, only when the flush
 * is completed the acquisition will be re-enabled
 * @param[in] userb TDC board instance token
 * @param[in] channel target channel [0, 4]
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_flush(struct fmctdc_board *userb, unsigned int channel)
{
	struct __fmctdc_board *b = (void *)(userb);
	int en, err;
	uint32_t val = 1;

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}
	en = fmctdc_channel_status_get(userb, channel);
	if (en < 0)
		return -1;

	/* Disable acquisition, it will flush the hw buffer */
	err = fmctdc_channel_status_set(userb, channel, FMCTDC_STATUS_DISABLE);
	if (err)
		return err;

	if (1) {
		/*
		 * For some reason the ZIO flush attribute does not work.
		 * I do not have time to investigate it. Flush it by reading
		 */
		struct fmctdc_time ts[100];
		int n;

		do {
			n = fmctdc_read(userb, channel, ts, 100, O_NONBLOCK);
		} while (n > 0);
	} else {
		char path[64];

		/* Flush ZIO buffer */
		snprintf(path, sizeof(path),
			 "ft-ch%u/chan0/buffer/flush",
			 channel + 1);
		err = fmctdc_sysfs_set(b, path, &val);
		if (err)
			return err;
	}

	/* Re-enable if it was enable */
	return fmctdc_channel_status_set(userb, channel, en);
}

/**
 * It sets the user offset to be applied on incoming timestamps. All the
 * timestamps read from the driver (this means also from this library) will
 * be already corrected using this offset.
 * @param[in] userb TDC board instance token
 * @param[in] channel target channel [0, 4]
 * @param[in] offset the number of pico-seconds to be added
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_set_offset_user(struct fmctdc_board *userb,
			   unsigned int channel, int32_t offset)
{
	__define_board(b, userb);
	uint32_t val = (uint32_t)offset;
	char attr[64];

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(attr, sizeof(attr), "ft-ch%u/user-offset", channel + 1);

	return fmctdc_sysfs_set(b, attr, &val);
}


/**
 * It get the current user offset applied to the incoming timestamps
 * @param[in] userb TDC board instance token
 * @param[in] channel target channel [0, 4]
 * @param[out] offset the number of pico-seconds to be added
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_get_offset_user(struct fmctdc_board *userb,
			   unsigned int channel, int32_t *offset)
{
	struct __fmctdc_board *b = (void *)(userb);
	uint32_t val;
	char path[64];
	int err;

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}
	snprintf(path, sizeof(path), "ft-ch%u/user-offset", channel + 1);
	err = fmctdc_sysfs_get(b, path, &val);
	if (err)
		return -1;

	*offset = (int32_t)val;
	return 0;
}

/**
 * It gets the current transfer mode
 * @param[in] userb TDC board instance token
 * @param[out] mode transfer mode
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_transfer_mode(struct fmctdc_board *userb,
			 enum ft_transfer_mode *mode)
{
	struct __fmctdc_board *b = (void *)(userb);
	uint32_t val;
	int err;

	err = fmctdc_sysfs_get(b, "transfer-mode", &val);
	if (err)
		return -1;

	*mode = val;
	return 0;
}

/**
 * It sets the coalescing timeout on a given channel
 * @param[in] userb TDC board instance token
 * @param[in] channel target channel [0, 4]
 * @param[in] timeout_ms ms timeout to trigger IRQ
 * @return 0 on success, otherwise -1 and errno is set appropriately
 *
 * It does not work per-channel for the following acquisition mechanism:
 * - FIFO (it will return the global IRQ coalescing timeout)
 */
int fmctdc_coalescing_timeout_set(struct fmctdc_board *userb,
				  unsigned int channel,
				  unsigned int timeout_ms)
{
	struct __fmctdc_board *b = (void *)(userb);
	char path[64];
	uint32_t val = timeout_ms;

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(path, sizeof(path), "ft-ch%u/irq_coalescing_time",
		 channel + 1);
	return fmctdc_sysfs_set(b, path, &val);
}

/**
 * It gets the coalescing timeout from a given channel
 * @param[in] userb TDC board instance token
 * @param[in] channel target channel [0, 4]
 * @param[out] timeout_ms ms timeout to trigger IRQ
 * @return 0 on success, otherwise -1 and errno is set appropriately
 *
 * It does not work per-channel for the following acuqisition mechanism:
 * - FIFO: there is a global configuration for all channels
 */
int fmctdc_coalescing_timeout_get(struct fmctdc_board *userb,
				  unsigned int channel,
				  unsigned int *timeout_ms)
{
	struct __fmctdc_board *b = (void *)(userb);
	char path[64];
	uint32_t val;
	int err;

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(path, sizeof(path), "ft-ch%u/irq_coalescing_time",
		 channel + 1);
	err = fmctdc_sysfs_get(b, path, &val);
	if (err)
		return -1;

	*timeout_ms = val;

	return 0;
}

/**
 * It sets the timestamp mode
 * @param[in] userb TDC board instance token
 * @param[in] channel target channel [0, 4]
 * @param[in] mode time-stamp mode
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_ts_mode_set(struct fmctdc_board *userb,
		       unsigned int channel,
		       enum fmctdc_ts_mode mode)
{
	struct __fmctdc_board *b = (void *)(userb);
	char path[64];

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(path, sizeof(path), "ft-ch%u/raw_readout_mode",
		 channel + 1);
	return fmctdc_sysfs_set(b, path, &mode);
}

/**
 * It gets the timestamp mode
 * @param[in] userb TDC board instance token
 * @param[in] channel target channel [0, 4]
 * @param[out] mode time-stamp mode
 * @return 0 on success, otherwise -1 and errno is set appropriately
 *
 */
int fmctdc_ts_mode_get(struct fmctdc_board *userb,
		       unsigned int channel,
		       enum fmctdc_ts_mode *mode)
{
	struct __fmctdc_board *b = (void *)(userb);
	char path[64];
	uint32_t val;
	int err;

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(path, sizeof(path), "ft-ch%u/raw_readout_mode",
		 channel + 1);
	err = fmctdc_sysfs_get(b, path, &val);
	if (err)
		return -1;

	*mode = val;

	return 0;
}

/**
 * It gets the number of received pulses (on hardware)
 * @param[in] userb TDC board instance token
 * @param[in] channel target channel [0, 4]
 * @param[out] val number of received pulses
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_stats_recv_get(struct fmctdc_board *userb,
			  unsigned int channel,
			  uint32_t *val)
{
	struct __fmctdc_board *b = (void *)(userb);
	char path[64];

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(path, sizeof(path), "ft-ch%u/received",
		 channel + 1);
	return fmctdc_sysfs_get(b, path, val);
}

/**
 * It gets the number of transferred timestamps
 * @param[in] userb TDC board instance token
 * @param[in] channel target channel [0, 4]
 * @param[out] val number of transferred timestamps
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_stats_trans_get(struct fmctdc_board *userb,
			  unsigned int channel,
			  uint32_t *val)
{
	struct __fmctdc_board *b = (void *)(userb);
	char path[64];

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}

	snprintf(path, sizeof(path), "ft-ch%u/transferred",
		 channel + 1);
	return fmctdc_sysfs_get(b, path, val);
}
