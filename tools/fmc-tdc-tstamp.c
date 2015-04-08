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
#include <inttypes.h>

#include <getopt.h>

#include "fmctdc-lib.h"

/* Previous time stamp for each channel */
struct fmctdc_time ts_prev[FMCTDC_NUM_CHANNELS];


void dump_timestamp(struct fmctdc_time ts, int fmt_wr)
{
	uint64_t picoseconds;

	if (fmt_wr) {
		/* White rabbit format */
		fprintf(stdout, "%10"PRIu64":%09u:%04u",
			ts.seconds, ts.coarse, ts.frac);
		return;
	} else {
		picoseconds = (uint64_t) ts.coarse * 8000ULL +
			      (uint64_t) ts.frac * 8000ULL / 4096ULL;
		fprintf(stdout,
			"%010"PRIu64"s  %012"PRIu64"ps",
			ts.seconds, picoseconds);
	}
}

void dump(unsigned int ch, struct fmctdc_time *ts, int fmt_wr, int diff_mode)
{
	struct fmctdc_time ts_tmp;
	uint64_t ns;
	double s, hz;

	fprintf(stdout, "channel %d | channel seq %-12u | board seq %-12u\n    ts   ",
		ch, ts->seq_id, ts->gseq_id);
	dump_timestamp(*ts, fmt_wr);
	fprintf(stdout, "\n");

	ts_tmp = *ts;
	fmctdc_ts_sub(&ts_tmp, &ts_prev[ch]);

	if (diff_mode) {
		fprintf(stdout, "    refer to board seq %-12u\n", ts->ref_gseq_id);
		return;
	}

	/* We are in normal mode, calculate the difference */
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
	fprintf(stderr, "  -d <ch_ref>,<ch_tar>: difference between a reference channel and\n");
	fprintf(stderr, "                        a target channel (<ch_tar> - <ch_ref>)\n");
	fprintf(stderr, "  -f:           flush buffer\n");
	fprintf(stderr, "  -r:           read buffer, no acquisition start\n");
	fprintf(stderr, "  -h:           print this message\n\n");
	fprintf(stderr, " channels enumerations go from %d to %d \n\n",
		FMCTDC_CH_1, FMCTDC_CH_LAST);
}

static void tstamp_flush(struct fmctdc_board *brd, int ch, int flush)
{
	int ret;

	if (!flush)
		return;

	ret = fmctdc_flush(brd, ch);
	if (ret)
		fprintf(stderr,
			"fmc-tdc-tstamp: failed to flush channel %d: %s\n",
			ch, fmctdc_strerror(errno));
}

int main(int argc, char **argv)
{
	struct fmctdc_board *brd;
	unsigned int dev_id;
	struct fmctdc_time ts;
	int channels[FMCTDC_NUM_CHANNELS];
	int ref[FMCTDC_NUM_CHANNELS], a, b;
	int chan_count = 0, i, n, ch, nfds, fd, byte_read, ret, n_boards;
	int nblock = 0;
	int n_samples = -1;
	int fmt_wr = 0, flush = 0, read = 0;
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

	for (i = 0; i < FMCTDC_NUM_CHANNELS; ++i)
		ref[i] = -1;

	/* Parse Options */
	while ((opt = getopt(argc, argv, "hwns:d:fr")) != -1) {
		switch (opt) {
		case 'h':
		case '?':
			help(argv[0]);
			exit(EXIT_SUCCESS);
			break;
		case 'f':
			flush = 1;
			break;
		case 'r':
			read = 1;
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
		case 'd':
			sscanf(optarg, "%i,%i", &a, &b);
			if (a < 0 || a > FMCTDC_CH_LAST) {
				fprintf(stderr,
					"%s: invalid reference channel %d\n",
					argv[0], a);
				help(argv[0]);
				exit(EXIT_FAILURE);
			}
			if (b < 0 || b > FMCTDC_CH_LAST) {
				fprintf(stderr,
					"%s: invalid target channel %d\n",
					argv[0], b);
				help(argv[0]);
				exit(EXIT_FAILURE);
			}
			ref[b] = a;
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
	brd = fmctdc_open(-1, dev_id); /* look for dev_id form the beginning */
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
		channels[ch] = fmctdc_fileno_channel(brd, ch);
		tstamp_flush(brd, ch, flush);
		chan_count++;
		optind++;
	}
	/* If there are not channels, then dump them all */
	if (!chan_count) {
		for (i = 0; i < FMCTDC_NUM_CHANNELS; i++) {
			tstamp_flush(brd, ch, flush);
			channels[i] =
				fmctdc_fileno_channel(brd, i);
			ret = fmctdc_reference_set(brd, i, ref[i]);
			if (ret) {
				fprintf(stderr,
					"%s: cannot set reference mode: %s\n",
					argv[0], fmctdc_strerror(errno));
				fprintf(stderr,
					"%s: continue in normal mode: %s\n",
					argv[0], fmctdc_strerror(errno));
				ref[i] = -1;
			}
		}
		chan_count = i;
	}


	/* Enable acquisition */
	if (!read)
		fmctdc_set_acquisition(brd, 1);
	/* Read Time-Stamps */
	n = 0;
	while (n < n_samples || n_samples <= 0) {
		nfds = 0;

		/* Prepare the list of channel to observe */
		FD_ZERO(&rfds);
		for (i = 0; i <= FMCTDC_CH_LAST; i++) {
			fd = channels[i];
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
		for (i = 0; i <= FMCTDC_CH_LAST; i++) {
			fd = channels[i];
			if (fd < 0)
				continue;

			if (!(nblock || FD_ISSET(fd, &rfds)))
				continue;

			byte_read = fmctdc_read(brd, i, &ts, 1,
						nblock ? O_NONBLOCK : 0);
			if (byte_read > 0) {
				dump(i, &ts, fmt_wr, ref[i] < 0 ? 0 : 1);

				ts_prev[i] = ts;
				n++;
			}
		}
	}

	/* Restore default time-stamping */
	for (i = 0; i <= FMCTDC_CH_LAST; i++) {
		if (channels[i] > 0)
			fmctdc_reference_clear(brd, -1);
	}
	/* Disable acquisition */
	if (!read)
		fmctdc_set_acquisition(brd, 0);

	fmctdc_close(brd);
	exit(EXIT_SUCCESS);
}
