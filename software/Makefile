# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: LGPL-2.1-or-later

# include parent_common.mk for buildsystem's defines
# use absolute path for REPO_PARENT
REPO_PARENT ?= $(shell /bin/pwd)/../../
-include $(REPO_PARENT)/parent_common.mk

all: kernel lib tools

DIRS = kernel lib tools

$(SPEC_SW_ABS):
kernel:
lib:
tools: lib

DESTDIR ?= /usr/local

.PHONY: all clean cppcheck flawfinder modules install modules_install $(DIRS)

install modules_install:

all clean modules install modules_install: $(DIRS)

clean: TARGET = clean
modules: TARGET = modules
install: TARGET = install
modules_install: TARGET = modules_install


$(DIRS):
	$(MAKE) -C $@ $(TARGET)

flawfinder cppcheck:
	for d in $(DIRS); do $(MAKE) -C $$d $@ || exit 1; done
