LINUX ?= /lib/modules/$(shell uname -r)/build
#LINUX ?= ../
ZIO ?= $(HOME)/dependencies/zio
SPEC_SW ?= $(HOME)/dependencies/spec-sw

KBUILD_EXTRA_SYMBOLS := $(ZIO)/Module.symvers $(SPEC_SW)/kernel/Module.symvers

ccflags-y = -I$(ZIO)/include -I$(SPEC_SW)/kernel -I$M

#ccflags-y += -DDEBUG

subdirs-ccflags-y = $(ccflags-y)

obj-m := spec-tdc.o

spec-tdc-objs	=  tdc-core.o tdc-zio.o tdc-spec.o tdc-acam.o

all: modules

modules_install clean modules:
	$(MAKE) -C $(LINUX) M=$(shell /bin/pwd) $@
