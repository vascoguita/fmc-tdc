/*
 * The fmc-tdc (a.k.a. FmcTdc1ns5cha) library test program.
 *
 * Copyright (c) 2014-2018 CERN
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "test-common.h"

extern char git_version[];
int n_boards;
struct fmctdc_board *brd = NULL;

void open_board(char *dev_id_str)
{
	unsigned int dev_id;

	if (sscanf(dev_id_str, "%04x", &dev_id) != 1) {
		fprintf(stderr, "Error parsing device ID %s\n", dev_id_str);
		exit(-1);
	}


	brd = fmctdc_open(dev_id);
	if (!brd) {
		fprintf(stderr, "Can't open device %s: %s\n", dev_id_str,
			strerror(errno));
		exit(-1);
	}
}

static void print_version(char *pname)
{
	printf("%s %s\n", pname, git_version);
	printf("%s\n", libfmctdc_version_s);
	printf("%s\n", libfmctdc_zio_version_s);
}

void check_help(int argc, char **argv, int min_args, char *usage, char *desc,
		char *options)
{
	if (argc >= 2 && !strcmp(argv[1], "-h")) {
		printf("%s: %s\n", argv[0], desc);
		printf("usage: %s %s\n", argv[0], usage);
		printf("%s\n", options);
		exit(0);
	} else if ((argc >= 2) && (!strcmp(argv[1], "-V"))) {
		print_version(argv[0]);
		exit(0);
	} else if (argc < min_args) {
		printf("usage: %s %s\n", argv[0], usage);
		exit(0);
	}
}

static void cleanup()
{
	if (brd)
		fmctdc_close(brd);
	fmctdc_exit();
}

void init(int argc, char *argv[])
{
	n_boards = fmctdc_init();
	if (n_boards < 0) {
		fprintf(stderr, "%s: fmctdc_init(): %s\n", argv[0],
			strerror(errno));
		exit(1);
	}

	atexit(cleanup);
}
