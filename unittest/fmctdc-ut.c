/*
 * Copyright (C) 2018 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 *
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */
#include <errno.h>
#include <getopt.h>
#include <libgen.h>
#include <poll.h>
#include <stdlib.h>
#include <string.h>
#include <mamma.h>

#include <fmctdc-lib.h>

struct fmctdc_test_desc {
	struct fmctdc_board *tdc;
};

static int fmctdc_dev_id;
static int fmcfd_dev_id;

#define CMD_LEN 1024
static int fmctdc_execute_fmc_fdelay_pulse(unsigned int devid,
					   unsigned int channel,
					   unsigned int period_us,
					   unsigned int delay_us,
					   unsigned int count)
{
	char cmd[CMD_LEN];

	snprintf(cmd, CMD_LEN,
		"fmc-fdelay-pulse -d 0x%x -o %d -m pulse -T %du -w 150n -r %du -c %d > /dev/null",
		devid, channel + 1, period_us, delay_us, count);

	return system(cmd);
}


/**
 * Print help message
 * @param[in] name program name
 */
static void fmctdc_ut_help(char *name)
{
	fprintf(stderr, "%s -T 0x<dev_id> -F 0x<dev_id>\n", basename(name));
	fprintf(stderr, "\t-T 0x<dev_id> : FMC TDC device ID\n");
	fprintf(stderr, "\t-F 0x<dev_id> : FMC FineDelay device ID\n");
}

static void fmctdc_set_up(struct m_suite *m_suite)
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

static void fmctdc_tear_down(struct m_suite *m_suite)
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



static void fmctdc_param_test7(struct m_test *m_test)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	int ret;

	ret = fmctdc_wr_mode(tdc, 1);
	m_assert_int_eq(0, ret);
	ret = fmctdc_check_wr_mode(tdc);
	m_assert_int_eq(0, ret);

	ret = fmctdc_wr_mode(tdc, 0);
	m_assert_int_eq(ENOLINK, ret);
	ret = fmctdc_check_wr_mode(tdc);
	m_assert_int_eq(ENODEV, ret);
}
static const char *fmctdc_param_test7_desc =
	"Being able to change the White-Rabbit mode";




static void fmctdc_op_test_setup(struct m_test *m_test)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	int i, err, ret;

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		err = fmctdc_channel_status_set(tdc, i, FMCTDC_STATUS_DISABLE);
		m_assert_int_eq(0, err);
		ret = fmctdc_channel_status_get(tdc, i);
		m_assert_int_eq(FMCTDC_STATUS_DISABLE, ret);

		err = fmctdc_set_buffer_len(tdc, i, 16);
		m_assert_int_eq(0, err);
		err = fmctdc_ts_mode_set(tdc, i, FMCTDC_TS_MODE_POST);
		m_assert_int_eq(0, err);
		err = fmctdc_coalescing_timeout_set(tdc, i, 10);
		m_assert_int_eq(0, err);
		err = fmctdc_set_buffer_mode(tdc, i, FMCTDC_BUFFER_FIFO);
		m_assert_int_eq(0, err);

		err = fmctdc_flush(tdc, i);
		m_assert_int_eq(0, err);
	}
}

static void fmctdc_op_test_tear_down(struct m_test *m_test)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	int i, err, ret;

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		err = fmctdc_channel_status_set(tdc, i, FMCTDC_STATUS_DISABLE);
		m_assert_int_eq(0, err);
		ret = fmctdc_channel_status_get(tdc, i);
		m_assert_int_eq(FMCTDC_STATUS_DISABLE, ret);
	}
}

static void fmctdc_op_test_parameters(struct m_test *m_test,
				      unsigned int count,
				      unsigned int period)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	struct fmctdc_time t[FMCTDC_NUM_CHANNELS], tmp;
	struct pollfd p;
	int i, k, err, ret;

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		err = fmctdc_channel_enable(tdc, i);
		m_assert_int_eq(0, err);
	}

	for (i = 0; i < FMCTDC_NUM_CHANNELS - 1; ++i) {
		err = fmctdc_execute_fmc_fdelay_pulse(fmcfd_dev_id,
						      i, period, 0, count);
		m_assert_int_eq(0, err);
	}

	for (k = 0; k < count; ++k) {
		for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
			p.fd = fmctdc_fileno_channel(tdc, i);
			p.events = POLLIN | POLLERR;
			ret = poll(&p, 1, 1000);
			m_assert_int_neq(0, ret); /* detect time out */
			m_assert_int_neq(0, p.revents & POLLIN);
			m_assert_int_lt(0, ret);

			ret = fmctdc_read(tdc, i, &t[i], 1, 0);
			m_assert_int_eq(1, ret);
		}

		for (i = 1; i < FMCTDC_NUM_CHANNELS; ++i) {
			memcpy(&tmp, &t[0], sizeof(t));
			fmctdc_ts_sub(&tmp, &t[i]);
			/*
			 * We know that from time to time ACAM TDC-GPX
			 * produces wrong timestamps (-8ns +8ns)
			 */
			m_assert_int_range(0, 8000, fmctdc_ts_ps(&tmp));
		}
	}
}

static void fmctdc_op_test1(struct m_test *m_test)
{
	fmctdc_op_test_parameters(m_test, 1, 1);
}
static const char *fmctdc_op_test1_desc =
	"FineDelay generates, simultaneously, one pulse for each channel. We check that they all arrives and the timestamp is the same (ignore fine field)";


static void fmctdc_op_test2(struct m_test *m_test)
{
	fmctdc_op_test_parameters(m_test, 1000, 1000);
}
static const char *fmctdc_op_test2_desc =
	"FineDelay generates, simultaneously, 1000 pulse for each channel (1kHz). We check that they all arrives and the timestamp is the same (ignore fine field)";

static void fmctdc_op_test3(struct m_test *m_test)
{
	fmctdc_op_test_parameters(m_test, 10000, 100);
}
static const char *fmctdc_op_test3_desc =
	"FineDelay generates, simultaneously, 10000 pulse for each channel (10kHz). We check that they all arrives and the timestamp is the same (ignore fine field)";

static void fmctdc_op_test4(struct m_test *m_test)
{
	fmctdc_op_test_parameters(m_test, 100000, 10);
}
static const char *fmctdc_op_test4_desc =
	"FineDelay generates, simultaneously, 100000 pulse for each channel (100kHz). We check that they all arrives and the timestamp is the same (ignore fine field)";

static void fmctdc_op_test5(struct m_test *m_test)
{
	fmctdc_op_test_parameters(m_test, 1000000, 100);
}
static const char *fmctdc_op_test5_desc =
	"FineDelay generates, simultaneously, 1000000 pulse for each channel (1MHz). We check that they all arrives and the timestamp is the same (ignore fine field)";



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
		m_test_desc(NULL, fmctdc_param_test7, NULL,
			    fmctdc_param_test7_desc),
	};
	struct m_suite fmctdc_suite_param = m_suite("FMC TDC test: parameters",
						    M_VERBOSE,
						    fmctdc_param_tests,
						    fmctdc_set_up,
						    fmctdc_tear_down);
	struct m_test fmctdc_op_tests[] = {
		m_test_desc(fmctdc_op_test_setup,
			    fmctdc_op_test1,
			    fmctdc_op_test_tear_down,
			    fmctdc_op_test1_desc),
		m_test_desc(fmctdc_op_test_setup,
			    fmctdc_op_test2,
			    fmctdc_op_test_tear_down,
			    fmctdc_op_test2_desc),
		m_test_desc(fmctdc_op_test_setup,
			    fmctdc_op_test3,
			    fmctdc_op_test_tear_down,
			    fmctdc_op_test3_desc),
		m_test_desc(fmctdc_op_test_setup,
			    fmctdc_op_test4,
			    fmctdc_op_test_tear_down,
			    fmctdc_op_test4_desc),
		m_test_desc(fmctdc_op_test_setup,
			    fmctdc_op_test5,
			    fmctdc_op_test_tear_down,
			    fmctdc_op_test5_desc),
	};
	struct m_suite fmctdc_suite_op = m_suite("FMC TDC test: operation",
						 M_VERBOSE,
						 fmctdc_op_tests,
						 fmctdc_set_up,
						 fmctdc_tear_down);

	char opt;
	int ret;

	while ((opt = getopt(argc, argv, "T:F:h")) != -1) {
		switch (opt) {
		case 'T':
			ret = sscanf(optarg, "0x%04x", &fmctdc_dev_id);
			if (ret != 1) {
				fmctdc_ut_help(argv[0]);
				exit(EXIT_FAILURE);
			}
			break;
		case 'F':
			ret = sscanf(optarg, "0x%04x", &fmcfd_dev_id);
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
		fprintf(stderr, "Missing TDC device ID options\n");
		fmctdc_ut_help(argv[0]);
		exit(EXIT_FAILURE);
	}
	m_suite_run(&fmctdc_suite_param);

	if (!fmcfd_dev_id) {
		fprintf(stderr, "Missing FineDelay device ID options\n");
		fmctdc_ut_help(argv[0]);
		exit(EXIT_FAILURE);
	}
	m_suite_run(&fmctdc_suite_op);

	exit(EXIT_SUCCESS);
}
