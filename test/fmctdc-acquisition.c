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
 *
 * fmctdc-acquisition: enables/disables acquisition (all inputs).
 */

#include "test-common.h"

int main(int argc, char **argv)
{
    init (argc, argv);

    check_help(argc, argv, 2, 
    	"[-h] <device> [on/off]", 
    	"Enables or disables acquisition (that is, all inputs simultaneosly). Disabling acquisition\n"
         "also empties the timestamp buffers.",
    	"");
    
    open_board(argv[1]);

    if (argc == 2)
    {
	printf("board %s: acquisition is %s\n", argv[1], fmctdc_get_acquisition(brd) ? "on" : "off" );
    } else if (argc > 2) {
	int on;

	if(!strcmp(argv[2], "on"))
	    on = 1;
	else if(!strcmp(argv[2], "off"))
	    on = 0;
	else {
        	fprintf(stderr,"%s: on/off expected.\n", argv[0]);    
        	return -1;
	}

	if( fmctdc_set_acquisition(brd, on) < 0);
	    return -1;
    }

    return 0;
}