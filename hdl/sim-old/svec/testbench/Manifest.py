action = "simulation"
target = "xilinx"
fetchto = "../../ip_cores"
vlog_opt="+incdir+../../sim/wb +incdir+../../sim/vme64x_bfm +incdir+../../sim"

files = [ "main.sv" ]

modules = { "local" :  [ "../../top/svec" ] }

