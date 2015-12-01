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
 * fmctdc-time: read board temperature
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
