/*
 * The fmc-tdc (a.k.a. FmcTdc1ns5cha) library test program.
 *
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation or, at your
 * option, any later version.
 */

#ifndef __TEST_COMMON_H
#define __TEST_COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <libgen.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

#include <getopt.h>

#include "fmctdc-lib.h"
#include "fmctdc-lib-private.h" /* for some extra debugging stuff */

extern int n_boards;
extern struct fmctdc_board *brd;

void usage_msg(const char *name, const char *msg);
void open_board(char *dev_id_str);
void check_help(int argc, char **argv, int min_args, char *usage, char *desc, char *options);
void init(int argc, char *argv[]);

#endif
