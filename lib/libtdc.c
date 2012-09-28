#include <glob.h>
#include <unistd.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <sys/select.h>
#include <linux/zio.h>
#include <linux/zio-user.h>
#include "libtdc.h"

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

static inline int __tdc_sysfs_get_lun(char *sysbase, uint32_t *resp)
{
	char path[128];
	FILE *f;

	sprintf(path, "%s/%s", sysbase, "lun");
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

static inline int __tdc_sysfs_get(struct tdc_board *b,  char *name,
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

static inline int __tdc_sysfs_set(struct tdc_board *b, char *name,
				  uint32_t value)
{
	char path[128];
	char s[16];
	int fd, ret, len;

	sprintf(path, "%s/%s", b->sysbase, name);
	len = sprintf(s, "%i\n", value);
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

struct tdc_board *tdc_open(int lun)
{
	glob_t glob_dev, glob_sys;
	struct tdc_board *b = NULL;
	int tdc_nboards;
	int ret;
	uint32_t dev_lun;
	int i, j;

	/* Look for boards in /dev: old and new pathnames: only one matches */
	glob("/dev/tdc-*-0-0-ctrl", 0, NULL, &glob_dev);
	glob("/dev/zio/tdc-*-0-0-ctrl", GLOB_APPEND, NULL, &glob_dev);

	/* And look in /sys as well */
        glob("/sys/bus/zio/devices/tdc-*",0 , NULL, &glob_sys);
	assert(glob_dev.gl_pathc == glob_sys.gl_pathc);

	/* Check that there are boards found */
	tdc_nboards = glob_dev.gl_pathc;
	if (!tdc_nboards) {
		fprintf (stderr, "No boards found!\n");
		errno = ENODEV;
		return NULL;
	}

	for (i = 0; i < tdc_nboards; i++) {
		ret = __tdc_sysfs_get_lun(glob_sys.gl_pathv[i], &dev_lun);
		/* Unable to get lun */
		if (ret < 0) {
			fprintf(stderr, "Unable to get lun for device %s\n",
				glob_sys.gl_pathv[i]);
			continue;
		}

		/* lun doesn't match */
		if (dev_lun != lun)
			continue;

		/* lun found */
		b = malloc(sizeof(struct tdc_board));
		b->lun = lun;
		b->sysbase = strdup(glob_sys.gl_pathv[i]);
		b->devbase = strdup(glob_dev.gl_pathv[i]);
		/* trim the "-0-0-ctrl" at the end */
		b->devbase[strlen(b->devbase) - strlen("-0-0-ctrl")] = '\0';
		/* extract dev_id */
		sscanf(b->sysbase, "%*[^f]tdc-%x", &b->dev_id);
		for (j = 0; j < ARRAY_SIZE(b->ctrl); j++) {
			b->ctrl[j] = -1;
			b->data[j] = -1;
			b->enabled[j] = 0;
		}
		break;
	}

	globfree(&glob_dev);
	globfree(&glob_sys);

	if (!b)
		errno = ENODEV;

	return b;
}

int tdc_close(struct tdc_board *b)
{
	int j;

	for (j = 0; j < ARRAY_SIZE(b->ctrl); j++) {
		if (b->ctrl[j] >= 0) {
			close(b->ctrl[j]);
			fprintf(stderr, "Device %s was still open\n",
				b->devbase);
		}
		b->ctrl[j] = -1;
		if (b->data[j] >= 0) {
			close(b->data[j]);
			fprintf(stderr, "Device %s was still open\n",
				b->devbase);
		}
		b->data[j] = -1;
	}

	free(b->sysbase);
	free(b->devbase);
	free(b);
	return 0;
}

int tdc_start_acquisition(struct tdc_board *b)
{
	return __tdc_sysfs_set(b, "activate_acquisition", 1);
}

int tdc_stop_acquisition(struct tdc_board *b)
{
	return __tdc_sysfs_set(b, "activate_acquisition", 0);
}

int tdc_set_host_utc_time(struct tdc_board *b)
{
	/* -1 means that the driver will load the host time */
	return __tdc_sysfs_set(b, "set_utc_time", -1);
}

int tdc_set_utc_time(struct tdc_board *b, uint32_t utc)
{
	/* a value different from -1 is an UTC */
	return __tdc_sysfs_set(b, "set_utc_time", utc);
}

int tdc_get_utc_time(struct tdc_board *b, uint32_t *utc)
{
	return __tdc_sysfs_get(b, "current_utc_time", utc);
}

int tdc_set_dac_word(struct tdc_board *b, uint32_t dw)
{
	return __tdc_sysfs_set(b, "dac_word", dw);
}

int tdc_get_dac_word(struct tdc_board *b, uint32_t *dw)
{
	return __tdc_sysfs_get(b, "dac_word", dw);
}

int tdc_set_time_threshold(struct tdc_board *b, uint32_t thres)
{
	return __tdc_sysfs_set(b, "time_thresh", thres);
}

int tdc_get_time_threshold(struct tdc_board *b, uint32_t *thres)
{
	return __tdc_sysfs_get(b, "time_thresh", thres);
}

int tdc_set_timestamp_threshold(struct tdc_board *b, uint32_t thres)
{
	return __tdc_sysfs_set(b, "tstamp_thresh", thres);
}

int tdc_get_timestamp_threshold(struct tdc_board *b, uint32_t *thres)
{
	return __tdc_sysfs_get(b, "tstamp_thresh", thres);
}

int tdc_set_active_channels(struct tdc_board *b, uint32_t config)
{
	int res = 0;
	int i;

	/* Hardware deactivation */
	res = __tdc_sysfs_set(b, "input_enable", config);
	if (res) {
		printf("Error setting chan config in hardware\n");
		return res;
	}

	/* ZIO deactivation */
	for (i = 0; i <= 4; i++) {
		char file[20];
		sprintf(file, "tdc-cset%i/enable", i);
		if (config & (1 << i)) {
			res = __tdc_sysfs_set(b, file, 1);
			b->enabled[i] = 1;
		} else {
			res = __tdc_sysfs_set(b, file, 0);
			b->enabled[i] = 0;
		}
		if (res) {
			printf("Error setting ZIO chan config in cset %i\n", i);
			return res;
		}
	}

	return res;
}

int tdc_get_active_channels(struct tdc_board *b, uint32_t *config)
{
	return __tdc_sysfs_get(b, "input_enable", config);
}

static int __tdc_valid_channel(struct tdc_board *b, int chan)
{
	if (chan < 0 || chan > 4) {
		fprintf(stderr, "%s: Invalid channel: %i\n",
			__func__, chan);
		errno = EINVAL;
		return  0;
	}

	if (!b->enabled[chan]) {
		fprintf(stderr, "%s: Channel not enabled: %i\n",
			__func__, chan);
		errno = EINVAL; 
		return  0;
	}

	return 1;
}

static int __tdc_open_file(struct tdc_board *b, int chan)
{
	char fname[128];

	/* open file */
	if (b->ctrl[chan] <= 0) {
		sprintf(fname, "%s-%i-0-ctrl", b->devbase, chan);
		b->ctrl[chan] = open(fname, O_RDONLY | O_NONBLOCK);
	}

	if (b->ctrl[chan] < 0)
		fprintf(stderr, "%s: Error opening file: %s\n",
			__func__, fname);

	return b->ctrl[chan];
}

int tdc_read(struct tdc_board *b, int chan, struct tdc_time *t,
	     int n, int flags)
{
	struct zio_control ctrl;
	int fd, i, j;
	fd_set set;

	if (!__tdc_valid_channel(b, chan))
		return -1;

	fd = __tdc_open_file(b, chan);
	if (fd < 0)
		return -1;

	for (i = 0; i < n; ) {
		j = read(fd, &ctrl, sizeof(ctrl));

		/* one register read */
		if (j == sizeof(ctrl)) {
			t[i].utc = ctrl.tstamp.secs;
			t[i].ticks = ctrl.tstamp.ticks;
			t[i].bins = ctrl.tstamp.bins;

			i++;
			continue;
		}

		/* some bytes read but not complete structure */
		if (j > 0) {
			errno = EIO;
			return -1;
		}

		/* from here on, an error was returned */

		/* real error, so exit */
		if (errno != EAGAIN)
			return -1;

		/* EAGAIN: if we already got something, we are done */
		if (i)
			return i;

		/* EAGAIN and no data yet. If noblock then return */
		if (flags == O_NONBLOCK)
			return -1;

		/* blocking read */
		FD_ZERO(&set);
		FD_SET(fd, &set);
		if (select(fd+1, &set, NULL, NULL, NULL) < 0)
			return -1;
		continue;
	}

	return i;
}

int tdc_fread(struct tdc_board *b, int chan, struct tdc_time *t, int n)
{
	int i, loop;

	for (i = 0; i < n; ) {
		loop = tdc_read(b, chan, t + i, 1, 0);
		if (loop < 0)
			return -1;
		i += loop;
	}
	return i;
}
