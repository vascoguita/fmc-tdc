#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <inttypes.h>
#include "libtdc.h"

int main(int argc, char **argv)
{
	struct tdc_board *b;
	struct tdc_time *t;
	uint32_t set, get;
	int res;
	int i;

	b = tdc_open(1);
	if (!b) {
		printf("Unable to open device with lun 1\n");
		exit(1);
	}

	/* set/get UTC time */
	set = 123;
	if (tdc_set_utc_time(b, set))
		printf("Error setting UTC time\n");
	if (tdc_get_dac_word(b, &get))
		printf("Error getting UtC time\n");
	if (set != get)
		printf("UTC time set and get don't match (this may not be an error)\n");
	else
		printf("UTC time functions OK\n");

	/* set/get DAC word */
	set = 123;
	if (tdc_set_dac_word(b, set))
		printf("Error setting DAC word\n");
	if (tdc_get_dac_word(b, &get))
		printf("Error getting DAC word\n");
	if (set != get)
		printf("DAC word set and get don't match\n");
	else
		printf("DAC word functions OK\n");

	/* set/get time threshold */
	set = 12;
	if (tdc_set_time_threshold(b, set))
		printf("Error setting time thresh\n");
	if (tdc_get_time_threshold(b, &get))
		printf("Error getting time thresh\n");
	if (set != get)
		printf("Time thresh set and get don't match\n");
	else
		printf("Time threshold functions OK\n");

	/* set/get timestamps threshold */
	set = 12;
	if (tdc_set_timestamp_threshold(b, set))
		printf("Error setting timestamps thresh\n");
	if (tdc_get_timestamp_threshold(b, &get))
		printf("Error getting timestamps thresh\n");
	if (set != get)
		printf("Timestamps thresh set and get don't match\n");
	else
		printf("Timestamps threshold functions OK\n");

	/* set/get channel termination */
	set = CHAN0 | CHAN2 | CHAN4;
	if (tdc_set_channels_term(b, set))
		printf("Error setting channels termination\n");
	if (tdc_get_channels_term(b, &get))
		printf("Error getting channels term\n");
	if (set != get)
		printf("Channels termination set and get don't match\n");
	else
		printf("Channel termination functions OK\n");

	/* read from valid chan */
	tdc_activate_channels(b);
	tdc_set_time_threshold(b, 1);
	tdc_set_timestamp_threshold(b, 100);
	tdc_start_acquisition(b);
	t = tdc_zalloc(1);
	// wait 2 seconds to ensure that there are samples
	sleep(2);
	for (i = 0; i <10; i++) {
		/* this should be a blocking read */
		res = tdc_read(b, CHAN0, t, 1, 0);
		if (res == 1) {
			printf("Got sample: utc %"PRIu64" ticks %"PRIu64" bins %"PRIu64" dacapo %i\n",
			       t->utc, t->ticks, t->bins, t->da_capo);
		} else {
			printf("Error reading sample\n");
		}
	}

	tdc_stop_acquisition(b);
	tdc_close(b);
	tdc_free(t);

	return 0;
}
