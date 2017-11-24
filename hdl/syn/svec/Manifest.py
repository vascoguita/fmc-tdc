target = "xilinx"
action = "synthesis"

fetchto = "../../ip_cores"

syn_device = "xc6slx150t"
syn_grade = "-3"
syn_package = "fgg900"
syn_top = "wr_svec_tdc"
syn_project = "wr_svec_tdc.xise"
syn_tool = "ise"

modules = { "local" : [ "../../top/svec" ] }
