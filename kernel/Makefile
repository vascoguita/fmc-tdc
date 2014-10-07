LINUX ?= /lib/modules/$(shell uname -r)/build
# FMC_BUS, ZIO, SPEC_SW comes from the upper level

KBUILD_EXTRA_SYMBOLS := \
	$(ZIO)/Module.symvers \
	$(SPEC_SW)/kernel/Module.symvers \
	$(FMC_BUS)/kernel/Module.symvers

GIT_VERSION = $(shell cd $(src); git describe --always --dirty --long --tags)

# For this CSM_VERSION, please see ohwr.org/csm documentation
ifdef CONFIG_CSM_VERSION
  ccflags-y += -D"CERN_SUPER_MODULE=MODULE_VERSION(\"$(CONFIG_CSM_VERSION)\")"
else
  ccflags-y += -DCERN_SUPER_MODULE=""
endif

ccflags-y = -DGIT_VERSION=\"$(GIT_VERSION)\" \
	-I$(src) \
	-I$(ZIO)/include \
	-I$(FMC_BUS)/kernel/include \
	-I$(FMC_BUS)/kernel/include/linux \
	-I$(FMC_BUS)/sdb-lib \
	-I$(SPEC_SW)/kernel
ccflags-$(CONFIG_FMC_TDC_DEBUG) += -DDEBUG

subdirs-ccflags-y = $(ccflags-y)

obj-m := fmc-tdc.o
fmc-tdc-objs = acam.o calibration.o fmc-util.o ft-spec.o \
		ft-svec.o ft-core.o onewire.o ft-time.o ft-irq.o ft-zio.o\
		fmc-bus-link/sdb-lib/access.o fmc-bus-link/sdb-lib/glue.o

all: modules

modules_install modules:
	rm -f fmc-bus-link
	ln -s $(FMC_BUS) fmc-bus-link
	$(MAKE) -C $(LINUX) M=$(shell /bin/pwd) $@
	rm -f fmc-bus-link

clean:
	$(MAKE) -C $(LINUX) M=$(shell /bin/pwd) $@
