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
#include <poll.h>
#include <signal.h>

#include <getopt.h>

#include "fmctdc-lib.h"

/* Previous time stamp for each channel */
struct fmctdc_time ts_prev[FMCTDC_NUM_CHANNELS];
static unsigned int stop = 0, fmt_wr = 0;


void dump_timestamp(struct fmctdc_time ts)
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

void dump(unsigned int ch, struct fmctdc_time *ts, int diff_mode)
{
	struct fmctdc_time ts_tmp;
	uint64_t ns;
	double s, hz;

	fprintf(stdout,
		"channel %d | channel seq %-12u | board seq %-12u\n    ts   ",
		ch, ts->seq_id, ts->gseq_id);
	dump_timestamp(*ts);
	fprintf(stdout, "\n");

	ts_tmp = *ts;
	fmctdc_ts_sub(&ts_tmp, &ts_prev[ch]);

	if (diff_mode) {
		fprintf(stdout, "    refer to board seq %-12u\n",
			ts->ref_gseq_id);
		return;
	}

	/* We are in normal mode, calculate the difference */
	fprintf(stdout, "    diff ");
	dump_timestamp(ts_tmp);

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
	fprintf(stderr, "  -m:           buffer mode: 'fifo' or 'circ'\n");
	fprintf(stderr, "  -l:           maximum buffer lenght\n");
	fprintf(stderr, "  -h:           print this message\n\n");
	fprintf(stderr, " channels enumerations go from %d to %d \n\n",
		FMCTDC_CH_1, FMCTDC_CH_LAST);
}


static void termination_handler(int signum)
{
	fprintf(stderr, "\nfmc-tdc-tstamp: killing application\n");
	stop = 1;
}

int main(int argc, char **argv)
{
	struct fmctdc_board *brd;
	unsigned int dev_id;
	struct fmctdc_time ts;
	int channels[FMCTDC_NUM_CHANNELS];
	int ref[FMCTDC_NUM_CHANNELS], a, b;
	int chan_count = 0, i, n, ch, fd, byte_read, ret, n_boards;
	int nblock = 0, buflen = 16;
	enum fmctdc_buffer_mode bufmode = FMCTDC_BUFFER_FIFO;
	int n_samples = -1;
	int fmt_wr = 0, flush = 0, read = 0, last = 0;
	char opt;
	struct sigaction new_action, old_action;
	int ch_valid[FMCTDC_NUM_CHANNELS] = {0, 1, 2, 3, 4};
	struct pollfd p[FMCTDC_NUM_CHANNELS];

	/* Set up the structure to specify the new action. */
	new_action.sa_handler = termination_handler;
	sigemptyset (&new_action.sa_mask);
	new_action.sa_flags = 0;

	sigaction (SIGINT, NULL, &old_action);
	if (old_action.sa_handler != SIG_IGN)
		sigaction (SIGINT, &new_action, NULL);
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
	while ((opt = getopt(argc, argv, "hwns:d:frm:l:c:")) != -1) {
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
		case 'm':
		        if (strcmp(optarg, "fifo") == 0) {
				bufmode = FMCTDC_BUFFER_FIFO;
			} else if (strcmp(optarg, "circ") == 0) {
				bufmode = FMCTDC_BUFFER_CIRC;
			} else {
				help(argv[0]);
				exit(EXIT_SUCCESS);
			}
			break;
		case 'l':
			sscanf(optarg, "%i", &buflen);
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
		case 'c':
			if (chan_count >= FMCTDC_NUM_CHANNELS) {
				fprintf(stderr,
					"%s: too many channels, maximum %d\n",
					argv[0],  FMCTDC_NUM_CHANNELS);
				break;
			}
			sscanf(optarg, "%i", &ch_valid[chan_count++]);
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
	if (!chan_count)
		chan_count = FMCTDC_NUM_CHANNELS;
	for (i = 0; i < chan_count; i++) {
		ch = ch_valid[i];
		if (flush) {
			ret = fmctdc_flush(brd, ch);
			if (ret)
				fprintf(stderr,
					"fmc-tdc-tstamp: failed to flush channel %d: %s\n",
					ch, fmctdc_strerror(errno));
		}

		channels[ch] = fmctdc_fileno_channel(brd, ch);

		p[ch].fd = channels[ch];
		p[ch].events = POLLIN | POLLERR;

		ret = fmctdc_reference_set(brd, ch, ref[ch]);
		if (ret) {
			fprintf(stderr,
				"%s: cannot set reference mode: %s\n",
				argv[0], fmctdc_strerror(errno));
			fprintf(stderr,
				"%s: continue in normal mode: %s\n",
				argv[0], fmctdc_strerror(errno));
			ref[ch] = -1;
		}

		/* set buffer mode */
		ret = fmctdc_set_buffer_mode(brd, ch, bufmode);
		if (ret) {
			fprintf(stderr,
				"%s: chan %d: cannot set buffer mode: %s. Use default\n",
				argv[0], ch, fmctdc_strerror(errno));
		}

		/* set buffer lenght */
		ret = fmctdc_set_buffer_len(brd, ch, buflen);
		if (ret) {
			fprintf(stderr,
				"%s: chan %d: cannot set buffer lenght: %s. Use default\n",
				argv[0], ch, fmctdc_strerror(errno));
		}

		if (!read)
			ret = fmctdc_channel_enable(brd, ch);
		if (ret)
			fprintf(stderr,
				"%s: chan %d: cannot enable acquisition: %s.\n",
				argv[0], i, fmctdc_strerror(errno));
	}


	/* Read Time-Stamps */
	n = 0;
	while ((n < n_samples || n_samples <= 0) && (!stop)) {
		if (!nblock) {
			ret = poll(p, FMCTDC_NUM_CHANNELS, 10);
			if (ret <= 0)
				continue;
		}

		/* Now we can read the timestamp */
		for (i = 0; i < chan_count; i++) {
			fd = channels[ch_valid[i]];
			if (fd < 0)
				continue;

			if (!(p[ch_valid[i]].revents & POLLIN))
				continue;
			byte_read = fmctdc_read(brd, i, &ts, 1,
						nblock ? O_NONBLOCK : 0);
			if (byte_read > 0) {
				dump(i, &ts, ref[i] < 0 ? 0 : 1);

				ts_prev[i] = ts;
				n++;
			}
		}
	}

	/* Restore default time-stamping */
	for (i = 0; i <= FMCTDC_CH_LAST; i++) {
		if (channels[i] > 0)
			fmctdc_reference_clear(brd, -1);
		if (!read)
			ret = fmctdc_channel_disable(brd, i);
		if (ret)
			fprintf(stderr,
				"%s: chan %d: cannot disable acquisition: %s.\n",
				argv[0], i, fmctdc_strerror(errno));
	}

	fmctdc_close(brd);
	exit(EXIT_SUCCESS);
}
