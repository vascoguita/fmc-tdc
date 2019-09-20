-include Makefile.specific
# include parent_common.mk for buildsystem's defines
#use absolute path for REPO_PARENT
REPO_PARENT ?= $(shell /bin/pwd)/../..
-include $(REPO_PARENT)/parent_common.mk

LINUX ?= /lib/modules/$(shell uname -r)/build

ZIO ?= ../zio

# ZIO_ABS has to be absolut path, due to beeing
# passed to the Kbuild
ZIO_ABS ?= $(abspath $(ZIO) )
ZIO_EXTRA_SYMBOLS-y = $(ZIO_ABS)/Module.symvers

FMC_ABS ?= $(abspath $(FMC))
FMC_EXTRA_SYMBOLS-y = $(FMC_ABS)/drivers/fmc/Module.symvers

ZIO_VERSION     ?= $(shell cd $(ZIO_ABS);     git describe --always --dirty --long --tags)

export ZIO_VERSION

CPPCHECK ?= cppcheck

all: modules

modules_install modules:
	$(MAKE) -C $(LINUX) M=$(shell /bin/pwd) \
		ZIO_ABS=$(ZIO_ABS) FMC_ABS=$(FMC_ABS) \
		ZIO_EXTRA_SYMBOLS-y=$(ZIO_EXTRA_SYMBOLS-y) \
		FMC_EXTRA_SYMBOLS-y=$(FMC_EXTRA_SYMBOLS-y) \
		SPEC_SW_ABS=$(SPEC_SW_ABS) $@

clean:
	$(MAKE) -C $(LINUX) M=$(shell /bin/pwd) $@

cppcheck:
	$(CPPCHECK) -q -I. -I$(ZIO_ABS)/include -I$(FMC_BUS_ABS)/sdb-lib/  --enable=all *.c *.h
