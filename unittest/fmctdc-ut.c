/*
 * Copyright (C) 2018 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 *
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */
#include <errno.h>
#include <getopt.h>
#include <inttypes.h>
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
					   unsigned int relative_us,
					   unsigned int count,
					   struct fmctdc_time t)
{
	char cmd[CMD_LEN];

	if (t.seconds)
		snprintf(cmd, CMD_LEN,
			 "fmc-fdelay-pulse -d 0x%x -o %d -m pulse -T %du -w 150n -D %"PRId64":0 -c %d > /dev/null",
			 devid, channel + 1, period_us, t.seconds, count);
	else
		snprintf(cmd, CMD_LEN,
			 "fmc-fdelay-pulse -d 0x%x -o %d -m pulse -T %du -w 150n -r %du -c %d > /dev/null",
			 devid, channel + 1, period_us, relative_us, count);

	printf("%s\n", cmd);
	system("fmc-fdelay-board-time -d 0x700 get\n");
	return system(cmd);
}

/**
 * It sets the fine-delay to work with White-Rabbit
 */
static int fmcdc_execute_fmc_fdelay_wr(unsigned int devid)
{
	char cmd[CMD_LEN];

	snprintf(cmd, CMD_LEN,
		 "fmc-fdelay-board-time -d 0x%x wr > /dev/null",
		 devid);

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
			m_assert_int_eq(-1, err);

		}

		for (len = 64; len < (64 << 20); len <<= 1) {
			err = fmctdc_set_buffer_len(tdc, i, len);
			m_assert_int_eq(0, err);
			ret = fmctdc_get_buffer_len(tdc, i);
			m_assert_int_le(len, ret);
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
	sleep(2);
	ret = fmctdc_check_wr_mode(tdc);
	m_assert_int_eq(0, ret);

	ret = fmctdc_wr_mode(tdc, 0);
	m_assert_int_eq(0, ret);
	sleep(2);
	ret = fmctdc_check_wr_mode(tdc);
	m_assert_int_eq(-1, ret);
	m_assert_int_eq(ENODEV, errno);
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

		err = fmctdc_set_buffer_len(tdc, i, 1000000);
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

	err = fmcdc_execute_fmc_fdelay_wr(fmcfd_dev_id);
	m_assert_int_eq(0, err);

	ret = fmctdc_wr_mode(tdc, 1);
	m_assert_int_eq(0, ret);

	/* wait maximum ~10seconds for white-rabbit to sync */
	for (i = 0; err && i < 5; ++i) {
		sleep(2);
		err = fmctdc_check_wr_mode(tdc);
	}
	m_assert_int_eq(0, err);
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
	struct fmctdc_time *t[FMCTDC_NUM_CHANNELS], tmp, start;
	struct pollfd p;
	int i, k, err, ret;
	uint32_t trans_b[FMCTDC_NUM_CHANNELS], recv_b[FMCTDC_NUM_CHANNELS];

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		err = fmctdc_stats_recv_get(tdc, i, &recv_b[i]);
		m_assert_int_eq(0, err);
		err = fmctdc_stats_trans_get(tdc, i, &trans_b[i]);
		m_assert_int_eq(0, err);

		t[i] = calloc(count, sizeof(struct fmctdc_time));
		m_assert_mem_not_null(t[i]);
		err = fmctdc_channel_enable(tdc, i);
		m_assert_int_eq(0, err);
	}

	/* Generate pulses 2_pulses in the future */
	err = fmctdc_get_time(tdc, &start);
	m_assert_int_eq(0, err);
	start.seconds += 2;
	start.coarse = 0;
	start.frac = 0;
	for (i = 0; i < FMCTDC_NUM_CHANNELS - 1; ++i) {
		err = fmctdc_execute_fmc_fdelay_pulse(fmcfd_dev_id,
						      i, period,
						      0,
						      count,
						      start);
		m_assert_int_eq(0, err);
		fmctdc_get_time(tdc, &tmp);
	}
	sleep(5 + ((count * period) / 1000000));

	fmctdc_get_time(tdc, &tmp);

	/* Check statistics */
	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		uint32_t val;

		err = fmctdc_stats_recv_get(tdc, i, &val);
		m_assert_int_eq(0, err);
		m_assert_int_eq(recv_b[i] + count, val);
		err = fmctdc_stats_trans_get(tdc, i, &val);
		m_assert_int_eq(0, err);
		m_assert_int_eq(trans_b[i] + count, val);
	}


	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i) {
		p.fd = fmctdc_fileno_channel(tdc, i);
		p.events = POLLIN | POLLERR;
		ret = poll(&p, 1, 1000);
		m_assert_int_neq(0, ret); /* detect time out */
		m_assert_int_neq(0, p.revents & POLLIN);
		m_assert_int_lt(0, ret);

		ret = 0;
		do {
			int n;
			n = fmctdc_read(tdc, i, t[i], count - ret,
					O_NONBLOCK);
			m_assert_int_neq(-1, n);
			ret += n;
		} while (ret > 0 && ret < count);
		m_assert_int_eq(count, ret);
	}

	/* Validate period */
	for (k = 1; k < count; ++k) {
		for (i = 1; i < FMCTDC_NUM_CHANNELS; ++i) {
			fmctdc_ts_sub(&tmp, &t[i][k], &t[i][k - 1]);
			m_assert_int_range(period - 1, period + 1,
					fmctdc_ts_ps(&tmp) / 1000000);
		}
	}

	/* Validate synchronicity */
	for (k = 0; k < count; ++k) {
		for (i = 1; i < FMCTDC_NUM_CHANNELS; ++i) {
			fmctdc_ts_sub(&tmp, &t[0][k], &t[i][k]);
			/*
			 * We know that from time to time ACAM TDC-GPX
			 * produces wrong timestamps (-8ns +8ns)
			 */
			m_assert_int_range(0, 8000, fmctdc_ts_ps(&tmp));
		}
	}

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i)
		free(t[i]);
}

static void fmctdc_op_test1(struct m_test *m_test)
{
	fmctdc_op_test_parameters(m_test, 1, 1);
}
static const char *fmctdc_op_test1_desc =
	"FineDelay generates, simultaneously, one pulse for each channel. We check that they all arrives and the timestamp is the same (error 8ns)";


static void fmctdc_op_test2(struct m_test *m_test)
{
	fmctdc_op_test_parameters(m_test, 1000, 1000);
}
static const char *fmctdc_op_test2_desc =
	"FineDelay generates, simultaneously, 1000 pulse for each channel (1kHz). We check that they all arrives and the timestamp is the same (error 8ns)";

static void fmctdc_op_test3(struct m_test *m_test)
{
	fmctdc_op_test_parameters(m_test, 10000, 100);
}
static const char *fmctdc_op_test3_desc =
	"FineDelay generates, simultaneously, 10000 pulse for each channel (10kHz). We check that they all arrives and the timestamp is the same (error 8ns)";

static void fmctdc_op_test4(struct m_test *m_test)
{
	fmctdc_op_test_parameters(m_test, 100000, 10);
}
static const char *fmctdc_op_test4_desc =
	"FineDelay generates, simultaneously, 100000 pulse for each channel (100kHz). We check that they all arrives and the timestamp is the same (error 8ns)";

static void fmctdc_op_test5(struct m_test *m_test)
{
	fmctdc_op_test_parameters(m_test, 1000000, 100);
}
static const char *fmctdc_op_test5_desc =
	"FineDelay generates, simultaneously, 1000000 pulse for each channel (1MHz). We check that they all arrives and the timestamp is the same (error 8ns)";

static void fmctdc_op_test6(struct m_test *m_test)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	struct pollfd p;
	const unsigned int timeout = 10;
	int i, err, ret;
	struct fmctdc_time t = {0, 0, 0, 0, 0};

	for (i = 0; i < FMCTDC_NUM_CHANNELS - 1; ++i) {
		err = fmctdc_coalescing_timeout_set(tdc, i, timeout);
		m_assert_int_eq(0, err);

		err = fmctdc_channel_enable(tdc, i);
		m_assert_int_eq(0, err);

		err = fmctdc_execute_fmc_fdelay_pulse(fmcfd_dev_id,
						      i, 1, 0, 1000000,
						      t);
		m_assert_int_eq(0, err);

		p.fd = fmctdc_fileno_channel(tdc, i);
		p.events = POLLIN | POLLERR;
		ret = poll(&p, 1, timeout / 2);
		m_assert_int_eq(0, ret);
	}
}
static const char *fmctdc_op_test6_desc =
	"FineDelay generates, simultaneously, 1000000 pulse for each channel (1MHz). We test the IRQ coalesing timeout. We expect to not receive timestamp before the timeout";

static void fmctdc_op_test7(struct m_test *m_test)
{
	struct fmctdc_test_desc *d = m_test->suite->private;
	struct fmctdc_board *tdc = d->tdc;
	struct pollfd p;
	const unsigned int timeout = 10;
	int i, err, ret;
	struct fmctdc_time t = {0, 0, 0, 0, 0};


	for (i = 0; i < FMCTDC_NUM_CHANNELS - 1; ++i) {
		err = fmctdc_coalescing_timeout_set(tdc, i, timeout);
		m_assert_int_eq(0, err);

		err = fmctdc_channel_enable(tdc, i);
		m_assert_int_eq(0, err);

		err = fmctdc_execute_fmc_fdelay_pulse(fmcfd_dev_id,
						      i, 1, 0, 1000000,
						      t);
		m_assert_int_eq(0, err);

		p.fd = fmctdc_fileno_channel(tdc, i);
		p.events = POLLIN | POLLERR;
		ret = poll(&p, 1, timeout + 1);
		m_assert_int_eq(0, ret);
	}
}
static const char *fmctdc_op_test7_desc =
	"FineDelay generates, simultaneously, 1000000 pulse for each channel (1MHz). We test the IRQ coalesing timeout. We expect to receive timestamp after the timeout";


static void fmctdc_math_test1(struct m_test *m_test)
{
	struct fmctdc_time t;
	int i;

	for (i = 0; i < 30; ++i) { /* 30 to not overflow coarse (32bit) */
		t.seconds = i;
		t.coarse = 125000000 * i + 31;
		t.frac = 4096 * i + 13;
		fmctdc_ts_norm(&t);

		m_assert_int_eq(t.seconds, i * 2);
		m_assert_int_eq(t.coarse, 31 + i);
		m_assert_int_eq(t.frac, 13);
	}

}
static const char *fmctdc_math_test1_desc =
	"Validate timestamp normalization";


static void fmctdc_math_test2(struct m_test *m_test)
{
	struct fmctdc_time ret1, ret2, t1, t2;

	t1.seconds = random();
	t1.coarse = random();
	t1.frac = random();
	fmctdc_ts_norm(&t1);

	t2.seconds = t1.seconds + 1;
	t2.coarse = random();
	t2.frac = random();
	fmctdc_ts_norm(&t2);

	fmctdc_ts_add(&ret1, &t1, &t2);
	fmctdc_ts_norm(&ret1);
	fmctdc_ts_sub(&ret2, &ret1, &t2);

	m_assert_int_eq(t1.seconds, ret2.seconds);
	m_assert_int_eq(t1.coarse, ret2.coarse);
	m_assert_int_eq(t1.frac, ret2.frac);
}
static const char *fmctdc_math_test2_desc =
	"Validate timestamp albegra (t1 < t2 : t1 = t1 + t2 - t2)";

static void fmctdc_math_test3(struct m_test *m_test)
{
	struct fmctdc_time ret, t1;
	int neg;

	t1.seconds = random();
	t1.coarse = random();
	t1.frac = random();
	fmctdc_ts_norm(&t1);

	neg = fmctdc_ts_sub(&ret, &t1, &t1);
	m_assert_int_eq(0, neg);
	m_assert_int_eq(0, ret.seconds);
	m_assert_int_eq(0, ret.coarse);
	m_assert_int_eq(0, ret.frac);
}
static const char *fmctdc_math_test3_desc =
	"Validate timestamp albegra (t1 - t1 = 0)";

static void fmctdc_math_test4(struct m_test *m_test)
{
	struct fmctdc_time ret, t1, t2;
	int neg;

	t1.seconds = 10;
	t1.coarse = 10;
	t1.frac = 10;
	t2.seconds = 11;
	t2.coarse = 10;
	t2.frac = 10;

	neg = fmctdc_ts_sub(&ret, &t1, &t2);
	m_assert_int_eq(1, neg);
	m_assert_int_eq(1, ret.seconds);
	m_assert_int_eq(0, ret.coarse);
	m_assert_int_eq(0, ret.frac);

	neg = fmctdc_ts_sub(&ret, &t2, &t1);
	m_assert_int_eq(0, neg);
	m_assert_int_eq(1, ret.seconds);
	m_assert_int_eq(0, ret.coarse);
	m_assert_int_eq(0, ret.frac);


	t1.seconds = 10;
	t1.coarse = 10;
	t1.frac = 10;
	t2.seconds = 10;
	t2.coarse = 11;
	t2.frac = 10;

	neg = fmctdc_ts_sub(&ret, &t1, &t2);
	m_assert_int_eq(1, neg);
	m_assert_int_eq(0, ret.seconds);
	m_assert_int_eq(1, ret.coarse);
	m_assert_int_eq(0, ret.frac);

	neg = fmctdc_ts_sub(&ret, &t2, &t1);
	m_assert_int_eq(0, neg);
	m_assert_int_eq(0, ret.seconds);
	m_assert_int_eq(1, ret.coarse);
	m_assert_int_eq(0, ret.frac);


	t1.seconds = 10;
	t1.coarse = 10;
	t1.frac = 10;
	t2.seconds = 10;
	t2.coarse = 10;
	t2.frac = 11;

	neg = fmctdc_ts_sub(&ret, &t1, &t2);
	m_assert_int_eq(1, neg);
	m_assert_int_eq(0, ret.seconds);
	m_assert_int_eq(0, ret.coarse);
	m_assert_int_eq(1, ret.frac);

	neg = fmctdc_ts_sub(&ret, &t2, &t1);
	m_assert_int_eq(0, neg);
	m_assert_int_eq(0, ret.seconds);
	m_assert_int_eq(0, ret.coarse);
	m_assert_int_eq(1, ret.frac);
}
static const char *fmctdc_math_test4_desc =
	"Validate timestamp albegra (t1 < t2 : r = t1 - t2, r = t2 - t1)";



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
		m_test_desc(fmctdc_op_test_setup,
			    fmctdc_op_test6,
			    fmctdc_op_test_tear_down,
			    fmctdc_op_test6_desc),
		m_test_desc(fmctdc_op_test_setup,
			    fmctdc_op_test7,
			    fmctdc_op_test_tear_down,
			    fmctdc_op_test7_desc),
	};
	struct m_suite fmctdc_suite_op = m_suite("FMC TDC test: operation",
						 M_VERBOSE,
						 fmctdc_op_tests,
						 fmctdc_set_up,
						 fmctdc_tear_down);
	struct m_test fmctdc_math_tests[] = {
		m_test_desc(NULL, fmctdc_math_test1, NULL,
			    fmctdc_math_test1_desc),
		m_test_desc_loop(NULL, fmctdc_math_test2, NULL,
				 fmctdc_math_test2_desc,
				 100),
		m_test_desc_loop(NULL, fmctdc_math_test3, NULL,
				 fmctdc_math_test3_desc,
				 100),
		m_test_desc(NULL, fmctdc_math_test4, NULL,
			    fmctdc_math_test4_desc),
	};
	struct m_suite fmctdc_suite_math = m_suite("FMC TDC test: math",
						   M_VERBOSE,
						   fmctdc_math_tests,
						   NULL,
						   NULL);

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

	m_suite_run(&fmctdc_suite_math);

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
