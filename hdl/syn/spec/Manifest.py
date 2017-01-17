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

modules = { "local" : [ "../../top/spec" ] }