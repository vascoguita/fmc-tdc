onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/clk_i
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/rst_i
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/int_flag_i
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/int_flag_delay_i
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/utc_p_i
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/current_retrig_nb_o
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/roll_over_incr_recent_o
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/clk_i_cycles_offset_o
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/roll_over_nb_o
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/retrig_nb_offset_o
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/clk_i_cycles_offset
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/current_cycles
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/current_cycles2
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/current_retrig_nb
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/current_retrig_nb2
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/retrig_nb_offset
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/retrig_p
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/roll_over_c
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/roll_over_c2
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/int_flag_r
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/int_flag_f
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/int_flag
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/int_flag_d
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/int_flag_p
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/retrig_cnt
add wave -noupdate -expand -group retrig /main/DUT/cmp_tdc_mezzanine/cmp_tdc_mezz/cmp_tdc_core/start_retrigger_block/retrig_p2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {133152732 ps} 0}
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
WaveRestoreZoom {634062951 ps} {634126951 ps}
