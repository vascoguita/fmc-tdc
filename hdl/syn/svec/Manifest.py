board  = "svec"
target = "xilinx"
action = "synthesis"

fetchto = "../../ip_cores"

syn_device = "xc6slx150t"
syn_grade = "-3"
syn_package = "fgg900"
syn_top = "wr_svec_tdc"
syn_project = "wr_svec_tdc.xise"
syn_tool = "ise"
#top_module = "wr_svec_tdc"

files = ["buildinfo_pkg.vhd",
         "sourceid_wr_svec_tdc_pkg.vhd",
         "svec-tdc0.ucf",
         "svec-tdc1.ucf",
         "wr_svec_tdc.ucf",]

modules = { "local" : [ "../../top/svec" ] }

# Do not fail during hdlmake fetch
try:
  exec(open(fetchto + "/general-cores/tools/gen_buildinfo.py").read())
except:
  pass

try:
    # Assume this module is in fact a git submodule of a main project that
    # is in the same directory as general-cores...
    exec(open(fetchto + "/general-cores/tools/gen_sourceid.py").read(),
         None, {'project': 'wr_svec_tdc'})
except Exception as e:
    print("Error: cannot generate source id file")
    raise

syn_post_project_cmd = "$(TCL_INTERPRETER) syn_extra_steps.tcl $(PROJECT_FILE)"

svec_base_ucf = ['wr', 'led', 'gpio']

ctrls = ["bank4_64b_32b", "bank5_64b_32b"]
