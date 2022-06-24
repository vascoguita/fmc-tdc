# scale for png output
output_scale = 4
set output output_file

load "samples_common.gnuplot"
set xlabel "sample (K)"
# y axis in us
set ylabel "us"
plot data_file u ($0/1000):($5*1000000) w points pointtype 7 ps 0.1
