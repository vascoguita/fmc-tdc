action = "simulation"
target = "xilinx"
fetchto = "../../ip_cores"
vlog_opt="+incdir+../../sim +incdir+../include/vme64x_bfm +incdir+../include "

files = [ "main.sv" ]

modules = { "local" :  [ "../../top/svec" ] }

