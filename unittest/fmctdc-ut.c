/*
 * Copyright (C) 2018 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 *
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */
#include <getopt.h>
#include <libgen.h>
#include <stdlib.h>
#include <mamma.h>

#include <fmctdc-lib.h>

struct fmctdc_test_desc {
	struct fmctdc_board *tdc;
};

static int fmctdc_dev_id;


/**
 * Print help message
 * @param[in] name program name
 */
static void fmctdc_ut_help(char *name)
{
	fprintf(stderr, "%s -D 0x<dev_id>\n", basename(name));
}

static void fmctdc_param_set_up(struct m_suite *m_suite)
{
	struct fmctdc_test_desc *d;
	int ret;

	ret = fmctdc_init();
	m_assert_int_lt(0, ret);

	d = malloc(sizeof(*d));
	m_assert_mem_not_null(d);

	d->tdc = fmctdc_open(-1, fmctdc_dev_id);
	m_assert_mem_not_null(d->tdc);

	m_suite->private = d;
}

static void fmctdc_param_tear_down(struct m_suite *m_suite)
{
	struct fmctdc_test_desc *d = m_suite->private;
	struct fmctdc_board *tdc = d->tdc;
	int err;

	free(d);
	err = fmctdc_close(tdc);
	m_assert_int_eq(0, err);
	fmctdc_exit();
}

static void fmctdc_param_test1(struct m_test *m_test)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	int i, fd;

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		fd = fmctdc_fileno_channel(tdc, i);
		m_assert_int_lt(0, fd);
	}
}
static const char *fmctdc_param_test1_desc =
	"All file descriptors must be valid (positive number)";

static void fmctdc_param_test2(struct m_test *m_test)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	unsigned int timeout, timeout_rb;
	int i, err;

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		for (timeout = 1; timeout < 1000; timeout *= 10) {
			err = fmctdc_coalescing_timeout_set(tdc, i,
							    timeout);
			m_assert_int_eq(0, err);
			err = fmctdc_coalescing_timeout_get(tdc, i,
							    &timeout_rb);
			m_assert_int_eq(0, err);
			m_assert_int_eq(timeout, timeout_rb);
		}
	}
}
static const char *fmctdc_param_test2_desc =
	"Being able to change the coalescing timeout";

static void fmctdc_param_test3(struct m_test *m_test)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	int i, err, ret;

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		/* disable */
		err = fmctdc_set_termination(tdc, i, 0);
		m_assert_int_eq(0, err);
		ret = fmctdc_get_termination(tdc, i);
		m_assert_int_eq(0, ret);
		/* enable */
		err = fmctdc_set_termination(tdc, i, 1);
		m_assert_int_eq(0, err);
		ret = fmctdc_get_termination(tdc, i);
		m_assert_int_eq(1, ret);
		/* disable */
		err = fmctdc_set_termination(tdc, i, 0);
		m_assert_int_eq(0, err);
		ret = fmctdc_get_termination(tdc, i);
		m_assert_int_eq(0, ret);
	}
}
static const char *fmctdc_param_test3_desc =
	"Being able to enable/disable termination";

static void fmctdc_param_test4(struct m_test *m_test)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	int i, err, ret;

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		/* disable */
		err = fmctdc_channel_status_set(tdc, i, FMCTDC_STATUS_DISABLE);
		m_assert_int_eq(0, err);
		ret = fmctdc_channel_status_get(tdc, i);
		m_assert_int_eq(FMCTDC_STATUS_DISABLE, ret);
		/* enable */
		err = fmctdc_channel_status_set(tdc, i, FMCTDC_STATUS_ENABLE);
		m_assert_int_eq(0, err);
		ret = fmctdc_channel_status_get(tdc, i);
		m_assert_int_eq(FMCTDC_STATUS_ENABLE, ret);
		/* disable */
		err = fmctdc_channel_status_set(tdc, i, FMCTDC_STATUS_DISABLE);
		m_assert_int_eq(0, err);
		ret = fmctdc_channel_status_get(tdc, i);
		m_assert_int_eq(FMCTDC_STATUS_DISABLE, ret);
	}
}
static const char *fmctdc_param_test4_desc =
	"Being able to enable/disable channel";

static void fmctdc_param_test5(struct m_test *m_test)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	int i, err, ret;

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		err = fmctdc_set_buffer_mode(tdc, i, FMCTDC_BUFFER_CIRC);
		m_assert_int_eq(0, err);
		ret = fmctdc_get_buffer_mode(tdc, i);
		m_assert_int_eq(FMCTDC_BUFFER_CIRC, ret);

		err = fmctdc_set_buffer_mode(tdc, i, FMCTDC_BUFFER_FIFO);
		m_assert_int_eq(0, err);
		ret = fmctdc_get_buffer_mode(tdc, i);
		m_assert_int_eq(FMCTDC_BUFFER_FIFO, ret);
	}
}
static const char *fmctdc_param_test5_desc =
	"Being able to change buffer mode: FIFO, CIRC";


static void fmctdc_param_test6(struct m_test *m_test)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	unsigned int len;
	int i, err, ret;

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		for (len = 1; len < 64; len <<= 1) {
			err = fmctdc_set_buffer_len(tdc, i, len);
			m_assert_int_eq(0, err);
			ret = fmctdc_get_buffer_len(tdc, i);
			m_assert_int_eq(len, ret);
		}
	}
}
static const char *fmctdc_param_test6_desc =
	"Being able to change the software buffer len";


int main(int argc, char *argv[])
{
	struct m_test fmctdc_param_tests[] = {
		m_test_desc(NULL, fmctdc_param_test1, NULL,
			    fmctdc_param_test1_desc),
		m_test_desc(NULL, fmctdc_param_test2, NULL,
			    fmctdc_param_test2_desc),
		m_test_desc(NULL, fmctdc_param_test3, NULL,
			    fmctdc_param_test3_desc),
		m_test_desc(NULL, fmctdc_param_test4, NULL,
			    fmctdc_param_test4_desc),
		m_test_desc(NULL, fmctdc_param_test5, NULL,
			    fmctdc_param_test5_desc),
		m_test_desc(NULL, fmctdc_param_test6, NULL,
			    fmctdc_param_test6_desc),
	};
	struct m_suite fmctdc_suite = m_suite("FMC TDC test: parameters",
					      M_VERBOSE,
					      fmctdc_param_tests,
					      fmctdc_param_set_up,
					      fmctdc_param_tear_down);
	char opt;
	int ret;

	while ((opt = getopt(argc, argv, "D:h")) != -1) {
		switch (opt) {
		case 'D':
			ret = sscanf(optarg, "0x%04x", &fmctdc_dev_id);
			if (ret != 1) {
				fmctdc_ut_help(argv[0]);
				exit(EXIT_FAILURE);
			}
			break;
		case 'h':
		case '?':
			fmctdc_ut_help(argv[0]);
			exit(EXIT_SUCCESS);
			break;
		}
	}

	if (!fmctdc_dev_id) {
		fprintf(stderr, "Missing device ID options\n");
		fmctdc_ut_help(argv[0]);
		exit(EXIT_FAILURE);
	}

	m_suite_run(&fmctdc_suite);

	exit(EXIT_SUCCESS);
}
