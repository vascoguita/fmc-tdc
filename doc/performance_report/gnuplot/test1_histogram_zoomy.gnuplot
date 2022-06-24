# data_file
set output output_file
stats data_file u 2 nooutput
scale_y=1

load "histogram_common.gnuplot"

set yrange [ 0.00000 : 20. ] noreverse writeback
set xtics 0,50,999
set xtics add ("<-5000" 0)
set xtics add (">5000" STATS_records-1)
set for [i=1:STATS_records/50-1] xtics add (sprintf("%d", i*500-5000) i*50)
plot data_file u 2 ti "Samples in a bin", "" u 0:2 smooth bezier t "Bezier approximation" lw 2
