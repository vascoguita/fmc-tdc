stats data_file."0x17_ch_1.txt" u 5 nooutput

set print output_file
do for [board=17:19] {
    do for [ch=0:4] {
	stats data_file."0x".board."_ch_".ch.".txt" u 5 nooutput
	print sprintf("%d & %d & %.3f & %.3f & %.3f & %.3f & %.3f \\\\", board - 16, ch + 1, STATS_mean*1e12, STATS_stddev*1e12, STATS_min*1e12, STATS_max*1e12, (-STATS_min+STATS_max)*1e12)
    }
}
