/*
 * The fmc-tdc (a.k.a. FmcTdc1ns5cha) library - timestamp math.
 *
 * Copyright (C) 2012-2018 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 *
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */
#include <unistd.h>
#include <errno.h>

#include "fmctdc-lib.h"
#include "fmctdc-lib-private.h"

/**
 * It provides a nano-second approximation of the timestamp.
 * @param[in] a timestamp
 * @return it returns the time stamp in nano-seconds
 */
uint64_t fmctdc_ts_approx_ns(struct fmctdc_time *a)
{
	uint64_t ns = 0;

	ns += a->seconds * 1000000000ULL;
	ns += ((uint64_t)a->coarse) * 8ULL;
	ns += ((uint64_t)a->frac) * 8000ULL / 4096ULL / 1000ULL;
	return ns;
}


/**
 * It provides a pico-seconds representation of the time stamp. Bear in mind
 * that it may overflow. If you thing that it may happen, check the timestamp
 * @param[in] a timestamp
 * @return it returns the time stamp in pico-seconds
 */
uint64_t fmctdc_ts_ps(struct fmctdc_time *a)
{
	uint64_t ps = 0;

	ps += a->seconds * 1000000000000ULL;
	ps += a->coarse * 8000;
	ps += a->frac * 8000ULL / 4096ULL;
	return ps;
}


/**
 * It perform the subtraction: a = a - b
 * @param[in] a timestamp
 * @param[in] b timestamp
 */
void fmctdc_ts_sub(struct fmctdc_time *a, struct fmctdc_time *b)
{
	int32_t d_frac, d_coarse = 0;

	d_frac = a->frac - b->frac;

	if (d_frac < 0) {
		d_frac += 4096;
		d_coarse--;
	}

	d_coarse += a->coarse - b->coarse;

	if (d_coarse < 0) {
		d_coarse += 125000000;
		a->seconds--;
	}

	a->coarse = d_coarse;
	a->frac = d_frac;
	a->seconds -= b->seconds;
}


/**
 * It perform an addiction: a = a + b
 * @param[in] a timestamp
 * @param[in] b timestamp
 */
void fmctdc_ts_add(struct fmctdc_time *a, struct fmctdc_time *b)
{
	a->frac += b->frac;

	if (a->frac >= 4096) {
		a->frac -= 4096;
		a->coarse++;
	}

	a->coarse += b->coarse;

	if (a->coarse >= 125000000) {
		a->coarse -= 125000000;
		a->seconds++;
	}

	a->seconds += b->seconds;
}

