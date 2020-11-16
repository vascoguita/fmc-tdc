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
#include <string.h>

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

	ps += (uint64_t) a->seconds * 1000000000000ULL;
	ps += (uint64_t) a->coarse * 8000ULL;
	ps += (uint64_t) a->frac * 8000ULL / 4096ULL;
	return ps;
}

/**
 * It normalizes the timestamp
 * @param[in,out] a timestamp
 */
void fmctdc_ts_norm(struct fmctdc_time *a)
{
	uint64_t tmp;

	if (a->frac >= 4096) {
		tmp = a->frac / 4096UL;
		a->coarse += tmp;
		a->frac -= tmp * 4096UL;
	}

	if (a->coarse >= 125000000) {
		tmp = a->coarse / 125000000UL;
		a->seconds += tmp;
		a->coarse -= tmp * 125000000UL;
	}
}

/**
 * It perform the subtraction: r = a - b (a > b)
 * @param[out] r result
 * @param[in] a normalized timestamp
 * @param[in] b normalized timestamp
 */
static void __fmctdc_ts_sub(struct fmctdc_time *r,
			    const struct fmctdc_time *a,
			    const struct fmctdc_time *b)
{
	int32_t d_frac, d_coarse = 0, d_seconds = 0;

	memset(r, 0, sizeof(*r));

	d_frac = a->frac - b->frac;

	if (d_frac < 0) {
		d_frac += 4096;
		d_coarse--;
	}

	d_coarse += (a->coarse - b->coarse);
	if (d_coarse < 0) {
		d_coarse += 125000000;
		d_seconds--;
	}

	d_seconds += (a->seconds - b->seconds);

	r->coarse = d_coarse;
	r->frac = d_frac;
	r->seconds = d_seconds;
}

/**
 * It perform the subtraction: r = a - b
 * @param[out] r result
 * @param[in] a normalized timestamp
 * @param[in] b normalized timestamp
 * @return 1 if the difference is negative, otherwise 0
 */
int fmctdc_ts_sub(struct fmctdc_time *r,
		  const struct fmctdc_time *a,
		  const struct fmctdc_time *b)
{
	int negative = 0;

	if (a->seconds < b->seconds)
		negative = 1;
	else if (a->seconds == b->seconds &&
		 a->coarse < b->coarse)
		negative = 1;
	else if (a->seconds == b->seconds &&
		 a->coarse == b->coarse &&
		 a->frac < b->frac)
		negative = 1;

	if (negative)
		__fmctdc_ts_sub(r, b, a);
	else
		__fmctdc_ts_sub(r, a, b);

	return negative;
}


/**
 * It perform an addiction: r = a + b
 * @param[out] r result
 * @param[in] a normalized timestamp
 * @param[in] b normalized timestamp
 */
void fmctdc_ts_add(struct fmctdc_time *r,
		   const struct fmctdc_time *a,
		   const struct fmctdc_time *b)
{
	memset(r, 0, sizeof(*r));

	r->frac = a->frac + b->frac;

	if (r->frac >= 4096) {
		r->frac -= 4096;
		r->coarse++;
	}

	r->coarse += a->coarse + b->coarse;

	if (r->coarse >= 125000000) {
		r->coarse -= 125000000;
		r->seconds++;
	}

	r->seconds += a->seconds + b->seconds;
}
