# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: CERN-OHL-W-2.0+

files = ["wr_spec_tdc.ucf",
"wr_spec_tdc.vhd"];

fetchto = "../../ip_cores"

modules = {
    "local" : [	"../../rtl/" ],
    "git" : [
       "https://ohwr.org/project/general-cores.git",
       "https://ohwr.org/project/gn4124-core.git",
       "https://ohwr.org/project/wr-cores.git",
       "https://ohwr.org/project/wr-cores/board/spec.git",
       "https://ohwr.org/project/ddr3-sp6-core.git",
       "https://ohwr.org/project/spec.git"
	    ]
    }

