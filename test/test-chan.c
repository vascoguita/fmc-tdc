#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <inttypes.h>
#include "libtdc.h"

int main(int argc, char **argv)
{
	struct tdc_board *b;
	struct tdc_time t;
	int res;
	int i;
	unsigned int chan, time_thres, tstamp_thres;

	if (argc != 4){
		fprintf(stderr, "Usage: %s <chan> <time_threshold> <tstamp_threshold>\n", argv[0]);
		fprintf(stderr, "\t<chan>: from 0 to 4.\n");
		fprintf(stderr, "\t<time_threshold>: from 0 to 4294967295 seconds.\n");
		fprintf(stderr, "\t<tstamp_threshold>: from 0 to 255 timestamps.\n");
		fflush(NULL);
		exit(1);
	}

	switch (atoi(argv[1])) {

	case 0: 
		chan = CHAN0;
		break;
	case 1:
		chan = CHAN1;
		break;
	case 2:
		chan = CHAN2;
		break;
	case 3:
		chan = CHAN3;
		break;
	case 4:
		chan = CHAN4;
		break;

	default:
		fprintf(stderr, "Invalid chan number %d. Valid values from 0 to 4\n", atoi(argv[1]));
		fflush(NULL);
		exit(1);
	}
	
	time_thres = atoi(argv[2]);
	tstamp_thres = atoi(argv[3]);

	if(tstamp_thres > 255) {
		fprintf(stderr, "Invalid timestamp threshold number %d. Valid values from 0 to 255\n", tstamp_thres);
		fflush(NULL);
		exit(1);
	}

	b = tdc_open(1);
	if (!b) {
		printf("Unable to open device with lun 1\n");
		fflush(NULL);
		exit(1);
	}


	/* read from valid chan */
	tdc_set_host_utc_time(b);
	tdc_activate_channels(b);
	tdc_set_channels_term(b, chan);
	tdc_set_time_threshold(b, time_thres);
	tdc_set_timestamp_threshold(b, tstamp_thres);
	tdc_start_acquisition(b);
	for (i = 0; i <10000; i++) {
		/* this should be a blocking read */
		res = tdc_read(b, chan, &t, 1, 0);
		if (res == 1) {
			printf("Got sample chan [%d]: utc %"PRIu64" ticks %"PRIu64" bins %"PRIu64" dacapo %i\n",
			       atoi(argv[1]), t.utc, t.ticks, t.bins, t.da_capo);
		} else {
			printf("Error reading sample\n");
		}
//		sleep(1);
	}

	tdc_stop_acquisition(b);
	tdc_close(b);

	return 0;
}
