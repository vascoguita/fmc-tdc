# SPDX-FileCopyrightText: 2020 CERN (home.cern)
#
# SPDX-License-Identifier: CC0-1.0

TOP_DIR = ../../..

HTML := spec_base_regs.htm
HTML += svec_base_regs.htm
HTML += svec_ref_fmc_tdc_mmap.htm
HTML += spec_ref_fmc_tdc_mmap.htm
HTML += fmc_tdc_mezzanine_mmap.htm

all: $(HTML)

.PHONY: clean

CHEBY_BUILD=(cd $(dir $<); cheby -i $(notdir $<) --gen-doc --doc html) > $@

fmc_tdc_mezzanine_mmap.htm: $(TOP_DIR)/hdl/cheby/fmc_tdc_mezzanine_mmap.cheby
	$(CHEBY_BUILD)

spec_ref_fmc_tdc_mmap.htm: $(TOP_DIR)/hdl/cheby/spec_ref_fmc_tdc_mmap.cheby
	$(CHEBY_BUILD)

svec_ref_fmc_tdc_mmap.htm: $(TOP_DIR)/hdl/cheby/svec_ref_fmc_tdc_mmap.cheby
	$(CHEBY_BUILD)

svec_base_regs.htm: $(TOP_DIR)/hdl/ip_cores/svec/hdl/rtl/svec_base_regs.cheby
	$(CHEBY_BUILD)

spec_base_regs.htm: $(TOP_DIR)/hdl/ip_cores/spec/hdl/rtl/spec_base_regs.cheby
	$(CHEBY_BUILD)

clean:
	@rm -f *.md *.rst *.htm