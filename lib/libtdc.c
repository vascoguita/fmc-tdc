#include <glob.h>
#include <unistd.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include "libtdc.h"

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

static int tdc_nboards;
static struct tdc_board *tdc_boards;

static inline int fdelay_sysfs_get(struct tdc_board *b,  char *name,
				   uint32_t *resp)
{
	char path[128];
	FILE *f;

	sprintf(path, "%s/%s", b->sysbase, name);
	f = fopen(path, "r");

	if (!f)
		return -1;
	errno = 0;
	if (fscanf(f, "%i", resp) != 1) {
		fclose(f);
		if (!errno)
			errno = EINVAL;
		return -1;
	}
	fclose(f);
	return 0;
}

static inline int fdelay_sysfs_set(struct tdc_board *b, char *name,
				   uint32_t *value)
{
	char path[128];
	char s[16];
	int fd, ret, len;

	sprintf(path, "%s/%s", b->sysbase, name);
	len = sprintf(s, "%i\n", *value);
	fd = open(path, O_WRONLY);
	if (fd < 0)
		return -1;
	ret = write(fd, s, len);
	close(fd);
	if (ret < 0)
		return -1;
	if (ret == len)
		return 0;
	errno = EINVAL;
	return -1;
}

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
		printf("Found device %s\n", b->sysbase);
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
	struct tdc_board *b = NULL;
	int i;

	/* If we are given an offset, select the dev there */
	/* If we are given an id, loop until we find it in the list */
	/* If we are given an offset and an id, the id in pos offset must match */

	if (offset >= tdc_nboards) {
		errno = ENODEV;
		return NULL;
	}

	if (offset >= 0) {
		b = tdc_boards + offset;
		if (dev_id >= 0 && dev_id != b->dev_id) {
			errno = EINVAL;
			return NULL;
		}
		goto found;
	}
	if (dev_id < 0) {
		errno = EINVAL;
		return NULL;
	}
	for (i = 0, b = tdc_boards; i < tdc_nboards; i++, b++)
		if (b->dev_id == dev_id)
			goto found;

	errno = ENODEV;
	return NULL;

found:
	printf("Opened device %s\n", b->sysbase);
	return b;
}

extern int tdc_close(struct tdc_board *b)
{
	int j;

	for (j = 0; j < ARRAY_SIZE(b->ctrl); j++) {
		if (b->ctrl[j] >= 0)
			close(b->ctrl[j]);
		b->ctrl[j] = -1;
		if (b->data[j] >= 0)
			close(b->data[j]);
		b->data[j] = -1;
	}
	return 0;
}
