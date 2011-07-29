#########################
###  DEFINE VARIABLES ###
#########################
set DesignName	"syn_tdc"
set FamilyName	"SPARTAN6"
set DeviceName	"XC6SLX45T"
set PackageName	"FGG484"
set SpeedGrade	"-2"
set TopModule	"top_tdc"
set EdifFile	"syn_tdc.edf"
if {![file exists $DesignName.ise]} {

project new $DesignName.ise

project set family $FamilyName
project set device $DeviceName
project set package $PackageName
project set speed $SpeedGrade

xfile add $EdifFile
if {[file exists synplicity.ucf]} {
    xfile add synplicity.ucf
}

project set "Netlist Translation Type" "Timestamp"
project set "Other NGDBuild Command Line Options" "-verbose"
project set "Generate Detailed MAP Report" TRUE

project close
}


file delete -force $DesignName\_xdb

project open $DesignName.ise

process run "Implement Design" -force rerun_all

project close

