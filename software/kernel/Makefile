# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: LGPL-2.1-or-later

-include Makefile.specific
# include parent_common.mk for buildsystem's defines
#use absolute path for REPO_PARENT
TOPDIR ?= $(shell /bin/pwd)/../..
REPO_PARENT ?= $(TOPDIR)/..
-include $(REPO_PARENT)/parent_common.mk

TDC_HDL := $(TOPDIR)/hdl

CPPCHECK ?= cppcheck
FLAWFINDER ?= flawfinder
DKMS ?= 0
CURDIR := $(shell /bin/pwd)
KVERSION ?= $(shell uname -r)
KERNELSRC ?= /lib/modules/$(KVERSION)/build
WBGEN2 ?= wbgen2

ifdef REPO_PARENT
ZIO ?= $(REPO_PARENT)/fmc/zio
FMC ?= $(REPO_PARENT)/fmc-sw
endif

ifeq ($(DKMS), 1)
# Take last installed version (if installed using RPM it should be OK)
ZIO_VERSION ?= $(shell basename $(shell ls -d $(DKMSTREE)/zio/* | grep -E "\/[0-9]+\.[0-9]+\.[0-9]+" | sort -V | tail -n 1))
ZIO_ABS ?= $(DKMSTREE)/zio/$(ZIO_VERSION)/source
ZIO_EXTRA_SYMBOLS-y = $(DKMSTREE)/zio/kernel-$(KVERSION)-$(shell uname -p)/module/Module.symvers
else

ifndef ZIO
$(error "Missing ZIO environment variable")
endif
ifndef FMC
$(error "Missing FMC environment variable")
endif

ZIO_ABS ?= $(abspath $(ZIO))
ZIO_EXTRA_SYMBOLS-y = $(ZIO_ABS)/drivers/zio/Module.symvers
ZIO_VERSION ?= $(shell cd $(ZIO_ABS); git describe --always --dirty --long --tags)
FMC_ABS ?= $(abspath $(FMC))
FMC_EXTRA_SYMBOLS-y = $(FMC_ABS)/drivers/fmc/Module.symvers

endif

VMEBUS_ABS ?= $(abspath $(VMEBUS) )

GIT_VERSION = $(shell git describe --always --dirty --long --tags)

all: modules

hw_headers: tdc_dma_eic.h tdc_onewire_regs.h tdc_buffer_control_regs.h timestamp_fifo_regs.h

tdc_dma_eic.h: $(TDC_HDL)/rtl/wbgen/dma_eic.wb
	$(WBGEN2) -s defines -C hw/$@ $<

tdc_onewire_regs.h: $(TDC_HDL)/rtl/wbgen/tdc_onewire_wb.wb
	$(WBGEN2) -s defines -C hw/$@ $<

tdc_buffer_control_regs.h: $(TDC_HDL)/rtl/wbgen/tdc_buffer_control_regs.wb
	$(WBGEN2) -s defines -C hw/$@ $<

timestamp_fifo_regs.h: $(TDC_HDL)/rtl/wbgen/timestamp_fifo_wb.wb
	$(WBGEN2) -s defines -C hw/$@ $<

modules: hw_headers
	$(MAKE) -C $(KERNELSRC) M=$(CURDIR) ZIO_ABS=$(ZIO_ABS) FMC_ABS=$(FMC_ABS) \
		ZIO_EXTRA_SYMBOLS-y=$(ZIO_EXTRA_SYMBOLS-y) \
		FMC_EXTRA_SYMBOLS-y=$(FMC_EXTRA_SYMBOLS-y) \
		ZIO_VERSION=$(ZIO_VERSION) \
		GIT_VERSION=$(GIT_VERSION) \
		$@

install modules_install: modules
	$(MAKE) -C $(KERNELSRC) M=$(CURDIR) modules_install

# be able to run the "clean" rule even if $(KERNELSRC) is not valid
clean:
	rm -rf *.o *~  .*.cmd *.ko *.mod.c .tmp_versions Module.symvers \
		Module.markers modules.order
	rm -f hw/tdc_dma_eic.h hw/tdc_onewire_regs.h
	rm -f hw/tdc_buffer_control_regs.h hw/timestamp_fifo_regs.h
	rm -f hw/channel_regs.h

cppcheck:
	$(CPPCHECK) -q -I. -I$(ZIO_ABS)/include -I$(FMC_BUS_ABS)/  --enable=all *.c *.h

flawfinder:
	$(FLAWFINDER) -SQDC --error-level=3 .
