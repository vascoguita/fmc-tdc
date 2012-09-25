#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "libtdc.h"

int main(int argc, char **argv)
{
	struct tdc_board *b;
	int i;
	uint32_t set, get;

	i = tdc_init();
	if (i < 0) {
		fprintf(stderr, "%s: tdc_init(): %s\n", argv[0],
			strerror(errno));
		exit(1);
	}
	if (i == 0) {
		fprintf(stderr, "%s: no boards found\n", argv[0]);
		exit(1);
	}
	if (i != 1) {
		fprintf(stderr, "%s: found %i boards\n",
			argv[0], i);
	}

	b = tdc_open(0, -1);

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
	set = 123;
	if (tdc_set_time_threshold(b, set))
		printf("Error setting time thresh\n");
	if (tdc_get_time_threshold(b, &get))
		printf("Error getting time thresh\n");
	if (set != get)
		printf("Time thresh set and get don't match\n");
	else
		printf("Time threshold functions OK\n");

	/* set/get timestamps threshold */
	set = 123;
	if (tdc_set_timestamp_threshold(b, set))
		printf("Error setting timestamps thresh\n");
	if (tdc_get_timestamp_threshold(b, &get))
		printf("Error getting timestamps thresh\n");
	if (set != get)
		printf("Timestamps thresh set and get don't match\n");
	else
		printf("Timestamps threshold functions OK\n");

	/* set/get active channels */
	set = CHAN0 | CHAN2 | CHAN4;
	if (tdc_set_active_channels(b, set))
		printf("Error setting active channels\n");
	if (tdc_get_active_channels(b, &get))
		printf("Error getting active channels\n");
	if (set != get)
		printf("Active channels set and get don't match\n");
	else
		printf("Channel activation functions OK\n");


	tdc_close(b);

	tdc_exit();
	return 0;
}
