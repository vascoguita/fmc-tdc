DESTDIR ?= /usr/local/
LIBTDC = ../lib/

TESTS = fmc-tdc-list \
	fmc-tdc-term \
	fmc-tdc-read \
	fmc-tdc-acquisition \
	fmc-tdc-temperature \
	fmc-tdc-time

CFLAGS = -I. -I$(LIBTDC) -I../kernel -Wall $(EXTRACFLAGS)

COMMON_SRCS = test-common.c
LDFLAGS = -L$(LIBTDC) -lfmctdc

all: $(TESTS)

%: %.c $(COMMON_SRCS)
	$(CC) $(CFLAGS) $*.c $(COMMON_SRCS) $(LDFLAGS) -o $@


clean:
	rm -f $(TESTS) test-common.o

# make nothing for modules_install, but avoid errors
modules_install:

install:
	install -d $(DESTDIR)/bin
	install -D $(TESTS) $(DESTDIR)/bin
