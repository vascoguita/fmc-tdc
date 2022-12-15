/*
 * The fmc-tdc (a.k.a. FmcTdc1ns5cha) library test program.
 *
 * Copyright (c) 2014-2018 CERN
* Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "test-common.h"

char git_version[] = "git version: " GIT_VERSION;

void perror_hint ( const char *func )
{
	perror(func);
	fprintf(stderr, "Hint: are trying to change time while acquisition is enabled?\n");
}

int main(int argc, char **argv)
{
	struct fmctdc_time ts;
	char *cmd;

	init(argc, argv);
	memset(&ts, 0, sizeof(ts));

	check_help(argc, argv, 3,
			"[-h] [-V] <device> <command> [timeval]",
		   	"Gets/sets the mezzanine TAI time and controls White Rabbit timing.",
		   	"Commands are:\n"
			"     get                    - shows current time and White Rabbit status.\n"
			"     set <seconds>          - sets current board time.\n"
		   	"     local                  - sets the time source to the card's local oscillator.\n"
			"     wr                     - sets the time source to White Rabbit.\n"
			"     host                   - sets the time source to local oscillator and coarsely\n"
			"                              synchronizes the card to the system clock.\n");

	open_board(argv[1]);

	cmd = argv[2];

	if (!strcmp(cmd, "get")) {
		if (fmctdc_get_time(brd, &ts) < 0) {
			perror("fmctdc_get_time()");
			return -1;
		}

		int err = fmctdc_check_wr_mode(brd);
		printf("WR Status: ");
		switch(err)
		{
			case ENODEV:	printf("disabled.\n"); break;
			case ENOLINK:	printf("link down.\n"); break;
			case EAGAIN:	printf("synchronization in progress.\n"); break;
			case 0:		printf("synchronized.\n"); break;
			default:	printf("error: %s\n", strerror(err)); break;
		}
		printf("Current TAI time is %llu.%09u s\n", (unsigned long long) ts.seconds,
		       ts.coarse * 8);
	} else if (!strcmp(cmd, "set")) {
		if (argc < 4) {
			fprintf(stderr, "%s: time value expected\n", argv[0]);
		}

		ts.coarse = 0;
		sscanf(argv[3], "%"SCNu64, &ts.seconds);

		if (fmctdc_set_time(brd, &ts) < 0) {
			perror_hint("fmctdc_set_time()");
			return -1;
		}
	} else if (!strcmp(cmd, "host")) {
		if (fmctdc_set_host_time(brd) < 0) {
			perror_hint("fmctdc_set_host_time()");
			return -1;
		}
	} else if (!strcmp(cmd, "wr")) {
		
		int err = fmctdc_wr_mode(brd, 1);

		if(err == ENOTSUP)
		{
			fprintf(stderr, "%s: no support for White Rabbit (check the gateware).\n",
				argv[0]);
			exit(1);
		} else if (err) {
			perror_hint("fmctdc_wr_mode()");
			exit(1);
		}

		setbuf(stdout, NULL);
		printf("Locking the card to WR: ");

		while ((err = fmctdc_check_wr_mode(brd)) != 0) {
			if( err == ENOLINK ) {
				fprintf(stderr, "\n%s: no White Rabbit link (check the cable and the switch).\n",
					argv[0]);
				return -1;
			}
			printf(".");
			sleep(1);
		}

		printf(" locked!\n");
	} else if (!strcmp(cmd, "local"))
	{
		int err = fmctdc_wr_mode(brd, 0);
		if(err < 0) {
			perror_hint("fmctdc_wr_mode()");
			return -1;
		}

		return 0;
	} else {
		fprintf(stderr, "%s: unrecognized command.\n", cmd);
		return -1;
	}

	return 0;
}
