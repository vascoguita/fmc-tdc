target = "xilinx"
action = "synthesis"

fetchto = "../../ip_cores"

syn_device = "xc6slx150t"
syn_grade = "-3"
syn_package = "fgg900"
syn_top = "wr_svec_tdc"
syn_project = "wr_svec_tdc.xise"
syn_tool = "ise"

# Allow the user to override fetchto using:
#  hdlmake -p "fetchto='xxx'"
if locals().get('fetchto', None) is None:
    fetchto = "../../ip_cores"

files = [
    "buildinfo_pkg.vhd",
]

modules = {
    "local" : [
        "../../top/svec",
    ],
}

# Do not fail during hdlmake fetch
try:
  exec(open(fetchto + "/general-cores/tools/gen_buildinfo.py").read())
except:
  pass

syn_post_project_cmd = "$(TCL_INTERPRETER) syn_extra_steps.tcl $(PROJECT_FILE)"

svec_base_ucf = ['wr', 'led', 'gpio']

ctrls = ["bank4_64b_32b", "bank5_64b_32b"]
