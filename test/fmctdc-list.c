/*
 * The fmc-tdc (a.k.a. FmcTdc1ns5cha) library test program.
 *
 * Author: Tomasz Włostowski <tomasz.wlostowski@cern.ch>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2 as published by the Free Software Foundation or, at your
 * option, any later version.
 *
 * fmctdc-list: displays all FmcTdc cards installed in the system.
 *
 */

#include "test-common.h"

int main(int argc, char **argv)
{
    int i;

    init(argc, argv);

    check_help(argc, argv, 1, 
    	"[-h]", 
    	"lists all installed fmc-tdc boards.", 
    	"");

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