ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/gn4124_core_pkg_s6.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/xilinx_cores/fifo_32x512.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/xilinx_cores/fifo_64x512.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/serdes_n_to_1_s2_diff.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/serdes_n_to_1_s2_se.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/l2p_ser_s6.vhd
ncvhdl -controlrelax NLSTEX -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/serdes_1_to_n_data_s2_se.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/p2l_des_s6.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/serdes_1_to_n_clk_pll_s2_diff.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/p2l_decode32.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/wbmaster32.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/dma_controller_wb_slave.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/dma_controller.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/l2p_dma_master.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/p2l_dma_master.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/l2p_arbiter.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/gnum_core/gn4124_core_s6.vhd

ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/tdc_core_pkg.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/free_counter.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/incr_counter.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/countdown_counter.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/clk_rst_managr.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/one_hz_gen.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/start_retrigger_control.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/data_formatting.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/data_engine.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/acam_timecontrol_interface.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/acam_databus_interface.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/mem_core/blk_mem_circ_buff_v6_4.vhd
#ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/ip_cores/mem_core/reg_mem_gen_v6_2.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/circular_buffer.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/reg_ctrl.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/data_engine.vhd

ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/top_tdc.vhd
#ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/test_tdc_acam/top_test_acam.vhd
#ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/rtl/test_tdc_pll/top_test_pll.vhd

ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/gnum_model/util.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/gnum_model/textutil.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/gnum_model/mem_model.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/gnum_model/cmd_router1.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/gnum_model/cmd_router.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/gnum_model/gn412x_bfm.vhd

ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/acam_timing_model.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/acam_fifo_model.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/acam_data_model.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/acam_model.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/start_stop_gen.vhd
ncvhdl -nocopyright -nolog -messages -linedebug -v93 -cdslib ./cds.lib -work worklib ../src/test_bench/tb_tdc.vhd

ncelab -nocopyright -nolog -messages -access +wc -messages -v93 -cdslib ./cds.lib -work worklib worklib.tb_tdc:behavioral
#ncelab -nocopyright -nolog -messages -access +wc -messages -v93 -cdslib ./cds.lib -work worklib worklib.tdc_top:rtl
#ncsim -gui -cdslib ./cds.lib -nocopyright -nolog -nokey worklib.tb_tdc:behavioral -input waves.tcl
