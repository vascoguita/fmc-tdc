
all: fmc-tdc.pdf doxygen-doc

fmc-tdc.pdf: fmc-tdc.tex
	texi2pdf $< 

doxygen-doc:
	rm -rf fmc-tdc-doxygen
	mkdir -p fmc-tdc-doxygen
	./doxy.sh -n"FMCTDC Device Driver" -o "fmc-tdc-doxygen" ../lib/libtdc.h

clean: 
	rm -f *.pdf *.out *.toc *.aux *.log 
	rm -rf fmc-tdc-doxygen
all:
