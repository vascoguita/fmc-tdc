files = ["synthesis_descriptor.vhd",
"wr_svec_tdc.ucf",
"wr_svec_tdc.vhd"];

fetchto = "../../ip_cores"

modules = {
    "local" : [	"../../rtl/", 
		"../../ip_cores/vme64x-core",
		"../../ip_cores/general-cores",
		"../../ip_cores/wr-cores",
                "../../ip_cores/wr-cores/board/svec"
	    ],
    "git" : [ 
        "git://ohwr.org/hdl-core-lib/general-cores.git",
        "git://ohwr.org/hdl-core-lib/vme64x-core.git",
        "git://ohwr.org/hdl-core-lib/etherbone-core.git",
        ],
    }

