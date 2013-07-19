/*
 * The "official" fmc-tdc API
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
#ifndef __FMCTDC_LIB_H__
#define __FMCTDC_LIB_H__

#include <stdint.h>

enum fmctdc_channel {
    FMCTDC_CH_1 = 1,
    FMCTDC_CH_2 = 2,
    FMCTDC_CH_3 = 3,
    FMCTDC_CH_4 = 4,
    FMCTDC_CH_5 = 5,
    FMCTDC_NUM_CHANNELS = 5
};

/* Opaque data type used as token */
struct fmctdc_board;

struct fmctdc_time {
	uint64_t seconds;
	uint32_t coarse;
	uint32_t frac;
	uint32_t seq_id;
};

extern int fmctdc_init(void);
extern void fmctdc_exit(void);

extern struct fmctdc_board *fmctdc_open(int offset, int dev_id);
extern struct fmctdc_board *fmctdc_open_by_lun(int lun);
extern int fmctdc_close(struct fmctdc_board *);

extern int fmctdc_set_time(struct fmctdc_board *b, struct fmctdc_time *t);
extern int fmctdc_get_time(struct fmctdc_board *b, struct fmctdc_time *t);
extern int fmctdc_set_host_time(struct fmctdc_board *b);

extern int fmctdc_set_termination(struct fmctdc_board *b, int channel, int enable);
extern int fmctdc_get_termination(struct fmctdc_board *b, int channel);

extern int fmctdc_purge_fifo(struct fmctdc_board *b, int channel);
extern int fmctdc_identify_card(struct fmctdc_board *b, int blink_led);

extern int fmctdc_fread(struct fmctdc_board *b, int channel, struct fmctdc_time *t, int n);
extern int fmctdc_fileno_channel(struct fmctdc_board *b, int channel);
extern int fmctdc_read(struct fmctdc_board *b, int channel, struct fmctdc_time *t, int n,
		       int flags);

extern int fmctdc_wr_mode(struct fmctdc_board *b, int on);
extern int fmctdc_check_wr_mode(struct fmctdc_board *b);

extern float fmctdc_read_temperature(struct fmctdc_board *b);

#ifdef FMCTDC_INTERNAL /* Libray users should ignore what follows */

#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

/* Internal structure */
struct __fmctdc_board {
	int dev_id;
	char *devbase;
	char *sysbase;
	int fdc[5]; /* The 5 control channels */
	int fdd[5]; /* The 5 data channels */
};

static inline int fmctdc_is_verbose(void)
{
	return getenv("FMCTDC_LIB_VERBOSE") != 0;
}

#define __define_board(b, ub)	struct __fmctdc_board *b = (void *)(ub)

/* These two from ../tools/fdelay-raw.h, used internally */
static inline int __fmctdc_sysfs_get(char *path, uint32_t *resp)
{
	FILE *f = fopen(path, "r");

	if (!f)
		return -1;
	errno = 0;
	if (fscanf(f, "%i", resp) != 1) {
		fclose(f);
		if (!errno)
			errno = EINVAL;
		return -1;
	}
	fclose(f);
	return 0;
}

static inline int __fmctdc_sysfs_set(char *path, uint32_t *value)
{
	char s[16];
	int fd, ret, len;

	len = sprintf(s, "%i\n", *value);
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
			       uint32_t *resp)
{
	char pathname[128];

	sprintf(pathname, "%s/%s", b->sysbase, name);
	return __fmctdc_sysfs_get(pathname, resp);
}

static inline int fmctdc_sysfs_set(struct __fmctdc_board *b, char *name,
			       uint32_t *value)
{
	char pathname[128];

	sprintf(pathname, "%s/%s", b->sysbase, name);
	return __fmctdc_sysfs_set(pathname, value);
}

static inline int __fmctdc_command(struct __fmctdc_board *b, uint32_t cmd)
{
	return fmctdc_sysfs_set(b, "command", &cmd);
}

#endif /* fmctdc_INTERNAL */
#endif /* __fmctdc_H__ */
