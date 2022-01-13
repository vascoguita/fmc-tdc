# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: CC0-1.0

SVG=$(wildcard *.svg)
PDF=$(SVG:.svg=.pdf)

.PHONY: all
all: $(PDF)

%.pdf : %.svg
	inkscape $< -o $@ || inkscape --without-gui $< -A $@

clean:
	rm -f $(PDF)

show:
	$(info all svg: $(SVG))
	$(info all pdf: $(PDF))
