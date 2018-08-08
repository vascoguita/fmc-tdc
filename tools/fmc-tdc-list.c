/*
 * The fmc-tdc (a.k.a. FmcTdc1ns5cha) library test program.
 *
 * Copyright (c) 2014-2018 CERN
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "test-common.h"

char git_version[] = "git version: " GIT_VERSION;

int main(int argc, char **argv)
{
	int i;

	init(argc, argv);

	check_help(argc, argv, 1,
		   "[-h] [-V]", "lists all installed fmc-tdc boards.", "");

	printf("Found %i board(s): \n", n_boards);

	for (i = 0; i < n_boards; i++) {
		struct __fmctdc_board *b;
		struct fmctdc_board *ub;

		ub = fmctdc_open(i, -1);
		b = (typeof(b)) ub;
		printf("%04x, %s, %s\n", b->dev_id, b->devbase, b->sysbase);
	}
	return 0;
}
