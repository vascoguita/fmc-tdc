LINUX ?= /lib/modules/$(shell uname -r)/build
ZIO ?= $(M)/../zio
FMC_BUS ?= $(M)/../fmc-bus
SPEC ?= $(M)/../spec-sw

KBUILD_EXTRA_SYMBOLS := $(ZIO)/Module.symvers $(SPEC)/kernel/Module.symvers $(FMC_BUS)/kernel/Module.symvers

ccflags-y = -I$(ZIO)/include -I$M  -I$(FMC_BUS)/kernel/include -I$(FMC_BUS)/kernel/include/linux -I$(FMC_BUS)/sdb-lib  -I$(SPEC)/kernel

#ccflags-y += -DDEBUG

subdirs-ccflags-y = $(ccflags-y)

obj-m := fmc-tdc.o

fmc-tdc-objs = acam.o calibration.o ft-spec.o ft-core.o onewire.o time.o ft-irq.o ft-zio.o ../fmc-bus/sdb-lib/access.o ../fmc-bus/sdb-lib/glue.o

all: modules

modules_install clean modules:
	$(MAKE) -C $(LINUX) M=$(shell /bin/pwd) $@
