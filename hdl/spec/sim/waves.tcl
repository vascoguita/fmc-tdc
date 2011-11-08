probe -create -shm -waveform :dut:acam_refclk
probe -create -shm -waveform :spec_clk_i
probe -create -shm -waveform :dut:clk
probe -create -shm -waveform :dut:gnum_reset
probe -create -shm -waveform :dut:general_reset

#probe -create -shm -waveform :dut:clks_rsts_mgment:pll_sclk_o
#probe -create -shm -waveform :dut:clks_rsts_mgment:pll_sdi_o
#probe -create -shm -waveform :dut:clks_rsts_mgment:pll_cs_o
#probe -create -shm -waveform :dut:clks_rsts_mgment:bit_index
#probe -create -shm -waveform :dut:clks_rsts_mgment:byte_index
##probe -create -shm -waveform :dut:clks_rsts_mgment:bit_being_sent
#probe -create -shm -waveform :dut:clks_rsts_mgment:word_being_sent
#probe -create -shm -waveform :dut:clks_rsts_mgment:pll_init_st
##probe -create -shm -waveform :dut:clks_rsts_mgment:nxt_pll_init_st
#probe -create -shm -waveform :dut:clks_rsts_mgment:gral_incr
#probe -create -shm -waveform :dut:clks_rsts_mgment:general_poreset:current_value


#probe -create -shm -waveform :spec_led_green
#probe -create -shm -waveform :spec_led_red
#probe -create -shm -waveform :tdc_led_status
#probe -create -shm -waveform :dut:tdc_led_count_done
#probe -create -shm -waveform :dut:spec_led_count_done

#probe -create -shm -waveform :dut:one_second_block:refclk_edge
#probe -create -shm -waveform :dut:one_second_block:onesec_counter_en
#probe -create -shm -waveform :dut:one_second_block:clock_periods_counter:current_value
#probe -create -shm -waveform :dut:one_second_block:total_delay
#probe -create -shm -waveform :dut:one_second_block:pulse_delayer_counter:current_value
#probe -create -shm -waveform :dut:one_second_block:one_hz_p_pre
#probe -create -shm -waveform :dut:one_second_block:one_hz_p_post
probe -create -shm -waveform :dut:one_second_block:one_hz_p_o
probe -create -shm -waveform :dut:int_flag_i
probe -create -shm -waveform :dut:acam_fall_intflag_p

#probe -create -shm -waveform :dut:start_retrigger_block:roll_over_reset
#probe -create -shm -waveform :dut:start_retrigger_block:add_roll_over
probe -create -shm -waveform :dut:start_retrigger_block:roll_over_value
#probe -create -shm -waveform :dut:start_retrigger_block:retrig_nb_reset
probe -create -shm -waveform :dut:start_retrigger_block:current_retrig_nb
#probe -create -shm -waveform :dut:start_retrigger_block:retrig_period_reset
probe -create -shm -waveform :dut:start_retrigger_block:retrig_p
probe -create -shm -waveform :dut:start_retrigger_block:current_cycles

probe -create -shm -waveform :dut:start_retrigger_block:clk_cycles_offset
probe -create -shm -waveform :dut:start_retrigger_block:retrig_nb_offset

probe -create -shm -waveform :dut:start_trig
probe -create -shm -waveform :dut:acam_timing_block:start_trig_edge
probe -create -shm -waveform :dut:acam_timing_block:window_delay
#probe -create -shm -waveform :dut:acam_timing_block:waitingfor_refclk
probe -create -shm -waveform :dut:acam_timing_block:refclk_edge
probe -create -shm -waveform :dut:acam_timing_block:window_prepulse
#probe -create -shm -waveform :dut:acam_timing_block:start_trig_received
#probe -create -shm -waveform :dut:acam_timing_block:counter_reset
#probe -create -shm -waveform :dut:acam_timing_block:window_active
#probe -create -shm -waveform :dut:acam_timing_block:counter_value
#probe -create -shm -waveform :start_dis_o
probe -create -shm -waveform :start_from_fpga_o
#probe -create -shm -waveform :stop_dis_o

#probe -create -shm -waveform :acam:timing_block:start01
#probe -create -shm -waveform :acam:timing_block:start_retrig_p
#probe -create -shm -waveform :acam:timing_block:start_retrig_nb

#probe -create -shm -waveform :dut:acam_timing_block:int_flag_i
#probe -create -shm -waveform :dut:start_retrigger_block:acam_fall_intflag_p_i
#probe -create -shm -waveform :dut:start_retrigger_block:acam_rise_intflag_p_i
#probe -create -shm -waveform :dut:start_retrigger_block:acam_halfcounter_gone
#probe -create -shm -waveform :dut:start_retrigger_block:add_offset
#probe -create -shm -waveform :dut:start_retrigger_block:start_nb_offset_o

probe -create -shm -waveform :tstop1
probe -create -shm -waveform :tstop2
probe -create -shm -waveform :tstop3
probe -create -shm -waveform :tstop4
probe -create -shm -waveform :tstop5

probe -create -shm -waveform :dut:data_formatting_block:local_utc
probe -create -shm -waveform :dut:data_formatting_block:coarse_time
probe -create -shm -waveform :dut:data_formatting_block:fine_time

#probe -create -shm -waveform :RSTINn             
#probe -create -shm -waveform :RSTOUT18n          
#probe -create -shm -waveform :RSTOUT33n          
#probe -create -shm -waveform :LCLK
#probe -create -shm -waveform :LCLKn        

probe -create -shm -waveform :P2L_CLKp
#probe -create -shm -waveform :P2L_CLKn 
probe -create -shm -waveform :P2L_DATA           
#probe -create -shm -waveform :P2L_DATA_32        
probe -create -shm -waveform :P2L_DFRAME         
probe -create -shm -waveform :P2L_VALID          
#probe -create -shm -waveform :P2L_RDY            
#probe -create -shm -waveform :P_WR_REQ           
#probe -create -shm -waveform :P_WR_RDY           
probe -create -shm -waveform :RX_ERROR           
#probe -create -shm -waveform :VC_RDY             
probe -create -shm -waveform :L2P_CLKp
#probe -create -shm -waveform :L2P_CLKn 
probe -create -shm -waveform :L2P_DATA           
#probe -create -shm -waveform :L2P_DATA_32        
probe -create -shm -waveform :L2P_DFRAME         
probe -create -shm -waveform :L2P_VALID          
#probe -create -shm -waveform :L2P_EDB            
#probe -create -shm -waveform :L2P_RDY            
#probe -create -shm -waveform :L_WR_RDY           
#probe -create -shm -waveform :P_RD_D_RDY         
probe -create -shm -waveform :TX_ERROR           
#probe -create -shm -waveform :GPIO               

probe -create -shm -waveform :dut:clk

probe -create -shm -waveform :dut:csr_clk
probe -create -shm -waveform :dut:csr_adr
probe -create -shm -waveform :dut:csr_cyc
probe -create -shm -waveform :dut:csr_we
probe -create -shm -waveform :dut:csr_stb
probe -create -shm -waveform :dut:csr_ack
probe -create -shm -waveform :dut:csr_dat_r
probe -create -shm -waveform :dut:csr_dat_w
#probe -create -shm -waveform :dut:csr_sel

probe -create -shm -waveform :dut:acam_config
probe -create -shm -waveform :dut:acam_config_rdbk
#probe -create -shm -waveform :dut:reg_control_block:control_register

probe -create -shm -waveform :dut:activate_acq
probe -create -shm -waveform :dut:deactivate_acq
probe -create -shm -waveform :dut:load_acam_config
probe -create -shm -waveform :dut:read_acam_config
probe -create -shm -waveform :dut:read_acam_status
probe -create -shm -waveform :dut:reset_acam

probe -create -shm -waveform :dut:data_engine_block:engine_st
probe -create -shm -waveform :dut:acm_adr
probe -create -shm -waveform :dut:acm_cyc
probe -create -shm -waveform :dut:acm_dat_w
probe -create -shm -waveform :dut:acm_stb
probe -create -shm -waveform :dut:acm_we
probe -create -shm -waveform :dut:acm_ack
probe -create -shm -waveform :dut:acm_dat_r
#probe -create -shm -waveform :dut:acam_data_block:acam_data_st
#probe -create -shm -waveform :dut:acam_data_block:nxt_acam_data_st

probe -create -shm -waveform :dut:ef1_i
probe -create -shm -waveform :dut:ef2_i
probe -create -shm -waveform :dut:lf1_i
probe -create -shm -waveform :dut:lf2_i
probe -create -shm -waveform :dut:data_bus_io
probe -create -shm -waveform :dut:address_o
probe -create -shm -waveform :dut:cs_n_o
probe -create -shm -waveform :dut:oe_n_o
probe -create -shm -waveform :dut:rd_n_o
probe -create -shm -waveform :dut:wr_n_o
waveform format -using "Waveform 1" ":dut:rd_n_o" -color "red"
probe -create -shm -waveform :dut:acam_data_block:acam_data_st
#probe -create -shm -waveform :dut:acam_data_block:wr_extend
#probe -create -shm -waveform :dut:acam_data_block:wr_remove
#probe -create -shm -waveform :dut:acam_data_block:wr
waveform format -using "Waveform 1" ":dut:wr_n_o" -color "magenta"

probe -create -shm -waveform :dut:acam_timestamp1
probe -create -shm -waveform :dut:acam_timestamp1_valid
probe -create -shm -waveform :dut:acam_timestamp2
probe -create -shm -waveform :dut:acam_timestamp2_valid

probe -create -shm -waveform :dut:data_formatting_block:metadata
probe -create -shm -waveform :dut:data_formatting_block:local_utc
probe -create -shm -waveform :dut:data_formatting_block:coarse_time
probe -create -shm -waveform :dut:data_formatting_block:fine_time

probe -create -shm -waveform :dut:data_formatting_block:wr_pointer
probe -create -shm -waveform :dut:wr_pointer

probe -create -shm -waveform :dut:mem_class_adr
probe -create -shm -waveform :dut:mem_class_cyc
probe -create -shm -waveform :dut:mem_class_we
probe -create -shm -waveform :dut:mem_class_stb
probe -create -shm -waveform :dut:mem_class_ack
probe -create -shm -waveform :dut:mem_class_dat_r
probe -create -shm -waveform :dut:mem_class_dat_w

probe -create -shm -waveform :dut:circular_buffer_block:class_adr
probe -create -shm -waveform :dut:circular_buffer_block:class_data_wr
probe -create -shm -waveform :dut:circular_buffer_block:class_data_rd
probe -create -shm -waveform :dut:circular_buffer_block:class_we
probe -create -shm -waveform :dut:circular_buffer_block:class_en

probe -create -shm -waveform :dut:circular_buffer_block:wb_pipelined_st
probe -create -shm -waveform :dut:circular_buffer_block:pipe_adr
probe -create -shm -waveform :dut:circular_buffer_block:pipe_data_rd
probe -create -shm -waveform :dut:circular_buffer_block:pipe_we
probe -create -shm -waveform :dut:circular_buffer_block:pipe_en

probe -create -shm -waveform :dut:dma_clk
probe -create -shm -waveform :dut:dma_adr
probe -create -shm -waveform :dut:dma_cyc
probe -create -shm -waveform :dut:dma_we
probe -create -shm -waveform :dut:dma_stb
probe -create -shm -waveform :dut:dma_ack
probe -create -shm -waveform :dut:dma_dat_r
probe -create -shm -waveform :dut:dma_dat_w
#probe -create -shm -waveform :dut:dma_sel
probe -create -shm -waveform :dut:gnum_interface_block:cmp_dma_controller:dma_ctrl_current_state

#probe -create -shm -waveform :acam:data_block:interface_fifo1:wr_pointer
#probe -create -shm -waveform :acam:data_block:interface_fifo1:rd_pointer
#probe -create -shm -waveform :acam:data_block:interface_fifo1:level

#probe -create -shm -waveform :acam:data_block:wr_falling_time
#probe -create -shm -waveform :acam:data_block:wr_rising_time

#probe -create -shm -waveform :pulses_generator:pulse_channel
#probe -create -shm -waveform :pulses_generator:sequence:pulse_ch

#probe -create -shm -waveform :acam:timing_block:timestamp_for_fifo1
#probe -create -shm -waveform :acam:timing_block:timestamp_for_fifo2
#probe -create -shm -waveform :acam:timing_block:tstart
#probe -create -shm -waveform :acam:timing_block:tstop1
#probe -create -shm -waveform :acam:timing_block:tstop2
#probe -create -shm -waveform :acam:timing_block:tstop3
#probe -create -shm -waveform :acam:timing_block:tstop4
#probe -create -shm -waveform :acam:timing_block:tstop5

#probe -create -shm -waveform :acam:data_block:interface_fifo1:fifo
#probe -create -shm -waveform :acam:data_block:interface_fifo1:fifo[0]
#probe -create -shm -waveform :acam:data_block:interface_fifo1:fifo[1]
#probe -create -shm -waveform :acam:data_block:interface_fifo1:fifo[2]
#probe -create -shm -waveform :acam:data_block:interface_fifo1:fifo[3]
#probe -create -shm -waveform :acam:data_block:interface_fifo1:fifo[4]

#probe -create -shm -waveform :acam:data_block:interface_fifo2:fifo
#probe -create -shm -waveform :acam:data_block:interface_fifo2:fifo[0]
#probe -create -shm -waveform :acam:data_block:interface_fifo2:fifo[1]
#probe -create -shm -waveform :acam:data_block:interface_fifo2:fifo[2]
#probe -create -shm -waveform :acam:data_block:interface_fifo2:fifo[3]
#probe -create -shm -waveform :acam:data_block:interface_fifo2:fifo[4]

#probe -create -shm -waveform :acam:timing_block:start_trig

#probe -create -shm -waveform :acam:timing_block:stop1_trig
#probe -create -shm -waveform :acam:timing_block:stop1

#probe -create -shm -waveform :acam:timing_block:stop2_trig
#probe -create -shm -waveform :acam:timing_block:stop2

#probe -create -shm -waveform :acam:timing_block:stop3_trig
#probe -create -shm -waveform :acam:timing_block:stop3

#probe -create -shm -waveform :acam:timing_block:stop4_trig
#probe -create -shm -waveform :acam:timing_block:stop4

#probe -create -shm -waveform :acam:timing_block:stop5_trig
#probe -create -shm -waveform :acam:timing_block:stop5


#probe -create -shm -waveform :acam:timing_block:start_nb1
#probe -create -shm -waveform :acam:timing_block:start_nb2
#probe -create -shm -waveform :acam:timing_block:start_nb3
#probe -create -shm -waveform :acam:timing_block:start_nb4
#probe -create -shm -waveform :acam:timing_block:start_nb5


#set intovf_severity_level warning

#run 1400 us
run 5 ms
