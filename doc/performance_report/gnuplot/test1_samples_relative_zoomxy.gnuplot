#data_file
stats data_file u 5 every ::0::10000 nooutput
# scale for png output
output_scale = 4
set output output_file

load "samples_common.gnuplot"
# y axis in ns
set yrange [ STATS_min*200000000 : STATS_max*200000000 ]
set xlabel "sample (k)"
plot data_file u ($0/1000):($5*1000000000) every ::0::10000 w points pointtype 7 ps 0.1
