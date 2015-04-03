files = ["synthesis_descriptor.vhd",
"wr_svec_tdc.ucf",
"wr_svec_tdc.vhd"];

fetchto = "../../ip_cores"

modules = {
    "local" : [	"../../rtl/", 
		"../../ip_cores/vme64x-core",
		"../../ip_cores/general-cores",
		"../../ip_cores/wr-cores"
	    ]
    }

