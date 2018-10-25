/*
 * Copyright (c) 2014-2018 CERN
 * Author: Federico Vaga <federico.vaga@cern.ch>
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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
#include <time.h>

#include <getopt.h>

#include "fmctdc-lib.h"

char git_version[] = "git_version: " GIT_VERSION;

/* Previous time stamp for each channel */
static unsigned int stop = 0;

enum tstamp_print_format
{
	TSTAMP_FMT_PS = 0,
	TSTAMP_FMT_WR,
};

/**
 * Print help message
 * @param[in] name program name
 */
static void help(char *name)
{
	fprintf(stderr,
		"%s -D <device> -c <channel> -n <number_of_samples>\n",
		basename(name));
	fprintf(stderr,
			"reads timestamps from fmc-tdc channels, measures the readout performance & correctness.\n\n");
}

/**
 * It stops timestamps readout after a signal
 * @param[in] signum signal number
 */
static void termination_handler(int signum)
{
	fprintf(stderr, "\nfmc-tdc-tstamp: killing application\n");
	stop = 1;
}

static struct fmctdc_time prev_ts;
static int total_samples = 0;
uint64_t delta_min = 0xffffffffffffffffULL;
uint64_t delta_max = 0;
double avg_acc = 0.0;
int misses = 0;

typedef struct
{
	int repeat;
	uint64_t start_tics;
	uint64_t timeout;
} timeout_t;

/* get monotonic number of useconds */
uint64_t get_monotonic_us(void)
{
	struct timespec tv;
	clock_gettime(CLOCK_MONOTONIC, &tv);

	return (uint64_t) tv.tv_sec * 1000000ULL +
		(uint64_t) (tv.tv_nsec / 1000);
}

int tmo_init(timeout_t *tmo, uint32_t milliseconds, int repeat)
{
	tmo->repeat = repeat;
	tmo->start_tics = get_monotonic_us();
	tmo->timeout = (uint64_t)milliseconds * 1000ULL;
	return 0;
}

int tmo_expired(timeout_t *tmo)
{
	uint64_t time = get_monotonic_us();
	int expired = (time > tmo->start_tics + tmo->timeout);

	if (tmo->repeat && expired)
		while (time > tmo->start_tics + tmo->timeout)
			tmo->start_tics += tmo->timeout;

	return expired;
}

static int prev_fine = 0;
static int64_t avg_delta_d = 0;
static int delta_stab_count = 0;
static const int64_t max_delta_span = 2000;
static int delta_stable = 0;

void process_timestamps(struct fmctdc_time *ts, int n_ts)
{
	int i;

	for (i = 0; i < n_ts; i++) {
		int fine = ts[i].debug & 0x1fff;

		if (ts->seq_id < 10) /* skip first few ts, just to be sure
					the buffer has been flushed */
			continue;

		if (total_samples > 0)
		{
			struct fmctdc_time delta;
			delta = ts[i];

			fmctdc_ts_sub(&delta, &ts[i], &prev_ts);
			int64_t ps = fmctdc_ts_ps(&delta);

			if ( (prev_ts.seq_id + 1) != ts[i].seq_id) {
				fprintf(stderr,
					"\n\nSuspicious timestamps (gap in sequence ids):\n");
				fprintf(stderr,"Previous : "PRItswr"\n",
					PRItswrVAL(&prev_ts));
				fprintf(stderr,"Current  : "PRItswr"\n",
					PRItswrVAL(&ts[i]));
				misses++;
			} else {
				int64_t avg_delta = (int64_t)((1e12 * avg_acc) / (double)total_samples);
				int64_t delta_diff = abs(ps - avg_delta);

				int curr_f_stable = (double)abs(avg_delta_d - avg_delta) < (double)(avg_delta / 100000.0);

				if (curr_f_stable && delta_stab_count < 10000)
					delta_stab_count++;
				else if (!curr_f_stable && delta_stab_count > 10)
					delta_stab_count-=10;

				delta_stable = delta_stab_count > 8000;

				avg_delta_d = avg_delta;

				if( delta_stable ) {
					if (ps < delta_min)
						delta_min = ps;
					else if (ps > delta_max)
						delta_max = ps;

					avg_delta_d = avg_delta;

					if (delta_diff > max_delta_span) {
						int frac_prev_from_acam = (prev_fine * 81 * 4096 / 8000) % 4096;
						int frac_curr_from_acam = (fine * 81 * 4096 / 8000) % 4096;
						int err_prev = frac_prev_from_acam - prev_ts.frac;
						int err_curr = frac_curr_from_acam - ts[i].frac;

						fprintf(stderr,
							"\n\nSuspicious timestamps (span exceeded: current-previous = %"PRIi64" ps, average = %"PRIi64" ps, error = %"PRIi64" ps, threshold = %"PRIi64" ps):\n",
							ps, avg_delta, delta_diff,
							max_delta_span);

						fprintf(stderr,
							"Previous : "PRItswr", ACAM bins: %d (DMA timestamp vs RAW ACAM readout error: %d)\n",
							PRItswrVAL(&prev_ts),
							prev_fine,
							err_prev);
						fprintf(stderr,
							"Current  : "PRItswr", ACAM bins: %d (DMA timestamp vs RAW ACAM readout error: %d)\n",
							PRItswrVAL(&ts[i]),
							fine,
							err_curr);
					}
				}
				avg_acc += (double)ps / 1e12;
			}
			//printf("Miss: %d %d\n\n", i, total_samples);
		}

		prev_ts = ts[i];
		prev_fine = fine;
		total_samples++;
	}
}

void display_stats()
{
	if( delta_stable )
		fprintf(stderr,
			"Got %d timestamps so far (rate %.1f Hz, misses : %d, dmin %"PRIi64" dmax %"PRIi64" span %"PRIi64")...                    \r",
			total_samples, 1.0 / (avg_acc / (double)total_samples),
			misses, delta_min, delta_max, delta_max - delta_min);
	else
		fprintf(stderr,
			"Got %d timestamps so far (input frequency UNSTABLE)...                    \r",
			total_samples);
}

static timeout_t refresh_timeout;

int main(int argc, char **argv)
{
	struct fmctdc_board *brd;
	unsigned int dev_id = 0xFFFFFFFF;
	struct fmctdc_time *ts;
	int fd, ret, n_boards;
	char opt;
	struct sigaction new_action, old_action;
	int ts_buf_size = 1024;
	int channel = -1;
	int nsamples = -1;

	/* Set up the structure to specify the new action. */
	new_action.sa_handler = termination_handler;
	sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = 0;

	sigaction(SIGINT, NULL, &old_action);
	if (old_action.sa_handler != SIG_IGN)
		sigaction(SIGINT, &new_action, NULL);
	atexit(fmctdc_exit);

	/* Initialize FMC TDC library */
	n_boards = fmctdc_init();
	if (n_boards < 0)
	{
		fprintf(stderr, "%s: fmctdc_init(): %s\n", argv[0],
				strerror(errno));
		exit(1);
	}

	/* Parse Options */
	while ((opt = getopt(argc, argv, "D:c:n:h")) != -1)
	{
		switch (opt)
		{
		case 'D':
			ret = sscanf(optarg, "0x%04x", &dev_id);
			if (!ret)
			{
				help(argv[0]);
				exit(EXIT_SUCCESS);
			}
			break;
		case 'h':
		case '?':
			help(argv[0]);
			exit(EXIT_SUCCESS);
			break;
		case 'n':
			sscanf(optarg, "%d", &nsamples);
			break;

		case 'c':
			sscanf(optarg, "%d", &channel);
			break;
		}
	}

	/* Open FMC TDC device */
	brd = fmctdc_open(-1, dev_id); /* look for dev_id form the beginning */
	if (!brd)
	{
		if (dev_id == 0xFFFFFFFF)
			fprintf(stderr, "Missing device identifier\n");
		else
			fprintf(stderr, "Can't open device 0x%x: %s\n", dev_id,
					strerror(errno));
		exit(EXIT_FAILURE);
	}

	if (channel < 0)
	{
		fprintf(stderr, "Channel number expected\n");
		exit(EXIT_FAILURE);
	}

	if (nsamples < 0)
	{
		fprintf(stderr, "Number of samples expected\n");
		exit(EXIT_FAILURE);
	}

	ret = fmctdc_flush(brd, channel);
	if (ret)
		fprintf(stderr,
				"fmc-tdc-tstamp: failed to flush channel %d: %s\n",
				FMCTDC_NUM_CHANNELS, fmctdc_strerror(errno));

	fd = fmctdc_fileno_channel(brd, channel);

	ret = fmctdc_channel_enable(brd, channel);
	if (ret)
		fprintf(stderr,
			"%s: chan %d: cannot enable acquisition: %s.\n",
			argv[0], channel, fmctdc_strerror(errno));

	/* Read Time-Stamps */
	ts = calloc(ts_buf_size, sizeof(*ts));
	if (!ts)
	{
		fprintf(stderr, "%s: cannot allocate memory\n", argv[0]);
		goto out;
	}

	tmo_init(&refresh_timeout, 1000, 1);
	fprintf(stderr,
		"WARNING!!! Please connect a pulse source of a stable frequency to the selected input.\n\n");
	fprintf(stderr,
		"Reading & checking %d samples...\n",
		nsamples);
	while (nsamples > 0)
	{
		int to_read = nsamples > ts_buf_size ? ts_buf_size : nsamples;
		struct pollfd pfd;
		pfd.fd = fd;
		pfd.events = POLLIN | POLLERR;

		if (stop)
			break;

		ret = poll(&pfd, 1, 10);
		if (ret <= 0)
			continue;

		if (!(pfd.revents & POLLIN))
			continue;

		int n_ts = fmctdc_read(brd, channel, ts, to_read, 0);
		if (n_ts == 0) /* no timestamp */
			continue;

		//    fprintf(stderr,"Got %d\n", n_ts);
		process_timestamps(ts, n_ts);

		if (tmo_expired(&refresh_timeout))
		{
			display_stats();
		}

		nsamples -= n_ts;
	}

	fprintf(stderr, "\n");

	free(ts);

out:
	ret = fmctdc_channel_disable(brd, channel);
	fmctdc_close(brd);
	exit(EXIT_SUCCESS);
}
