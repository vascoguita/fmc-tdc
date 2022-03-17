// SPDX-License-Identifier: GPL-3.0-or-later
/*
 * Copyright (C) 2019 CERN (www.cern.ch)
 * Author: Federico Vaga <federico.vaga@cern.ch>
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <inttypes.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <fmc-tdc.h>

char git_version[] = "git version: " GIT_VERSION;

static char options[] = "hf:o:D:b";
static const char help_msg[] =
	"Usage: fmc-tdc-calibration [options]\n"
	"\n"
	"The tool reads calibration data from a file that contains it in binary\n"
	"form and shows it on STDOUT in binary form or in human readable\n"
	"one (default).\n"
	"This could be used to change the TDC calibration data at runtime\n"
	"by redirecting the binary output of this program to the proper\n"
	"sysfs binary attribute.\n"
	"This tool expects all values to be little endian.\n"
	"Please note that the TDC driver supports only ps precision, but\n"
	"calibration data is typically stored with sub-picosecond\n"
	"precision. For this reason, according to your source, calibration\n"
	"values may disagree on the fs part.\n"
	"\n"
	"General options:\n"
	"-h                 Print this message\n"
	"-b                 Show Calibration in binary form\n"
	"\n"
	"Read options:\n"
	"-f                 Source file where to read calibration data from\n"
	"-o                 Offset in bytes within the file (default 0)\n"
	"Write options:\n"
	"-D                 FMC TDC Target Device ID\n"
	"\n";


/**
 * Read calibration data from file
 * @path: file path
 * @calib: calibration data
 * @offset: offset in file
 *
 * Return: number of bytes read
 */
static int fau_calibration_read(char *path, struct ft_calibration_raw *calib,
				off_t offset)
{
	int fd;
	int ret = 0;
	uint32_t *data32 = (uint32_t *)calib;
	int i;

	fd = open(path, O_RDONLY);
	if (fd < 0)
		return -1;
	ret = lseek(fd, offset, SEEK_SET);
	if (ret >= 0)
		ret = read(fd, calib, sizeof(*calib));
	close(fd);

	/* Fix endianess */
	for (i = 0; i < sizeof(*calib) / sizeof(uint32_t); ++i)
		data32[i] = le32toh(data32[i]);

	return ret;
}

/**
 * Print calibration data on stdout in humand readable format
 * @calib: calibration data
 */
static void fau_calibration_dump_human(struct ft_calibration_raw *calib)
{
	int i;

	fprintf(stdout, "Temperature: %"PRIu32" C\n",
		calib->calibration_temp);
	fprintf(stdout, "White Rabbit Offset: %"PRIi32" fs\n",
		calib->wr_offset * 10);
	fputs("Zero Offset\n", stdout);
	for (i = 0 ; i < FT_NUM_CHANNELS - 1; ++i)
		fprintf(stdout, "  ch%d-ch%d: %"PRIi32" fs\n",
			i + 1, i + 2, calib->zero_offset[i] * 10);
	fputc('\n', stdout);
}

/**
 * Print binary calibration data on stdout
 * @calib: calibration data
 */
static void fau_calibration_dump_machine(struct ft_calibration_raw *calib)
{
	write(fileno(stdout), calib, sizeof(*calib));
}

/**
 * Write calibration data to device
 * @devid: Device ID
 * @calib: calibration data
 *
 * Return: number of bytes wrote
 */
static int fau_calibration_write(unsigned int devid,
				 struct ft_calibration_raw *calib)
{
	struct ft_calibration_raw calib_cp;
	uint32_t *data32;
	char path[128];
	int fd;
	int ret;
	int i;

	sprintf(path,
		"/sys/bus/zio/devices/tdc-1n5c-%04x/calibration_data",
		devid);

	/* Fix endianess */
	memcpy(&calib_cp, calib, sizeof(calib_cp));
	data32 = (uint32_t *) &calib_cp;
	for (i = 0; i < sizeof(calib_cp) / sizeof(uint32_t); ++i)
		data32[i] = htole32(data32[i]);

	fd = open(path, O_WRONLY);
	if (fd < 0)
		return -1;
	ret = write(fd, &calib_cp, sizeof(calib_cp));
	close(fd);

	return ret;
}

int main(int argc, char *argv[])
{
	char c;
	int ret;
	char *path = NULL;
	unsigned int offset = 0;
	unsigned int devid = 0;
	int show_bin = 0, write = 0;
	struct ft_calibration_raw calib;

	while ((c = getopt(argc, argv, options)) != -1) {
		switch (c) {
		default:
		case 'h':
			fprintf(stderr, help_msg);
			exit(EXIT_SUCCESS);
		case 'D':
			ret = sscanf(optarg, "0x%x", &devid);
			if (ret != 1) {
				fprintf(stderr,
					"Invalid devid %s\n",
					optarg);
				exit(EXIT_FAILURE);
			}
			write = 1;
			break;
		case 'f':
			path = optarg;
			break;
		case 'o':
			ret = sscanf(optarg, "0x%x", &offset);
			if (ret != 1) {
				ret = sscanf(optarg, "%u", &offset);
				if (ret != 1) {
					fprintf(stderr,
						"Invalid offset %s\n",
						optarg);
					exit(EXIT_FAILURE);
				}
			}
			break;
		case 'b':
			show_bin = 1;
			break;
		}
	}

	if (!path) {
		fputs("Calibration file is mandatory\n", stderr);
		exit(EXIT_FAILURE);
	}

	/* Read EEPROM file */
	ret = fau_calibration_read(path, &calib, offset);
	if (ret < 0) {
		fprintf(stderr, "Can't read calibration data from '%s'. %s\n",
			path, strerror(errno));
		exit(EXIT_FAILURE);
	}
	if (ret != sizeof(calib)) {
		fprintf(stderr,
			"Can't read all calibration data from '%s'. %s\n",
			path, strerror(errno));
		exit(EXIT_FAILURE);
	}

	/* Show calibration data*/
	if (show_bin)
		fau_calibration_dump_machine(&calib);
	else if(!write)
		fau_calibration_dump_human(&calib);

	/* Write calibration data */
	if (write) {
		ret = fau_calibration_write(devid, &calib);
		if (ret < 0) {
			fprintf(stderr,
				"Can't write calibration data to '0x%x'. %s\n",
				devid, strerror(errno));
			exit(EXIT_FAILURE);
		}
		if (ret != sizeof(calib)) {
			fprintf(stderr,
				"Can't write all calibration data to '0x%x'. %s\n",
				devid, strerror(errno));
			exit(EXIT_FAILURE);
		}
	}
	exit(EXIT_SUCCESS);
}
