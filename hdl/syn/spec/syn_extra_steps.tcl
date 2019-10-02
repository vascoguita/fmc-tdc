# get project file from 1st command-line argument
set project_file [lindex $argv 0]

if {![file exists $project_file]} {
    report ERROR "Missing file $project_file, exiting."
    exit -1
}

xilinx::project open $project_file

# Some of these are not respected by ISE when passed through hdlmake,
# so we add them all ourselves after creating the project
#
# Not respected by ISE when passed through hdlmake:
# 1. Pack I/O Registers/Latches into IOBs
# 2. Register Duplication Map


xilinx::project set "Enable Multi-Threading" "off"
xilinx::project set "Enable Multi-Threading" "off" -process "Place & Route"

xilinx::project set "Pack I/O Registers into IOBs" "Yes"
xilinx::project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs"

xilinx::project set "Register Duplication Map" "Off"

xilinx::project set "Register Balancing" "Yes"

xilinx::project set "Placer Effort Level Map" "High"
xilinx::project set "Placer Extra Effort Map" "Continue on Impossible"
xilinx::project set "Extra Effort (Highest PAR level only)" "Continue on Impossible"

xilinx::project save

xilinx::project close
