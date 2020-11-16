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
	init(argc, argv);

	check_help(argc, argv, 2,
		   "[-h] [-V] <device>",
		   "Displays current temperature of the mezzanine.\n", "");

	open_board(argv[1]);

	printf("%.1f deg C\n", fmctdc_read_temperature(brd));

	return 0;
}
