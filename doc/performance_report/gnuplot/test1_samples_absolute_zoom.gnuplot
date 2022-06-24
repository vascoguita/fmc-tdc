#data_file
# stats data_file nooutput
# scale for png output
output_scale = 4
set output output_file

load "samples_common.gnuplot"
# y axis in ns
#set xrange [ * : 1000 ] noreverse writeback
set ytics format "%.0f"
set xlabel "sample (k)"
plot data_file u ($0/1000):($3*1000000000) every ::0::10000 w points pointtype 7 ps 0.1
