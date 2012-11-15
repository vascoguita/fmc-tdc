ZIO ?= $(HOME)/zio

LIB = libtdc.a
LOBJ := libtdc.o

CFLAGS = -Wall -ggdb -I.. -I../lib -I$(ZIO)/include
LDFLAGS = -L../lib/ -ltdc

modules all: lib sanity-test

lib:
	$(MAKE) -C ../lib

sanity-test:
	$(CC) $(CFLAGS) $@.c $(LDFLAGS) -o $@

clean:
	$(MAKE) clean -C ../lib
	rm -f *.o *~ sanity-test
