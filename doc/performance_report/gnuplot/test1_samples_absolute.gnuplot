#data_file
# stats data_file nooutput
# scale for png output
output_scale = 4
set output output_file

load "samples_common.gnuplot"
# y axis in us
set ylabel "us"
set ytics format "%.0f"
plot data_file u ($0/1000000):($3*1000000) w points pointtype 7 ps 0.1
