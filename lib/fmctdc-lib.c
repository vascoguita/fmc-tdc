/*
 * The fmc-tdc (a.k.a. FmcTdc1ns5cha) library.
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
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <glob.h>
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

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

static struct __fmctdc_board *ft_boards; /**< list of available boards */
static int ft_nboards; /**< number of available boards */
static char *names[] = { "seconds", "coarse" }; /**< names used to retrive
						   time-stamps from sysfs */

/**
 * It returns the error message associated to the given error code
 */
char *fmctdc_strerror(int err)
{
	return strerror(err);
}


/**
 * Init the library. You must call this function before use any other
 * library function
 * @return the number of boards found
 */
int fmctdc_init(void)
{
	glob_t glob_dev, glob_sys;
	struct __fmctdc_board *b;
	int i, j;
	uint32_t v;

	/* Look for boards in /dev: old and new pathnames: only one matches */
	glob("/dev/tdc-1n5c-*-0-0-ctrl", 0, NULL, &glob_dev);
	glob("/dev/zio/tdc-1n5c-*-0-0-ctrl", GLOB_APPEND, NULL, &glob_dev);
	glob("/dev/zio-tdc-1n5c-*-0-0-ctrl", GLOB_APPEND, NULL, &glob_dev);
	glob("/dev/zio/zio-tdc-1n5c-*-0-0-ctrl", GLOB_APPEND, NULL, &glob_dev);

	/* And look in /sys as well */
	glob("/sys/bus/zio/devices/tdc-1n5c-*", 0, NULL, &glob_sys);
	glob("/sys/bus/zio/devices/zio-tdc-1n5c-*", GLOB_APPEND, NULL, &glob_sys);
	assert(glob_dev.gl_pathc == glob_sys.gl_pathc);

	/* Allocate as needed */
	ft_nboards = glob_dev.gl_pathc;
	if (!ft_nboards) {
		ft_boards = NULL;
		return 0;
	}
	ft_boards = calloc(glob_dev.gl_pathc, sizeof(ft_boards[0]));
	if (!ft_boards) {
		globfree(&glob_dev);
		globfree(&glob_sys);
		return -1;
	}

	for (i = 0, b = ft_boards; i < ft_nboards; i++, b++) {
		b->sysbase = strdup(glob_sys.gl_pathv[i]);
		b->devbase = strdup(glob_dev.gl_pathv[i]);
		/* trim the "-0-0-ctrl" at the end */
		b->devbase[strlen(b->devbase) - strlen("-0-0-ctrl")] = '\0';
		/* extract dev_id */
		sscanf(b->sysbase, "%*[^t]tdc-1n5c-%x", &b->dev_id);
		for (j = 0; j < ARRAY_SIZE(b->fdc); j++) {
			b->fdc[j] = -1;
			b->fdd[j] = -1;
		}
		if (fmctdc_is_verbose()) {
			fprintf(stderr, "%s: %04x %s %s\n", __func__,
				b->dev_id, b->sysbase, b->devbase);
		}
	}
	globfree(&glob_dev);
	globfree(&glob_sys);

	/* Now, if at least one board is there, check the version */
	if (ft_nboards == 0)
		return 0;

	if (fmctdc_sysfs_get(ft_boards, "version", &v) < 0)
		return -1;

	if (v != FT_VERSION_MAJ) {
		fprintf(stderr, "%s: version mismatch, lib(%i) != drv(%i)\n",
			__func__, FT_VERSION_MAJ, v);
		errno = EIO;
		return -1;
	}
	return ft_nboards;
}


/**
 * It releases all the resources used by the library. Once you call this
 * function you cannot use other function from this library.
 */
void fmctdc_exit(void)
{
	struct __fmctdc_board *b;
	int i, j, err;

	for (i = 0, err = 0, b = ft_boards; i < ft_nboards; i++, b++) {
		for (j = 0; j < ARRAY_SIZE(b->fdc); j++) {
			if (b->fdc[j] >= 0) {
				close(b->fdc[j]);
				b->fdc[j] = -1;
				err++;
			}
			if (b->fdd[j] >= 0) {
				close(b->fdd[j]);
				b->fdd[j] = -1;
				err++;
			}
		}
		if (err)
			fprintf(stderr, "%s: device %s was still open\n",
				__func__, b->devbase);
		free(b->sysbase);
		free(b->devbase);
	}
	if (ft_nboards)
		free(ft_boards);
}


/**
 * It opens one specific device. -1 arguments mean "not installed"
 * @param[in] offset board enumeration offset [0, N]. -1 to ignore it and
 *                   use dev_id
 * @param[in] dev_id FMC device id. 0 to ignore it and use only the offset
 * @return an instance token, otherwise NULL and errno is appripriately set
 */
struct fmctdc_board *fmctdc_open(int offset, int dev_id)
{
	struct __fmctdc_board *b = NULL;
	uint32_t nsamples = 1;
	int i;

	if (offset >= ft_nboards) {
		errno = ENODEV;
		return NULL;
	}
	if (offset >= 0) {
		b = ft_boards + offset;
		if (dev_id >= 0 && dev_id != b->dev_id) {
			errno = EINVAL;
			return NULL;
		}
		goto found;
	}
	if (dev_id < 0) {
		errno = EINVAL;
		return NULL;
	}
	for (i = 0, b = ft_boards; i < ft_nboards; i++, b++)
		if (b->dev_id == dev_id)
			goto found;
	errno = ENODEV;
	return NULL;

found:
	/* Trim all block sizes to 1 sample (i.e. 4 bytes) */
	fmctdc_sysfs_set(b, "ft-ch1/trigger/post-samples", &nsamples);
	fmctdc_sysfs_set(b, "ft-ch2/trigger/post-samples", &nsamples);
	fmctdc_sysfs_set(b, "ft-ch3/trigger/post-samples", &nsamples);
	fmctdc_sysfs_set(b, "ft-ch4/trigger/post-samples", &nsamples);
	fmctdc_sysfs_set(b, "ft-ch5/trigger/post-samples", &nsamples);

	return (void *)b;
}


/**
 * It opens one specific device by logical unit number (CERN/CO-like)
 * @param[in] lun Logical Unit Number
 * @return an instance token, otherwise NULL and errno is appripriately set
 */
struct fmctdc_board *fmctdc_open_by_lun(int lun)
{
	ssize_t ret;
	char dev_id_str[4];
	char path_pattern[] = "/dev/fmc-tdc.%d";
	char path[sizeof(path_pattern) + 1];
	int dev_id;

	ret = snprintf(path, sizeof(path), path_pattern, lun);
	if (ret < 0 || ret >= sizeof(path)) {
		errno = EINVAL;
		return NULL;
	}
	ret = readlink(path, dev_id_str, sizeof(dev_id_str));
	if (sscanf(dev_id_str, "%4x", &dev_id) != 1) {
		errno = ENODEV;
		return NULL;
	}
	return fmctdc_open(-1, dev_id);
}


/**
 * It closes a TDC instance
 * @param[in] userb TDC board instance token
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_close(struct fmctdc_board *userb)
{
	__define_board(b, userb);
	int j;

	for (j = 0; j < ARRAY_SIZE(b->fdc); j++) {
		if (b->fdc[j] >= 0)
			close(b->fdc[j]);
		b->fdc[j] = -1;
		if (b->fdd[j] >= 0)
			close(b->fdd[j]);
		b->fdd[j] = -1;
	}
	return 0;

}


/**
 * It reads the current temperature of the TDC
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
 * It enables/disables the channel termination
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

	if (channel >= FMCTDC_NUM_CHANNELS)
		return -EINVAL;

	snprintf(attr, sizeof(attr), "ft-ch%d/termination", channel);

	val = on ? 1 : 0;
	return fmctdc_sysfs_set(b, attr, &val);
}


/**
 * It returns the current status of a channel termination
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

	if (channel >= FMCTDC_NUM_CHANNELS)
		return -EINVAL;

	snprintf(attr, sizeof(attr), "ft-ch%d/termination", channel);

	ret = fmctdc_sysfs_get(b, attr, &val);
	if (ret)
		return ret;
	return val;
}


/**
 * It gets the acquisition status of the board
 * @param[in] userb TDC board instance token
 * @return the acquisition status, otherwise -1 and errno is set appropriately
 */
int fmctdc_get_acquisition(struct fmctdc_board *userb)
{
	__define_board(b, userb);
	uint32_t val;
	int ret;

	ret = fmctdc_sysfs_get(b, "enable_inputs", &val);
	if (ret)
		return ret;
	return val;
}


/**
 * It sets the acquisition status of the board
 * @param[in] userb TDC board instance token
 * @param[in] on acquisition status to set
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_set_acquisition(struct fmctdc_board *userb, int on)
{
	__define_board(b, userb);
	uint32_t val;

	val = on ? 1 : 0;
	return fmctdc_sysfs_set(b, "enable_inputs", &val);
}


/**
 * It opens the zio control channel of a TDC board
 * @param[in] b TDC board instance token
 * @param[in] channel channel to open
 * @return a file descriptor, otherwise -1 and errno is set appropriately
 */
static int __fmctdc_open_channel(struct __fmctdc_board *b, unsigned int channel)
{
	char fname[128];
	if (b->fdc[channel - 1] <= 0) {
		snprintf(fname, sizeof(fname), "%s-%d-0-ctrl", b->devbase,
			 channel - 1);
		b->fdc[channel - 1] = open(fname, O_RDONLY | O_NONBLOCK);
	}
	return b->fdc[channel - 1];
}


/**
 * It get the file descriptor of a board channel
 * @param[in] userb TDC board instance token
 * @param[in] channel channel to use
 * @return a file descriptor, otherwise -1 and errno is set appropriately
 */
int fmctdc_fileno_channel(struct fmctdc_board *userb, unsigned int channel)
{
	__define_board(b, userb);
	return __fmctdc_open_channel(b, channel);
}


/**
 * this "read" behaves like the system call and obeys O_NONBLOCK
 * @param[in] userb TDC board instance token
 * @param[in] channel channel to use
 * @param[out] t array of time-stamps
 * @param[in] n number of elements to save in the array
 * @param[in] flags tune the behaviour of the function.
 *                      O_NONBLOCK - do not block
 * @return number of acquired time-stamps, otherwise -1 and errno is set
 *         appropriately
 */
int fmctdc_read(struct fmctdc_board *userb, unsigned int channel,
		struct fmctdc_time *t, int n, int flags)
{
	__define_board(b, userb);
	struct zio_control ctrl;
	uint32_t *attrs;
	int i, j, fd;
	fd_set set;

	if (channel >= FMCTDC_NUM_CHANNELS)
		return -EINVAL;

	fd = __fmctdc_open_channel(b, channel);
	if (fd < 0)
		return fd;	/* errno already set */

	for (i = 0; i < n;) {
		j = read(fd, &ctrl, sizeof(ctrl));
		if (j < 0 && errno != EAGAIN)
			return -1;
		if (j == sizeof(ctrl)) {
			/* one sample: pick it */
			attrs = ctrl.attr_channel.ext_val;
			t->seconds = ctrl.tstamp.secs;
			t->coarse = ctrl.tstamp.ticks;
			t->frac = ctrl.tstamp.bins;
			t->seq_id = ctrl.seq_num;
			t->gseq_id = attrs[FT_ATTR_DEV_SEQUENCE];
			t->ref_gseq_id = attrs[FT_ATTR_TDC_DELAY_REF_SEQ];
			i++;
			continue;
		}
		if (j > 0) {
			errno = EIO;
			return -1;
		}
		/* so, it's EAGAIN: if we already got something, we are done */
		if (i)
			return i;
		/* EAGAIN at first sample */
		if (j < 0 && flags == O_NONBLOCK)
			return -1;

		/* So, first sample and blocking read. Wait.. */
		FD_ZERO(&set);
		FD_SET(fd, &set);
		if (select(fd + 1, &set, NULL, NULL, NULL) < 0)
			return -1;
		continue;
	}
	return i;
}

/**
 * this "fread" behaves like stdio: it reads all the samples
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
	int i, loop;

	for (i = 0; i < n;) {
		loop = fmctdc_read(userb, channel, t + i, n - i, 0);
		if (loop < 0)
			return -1;
		i += loop;
	}
	return i;
}


/**
 * It sets the board time according to the given time-stamp
 * @param[in] userb TDC board instance token
 * @param[in] t time-stamp
 * @return 0 on success, otherwise -1 and errno is set
 */
int fmctdc_set_time(struct fmctdc_board *userb, struct fmctdc_time *t)
{
	__define_board(b, userb);
	uint32_t attrs[ARRAY_SIZE(names)];
	int i, ret;

	attrs[0] = t->seconds & 0xffffffff;
	attrs[1] = t->coarse;

	for (i = ARRAY_SIZE(names) - 1; i >= 0; i--) {
		ret = fmctdc_sysfs_set(b, names[i], attrs + i);
		if (ret < 0)
			return ret;
	}
	return 0;
}


/**
 * It gets the boar time
 * @param[in] userb TDC board instance token
 * @param[out] t time-stamp
 * @return 0 on success, otherwise -1 and errno is set
 */
int fmctdc_get_time(struct fmctdc_board *userb, struct fmctdc_time *t)
{
	__define_board(b, userb);
	uint32_t attrs[ARRAY_SIZE(names)];
	int i, ret;

	for (i = 0; i < ARRAY_SIZE(names); i++) {
		ret = fmctdc_sysfs_get(b, names[i], attrs + i);
		if (ret < 0)
			return ret;
	}

	t->seconds = attrs[0];
	t->coarse = attrs[1];
	t->frac = 0;

	return 0;
}


/**
 * It sets the board time to the host time
 * @param[in] userb TDC board instance token
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_set_host_time(struct fmctdc_board *userb)
{
	__define_board(b, userb);
	return __fmctdc_command(b, FT_CMD_SET_HOST_TIME);
}


/**
 * It enables/disables the WhiteRabbit timing system
 * @param[in] userb TDC board instance token
 * @param[in] on white-rabbit status to set
 * @return 0 on success, otherwise an error code
 */
int fmctdc_wr_mode(struct fmctdc_board *userb, int on)
{
	__define_board(b, userb);
	if (on)
		__fmctdc_command(b, FT_CMD_WR_ENABLE);
	else
		__fmctdc_command(b, FT_CMD_WR_DISABLE);
	return errno;
}


/**
 * It check the current status of the WhiteRabbit timing system
 * @param[in] userb TDC board instance token
 * @return 0 if it properly works, -ENOLINK if it is not synchronized and
 *         -ENODEV if it is not enabled
 */
extern int fmctdc_check_wr_mode(struct fmctdc_board *userb)
{
	__define_board(b, userb);
	if (__fmctdc_command(b, FT_CMD_WR_QUERY) == 0)
		return 0;
	return errno;
}


/**
 * It assigns a time reference to a target channel. After you set a reference,
 * you will read (from the target channel) the time-stamp difference between
 * the last reference pulse and the target.
 * @param[in] userb TDC board instance token
 * @param[in] ch_target target channel [1, 5]
 * @param[in] ch_reference reference channel [0, 5]. Use 0 to remove reference
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_reference_set(struct fmctdc_board *userb,
			 unsigned int ch_target, int ch_reference)
{
	struct __fmctdc_board *b = (void *)(userb);
	char path[64];

	if (ch_target > FMCTDC_NUM_CHANNELS || ch_target <= 0 ) {
		errno = EINVAL;
		return -1;
	}
	snprintf(path, sizeof(path), "ft-ch%d/diff-reference", ch_target);
	return fmctdc_sysfs_set(b, path, &ch_reference);
}


/**
 * It removes all samples from the channel buffer
 * @param[in] userb TDC board instance token
 * @param[in] channel target channel [1, 5]
 * @return 0 on success, otherwise -1 and errno is set appropriately
 */
int fmctdc_flush(struct fmctdc_board *userb, unsigned int channel)
{
	struct __fmctdc_board *b = (void *)(userb);
	struct fmctdc_time t[10];
	char path[64];
	int i, en, err;

	if (channel >= FMCTDC_NUM_CHANNELS) {
		errno = EINVAL;
		return -1;
	}
	en = fmctdc_get_acquisition(userb);
	if (en < 0)
		return -1;

	/* Disable acquisition, it will flush the hw buffer */
	err = fmctdc_set_acquisition(userb, 0);
	if (err)
		return err;

	/* FIXME when TDC driver will have its zio-trigger this is not
	 * necessary anymore */
	do {
		i = fmctdc_read(userb, channel, t, 10, 0);
	} while (i > 0);

	/* Flush ZIO buffer */
	snprintf(path, sizeof(path), "ft-ch%d/chan0/buffer/flush", channel);
	err = fmctdc_sysfs_set(b, path, &channel);
	if (err) {
		return err;
	}

	/* Re-enable if it was enable */
	return fmctdc_set_acquisition(userb, en);
}
