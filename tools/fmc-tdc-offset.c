/*
 * Copyright (C) 2014-2018 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include <inttypes.h>
#include "test-common.h"

char git_version[] = "git version: " GIT_VERSION;

int main(int argc, char **argv)
{
	int32_t offset;
	int err, ret, i, channel, ch_start = FMCTDC_CH_1, ch_end = FMCTDC_CH_LAST;

	init(argc, argv);

	check_help(argc, argv, 2,
		   "[-h] [-V] <device> <channel> [offset-ps]",
		   "It sets or gets the user-offset applied to the incoming timestamps\n",
		   "");
	open_board(argv[1]);


	if (argc >= 3) {
		channel = atoi(argv[2]);
		if (channel < FMCTDC_CH_1 || channel > FMCTDC_CH_LAST) {
			fprintf(stderr, "%s: invalid channel.\n", argv[0]);
			return -1;
		}
		ch_start = channel;
		ch_end = channel;
	}

	if (argc >= 4) {
		ret = sscanf(argv[3], "%"SCNi32, &offset);
		if (ret != 1) {
			fprintf(stderr, "%s: invalid command.\n", argv[0]);
			return -1;
		}
		err = fmctdc_set_offset_user(brd, channel, offset);
		if (err) {
			fprintf(stderr, "%s: error setting the user-offset: %s\n",
				argv[0], strerror(errno));
			return -1;
		}
	}

	for (i = ch_start; i <= ch_end; i++) {
		err = fmctdc_get_offset_user(brd, i, &offset);
		if (err)
			printf("channel %d: ERROR\n", i);
		else
			printf("channel %d: %d ps\n", i, offset);
	}

	return 0;
}
