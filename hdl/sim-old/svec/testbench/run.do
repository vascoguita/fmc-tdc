# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: CERN-OHL-W-2.0+

vlog -sv main.sv +incdir+. +incdir+../../sim/wb +incdir+../../sim/vme64x_bfm +incdir+../../sim
vsim work.main -voptargs=+acc

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

do wave.do
radix -hexadecimal
run 100us