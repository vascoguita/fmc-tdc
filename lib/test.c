#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "libtdc.h"

int main(int argc, char **argv)
{
	int i;

	i = tdc_init();
	if (i < 0) {
		fprintf(stderr, "%s: tdc_init(): %s\n", argv[0],
			strerror(errno));
		exit(1);
	}
	if (i == 0) {
		fprintf(stderr, "%s: no boards found\n", argv[0]);
		exit(1);
	}
	if (i != 1) {
		fprintf(stderr, "%s: found %i boards",
			argv[0], i);
	}

	tdc_exit();
	return 0;
}
