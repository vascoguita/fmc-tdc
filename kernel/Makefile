# include parent_common.mk for buildsystem's defines
#use absolute path for REPO_PARENT
REPO_PARENT=$(shell /bin/pwd)/../..
-include $(REPO_PARENT)/parent_common.mk

LINUX ?= /lib/modules/$(shell uname -r)/build

FMC_BUS ?= ../fmc-bus
ZIO ?= ../zio
SPEC_SW ?= ../spec-sw

# FMC_BUS_ABS, ZIO_ABS and SPEC_SW_ABS has to be absolut path, due to beeing
# passed to the Kbuild
FMC_BUS_ABS ?= $(abspath $(FMC_BUS) )
ZIO_ABS ?= $(abspath $(ZIO) )
SPEC_SW_ABS ?= $(abspath $(SPEC_SW) )

GIT_VERSION = $(shell git describe --always --dirty --long --tags)
export GIT_VERSION

ZIO_VERSION = $(shell cd $(ZIO_ABS); git describe --always --dirty --long --tags)
export ZIO_VERSION

all: modules

modules_install modules:
	rm -f fmc-bus-link
	ln -s $(FMC_BUS_ABS) fmc-bus-link
	$(MAKE) -C $(LINUX) M=$(shell /bin/pwd) FMC_BUS_ABS=$(FMC_BUS_ABS) ZIO_ABS=$(ZIO_ABS) SPEC_SW_ABS=$(SPEC_SW_ABS) $@
	rm -f fmc-bus-link

clean:
	$(MAKE) -C $(LINUX) M=$(shell /bin/pwd) $@
