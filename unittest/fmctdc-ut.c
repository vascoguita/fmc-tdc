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
	/* First Test */
}
static const char *fmctdc_param_test1_desc = "";


int main(int argc, char *argv[])
{
	struct m_test fmctdc_param_tests[] = {
		m_test_desc(NULL, fmctdc_param_test1, NULL,
			    fmctdc_param_test1_desc),
	};
	struct m_suite fmctdc_suite = m_suite("FMC TDC test: parameters", 0,
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
