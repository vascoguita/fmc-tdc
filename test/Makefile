ZIO ?= $(HOME)/zio

LIB = libtdc.a
LOBJ := libtdc.o

CFLAGS = -Wall -ggdb -I.. -I../lib -I$(ZIO)/include
LDFLAGS = -L../lib/ -ltdc

modules all: lib test test-chan

lib:
	$(MAKE) -C ../lib

test:
	$(CC) $(CFLAGS) $@.c $(LDFLAGS) -o $@

test-chan:
	$(CC) $(CFLAGS) $@.c $(LDFLAGS) -o $@

clean:
	$(MAKE) clean -C ../lib
	rm -f *.o *~ test test-chan
