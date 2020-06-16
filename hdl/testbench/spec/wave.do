onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/clk_sys_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/rst_sys_n_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/clk_tdc_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/rst_tdc_n_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/fmc_id_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/acam_refclk_r_edge_p_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/send_dac_word_p_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/dac_word_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/start_from_fpga_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/err_flag_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/int_flag_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/start_dis_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/stop_dis_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/data_bus_io
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/address_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cs_n_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/oe_n_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/rd_n_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wr_n_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/ef1_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/ef2_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/enable_inputs_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/term_en_1_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/term_en_2_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/term_en_3_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/term_en_4_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/term_en_5_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_led_stat_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_led_trig_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_link_up_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_time_valid_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_cycles_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_utc_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_clk_aux_lock_en_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_clk_aux_locked_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_clk_dmtd_locked_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_dac_value_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_dac_wr_p_i
add wave -noupdate -group Mezz -expand /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/slave_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/slave_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/dma_wb_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/dma_wb_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wb_irq_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_scl_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_scl_oen_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_scl_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_sda_oen_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_sda_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/i2c_sda_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/onewire_b
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp_valid_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sim_timestamp_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sim_timestamp_valid_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sim_timestamp_ready_o
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/general_rst_n
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/rst_ref_0_n
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cnx_master_out
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cnx_master_in
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_core_wb_adr
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_mem_wb_adr
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/mezz_owr_en
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/mezz_owr_i
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_scl_in
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_scl_out
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_scl_oe_n
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_sda_in
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_sda_out
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/sys_sda_oe_n
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/irq_tstamp
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/reg_to_wr
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/reg_from_wr
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_utc_p
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/wrabbit_synched
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/irq_fifo
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/irq_dma
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp_valid
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp_ready
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/timestamp_stb
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_timestamp
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_timestamp_valid
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_timestamp_ready
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tdc_timestamp_valid_p
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/channel_enable
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/irq_threshold
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/irq_timeout
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/tick_1ms
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/counter_1ms
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/ts_offset
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/reset_seq
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/raw_enable
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/regs_ow_out
add wave -noupdate -group Mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/regs_ow_in
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/clk_i
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/rst_n_i
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/enable_i
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/raw_mode_i
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/ts_i
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/ts_valid_i
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/ts_ready_o
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/slave_i
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/slave_o
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/irq_o
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/dma_wb_o
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/dma_wb_i
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/cr_cnx_master_out
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/cr_cnx_master_in
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/dma_cnx_slave_out
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/dma_cnx_slave_in
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/c_CR_CNX_BASE_ADDR
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/c_CR_CNX_BASE_MASK
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/irq_tick_div
add wave -noupdate -group DMAEng /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/irq_tick
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/clk_i
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/rst_n_i
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/enable_i
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/raw_mode_i
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/ts_i
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/ts_valid_i
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/ts_ready_o
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/slave_i
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/slave_o
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/irq_tick_i
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/irq_o
add wave -noupdate -group DMACh0 -expand /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/dma_wb_o
add wave -noupdate -group DMACh0 -expand /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/dma_wb_i
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/cur_base
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/cur_size
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/cur_valid
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/cur_pos
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/next_base
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/next_size
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/next_valid
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/addr
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/count
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/burst_count
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/irq_timer
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/regs_out
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/regs_in
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/fifo_in
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/fifo_out
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/fifo_rd
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/fifo_wr
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/fifo_full
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/fifo_empty
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/fifo_clear
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/fifo_valid
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/fifo_count
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/state
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/dma_state
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/ts
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/buffer_switch_latched
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/dma_addr
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/burst_add
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/burst_sub
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/bursts_in_fifo
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/ack_count
add wave -noupdate -group DMACh0 -expand /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/dma_wb_out
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/irq_req
add wave -noupdate -group DMACh0 /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_with_dma_readout/U_DMA_Engine/gen_channels(0)/U_DMA_Channel/overflow
add wave -noupdate -group ddr3 /main/DUT/ddr_a_o
add wave -noupdate -group ddr3 /main/DUT/ddr_ba_o
add wave -noupdate -group ddr3 /main/DUT/ddr_cas_n_o
add wave -noupdate -group ddr3 /main/DUT/ddr_ck_n_o
add wave -noupdate -group ddr3 /main/DUT/ddr_ck_p_o
add wave -noupdate -group ddr3 /main/DUT/ddr_cke_o
add wave -noupdate -group ddr3 /main/DUT/ddr_dq_b
add wave -noupdate -group ddr3 /main/DUT/ddr_ldm_o
add wave -noupdate -group ddr3 /main/DUT/ddr_ldqs_n_b
add wave -noupdate -group ddr3 /main/DUT/ddr_ldqs_p_b
add wave -noupdate -group ddr3 /main/DUT/ddr_odt_o
add wave -noupdate -group ddr3 /main/DUT/ddr_ras_n_o
add wave -noupdate -group ddr3 /main/DUT/ddr_reset_n_o
add wave -noupdate -group ddr3 /main/DUT/ddr_rzq_b
add wave -noupdate -group ddr3 /main/DUT/ddr_udm_o
add wave -noupdate -group ddr3 /main/DUT/ddr_udqs_n_b
add wave -noupdate -group ddr3 /main/DUT/ddr_udqs_p_b
add wave -noupdate -group ddr3 /main/DUT/ddr_we_n_o
add wave -noupdate -group ddr3 /main/DUT/ddr_wr_fifo_empty
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/clk_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/rst_n_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/status_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_dq_b
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_a_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_ba_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_ras_n_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_cas_n_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_we_n_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_odt_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_rst_n_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_cke_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_dm_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_udm_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_dqs_p_b
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_dqs_n_b
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_udqs_p_b
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_udqs_n_b
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_clk_p_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_clk_n_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_rzq_b
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/ddr3_zio_b
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb0_rst_n_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb0_clk_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb0_sel_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb0_cyc_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb0_stb_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb0_we_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb0_addr_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb0_data_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb0_data_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb0_ack_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb0_stall_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_cmd_empty_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_cmd_full_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_full_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_empty_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_count_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_overflow_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_error_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_full_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_empty_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_count_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_underrun_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_error_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb1_rst_n_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb1_clk_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb1_sel_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb1_cyc_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb1_stb_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb1_we_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb1_addr_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb1_data_i
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb1_data_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb1_ack_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/wb1_stall_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_cmd_empty_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_cmd_full_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_full_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_empty_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_count_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_overflow_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_error_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_full_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_empty_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_count_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_underrun_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_error_o
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_cmd_clk
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_cmd_en
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_cmd_instr
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_cmd_bl
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_cmd_byte_addr
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_cmd_empty
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_cmd_full
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_clk
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_en
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_mask
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_data
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_full
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_empty
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_count
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_underrun
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_wr_error
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_clk
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_en
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_data
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_full
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_empty
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_count
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_overflow
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p0_rd_error
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_cmd_clk
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_cmd_en
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_cmd_instr
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_cmd_bl
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_cmd_byte_addr
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_cmd_empty
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_cmd_full
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_clk
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_en
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_mask
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_data
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_full
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_empty
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_count
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_underrun
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_wr_error
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_clk
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_en
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_data
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_full
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_empty
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_count
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_overflow
add wave -noupdate -group ddr3ctrl /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/p1_rd_error
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_125m_pllref_p_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_125m_pllref_n_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_20m_vcxo_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_125m_gtp_n_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_125m_gtp_p_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_aux_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_rst_n_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_p2l_clk_n_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_p2l_clk_p_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_p2l_rdy_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_p2l_dframe_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_p2l_valid_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_p2l_data_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_p_wr_req_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_p_wr_rdy_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_rx_error_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_l2p_clk_n_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_l2p_clk_p_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_l2p_dframe_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_l2p_valid_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_l2p_edb_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_l2p_data_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_l2p_rdy_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_l_wr_rdy_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_p_rd_d_rdy_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_tx_error_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_vc_rdy_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_gpio_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/fmc0_scl_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/fmc0_sda_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/fmc0_prsnt_m2c_n_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/onewire_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/spi_sclk_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/spi_ncs_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/spi_mosi_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/spi_miso_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/pcbrev_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/led_act_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/led_link_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/button1_n_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/uart_rxd_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/uart_txd_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/plldac_sclk_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/plldac_din_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/pll25dac_cs_n_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/pll20dac_cs_n_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_txp_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_txn_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_rxp_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_rxn_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_mod_def0_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_mod_def1_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_mod_def2_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_rate_select_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_tx_fault_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_tx_disable_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_los_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_a_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_ba_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_cas_n_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_ck_n_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_ck_p_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_cke_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dq_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_ldm_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_ldqs_n_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_ldqs_p_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_odt_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_ras_n_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_reset_n_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_rzq_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_udm_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_udqs_n_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_udqs_p_b
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_we_n_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dma_clk_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dma_rst_n_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dma_wb_cyc_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dma_wb_stb_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dma_wb_adr_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dma_wb_sel_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dma_wb_we_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dma_wb_dat_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dma_wb_ack_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dma_wb_stall_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_dma_wb_dat_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_wr_fifo_empty_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_62m5_sys_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/rst_62m5_sys_n_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_125m_ref_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/rst_125m_ref_n_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/irq_user_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrf_src_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrf_src_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrf_snk_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrf_snk_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_tx_data_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_tx_valid_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_tx_dreq_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_tx_last_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_tx_flush_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_tx_cfg_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_rx_first_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_rx_last_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_rx_data_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_rx_valid_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_rx_dreq_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrs_rx_cfg_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wb_eth_master_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wb_eth_master_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/tm_link_up_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/tm_time_valid_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/tm_tai_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/tm_cycles_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/tm_dac_value_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/tm_dac_wr_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/tm_clk_aux_lock_en_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/tm_clk_aux_locked_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/pps_p_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/pps_led_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/link_ok_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/app_wb_o
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/app_wb_i
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_62m5_sys
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_pll_aux
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/rst_pll_aux_n
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_333m_ddr
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/rst_333m_ddr_n
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_rst
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_status
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/ddr_calib_done
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_wb_ddr_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_wb_ddr_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_wb_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gn_wb_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/carrier_wb_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/carrier_wb_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/gennum_status
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/metadata_addr
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/metadata_data
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/buildinfo_addr
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/buildinfo_data
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/therm_id_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/therm_id_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/fmc_i2c_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/fmc_i2c_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/dma_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/dma_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/flash_spi_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/flash_spi_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/vic_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/vic_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrc_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrc_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrc_out_sh
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/csr_rst_gbl
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/csr_rst_app
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/rst_csr_app_n
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/rst_csr_app_sync_n
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/rst_gbl_n
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/fmc0_scl_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/fmc0_sda_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/fmc0_scl_oen
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/fmc0_sda_oen
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/fmc_presence
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/irq_master
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/irqs
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/rst_62m5_sys_n
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/rst_125m_ref_n
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_125m_ref
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/clk_10m_ext
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/eeprom_sda_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/eeprom_sda_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/eeprom_scl_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/eeprom_scl_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_sda_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_sda_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_scl_in
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/sfp_scl_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrc_abscal_txts_out
add wave -noupdate -group SpecBase /main/DUT/inst_spec_base/wrc_abscal_rxts_out
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/rst_n_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/clk_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_cyc_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_stb_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_adr_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_sel_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_we_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_dat_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_ack_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_err_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_rty_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_stall_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_dat_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/metadata_addr_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/metadata_data_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/metadata_data_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/metadata_wr_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/csr_app_offset_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/csr_resets_global_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/csr_resets_appl_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/csr_fmc_presence_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/csr_gn4124_status_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/csr_ddr_status_calib_done_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/csr_pcb_rev_rev_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/therm_id_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/therm_id_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/fmc_i2c_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/fmc_i2c_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/flash_spi_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/flash_spi_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/dma_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/dma_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/vic_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/vic_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/buildinfo_addr_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/buildinfo_data_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/buildinfo_data_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/buildinfo_wr_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wrc_regs_i
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wrc_regs_o
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/rd_int
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wr_int
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/rd_ack_int
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wr_ack_int
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_en
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/ack_int
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_rip
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wb_wip
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/metadata_rack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/metadata_re
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/csr_resets_global_reg
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/csr_resets_appl_reg
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/therm_id_re
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/therm_id_wt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/therm_id_rt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/therm_id_tr
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/therm_id_wack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/therm_id_rack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/fmc_i2c_re
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/fmc_i2c_wt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/fmc_i2c_rt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/fmc_i2c_tr
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/fmc_i2c_wack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/fmc_i2c_rack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/flash_spi_re
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/flash_spi_wt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/flash_spi_rt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/flash_spi_tr
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/flash_spi_wack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/flash_spi_rack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/dma_re
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/dma_wt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/dma_rt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/dma_tr
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/dma_wack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/dma_rack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/vic_re
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/vic_wt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/vic_rt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/vic_tr
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/vic_wack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/vic_rack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/buildinfo_rack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/buildinfo_re
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wrc_regs_re
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wrc_regs_wt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wrc_regs_rt
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wrc_regs_tr
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wrc_regs_wack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/wrc_regs_rack
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/reg_rdat_int
add wave -noupdate -group SpecCsr /main/DUT/inst_spec_base/inst_devs/rd_ack1_int
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_dq
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_a
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_ba
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_ras_n
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_cas_n
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_we_n
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_odt
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_reset_n
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_cke
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_dm
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_udqs
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_udqs_n
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_rzq
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_udm
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_sys_clk
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_sys_rst_i
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_calib_done
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_clk0
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_rst0
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_dqs
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_dqs_n
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_ck
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/mcb3_dram_ck_n
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_cmd_clk
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_cmd_en
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_cmd_instr
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_cmd_bl
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_cmd_byte_addr
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_cmd_empty
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_cmd_full
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_wr_clk
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_wr_en
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_wr_mask
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_wr_data
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_wr_full
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_wr_empty
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_wr_count
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_wr_underrun
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_wr_error
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_rd_clk
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_rd_en
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_rd_data
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_rd_full
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_rd_empty
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_rd_count
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_rd_overflow
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p0_rd_error
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_cmd_clk
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_cmd_en
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_cmd_instr
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_cmd_bl
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_cmd_byte_addr
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_cmd_empty
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_cmd_full
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_wr_clk
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_wr_en
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_wr_mask
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_wr_data
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_wr_full
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_wr_empty
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_wr_count
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_wr_underrun
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_wr_error
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_rd_clk
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_rd_en
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_rd_data
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_rd_full
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_rd_empty
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_rd_count
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_rd_overflow
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_p1_rd_error
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_sys_clk_p
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_sys_clk_n
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_async_rst
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_sysclk_2x
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_sysclk_2x_180
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_pll_ce_0
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_pll_ce_90
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_pll_lock
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_mcb_drp_clk
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_cmp_error
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_cmp_data_valid
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_vio_modify_enable
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_error_status
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_vio_data_mode_value
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_vio_addr_mode_value
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_cmp_data
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_selfrefresh_enter
add wave -noupdate -group DdrTop /main/DUT/inst_spec_base/gen_with_ddr/cmp_ddr_ctrl_bank3/cmp_ddr3_ctrl_wrapper/gen_spec_bank3_32b_32b/cmp_ddr3_ctrl/c3_selfrefresh_mode
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/rst_n_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/clk_sys_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_adr_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_dat_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_dat_o
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_cyc_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_sel_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_stb_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_we_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_ack_o
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_err_o
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_rty_o
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_stall_o
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wb_int_o
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/irq_tdc_fifo1_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/irq_tdc_fifo2_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/irq_tdc_fifo3_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/irq_tdc_fifo4_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/irq_tdc_fifo5_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/irq_tdc_dma1_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/irq_tdc_dma2_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/irq_tdc_dma3_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/irq_tdc_dma4_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/irq_tdc_dma5_i
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/eic_idr_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/eic_idr_write_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/eic_ier_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/eic_ier_write_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/eic_imr_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/eic_isr_clear_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/eic_isr_status_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/eic_irq_ack_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/eic_isr_write_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/irq_inputs_vector_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/ack_sreg
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/rddata_reg
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wrdata_reg
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/bwsel_reg
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/rwaddr_reg
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/ack_in_progress
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/wr_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/rd_int
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/allones
add wave -noupdate -group EIC /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/gen_enable_eic/cmp_tdc_eic/allzeros
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/clk_sys_i
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/rst_n_i
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/slave_i
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/slave_o
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/msi_master_i
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/msi_master_o
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/master_i
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/master_o
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/msi_slave_i
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/msi_slave_o
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/master_i_1
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/master_o_1
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/sdb_sel
add wave -noupdate -group xbar-mezz /main/DUT/cmp_fmc_tdc_mezzanine/cmp_tdc_mezz/cmp_sdb_crossbar/c_layout
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/clk_sys_i
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/rst_n_i
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/wb_adr_i
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/wb_dat_i
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/wb_dat_o
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/wb_cyc_i
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/wb_sel_i
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/wb_stb_i
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/wb_we_i
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/wb_ack_o
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/wb_stall_o
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/irqs_i
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/irq_master_o
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/irqs_i_reg
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ctl_pol
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ctl_pol_in
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ctl_wr
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ctl_enable
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ctl_emu_edge
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ctl_emu_len
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_risr
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ier
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ier_wr
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_idr
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_idr_wr
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_imr
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_var
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_eoir
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_eoir_wr
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ivt_ram_addr_wb
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ivt_ram_data_towb
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ivt_ram_data_fromwb
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ivt_ram_data_int
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_ivt_ram_wr
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_swir
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vic_swir_wr
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/swi_mask
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/current_irq
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/state
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/wb_in
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/wb_out
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/timeout_count
add wave -noupdate -group Vic /main/DUT/inst_spec_base/gen_vic/inst_vic/U_Wrapped_VIC/vector_table
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/clk_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/rst_n_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_irq_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_carrier_addr_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_host_addr_h_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_host_addr_l_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_len_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_start_l2p_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_start_p2l_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_start_next_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_byte_swap_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_abort_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_done_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_error_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/next_item_carrier_addr_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/next_item_host_addr_h_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/next_item_host_addr_l_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/next_item_len_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/next_item_next_l_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/next_item_next_h_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/next_item_attrib_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/next_item_valid_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/wb_rst_n_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/wb_clk_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/wb_adr_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/wb_dat_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/wb_dat_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/wb_sel_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/wb_cyc_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/wb_stb_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/wb_we_i
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/wb_ack_o
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_start_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_abort_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_wr_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_wack_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_byte_swap_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_byte_swap
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_start
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_abort
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_wr
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_async_cstart
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_async_hstartl
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_async_hstarth
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_async_len
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_async_nextl
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_async_nexth
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_async_attrib_chain
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_async_attrib_dir
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_stat_irq_i_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_stat_irq_o_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_stat_status_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_stat_wr_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_stat_wack_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_stat_rd_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_stat_rack_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_stat_irq_wr_wb
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_stat_irq_wr
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_stat_wr
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_cstart_reg
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_hstartl_reg
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_hstarth_reg
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_len_reg
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_nextl_reg
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_nexth_reg
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_attrib_chain_reg
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_attrib_dir_reg
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_byte_swap_reg
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_ctrl_current_state
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_stat_reg
add wave -noupdate -group GennumDMA /main/DUT/inst_spec_base/gen_with_gennum/cmp_gn4124_core/cmp_wrapped_gn4124/gen_with_dma/cmp_dma_controller/dma_irq_reg
add wave -noupdate -group Top /main/DUT/button1_n_i
add wave -noupdate -group Top /main/DUT/clk_20m_vcxo_i
add wave -noupdate -group Top /main/DUT/clk_125m_pllref_p_i
add wave -noupdate -group Top /main/DUT/clk_125m_pllref_n_i
add wave -noupdate -group Top /main/DUT/clk_125m_gtp_n_i
add wave -noupdate -group Top /main/DUT/clk_125m_gtp_p_i
add wave -noupdate -group Top /main/DUT/pll25dac_cs_n_o
add wave -noupdate -group Top /main/DUT/pll20dac_cs_n_o
add wave -noupdate -group Top /main/DUT/plldac_din_o
add wave -noupdate -group Top /main/DUT/plldac_sclk_o
add wave -noupdate -group Top /main/DUT/sfp_txp_o
add wave -noupdate -group Top /main/DUT/sfp_txn_o
add wave -noupdate -group Top /main/DUT/sfp_rxp_i
add wave -noupdate -group Top /main/DUT/sfp_rxn_i
add wave -noupdate -group Top /main/DUT/sfp_mod_def0_i
add wave -noupdate -group Top /main/DUT/sfp_mod_def1_b
add wave -noupdate -group Top /main/DUT/sfp_mod_def2_b
add wave -noupdate -group Top /main/DUT/sfp_rate_select_o
add wave -noupdate -group Top /main/DUT/sfp_tx_fault_i
add wave -noupdate -group Top /main/DUT/sfp_tx_disable_o
add wave -noupdate -group Top /main/DUT/sfp_los_i
add wave -noupdate -group Top /main/DUT/onewire_b
add wave -noupdate -group Top /main/DUT/led_act_o
add wave -noupdate -group Top /main/DUT/led_link_o
add wave -noupdate -group Top /main/DUT/pcbrev_i
add wave -noupdate -group Top /main/DUT/uart_rxd_i
add wave -noupdate -group Top /main/DUT/uart_txd_o
add wave -noupdate -group Top /main/DUT/spi_sclk_o
add wave -noupdate -group Top /main/DUT/spi_ncs_o
add wave -noupdate -group Top /main/DUT/spi_mosi_o
add wave -noupdate -group Top /main/DUT/spi_miso_i
add wave -noupdate -group Top /main/DUT/ddr_a_o
add wave -noupdate -group Top /main/DUT/ddr_ba_o
add wave -noupdate -group Top /main/DUT/ddr_cas_n_o
add wave -noupdate -group Top /main/DUT/ddr_ck_n_o
add wave -noupdate -group Top /main/DUT/ddr_ck_p_o
add wave -noupdate -group Top /main/DUT/ddr_cke_o
add wave -noupdate -group Top /main/DUT/ddr_dq_b
add wave -noupdate -group Top /main/DUT/ddr_ldm_o
add wave -noupdate -group Top /main/DUT/ddr_ldqs_n_b
add wave -noupdate -group Top /main/DUT/ddr_ldqs_p_b
add wave -noupdate -group Top /main/DUT/ddr_odt_o
add wave -noupdate -group Top /main/DUT/ddr_ras_n_o
add wave -noupdate -group Top /main/DUT/ddr_reset_n_o
add wave -noupdate -group Top /main/DUT/ddr_rzq_b
add wave -noupdate -group Top /main/DUT/ddr_udm_o
add wave -noupdate -group Top /main/DUT/ddr_udqs_n_b
add wave -noupdate -group Top /main/DUT/ddr_udqs_p_b
add wave -noupdate -group Top /main/DUT/ddr_we_n_o
add wave -noupdate -group Top /main/DUT/gn_rst_n_i
add wave -noupdate -group Top /main/DUT/gn_gpio_b
add wave -noupdate -group Top /main/DUT/gn_p2l_rdy_o
add wave -noupdate -group Top /main/DUT/gn_p2l_clk_n_i
add wave -noupdate -group Top /main/DUT/gn_p2l_clk_p_i
add wave -noupdate -group Top /main/DUT/gn_p2l_data_i
add wave -noupdate -group Top /main/DUT/gn_p2l_dframe_i
add wave -noupdate -group Top /main/DUT/gn_p2l_valid_i
add wave -noupdate -group Top /main/DUT/gn_p_wr_req_i
add wave -noupdate -group Top /main/DUT/gn_p_wr_rdy_o
add wave -noupdate -group Top /main/DUT/gn_rx_error_o
add wave -noupdate -group Top /main/DUT/gn_l2p_data_o
add wave -noupdate -group Top /main/DUT/gn_l2p_dframe_o
add wave -noupdate -group Top /main/DUT/gn_l2p_valid_o
add wave -noupdate -group Top /main/DUT/gn_l2p_clk_n_o
add wave -noupdate -group Top /main/DUT/gn_l2p_clk_p_o
add wave -noupdate -group Top /main/DUT/gn_l2p_edb_o
add wave -noupdate -group Top /main/DUT/gn_l2p_rdy_i
add wave -noupdate -group Top /main/DUT/gn_l_wr_rdy_i
add wave -noupdate -group Top /main/DUT/gn_p_rd_d_rdy_i
add wave -noupdate -group Top /main/DUT/gn_tx_error_i
add wave -noupdate -group Top /main/DUT/gn_vc_rdy_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_pll_sclk_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_pll_sdi_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_pll_cs_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_pll_dac_sync_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_pll_sdo_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_pll_status_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_clk_125m_p_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_clk_125m_n_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_acam_refclk_p_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_acam_refclk_n_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_start_from_fpga_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_err_flag_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_int_flag_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_start_dis_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_stop_dis_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_data_bus_io
add wave -noupdate -group Top /main/DUT/fmc0_tdc_address_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_cs_n_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_oe_n_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_rd_n_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_wr_n_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_ef1_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_ef2_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_enable_inputs_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_term_en_1_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_term_en_2_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_term_en_3_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_term_en_4_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_term_en_5_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_led_status_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_led_trig1_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_led_trig2_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_led_trig3_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_led_trig4_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_led_trig5_o
add wave -noupdate -group Top /main/DUT/fmc0_tdc_in_fpga_1_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_in_fpga_2_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_in_fpga_3_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_in_fpga_4_i
add wave -noupdate -group Top /main/DUT/fmc0_tdc_in_fpga_5_i
add wave -noupdate -group Top /main/DUT/fmc0_scl_b
add wave -noupdate -group Top /main/DUT/fmc0_sda_b
add wave -noupdate -group Top /main/DUT/fmc0_tdc_onewire_b
add wave -noupdate -group Top /main/DUT/fmc0_prsnt_m2c_n_i
add wave -noupdate -group Top /main/DUT/aux_leds_o
add wave -noupdate -group Top /main/DUT/sim_wb_i
add wave -noupdate -group Top /main/DUT/sim_wb_o
add wave -noupdate -group Top /main/DUT/sim_timestamp_i
add wave -noupdate -group Top /main/DUT/sim_timestamp_valid_i
add wave -noupdate -group Top /main/DUT/sim_timestamp_ready_o
add wave -noupdate -group Top /main/DUT/clk_sys_62m5
add wave -noupdate -group Top /main/DUT/rst_sys_62m5_n
add wave -noupdate -group Top /main/DUT/clk_ref_125m
add wave -noupdate -group Top /main/DUT/rst_ref_125m_n
add wave -noupdate -group Top /main/DUT/tdc0_clk_125m
add wave -noupdate -group Top /main/DUT/cnx_master_out
add wave -noupdate -group Top /main/DUT/cnx_master_in
add wave -noupdate -group Top /main/DUT/cnx_slave_out
add wave -noupdate -group Top /main/DUT/cnx_slave_in
add wave -noupdate -group Top /main/DUT/gn_wb_adr
add wave -noupdate -group Top /main/DUT/tm_link_up
add wave -noupdate -group Top /main/DUT/tm_time_valid
add wave -noupdate -group Top /main/DUT/tm_dac_wr_p
add wave -noupdate -group Top /main/DUT/tm_tai
add wave -noupdate -group Top /main/DUT/tm_cycles
add wave -noupdate -group Top /main/DUT/tm_dac_value
add wave -noupdate -group Top /main/DUT/tm_clk_aux_lock_en
add wave -noupdate -group Top /main/DUT/tm_clk_aux_locked
add wave -noupdate -group Top /main/DUT/wrabbit_en
add wave -noupdate -group Top /main/DUT/pps_led
add wave -noupdate -group Top /main/DUT/ddr_wr_fifo_empty
add wave -noupdate -group Top /main/DUT/fmc0_irq
add wave -noupdate -group Top /main/DUT/irq_vector
add wave -noupdate -group Top /main/DUT/gn4124_access
add wave -noupdate -group Top /main/DUT/tdc_scl_oen
add wave -noupdate -group Top /main/DUT/tdc_scl_in
add wave -noupdate -group Top /main/DUT/tdc_sda_oen
add wave -noupdate -group Top /main/DUT/tdc_sda_in
add wave -noupdate -group Top /main/DUT/tdc0_soft_rst_n
add wave -noupdate -group Top /main/DUT/ddr3_tdc_adr
add wave -noupdate -group Top /main/DUT/powerup_rst_cnt
add wave -noupdate -group Top /main/DUT/carrier_info_fmc_rst
add wave -noupdate -group Top /main/DUT/tdc_dma_out
add wave -noupdate -group Top /main/DUT/tdc_dma_in
add wave -noupdate -group Top /main/DUT/fmc0_wb_ddr_in
add wave -noupdate -group Top /main/DUT/fmc0_wb_ddr_out
add wave -noupdate -group Top /main/DUT/sim_ts_valid
add wave -noupdate -group Top /main/DUT/sim_ts_ready
add wave -noupdate -group Top /main/DUT/sim_ts
add wave -noupdate -group Top /main/DUT/ddr3_status
add wave -noupdate -group Top /main/DUT/dma_reg_adr
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CMD_INT
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CMD_REQ
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CMD_ACK
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CMD_CLOCK_EN
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CMD_RD_DATA
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CMD_RD_DATA_VALID
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RSTINn
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RSTOUT18n
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RSTOUT33n
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/LCLK
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/LCLKn
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_CLKp
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_CLKn
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_DATA
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_DFRAME
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_VALID
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_EDB
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L_WR_RDY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P_RD_D_RDY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_RDY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/TX_ERROR
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_CLKp
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_CLKn
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_DATA
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_DFRAME
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_VALID
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_RDY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P_WR_REQ
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P_WR_RDY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RX_ERROR
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/VC_RDY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/GPIO
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CMD
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/T_LCLKi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/T_P2L_CLK_DLYi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/PRIMARY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/SECONDARY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/GENERATE_X
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/EXPECT_ERROR
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/OUTBOUND_RD_OUTSTANDING
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RESPONSE_DELAY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/GPIOi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/GPIOo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/LCLKo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/LCLKno
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_CLKpi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_CLKni
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_CLKi_90
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_DATAi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_DFRAMEi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_VALIDi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_EDBi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L_WR_RDYo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P_RD_D_RDYo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_RDYo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/TX_ERRORo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_CLKpo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_CLKno
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_DATAo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_DFRAMEo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_VALIDo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_RDYi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P_WR_REQo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P_WR_RDYi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RX_ERRORi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/VC_RDYo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/LCLKi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/LCLKni
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_CLKpo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_CLKno
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_DATAo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_DFRAMEo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_VALIDo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_EDBo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L_WR_RDYi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P_RD_D_RDYi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/L2P_RDYi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/TX_ERRORi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_CLKpi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_CLKni
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_DATAi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_DFRAMEi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_VALIDi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P2L_RDYo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P_WR_REQi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/P_WR_RDYo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RX_ERRORo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/VC_RDYi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/ICLK
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/LCLK_PERIOD
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CLK0o
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CLK90o
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CLK
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RSTOUTo
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/T_HOLD_OUTi
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/INBOUND_READ_REQUEST_ARRAY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/INBOUND_READ_REQUEST_CPL_STATE
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CURRENT_INBOUND_RD_IPR
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RD_BUFFER
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/OUTBOUND_READ_REQUEST_CPL_STATE
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CURRENT_OUTBOUND_RD_IPR
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RANDOM_NUMBER
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/BAR_ATTRIBUTE_ARRAY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/BFM_BAR_ATTRIBUTE_ARRAY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_REQ0
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_REQ1
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_WR0
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_WR1
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_ACK0
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_ACK1
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_ADDR0
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_ADDR1
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_WR_DATA0
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_WR_DATA1
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_RD_DATA0
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/RAM_RD_DATA1
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/IN_DATA
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/IN_DATA_LOW
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/IN_DFRAME
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/IN_VALID
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/Q_IN_DFRAME
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CMD_RD_DATA_IN
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CMD_RD_DATA_IN_VALID
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/Q_OUT_DATA
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/OUT_DATA
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/Q_OUT_DFRAME
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/OUT_DFRAME
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/Q_OUT_VALID
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/OUT_VALID
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/OUT_WR_REQ
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/OUT_WR_RDY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/Q_OUT_WR_RDY
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CMD_RD_DATA_OUT
add wave -noupdate -expand -group GennumBFM /main/Host/U_BFM/CMD_RD_DATA_OUT_VALID
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {199168064 ps} 0}
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
WaveRestoreZoom {0 ps} {416165888 ps}



