# This is not a kbuild Makefile. It is a plain Makefile so it can be copied

# If it exists includes Makefile.specific. In this Makefile, you should put
# specific Makefile code that you want to run before this. For example,
# build a particular environment.
-include Makefile.specific


#ZIO := $(shell ../scripts/check-submodule zio $(ZIO))
ZIO ?= ../zio

LIB = libfmctdc.a
LOBJ := fmctdc-lib.o

CFLAGS = -Wall -ggdb -O2 -I../kernel -I$(ZIO)/include $(EXTRACFLAGS)

DESTDIR ?= /usr/local

modules all: lib

lib: $(LIB)

%: %.c $(LIB)
	$(CC) $(CFLAGS) $*.c $(LDFLAGS) -o $@

$(LIB): $(LOBJ)
	ar r $@ $^

clean:
	rm -f $(LIB) .depend *.o *~

.depend: Makefile $(wildcard *.c *.h ../*.h)
	$(CC) $(CFLAGS) -M $(LOBJ:.o=.c) -o $@

install:
	install -d $(DESTDIR)/lib
	install -d $(DESTDIR)/include/fmc-tdc

	install -m 644 -D $(LIB) $(DESTDIR)/lib
	install -m 644 -D fmctdc-lib.h $(DESTDIR)/include/fmc-tdc

modules_install:

-include .depend

