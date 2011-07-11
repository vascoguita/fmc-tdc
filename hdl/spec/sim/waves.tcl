probe -create -shm -waveform :spec_clk_i
probe -create -shm -waveform :dut:por_reset
probe -create -shm -waveform :dut:internal_reset
probe -create -shm -waveform :dut:clk
probe -create -shm -waveform :dut:acam_refclk
probe -create -shm -waveform :dut:gnum_reset
probe -create -shm -waveform :dut:general_reset

#probe -create -shm -waveform :dut:clocks_and_resets_management_block:half_clk
probe -create -shm -waveform :dut:clocks_and_resets_management_block:cs
#probe -create -shm -waveform :dut:clocks_and_resets_management_block:bit_index
probe -create -shm -waveform :dut:clocks_and_resets_management_block:byte_index
probe -create -shm -waveform :dut:clocks_and_resets_management_block:bit_being_sent
probe -create -shm -waveform :dut:clocks_and_resets_management_block:byte_being_sent
probe -create -shm -waveform :dut:clocks_and_resets_management_block:pll_init_st
probe -create -shm -waveform :dut:clocks_and_resets_management_block:gral_incr
probe -create -shm -waveform :dut:clocks_and_resets_management_block:inv_reset
probe -create -shm -waveform :dut:clocks_and_resets_management_block:general_power_on_reset:current_value

#probe -create -shm -waveform :dut:clocks_and_resets_management_block:nxt_pll_init_st

probe -create -shm -waveform :spec_led_green
probe -create -shm -waveform :spec_led_red
probe -create -shm -waveform :tdc_led_status
probe -create -shm -waveform :dut:tdc_led_count_done
probe -create -shm -waveform :dut:spec_led_count_done

#probe -create -shm -waveform :RSTINn             
#probe -create -shm -waveform :RSTOUT18n          
#probe -create -shm -waveform :RSTOUT33n          
#probe -create -shm -waveform :LCLK
#probe -create -shm -waveform :LCLKn        

probe -create -shm -waveform :P2L_CLKp
probe -create -shm -waveform :P2L_CLKn 
probe -create -shm -waveform :P2L_DATA           
probe -create -shm -waveform :P2L_DATA_32        
probe -create -shm -waveform :P2L_DFRAME         
probe -create -shm -waveform :P2L_VALID          
probe -create -shm -waveform :P2L_RDY            
probe -create -shm -waveform :P_WR_REQ           
probe -create -shm -waveform :P_WR_RDY           
probe -create -shm -waveform :RX_ERROR           
probe -create -shm -waveform :VC_RDY             
#probe -create -shm -waveform :L2P_CLKp, L2P_CLKn 
#probe -create -shm -waveform :L2P_DATA           
#probe -create -shm -waveform :L2P_DATA_32        
#probe -create -shm -waveform :L2P_DFRAME         
#probe -create -shm -waveform :L2P_VALID          
#probe -create -shm -waveform :L2P_EDB            
#probe -create -shm -waveform :L2P_RDY            
#probe -create -shm -waveform :L_WR_RDY           
#probe -create -shm -waveform :P_RD_D_RDY         
#probe -create -shm -waveform :TX_ERROR           
probe -create -shm -waveform :GPIO               

#probe -create -shm -waveform :dut:acm_adr
#probe -create -shm -waveform :dut:acm_cyc
#probe -create -shm -waveform :dut:acm_dat_w
#probe -create -shm -waveform :dut:acm_stb
#probe -create -shm -waveform :dut:acm_we
#probe -create -shm -waveform :dut:acm_ack
#probe -create -shm -waveform :dut:acm_dat_r

probe -create -shm -waveform :dut:csr_clk
probe -create -shm -waveform :dut:csr_cyc
probe -create -shm -waveform :dut:csr_sel
probe -create -shm -waveform :dut:csr_adr
probe -create -shm -waveform :dut:csr_dat_r
probe -create -shm -waveform :dut:csr_dat_w
probe -create -shm -waveform :dut:csr_stb
probe -create -shm -waveform :dut:csr_ack
probe -create -shm -waveform :dut:csr_we

probe -create -shm -waveform :dut:acam_data_block:acam_data_st
probe -create -shm -waveform :dut:acam_data_block:nxt_acam_data_st

probe -create -shm -waveform :dut:data_bus_io
probe -create -shm -waveform :dut:address_o
probe -create -shm -waveform :dut:cs_n_o
probe -create -shm -waveform :dut:oe_n_o
probe -create -shm -waveform :dut:rd_n_o
probe -create -shm -waveform :dut:wr_n_o

#probe -create -shm -waveform :acam:data_block:wr_falling_time
#probe -create -shm -waveform :acam:data_block:wr_rising_time

#probe -create -shm -waveform :dut:one_second_block:acam_refclk_i
#probe -create -shm -waveform :dut:one_second_block:s_acam_refclk
#probe -create -shm -waveform :dut:one_second_block:refclk_edge
#probe -create -shm -waveform :dut:one_second_block:onesec_counter_en
#probe -create -shm -waveform :dut:one_second_block:total_delay
#probe -create -shm -waveform :dut:one_second_block:one_hz_p_pre
#probe -create -shm -waveform :dut:one_second_block:one_hz_p_post
probe -create -shm -waveform :dut:one_second_block:one_hz_p_o

#probe -create -shm -waveform :dut:acam_timing_block:counter_reset
#probe -create -shm -waveform :dut:acam_timing_block:window_inverted
#probe -create -shm -waveform :dut:acam_timing_block:start_window
#probe -create -shm -waveform :dut:acam_timing_block:start_dis_o

#probe -create -shm -waveform :dut:acam_timing_block:int_flag_i
#probe -create -shm -waveform :dut:start_nb_block:acam_irflag_p_i
#probe -create -shm -waveform :dut:start_nb_block:start_nb_offset_o

#probe -create -shm -waveform :start_dis_o
probe -create -shm -waveform :start_from_fpga_o
probe -create -shm -waveform :acam_refclk_i
#probe -create -shm -waveform :stop_dis_o

probe -create -shm -waveform :tstop1
probe -create -shm -waveform :tstop2
probe -create -shm -waveform :tstop3
probe -create -shm -waveform :tstop4
probe -create -shm -waveform :tstop5
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

probe -create -shm -waveform :acam:timing_block:start01
probe -create -shm -waveform :acam:timing_block:start_retrig_p
probe -create -shm -waveform :acam:timing_block:start_retrig_nb
#probe -create -shm -waveform :acam:timing_block:int_flag_o

#probe -create -shm -waveform :acam:timing_block:start_nb1
#probe -create -shm -waveform :acam:timing_block:start_nb2
#probe -create -shm -waveform :acam:timing_block:start_nb3
#probe -create -shm -waveform :acam:timing_block:start_nb4
#probe -create -shm -waveform :acam:timing_block:start_nb5


set intovf_severity_level warning

run 1 ms
