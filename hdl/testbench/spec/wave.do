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
WaveRestoreZoom {13870017 ps} {15197065 ps}
