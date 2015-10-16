LINUX ?= /lib/modules/$(shell uname -r)/build
# FMC_BUS, ZIO, SPEC_SW comes from the upper level

GIT_VERSION = $(shell git describe --always --dirty --long --tags)
export GIT_VERSION

ZIO_VERSION = $(shell cd $(ZIO); git describe --always --dirty --long --tags)
export ZIO_VERSION

all: modules

modules_install modules:
	rm -f fmc-bus-link
	ln -s $(FMC_BUS) fmc-bus-link
	$(MAKE) -C $(LINUX) M=$(shell /bin/pwd) $@
	rm -f fmc-bus-link

clean:
	$(MAKE) -C $(LINUX) M=$(shell /bin/pwd) $@
