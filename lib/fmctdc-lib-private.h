/*
 * The "official" fmc-tdc API
 *
 * Copyright (C) 2012-2018 CERN (www.cern.ch)
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

#ifndef __FMCTDC_LIB_PRIVATE_H__
#define __FMCTDC_LIB_PRIVATE_H__
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <fmc-tdc.h>

/* Internal structure */
struct __fmctdc_board {
	int dev_id;
	char *devbase;
	char *sysbase;
	int fdcc[FMCTDC_NUM_CHANNELS]; /**< current controls */
	int fdc[5];		/* The 5 control channels */
	int fdd[5];		/* The 5 data channels */
	int ch_ref[FMCTDC_NUM_CHANNELS];  /**< reference channel */
};

static inline int fmctdc_is_verbose(void)
{
	return getenv("FMCTDC_LIB_VERBOSE") != 0;
}

#define __define_board(b, ub)	struct __fmctdc_board *b = (void *)(ub)

/* These two from ../tools/fdelay-raw.h, used internally */
static inline int __fmctdc_sysfs_get(char *path, uint32_t * resp)
{
	FILE *f = fopen(path, "r");

	if (!f)
		return -1;
	errno = 0;
	if (fscanf(f, "%u", resp) != 1) {
		fclose(f);
		if (!errno)
			errno = EINVAL;
		return -1;
	}
	fclose(f);
	return 0;
}

static inline int __fmctdc_sysfs_set(char *path, uint32_t * value)
{
	char s[16];
	int fd, ret, len;

	len = sprintf(s, "%u\n", *value);
	fd = open(path, O_WRONLY);
	if (fd < 0)
		return -1;
	ret = write(fd, s, len);
	close(fd);
	if (ret < 0)
		return -1;
	if (ret == len)
		return 0;
	errno = EINVAL;
	return -1;
}

/* And these two for the board structure */
static inline int fmctdc_sysfs_get(struct __fmctdc_board *b, char *name,
				   uint32_t * resp)
{
	char pathname[128];

	sprintf(pathname, "%s/%s", b->sysbase, name);
	return __fmctdc_sysfs_get(pathname, resp);
}

static inline int fmctdc_sysfs_set(struct __fmctdc_board *b, char *name,
				   uint32_t * value)
{
	char pathname[128];

	sprintf(pathname, "%s/%s", b->sysbase, name);
	return __fmctdc_sysfs_set(pathname, value);
}

static inline int __fmctdc_command(struct __fmctdc_board *b, uint32_t cmd)
{
	return fmctdc_sysfs_set(b, "command", &cmd);
}

#endif /* __FMCTDC_LIB_PRIVATE_H__ */
