ZIO ?= $(HOME)/dependencies/zio

LIB = libtdc.a
LOBJ := libtdc.o

CFLAGS = -Wall -ggdb -I.. -I../lib -I$(ZIO)/include
LDFLAGS = -L../lib/ -ltdc

modules all: lib test

lib:
	$(MAKE) -C ../lib

test:
	$(CC) $(CFLAGS) $@.c $(LDFLAGS) -o $@


clean:
	$(MAKE) clean -C ../lib
	rm -f *.o *~ test
