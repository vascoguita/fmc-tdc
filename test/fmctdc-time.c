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
 * fmctdc-time: get/set board time
 */

#include "test-common.h"

int main(int argc, char **argv)
{
	struct fmctdc_time ts;
	char *cmd;

	init(argc, argv);

	check_help(argc, argv, 3,
		   "[-h] <device> <command> [timeval]",
		   "Gets/sets the mezzanine TAI time.",
		   "Commands are:"
		   "get     		- prints current TAI time"
		   "set <seconds>		- sets TAI time"
		   "host			- sets TAI time to current host time");

	open_board(argv[1]);

	cmd = argv[2];

	if (!strcmp(cmd, "get")) {
		if (fmctdc_get_time(brd, &ts) < 0) {
			perror("fmctdc_get_time()");
			return -1;
		}
		printf("Current TAI time is %lld.%09d s\n", ts.seconds,
		       ts.coarse * 8);
	} else if (!strcmp(cmd, "set")) {
		if (argc < 4) {
			fprintf(stderr, "%s: time value expected\n", argv[0]);
		}

		ts.coarse = 0;
		ts.seconds = atoi(argv[3]);

		if (fmctdc_set_time(brd, &ts) < 0) {
			perror("fmctdc_set_time()");
			fprintf(stderr,
				"Hint: are trying to change time while acquisition is enabled?\n");
			return -1;
		}
	} else if (!strcmp(cmd, "host")) {
		if (fmctdc_set_host_time(brd) < 0) {
			perror("fmctdc_set_host_time()");
			fprintf(stderr,
				"Hint: are trying to change time while acquisition is enabled?\n");
			return -1;
		}
	} else {
		fprintf(stderr, "%s: unrecognized command.\n", cmd);
		return -1;
	}

	return 0;
}
