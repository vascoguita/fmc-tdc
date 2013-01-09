LINUX ?= /lib/modules/$(shell uname -r)/build
ZIO ?= $(HOME)/zio
SPEC_SW ?= $(HOME)/spec-sw

KBUILD_EXTRA_SYMBOLS := $(ZIO)/Module.symvers $(SPEC_SW)/kernel/Module.symvers $(SPEC_SW)/fmc-bus/kernel/Module.symvers

ccflags-y = -I$(ZIO)/include -I$(SPEC_SW)/kernel -I$M -I$(SPEC_SW)/kernel -I$(SPEC_SW)/fmc-bus/kernel/include

#ccflags-y += -DDEBUG

subdirs-ccflags-y = $(ccflags-y)

obj-m := spec-tdc.o

spec-tdc-objs	=  tdc-core.o tdc-zio.o tdc-fmc.o tdc-acam.o tdc-dma.o

all: modules

modules_install clean modules:
	$(MAKE) -C $(LINUX) M=$(shell /bin/pwd) $@
