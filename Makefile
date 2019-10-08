# include parent_common.mk for buildsystem's defines
#use absolute path for REPO_PARENT
REPO_PARENT ?= $(shell /bin/pwd)/..
-include $(REPO_PARENT)/parent_common.mk

all: kernel lib tools

# a hack, to prevent compiling wr-nic.ko, which won't work on older kernels
CONFIG_WR_NIC=n
export CONFIG_WR_NIC

# The user can override, using environment variables, all these three:
ZIO ?= $(shell pwd)/zio

# ZIO_ABS has to be absolut path, due to beeing
# passed to the Kbuild
ZIO_ABS ?= $(abspath $(ZIO) )

export ZIO_ABS

ZIO_VERSION = $(shell cd $(ZIO_ABS); git describe --always --dirty --long --tags)
export ZIO_VERSION


DIRS = $(ZIO_ABS) kernel lib tools mamma/lib unittest

kernel: $(ZIO_ABS)
lib: $(ZIO_ABS)
tools: lib

.PHONY: all clean modules install modules_install $(DIRS)
.PHONY: gitmodules prereq_install prereq_install_warn

install modules_install: prereq_install_warn

all clean modules install modules_install: $(DIRS)

clean: TARGET = clean
modules: TARGET = modules
install: TARGET = install
modules_install: TARGET = modules_install


$(DIRS):
	$(MAKE) -C $@ $(TARGET)


SUBMOD = $(ZIO_ABS)

prereq_install_warn:
	@test -f .prereq_installed || \
		echo -e "\n\n\tWARNING: Consider \"make prereq_install\"\n"

prereq_install:
	for d in $(SUBMOD); do $(MAKE) -C $$d modules_install || exit 1; done
	touch .prereq_installed

$(ZIO_ABS): zio-init_repo

# init submodule if missing
zio-init_repo:
	@test -d $(ZIO_ABS)/doc || ( echo "Checking out submodule $(ZIO_ABS)" && git submodule update --init $(ZIO_ABS) )

cppcheck:
	for d in kernel lib tools; do $(MAKE) -C $$d cppcheck || exit 1; done
