ngdbuild -uc synplicity.ucf syn_tdc.edf
map -detail -w -timing -ol high syn_tdc.ngd
par -ol high syn_tdc.ncd par_tdc
trce -u par_tdc.ncd syn_tdc.pcf
bitgen par_tdc.ncd tdc
