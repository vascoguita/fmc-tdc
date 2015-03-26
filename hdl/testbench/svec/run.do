vlog -sv main.sv +incdir+../../sim +incdir+../include/vme64x_bfm +incdir+../include
vsim -L unisim work.main -voptargs=+acc

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

do wave.do
radix -hexadecimal
run 1ms