files = ["synthesis_descriptor.vhd",
"wr_spec_tdc.ucf",
"wr_spec_tdc.vhd"];

fetchto = "../../ip_cores"

modules = {
    "local" : [	"../../rtl/", 
		"../../ip_cores/general-cores",
		"../../ip_cores/gn4124-core",
		"../../ip_cores/wr-cores",
       "../../ip_cores/wr-cores/board/spec",
       "../../ip_cores/ddr3-sp6-core",
       "../../ip_cores/spec"
	    ]
    }

