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
	FMCTDC_CH_LAST = 5,
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

extern int fmctdc_set_acquisition(struct fmctdc_board *b, int enable);
extern int fmctdc_get_acquisition(struct fmctdc_board *b);

extern int fmctdc_set_termination(struct fmctdc_board *b, int channel,
				  int enable);
extern int fmctdc_get_termination(struct fmctdc_board *b, int channel);

extern int fmctdc_fread(struct fmctdc_board *b, int channel,
			struct fmctdc_time *t, int n);
extern int fmctdc_fileno_channel(struct fmctdc_board *b, int channel);
extern int fmctdc_read(struct fmctdc_board *b, int channel,
		       struct fmctdc_time *t, int n, int flags);

extern float fmctdc_read_temperature(struct fmctdc_board *b);

extern int fmctdc_wr_mode(struct fmctdc_board *b, int on);
extern int fmctdc_check_wr_mode(struct fmctdc_board *b);

extern void fmctdc_ts_sub(struct fmctdc_time *a, struct fmctdc_time *b);

#endif /* __FMCTDC_LIB_H__ */
