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
 * fmctdc-read: read timestamps from a given FmcTdc card.
 */

#include <inttypes.h>
#include "test-common.h"

void dump_timestamp(struct fmctdc_time ts, int channel, int fmt_wr)
{
	if (fmt_wr)
		printf("channel %d seq %-12u ts %10"PRIu64":%09u:%04u\n", channel,
		       ts.seq_id, ts.seconds, ts.coarse, ts.frac);
	else {
		uint64_t picoseconds =
		    (uint64_t) ts.coarse * 8000ULL +
		    (uint64_t) ts.frac * 8000ULL / 4096ULL;
		printf
		    ("channel %d seq %-12u ts %10"PRIu64".%03llu,%03llu,%03llu,%03llu ps\n",
		     channel, ts.seq_id, ts.seconds,
		     picoseconds / 1000000000ULL,
		     (picoseconds / 1000000ULL) % 1000ULL,
		     (picoseconds / 1000ULL) % 1000ULL, picoseconds % 1000ULL);
	}

}

int main(int argc, char **argv)
{
	int channels[FMCTDC_NUM_CHANNELS];
	int chan_count = 0, i, n;
	int non_block = 0;
	int n_samples = -1;
	int fmt_wr = 0;
	int stop = 0;
	char opt;
	fd_set rfds;

	init(argc, argv);

	check_help(argc, argv, 2,
		   "[options]  <device> [channels]",
		   "reads timestamps from the selected fmc-tdc channels. No [channels] means all channels.",
		   "Options are:\n"
		   "  -n:           non-blocking mode\n"
		   "  -s n_samples: keep reading until n_samples timestamps\n"
		   "  -w:           dump timestamps in hardware (White Rabbit) format\n"
		   "  -h:           print this message\n");

	while ((opt = getopt(argc, argv, "wns:")) != -1) {
		switch (opt) {
		case 's':
			sscanf(optarg, "%i", &n_samples);
			break;
		case 'n':
			non_block = 1;
			break;
		case 'w':
			fmt_wr = 1;
			break;
		}
	}

	if (optind >= argc) {
		fprintf(stderr, "%s: device ID expected\n", argv[0]);
		return -1;
	}

	open_board(argv[optind++]);

	memset(channels, 0, sizeof(channels));

	/* parse channel list */
	while (optind < argc) {
		int ch = atoi(argv[optind]);

		if (ch < FMCTDC_CH_1 || ch > FMCTDC_CH_LAST) {
			fprintf(stderr, "%s: invalid channel.\n", argv[0]);
			return -1;
		}

		optind++;
		channels[ch - FMCTDC_CH_1] = fmctdc_fileno_channel(brd, ch);

		chan_count++;
	}

	if (!chan_count) {
		for (i = FMCTDC_CH_1; i <= FMCTDC_CH_LAST; i++)
			channels[i - FMCTDC_CH_1] =
			    fmctdc_fileno_channel(brd, i);
		chan_count = FMCTDC_NUM_CHANNELS;
	}

	n = 0;

	while (!stop) {
		int nfds = 0;
		struct fmctdc_time ts;
		stop = 1;

		FD_ZERO(&rfds);

		for (i = FMCTDC_CH_1; i <= FMCTDC_CH_LAST; i++) {
			int fd = channels[i - FMCTDC_CH_1];
			
			if (fd < 0) {
				fprintf(stderr, "Can't open channel %d\n", i);
				return -1;
			} else if (fd > 0) {
				FD_SET(fd, &rfds);
				nfds = fd > nfds ? fd : nfds;
			}
				
		}

		/* non-blocking mode: do nothing, otherwise wait until one of the channels becomes active */
		if (!non_block
		    && select(nfds + 1, &rfds, NULL, NULL, NULL) <= 0)
			continue;

		for (i = FMCTDC_CH_1; i <= FMCTDC_CH_LAST; i++) {
			int fd = channels[i - FMCTDC_CH_1];

			if (fd > 0) {
				int got_data = 0;

				if (non_block || FD_ISSET(fd, &rfds))
					got_data =
					    fmctdc_read(brd, i, &ts, 1,
							non_block ? O_NONBLOCK :
							0) == 1;

				if (got_data) {
					dump_timestamp(ts, i, fmt_wr);
					n++;
					if (n < n_samples || n_samples <= 0)
						stop = 0;
				}
			}
		}
	}

	return 0;
}
