cd <to the synthesis directory: hdl/syn/spec>

ngdbuild -uc synplicity.ucf syn_tdc.edf
map -detail -xe n -w -timing -ol high syn_tdc.ngd
par -w -xe n -ol high syn_tdc.ncd par_tdc.ncd syn_tdc.pcf
trce -v 32 -u par_tdc.ncd syn_tdc.pcf -o timing_report
bitgen -w -g Binary:Yes par_tdc.ncd tdc

ngdbuild -uc synplicity.ucf syn_tdc.edf;map -detail -xe n -w -timing -ol high -pr b  syn_tdc.ngd;par -w -ol high -xe n -mt off syn_tdc.ncd par_tdc.ncd syn_tdc.pcf;trce -v 32 -u par_tdc.ncd syn_tdc.pcf -o timing_report;bitgen -w -g Binary:Yes par_tdc.ncd tdc