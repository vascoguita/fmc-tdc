if (!exists("scale_x")) scale_x=5
if (!exists("scale_y")) scale_y=3
if (!exists("output_scale")) output_scale=1
set terminal pdfcairo fontscale 0.3 size scale_x*output_scale in,scale_y*output_scale in # size in inches
set style fill   solid 1.00 #border lt -1
set style data histograms # set as histogram
set xrange [ -10 : 1010 ] noreverse writeback
set ylabel "samples"
set xlabel "bin"
set key
set grid
set xtics rotate # obrucić labele na x o 90 stopni
#xtic - skąd brać label X
