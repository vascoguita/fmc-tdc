sim_tool = "modelsim"
top_module="main"
syn_device="xc6slx45t"
sim_top="main"

if locals().get('fetchto', None) is None:
  fetchto = "../../ip_cores"

action = "simulation"
target = "xilinx"
include_dirs=[ "../../sim", "../include"  ]
vcom_opt = "-mixedsvvh l"

# For wr-cores
board='spec'

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
    "sourceid_wr_spec_tdc_pkg.vhd",
]


modules = {
  "local" :  [
    "../../top/spec",
    fetchto + "/gn4124-core/hdl/sim/gn4124_bfm"
  ],
  "git" : [
    "https://ohwr.org/project/wr-cores.git",
    "https://ohwr.org/project/general-cores.git",
    "https://ohwr.org/project/gn4124-core.git",
    "https://ohwr.org/project/ddr3-sp6-core.git",
  ],
  "system": ['xilinx']
}

ctrls = ["bank3_32b_32b"]

# Do not fail during hdlmake fetch
try:
  exec(open(fetchto + "/general-cores/tools/gen_buildinfo.py").read())
except:
  pass

try:
    # Assume this module is in fact a git submodule of a main project that
    # is in the same directory as general-cores...
    exec(open(fetchto + "/general-cores/tools/gen_sourceid.py").read(),
         None, {'project': 'wr_spec_tdc'})
except Exception as e:
    print("Error: cannot generate source id file")
    raise
