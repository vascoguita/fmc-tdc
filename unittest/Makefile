# If it exists includes Makefile.specific. In this Makefile, you should put
# specific Makefile code that you want to run before this. For example,
# build a particular environment.
-include Makefile.specific

# include parent_common.mk for buildsystem's defines
REPO_PARENT ?= ../..
-include $(REPO_PARENT)/parent_common.mk

DESTDIR ?= /usr/local/
LIBTDC = ../lib/

CFLAGS = -ggdb -I. -I$(LIBTDC) -I../kernel -Wall -Werror $(EXTRACFLAGS)
GIT_VERSION := $(shell git describe --dirty --long --tags)
CFLAGS += -DGIT_VERSION="\"$(GIT_VERSION)\""

LDFLAGS = -L$(LIBTDC)
LDLIBS = -lfmctdc -lrt

all: fmctdc-ut

fmctdc-ut: fmctdc-ut.c $(LIBTDC)/libfmctdc.a

clean:
	rm -f $(TESTS) test-common.o
