sim_tool = "modelsim"
top_module="main"
syn_device="xc6slx45t"
sim_top="main"

action = "simulation"
target = "xilinx"
fetchto = "../../ip_cores"
include_dirs=[ "../../sim", "../include"  ]
vcom_opt = "-mixedsvvh l"

include_dirs = [
    "../include",
    "../../sim",
    fetchto + "/gn4124-core/hdl/sim/gn4124_bfm",
    fetchto + "/general-cores/sim",
    fetchto + "/general-cores/modules/wishbone/wb_lm32/src",
    fetchto + "/wr-cores/sim",
    fetchto + "/ddr3-sp6-core/hdl/sim/",
    fetchto + "/general-cores/modules/wishbone/wb_spi",
]

files = [
    "main.sv",
    "buildinfo_pkg.vhd",
]


modules = { "local" :  [ "../../top/spec", "../../ip_cores/gn4124-core/hdl/sim/gn4124_bfm" ] }

ctrls = ["bank3_32b_32b"]

# Do not fail during hdlmake fetch
try:
  exec(open(fetchto + "/general-cores/tools/gen_buildinfo.py").read())
except:
  pass