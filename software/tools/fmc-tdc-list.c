/*
 * The fmc-tdc (a.k.a. FmcTdc1ns5cha) library test program.
 *
 * Copyright (c) 2014-2020 CERN
 * Author: Federico Vaga <federico.vaga@cern.ch>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include <glob.h>
#include <getopt.h>

static const char git_version[] = "git version: " GIT_VERSION;

static void help(char *name)
{
	fprintf(stderr, "%s: Lists boards\n"
		"\t-V  print version\n"
		"\t-V  print help\n",
		name);
}

static void print_version(char *name)
{
	printf("%s %s\n", name, git_version);
}

int main(int argc, char **argv)
{
	glob_t g;
	int err, i;
	char opt;

	while ((opt = getopt(argc, argv, "hV")) != -1) {
		switch (opt) {
		case 'h':
		case '?':
			help(argv[0]);
			exit(EXIT_SUCCESS);
			break;
		case 'V':
			print_version(argv[0]);
			exit(EXIT_SUCCESS);
		}
	}

	err = glob("/dev/zio/tdc-1n5c-[A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9]-0-0-ctrl",
		   GLOB_NOSORT, NULL, &g);
	if (err == GLOB_NOMATCH)
		goto out_glob;

	for (i = 0; i < g.gl_pathc; i++) {
		uint32_t dev_id;
		char dev_id_str[7]= "0x";

		/* Keep only the ID */
		strncpy(dev_id_str + 2,
			g.gl_pathv[i] + strlen("/dev/zio/tdc-1n5c-"), 4);
		dev_id = strtol(dev_id_str, NULL, 0);
		printf("  FMC-TDC Device ID %04x\n", dev_id);
	}

	globfree(&g);

out_glob:
	exit(err ? EXIT_FAILURE : EXIT_SUCCESS);
}
