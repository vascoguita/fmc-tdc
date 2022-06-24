#data_file
# stats data_file nooutput
# scale for png output
output_scale = 4
set output output_file

load "samples_common.gnuplot"
# y axis in ns
plot data_file u ($0/1000000):($5*1000000000) w points pointtype 7 ps 0.1
