onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /main/DUT/cnx_master_out
add wave -noupdate -group Acam /main/ACAM/PuResN
add wave -noupdate -group Acam /main/ACAM/Alutrigger
add wave -noupdate -group Acam /main/ACAM/RefClk
add wave -noupdate -group Acam /main/ACAM/WRN
add wave -noupdate -group Acam /main/ACAM/RDN
add wave -noupdate -group Acam /main/ACAM/CSN
add wave -noupdate -group Acam /main/ACAM/OEN
add wave -noupdate -group Acam /main/ACAM/Adr
add wave -noupdate -group Acam /main/ACAM/TStart
add wave -noupdate -group Acam /main/ACAM/TStop
add wave -noupdate -group Acam /main/ACAM/StartDis
add wave -noupdate -group Acam /main/ACAM/StopDis
add wave -noupdate -group Acam /main/ACAM/IrFlag
add wave -noupdate -group Acam /main/ACAM/ErrFlag
add wave -noupdate -group Acam /main/ACAM/EF1
add wave -noupdate -group Acam /main/ACAM/EF2
add wave -noupdate -group Acam /main/ACAM/LF1
add wave -noupdate -group Acam /main/ACAM/LF2
add wave -noupdate -group Acam /main/ACAM/D
add wave -noupdate -group Acam /main/ACAM/c_empty_flag_delay
add wave -noupdate -group Acam /main/ACAM/start_masked
add wave -noupdate -group Acam /main/ACAM/stop1_masked
add wave -noupdate -group Acam /main/ACAM/r_MasterAluTrig
add wave -noupdate -group Acam /main/ACAM/r_StartDisStart
add wave -noupdate -group Acam /main/ACAM/DQ
add wave -noupdate -group Acam /main/ACAM/EF1_int
add wave -noupdate -group Acam /main/ACAM/EF2_int
add wave -noupdate -group Acam /main/ACAM/start_disabled_int
add wave -noupdate -group Acam /main/ACAM/imode_start_offset
add wave -noupdate -group Acam /main/ACAM/t
add wave -noupdate -group Acam /main/ACAM/t_prev
add wave -noupdate -group Acam /main/ACAM/fifo_empty
add wave -noupdate -group Acam /main/ACAM/fifo_notempty
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/clk_sys_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/rst_sys_n_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/clk_tdc_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/rst_tdc_n_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_refclk_r_edge_p_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/send_dac_word_p_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/dac_word_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_from_fpga_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/err_flag_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/int_flag_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_dis_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/stop_dis_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_bus_io
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/address_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/cs_n_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/oe_n_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/rd_n_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/wr_n_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/ef1_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/ef2_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/enable_inputs_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/term_en_1_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/term_en_2_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/term_en_3_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/term_en_4_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/term_en_5_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/tdc_led_status_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig1_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig2_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig3_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig4_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig5_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/wrabbit_status_reg_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/wrabbit_ctrl_reg_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/wrabbit_synched_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/wrabbit_tai_p_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/wrabbit_tai_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/cfg_slave_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/cfg_slave_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/timestamp_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/timestamp_valid_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/timestamp_ready_i
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/channel_enable_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/irq_threshold_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/irq_timeout_o
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acm_adr
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acm_cyc
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acm_stb
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acm_we
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acm_ack
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acm_dat_r
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acm_dat_w
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_ef1
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_ef2
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_ef1_meta
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_ef2_meta
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_errflag_f_edge_p
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_errflag_r_edge_p
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_intflag_f_edge_p
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp1
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp2
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp1_ok_p
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp2_ok_p
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/activate_acq_p
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/deactivate_acq_p
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/load_acam_config
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/read_acam_config
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/read_acam_status
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/read_ififo1
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/read_ififo2
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/read_start01
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reset_acam
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/load_utc
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/roll_over_incr_recent
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/deactivate_chan
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/pulse_delay
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/window_delay
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/clk_period
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/starting_utc
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_inputs_en
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_ififo1
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_ififo2
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_start01
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/irq_tstamp_threshold
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/irq_time_threshold
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/local_utc
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_config
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_config_rdbk
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_from_fpga
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/state_active_p
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/clk_i_cycles_offset
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/roll_over_nb
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/retrig_nb_offset
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/local_utc_p
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/current_retrig_nb
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/utc_p
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/utc
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/wrabbit_ctrl_reg
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_channel
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp_channel
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/raw_timestamp_valid
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/raw_timestamp
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/final_timestamp_valid
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/final_timestamp_ready
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/final_timestamp
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/channel_enable_int
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/rst_sys
add wave -noupdate -group Core /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/rst_tdc
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/clk_sys_i
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/rst_sys_n_i
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/clk_tdc_i
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/rst_tdc_n_i
add wave -noupdate -group Regs -expand /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/slave_i
add wave -noupdate -group Regs -expand /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/slave_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_config_rdbk_i
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_ififo1_i
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_ififo2_i
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_start01_i
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/local_utc_i
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/core_status_i
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_code_i
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wrabbit_status_reg_i
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_config_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/activate_acq_p_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/deactivate_acq_p_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_wr_config_p_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_config_p_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rst_p_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_status_p_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_ififo1_p_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_ififo2_p_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_start01_p_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/send_dac_word_p_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dac_word_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/load_utc_p_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/starting_utc_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_tstamp_threshold_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_time_threshold_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/one_hz_phase_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_inputs_en_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wrabbit_ctrl_reg_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/start_phase_o
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_config
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/reg_adr
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/reg_adr_pipe0
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/starting_utc
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_inputs_en
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/start_phase
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/ctrl_reg
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/one_hz_phase
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_tstamp_threshold
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_time_threshold
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/clear_ctrl_reg
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/send_dac_word_p
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dac_word
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/pulse_extender_en
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/pulse_extender_c
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wrabbit_ctrl_reg
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/ack_out_pipe0
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/ack_out_pipe1
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb0
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb1
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb2
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb3
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe0
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe1
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe2
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe3
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/cyc_in_progress
add wave -noupdate -group Regs -expand /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wb_in
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wb_out
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/cc_rst_n
add wave -noupdate -group Regs /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/cc_rst_n_or_sys
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/clk_i
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/rst_i
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/acam_refclk_r_edge_p_i
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/utc_p_i
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/state_active_p_i
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/activate_acq_p_i
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/deactivate_acq_p_i
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/err_flag_i
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/int_flag_i
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/start_from_fpga_o
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/stop_dis_o
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/acam_errflag_r_edge_p_o
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/acam_errflag_f_edge_p_o
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/acam_intflag_f_edge_p_o
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/int_flag_synch
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/err_flag_synch
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/acam_intflag_f_edge_p
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/start_pulse
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/wait_for_utc
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/rst_n
add wave -noupdate -group Timecontrol /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/wait_for_state_active
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/clk_i
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/rst_i
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/ef1_i
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/ef2_i
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/data_bus_io
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/cyc_i
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/stb_i
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/we_i
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/adr_i
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/dat_i
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/ef1_o
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/ef1_meta_o
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/ef2_o
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/ef2_meta_o
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/adr_o
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/cs_n_o
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/oe_n_o
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/rd_n_o
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/wr_n_o
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/ack_o
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/dat_o
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/acam_data_st
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/nxt_acam_data_st
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/ef1_synch
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/ef2_synch
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/ack
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/rd
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/rd_extend
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/wr
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/wr_extend
add wave -noupdate -group Datablk /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_data_block/wr_remove
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/clk_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/rst_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/activate_acq_p_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/deactivate_acq_p_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_wr_config_p_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rst_p_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rdbk_config_p_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rdbk_status_p_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rdbk_ififo1_p_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rdbk_ififo2_p_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rdbk_start01_p_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_config_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ef1_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ef1_meta_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ef2_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ef2_meta_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ack_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_dat_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/start_from_fpga_i
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/state_active_p_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_adr_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_cyc_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_stb_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_dat_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_we_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_config_rdbk_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ififo1_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ififo2_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_start01_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_tstamp1_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_tstamp2_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_tstamp1_ok_p_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_tstamp2_ok_p_o
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/engine_st
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/nxt_engine_st
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_cyc
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_stb
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_we
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_adr
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/config_adr_c
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_config_rdbk
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/reset_word
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_config_reg4
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/time_c_full_p
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/time_c_en
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/time_c_rst
add wave -noupdate -group DataEng /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/time_c
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/clk_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/rst_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/acam_tstamp1_ok_p_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/acam_tstamp1_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/acam_tstamp2_ok_p_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/acam_tstamp2_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/utc_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/roll_over_incr_recent_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/clk_i_cycles_offset_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/roll_over_nb_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/retrig_nb_offset_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/utc_p_i
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/timestamp_o
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/timestamp_valid_o
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/acam_channel
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/acam_slope
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/acam_fine_timestamp
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/acam_start_nb
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_acam_start_nb
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_clk_i_cycles_offset
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_roll_over
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_nb_of_retrig
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_retrig_nb_offset
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_nb_of_cycles
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_retrig_from_roll_over
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/acam_start_nb_32
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/full_timestamp
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/metadata
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/utc
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/coarse_time
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/fine_time
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/tstamp_on_first_retrig_case1
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/tstamp_on_first_retrig_case2
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/coarse_zero
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_previous_clk_i_cycles_offset
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_previous_retrig_nb_offset
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_previous_roll_over_nb
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_current_retrig_nb_offset
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_current_roll_over_nb
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_current_retrig_from_roll_over
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/un_acam_fine_time
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/previous_utc
add wave -noupdate -group DataFmt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_formatting_block/timestamp_valid_int
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/clk_tdc_i
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/rst_tdc_n_i
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/clk_sys_i
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/rst_sys_n_i
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/enable_i
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/ts_i
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/ts_valid_i
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/ts_o
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/ts_valid_o
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/ts_ready_i
add wave -noupdate -group FilterAndCvt -expand -subitemconfig {/main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/channels(0) -expand} /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/channels
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s1_frac_scaled
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s1_tai
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s2_tai
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s3_tai
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s1_valid
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s2_valid
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s3_valid
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s1_coarse
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s2_coarse
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s3_coarse
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s2_frac
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s3_frac
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/coarse_adj
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s1_channel
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s2_channel
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s3_channel
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s1_edge
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s2_edge
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s3_edge
add wave -noupdate -group FilterAndCvt -expand /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/s3_ts
add wave -noupdate -group FilterAndCvt /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/U_FilterAndConvert/ts_valid_sys
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/clk_sys_i
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/rst_sys_n_i
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/slave_i
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/slave_o
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/irq_o
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/enable_i
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/tick_i
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/irq_threshold_i
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/irq_timeout_i
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/timestamp_i
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/timestamp_valid_i
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/tmr_timeout
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/buf_irq_int
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/buf_count
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/last_ts
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/regs_in
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/regs_out
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/channel_id
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/ts_match
add wave -noupdate -expand -group fifo0 /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/gen_without_dma_readout/gen_fifos(0)/U_TheFifo/timestamp_with_seq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {648894565 ps} 0}
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
WaveRestoreZoom {0 ps} {2097152 ns}
