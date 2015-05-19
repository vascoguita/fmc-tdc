sim_tool = "modelsim"
top_module="main"
syn_device="xc6slx45t"

action = "simulation"
target = "xilinx"
fetchto = "../../ip_cores"
include_dirs=[ "../../sim", "../include", "../../ip_cores/gn4124-core/hdl/gn4124core/sim/gn4124_bfm" ]

files = [ "main.sv" ]

modules = { "local" :  [ "../../top/spec", "../../ip_cores/gn4124-core/hdl/gn4124core/sim/gn4124_bfm" ] }

