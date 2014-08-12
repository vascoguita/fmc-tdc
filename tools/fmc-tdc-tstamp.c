/*
 * Copyright (c) 2014 CERN
 * Author: Federico Vaga <federico.vaga@cern.ch>
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation or, at your
 * option, any later version.
 *
 * fmctdc-tstamp: read timestamps from a given FmcTdc card.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <libgen.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>

#include <getopt.h>

#include "fmctdc-lib.h"

/* Previous time stamp for each channel */
struct fmctdc_time ts_prev[FMCTDC_NUM_CHANNELS];


void dump_timestamp(struct fmctdc_time ts, int fmt_wr)
{
	uint64_t picoseconds;

	if (fmt_wr) {
		/* White rabbit format */
		fprintf(stdout, "%10llu:%09u:%04u",
			ts.seconds, ts.coarse, ts.frac);
		return;
	} else {
		picoseconds = (uint64_t) ts.coarse * 8000ULL +
			      (uint64_t) ts.frac * 8000ULL / 4096ULL;
		fprintf(stdout,
			"%010llu.%03llu,%03llu,%03llu,%03llu ps",
			ts.seconds,
			picoseconds / 1000000000ULL,
			(picoseconds / 1000000ULL) % 1000ULL,
			(picoseconds / 1000ULL) % 1000ULL, picoseconds % 1000ULL);
	}
}

void dump(unsigned int ch, struct fmctdc_time *ts, int fmt_wr)
{
	struct fmctdc_time ts_tmp;
	uint64_t ns;
	double s, hz;

	fprintf(stdout, "channel %d seq %-12u\n    ts   ", ch, ts->seq_id);
	dump_timestamp(*ts, fmt_wr);
	fprintf(stdout, "\n");

	ts_tmp = *ts;
	fmctdc_ts_sub(&ts_tmp, &ts_prev[ch]);

	fprintf(stdout, "    diff ");
	dump_timestamp(ts_tmp, fmt_wr);

	ns  = (uint64_t) ts_tmp.coarse * 8ULL;
	ns += (uint64_t) (ts_tmp.frac * 8000ULL / 4096ULL) / 1000ULL;
	s = ts_tmp.seconds + ((double)ns/1000000000ULL);
	hz = 1/s;
	fprintf(stdout, " [%f Hz]\n", hz);
}

/* Print help message */
static void help(char *name)
{
	fprintf(stderr, "%s [options] <device> [channels]\n", basename(name));
	fprintf(stderr,
		"reads timestamps from fmc-tdc channels. No [channels] means all channels.\n\n");
	fprintf(stderr, "Options are:\n");
	fprintf(stderr, "  -n          : non-blocking mode\n");
	fprintf(stderr, "  -s n_samples: dump 'n_samples' timestamps\n");
	fprintf(stderr, "  -w          : user White Rabbit format\n");
	fprintf(stderr, "  -h:           print this message\n\n");
}


int main(int argc, char **argv)
{
	struct fmctdc_board *brd;
	unsigned int dev_id;
	struct fmctdc_time ts;
	int channels[FMCTDC_NUM_CHANNELS];
	int chan_count = 0, i, n, ch, nfds, fd, byte_read, ret, n_boards;
	int nblock = 0;
	int n_samples = -1;
	int fmt_wr = 0;
	char opt;
	fd_set rfds;

	atexit(fmctdc_exit);

	/* Initialize FMC TDC library */
	n_boards = fmctdc_init();
	if (n_boards < 0) {
		fprintf(stderr, "%s: fmctdc_init(): %s\n", argv[0],
			strerror(errno));
		exit(1);
	}


	/* Parse Options */
	while ((opt = getopt(argc, argv, "hwns:")) != -1) {
		switch (opt) {
		case 'h':
		case '?':
			help(argv[0]);
			exit(EXIT_SUCCESS);
			break;
		case 's':
			sscanf(optarg, "%i", &n_samples);
			break;
		case 'n':
			nblock = 1;
			break;
		case 'w':
			fmt_wr = 1;
			break;
		}
	}
	if (optind >= argc) {
		help(argv[0]);
		exit(EXIT_FAILURE);
	}
	if (sscanf(argv[optind], "0x%04x", &dev_id) != 1) {
		fprintf(stderr, "Error parsing device ID %s\n", argv[optind]);
		exit(EXIT_FAILURE);
	}
	optind++;


	/* Open FMC TDC device */
	brd = fmctdc_open(0, dev_id); /* look for dev_id form the beginning */
	if (!brd) {
		fprintf(stderr, "Can't open device 0x%x: %s\n", dev_id,
			strerror(errno));
		exit(EXIT_FAILURE);
	}


	/* Open Channels from command line */
	memset(channels, 0, sizeof(channels));
	while (optind < argc) {
		ch = atoi(argv[optind]);

		if (ch < FMCTDC_CH_1 || ch > FMCTDC_CH_LAST) {
			fprintf(stderr, "%s: invalid channel.\n", argv[0]);
			fmctdc_close(brd);
			exit(EXIT_FAILURE);
		}
		channels[ch - FMCTDC_CH_1] = fmctdc_fileno_channel(brd, ch);

		chan_count++;
		optind++;
	}
	/* If there are not channels, then dump them all */
	if (!chan_count) {
		for (i = FMCTDC_CH_1; i <= FMCTDC_CH_LAST; i++)
			channels[i - FMCTDC_CH_1] =
			    fmctdc_fileno_channel(brd, i);
		chan_count = FMCTDC_NUM_CHANNELS;
	}


	/* Read Time-Stamps */
	n = 0;
	while (n < n_samples || n_samples <= 0) {
		nfds = 0;

		/* Prepare the list of channel to observe */
		FD_ZERO(&rfds);
		for (i = FMCTDC_CH_1; i <= FMCTDC_CH_LAST; i++) {
			fd = channels[i - FMCTDC_CH_1];
			if (fd < 0) {
				fprintf(stderr, "Can't open channel %d\n", i);
				exit(EXIT_FAILURE);
			} else {
				FD_SET(fd, &rfds);
				nfds = fd > nfds ? fd : nfds;
			}
		}

		/* non-blocking mode: do nothing, otherwise wait until one
		   of the channels becomes active */
		ret = select(nfds + 1, &rfds, NULL, NULL, NULL);
		if (!nblock && ret <= 0) {
			if (ret < 0)
				fprintf(stderr,
					"Error while waiting for timestamp: %s",
					strerror(errno));
			continue;
		}

		/* Now we can read the timestamp */
		for (i = FMCTDC_CH_1; i <= FMCTDC_CH_LAST; i++) {
			fd = channels[i - FMCTDC_CH_1];
			if (fd < 0)
				continue;

			if (!(nblock || FD_ISSET(fd, &rfds)))
				continue;

			byte_read = fmctdc_read(brd, i, &ts, 1,
						nblock ? O_NONBLOCK : 0);
			if (byte_read > 0) {
				dump(i, &ts, fmt_wr);

				ts_prev[i] = ts;
				n++;
			}
		}
	}

	fmctdc_close(brd);
	exit(EXIT_SUCCESS);
}
