# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: CC-BY-SA-4.0+

all : tdc_performance_report.pdf



.PHONY : all clean

tdc_performance_report.pdf: tdc_performance_report.pdf
	pdflatex -dPDFSETTINGS=/prepress -dSubsetFonts=true -dEmbedAllFonts=true -dMaxSubsetPct=100 -dCompatibilityLevel=1.4 $^
	pdflatex -dPDFSETTINGS=/prepress -dSubsetFonts=true -dEmbedAllFonts=true -dMaxSubsetPct=100 -dCompatibilityLevel=1.4 $^

clean :
	rm -f *.eps *.pdf *.dat *.log *.out *.aux *.dvi *.ps *.toc
