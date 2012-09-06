#include <glob.h>
#include <unistd.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "libtdc.h"

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

static int tdc_nboards;
static struct tdc_board *tdc_boards;

int tdc_init(void)
{
	glob_t glob_dev, glob_sys;
	struct tdc_board *b;
	int i, j;

	/* Look for boards in /dev: old and new pathnames: only one matches */
	glob("/dev/tdc-*-0-0-ctrl", 0, NULL, &glob_dev);
	glob("/dev/zio/tdc-*-0-0-ctrl", GLOB_APPEND, NULL, &glob_dev);

	/* And look in /sys as well */
        glob("/sys/bus/zio/devices/tdc-*",0 , NULL, &glob_sys);
	assert(glob_dev.gl_pathc == glob_sys.gl_pathc);

	/* Allocate as needed */
	tdc_nboards = glob_dev.gl_pathc;
	if (!tdc_nboards) {
		tdc_boards = NULL;
		return 0;
	}
	tdc_boards = calloc(glob_dev.gl_pathc, sizeof(tdc_boards[0]));
	if (!tdc_boards) {
		globfree(&glob_dev);
		globfree(&glob_sys);
		return -1;
	}

	for (i = 0, b = tdc_boards; i < tdc_nboards; i++, b++) {
		b->sysbase = strdup(glob_sys.gl_pathv[i]);
		b->devbase = strdup(glob_dev.gl_pathv[i]);
		/* trim the "-0-0-ctrl" at the end */
		b->devbase[strlen(b->devbase) - strlen("-0-0-ctrl")] = '\0';
		/* extract dev_id */
		sscanf(b->sysbase, "%*[^f]tdc-%x", &b->dev_id);
		for (j = 0; j < ARRAY_SIZE(b->ctrl); j++) {
			b->ctrl[j] = -1;
			b->data[j] = -1;
		}
		printf("Initialized device %s", b->sysbase);
	}
	globfree(&glob_dev);
	globfree(&glob_sys);

	return tdc_nboards;
}

void tdc_exit(void)
{
	struct tdc_board *b;
	int i, j, err;

	for (i = 0, err = 0, b = tdc_boards; i < tdc_nboards; i++, b++) {
		for (j = 0; j < ARRAY_SIZE(b->ctrl); j++) {
			if (b->ctrl[j] >= 0) {
				close(b->ctrl[j]);
				b->ctrl[j] = -1;
				err++;
			}
			if (b->data[j] >= 0) {
				close(b->data[j]);
				b->data[j] = -1;
				err++;
			}
		}
		if (err)
			fprintf(stderr, "%s: device %s was still open\n",
				__func__, b->devbase);
		free(b->sysbase);
		free(b->devbase);
	}
	if(tdc_nboards)
		free(tdc_boards);
}

struct tdc_board *tdc_open(int offset, int dev_id)
{
	return NULL;
}

extern int tdc_close(struct tdc_board *b)
{
	return 0;
}
