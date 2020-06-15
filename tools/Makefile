# If it exists includes Makefile.specific. In this Makefile, you should put
# specific Makefile code that you want to run before this. For example,
# build a particular environment.
-include Makefile.specific

# include parent_common.mk for buildsystem's defines
IGNORE_CPU_SUFFIX := y
REPO_PARENT ?=
-include $(REPO_PARENT)/parent_common.mk

DESTDIR ?= /usr/local/
LIBTDC = ../lib/

TESTS = fmc-tdc-list \
	fmc-tdc-term \
	fmc-tdc-temperature \
	fmc-tdc-time \
	fmc-tdc-tstamp \
	fmc-tdc-perftest \
	fmc-tdc-offset \
	fmc-tdc-calibration

CFLAGS = -ggdb -I. -I$(LIBTDC) -I../kernel -Wall -Werror $(EXTRACFLAGS)
GIT_VERSION := $(shell git describe --dirty --long --tags)
CFLAGS += -DGIT_VERSION="\"$(GIT_VERSION)\""

COMMON_SRCS = test-common.c
LDFLAGS = -L$(LIBTDC) 
LDLIBS = -lfmctdc -lrt

CPPCHECK ?= cppcheck

all: $(TESTS)

$(TESTS): $(COMMON_SRCS:.c=.o) $(LIBTDC)/libfmctdc.a

clean:
	rm -f $(TESTS) test-common.o

# make nothing for modules_install, but avoid errors
modules_install:

install:
	install -d $(DESTDIR)/bin
	install -D $(TESTS) $(DESTDIR)/bin

cppcheck:
	$(CPPCHECK) -q -I. -I../kernel -I$(LIBTDC) --suppress=missingIncludeSystem --enable=all *.c *.h
