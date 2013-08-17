/*
 * The fmc-tdc (a.k.a. FmcTdc1ns5cha) library test program.
 *
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation or, at your
 * option, any later version.
 *
 * test-common.c: some shared routines
 */

#include "test-common.h"

int n_boards;
struct fmctdc_board *brd = NULL;

void usage_msg(const char *name, const char *msg)
{
	printf("usage: %s %s\n", name, msg);
	exit(0);
}

void open_board(char *dev_id_str)
{
	unsigned int dev_id;

	if (sscanf(dev_id_str, "%04x", &dev_id) != 1) {
		fprintf(stderr, "Error parsing device ID %s\n", dev_id_str);
		exit(-1);
	}

	brd = fmctdc_open(-1, dev_id);
	if (!brd) {
		fprintf(stderr, "Can't open device %s: %s\n", dev_id_str,
			strerror(errno));
		exit(-1);
	}
}

void check_help(int argc, char **argv, int min_args, char *usage, char *desc,
		char *options)
{
	if (argc >= 2 && !strcmp(argv[1], "-h")) {
		printf("%s: %s\n", argv[0], desc);
		printf("usage: %s %s\n", argv[0], usage);
		printf("%s\n", options);
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
