cd <to /syn/spec>
ngdbuild -uc synplicity.ucf syn_tdc.edf
map -detail -w -timing -ol high syn_tdc.ngd
par -w -ol high syn_tdc.ncd par_tdc.ncd syn_tdc.pcf
trce -v 32 -u par_tdc.ncd syn_tdc.pcf -o timing_report
bitgen -w -g Binary:Yes par_tdc.ncd tdc


