#1001 define_clock {p:tdc_clk_p_i} -name {tdc_clk125p} -freq {125} -clockgroup {default_clkgroup28__1}
define_clock [get_ports {tdc_clk_p_i}] -name {tdc_clk125p} -freq {125} -clockgroup {default_clkgroup28__1} 

#1002 define_clock {p:spec_clk_i} -name {spec_clk20} -freq {20} -clockgroup {default_clkgroup29__2}
define_clock [get_ports {spec_clk_i}] -name {spec_clk20} -freq {20} -clockgroup {default_clkgroup29__2} 

#1003 define_clock {p:acam_refclk_p_i} -name {acam_refclk31_25} -freq {31.25} -clockgroup {default_clkgroup30__3}
define_clock [get_ports {acam_refclk_p_i}] -name {acam_refclk31_25} -freq {31.25} -clockgroup {default_clkgroup30__3} 

#1004 define_clock {n:gnum_interface_block.cmp_clk_in.rx_bufg_pll_x1} -name {gnum_clk200} -freq {200} -clockgroup {default_clkgroup31__4}
define_clock [get_nets {gnum_interface_block.sys_clk}] -name {gnum_clk200} -freq {200} -clockgroup {default_clkgroup31__4} 

#1005 define_multicycle_path -from {p:data_bus_io[27:0]} {3}
define_multicycle_path -from [get_ports {data_bus_io[27:0]}] {3} 

#1006 define_multicycle_path -to {p:data_bus_io[27:0]} {3}
define_multicycle_path -to [get_ports {data_bus_io[27:0]}] {3} 

#1007 define_multicycle_path -to {p:address_o[3:0]} {3}
define_multicycle_path -to [get_ports {address_o[3:0]}] {3} 

#1008 define_false_path -from {p:spec_aux0_i}
define_false_path -from [get_ports {spec_aux0_i}] 

#1009 define_false_path -from {p:spec_aux1_i}
define_false_path -from [get_ports {spec_aux1_i}] 

#1010 define_false_path -to {p:spec_aux2_o}
define_false_path -to [get_ports {spec_aux2_o}] 

#1011 define_false_path -to {p:spec_aux3_o}
define_false_path -to [get_ports {spec_aux3_o}] 

#1012 define_false_path -to {p:spec_aux4_o}
define_false_path -to [get_ports {spec_aux4_o}] 

#1013 define_false_path -to {p:spec_aux5_o}
define_false_path -to [get_ports {spec_aux5_o}] 

#1014 define_false_path -to {p:spec_led_green_o}
define_false_path -to [get_ports {spec_led_green_o}] 

#1015 define_false_path -to {p:spec_led_red_o}
define_false_path -to [get_ports {spec_led_red_o}] 

#1016 define_false_path -to {p:tdc_led_status_o}
define_false_path -to [get_ports {tdc_led_status_o}] 

#1017 define_false_path -to {p:tdc_led_trig1_o}
define_false_path -to [get_ports {tdc_led_trig1_o}] 

#1018 define_false_path -to {p:tdc_led_trig2_o}
define_false_path -to [get_ports {tdc_led_trig2_o}] 

#1019 define_false_path -to {p:tdc_led_trig3_o}
define_false_path -to [get_ports {tdc_led_trig3_o}] 

#1020 define_false_path -to {p:tdc_led_trig4_o}
define_false_path -to [get_ports {tdc_led_trig4_o}] 

#1021 define_false_path -to {p:tdc_led_trig5_o}
define_false_path -to [get_ports {tdc_led_trig5_o}] 

#1022 define_false_path -from {p:rst_n_a_i}
define_false_path -from [get_ports {rst_n_a_i}] 

#1023 define_false_path -from {i:gnum_interface_block.rst_reg}
define_false_path -from [get_cells {gnum_interface_block.rst_reg}] 

#1024 define_global_attribute {syn_useioff} {1}
define_global_attribute {syn_useioff} {1} 

#1025 define_global_attribute {syn_noarrayports} {1}
define_global_attribute {syn_noarrayports} {1} 

#1026 define_global_attribute {syn_netlist_hierarchy} {0}
define_global_attribute {syn_netlist_hierarchy} {0} 

#1027 define_attribute {p:acam_refclk_p_i} {syn_loc} {E16}
define_attribute  {p:acam_refclk_p_i} {syn_loc} {E16} 

#1028 define_attribute {p:acam_refclk_n_i} {syn_loc} {F16}
define_attribute  {p:acam_refclk_n_i} {syn_loc} {F16} 

#1029 define_attribute {p:tdc_clk_p_i} {syn_loc} {L20}
define_attribute  {p:tdc_clk_p_i} {syn_loc} {L20} 

#1030 define_attribute {p:tdc_clk_n_i} {syn_loc} {L22}
define_attribute  {p:tdc_clk_n_i} {syn_loc} {L22} 

#1031 define_attribute {p:tdc_led_trig1_o} {syn_loc} {W18}
define_attribute  {p:tdc_led_trig1_o} {syn_loc} {W18} 

#1032 define_attribute {p:tdc_led_trig2_o} {syn_loc} {B20}
define_attribute  {p:tdc_led_trig2_o} {syn_loc} {B20} 

#1033 define_attribute {p:tdc_led_trig3_o} {syn_loc} {A20}
define_attribute  {p:tdc_led_trig3_o} {syn_loc} {A20} 

#1034 define_attribute {p:term_en_1_o} {syn_loc} {Y11}
define_attribute  {p:term_en_1_o} {syn_loc} {Y11} 

#1035 define_attribute {p:term_en_2_o} {syn_loc} {AB11}
define_attribute  {p:term_en_2_o} {syn_loc} {AB11} 

#1036 define_attribute {p:ef1_i} {syn_loc} {W12}
define_attribute  {p:ef1_i} {syn_loc} {W12} 

#1037 define_attribute {p:ef2_i} {syn_loc} {Y12}
define_attribute  {p:ef2_i} {syn_loc} {Y12} 

#1038 define_attribute {p:term_en_3_o} {syn_loc} {R11}
define_attribute  {p:term_en_3_o} {syn_loc} {R11} 

#1039 define_attribute {p:term_en_4_o} {syn_loc} {T11}
define_attribute  {p:term_en_4_o} {syn_loc} {T11} 

#1040 define_attribute {p:term_en_5_o} {syn_loc} {R13}
define_attribute  {p:term_en_5_o} {syn_loc} {R13} 

#1041 define_attribute {p:tdc_led_status_o} {syn_loc} {T14}
define_attribute  {p:tdc_led_status_o} {syn_loc} {T14} 

#1042 define_attribute {p:tdc_led_trig4_o} {syn_loc} {D17}
define_attribute  {p:tdc_led_trig4_o} {syn_loc} {D17} 

#1043 define_attribute {p:tdc_led_trig5_o} {syn_loc} {C18}
define_attribute  {p:tdc_led_trig5_o} {syn_loc} {C18} 

#1044 define_attribute {p:pll_sclk_o} {syn_loc} {AA16}
define_attribute  {p:pll_sclk_o} {syn_loc} {AA16} 

#1045 define_attribute {p:pll_dac_sync_o} {syn_loc} {AB16}
define_attribute  {p:pll_dac_sync_o} {syn_loc} {AB16} 

#1046 define_attribute {p:pll_cs_o} {syn_loc} {Y17}
define_attribute  {p:pll_cs_o} {syn_loc} {Y17} 

#1047 define_attribute {p:cs_n_o} {syn_loc} {AB17}
define_attribute  {p:cs_n_o} {syn_loc} {AB17} 

#1048 define_attribute {p:prsnt_m2c_n_i} {syn_loc} {AB14}
define_attribute  {p:prsnt_m2c_n_i} {syn_loc} {AB14} 

#1049 define_attribute {p:err_flag_i} {syn_loc} {V11}
define_attribute  {p:err_flag_i} {syn_loc} {V11} 

#1050 define_attribute {p:int_flag_i} {syn_loc} {W11}
define_attribute  {p:int_flag_i} {syn_loc} {W11} 

#1051 define_attribute {p:start_dis_o} {syn_loc} {T15}
define_attribute  {p:start_dis_o} {syn_loc} {T15} 

#1052 define_attribute {p:stop_dis_o} {syn_loc} {U15}
define_attribute  {p:stop_dis_o} {syn_loc} {U15} 

#1053 define_attribute {p:rst_n_a_i} {syn_loc} {N20}
define_attribute  {p:rst_n_a_i} {syn_loc} {N20} 

#1054 define_attribute {p:p2l_clk_p_i} {syn_loc} {M20}
define_attribute  {p:p2l_clk_p_i} {syn_loc} {M20} 

#1055 define_attribute {p:p2l_clk_n_i} {syn_loc} {M19}
define_attribute  {p:p2l_clk_n_i} {syn_loc} {M19} 

#1056 define_attribute {p:p2l_data_i[15]} {syn_loc} {H19}
define_attribute  {b:p2l_data_i[15]} {syn_loc} {H19} 

#1057 define_attribute {p:p2l_data_i[14]} {syn_loc} {F21}
define_attribute  {b:p2l_data_i[14]} {syn_loc} {F21} 

#1058 define_attribute {p:p2l_data_i[13]} {syn_loc} {F22}
define_attribute  {b:p2l_data_i[13]} {syn_loc} {F22} 

#1059 define_attribute {p:p2l_data_i[12]} {syn_loc} {E20}
define_attribute  {b:p2l_data_i[12]} {syn_loc} {E20} 

#1060 define_attribute {p:p2l_data_i[11]} {syn_loc} {E22}
define_attribute  {b:p2l_data_i[11]} {syn_loc} {E22} 

#1061 define_attribute {p:p2l_data_i[10]} {syn_loc} {J19}
define_attribute  {b:p2l_data_i[10]} {syn_loc} {J19} 

#1062 define_attribute {p:p2l_data_i[9]} {syn_loc} {H20}
define_attribute  {b:p2l_data_i[9]} {syn_loc} {H20} 

#1063 define_attribute {p:p2l_data_i[8]} {syn_loc} {K19}
define_attribute  {b:p2l_data_i[8]} {syn_loc} {K19} 

#1064 define_attribute {p:p2l_data_i[7]} {syn_loc} {K18}
define_attribute  {b:p2l_data_i[7]} {syn_loc} {K18} 

#1065 define_attribute {p:p2l_data_i[6]} {syn_loc} {G20}
define_attribute  {b:p2l_data_i[6]} {syn_loc} {G20} 

#1066 define_attribute {p:p2l_data_i[5]} {syn_loc} {G22}
define_attribute  {b:p2l_data_i[5]} {syn_loc} {G22} 

#1067 define_attribute {p:p2l_data_i[4]} {syn_loc} {K17}
define_attribute  {b:p2l_data_i[4]} {syn_loc} {K17} 

#1068 define_attribute {p:p2l_data_i[3]} {syn_loc} {L17}
define_attribute  {b:p2l_data_i[3]} {syn_loc} {L17} 

#1069 define_attribute {p:p2l_data_i[2]} {syn_loc} {H21}
define_attribute  {b:p2l_data_i[2]} {syn_loc} {H21} 

#1070 define_attribute {p:p2l_data_i[1]} {syn_loc} {H22}
define_attribute  {b:p2l_data_i[1]} {syn_loc} {H22} 

#1071 define_attribute {p:p2l_data_i[0]} {syn_loc} {K20}
define_attribute  {b:p2l_data_i[0]} {syn_loc} {K20} 

#1072 define_attribute {p:p2l_dframe_i} {syn_loc} {J22}
define_attribute  {p:p2l_dframe_i} {syn_loc} {J22} 

#1073 define_attribute {p:p2l_valid_i} {syn_loc} {L19}
define_attribute  {p:p2l_valid_i} {syn_loc} {L19} 

#1074 define_attribute {p:p2l_rdy_o} {syn_loc} {J16}
define_attribute  {p:p2l_rdy_o} {syn_loc} {J16} 

#1075 define_attribute {p:p_wr_req_i[1]} {syn_loc} {M21}
define_attribute  {b:p_wr_req_i[1]} {syn_loc} {M21} 

#1076 define_attribute {p:p_wr_req_i[0]} {syn_loc} {M22}
define_attribute  {b:p_wr_req_i[0]} {syn_loc} {M22} 

#1077 define_attribute {p:p_wr_rdy_o[1]} {syn_loc} {K16}
define_attribute  {b:p_wr_rdy_o[1]} {syn_loc} {K16} 

#1078 define_attribute {p:p_wr_rdy_o[0]} {syn_loc} {L15}
define_attribute  {b:p_wr_rdy_o[0]} {syn_loc} {L15} 

#1079 define_attribute {p:rx_error_o} {syn_loc} {J17}
define_attribute  {p:rx_error_o} {syn_loc} {J17} 

#1080 define_attribute {p:vc_rdy_i[1]} {syn_loc} {B22}
define_attribute  {b:vc_rdy_i[1]} {syn_loc} {B22} 

#1081 define_attribute {p:vc_rdy_i[0]} {syn_loc} {B21}
define_attribute  {b:vc_rdy_i[0]} {syn_loc} {B21} 

#1082 define_attribute {p:l2p_clk_p_o} {syn_loc} {K21}
define_attribute  {p:l2p_clk_p_o} {syn_loc} {K21} 

#1083 define_attribute {p:l2p_clk_n_o} {syn_loc} {K22}
define_attribute  {p:l2p_clk_n_o} {syn_loc} {K22} 

#1084 define_attribute {p:l2p_data_o[15]} {syn_loc} {Y21}
define_attribute  {b:l2p_data_o[15]} {syn_loc} {Y21} 

#1085 define_attribute {p:l2p_data_o[14]} {syn_loc} {W20}
define_attribute  {b:l2p_data_o[14]} {syn_loc} {W20} 

#1086 define_attribute {p:l2p_data_o[13]} {syn_loc} {V20}
define_attribute  {b:l2p_data_o[13]} {syn_loc} {V20} 

#1087 define_attribute {p:l2p_data_o[12]} {syn_loc} {V22}
define_attribute  {b:l2p_data_o[12]} {syn_loc} {V22} 

#1088 define_attribute {p:l2p_data_o[11]} {syn_loc} {T19}
define_attribute  {b:l2p_data_o[11]} {syn_loc} {T19} 

#1089 define_attribute {p:l2p_data_o[10]} {syn_loc} {T21}
define_attribute  {b:l2p_data_o[10]} {syn_loc} {T21} 

#1090 define_attribute {p:l2p_data_o[9]} {syn_loc} {R22}
define_attribute  {b:l2p_data_o[9]} {syn_loc} {R22} 

#1091 define_attribute {p:l2p_data_o[8]} {syn_loc} {P22}
define_attribute  {b:l2p_data_o[8]} {syn_loc} {P22} 

#1092 define_attribute {p:l2p_data_o[7]} {syn_loc} {Y22}
define_attribute  {b:l2p_data_o[7]} {syn_loc} {Y22} 

#1093 define_attribute {p:l2p_data_o[6]} {syn_loc} {W22}
define_attribute  {b:l2p_data_o[6]} {syn_loc} {W22} 

#1094 define_attribute {p:l2p_data_o[5]} {syn_loc} {V19}
define_attribute  {b:l2p_data_o[5]} {syn_loc} {V19} 

#1095 define_attribute {p:l2p_data_o[4]} {syn_loc} {V21}
define_attribute  {b:l2p_data_o[4]} {syn_loc} {V21} 

#1096 define_attribute {p:l2p_data_o[3]} {syn_loc} {T20}
define_attribute  {b:l2p_data_o[3]} {syn_loc} {T20} 

#1097 define_attribute {p:l2p_data_o[2]} {syn_loc} {P18}
define_attribute  {b:l2p_data_o[2]} {syn_loc} {P18} 

#1098 define_attribute {p:l2p_data_o[1]} {syn_loc} {P21}
define_attribute  {b:l2p_data_o[1]} {syn_loc} {P21} 

#1099 define_attribute {p:l2p_data_o[0]} {syn_loc} {P16}
define_attribute  {b:l2p_data_o[0]} {syn_loc} {P16} 

#1100 define_attribute {p:l2p_dframe_o} {syn_loc} {U22}
define_attribute  {p:l2p_dframe_o} {syn_loc} {U22} 

#1101 define_attribute {p:l2p_valid_o} {syn_loc} {T18}
define_attribute  {p:l2p_valid_o} {syn_loc} {T18} 

#1102 define_attribute {p:l2p_edb_o} {syn_loc} {U20}
define_attribute  {p:l2p_edb_o} {syn_loc} {U20} 

#1103 define_attribute {p:l2p_rdy_i} {syn_loc} {U19}
define_attribute  {p:l2p_rdy_i} {syn_loc} {U19} 

#1104 define_attribute {p:l_wr_rdy_i[1]} {syn_loc} {T22}
define_attribute  {b:l_wr_rdy_i[1]} {syn_loc} {T22} 

#1105 define_attribute {p:l_wr_rdy_i[0]} {syn_loc} {R20}
define_attribute  {b:l_wr_rdy_i[0]} {syn_loc} {R20} 

#1106 define_attribute {p:p_rd_d_rdy_i[1]} {syn_loc} {P19}
define_attribute  {b:p_rd_d_rdy_i[1]} {syn_loc} {P19} 

#1107 define_attribute {p:p_rd_d_rdy_i[0]} {syn_loc} {N16}
define_attribute  {b:p_rd_d_rdy_i[0]} {syn_loc} {N16} 

#1108 define_attribute {p:tx_error_i} {syn_loc} {M17}
define_attribute  {p:tx_error_i} {syn_loc} {M17} 

#1109 define_attribute {p:irq_p_o} {syn_loc} {U16}
define_attribute  {p:irq_p_o} {syn_loc} {U16} 

#1110 define_attribute {p:pll_sdo_i} {syn_loc} {AB18}
define_attribute  {p:pll_sdo_i} {syn_loc} {AB18} 

#1111 define_attribute {p:pll_status_i} {syn_loc} {Y18}
define_attribute  {p:pll_status_i} {syn_loc} {Y18} 

#1112 define_attribute {p:pll_sdi_o} {syn_loc} {AA18}
define_attribute  {p:pll_sdi_o} {syn_loc} {AA18} 

#1113 define_attribute {p:start_from_fpga_o} {syn_loc} {W17}
define_attribute  {p:start_from_fpga_o} {syn_loc} {W17} 

#1114 define_attribute {p:data_bus_io[27]} {syn_loc} {AB4}
define_attribute  {b:data_bus_io[27]} {syn_loc} {AB4} 

#1115 define_attribute {p:data_bus_io[26]} {syn_loc} {AA4}
define_attribute  {b:data_bus_io[26]} {syn_loc} {AA4} 

#1116 define_attribute {p:data_bus_io[25]} {syn_loc} {AB9}
define_attribute  {b:data_bus_io[25]} {syn_loc} {AB9} 

#1117 define_attribute {p:data_bus_io[24]} {syn_loc} {Y9}
define_attribute  {b:data_bus_io[24]} {syn_loc} {Y9} 

#1118 define_attribute {p:data_bus_io[23]} {syn_loc} {Y10}
define_attribute  {b:data_bus_io[23]} {syn_loc} {Y10} 

#1119 define_attribute {p:data_bus_io[22]} {syn_loc} {W10}
define_attribute  {b:data_bus_io[22]} {syn_loc} {W10} 

#1120 define_attribute {p:data_bus_io[21]} {syn_loc} {U10}
define_attribute  {b:data_bus_io[21]} {syn_loc} {U10} 

#1121 define_attribute {p:data_bus_io[20]} {syn_loc} {T10}
define_attribute  {b:data_bus_io[20]} {syn_loc} {T10} 

#1122 define_attribute {p:data_bus_io[19]} {syn_loc} {AB8}
define_attribute  {b:data_bus_io[19]} {syn_loc} {AB8} 

#1123 define_attribute {p:data_bus_io[18]} {syn_loc} {AA8}
define_attribute  {b:data_bus_io[18]} {syn_loc} {AA8} 

#1124 define_attribute {p:data_bus_io[17]} {syn_loc} {AB7}
define_attribute  {b:data_bus_io[17]} {syn_loc} {AB7} 

#1125 define_attribute {p:data_bus_io[16]} {syn_loc} {Y7}
define_attribute  {b:data_bus_io[16]} {syn_loc} {Y7} 

#1126 define_attribute {p:data_bus_io[15]} {syn_loc} {V9}
define_attribute  {b:data_bus_io[15]} {syn_loc} {V9} 

#1127 define_attribute {p:data_bus_io[14]} {syn_loc} {U9}
define_attribute  {b:data_bus_io[14]} {syn_loc} {U9} 

#1128 define_attribute {p:data_bus_io[13]} {syn_loc} {AB6}
define_attribute  {b:data_bus_io[13]} {syn_loc} {AB6} 

#1129 define_attribute {p:data_bus_io[12]} {syn_loc} {AA6}
define_attribute  {b:data_bus_io[12]} {syn_loc} {AA6} 

#1130 define_attribute {p:data_bus_io[11]} {syn_loc} {R8}
define_attribute  {b:data_bus_io[11]} {syn_loc} {R8} 

#1131 define_attribute {p:data_bus_io[10]} {syn_loc} {R9}
define_attribute  {b:data_bus_io[10]} {syn_loc} {R9} 

#1132 define_attribute {p:data_bus_io[9]} {syn_loc} {AB5}
define_attribute  {b:data_bus_io[9]} {syn_loc} {AB5} 

#1133 define_attribute {p:data_bus_io[8]} {syn_loc} {Y5}
define_attribute  {b:data_bus_io[8]} {syn_loc} {Y5} 

#1134 define_attribute {p:data_bus_io[7]} {syn_loc} {AB12}
define_attribute  {b:data_bus_io[7]} {syn_loc} {AB12} 

#1135 define_attribute {p:data_bus_io[6]} {syn_loc} {U8}
define_attribute  {b:data_bus_io[6]} {syn_loc} {U8} 

#1136 define_attribute {p:data_bus_io[5]} {syn_loc} {AA12}
define_attribute  {b:data_bus_io[5]} {syn_loc} {AA12} 

#1137 define_attribute {p:data_bus_io[4]} {syn_loc} {T8}
define_attribute  {b:data_bus_io[4]} {syn_loc} {T8} 

#1138 define_attribute {p:data_bus_io[3]} {syn_loc} {W8}
define_attribute  {b:data_bus_io[3]} {syn_loc} {W8} 

#1139 define_attribute {p:data_bus_io[2]} {syn_loc} {V7}
define_attribute  {b:data_bus_io[2]} {syn_loc} {V7} 

#1140 define_attribute {p:data_bus_io[1]} {syn_loc} {Y6}
define_attribute  {b:data_bus_io[1]} {syn_loc} {Y6} 

#1141 define_attribute {p:data_bus_io[0]} {syn_loc} {W6}
define_attribute  {b:data_bus_io[0]} {syn_loc} {W6} 

#1142 define_attribute {p:address_o[3]} {syn_loc} {AB15}
define_attribute  {b:address_o[3]} {syn_loc} {AB15} 

#1143 define_attribute {p:address_o[2]} {syn_loc} {Y15}
define_attribute  {b:address_o[2]} {syn_loc} {Y15} 

#1144 define_attribute {p:address_o[1]} {syn_loc} {U12}
define_attribute  {b:address_o[1]} {syn_loc} {U12} 

#1145 define_attribute {p:address_o[0]} {syn_loc} {T12}
define_attribute  {b:address_o[0]} {syn_loc} {T12} 

#1146 define_attribute {p:oe_n_o} {syn_loc} {V13}
define_attribute  {p:oe_n_o} {syn_loc} {V13} 

#1147 define_attribute {p:rd_n_o} {syn_loc} {AB13}
define_attribute  {p:rd_n_o} {syn_loc} {AB13} 

#1148 define_attribute {p:wr_n_o} {syn_loc} {Y13}
define_attribute  {p:wr_n_o} {syn_loc} {Y13} 

#1149 define_attribute {p:enable_inputs_o} {syn_loc} {C19}
define_attribute  {p:enable_inputs_o} {syn_loc} {C19} 

#1150 define_attribute {p:spec_aux0_i} {syn_loc} {C22}
define_attribute  {p:spec_aux0_i} {syn_loc} {C22} 

#1151 define_attribute {p:spec_aux1_i} {syn_loc} {D21}
define_attribute  {p:spec_aux1_i} {syn_loc} {D21} 

#1152 define_attribute {p:spec_aux2_o} {syn_loc} {G19}
define_attribute  {p:spec_aux2_o} {syn_loc} {G19} 

#1153 define_attribute {p:spec_aux3_o} {syn_loc} {F20}
define_attribute  {p:spec_aux3_o} {syn_loc} {F20} 

#1154 define_attribute {p:spec_aux4_o} {syn_loc} {F18}
define_attribute  {p:spec_aux4_o} {syn_loc} {F18} 

#1155 define_attribute {p:spec_aux5_o} {syn_loc} {C20}
define_attribute  {p:spec_aux5_o} {syn_loc} {C20} 

#1156 define_attribute {p:spec_led_green_o} {syn_loc} {E5}
define_attribute  {p:spec_led_green_o} {syn_loc} {E5} 

#1157 define_attribute {p:spec_led_red_o} {syn_loc} {D5}
define_attribute  {p:spec_led_red_o} {syn_loc} {D5} 

#1158 define_attribute {p:spec_clk_i} {syn_loc} {H12}
define_attribute  {p:spec_clk_i} {syn_loc} {H12} 

#1159 define_attribute {p:carrier_one_wire_b} {syn_loc} {D4}
define_attribute  {p:carrier_one_wire_b} {syn_loc} {D4} 

#1160 define_attribute {p:mezz_one_wire_b} {syn_loc} {A19}
define_attribute  {p:mezz_one_wire_b} {syn_loc} {A19} 

#1161 define_attribute {p:sys_scl_b} {syn_loc} {F7}
define_attribute  {p:sys_scl_b} {syn_loc} {F7} 

#1162 define_attribute {p:sys_sda_b} {syn_loc} {F8}
define_attribute  {p:sys_sda_b} {syn_loc} {F8} 

#1163 define_attribute {p:pcb_ver_i[0]} {syn_loc} {P5}
define_attribute  {b:pcb_ver_i[0]} {syn_loc} {P5} 

#1164 define_attribute {p:pcb_ver_i[1]} {syn_loc} {P4}
define_attribute  {b:pcb_ver_i[1]} {syn_loc} {P4} 

#1165 define_attribute {p:pcb_ver_i[2]} {syn_loc} {AA2}
define_attribute  {b:pcb_ver_i[2]} {syn_loc} {AA2} 

#1166 define_attribute {p:pcb_ver_i[3]} {syn_loc} {AA1}
define_attribute  {b:pcb_ver_i[3]} {syn_loc} {AA1} 

#1167 define_attribute {p:prsnt_m2c_n_i} {syn_loc} {AB14}
define_attribute  {p:prsnt_m2c_n_i} {syn_loc} {AB14} 

#1168 define_io_standard {acam_refclk_p_i} {DIFF_SSTL_18_Class_II}
define_io_standard { acam_refclk_p_i } syn_pad_type { DIFF_SSTL_18_Class_II }


#1169 define_io_standard {acam_refclk_n_i} {DIFF_SSTL_18_Class_II}
define_io_standard { acam_refclk_n_i } syn_pad_type { DIFF_SSTL_18_Class_II }


#1170 define_io_standard {tdc_clk_p_i} {DIFF_SSTL_18_Class_II}
define_io_standard { tdc_clk_p_i } syn_pad_type { DIFF_SSTL_18_Class_II }


#1171 define_io_standard {tdc_clk_n_i} {DIFF_SSTL_18_Class_II}
define_io_standard { tdc_clk_n_i } syn_pad_type { DIFF_SSTL_18_Class_II }


#1172 define_io_standard {tdc_led_trig1_o} {LVCMOS_25}
define_io_standard { tdc_led_trig1_o } syn_pad_type { LVCMOS_25 }


#1173 define_io_standard {tdc_led_trig2_o} {LVCMOS_25}
define_io_standard { tdc_led_trig2_o } syn_pad_type { LVCMOS_25 }


#1174 define_io_standard {tdc_led_trig3_o} {LVCMOS_25}
define_io_standard { tdc_led_trig3_o } syn_pad_type { LVCMOS_25 }


#1175 define_io_standard {term_en_1_o} {LVCMOS_25}
define_io_standard { term_en_1_o } syn_pad_type { LVCMOS_25 }


#1176 define_io_standard {term_en_2_o} {LVCMOS_25}
define_io_standard { term_en_2_o } syn_pad_type { LVCMOS_25 }


#1177 define_io_standard {ef1_i} {LVCMOS_25}
define_io_standard { ef1_i } syn_pad_type { LVCMOS_25 }


#1178 define_io_standard {ef2_i} {LVCMOS_25}
define_io_standard { ef2_i } syn_pad_type { LVCMOS_25 }


#1179 define_io_standard {term_en_3_o} {LVCMOS_25}
define_io_standard { term_en_3_o } syn_pad_type { LVCMOS_25 }


#1180 define_io_standard {term_en_4_o} {LVCMOS_25}
define_io_standard { term_en_4_o } syn_pad_type { LVCMOS_25 }


#1181 define_io_standard {term_en_5_o} {LVCMOS_25}
define_io_standard { term_en_5_o } syn_pad_type { LVCMOS_25 }


#1182 define_io_standard {tdc_led_status_o} {LVCMOS_25}
define_io_standard { tdc_led_status_o } syn_pad_type { LVCMOS_25 }


#1183 define_io_standard {tdc_led_trig4_o} {LVCMOS_25}
define_io_standard { tdc_led_trig4_o } syn_pad_type { LVCMOS_25 }


#1184 define_io_standard {tdc_led_trig5_o} {LVCMOS_25}
define_io_standard { tdc_led_trig5_o } syn_pad_type { LVCMOS_25 }


#1185 define_io_standard {pll_sclk_o} {LVCMOS_25}
define_io_standard { pll_sclk_o } syn_pad_type { LVCMOS_25 }


#1186 define_io_standard {pll_dac_sync_o} {LVCMOS_25}
define_io_standard { pll_dac_sync_o } syn_pad_type { LVCMOS_25 }


#1187 define_io_standard {pll_cs_o} {LVCMOS_25}
define_io_standard { pll_cs_o } syn_pad_type { LVCMOS_25 }


#1188 define_io_standard {cs_n_o} {LVCMOS_25}
define_io_standard { cs_n_o } syn_pad_type { LVCMOS_25 }


#1189 define_io_standard {prsnt_m2c_n_i} {LVCMOS_25}
define_io_standard { prsnt_m2c_n_i } syn_pad_type { LVCMOS_25 }


#1190 define_io_standard {rst_n_a_i} {LVCMOS18}
define_io_standard { rst_n_a_i } syn_pad_type { LVCMOS18 }


#1191 define_io_standard {p2l_clk_p_i} {DIFF_SSTL_18_Class_II}
define_io_standard { p2l_clk_p_i } syn_pad_type { DIFF_SSTL_18_Class_II }


#1192 define_io_standard {p2l_clk_n_i} {DIFF_SSTL_18_Class_II}
define_io_standard { p2l_clk_n_i } syn_pad_type { DIFF_SSTL_18_Class_II }


#1193 define_io_standard {p2l_data_i[15:0]} {SSTL_18_Class_I}
define_io_standard { p2l_data_i[15:0] } syn_pad_type { SSTL_18_Class_I }


#1194 define_io_standard {p2l_dframe_i} {SSTL_18_Class_I}
define_io_standard { p2l_dframe_i } syn_pad_type { SSTL_18_Class_I }


#1195 define_io_standard {p2l_valid_i} {SSTL_18_Class_I}
define_io_standard { p2l_valid_i } syn_pad_type { SSTL_18_Class_I }


#1196 define_io_standard {p2l_rdy_o} {SSTL_18_Class_I}
define_io_standard { p2l_rdy_o } syn_pad_type { SSTL_18_Class_I }


#1197 define_io_standard {p_wr_req_i[1:0]} {SSTL_18_Class_I}
define_io_standard { p_wr_req_i[1:0] } syn_pad_type { SSTL_18_Class_I }


#1198 define_io_standard {p_wr_rdy_o[1:0]} {SSTL_18_Class_I}
define_io_standard { p_wr_rdy_o[1:0] } syn_pad_type { SSTL_18_Class_I }


#1199 define_io_standard {rx_error_o} {SSTL_18_Class_I}
define_io_standard { rx_error_o } syn_pad_type { SSTL_18_Class_I }


#1200 define_io_standard {vc_rdy_i[1:0]} {SSTL_18_Class_I}
define_io_standard { vc_rdy_i[1:0] } syn_pad_type { SSTL_18_Class_I }


#1201 define_io_standard {l2p_clk_p_o} {DIFF_SSTL_18_Class_II}
define_io_standard { l2p_clk_p_o } syn_pad_type { DIFF_SSTL_18_Class_II }


#1202 define_io_standard {l2p_clk_n_o} {DIFF_SSTL_18_Class_II}
define_io_standard { l2p_clk_n_o } syn_pad_type { DIFF_SSTL_18_Class_II }


#1203 define_io_standard {l2p_data_o[15:0]} {SSTL_18_Class_I}
define_io_standard { l2p_data_o[15:0] } syn_pad_type { SSTL_18_Class_I }


#1204 define_io_standard {l2p_dframe_o} {SSTL_18_Class_I}
define_io_standard { l2p_dframe_o } syn_pad_type { SSTL_18_Class_I }


#1205 define_io_standard {l2p_valid_o} {SSTL_18_Class_I}
define_io_standard { l2p_valid_o } syn_pad_type { SSTL_18_Class_I }


#1206 define_io_standard {l2p_edb_o} {SSTL_18_Class_I}
define_io_standard { l2p_edb_o } syn_pad_type { SSTL_18_Class_I }


#1207 define_io_standard {l2p_rdy_i} {SSTL_18_Class_I}
define_io_standard { l2p_rdy_i } syn_pad_type { SSTL_18_Class_I }


#1208 define_io_standard {l_wr_rdy_i[1:0]} {SSTL_18_Class_I}
define_io_standard { l_wr_rdy_i[1:0] } syn_pad_type { SSTL_18_Class_I }


#1209 define_io_standard {p_rd_d_rdy_i[1:0]} {SSTL_18_Class_I}
define_io_standard { p_rd_d_rdy_i[1:0] } syn_pad_type { SSTL_18_Class_I }


#1210 define_io_standard {tx_error_i} {SSTL_18_Class_I}
define_io_standard { tx_error_i } syn_pad_type { SSTL_18_Class_I }


#1211 define_io_standard {irq_p_o} {LVCMOS_25}
define_io_standard { irq_p_o } syn_pad_type { LVCMOS_25 }


#1212 define_io_standard {pcb_ver_i[0]} {LVCMOS_15}
define_io_standard { pcb_ver_i[0] } syn_pad_type { LVCMOS_15 }


#1213 define_io_standard {pcb_ver_i[1]} {LVCMOS_15}
define_io_standard { pcb_ver_i[1] } syn_pad_type { LVCMOS_15 }


#1214 define_io_standard {pcb_ver_i[2]} {LVCMOS_15}
define_io_standard { pcb_ver_i[2] } syn_pad_type { LVCMOS_15 }


#1215 define_io_standard {pcb_ver_i[3]} {LVCMOS_15}
define_io_standard { pcb_ver_i[3] } syn_pad_type { LVCMOS_15 }


#1216 define_io_standard {prsnt_m2c_n_i} {LVCMOS_25}
define_io_standard { prsnt_m2c_n_i } syn_pad_type { LVCMOS_25 }


#1217 define_io_standard {pll_status_i} {LVCMOS_25}
define_io_standard { pll_status_i } syn_pad_type { LVCMOS_25 }


#1218 define_io_standard {pll_sdo_i} {LVCMOS_25}
define_io_standard { pll_sdo_i } syn_pad_type { LVCMOS_25 }


#1219 define_io_standard {pll_sdi_o} {LVCMOS_25}
define_io_standard { pll_sdi_o } syn_pad_type { LVCMOS_25 }


#1220 define_io_standard {err_flag_i} {LVCMOS_25}
define_io_standard { err_flag_i } syn_pad_type { LVCMOS_25 }


#1221 define_io_standard {int_flag_i} {LVCMOS_25}
define_io_standard { int_flag_i } syn_pad_type { LVCMOS_25 }


#1222 define_io_standard {start_dis_o} {LVCMOS_25}
define_io_standard { start_dis_o } syn_pad_type { LVCMOS_25 }


#1223 define_io_standard {start_from_fpga_o} {LVCMOS_25}
define_io_standard { start_from_fpga_o } syn_pad_type { LVCMOS_25 }


#1224 define_io_standard {stop_dis_o} {LVCMOS_25}
define_io_standard { stop_dis_o } syn_pad_type { LVCMOS_25 }


#1225 define_io_standard {data_bus_io[27:0]} {LVCMOS_25}
define_io_standard { data_bus_io[27:0] } syn_pad_type { LVCMOS_25 }


#1226 define_io_standard {address_o[3:0]} {LVCMOS_25}
define_io_standard { address_o[3:0] } syn_pad_type { LVCMOS_25 }


#1227 define_io_standard {oe_n_o} {LVCMOS_25}
define_io_standard { oe_n_o } syn_pad_type { LVCMOS_25 }


#1228 define_io_standard {rd_n_o} {LVCMOS_25}
define_io_standard { rd_n_o } syn_pad_type { LVCMOS_25 }


#1229 define_io_standard {wr_n_o} {LVCMOS_25}
define_io_standard { wr_n_o } syn_pad_type { LVCMOS_25 }


#1230 define_io_standard {enable_inputs_o} {LVCMOS_25}
define_io_standard { enable_inputs_o } syn_pad_type { LVCMOS_25 }


#1231 define_io_standard {spec_aux0_i} {LVCMOS18}
define_io_standard { spec_aux0_i } syn_pad_type { LVCMOS18 }


#1232 define_io_standard {spec_aux1_i} {LVCMOS18}
define_io_standard { spec_aux1_i } syn_pad_type { LVCMOS18 }


#1233 define_io_standard {spec_aux2_o} {LVCMOS18}
define_io_standard { spec_aux2_o } syn_pad_type { LVCMOS18 }


#1234 define_io_standard {spec_aux3_o} {LVCMOS18}
define_io_standard { spec_aux3_o } syn_pad_type { LVCMOS18 }


#1235 define_io_standard {spec_aux4_o} {LVCMOS18}
define_io_standard { spec_aux4_o } syn_pad_type { LVCMOS18 }


#1236 define_io_standard {spec_aux5_o} {LVCMOS18}
define_io_standard { spec_aux5_o } syn_pad_type { LVCMOS18 }


#1237 define_io_standard {spec_led_green_o} {LVCMOS_25}
define_io_standard { spec_led_green_o } syn_pad_type { LVCMOS_25 }


#1238 define_io_standard {spec_led_red_o} {LVCMOS_25}
define_io_standard { spec_led_red_o } syn_pad_type { LVCMOS_25 }


#1239 define_io_standard {spec_clk_i} {LVCMOS_25}
define_io_standard { spec_clk_i } syn_pad_type { LVCMOS_25 }


#1240 define_io_standard {carrier_one_wire_b} {LVCMOS_25}
define_io_standard { carrier_one_wire_b } syn_pad_type { LVCMOS_25 }


#1241 define_io_standard {sys_scl_b} {LVCMOS_25}
define_io_standard { sys_scl_b } syn_pad_type { LVCMOS_25 }


#1242 define_io_standard {sys_sda_b} {LVCMOS_25}
define_io_standard { sys_sda_b } syn_pad_type { LVCMOS_25 }


#1243 define_io_standard {mezz_one_wire_b} {LVCMOS_25}
define_io_standard { mezz_one_wire_b } syn_pad_type { LVCMOS_25 }


