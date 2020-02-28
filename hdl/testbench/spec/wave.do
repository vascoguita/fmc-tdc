onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/clk_i
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/rst_i
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/utc_p_i
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/state_active_p_i
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/activate_acq_p_i
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/deactivate_acq_p_i
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/start_from_fpga_o
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/stop_dis_o
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/acam_intflag_f_edge_p
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/start_pulse
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/wait_for_utc
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/rst_n
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/wait_for_state_active
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/engine_st
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_cyc
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_stb
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_we
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_adr
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ef1_i
add wave -noupdate /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ef2_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/clk_sys_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/rst_sys_n_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/clk_tdc_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/rst_tdc_n_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/fmc_id_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/acam_refclk_r_edge_p_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/send_dac_word_p_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/dac_word_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/start_from_fpga_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/err_flag_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/int_flag_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/start_dis_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/stop_dis_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/data_bus_io
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/address_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cs_n_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/oe_n_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/rd_n_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wr_n_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/ef1_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/ef2_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/enable_inputs_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/term_en_1_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/term_en_2_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/term_en_3_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/term_en_4_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/term_en_5_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_led_stat_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_led_trig_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_link_up_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_time_valid_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_cycles_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_utc_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_clk_aux_lock_en_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_clk_aux_locked_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_clk_dmtd_locked_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_dac_value_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_dac_wr_p_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/slave_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/slave_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/dma_wb_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/dma_wb_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wb_irq_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_scl_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_scl_oen_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_scl_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_sda_oen_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_sda_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_sda_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/onewire_b
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp_valid_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sim_timestamp_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sim_timestamp_valid_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sim_timestamp_ready_o
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/general_rst_n
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/rst_ref_0_n
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cnx_master_out
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cnx_master_in
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_core_wb_adr
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_mem_wb_adr
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/mezz_owr_en
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/mezz_owr_i
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_scl_in
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_scl_out
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_scl_oe_n
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_sda_in
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_sda_out
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_sda_oe_n
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/irq_tstamp
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/reg_to_wr
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/reg_from_wr
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_utc_p
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_synched
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/irq_fifo
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/irq_dma
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp_valid
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp_ready
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp_stb
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_timestamp
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_timestamp_valid
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_timestamp_ready
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_timestamp_valid_p
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/channel_enable
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/irq_threshold
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/irq_timeout
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tick_1ms
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/counter_1ms
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/ts_offset
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/reset_seq
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/raw_enable
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/regs_ow_out
add wave -noupdate -expand -group FmcTdcMezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/regs_ow_in
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10122127 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 383
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
WaveRestoreZoom {8005809 ps} {9332857 ps}
