# SPDX-FileCopyrightText: 2020 CERN (home.cern)
# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: CC-BY-SA-4.0+

# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    =
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile doxygen

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	$(MAKE) doxygen TARGET=$@
	$(MAKE) -C img all
	$(MAKE) -C gateware/regs all
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
clean:
	$(MAKE) -C img clean
	$(MAKE) -C gateware/regs clean
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

GIT_VERSION = $(shell cd $(src); git describe --dirty --long --tags)

doxygen:
ifeq ($(TARGET),clean)
	@echo "Remove Doxygen files"
	@rm -rf doxygen-lib-output
else
	GIT_VERSION=$(GIT_VERSION) doxygen ./doxygen-fmctdc-config
endif
