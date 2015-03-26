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
add wave -noupdate -group Top /main/DUT/por_n_i
add wave -noupdate -group Top /main/DUT/clk_20m_vcxo_i
add wave -noupdate -group Top /main/DUT/clk_125m_pllref_p_i
add wave -noupdate -group Top /main/DUT/clk_125m_pllref_n_i
add wave -noupdate -group Top /main/DUT/clk_125m_gtp_p_i
add wave -noupdate -group Top /main/DUT/clk_125m_gtp_n_i
add wave -noupdate -group Top /main/DUT/sfp_txp_o
add wave -noupdate -group Top /main/DUT/sfp_txn_o
add wave -noupdate -group Top /main/DUT/sfp_rxp_i
add wave -noupdate -group Top /main/DUT/sfp_rxn_i
add wave -noupdate -group Top /main/DUT/sfp_mod_def0_b
add wave -noupdate -group Top /main/DUT/sfp_mod_def1_b
add wave -noupdate -group Top /main/DUT/sfp_mod_def2_b
add wave -noupdate -group Top /main/DUT/sfp_rate_select_b
add wave -noupdate -group Top /main/DUT/sfp_tx_fault_i
add wave -noupdate -group Top /main/DUT/sfp_tx_disable_o
add wave -noupdate -group Top /main/DUT/sfp_los_i
add wave -noupdate -group Top /main/DUT/pll20dac_din_o
add wave -noupdate -group Top /main/DUT/pll20dac_sclk_o
add wave -noupdate -group Top /main/DUT/pll20dac_sync_n_o
add wave -noupdate -group Top /main/DUT/pll25dac_din_o
add wave -noupdate -group Top /main/DUT/pll25dac_sclk_o
add wave -noupdate -group Top /main/DUT/pll25dac_sync_n_o
add wave -noupdate -group Top /main/DUT/uart_rxd_i
add wave -noupdate -group Top /main/DUT/uart_txd_o
add wave -noupdate -group Top /main/DUT/carrier_onewire_b
add wave -noupdate -group Top /main/DUT/pcb_ver_i
add wave -noupdate -group Top /main/DUT/tdc1_prsntm2c_n_i
add wave -noupdate -group Top /main/DUT/tdc2_prsntm2c_n_i
add wave -noupdate -group Top /main/DUT/fp_led_line_oen_o
add wave -noupdate -group Top /main/DUT/fp_led_line_o
add wave -noupdate -group Top /main/DUT/fp_led_column_o
add wave -noupdate -group Top /main/DUT/VME_AS_n_i
add wave -noupdate -group Top /main/DUT/VME_RST_n_i
add wave -noupdate -group Top /main/DUT/VME_WRITE_n_i
add wave -noupdate -group Top /main/DUT/VME_AM_i
add wave -noupdate -group Top /main/DUT/VME_DS_n_i
add wave -noupdate -group Top /main/DUT/VME_GA_i
add wave -noupdate -group Top /main/DUT/VME_BERR_o
add wave -noupdate -group Top /main/DUT/VME_DTACK_n_o
add wave -noupdate -group Top /main/DUT/VME_RETRY_n_o
add wave -noupdate -group Top /main/DUT/VME_RETRY_OE_o
add wave -noupdate -group Top /main/DUT/VME_LWORD_n_b
add wave -noupdate -group Top /main/DUT/VME_ADDR_b
add wave -noupdate -group Top /main/DUT/VME_DATA_b
add wave -noupdate -group Top /main/DUT/VME_BBSY_n_i
add wave -noupdate -group Top /main/DUT/VME_IRQ_n_o
add wave -noupdate -group Top /main/DUT/VME_IACK_n_i
add wave -noupdate -group Top /main/DUT/VME_IACKIN_n_i
add wave -noupdate -group Top /main/DUT/VME_IACKOUT_n_o
add wave -noupdate -group Top /main/DUT/VME_DTACK_OE_o
add wave -noupdate -group Top /main/DUT/VME_DATA_DIR_o
add wave -noupdate -group Top /main/DUT/VME_DATA_OE_N_o
add wave -noupdate -group Top /main/DUT/VME_ADDR_DIR_o
add wave -noupdate -group Top /main/DUT/VME_ADDR_OE_N_o
add wave -noupdate -group Top /main/DUT/tdc1_pll_sclk_o
add wave -noupdate -group Top /main/DUT/tdc1_pll_sdi_o
add wave -noupdate -group Top /main/DUT/tdc1_pll_cs_n_o
add wave -noupdate -group Top /main/DUT/tdc1_pll_dac_sync_n_o
add wave -noupdate -group Top /main/DUT/tdc1_pll_sdo_i
add wave -noupdate -group Top /main/DUT/tdc1_pll_status_i
add wave -noupdate -group Top /main/DUT/tdc1_125m_clk_p_i
add wave -noupdate -group Top /main/DUT/tdc1_125m_clk_n_i
add wave -noupdate -group Top /main/DUT/tdc1_acam_refclk_p_i
add wave -noupdate -group Top /main/DUT/tdc1_acam_refclk_n_i
add wave -noupdate -group Top /main/DUT/tdc1_start_from_fpga_o
add wave -noupdate -group Top /main/DUT/tdc1_err_flag_i
add wave -noupdate -group Top /main/DUT/tdc1_int_flag_i
add wave -noupdate -group Top /main/DUT/tdc1_start_dis_o
add wave -noupdate -group Top /main/DUT/tdc1_stop_dis_o
add wave -noupdate -group Top /main/DUT/tdc1_data_bus_io
add wave -noupdate -group Top /main/DUT/tdc1_address_o
add wave -noupdate -group Top /main/DUT/tdc1_cs_n_o
add wave -noupdate -group Top /main/DUT/tdc1_oe_n_o
add wave -noupdate -group Top /main/DUT/tdc1_rd_n_o
add wave -noupdate -group Top /main/DUT/tdc1_wr_n_o
add wave -noupdate -group Top /main/DUT/tdc1_ef1_i
add wave -noupdate -group Top /main/DUT/tdc1_ef2_i
add wave -noupdate -group Top /main/DUT/tdc1_enable_inputs_o
add wave -noupdate -group Top /main/DUT/tdc1_term_en_1_o
add wave -noupdate -group Top /main/DUT/tdc1_term_en_2_o
add wave -noupdate -group Top /main/DUT/tdc1_term_en_3_o
add wave -noupdate -group Top /main/DUT/tdc1_term_en_4_o
add wave -noupdate -group Top /main/DUT/tdc1_term_en_5_o
add wave -noupdate -group Top /main/DUT/tdc1_onewire_b
add wave -noupdate -group Top /main/DUT/tdc1_scl_b
add wave -noupdate -group Top /main/DUT/tdc1_sda_b
add wave -noupdate -group Top /main/DUT/tdc1_led_status_o
add wave -noupdate -group Top /main/DUT/tdc1_led_trig1_o
add wave -noupdate -group Top /main/DUT/tdc1_led_trig2_o
add wave -noupdate -group Top /main/DUT/tdc1_led_trig3_o
add wave -noupdate -group Top /main/DUT/tdc1_led_trig4_o
add wave -noupdate -group Top /main/DUT/tdc1_led_trig5_o
add wave -noupdate -group Top /main/DUT/tdc1_in_fpga_1_i
add wave -noupdate -group Top /main/DUT/tdc1_in_fpga_2_i
add wave -noupdate -group Top /main/DUT/tdc1_in_fpga_3_i
add wave -noupdate -group Top /main/DUT/tdc1_in_fpga_4_i
add wave -noupdate -group Top /main/DUT/tdc1_in_fpga_5_i
add wave -noupdate -group Top /main/DUT/tdc2_pll_sclk_o
add wave -noupdate -group Top /main/DUT/tdc2_pll_sdi_o
add wave -noupdate -group Top /main/DUT/tdc2_pll_cs_n_o
add wave -noupdate -group Top /main/DUT/tdc2_pll_dac_sync_n_o
add wave -noupdate -group Top /main/DUT/tdc2_pll_sdo_i
add wave -noupdate -group Top /main/DUT/tdc2_pll_status_i
add wave -noupdate -group Top /main/DUT/tdc2_125m_clk_p_i
add wave -noupdate -group Top /main/DUT/tdc2_125m_clk_n_i
add wave -noupdate -group Top /main/DUT/tdc2_acam_refclk_p_i
add wave -noupdate -group Top /main/DUT/tdc2_acam_refclk_n_i
add wave -noupdate -group Top /main/DUT/tdc2_start_from_fpga_o
add wave -noupdate -group Top /main/DUT/tdc2_err_flag_i
add wave -noupdate -group Top /main/DUT/tdc2_int_flag_i
add wave -noupdate -group Top /main/DUT/tdc2_start_dis_o
add wave -noupdate -group Top /main/DUT/tdc2_stop_dis_o
add wave -noupdate -group Top /main/DUT/tdc2_data_bus_io
add wave -noupdate -group Top /main/DUT/tdc2_address_o
add wave -noupdate -group Top /main/DUT/tdc2_cs_n_o
add wave -noupdate -group Top /main/DUT/tdc2_oe_n_o
add wave -noupdate -group Top /main/DUT/tdc2_rd_n_o
add wave -noupdate -group Top /main/DUT/tdc2_wr_n_o
add wave -noupdate -group Top /main/DUT/tdc2_ef1_i
add wave -noupdate -group Top /main/DUT/tdc2_ef2_i
add wave -noupdate -group Top /main/DUT/tdc2_enable_inputs_o
add wave -noupdate -group Top /main/DUT/tdc2_term_en_1_o
add wave -noupdate -group Top /main/DUT/tdc2_term_en_2_o
add wave -noupdate -group Top /main/DUT/tdc2_term_en_3_o
add wave -noupdate -group Top /main/DUT/tdc2_term_en_4_o
add wave -noupdate -group Top /main/DUT/tdc2_term_en_5_o
add wave -noupdate -group Top /main/DUT/tdc2_onewire_b
add wave -noupdate -group Top /main/DUT/tdc2_scl_b
add wave -noupdate -group Top /main/DUT/tdc2_sda_b
add wave -noupdate -group Top /main/DUT/tdc2_led_status_o
add wave -noupdate -group Top /main/DUT/tdc2_led_trig1_o
add wave -noupdate -group Top /main/DUT/tdc2_led_trig2_o
add wave -noupdate -group Top /main/DUT/tdc2_led_trig3_o
add wave -noupdate -group Top /main/DUT/tdc2_led_trig4_o
add wave -noupdate -group Top /main/DUT/tdc2_led_trig5_o
add wave -noupdate -group Top /main/DUT/tdc2_in_fpga_1_i
add wave -noupdate -group Top /main/DUT/tdc2_in_fpga_2_i
add wave -noupdate -group Top /main/DUT/tdc2_in_fpga_3_i
add wave -noupdate -group Top /main/DUT/tdc2_in_fpga_4_i
add wave -noupdate -group Top /main/DUT/tdc2_in_fpga_5_i
add wave -noupdate -group Top /main/DUT/clk_20m_vcxo_buf
add wave -noupdate -group Top /main/DUT/clk_20m_vcxo
add wave -noupdate -group Top /main/DUT/clk_62m5_sys
add wave -noupdate -group Top /main/DUT/pllout_clk_sys
add wave -noupdate -group Top /main/DUT/pllout_clk_sys_fb
add wave -noupdate -group Top /main/DUT/sys_locked
add wave -noupdate -group Top /main/DUT/tdc1_125m_clk
add wave -noupdate -group Top /main/DUT/tdc1_send_dac_word_p
add wave -noupdate -group Top /main/DUT/tdc1_dac_word
add wave -noupdate -group Top /main/DUT/tdc2_125m_clk
add wave -noupdate -group Top /main/DUT/tdc2_send_dac_word_p
add wave -noupdate -group Top /main/DUT/tdc2_dac_word
add wave -noupdate -group Top /main/DUT/pllout_clk_dmtd
add wave -noupdate -group Top /main/DUT/pllout_clk_fb_dmtd
add wave -noupdate -group Top /main/DUT/pllout_clk_fb_pllref
add wave -noupdate -group Top /main/DUT/clk_125m_pllref
add wave -noupdate -group Top /main/DUT/clk_125m_gtp
add wave -noupdate -group Top /main/DUT/clk_dmtd
add wave -noupdate -group Top /main/DUT/por_rst_n_a
add wave -noupdate -group Top /main/DUT/powerup_rst_cnt
add wave -noupdate -group Top /main/DUT/rst_n_sys
add wave -noupdate -group Top /main/DUT/tdc1_soft_rst_n
add wave -noupdate -group Top /main/DUT/tdc2_soft_rst_n
add wave -noupdate -group Top /main/DUT/carrier_info_fmc_rst
add wave -noupdate -group Top /main/DUT/carrier_info_stat_reserv
add wave -noupdate -group Top /main/DUT/VME_DATA_b_out
add wave -noupdate -group Top /main/DUT/VME_ADDR_b_out
add wave -noupdate -group Top /main/DUT/VME_LWORD_n_b_out
add wave -noupdate -group Top /main/DUT/VME_DATA_DIR_int
add wave -noupdate -group Top /main/DUT/VME_ADDR_DIR_int
add wave -noupdate -group Top /main/DUT/tm_link_up
add wave -noupdate -group Top /main/DUT/tm_time_valid
add wave -noupdate -group Top /main/DUT/tm_utc
add wave -noupdate -group Top /main/DUT/tm_cycles
add wave -noupdate -group Top /main/DUT/tm_clk_aux_lock_en
add wave -noupdate -group Top /main/DUT/tm_clk_aux_locked
add wave -noupdate -group Top /main/DUT/tm_dac_value
add wave -noupdate -group Top /main/DUT/tm_dac_wr_p
add wave -noupdate -group Top /main/DUT/phy_tx_data
add wave -noupdate -group Top /main/DUT/phy_rx_data
add wave -noupdate -group Top /main/DUT/phy_tx_k
add wave -noupdate -group Top /main/DUT/phy_tx_disparity
add wave -noupdate -group Top /main/DUT/phy_rx_k
add wave -noupdate -group Top /main/DUT/phy_tx_enc_err
add wave -noupdate -group Top /main/DUT/phy_rx_rbclk
add wave -noupdate -group Top /main/DUT/phy_rx_enc_err
add wave -noupdate -group Top /main/DUT/phy_rst
add wave -noupdate -group Top /main/DUT/phy_loopen
add wave -noupdate -group Top /main/DUT/phy_rx_bitslide
add wave -noupdate -group Top /main/DUT/dac_hpll_load_p1
add wave -noupdate -group Top /main/DUT/dac_dpll_load_p1
add wave -noupdate -group Top /main/DUT/dac_hpll_data
add wave -noupdate -group Top /main/DUT/dac_dpll_data
add wave -noupdate -group Top /main/DUT/wrc_scl_out
add wave -noupdate -group Top /main/DUT/wrc_scl_in
add wave -noupdate -group Top /main/DUT/wrc_sda_out
add wave -noupdate -group Top /main/DUT/wrc_sda_in
add wave -noupdate -group Top /main/DUT/sfp_scl_out
add wave -noupdate -group Top /main/DUT/sfp_scl_in
add wave -noupdate -group Top /main/DUT/sfp_sda_out
add wave -noupdate -group Top /main/DUT/sfp_sda_in
add wave -noupdate -group Top /main/DUT/wrc_owr_en
add wave -noupdate -group Top /main/DUT/wrc_owr_in
add wave -noupdate -group Top /main/DUT/cnx_master_out
add wave -noupdate -group Top /main/DUT/cnx_master_in
add wave -noupdate -group Top /main/DUT/cnx_slave_out
add wave -noupdate -group Top /main/DUT/cnx_slave_in
add wave -noupdate -group Top /main/DUT/irq_to_vmecore
add wave -noupdate -group Top /main/DUT/tdc1_irq
add wave -noupdate -group Top /main/DUT/tdc2_irq
add wave -noupdate -group Top /main/DUT/tdc1_scl_oen
add wave -noupdate -group Top /main/DUT/tdc1_scl_in
add wave -noupdate -group Top /main/DUT/tdc1_sda_oen
add wave -noupdate -group Top /main/DUT/tdc1_sda_in
add wave -noupdate -group Top /main/DUT/tdc2_scl_oen
add wave -noupdate -group Top /main/DUT/tdc2_scl_in
add wave -noupdate -group Top /main/DUT/tdc2_sda_oen
add wave -noupdate -group Top /main/DUT/tdc2_sda_in
add wave -noupdate -group Top /main/DUT/carrier_owr_en
add wave -noupdate -group Top /main/DUT/carrier_owr_i
add wave -noupdate -group Top /main/DUT/led_state
add wave -noupdate -group Top /main/DUT/tdc1_ef
add wave -noupdate -group Top /main/DUT/tdc2_ef
add wave -noupdate -group Top /main/DUT/led_tdc1_ef
add wave -noupdate -group Top /main/DUT/led_tdc2_ef
add wave -noupdate -group Top /main/DUT/led_vme_access
add wave -noupdate -group Top /main/DUT/led_clk_62m5_divider
add wave -noupdate -group Top /main/DUT/led_clk_62m5_aux
add wave -noupdate -group Top /main/DUT/led_clk_62m5
add wave -noupdate -group Top /main/DUT/wrabbit_led_red
add wave -noupdate -group Top /main/DUT/wrabbit_led_green
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/clk_sys_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/rst_sys_n_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/rst_n_a_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/pll_sclk_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/pll_sdi_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/pll_cs_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/pll_dac_sync_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/pll_sdo_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/pll_status_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_clk_125m_p_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_clk_125m_n_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/acam_refclk_p_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/acam_refclk_n_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/start_from_fpga_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/err_flag_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/int_flag_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/start_dis_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/stop_dis_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/data_bus_io
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/address_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/cs_n_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/oe_n_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/rd_n_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/wr_n_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/ef1_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/ef2_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/enable_inputs_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/term_en_1_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/term_en_2_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/term_en_3_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/term_en_4_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/term_en_5_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_led_status_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_led_trig1_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_led_trig2_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_led_trig3_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_led_trig4_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_led_trig5_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_in_fpga_1_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_in_fpga_2_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_in_fpga_3_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_in_fpga_4_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_in_fpga_5_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/mezz_scl_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/mezz_sda_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/mezz_scl_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/mezz_sda_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/mezz_one_wire_b
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tm_link_up_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tm_time_valid_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tm_cycles_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tm_tai_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tm_clk_aux_lock_en_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tm_clk_aux_locked_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tm_clk_dmtd_locked_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tm_dac_value_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tm_dac_wr_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/slave_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/slave_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/direct_slave_i
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/direct_slave_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/irq_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/clk_125m_tdc_o
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/clk_125m_mezz
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/rst_125m_mezz_n
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/rst_125m_mezz
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/acam_refclk_r_edge_p
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/send_dac_word_p
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/dac_word
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/pll_sclk
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/pll_sdi
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/pll_dac_sync
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/fmc_eic_irq
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/fmc_eic_irq_synch
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_scl_out
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_scl_oen
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_sda_out
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/tdc_sda_oen
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/direct_timestamp
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/direct_timestamp_wr
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/cnx_master_in
add wave -noupdate -group Mezz1Wrapper /main/DUT/cmp_tdc_mezzanine_1/cnx_master_out
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/clk_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/rst_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/activate_acq_p_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/deactivate_acq_p_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_wr_config_p_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rst_p_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rdbk_config_p_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rdbk_status_p_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rdbk_ififo1_p_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rdbk_ififo2_p_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_rdbk_start01_p_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_config_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ef1_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ef1_meta_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ef2_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ef2_meta_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ack_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_dat_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/start_from_fpga_i
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/state_active_p_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_adr_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_cyc_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_stb_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_dat_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_we_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_config_rdbk_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ififo1_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_ififo2_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_start01_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_tstamp1_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_tstamp2_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_tstamp1_ok_p_o
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_tstamp2_ok_p_o
add wave -noupdate -group DataEngine1 -height 16 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/engine_st
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/nxt_engine_st
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_cyc
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_stb
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_we
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_adr
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/config_adr_c
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_config_rdbk
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/reset_word
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/acam_config_reg4
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/time_c_full_p
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/time_c_en
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/time_c_rst
add wave -noupdate -group DataEngine1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_engine_block/time_c
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/clk_i
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/rst_i
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/acam_refclk_r_edge_p_i
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/utc_p_i
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/state_active_p_i
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/activate_acq_p_i
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/deactivate_acq_p_i
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/err_flag_i
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/int_flag_i
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/start_from_fpga_o
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/stop_dis_o
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/acam_errflag_r_edge_p_o
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/acam_errflag_f_edge_p_o
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/acam_intflag_f_edge_p_o
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/int_flag_synch
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/err_flag_synch
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/acam_intflag_f_edge_p
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/start_pulse
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/wait_for_utc
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/rst_n
add wave -noupdate -group acam-timing1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_timing_block/wait_for_state_active
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/clk_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/rst_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/acam_refclk_r_edge_p_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/clk_period_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/load_utc_p_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/starting_utc_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/pulse_delay_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/local_utc_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/local_utc_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/local_utc
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/one_hz_p_pre
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/one_hz_p_post
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/onesec_counter_en
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_one_second_block/total_delay
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/clk_sys_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/rst_n_sys_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/clk_tdc_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/rst_tdc_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/slave_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/slave_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_config_rdbk_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_ififo1_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_ififo2_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_start01_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wr_index_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/local_utc_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/core_status_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_code_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wrabbit_status_reg_i
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_config_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/activate_acq_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/deactivate_acq_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_wr_config_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_config_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rst_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_status_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_ififo1_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_ififo2_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_start01_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dacapo_c_rst_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/deactivate_chan_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/send_dac_word_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dac_word_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/load_utc_p_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/starting_utc_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_tstamp_threshold_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_time_threshold_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/one_hz_phase_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_inputs_en_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wrabbit_ctrl_reg_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/start_phase_o
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_config
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/reg_adr
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/reg_adr_pipe0
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/starting_utc
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_inputs_en
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/start_phase
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/ctrl_reg
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/one_hz_phase
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_tstamp_threshold
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_time_threshold
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/clear_ctrl_reg
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/send_dac_word_p
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dac_word
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/pulse_extender_en
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/pulse_extender_c
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wrabbit_ctrl_reg
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/deactivate_chan
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/ack_out_pipe0
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/ack_out_pipe1
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb0
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb1
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb2
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb3
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe0
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe1
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe2
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe3
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/cyc_in_progress
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wb_in
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wb_out
add wave -noupdate -group 1s-1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/rst_n_tdc
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/clk_sys_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/rst_n_sys_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/clk_tdc_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/rst_tdc_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/slave_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/slave_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_config_rdbk_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_ififo1_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_ififo2_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_start01_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wr_index_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/local_utc_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/core_status_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_code_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wrabbit_status_reg_i
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_config_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/activate_acq_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/deactivate_acq_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_wr_config_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_config_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rst_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_status_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_ififo1_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_ififo2_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_rdbk_start01_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dacapo_c_rst_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/deactivate_chan_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/send_dac_word_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dac_word_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/load_utc_p_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/starting_utc_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_tstamp_threshold_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_time_threshold_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/one_hz_phase_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_inputs_en_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wrabbit_ctrl_reg_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/start_phase_o
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_config
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/reg_adr
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/reg_adr_pipe0
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/starting_utc
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/acam_inputs_en
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/start_phase
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/ctrl_reg
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/one_hz_phase
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_tstamp_threshold
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/irq_time_threshold
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/clear_ctrl_reg
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/send_dac_word_p
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dac_word
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/pulse_extender_en
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/pulse_extender_c
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wrabbit_ctrl_reg
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/deactivate_chan
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/ack_out_pipe0
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/ack_out_pipe1
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb0
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb1
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb2
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_comb3
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe0
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe1
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe2
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/dat_out_pipe3
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/cyc_in_progress
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wb_in
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/wb_out
add wave -noupdate -expand -group Regs1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reg_control_block/rst_n_tdc
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/clk_tdc_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/clk_sys_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/rst_n_sys_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_wr_rst_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_wr_stb_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_wr_cyc_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_wr_we_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_wr_adr_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_wr_dat_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tdc_mem_wb_rst_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tdc_mem_wb_stb_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tdc_mem_wb_cyc_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tdc_mem_wb_we_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tdc_mem_wb_adr_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tdc_mem_wb_dat_i
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_wr_ack_p_o
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_wr_dat_o
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tdc_mem_wb_ack_o
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tdc_mem_wb_dat_o
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tdc_mem_wb_stall_o
add wave -noupdate -expand -group CircBuf1 -height 16 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_rd_wb_st
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/nxt_tstamp_rd_wb_st
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_wr_ack_p
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_rd_we
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/tstamp_wr_we
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/mb_data
add wave -noupdate -expand -group CircBuf1 /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circular_buffer_block/adr_d0
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/clk_sys_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/rst_n_sys_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/clk_tdc_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/rst_tdc_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_refclk_r_edge_p_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/send_dac_word_p_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/dac_word_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/start_from_fpga_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/err_flag_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/int_flag_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/start_dis_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/stop_dis_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/data_bus_io
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/address_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/cs_n_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/oe_n_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/rd_n_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wr_n_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/ef1_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/ef2_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/enable_inputs_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/term_en_1_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/term_en_2_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/term_en_3_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/term_en_4_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/term_en_5_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_status_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig1_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig2_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig3_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig4_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_led_trig5_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_1_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_2_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_3_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_4_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_5_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/irq_tstamp_p_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/irq_time_p_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/irq_acam_err_p_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_status_reg_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_ctrl_reg_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_synched_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_tai_p_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_tai_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/cfg_slave_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/cfg_slave_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/mem_slave_i
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/mem_slave_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/direct_timestamp_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/direct_timestamp_stb_o
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_adr
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_cyc
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_stb
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_we
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_ack
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_dat_r
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acm_dat_w
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ef1
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ef2
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ef1_meta
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ef2_meta
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_errflag_f_edge_p
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_errflag_r_edge_p
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_intflag_f_edge_p
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp1
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp2
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp1_ok_p
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp2_ok_p
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/activate_acq_p
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/deactivate_acq_p
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/load_acam_config
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/read_acam_config
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/read_acam_status
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/read_ififo1
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/read_ififo2
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/read_start01
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/reset_acam
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/load_utc
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/clear_dacapo_counter
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/roll_over_incr_recent
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/deactivate_chan
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/pulse_delay
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/window_delay
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/clk_period
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/starting_utc
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_inputs_en
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ififo1
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_ififo2
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_start01
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/irq_tstamp_threshold
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/irq_time_threshold
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_utc
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wr_index
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_config
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_config_rdbk
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tstamp_wr_p
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/start_from_fpga
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/state_active_p
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/clk_i_cycles_offset
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/roll_over_nb
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/retrig_nb_offset
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/local_utc_p
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/current_retrig_nb
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/utc_p
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/utc
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/wrabbit_ctrl_reg
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circ_buff_class_adr
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circ_buff_class_stb
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circ_buff_class_cyc
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circ_buff_class_we
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circ_buff_class_ack
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circ_buff_class_data_wr
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/circ_buff_class_data_rd
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_channel
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_1
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_2
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_3
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_4
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/tdc_in_fpga_5
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/acam_tstamp_channel
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/rst_sys
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/CONTROL
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/CLK
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/TRIG0
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/TRIG1
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/TRIG2
add wave -noupdate -group TDC1Core /main/DUT/cmp_tdc_mezzanine_1/cmp_tdc_mezz/cmp_tdc_core/TRIG3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {943109721 ps} 0}
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
WaveRestoreZoom {919925540 ps} {1035495170 ps}
