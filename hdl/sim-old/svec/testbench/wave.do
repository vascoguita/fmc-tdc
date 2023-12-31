# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: CERN-OHL-W-2.0+

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/clk_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/rst_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/tdc_config_wb_adr_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/tdc_config_wb_cyc_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/tdc_config_wb_dat_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/tdc_config_wb_stb_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/tdc_config_wb_we_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_config_rdbk_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_status_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_ififo1_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_ififo2_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_start01_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/wr_index_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/local_utc_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/core_status_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/irq_code_i
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/tdc_config_wb_ack_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/tdc_config_wb_dat_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_config_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/activate_acq_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/deactivate_acq_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_wr_config_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_rdbk_config_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_rst_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_rdbk_status_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_rdbk_ififo1_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_rdbk_ififo2_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_rdbk_start01_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/dacapo_c_rst_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/send_dac_word_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/dac_word_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/load_utc_p_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/starting_utc_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/irq_tstamp_threshold_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/irq_time_threshold_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/one_hz_phase_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_inputs_en_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/start_phase_o
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_config
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/reg_adr
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/reg_adr_pipe0
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/starting_utc
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/acam_inputs_en
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/start_phase
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/ctrl_reg
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/one_hz_phase
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/irq_tstamp_threshold
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/irq_time_threshold
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/clear_ctrl_reg
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/send_dac_word_p
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/dac_word
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/pulse_extender_en
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/pulse_extender_c
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/dat_out
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/dat_out_pipe0
add wave -noupdate /main/DUT/cmp_tdc_board0/tdc_core/reg_control_block/tdc_config_wb_ack_o_pipe0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {505599788 ps} 0}
configure wave -namecolwidth 177
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {441541177 ps} {657429313 ps}
