if (!exists("scale_x")) scale_x=640
if (!exists("scale_y")) scale_y=480
set terminal pngcairo size scale_x*output_scale,scale_y*output_scale enhanced font "arial,10" fontscale output_scale linewidth output_scale
set style fill   solid 1.00 #border lt -1
set xrange [* : *]
set ylabel "ns"
set xlabel "sample (M)"
unset key
set xtics rotate
