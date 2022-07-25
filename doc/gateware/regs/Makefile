# SPDX-FileCopyrightText: 2020 CERN (home.cern)
# SPDX-FileCopyrightText: 2022 CERN (home.cern)
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

REST := spec_base_regs.rst
REST += svec_base_regs.rst
REST += svec_ref_fmc_tdc_mmap.rst
REST += spec_ref_fmc_tdc_mmap.rst
REST += fmc_tdc_mezzanine_mmap.rst


LATEX += dma_eic.tex
LATEX += fmc_tdc_direct_readout_slave.tex
LATEX += tdc_buffer_control_regs.tex
LATEX += tdc_eic.tex
LATEX += tdc_onewire_wb.tex
LATEX += timestamp_fifo_wb.tex

all: html latex rest

latex: $(LATEX)
html: $(HTML)
rest: $(REST)


.PHONY: clean

CHEBY_BUILD=(cd $(dir $<); ~/.local/bin/cheby -i $(notdir $<) --gen-doc --doc html) > $@
CHEBY_BUILD_REST=(cd $(dir $<); ~/.local/bin/cheby -i $(notdir $<) --gen-doc --doc rest) > $@
WBGEN2_BUILD=(~/wr/tdc/wishbone-gen/wbgen2 -D $@ $<)
WBGEN2_BUILD_TEX=(~/wr/tdc/wishbone-gen/wbgen2 -f latex -D $@ $<)

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

fmc_tdc_mezzanine_mmap.rst: $(TOP_DIR)/hdl/cheby/fmc_tdc_mezzanine_mmap.cheby
	$(CHEBY_BUILD_REST)

spec_ref_fmc_tdc_mmap.rst: $(TOP_DIR)/hdl/cheby/spec_ref_fmc_tdc_mmap.cheby
	$(CHEBY_BUILD_REST)

svec_ref_fmc_tdc_mmap.rst: $(TOP_DIR)/hdl/cheby/svec_ref_fmc_tdc_mmap.cheby
	$(CHEBY_BUILD_REST)

svec_base_regs.rst: $(TOP_DIR)/hdl/ip_cores/svec/hdl/rtl/svec_base_regs.cheby
	$(CHEBY_BUILD_REST)

spec_base_regs.rst: $(TOP_DIR)/hdl/ip_cores/spec/hdl/rtl/spec_base_regs.cheby
	$(CHEBY_BUILD_REST)

timestamp_fifo_wb.tex:            $(TOP_DIR)/hdl/rtl/wbgen/timestamp_fifo_wb.wb
	$(WBGEN2_BUILD_TEX)

dma_eic.tex:                      $(TOP_DIR)/hdl/rtl/wbgen/dma_eic.wb
	$(WBGEN2_BUILD_TEX)

fmc_tdc_direct_readout_slave.tex: $(TOP_DIR)/hdl/rtl/wbgen/fmc_tdc_direct_readout_slave.wb
	$(WBGEN2_BUILD_TEX)

tdc_buffer_control_regs.tex:      $(TOP_DIR)/hdl/rtl/wbgen/tdc_buffer_control_regs.wb
	$(WBGEN2_BUILD_TEX)

tdc_eic.tex:                      $(TOP_DIR)/hdl/rtl/wbgen/tdc_eic.wb
	$(WBGEN2_BUILD_TEX)

tdc_onewire_wb.tex:               $(TOP_DIR)/hdl/rtl/wbgen/tdc_onewire_wb.wb
	$(WBGEN2_BUILD_TEX)




clean:
	@rm -f *.rst *.htm *.html *.tex
