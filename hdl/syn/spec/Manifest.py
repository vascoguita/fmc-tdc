board  = "spec"
target = "xilinx"
action = "synthesis"

fetchto = "../../ip_cores"

syn_device = "xc6slx45t"
syn_grade = "-3"
syn_package = "fgg484"
syn_top = "wr_spec_tdc"
syn_project = "wr_spec_tdc.xise"
syn_tool = "ise"
top_module = "wr_spec_tdc"

files = ["buildinfo_pkg.vhd"]


modules = { "local" : [ "../../top/spec" ] }

# Do not fail during hdlmake fetch
try:
  exec(open(fetchto + "/general-cores/tools/gen_buildinfo.py").read())
except:
  pass

syn_post_project_cmd = "$(TCL_INTERPRETER) syn_extra_steps.tcl $(PROJECT_FILE)"

spec_base_ucf = ['wr', 'ddr3', 'onewire', 'spi']

ctrls = ["bank3_32b_32b"]
