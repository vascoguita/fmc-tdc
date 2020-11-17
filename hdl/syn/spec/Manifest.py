board  = "spec"
target = "xilinx"
action = "synthesis"

if locals().get('fetchto', None) is None:
  fetchto = "../../ip_cores"

syn_device = "xc6slx45t"
syn_grade = "-3"
syn_package = "fgg484"
syn_top = "wr_spec_tdc"
syn_project = "wr_spec_tdc.xise"
syn_tool = "ise"
#syn_tool = "planahead"
top_module = "wr_spec_tdc"

files = ["buildinfo_pkg.vhd", "sourceid_wr_spec_tdc_pkg.vhd"]

modules = { "local" : [ "../../top/spec" ] }

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

syn_post_project_cmd = "$(TCL_INTERPRETER) syn_extra_steps.tcl $(PROJECT_FILE)"

spec_base_ucf = ['wr', 'ddr3', 'onewire', 'spi']

ctrls = ["bank3_32b_32b"]
