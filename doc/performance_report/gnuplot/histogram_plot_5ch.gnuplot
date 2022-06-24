plot \
    data_file."0x17_ch_0.txt" u 2 ti "Samples in a bin channel 1" lc 1, "" u 0:2 smooth bezier t "Bezier approximation" lc 1, \
    data_file."0x17_ch_1.txt" u 2 ti "Samples in a bin channel 2" lc 2, "" u 0:2 smooth bezier t "Bezier approximation" lc 2, \
    data_file."0x17_ch_2.txt" u 2 ti "Samples in a bin channel 3" lc 5, "" u 0:2 smooth bezier t "Bezier approximation" lc 5, \
    data_file."0x17_ch_3.txt" u 2 ti "Samples in a bin channel 4" lc 7, "" u 0:2 smooth bezier t "Bezier approximation" lc 7, \
    data_file."0x17_ch_4.txt" u 2 ti "Samples in a bin channel 5" lc 8, "" u 0:2 smooth bezier t "Bezier approximation" lc 8, \
