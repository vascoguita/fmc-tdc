#!   /usr/bin/env   python
#    coding: utf8
##_________________________________________________________________________________________________
##                                                                                                |
##                                           |TDC PTS|                                            |
##                                                                                                |
##                                         CERN,BE/CO-HT                                          |
##________________________________________________________________________________________________|

##-------------------------------------------------------------------------------------------------
##                                                                                                |
##                                  TDC ACAM test with Cesium PPS                                 |
##                                                                                                |
##-------------------------------------------------------------------------------------------------
##                                                                                                |
## Description  Testing of the ACAM timestamps using the Cesium clock. Only one channel           |
##              (any channel) is receiving the PPS signal. An interrupt is set to occur once the  |
##              circular buffer is full; The rising edges are kept and subtracted between them;   |
##              64 measurements of 1 sec are expected on every iteration. The maximum and minimum |
##              values of every iteration are kept and compared to the max and min of all other   |
##              iterations. The final span should be less than the design's specification:        |
##              700ps + timebase accuracy of 4ppm = 4000700 ps                                    |
##                                                                                                |
##                                                                                                |
## FW to load   tdc.bin                                                                           |
## Authors      Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
## Website      http://www.ohwr.org/projects/pts                                                  |
## Date         11/01/2013                                                                        |
##-------------------------------------------------------------------------------------------------

##-------------------------------------------------------------------------------------------------
##                               GNU LESSER GENERAL PUBLIC LICENSE                                |
##                              ------------------------------------                              |
## This source file is free software; you can redistribute it and/or modify it under the terms of |
## the GNU Lesser General Public License as published by the Free Software Foundation; either     |
## version 2.1 of the License, or (at your option) any later version.                             |
## This source is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;       |
## without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.      |
## See the GNU Lesser General Public License for more details.                                    |
## You should have received a copy of the GNU Lesser General Public License along with this       |
## source; if not, download it from http://www.gnu.org/licenses/lgpl-2.1.html                     |
##-------------------------------------------------------------------------------------------------

##-------------------------------------------------------------------------------------------------
##                                            Import                                             --
##-------------------------------------------------------------------------------------------------


# Import system modules
import sys
import time
import os
import math
import pylab
from pylab import *
from datetime import datetime

# Add common modules location tp path
sys.path.append('../../../../')
sys.path.append('../../../../gnurabbit/python/')
sys.path.append('../../../../common/')

# Import common modules
from ptsexcept import *
import rr
import csr


##-------------------------------------------------------------------------------------------------
##                                             Main                                              --
##-------------------------------------------------------------------------------------------------

def main (default_directory='.'):

    # Constants declaration
    FMC_TDC_ADDR             = '1a39:0004/1a39:0004@0001:0000'#'1a39:0004/1a39:0004@000B:0000'
    FMC_TDC_BITSTREAM_PATH   = '../firmwares/tdc.bit'
    FPGA_LOADER_PATH         = '../../../../gnurabbit/user/fpga_loader'

    # SPEC object declaration
    spec = rr.Gennum()

    # Bind SPEC object to FMC TDC card
    print "\n-------------------------------------------------------------------"
    print "----------------------------- FMC TDC -----------------------------"
    print "-------------------- ACAM test with Cesium PPS --------------------\n"


    print "\n_______________________________Info______________________________\n"
    print "FMC TDC address to parse: %s"%(FMC_TDC_ADDR)
    for name, value in spec.parse_addr(FMC_TDC_ADDR).iteritems():
        print "%s:0x%04X"%(name, value)
    spec.bind(FMC_TDC_ADDR)

    # Load FMC TDC firmware
    print "\n_________________________Initialisations_________________________\n"
    print "Loading FMC TDC firmware...",
    firmware_loader = os.path.join(default_directory, FPGA_LOADER_PATH)
    bitstream = os.path.join(default_directory, FMC_TDC_BITSTREAM_PATH)
    os.system(firmware_loader + ' ' + bitstream)
    time.sleep(1)
    print "Firmware loaded!"

    # TDC object declaration
    tdc = fmc_tdc.CFMCTDC(spec)

    # Check bitsteam type
    bitstream_type = tdc.read_bitstream_type()
    if(bitstream_type == 0xFFFFFFFF):
        msg = ("FATAL ERROR: No access to TDC core")
        print (msg)
    else:
        print('Access to TDC core OK')

    # Configure ACAM and TDC core registers
    print "\n__________________________Configuration__________________________\n"
    tdc.config_acam()
    time.sleep(1)
    tdc.reset_acam()
    acam_status_test = tdc.read_acam_status()-0xC4000800
    if acam_status_test == 0:
        print "ACAM IC8: Status register OK"
    else:
        msg = ("ERROR: ACAM IC8: No communication")
        print (msg)
    acam_readback_regs = []
    acam_readback_regs = tdc.readback_acam_config()
    for i in range(len(tdc.ACAM_READBACK_REGS)): 
        if (acam_readback_regs[i] == tdc.ACAM_READBACK_REGS[i]):
            print "ACAM IC8: reg 0x%02X: 0x%08X OK"%(tdc.ACAM_READBACK_ADDR[i], acam_readback_regs[i])
        else:
            msg = ("ERROR: ACAM IC8: Configuration registers failure; reg 0x%2X: received 0x%8X, expected 0x%8X"%(tdc.ACAM_READBACK_ADDR[i], acam_readback_regs[i], tdc.ACAM_READBACK_REGS[i]))
            print (msg)

    # Enable terminations of all channels
    tdc.enable_channels()
    tdc.channel_term(1, 1)
    tdc.channel_term(2, 1)
    tdc.channel_term(3, 1)
    tdc.channel_term(4, 1)
    tdc.channel_term(5, 1)

    # Interrupts
    print "\n____________________________IRQs_________________________________\n"
    print('Set IRQ enable mask: %.4X')%tdc.set_irq_en_mask(0xC) # was 0xC!!
    tdc.set_irq_tstamp_thresh(0x100)
    tdc.set_irq_time_thresh(0xFFF)
    tdc.set_irq_en_mask(0xC)

    # Enable timestamps aquisition (TDC_START_FPGA pulse sent at this step) 
    tdc.start_acq()

    # Data Files
    filename1 = "../measures/holidays_cesium_all_raw_r_tstamps_%s.txt" %datetime.now()
    all_raw_data_file = (open("%s" %filename1, "a"))   
    filename2 = "../measures/holidays_cesium_all_1s_%s.txt" %datetime.now()
    all_1s_file = (open("%s" %filename2, "a"))   
    all_measurs_min = []
    all_measurs_max = []
    all_measurs_avg = []
    time.sleep(1)

    for i in range(200000):

        tdc.check_irq(0)

        # Check timestamps after the interrupt
        print "\n__________________________Iteration %d_____________________________\n" %(i)
        print "Time now                 : %s" %datetime.now()
        print "Temperature now          : %3.3f°C" %tdc.mezz_get_temp()
        print "IRQ source               : %d"%(tdc.get_irq_src())
        print "TDC Write pointer        : %d"%(tdc.get_pointer())
        print "TDC Overflows            : %d"%(tdc.get_overflow_counter())
        timestamps, data, eurika = tdc.get_timestamps(0)
  
        # keep only rising edge timestamps
        r_edge_timestamps = []
        for m in range(len(timestamps)):
            if (timestamps[m][2] == 1):
                r_edge_timestamps.append(timestamps[m][0])

        print "\nRising tstamps         : %d"%(len(r_edge_timestamps))

        # evaluate timestamps
        current_measurs = []
        for k in range(0,len(r_edge_timestamps),2):
           measur = r_edge_timestamps[k+1] - r_edge_timestamps[k]
           current_measurs.append(measur)

        for l in current_measurs:
            all_1s_file.write("%20.2f\n" %l)

        current_max = max(current_measurs)
        current_min = min(current_measurs)
        span = current_max-current_min
        avg = (sum(current_measurs, 0.0) / len(current_measurs))
        print "max                      : %20.2f ps"%max(current_measurs)
        print "min                      : %20.2f ps"%min(current_measurs)
        print "span                     : %20.2f ps"%span
        print "average                  : %20.2f ps"%avg

        if (span > 4000000): # 4ppm timebase acuracy
            print "Things messed up!"
            for j in data:
                all_raw_data_file.write("%20.2f\n" %j)

        all_measurs_max.append(current_max)
        all_measurs_min.append(current_min)
        all_measurs_avg.append(avg)
        print "span so far              : %20.2f ps"%((max(all_measurs_max))-(min(all_measurs_min)))
        print "avg so far               : %20.2f ps"%(sum(all_measurs_avg, 0.0) / len(all_measurs_avg))
        print "max so far: iter %d       : %20.2f ps"%(all_measurs_max.index(max(all_measurs_max)), max(all_measurs_max))
        print "min so far: iter %d       : %20.2f ps"%(all_measurs_min.index(min(all_measurs_min)),min(all_measurs_min))


        tdc.clear_irq_src(int(math.log(tdc.get_irq_src(),2)))

    print "\n-----------------------------------------------------------------\n\n\n"


if __name__ == '__main__' :
    main()
