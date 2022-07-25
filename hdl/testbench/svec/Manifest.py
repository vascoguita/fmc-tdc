# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: CC0-1.0

sim_tool = "modelsim"
top_module="main"
syn_device="xc6slx150t"

action = "simulation"
target = "xilinx"
fetchto = "../../ip_cores"
include_dirs=[ "../../sim", "../include", "../../ip_cores/vme64x-core/hdl/vme64x-core/sim/vme64x_bfm" ]

files = [ "main.sv" ]

modules = { "local" :  [ "../../top/svec" ] }

