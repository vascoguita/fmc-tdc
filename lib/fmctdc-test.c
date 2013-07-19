/*
 * The fmc-tdc (a.k.a. FmcTdc1ns5cha) library test program.
 *
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 * Author: Alessandro Rubini <rubini@gnudd.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation or, at your
 * option, any later version.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <libgen.h>

#define FMCTDC_INTERNAL /* hack... */
#include "fmctdc-lib.h"

int n_boards;
struct fmctdc_board *brd;

int go_identify(int argc, char **argv);
int go_list(int argc, char **argv);
int go_read(int argc, char **argv);
int go_time(int argc, char **argv);
int go_termination(int argc, char **argv);
int go_test(int argc, char **argv);

static struct subprogram {
    char *name;
    int (*go)(int argc, char **argv);
} subprograms[] = {
    { "fmctdc-identify", go_identify },
    { "fmctdc-list", go_list },
    { NULL, NULL },
} ;

void usage_msg(const char *name, const char *msg)
{
    printf("usage: %s %s\n", name, msg);
    exit(0);
}

int open_board(char *dev_id_str)
{
	unsigned int dev_id;
	
	if(sscanf(dev_id_str, "%04x", &dev_id) != 1)
		return -1;
	
	brd = fmctdc_open(-1, dev_id);
	if(!brd)
	{
		fprintf(stderr, "can't open device %s: %s\n", dev_id_str, strerror(errno));
		return -1;
	}
	return 0;
}

int go_identify(int argc, char **argv)
{
    if (argc >= 2 && !strcmp(argv[1], "-h"))
    {
	printf("%s: identifies a given fmc-tdc device in a crate by blinking its status LED.\n", argv[0]);
	printf("usage: %s [-h] <device>\n", argv[0]);
	return 0;
    }

    if(argc < 2)
    {
		printf("usage: %s [-h] <device>\n", argv[0]);
		return 0;
    }

	if(open_board(argv[1]) < 0)
		return -1;

	printf("Blinking the status LED. Press ENTER to stop.\n");
	fmctdc_identify_card(brd, 1);
	getchar();
	fmctdc_identify_card(brd, 0);
    
    return 0;
}

int go_list(int argc, char **argv)
{
    int i;

    if (argc >= 2 && !strcmp(argv[1], "-h"))
    {
	printf("%s: lists all installed fmc-tdc boards.\n", argv[0]);
	printf("usage: %s [-h]\n", argv[0]);
	return 0;
    }

    printf("Found %i board(s): \n", n_boards);

    for (i = 0; i < n_boards; i++) 
    {
    	struct __fmctdc_board *b;
		struct fmctdc_board *ub;

		ub = fmctdc_open(i, -1);
		b = (typeof(b))ub;
		printf("%04x, %s, %s\n", b->dev_id, b->devbase, b->sysbase);
    }
    return 0;
}

int main(int argc, char **argv)
{
	int rv = 0;
	struct subprogram *sp;

	n_boards = fmctdc_init();
	if (n_boards < 0) {
		fprintf(stderr, "%s: fdelay_init(): %s\n", argv[0],
			strerror(errno));
		exit(1);
	}

	for(sp = subprograms; sp->name; sp++)
	    if (!strcmp(sp->name, basename(argv[0]))) {
		rv = sp->go(argc, argv);
		break;
	    }

//	rv = go_test(argc, argv);

	fmctdc_exit();
	return rv;
}