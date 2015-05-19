files = ["synthesis_descriptor.vhd",
"wr_spec_tdc.ucf",
"wr_spec_tdc.vhd"];

fetchto = "../../ip_cores"

modules = {
    "local" : [	"../../rtl/", 
		"../../ip_cores/gn4124-core",
		"../../ip_cores/general-cores",
		"../../ip_cores/wr-cores"
	    ]
    }

