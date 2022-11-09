# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: CERN-OHL-W-2.0+

vsim -t 1ps -L unisim work.main -voptargs=+acc

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

do wave.do
radix -hexadecimal
run 1ms