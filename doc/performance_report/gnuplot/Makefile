# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: CC0-1.0

# Data dependencies are not perfect, they don't trigger regeneration of files.
# But better this than nothing
IMG_DIR=../img

test1=test1_samples_absolute.png test1_samples_absolute_zoom.png test1_samples_relative.png test1_samples_relative_zoomxy.png test1_histogram.pdf test1_histogram_zoomy.pdf test1_histogram_zoomx.pdf
test2=test2_samples_absolute.png test2_samples_relative.png test2_samples_relative_zoomxy.png test2_histogram.pdf test2_histogram_zoomy.pdf test2_histogram_zoomx.pdf
test3_1MHz=test3_samples_absolute_1MHz.png test3_samples_relative_1MHz.png test3_histogram_1MHz.pdf test3_histogram_zoomy_1MHz.pdf test3_histogram_zoomx_1MHz.pdf
test3_2MHz=test3_samples_absolute_2MHz.png test3_samples_relative_2MHz.png test3_histogram_2MHz.pdf test3_histogram_zoomy_2MHz.pdf test3_histogram_zoomx_2MHz.pdf
test4=test4_histogram_15ch.pdf test4_histogram_15ch_zoomxy.pdf test4_histogram_15ch_zoomy.pdf test4_histogram_5ch.pdf test4_histogram_5ch_zoomxy.pdf test4_histogram_5ch_zoomy.pdf test4_stats.tex
test5=test5_samples_absolute.png test5_samples_absolute_zoom.png test5_samples_relative.png test5_samples_relative_zoomxy.png test5_histogram.pdf test5_histogram_zoomy.pdf test5_histogram_zoomx.pdf
test6=test6_samples_absolute.png test6_samples_relative.png test6_samples_relative_zoomxy.png test6_histogram.pdf test6_histogram_zoomy.pdf test6_histogram_zoomx.pdf


all: test1 test2 test3 test4 test5 test6

test1: $(addprefix $(IMG_DIR)/,$(test1))
test2: $(addprefix $(IMG_DIR)/,$(test2))
test3: test3_1MHz test3_2MHz
test3_1MHz: $(addprefix $(IMG_DIR)/,$(test3_1MHz))
test3_2MHz: $(addprefix $(IMG_DIR)/,$(test3_2MHz))
test4: $(addprefix $(IMG_DIR)/,$(test4))
test5: $(addprefix $(IMG_DIR)/,$(test5))
test6: $(addprefix $(IMG_DIR)/,$(test6))

test1: DATA_DIR=../data_report/test1_run1
test2: DATA_DIR=../data_report/test2_run3
test3_1MHz: DATA_DIR=../data_report/test3_run3
test3_2MHz: DATA_DIR=../data_report/test3_run4
test4: DATA_DIR=../data_report/test4_run2
test5: DATA_DIR=../data_report/vme_test1_run1
test6: DATA_DIR=../data_report/vme_test2_run4

vpath %.png ../img
vpath %.pdf ../img

$(IMG_DIR)/test1_histogram.pdf: DATA_FILE=test1_hist_tdc_0x18_ch_1.txt
$(IMG_DIR)/test1_histogram_zoomx.pdf: DATA_FILE=test1_hist_tdc_0x18_ch_1.txt
$(IMG_DIR)/test1_histogram_zoomy.pdf: DATA_FILE=test1_hist_tdc_0x18_ch_1.txt
# $(IMG_DIR)/test1_histogram_all.pdf: DATA_FILE=test1_hist_tdc_0x18_ch_1.txt
$(IMG_DIR)/test1_samples_absolute.png: DATA_FILE=test1_sample_tdc_0x18_ch_1.txt
$(IMG_DIR)/test1_samples_absolute_zoom.png: DATA_FILE=test1_sample_tdc_0x18_ch_1.txt
$(IMG_DIR)/test1_samples_relative.png: DATA_FILE=test1_sample_tdc_0x18_ch_1.txt
$(IMG_DIR)/test1_samples_relative_zoomxy.png: DATA_FILE=test1_sample_tdc_0x18_ch_1.txt

$(IMG_DIR)/test2_histogram.pdf: DATA_FILE=test2_hist_tdc_0x18_ch_1.txt
$(IMG_DIR)/test2_histogram_zoomx.pdf: DATA_FILE=test2_hist_tdc_0x18_ch_1.txt
$(IMG_DIR)/test2_histogram_zoomy.pdf: DATA_FILE=test2_hist_tdc_0x18_ch_1.txt
$(IMG_DIR)/test2_samples_absolute.png: DATA_FILE=test2_sample_tdc_0x18_ch_1.txt
$(IMG_DIR)/test2_samples_relative.png: DATA_FILE=test2_sample_tdc_0x18_ch_1.txt
$(IMG_DIR)/test2_samples_relative_zoomxy.png: DATA_FILE=test2_sample_tdc_0x18_ch_1.txt

$(IMG_DIR)/test3_samples_absolute_1MHz.png: DATA_FILE=test3_sample_tdc_0x18_ch_0.txt
$(IMG_DIR)/test3_samples_relative_1MHz.png: DATA_FILE=test3_sample_tdc_0x18_ch_0.txt
$(IMG_DIR)/test3_histogram_1MHz.pdf: DATA_FILE=test3_hist_tdc_0x18_ch_0.txt
$(IMG_DIR)/test3_histogram_zoomx_1MHz.pdf: DATA_FILE=test3_hist_tdc_0x18_ch_0.txt
$(IMG_DIR)/test3_histogram_zoomy_1MHz.pdf: DATA_FILE=test3_hist_tdc_0x18_ch_0.txt

$(IMG_DIR)/test3_samples_absolute_2MHz.png: DATA_FILE=test3_sample_tdc_0x18_ch_0.txt
$(IMG_DIR)/test3_samples_relative_2MHz.png: DATA_FILE=test3_sample_tdc_0x18_ch_0.txt
$(IMG_DIR)/test3_histogram_2MHz.pdf: DATA_FILE=test3_hist_tdc_0x18_ch_0.txt
$(IMG_DIR)/test3_histogram_zoomx_2MHz.pdf: DATA_FILE=test3_hist_tdc_0x18_ch_0.txt
$(IMG_DIR)/test3_histogram_zoomy_2MHz.pdf: DATA_FILE=test3_hist_tdc_0x18_ch_0.txt

$(IMG_DIR)/test4_histogram_5ch.pdf: DATA_FILE=test4_hist_tdc_
$(IMG_DIR)/test4_histogram_5ch_zoomxy.pdf: DATA_FILE=test4_hist_tdc_
$(IMG_DIR)/test4_histogram_5ch_zoomy.pdf: DATA_FILE=test4_hist_tdc_
$(IMG_DIR)/test4_histogram_15ch.pdf: DATA_FILE=test4_hist_tdc_
$(IMG_DIR)/test4_histogram_15ch_zoomxy.pdf: DATA_FILE=test4_hist_tdc_
$(IMG_DIR)/test4_histogram_15ch_zoomy.pdf: DATA_FILE=test4_hist_tdc_
$(IMG_DIR)/test4_stats.tex: DATA_FILE=test4_sample_tdc_

$(IMG_DIR)/test5_histogram.pdf: DATA_FILE=vme_test1_hist_tdc_0x5_ch_2.txt
$(IMG_DIR)/test5_histogram_zoomx.pdf: DATA_FILE=vme_test1_hist_tdc_0x5_ch_2.txt
$(IMG_DIR)/test5_histogram_zoomy.pdf: DATA_FILE=vme_test1_hist_tdc_0x5_ch_2.txt
$(IMG_DIR)/test5_samples_absolute.png: DATA_FILE=vme_test1_sample_tdc_0x5_ch_2.txt
$(IMG_DIR)/test5_samples_absolute_zoom.png: DATA_FILE=vme_test1_sample_tdc_0x5_ch_2.txt
$(IMG_DIR)/test5_samples_relative.png: DATA_FILE=vme_test1_sample_tdc_0x5_ch_2.txt
$(IMG_DIR)/test5_samples_relative_zoomxy.png: DATA_FILE=vme_test1_sample_tdc_0x5_ch_2.txt

$(IMG_DIR)/test6_histogram.pdf: DATA_FILE=vme_test2_hist_tdc_0x5_ch_2.txt
$(IMG_DIR)/test6_histogram_zoomx.pdf: DATA_FILE=vme_test2_hist_tdc_0x5_ch_2.txt
$(IMG_DIR)/test6_histogram_zoomy.pdf: DATA_FILE=vme_test2_hist_tdc_0x5_ch_2.txt
$(IMG_DIR)/test6_samples_absolute.png: DATA_FILE=vme_test2_sample_tdc_0x5_ch_2.txt
$(IMG_DIR)/test6_samples_relative.png: DATA_FILE=vme_test2_sample_tdc_0x5_ch_2.txt
$(IMG_DIR)/test6_samples_relative_zoomxy.png: DATA_FILE=vme_test2_sample_tdc_0x5_ch_2.txt

$(IMG_DIR)/%.png: %.gnuplot $(DATA_DIR)/$(DATA_FILE)
	gnuplot -e "data_file='$(DATA_DIR)/$(DATA_FILE)'" -e "output_file='$@'" -c $< -s -d -p

$(IMG_DIR)/%.pdf: %.gnuplot $(DATA_DIR)/$(DATA_FILE)
	gnuplot -e "data_file='$(DATA_DIR)/$(DATA_FILE)'" -e "output_file='$@'" -c $< -s -d -p

$(IMG_DIR)/%.tex: %.gnuplot $(DATA_DIR)/$(DATA_FILE)
	gnuplot -e "data_file='$(DATA_DIR)/$(DATA_FILE)'" -e "output_file='$@'" -c $< -s -d -p
