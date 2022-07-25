#!/bin/bash
# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: CC0-1.0

wbgen2 -V timestamp_fifo_wb.vhd -H record_full -p timestamp_fifo_wbgen2_pkg.vhd -K timestamp_fifo_regs.vh -s defines -C timestamp_fifo_regs.h -D wbgen/timestamp_fifo_wb.html wbgen/timestamp_fifo_wb.wb 
wbgen2 -V tdc_onewire_wb.vhd -H record_full -p tdc_onewire_wbgen2_pkg.vhd -K timestamp_onewire_regs.vh -s defines -C tdc_onewire_regs.h wbgen/tdc_onewire_wb.wb 
#wbgen2 -V tdc_buffer_control_regs.vhd -H record_full -p tdc_buffer_control_regs_wbgen2_pkg.vhd -K tdc_buffer_control_regs.vh -s defines -C tdc_buffer_control_regs.h wbgen/tdc_buffer_control_regs.wb 

#don't do this, latest wbgen is buggy
#wbgen2 -V tdc_eic.vhd -s defines -C tdc_eic.h -D wbgen/tdc_eic.html wbgen/tdc_eic.wb

# wbgen2 --hstyle=record -V ../fmc_tdc_direct_readout_slave.vhd -p ../fmc_tdc_direct_readout_slave_pkg.vhd -s defines -C fmctdc-direct.h fmc_tdc_direct_readout_slave.wb
