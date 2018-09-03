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

enum tstamp_print_format {
	TSTAMP_FMT_PS = 0,
	TSTAMP_FMT_WR,
};

/**
 * It prints the given timestamp using the White-Rabit format
 * @param[in] ts timestamp
 *
 * seconds:coarse:frac
 */
static inline void print_ts_wr(struct fmctdc_time ts)
{
	fprintf(stderr, "%10"PRIu64":%09u:%04u seq %-10d",
		ts.seconds, ts.coarse, ts.frac, ts.seq_id);

}

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

typedef struct {
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
	tmo->timeout = (uint64_t) milliseconds * 1000ULL;
	return 0;
}

int tmo_restart(timeout_t *tmo)
{
	tmo->start_tics = get_monotonic_us();
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

int64_t max_span = 2000;

void process_timestamps( struct fmctdc_time *ts, int n_ts )
{
	int i;
	for(i = 0; i < n_ts; i++)
	{
		if ( ts->seq_id < 3 ) // skip first few ts, just to be sure the buffer has been flushed
			continue;
		if (total_samples > 0)
		{
			struct fmctdc_time delta;

			delta = ts[i];
			fmctdc_ts_sub( &delta, &prev_ts );
			int64_t ps = fmctdc_ts_ps(&delta);

			//printf("ps: %lld seq:%d\n", ps, ts[i].seq_id);
			if ( prev_ts.seq_id + 1 != ts[i].seq_id )
			{
				fprintf(stderr, "\n\nSuspicious timestamps (gap in seq ids):\n");
				fprintf(stderr,"Prev: "); print_ts_wr( prev_ts ); fprintf(stderr, "\n");
				fprintf(stderr,"Curr: "); print_ts_wr( ts[i] ); fprintf(stderr, "\n");
				misses++;
			} else {
				if(ps < delta_min)
					delta_min = ps;
				else if(ps > delta_max)
					delta_max = ps;

				int64_t span = delta_max - delta_min;

				if( span > max_span )
				{
					fprintf(stderr, "\n\nSuspicious timestamps (span exceeded):\n");

					max_span = span;

					fprintf(stderr,"Prev: "); print_ts_wr( prev_ts ); fprintf(stderr, "\n");
					fprintf(stderr,"Curr: "); print_ts_wr( ts[i] ); fprintf(stderr, "\n");
				}
                    
				avg_acc += (double) ps / 1e12;
			}

         
			//printf("Miss: %d %d\n\n", i, total_samples);
             
            
		}

		prev_ts = ts[i];
		total_samples++;
	}
}

void display_stats()
{
	fprintf(stderr,"Got %d timestamps so far (rate %.1f Hz, misses : %d, dmin %"PRId64" dmax %"PRId64" span %"PRId64")...                    \r", total_samples, 1.0/ (avg_acc/(double) total_samples), misses, delta_min, delta_max, delta_max - delta_min );
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

	
	/* Parse Options */
	while ((opt = getopt(argc, argv, "D:c:n:h")) != -1) {
		switch (opt) {
		case 'D':
			ret = sscanf(optarg, "0x%04x", &dev_id);
			if (!ret) {
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
	if (!brd) {
		if (dev_id == 0xFFFFFFFF)
			fprintf(stderr, "Missing device identifier\n");
		else
			fprintf(stderr, "Can't open device 0x%x: %s\n", dev_id,
				strerror(errno));
		exit(EXIT_FAILURE);
	}

	if( channel < 0 )
	{
		fprintf(stderr, "Channel number expected\n");
		exit(EXIT_FAILURE);
	}

	if( nsamples < 0 )
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
	if (!ts) {
		fprintf(stderr, "%s: cannot allocate memory\n", argv[0]);
		goto out;
	}

	tmo_init(&refresh_timeout, 1000, 1) ;
	fprintf(stderr,"Reading & checking %d samples...\n", nsamples);
	while (nsamples > 0) {
		int to_read = nsamples > ts_buf_size ? ts_buf_size : nsamples;
		struct pollfd pfd;
		pfd.fd = fd;
		pfd.events = POLLIN | POLLERR;

		if(stop)
			break;

		ret = poll(&pfd, 1, 10);
		if (ret <= 0)
			continue;

		if (!(pfd.revents & POLLIN))
			continue;

		int n_ts = fmctdc_read(brd, channel, ts, to_read, 0 );
		if (n_ts == 0) /* no timestamp */
			continue;

		//    fprintf(stderr,"Got %d\n", n_ts);
		process_timestamps( ts, n_ts );

		if( tmo_expired(&refresh_timeout) )
		{
			display_stats();
		}

		nsamples -= n_ts;

	}

	fprintf(stderr,"\n");

	free(ts);

out:
	ret = fmctdc_channel_disable(brd, channel);
	fmctdc_close(brd);
	exit(EXIT_SUCCESS);
}
