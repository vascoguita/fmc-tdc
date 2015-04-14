onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group VME /main/VME/sys_rst_n_i
add wave -noupdate -expand -group VME /main/VME/as_n
add wave -noupdate -expand -group VME /main/VME/rst_n
add wave -noupdate -expand -group VME /main/VME/write_n
add wave -noupdate -expand -group VME /main/VME/am
add wave -noupdate -expand -group VME /main/VME/ds_n
add wave -noupdate -expand -group VME /main/VME/ga
add wave -noupdate -expand -group VME /main/VME/berr_n
add wave -noupdate -expand -group VME /main/VME/dtack_n
add wave -noupdate -expand -group VME /main/VME/retry_n
add wave -noupdate -expand -group VME /main/VME/lword_n
add wave -noupdate -expand -group VME /main/VME/addr
add wave -noupdate -expand -group VME /main/VME/data
add wave -noupdate -expand -group VME /main/VME/bbsy_n
add wave -noupdate -expand -group VME /main/VME/irq_n
add wave -noupdate -expand -group VME /main/VME/iackin_n
add wave -noupdate -expand -group VME /main/VME/iackout_n
add wave -noupdate -expand -group VME /main/VME/iack_n
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/clk_sys_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/rst_sys_n_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/clk_tdc_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/rst_tdc_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/acam_refclk_r_edge_p_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/send_dac_word_p_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/dac_word_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/start_from_fpga_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/err_flag_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/int_flag_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/start_dis_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/stop_dis_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/data_bus_io
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/address_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cs_n_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/oe_n_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/rd_n_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wr_n_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/ef1_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/ef2_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/enable_inputs_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/term_en_1_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/term_en_2_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/term_en_3_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/term_en_4_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/term_en_5_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_led_status_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_led_trig1_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_led_trig2_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_led_trig3_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_led_trig4_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_led_trig5_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_in_fpga_1_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_in_fpga_2_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_in_fpga_3_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_in_fpga_4_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_in_fpga_5_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wrabbit_link_up_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wrabbit_time_valid_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wrabbit_cycles_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wrabbit_utc_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wrabbit_clk_aux_lock_en_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wrabbit_clk_aux_locked_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wrabbit_clk_dmtd_locked_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wrabbit_dac_value_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wrabbit_dac_wr_p_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/slave_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/slave_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wb_irq_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/i2c_scl_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/i2c_scl_oen_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/i2c_scl_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/i2c_sda_oen_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/i2c_sda_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/i2c_sda_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/onewire_b
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/direct_timestamp_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/direct_timestamp_stb_o
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/general_rst_n
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/rst_ref_0_n
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cnx_master_out
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cnx_master_in
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_core_wb_adr
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tdc_mem_wb_adr
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/mezz_owr_en
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/mezz_owr_i
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/sys_scl_in
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/sys_scl_out
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/sys_scl_oe_n
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/sys_sda_in
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/sys_sda_out
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/sys_sda_oe_n
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/irq_tstamp
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/reg_to_wr
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/reg_from_wr
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wrabbit_utc_p
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/wrabbit_synched
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/irq_channel
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/timestamp
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/timestamp_stb
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/channel_enable
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/irq_threshold
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/irq_timeout
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/tick_1ms
add wave -noupdate -group Mezzanine /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/counter_1ms
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/clk_sys_i
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/clk_tdc_i
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/rst_n_sys_i
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/rst_tdc_i
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/slave_i
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/slave_o
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/irq_o
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/enable_i
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/tick_i
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/irq_threshold_i
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/irq_timeout_i
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/timestamp_i
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/timestamp_valid_i
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/tmr_timeout
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/buf_irq_int
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/buf_count
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/last_ts
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/regs_in
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/regs_out
add wave -noupdate -group Fifo0 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/gen_fifos(0)/U_TheFifo/channel_id
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/clk_sys_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/rst_n_sys_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/clk_tdc_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/rst_tdc_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_refclk_r_edge_p_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/send_dac_word_p_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/dac_word_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/start_from_fpga_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/err_flag_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/int_flag_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/start_dis_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/stop_dis_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_bus_io
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/address_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/cs_n_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/oe_n_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/rd_n_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wr_n_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/ef1_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/ef2_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/enable_inputs_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/term_en_1_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/term_en_2_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/term_en_3_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/term_en_4_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/term_en_5_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_status_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig1_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig2_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig3_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig4_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig5_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_1_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_2_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_3_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_4_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_5_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_status_reg_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_ctrl_reg_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_synched_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_tai_p_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_tai_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/cfg_slave_i
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/cfg_slave_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/timestamp_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/timestamp_stb_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/channel_enable_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/irq_threshold_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/irq_timeout_o
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_adr
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_cyc
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_stb
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_we
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_ack
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_dat_r
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_dat_w
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ef1
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ef2
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ef1_meta
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ef2_meta
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_errflag_f_edge_p
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_errflag_r_edge_p
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_intflag_f_edge_p
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp1
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp2
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp1_ok_p
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp2_ok_p
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/activate_acq_p
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/deactivate_acq_p
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/load_acam_config
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/read_acam_config
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/read_acam_status
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/read_ififo1
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/read_ififo2
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/read_start01
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reset_acam
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/load_utc
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/roll_over_incr_recent
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/deactivate_chan
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/pulse_delay
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/window_delay
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/clk_period
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/starting_utc
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_inputs_en
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ififo1
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ififo2
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_start01
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/irq_tstamp_threshold
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/irq_time_threshold
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_utc
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_config
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_config_rdbk
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/start_from_fpga
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/state_active_p
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/clk_i_cycles_offset
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/roll_over_nb
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/retrig_nb_offset
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_utc_p
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/current_retrig_nb
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/utc_p
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/utc
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_ctrl_reg
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_channel
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_1
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_2
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_3
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_4
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_5
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp_channel
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/rst_sys
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/timestamp_valid
add wave -noupdate -expand -group Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/timestamp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {936185162 ps} 0}
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
WaveRestoreZoom {890208852 ps} {1005778482 ps}
