# data_file
set output output_file
stats data_file."0x17_ch_1.txt" u 2 nooutput
load "histogram_common.gnuplot"
set xrange [ STATS_records/2 - 150 -1 : STATS_records/2 +150-1 ] noreverse writeback
set yrange [ 0.00000 : 300. ] noreverse writeback
set xtics 0,50,999
set xtics add ("<-5000" 0)
set xtics add (">5000" STATS_records-1)
set for [i=1:STATS_records/50-1] xtics add (sprintf("%d", i*500-5000) i*50)
load "histogram_plot_5ch.gnuplot"
