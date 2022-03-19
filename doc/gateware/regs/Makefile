# SPDX-FileCopyrightText: 2020 CERN (home.cern)
#
# SPDX-License-Identifier: CC0-1.0

TOP_DIR = ../../..

HTML := spec_base_regs.htm
HTML += svec_base_regs.htm
HTML += svec_ref_fmc_tdc_mmap.htm
HTML += spec_ref_fmc_tdc_mmap.htm
HTML += fmc_tdc_mezzanine_mmap.htm

HTML += dma_eic.html
HTML += fmc_tdc_direct_readout_slave.html
HTML += tdc_buffer_control_regs.html
HTML += tdc_eic.html
HTML += tdc_onewire_wb.html
HTML += timestamp_fifo_wb.html

all: $(HTML)

.PHONY: clean

CHEBY_BUILD=(cd $(dir $<); ~/.local/bin/cheby -i $(notdir $<) --gen-doc --doc html) > $@
WBGEN2_BUILD=(wbgen2 -D $@ $<)

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

timestamp_fifo_wb.html:            $(TOP_DIR)/hdl/rtl/wbgen/timestamp_fifo_wb.wb
	$(WBGEN2_BUILD)

dma_eic.html:                      $(TOP_DIR)/hdl/rtl/wbgen/dma_eic.wb
	$(WBGEN2_BUILD)

fmc_tdc_direct_readout_slave.html: $(TOP_DIR)/hdl/rtl/wbgen/fmc_tdc_direct_readout_slave.wb
	$(WBGEN2_BUILD)

tdc_buffer_control_regs.html:      $(TOP_DIR)/hdl/rtl/wbgen/tdc_buffer_control_regs.wb
	$(WBGEN2_BUILD)

tdc_eic.html:                      $(TOP_DIR)/hdl/rtl/wbgen/tdc_eic.wb
	$(WBGEN2_BUILD)

tdc_onewire_wb.html:               $(TOP_DIR)/hdl/rtl/wbgen/tdc_onewire_wb.wb
	$(WBGEN2_BUILD)

timestamp_fifo_wb.html:            $(TOP_DIR)/hdl/rtl/wbgen/timestamp_fifo_wb.wb
	$(WBGEN2_BUILD)

clean:
	@rm -f *.md *.rst *.htm *.html
