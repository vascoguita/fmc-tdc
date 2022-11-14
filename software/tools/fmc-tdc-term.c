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

int main(int argc, char **argv)
{
	init(argc, argv);

	check_help(argc, argv, 2,
		   "[-h] [-V] <device> <channel> [on/off]",
		   "Enables or disables the 50 Ohm termination of a given input channel.\n"
		   "No on/off command returns the current state of termination resistor.",
		   "");;

	open_board(argv[1]);

	if (argc == 2) {
		int i;
		for (i = FMCTDC_CH_1; i <= FMCTDC_CH_LAST; i++)
			printf("channel %d: 50 Ohm termination is %s\n", i,
			       fmctdc_get_termination(brd, i) ? "on" : "off");
		return 0;
	}

	int channel = atoi(argv[2]);

	if (channel < FMCTDC_CH_1 || channel > FMCTDC_CH_LAST) {
		fprintf(stderr, "%s: invalid channel.\n", argv[0]);
		return -1;
	}

	if (argc >= 4) {
		int term_on;
		if (!strcasecmp(argv[3], "on"))
			term_on = 1;
		else if (!strcasecmp(argv[3], "off"))
			term_on = 0;
		else {
			fprintf(stderr, "%s: invalid command.\n", argv[0]);
			return -1;
		}

		if (fmctdc_set_termination(brd, channel, term_on) < 0) {
			fprintf(stderr, "%s: error setting termination: %s\n",
				argv[0], strerror(errno));
			return -1;
		}
	}

	printf("channel %d: 50 Ohm termination is %s\n", channel,
	       fmctdc_get_termination(brd, channel) ? "on" : "off");

	return 0;
}
