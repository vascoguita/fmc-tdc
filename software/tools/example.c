// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2022 CERN (home.cern)

/* 
 * Author: Federico Vaga <federico.vaga@cern.ch>
 *
 * This is an example program that shows the different part of the library
 * in action.
 *
 *
 * This is part of the documentation, so when you change it **REMEMBER** to
 * update the references in documents in `doc/`.
 *
 * The reason to have the example here as a true program is that we can always
 * compile it and run it, so that we can validate the example.
 * This way, at least for this aspect, the documentation in always aligned.
 *
 * Do not try to optimize this code, the purpose is to show code, highlight
 * snippet and being able to refer to it from the documentation
 */

#include <assert.h>
#include <errno.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#include <fmctdc-lib.h>

static const unsigned int channel = 0;
static const int termination = 0;
static const enum fmctdc_buffer_type buffer_type = FMCTDC_BUFFER_VMALLOC;
static const enum fmctdc_buffer_mode buffer_mode = FMCTDC_BUFFER_FIFO;
static const unsigned int buffer_len= 128;
static const int32_t offset_user = 0;
static const int wr_mode = 0;
static const struct fmctdc_time time = {0, 0, 0, 0, 0};
static char *prog_name;

static int fetch_and_process(struct fmctdc_board *tdc);
static int acquire(struct fmctdc_board *tdc);
static int config(struct fmctdc_board *tdc);
static int config_and_acquire(struct fmctdc_board *tdc);
static int use_fmctdc_library(void);

int main(int argc, char *argv[])
{
	int err;

	prog_name = argv[0];

	err = fmctdc_init();
	if (err)
		exit(EXIT_FAILURE);

	err = use_fmctdc_library();
	if (err)
		exit(EXIT_FAILURE);
	fmctdc_exit(); /* optional, indeed in the error condition
			  we do not do it */
	exit(EXIT_SUCCESS);
}

static int use_fmctdc_library(void)
{
	struct fmctdc_board *tdc;
	int err;

	/* Open the TDC */
	tdc = fmctdc_open(0x0000);
	if (!tdc) {
		fprintf(stderr, "%s: Cannot open device: %s\n",
			prog_name, fmctdc_strerror(errno));
		return -1;
	}

	err = fmctdc_flush(tdc, channel);
	if (err)
		return err;

	err = config_and_acquire(tdc);
	if (err) {
		fprintf(stderr, "%s: Error: %s\n",
			prog_name, fmctdc_strerror(errno));
		return -1;
	}

	fmctdc_close(tdc);

	return err;
}

static int config_and_acquire(struct fmctdc_board *tdc)
{
	int err;

	err = config(tdc);
	if (err)
		return err;

	err = acquire(tdc);
	if (err)
		return err;

	return err;
}

static int config(struct fmctdc_board *tdc)
{
	int err = 0;
	/* read-back */
	int termination_rb;
	int32_t offset_user_rb;
	enum fmctdc_buffer_type buffer_type_rb;
	enum fmctdc_buffer_mode buffer_mode_rb;
	int buffer_len_rb;
	int wr_mode_rb;
	unsigned int coalescing_timeout = 50; /* a number */
	unsigned int coalescing_timeout_rb;
	struct fmctdc_time time_rb;

	err = fmctdc_set_termination(tdc, channel, termination);
	if (err)
		return err;
	termination_rb = fmctdc_get_termination(tdc, channel);
	if (termination_rb < 0)
		return termination_rb;
	assert(termination == termination_rb);

	err = fmctdc_coalescing_timeout_set(tdc, channel, coalescing_timeout);
	if (err)
		return err;
	err = fmctdc_coalescing_timeout_get(tdc, channel, &coalescing_timeout_rb);
	if (err)
		return err;
	assert(coalescing_timeout == coalescing_timeout_rb);

	err = fmctdc_wr_mode(tdc, wr_mode);
	if (err)
		return err;
	wr_mode_rb = fmctdc_check_wr_mode(tdc);
	if (wr_mode_rb < 0)
		return wr_mode_rb;
	assert(wr_mode == wr_mode_rb);

	err = fmctdc_set_time(tdc, &time);
	if (err)
		return err;
	err = fmctdc_get_time(tdc, &time_rb);
	if (err)
		return err;
	/* time_rbx and time_rb may be different, no need to compare */

	err = fmctdc_set_offset_user(tdc, channel, offset_user);
	if (err)
		return err;
	err = fmctdc_get_offset_user(tdc, channel, &offset_user_rb);
	if (err)
		return err;
	assert(offset_user == offset_user_rb);

	err = fmctdc_set_buffer_type(tdc, buffer_type);
	if (err)
		return err;
	buffer_type_rb = fmctdc_get_buffer_type(tdc);
	if (buffer_type_rb < 0)
		return buffer_type_rb;
	assert(buffer_type == buffer_type_rb);

	err = fmctdc_set_buffer_len(tdc, channel, buffer_len);
	if (err)
		return err;
	buffer_len_rb = fmctdc_get_buffer_len(tdc, channel);
	if (buffer_len_rb < 0)
		return buffer_len_rb;
	assert(buffer_len == buffer_len_rb);

	err = fmctdc_set_buffer_mode(tdc, channel, buffer_mode);
	if (err)
		return err;
	buffer_mode_rb = fmctdc_get_buffer_mode(tdc, channel);
	if (buffer_mode_rb < 0)
		return buffer_mode_rb;
	assert(buffer_mode == buffer_mode_rb);

	return err;
}

static int acquire(struct fmctdc_board *tdc)
{
	int err = 0;

	err = fmctdc_channel_enable(tdc, channel);
	if (err)
		return err;

	err = fetch_and_process(tdc);
	if (err)
		return err;

	err = fmctdc_channel_disable(tdc, channel);
	if (err)
		return err;

	return err;
}

static int fetch_and_process(struct fmctdc_board *tdc)
{
	int err = 0;
	int n, i;
	float temperature;
	const int max = 10;
	struct fmctdc_time ts[max];
	uint32_t recv, trans;

	do {
		n = fmctdc_read(tdc, channel, ts, max, O_NONBLOCK);
	} while (n < 0 && errno == EAGAIN);
	if (n < 0)
		return n;

	temperature = fmctdc_read_temperature(tdc);

	err = fmctdc_stats_recv_get(tdc, channel, &recv);
	if (err)
		return err;
	err = fmctdc_stats_trans_get(tdc, channel, &trans);
	if (err)
		return err;

	printf("Temperature: %f\n", temperature);
	printf("Stats: %d %d\n", recv, trans);
	for (i = 0; i < n; ++i)
		printf("Timestamp: "PRItsps"\n", PRItspsVAL(&ts[i]));

	return err;
}
