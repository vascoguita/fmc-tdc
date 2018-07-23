sim_tool = "modelsim"
top_module="main"
syn_device="xc6slx45t"
sim_top="main"

action = "simulation"
target = "xilinx"
fetchto = "../../ip_cores"
include_dirs=[ "../../sim", "../include"  ]
vcom_opt = "-mixedsvvh l"
files = [ "main.sv" ]

modules = { "local" :  [ "../../top/spec", "../../ip_cores/gn4124-core/hdl/gn4124core/sim/gn4124_bfm" ] }

ctrls = ["bank3_32b_32b"]