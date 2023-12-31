# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: LGPL-2.1-or-later

# This is not a kbuild Makefile. It is a plain Makefile so it can be copied

# If it exists includes Makefile.specific. In this Makefile, you should put
# specific Makefile code that you want to run before this. For example,
# build a particular environment.
-include Makefile.specific

# include parent_common.mk for buildsystem's defines
IGNORE_CPU_SUFFIX := y
REPO_PARENT ?=$(shell pwd)/../../../
-include $(REPO_PARENT)/parent_common.mk

ifdef REPO_PARENT
ZIO ?= $(REPO_PARENT)/zio
endif

ifndef ZIO
$(error "Missing ZIO environment variable")
endif
ZIO_ABS ?= $(abspath $(ZIO))

VERSION := $(shell git describe --tags --abbrev=0 | tr -d 'v')
SO_VERSION_XYZ := $(shell echo $(VERSION) | grep -o -E "[0-9]+\.[0-9]+\.[0-9]")
SO_VERSION_X := $(shell echo $(SO_VERSION_XYZ) | cut -d "." -f 1)

LIB = libfmctdc.a
LIBS = libfmctdc.so
LIBS_XYZ = $(LIBS).$(SO_VERSION_XYZ)
LOBJ := fmctdc-lib.o
LOBJ += fmctdc-lib-math.o

GIT_VERSION := $(shell git describe --dirty --long --tags)
ZIO_GIT_VERSION := $(shell cd $(ZIO_ABS); git describe --dirty --long --tags)

CFLAGS = -Wall -Werror -ggdb -O2 -I../kernel -I$(ZIO_ABS)/include
CFLAGS += -fPIC
CFLAGS += -DGIT_VERSION="\"$(GIT_VERSION)\""
CFLAGS += -DZIO_GIT_VERSION="\"$(ZIO_GIT_VERSION)\""
CFLAGS +=  $(EXTRACFLAGS)
DESTDIR ?= /usr/local
CPPCHECK ?= cppcheck
FLAWFINDER ?= flawfinder

modules all: lib

lib: $(LIB) $(LIBS_XYZ)

%: %.c $(LIB)
	$(CC) $(CFLAGS) $*.c $(LDFLAGS) -o $@

$(LIB): $(LOBJ)
	$(AR) r $@ $^

$(LIBS_XYZ): $(LIB)
	$(CC) -shared  -o $@ -Wl,--whole-archive,-soname,$@ $^ -Wl,--no-whole-archive

clean:
	rm -f $(LIB) $(LIBS_XYZ) .depend *.o *~

.depend: Makefile $(wildcard *.c *.h ../*.h)
	$(CC) $(CFLAGS) -M $(LOBJ:.o=.c) -o $@

install:
	install -d $(DESTDIR)/lib
	install -d $(DESTDIR)/include/fmc-tdc

	install -m 644 -D $(LIB) $(DESTDIR)/lib
	install -m 0755 $(LIBS_XYZ) $(DESTDIR)/lib
	install -m 644 -D fmctdc-lib.h $(DESTDIR)/include/fmc-tdc
	ln -sf $(LIBS_XYZ) $(DESTDIR)/lib/$(LIBS).$(SO_VERSION_X)
	ln -sf $(LIBS).$(SO_VERSION_X) $(DESTDIR)/lib/$(LIBS)

modules_install:

cppcheck:
	$(CPPCHECK) -q -I. -I../kernel -I $(ZIO_ABS)/include --suppress=missingIncludeSystem --enable=warning,style,information,missingInclude *.c *.h

flawfinder:
	$(FLAWFINDER) -SQDC --error-level=6 .

-include .depend

.PHONY: cppcheck flawfinder
