# Synopsys, Inc. constraint file
# C:/FMC_TDC/evas_fmc_tdc/syn/tdc_syn_constraints.sdc
# Written on Fri Aug 09 16:09:57 2013
# by Synplify Premier with Design Planner, F-2012.03 Scope Editor

#
# Collections
#

#
# Clocks
#
define_clock   {p:tdc_clk_p_i} -name {tdc_clk125p}  -freq 125 -clockgroup default_clkgroup28__1
define_clock   {p:spec_clk_i} -name {spec_clk20}  -freq 20 -clockgroup default_clkgroup29__2
define_clock   {p:acam_refclk_p_i} -name {acam_refclk31_25}  -freq 31.25 -clockgroup default_clkgroup30__3
define_clock   {n:gnum_interface_block.cmp_clk_in.rx_bufg_pll_x1} -name {gnum_clk200}  -freq 200 -clockgroup default_clkgroup31__4

#
# Clock to Clock
#

#
# Inputs/Outputs
#
define_input_delay -disable      -default  2.00 -improve 0.00 -route 0.00 -ref {tdc_clk125:r}
define_output_delay -disable     -default  2.00 -improve 0.00 -route 0.00 -ref {tdc_clk125:r}

#
# Registers
#

#
# Delay Paths
#
define_false_path  -to {{p:tdc_led_status_o}} 
define_false_path  -to {{p:tdc_led_trig1_o}} 
define_false_path  -to {{p:tdc_led_trig2_o}} 
define_false_path  -to {{p:tdc_led_trig3_o}} 
define_false_path  -to {{p:tdc_led_trig4_o}} 
define_false_path  -to {{p:tdc_led_trig5_o}} 
define_false_path  -from {{p:rst_n_a_i}} 
define_false_path  -from {{i:gnum_interface_block.rst_reg}} 

#
# Attributes
#
define_global_attribute  {syn_useioff} {1}
define_global_attribute  {syn_noarrayports} {1}
define_global_attribute  {syn_netlist_hierarchy} {0}
define_attribute {p:acam_refclk_p_i} {syn_loc} {E16}
define_attribute {p:acam_refclk_n_i} {syn_loc} {F16}
define_attribute {p:tdc_clk_p_i} {syn_loc} {L20}
define_attribute {p:tdc_clk_n_i} {syn_loc} {L22}
define_attribute {p:tdc_led_trig1_o} {syn_loc} {W18}
define_attribute {p:tdc_led_trig2_o} {syn_loc} {B20}
define_attribute {p:tdc_led_trig3_o} {syn_loc} {A20}
define_attribute {p:term_en_1_o} {syn_loc} {Y11}
define_attribute {p:term_en_2_o} {syn_loc} {AB11}
define_attribute {p:ef1_i} {syn_loc} {W12}
define_attribute {p:ef2_i} {syn_loc} {Y12}
define_attribute {p:term_en_3_o} {syn_loc} {R11}
define_attribute {p:term_en_4_o} {syn_loc} {T11}
define_attribute {p:term_en_5_o} {syn_loc} {R13}
define_attribute {p:tdc_led_status_o} {syn_loc} {T14}
define_attribute {p:tdc_led_trig4_o} {syn_loc} {D17}
define_attribute {p:tdc_led_trig5_o} {syn_loc} {C18}
define_attribute {p:pll_sclk_o} {syn_loc} {AA16}
define_attribute {p:pll_dac_sync_o} {syn_loc} {AB16}
define_attribute {p:pll_cs_o} {syn_loc} {Y17}
define_attribute {p:cs_n_o} {syn_loc} {AB17}
define_attribute {p:err_flag_i} {syn_loc} {V11}
define_attribute {p:int_flag_i} {syn_loc} {W11}
define_attribute {p:start_dis_o} {syn_loc} {T15}
define_attribute {p:stop_dis_o} {syn_loc} {U15}
define_attribute {p:rst_n_a_i} {syn_loc} {N20}
define_attribute {p:p2l_clk_p_i} {syn_loc} {M20}
define_attribute {p:p2l_clk_n_i} {syn_loc} {M19}
define_attribute {p:p2l_data_i[15]} {syn_loc} {H19}
define_attribute {p:p2l_data_i[14]} {syn_loc} {F21}
define_attribute {p:p2l_data_i[13]} {syn_loc} {F22}
define_attribute {p:p2l_data_i[12]} {syn_loc} {E20}
define_attribute {p:p2l_data_i[11]} {syn_loc} {E22}
define_attribute {p:p2l_data_i[10]} {syn_loc} {J19}
define_attribute {p:p2l_data_i[9]} {syn_loc} {H20}
define_attribute {p:p2l_data_i[8]} {syn_loc} {K19}
define_attribute {p:p2l_data_i[7]} {syn_loc} {K18}
define_attribute {p:p2l_data_i[6]} {syn_loc} {G20}
define_attribute {p:p2l_data_i[5]} {syn_loc} {G22}
define_attribute {p:p2l_data_i[4]} {syn_loc} {K17}
define_attribute {p:p2l_data_i[3]} {syn_loc} {L17}
define_attribute {p:p2l_data_i[2]} {syn_loc} {H21}
define_attribute {p:p2l_data_i[1]} {syn_loc} {H22}
define_attribute {p:p2l_data_i[0]} {syn_loc} {K20}
define_attribute {p:p2l_dframe_i} {syn_loc} {J22}
define_attribute {p:p2l_valid_i} {syn_loc} {L19}
define_attribute {p:p2l_rdy_o} {syn_loc} {J16}
define_attribute {p:p_wr_req_i[1]} {syn_loc} {M21}
define_attribute {p:p_wr_req_i[0]} {syn_loc} {M22}
define_attribute {p:p_wr_rdy_o[1]} {syn_loc} {K16}
define_attribute {p:p_wr_rdy_o[0]} {syn_loc} {L15}
define_attribute {p:rx_error_o} {syn_loc} {J17}
define_attribute {p:vc_rdy_i[1]} {syn_loc} {B22}
define_attribute {p:vc_rdy_i[0]} {syn_loc} {B21}
define_attribute {p:l2p_clk_p_o} {syn_loc} {K21}
define_attribute {p:l2p_clk_n_o} {syn_loc} {K22}
define_attribute {p:l2p_data_o[15]} {syn_loc} {Y21}
define_attribute {p:l2p_data_o[14]} {syn_loc} {W20}
define_attribute {p:l2p_data_o[13]} {syn_loc} {V20}
define_attribute {p:l2p_data_o[12]} {syn_loc} {V22}
define_attribute {p:l2p_data_o[11]} {syn_loc} {T19}
define_attribute {p:l2p_data_o[10]} {syn_loc} {T21}
define_attribute {p:l2p_data_o[9]} {syn_loc} {R22}
define_attribute {p:l2p_data_o[8]} {syn_loc} {P22}
define_attribute {p:l2p_data_o[7]} {syn_loc} {Y22}
define_attribute {p:l2p_data_o[6]} {syn_loc} {W22}
define_attribute {p:l2p_data_o[5]} {syn_loc} {V19}
define_attribute {p:l2p_data_o[4]} {syn_loc} {V21}
define_attribute {p:l2p_data_o[3]} {syn_loc} {T20}
define_attribute {p:l2p_data_o[2]} {syn_loc} {P18}
define_attribute {p:l2p_data_o[1]} {syn_loc} {P21}
define_attribute {p:l2p_data_o[0]} {syn_loc} {P16}
define_attribute {p:l2p_dframe_o} {syn_loc} {U22}
define_attribute {p:l2p_valid_o} {syn_loc} {T18}
define_attribute {p:l2p_edb_o} {syn_loc} {U20}
define_attribute {p:l2p_rdy_i} {syn_loc} {U19}
define_attribute {p:l_wr_rdy_i[1]} {syn_loc} {T22}
define_attribute {p:l_wr_rdy_i[0]} {syn_loc} {R20}
define_attribute {p:p_rd_d_rdy_i[1]} {syn_loc} {P19}
define_attribute {p:p_rd_d_rdy_i[0]} {syn_loc} {N16}
define_attribute {p:tx_error_i} {syn_loc} {M17}
define_attribute {p:irq_p_o} {syn_loc} {U16}
define_attribute {p:pll_sdo_i} {syn_loc} {AB18}
define_attribute {p:pll_status_i} {syn_loc} {Y18}
define_attribute {p:pll_sdi_o} {syn_loc} {AA18}
define_attribute {p:start_from_fpga_o} {syn_loc} {W17}
define_attribute {p:data_bus_io[27]} {syn_loc} {AB4}
define_attribute {p:data_bus_io[26]} {syn_loc} {AA4}
define_attribute {p:data_bus_io[25]} {syn_loc} {AB9}
define_attribute {p:data_bus_io[24]} {syn_loc} {Y9}
define_attribute {p:data_bus_io[23]} {syn_loc} {Y10}
define_attribute {p:data_bus_io[22]} {syn_loc} {W10}
define_attribute {p:data_bus_io[21]} {syn_loc} {U10}
define_attribute {p:data_bus_io[20]} {syn_loc} {T10}
define_attribute {p:data_bus_io[19]} {syn_loc} {AB8}
define_attribute {p:data_bus_io[18]} {syn_loc} {AA8}
define_attribute {p:data_bus_io[17]} {syn_loc} {AB7}
define_attribute {p:data_bus_io[16]} {syn_loc} {Y7}
define_attribute {p:data_bus_io[15]} {syn_loc} {V9}
define_attribute {p:data_bus_io[14]} {syn_loc} {U9}
define_attribute {p:data_bus_io[13]} {syn_loc} {AB6}
define_attribute {p:data_bus_io[12]} {syn_loc} {AA6}
define_attribute {p:data_bus_io[11]} {syn_loc} {R8}
define_attribute {p:data_bus_io[10]} {syn_loc} {R9}
define_attribute {p:data_bus_io[9]} {syn_loc} {AB5}
define_attribute {p:data_bus_io[8]} {syn_loc} {Y5}
define_attribute {p:data_bus_io[7]} {syn_loc} {AB12}
define_attribute {p:data_bus_io[6]} {syn_loc} {U8}
define_attribute {p:data_bus_io[5]} {syn_loc} {AA12}
define_attribute {p:data_bus_io[4]} {syn_loc} {T8}
define_attribute {p:data_bus_io[3]} {syn_loc} {W8}
define_attribute {p:data_bus_io[2]} {syn_loc} {V7}
define_attribute {p:data_bus_io[1]} {syn_loc} {Y6}
define_attribute {p:data_bus_io[0]} {syn_loc} {W6}
define_attribute {p:address_o[3]} {syn_loc} {AB15}
define_attribute {p:address_o[2]} {syn_loc} {Y15}
define_attribute {p:address_o[1]} {syn_loc} {U12}
define_attribute {p:address_o[0]} {syn_loc} {T12}
define_attribute {p:oe_n_o} {syn_loc} {V13}
define_attribute {p:rd_n_o} {syn_loc} {AB13}
define_attribute {p:wr_n_o} {syn_loc} {Y13}
define_attribute {p:enable_inputs_o} {syn_loc} {C19}
define_attribute {p:spec_aux0_i} {syn_loc} {C22}
define_attribute {p:spec_aux1_i} {syn_loc} {D21}
define_attribute {p:spec_aux2_o} {syn_loc} {G19}
define_attribute {p:spec_aux3_o} {syn_loc} {F20}
define_attribute {p:spec_aux4_o} {syn_loc} {F18}
define_attribute {p:spec_aux5_o} {syn_loc} {C20}
define_attribute {p:spec_led_green_o} {syn_loc} {E5}
define_attribute {p:spec_led_red_o} {syn_loc} {D5}
define_attribute {p:spec_clk_i} {syn_loc} {H12}
define_attribute {p:carrier_one_wire_b} {syn_loc} {D4}
define_attribute {p:mezz_one_wire_b} {syn_loc} {A19}
define_attribute {p:mezz_sys_scl_b} {syn_loc} {F7}
define_attribute {p:mezz_sys_sda_b} {syn_loc} {F8}
define_attribute {p:pcb_ver_i[0]} {syn_loc} {P5}
define_attribute {p:pcb_ver_i[1]} {syn_loc} {P4}
define_attribute {p:pcb_ver_i[2]} {syn_loc} {AA2}
define_attribute {p:pcb_ver_i[3]} {syn_loc} {AA1}
define_attribute {p:prsnt_m2c_n_i} {syn_loc} {AB14}

#
# I/O Standards
#
define_io_standard               {acam_refclk_p_i} syn_pad_type {DIFF_SSTL_18_Class_II}
define_io_standard               {acam_refclk_n_i} syn_pad_type {DIFF_SSTL_18_Class_II}
define_io_standard               {tdc_clk_p_i} syn_pad_type {DIFF_SSTL_18_Class_II}
define_io_standard               {tdc_clk_n_i} syn_pad_type {DIFF_SSTL_18_Class_II}
define_io_standard               {tdc_led_trig1_o} syn_pad_type {LVCMOS_25}
define_io_standard               {tdc_led_trig2_o} syn_pad_type {LVCMOS_25}
define_io_standard               {tdc_led_trig3_o} syn_pad_type {LVCMOS_25}
define_io_standard               {term_en_1_o} syn_pad_type {LVCMOS_25}
define_io_standard               {term_en_2_o} syn_pad_type {LVCMOS_25}
define_io_standard               {ef1_i} syn_pad_type {LVCMOS_25}
define_io_standard               {ef2_i} syn_pad_type {LVCMOS_25}
define_io_standard               {term_en_3_o} syn_pad_type {LVCMOS_25}
define_io_standard               {term_en_4_o} syn_pad_type {LVCMOS_25}
define_io_standard               {term_en_5_o} syn_pad_type {LVCMOS_25}
define_io_standard               {tdc_led_status_o} syn_pad_type {LVCMOS_25}
define_io_standard               {tdc_led_trig4_o} syn_pad_type {LVCMOS_25}
define_io_standard               {tdc_led_trig5_o} syn_pad_type {LVCMOS_25}
define_io_standard               {pll_sclk_o} syn_pad_type {LVCMOS_25}
define_io_standard               {pll_dac_sync_o} syn_pad_type {LVCMOS_25}
define_io_standard               {pll_cs_o} syn_pad_type {LVCMOS_25}
define_io_standard               {cs_n_o} syn_pad_type {LVCMOS_25}
define_io_standard               {rst_n_a_i} syn_pad_type {LVCMOS18}
define_io_standard               {p2l_clk_p_i} syn_pad_type {DIFF_SSTL_18_Class_II}
define_io_standard               {p2l_clk_n_i} syn_pad_type {DIFF_SSTL_18_Class_II}
define_io_standard               {p2l_data_i[15:0]} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {p2l_dframe_i} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {p2l_valid_i} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {p2l_rdy_o} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {p_wr_req_i[1:0]} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {p_wr_rdy_o[1:0]} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {rx_error_o} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {vc_rdy_i[1:0]} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {l2p_clk_p_o} syn_pad_type {DIFF_SSTL_18_Class_II}
define_io_standard               {l2p_clk_n_o} syn_pad_type {DIFF_SSTL_18_Class_II}
define_io_standard               {l2p_data_o[15:0]} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {l2p_dframe_o} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {l2p_valid_o} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {l2p_edb_o} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {l2p_rdy_i} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {l_wr_rdy_i[1:0]} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {p_rd_d_rdy_i[1:0]} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {tx_error_i} syn_pad_type {SSTL_18_Class_I}
define_io_standard               {irq_p_o} syn_pad_type {LVCMOS_25}
define_io_standard               {pcb_ver_i[0]} syn_pad_type {LVCMOS_15}
define_io_standard               {pcb_ver_i[1]} syn_pad_type {LVCMOS_15}
define_io_standard               {pcb_ver_i[2]} syn_pad_type {LVCMOS_15}
define_io_standard               {pcb_ver_i[3]} syn_pad_type {LVCMOS_15}
define_io_standard               {prsnt_m2c_n_i} syn_pad_type {LVCMOS_25}
define_io_standard               {pll_status_i} syn_pad_type {LVCMOS_25}
define_io_standard               {pll_sdo_i} syn_pad_type {LVCMOS_25}
define_io_standard               {pll_sdi_o} syn_pad_type {LVCMOS_25}
define_io_standard               {err_flag_i} syn_pad_type {LVCMOS_25}
define_io_standard               {int_flag_i} syn_pad_type {LVCMOS_25}
define_io_standard               {start_dis_o} syn_pad_type {LVCMOS_25}
define_io_standard               {start_from_fpga_o} syn_pad_type {LVCMOS_25}
define_io_standard               {stop_dis_o} syn_pad_type {LVCMOS_25}
define_io_standard               {data_bus_io[27:0]} syn_pad_type {LVCMOS_25}
define_io_standard               {address_o[3:0]} syn_pad_type {LVCMOS_25}
define_io_standard               {oe_n_o} syn_pad_type {LVCMOS_25}
define_io_standard               {rd_n_o} syn_pad_type {LVCMOS_25}
define_io_standard               {wr_n_o} syn_pad_type {LVCMOS_25}
define_io_standard               {enable_inputs_o} syn_pad_type {LVCMOS_25}
define_io_standard               {spec_aux0_i} syn_pad_type {LVCMOS18}
define_io_standard               {spec_aux1_i} syn_pad_type {LVCMOS18}
define_io_standard               {spec_aux2_o} syn_pad_type {LVCMOS18}
define_io_standard               {spec_aux3_o} syn_pad_type {LVCMOS18}
define_io_standard               {spec_aux4_o} syn_pad_type {LVCMOS18}
define_io_standard               {spec_aux5_o} syn_pad_type {LVCMOS18}
define_io_standard               {spec_led_green_o} syn_pad_type {LVCMOS_25}
define_io_standard               {spec_led_red_o} syn_pad_type {LVCMOS_25}
define_io_standard               {spec_clk_i} syn_pad_type {LVCMOS_25}
define_io_standard               {carrier_one_wire_b} syn_pad_type {LVCMOS_25}
define_io_standard               {mezz_sys_scl_b} syn_pad_type {LVCMOS_25}
define_io_standard               {mezz_sys_sda_b} syn_pad_type {LVCMOS_25}
define_io_standard               {mezz_one_wire_b} syn_pad_type {LVCMOS_25}

#
# Compile Points
#

#
# Other
#
