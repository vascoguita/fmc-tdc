@TM:1311271088
@N:  :"":0:0:0:-1|Running in logic synthesis mode without enhanced optimization
@W:  :"":0:0:0:-1|No start clock found for start point gnum_interface_block.cmp_wbmaster32.cmp_fifo_to_wb / prog_full (rising). Should not occur. 
@W:  :"":0:0:0:-1|No start clock found for start point gnum_interface_block.cmp_p2l_dma_master.cmp_to_wb_fifo / prog_full (rising). Should not occur. 
@W:  :"":0:0:0:-1|No start clock found for start point gnum_interface_block.cmp_l2p_ser.cmp_clk_out.loop0®0®loop3®oserdes_m / OQ (rising). Should not occur. 
@W:  :"":0:0:0:-1|No start clock found for start point gnum_interface_block.cmp_l2p_ser.cmp_dframe_out.loop0®0®loop3®oserdes_m / OQ (rising). Should not occur. 
@W:  :"":0:0:0:-1|No start clock found for start point gnum_interface_block.cmp_l2p_ser.cmp_valid_out.loop0®0®loop3®oserdes_m / OQ (rising). Should not occur. 
@W: BN102 :"":0:0:0:-1|Cannot find object p2l_data_i to apply define_input_delay 
@W: BN102 :"":0:0:0:-1|Cannot find object p_wr_req_i to apply define_input_delay 
@W: BN102 :"":0:0:0:-1|Cannot find object vc_rdy_i to apply define_input_delay 
@W: BN102 :"":0:0:0:-1|Cannot find object l_wr_rdy_i to apply define_input_delay 
@W: BN102 :"":0:0:0:-1|Cannot find object p_rd_d_rdy_i to apply define_input_delay 
@W: BN103 :"":0:0:0:-1|Cannot find object p_wr_rdy_o to apply define_output_delay 
@W: BN103 :"":0:0:0:-1|Cannot find object l2p_data_o to apply define_output_delay 
@N: BN116 :"":0:0:0:-1|Removing sequential instance state[0] of view:PrimLib.dffr(prim) because there are no references to its outputs 
@N: BN116 :"":0:0:0:-1|Removing sequential instance state[1] of view:PrimLib.dffr(prim) because there are no references to its outputs 
@N: BN116 :"":0:0:0:-1|Removing sequential instance state[2] of view:PrimLib.dffr(prim) because there are no references to its outputs 
@N: BN116 :"":0:0:0:-1|Removing sequential instance state[3] of view:PrimLib.dffr(prim) because there are no references to its outputs 
@N: FX211 :"":0:0:0:-1|Packed ROM clks_rsts_mgment.un7_word_being_sent_0[17:0] (7 input, 18 output) to Block SelectRAM 
@N: FX430 :"":0:0:0:-1|Found 3 global buffers instantiated by user 
@N: FX623 :"":0:0:0:-1|Packing into LUT62
@N: MF249 :"":0:0:0:-1|Running in 64-bit mode.
@N: MF257 :"":0:0:0:-1|Gated clock conversion enabled 
@N: MF276 :"":0:0:0:-1|Gated clock conversion enabled, but no gated clocks found in design 
@N: MF333 :"":0:0:0:-1|Generated clock conversion enabled, but no generated clocks found in design 
@TM:1312220640
@W: MT305 :"":0:0:0:-1|Timing constraint (to p:tdc_led_trig5_o) (false path) was not applied to the design because none of the '-to' objects specified by the constraint exist in the design 
@TM:1311271088
@W: MT305 :"":0:0:0:-1|Timing constraint (to p:spec_aux4_o) (false path) was not applied to the design because higher priority constraint(s) were applied to the paths 
@W: MT305 :"":0:0:0:-1|Timing constraint (to p:spec_aux5_o) (false path) was not applied to the design because higher priority constraint(s) were applied to the paths 
@W: MT305 :"":0:0:0:-1|Timing constraint (to p:tdc_led_trig1_o) (false path) was not applied to the design because none of the '-to' objects specified by the constraint exist in the design 
@W: MT305 :"":0:0:0:-1|Timing constraint (to p:tdc_led_trig2_o) (false path) was not applied to the design because none of the '-to' objects specified by the constraint exist in the design 
@W: MT305 :"":0:0:0:-1|Timing constraint (to p:tdc_led_trig3_o) (false path) was not applied to the design because none of the '-to' objects specified by the constraint exist in the design 
@W: MT305 :"":0:0:0:-1|Timing constraint (to p:tdc_led_trig4_o) (false path) was not applied to the design because none of the '-to' objects specified by the constraint exist in the design 
@N: MT320 :"":0:0:0:-1|This timing report estimates place and route data. Please look at the place and route timing report for final timing..
@W: MT420 :"":0:0:0:-1|Found inferred clock serdes_1_to_n_clk_pll_s2_diff|buf_pll_fb_clk_inferred_clock with period 5.00ns. A user-defined clock should be declared on object "n:gnum_interface_block.cmp_clk_in.buf_pll_fb_clk"
@W: MT420 :"":0:0:0:-1|Found inferred clock serdes_1_to_n_clk_pll_s2_diff|buf_P_clk_inferred_clock with period 5.00ns. A user-defined clock should be declared on object "n:gnum_interface_block.cmp_clk_in.buf_P_clk"
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller.vhd":31:7:31:20|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller.vhd":157:9:157:16|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller.vhd":167:9:167:21|M
@N: CD231 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller.vhd":187:27:187:28|M
@W: CL111 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller.vhd":251:4:251:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller.vhd":327:4:327:5|M
@N: CL201 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller.vhd":327:4:327:5|M
@W: CD604 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller.vhd":444:8:444:21|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":17:7:17:29|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":25:4:25:11|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":177:4:177:5|M
@W: CL111 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":177:4:177:5|M
@W: CL189 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":177:4:177:5|M
@W: CL190 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":177:4:177:5|M
@W: CL190 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":177:4:177:5|M
@W: CL260 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":177:4:177:5|M
@W: CL260 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":177:4:177:5|M
@W: CL260 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":177:4:177:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":474:4:474:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":474:4:474:5|M
@W: BN132 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":474:4:474:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/dma_controller_wb_slave.vhd":474:4:474:5|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/gn4124_core_s6.vhd":41:7:41:17|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/gn4124_core_s6.vhd":72:6:72:15|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/gn4124_core_s6.vhd":75:6:75:13|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/gn4124_core_s6.vhd":91:6:91:15|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/gn4124_core_s6.vhd":183:9:183:16|M
@W: CD326 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/gn4124_core_s6.vhd":337:2:337:11|M
@N: CL135 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/gn4124_core_s6.vhd":746:4:746:5|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_arbiter.vhd":32:7:32:17|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":33:7:33:20|M
@W: CL246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":47:6:47:27|M
@W: CL246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":50:6:50:19|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":54:6:54:25|M
@N: CD231 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":135:26:135:27|M
@A:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":173:4:173:5|M
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":173:4:173:5|M
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":173:4:173:5|M
@W: CL111 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":173:4:173:5|M
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":215:4:215:5|M
@W: CL169 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":215:4:215:5|M
@W: CL190 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":215:4:215:5|M
@W: CL260 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":215:4:215:5|M
@N: FX404 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":226:6:226:7|M
@N: FX404 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":261:25:261:55|M
@N: CL201 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":312:4:312:5|M
@W: CD604 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":472:8:472:21|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: CL177 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@W: CL260 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":544:4:544:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":579:4:579:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_dma_master.vhd":591:4:591:5|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/l2p_ser_s6.vhd":35:7:35:13|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_decode32.vhd":31:7:31:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_decode32.vhd":98:9:98:26|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_decode32.vhd":114:9:114:19|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_decode32.vhd":187:4:187:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_decode32.vhd":187:4:187:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_decode32.vhd":220:4:220:5|M
@N: FX404 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_decode32.vhd":249:6:249:7|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_decode32.vhd":306:4:306:5|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_des_s6.vhd":34:7:34:13|M
@W: CL169 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_des_s6.vhd":136:4:136:5|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":34:7:34:20|M
@W: CL246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":48:6:48:28|M
@W: CL246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":51:6:51:19|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":56:6:56:25|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":63:6:63:23|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":64:6:64:24|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":65:6:65:21|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":73:6:73:16|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":92:6:92:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":137:9:137:24|M
@N: CD231 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":172:28:172:29|M
@N: FX404 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":248:25:248:57|M
@N: CL201 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":272:4:272:5|M
@W: CD604 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":362:8:362:21|M
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":396:4:396:5|M
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":458:4:458:5|M
@W: CL111 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":458:4:458:5|M
@W: CL169 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":458:4:458:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: CL177 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@W: CL190 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@W: CL260 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@W: CL260 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":527:4:527:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":564:4:564:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/p2l_dma_master.vhd":576:4:576:5|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":69:7:69:35|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":81:4:81:11|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":82:4:82:11|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":102:9:102:13|M
@A:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":155:4:155:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":155:4:155:5|M
@W: CL169 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":155:4:155:5|M
@W: CL190 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":155:4:155:5|M
@N: CL201 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":155:4:155:5|M
@W: MT246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":220:2:220:10|M
@W: MT246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":277:2:277:18|M
@W: MT246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":286:2:286:20|M
@W: MT246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":292:2:292:10|M
@W: MT246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd":408:2:408:15|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":74:7:74:30|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":74:7:74:30|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":95:9:95:14|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":95:9:95:14|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":96:9:96:15|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":96:9:96:15|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":97:9:97:13|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":97:9:97:13|M
@W: CL240 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":97:9:97:13|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":101:9:101:13|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":101:9:101:13|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":108:9:108:15|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":108:9:108:15|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":111:9:111:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":111:9:111:18|M
@W: CL240 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":111:9:111:18|M
@W: CD639 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":114:9:114:16|M
@W: CD639 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":114:9:114:16|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":119:9:119:19|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":119:9:119:19|M
@W: CL240 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":119:9:119:19|M
@A:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":141:4:141:5|M
@A:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":141:4:141:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":141:4:141:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":141:4:141:5|M
@W: BN132 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":141:4:141:5|M
@W: CL111 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":141:4:141:5|M
@W: CL189 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":141:4:141:5|M
@N: CL201 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":141:4:141:5|M
@N: CL201 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":141:4:141:5|M
@A:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@A:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@A:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@A:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL111 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL111 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL111 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL169 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL169 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL169 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL169 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL190 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL190 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL190 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL260 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":210:4:210:5|M
@W: CL168 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":395:6:395:14|M
@W: CL168 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd":395:6:395:14|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_diff.vhd":72:7:72:27|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_diff.vhd":88:9:88:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_diff.vhd":89:9:89:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_diff.vhd":90:9:90:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_diff.vhd":91:9:91:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_diff.vhd":92:9:92:16|M
@W: CD639 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_diff.vhd":93:9:93:16|M
@W: CL167 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_diff.vhd":199:6:199:14|M
@W: MT246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_diff.vhd":199:6:199:14|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":72:7:72:25|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":72:7:72:25|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":87:9:87:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":87:9:87:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":88:9:88:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":88:9:88:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":89:9:89:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":89:9:89:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":90:9:90:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":90:9:90:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":91:9:91:16|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":91:9:91:16|M
@W: CD639 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":92:9:92:16|M
@W: CD639 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":92:9:92:16|M
@W: CL167 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":197:6:197:14|M
@W: CL167 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd":197:6:197:14|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":35:7:35:16|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":54:6:54:24|M
@W: CL247 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":61:6:61:18|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":66:6:66:23|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":68:6:68:16|M
@N: CD231 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":133:29:133:30|M
@N: CD231 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":154:33:154:34|M
@N: CL201 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":248:4:248:5|M
@W: CD604 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":285:8:285:21|M
@W: MT246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":302:2:302:15|M
@W: MT246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":323:2:323:17|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@W: CL170 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@N: CL201 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@W: CL260 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":344:4:344:5|M
@W: CD604 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/wbmaster32.vhd":403:8:403:21|M
@W: CD286 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/xilinx_cores/fifo_32x512.vhd":43:7:43:17|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/xilinx_cores/fifo_32x512.vhd":43:7:43:17|M
@W: CD286 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/xilinx_cores/fifo_64x512.vhd":43:7:43:17|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/ip_cores/gnum_core/xilinx_cores/fifo_64x512.vhd":43:7:43:17|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_databus_interface.vhd":28:7:28:28|M
@W: CL246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_databus_interface.vhd":50:8:50:12|M
@W: CL246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_databus_interface.vhd":52:8:52:12|M
@N: CD231 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_databus_interface.vhd":66:40:66:41|M
@N: CL201 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_databus_interface.vhd":68:7:68:18|M
@W: CD604 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_databus_interface.vhd":167:8:167:21|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":27:7:27:32|M
@TM:1312220640
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":76:7:76:16|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":76:7:76:16|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":76:7:76:16|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":76:7:76:16|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":76:7:76:16|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":76:7:76:16|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":77:7:77:16|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":77:7:77:16|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":77:7:77:16|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":77:7:77:16|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":77:7:77:16|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":77:7:77:16|M
@TM:1312220614
@N: CL177 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/acam_timecontrol_interface.vhd":79:7:79:15|M
@TM:1311271088
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":32:7:32:20|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":39:8:39:15|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":40:8:40:19|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":41:8:41:16|M
@W: CL159 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":42:8:42:19|M
@W: CL240 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":51:8:51:21|M
@N: CD231 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":84:24:84:25|M
@N: CL201 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":172:7:172:17|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":178:7:178:21|M
@TM:1312220640
@W: BN132 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":183:7:183:14|M
@TM:1311271088
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":339:8:339:19|M
@W: CD604 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":344:8:344:21|M
@TM:1312220640
@W: BN132 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":382:31:382:42|M
@TM:1311271088
@N: FX276 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/clk_rst_managr.vhd":390:41:390:50|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/countdown_counter.vhd":17:7:17:23|M
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/countdown_counter.vhd":37:7:37:11|M
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/countdown_counter.vhd":37:7:37:11|M
@TM:1312220614
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/data_formatting.vhd":28:7:28:21|M
@W: CL247 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/data_formatting.vhd":34:8:34:23|M
@W: CL246 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/data_formatting.vhd":38:8:38:24|M
@W: CL111 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/data_formatting.vhd":61:7:61:20|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/data_formatting.vhd":64:7:64:14|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/free_counter.vhd":15:7:15:18|M
@TM:1312220640
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/free_counter.vhd":35:7:35:11|M
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/free_counter.vhd":35:7:35:11|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/free_counter.vhd":35:7:35:11|M
@TM:1312220614
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/incr_counter.vhd":16:7:16:18|M
@TM:1312220640
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/incr_counter.vhd":36:7:36:11|M
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/incr_counter.vhd":36:7:36:11|M
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/incr_counter.vhd":36:7:36:11|M
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/incr_counter.vhd":36:7:36:11|M
@A: BN291 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/incr_counter.vhd":36:7:36:11|M
@TM:1312220614
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/one_hz_gen.vhd":27:7:27:16|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/start_retrigger_control.vhd":31:7:31:29|M
@TM:1312220640
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/start_retrigger_control.vhd":85:4:85:22|M
@TM:1312220614
@N:  :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":29:7:29:13|M
@N: CD630 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":29:7:29:13|M
@W: CL240 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":60:8:60:14|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":353:7:353:20|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":361:7:361:12|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":366:7:366:19|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":367:7:367:19|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":368:7:368:19|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":369:7:369:19|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":370:7:370:19|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":376:7:376:18|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":377:7:377:20|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":378:7:378:26|M
@W: CL240 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":378:7:378:26|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":385:7:385:21|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":386:7:386:22|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":397:7:397:11|M
@W: CL240 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":397:7:397:11|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":414:7:414:15|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":415:7:415:13|M
@W: CL240 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":415:7:415:13|M
@W: CD638 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":416:7:416:15|M
@W: CL240 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":416:7:416:15|M
@TM:1312220640
@N: BN116 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":441:4:441:24|M
@TM:1312220614
@W: CL168 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":456:4:456:24|M
@W: CL167 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":530:4:530:23|M
@W: CL167 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":530:4:530:23|M
@W: CL245 :"/afs/cern.ch/eng/eda/cds_users/gfernand/projects/tdc/src/rtl/top_tdc.vhd":530:4:530:23|M
@N: CD720 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/vhd/std.vhd":123:18:123:21|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":428:10:428:13|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":583:10:583:15|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":599:10:599:17|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":636:10:636:15|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":6062:10:6062:13|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":6077:10:6077:15|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":6266:10:6266:14|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":9014:10:9014:17|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":9185:10:9185:17|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":10943:10:10943:13|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":10957:10:10957:15|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":14184:10:14184:17|M
@N: CD630 :"/afs/cern.ch/project/parc/elec/synplify/D-2010.03/lib/xilinx/unisim.vhd":16190:10:16190:16|M
