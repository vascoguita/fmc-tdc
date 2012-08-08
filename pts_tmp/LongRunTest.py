#!   /usr/bin/env   python
#    coding: utf8

# Copyright CERN, 2011
# Author: EGousiou <egousiou@cern.ch>
# Licence: GPL v2 or later.
# Website: http://www.ohwr.org


# Import system modules
import sys
import time
import os
import math
import pylab
from pylab import *
from datetime import datetime

# Import common modules
from ptsexcept import *
import rr

# Import specific modules
import fmc_tdc
sys.path.append('../../../../fmc_delay/software/python/')
import fdelay_lib


# Add common modules location to path
sys.path.append('../../../')
sys.path.append('../../../gnurabbit/python/')
sys.path.append('../../../common/')


"""
test06: Tests the TDC precission: pulses are sent in 2 different channels with some delay between them introduced through a cable.
After thousands of pulses the span of all the measurements should remain <1000 ps.
Channel 1 of the FD board should arrive to any 2 channels of the TDC.
"""

def main (default_directory='.'):

    # Constants declaration
    FMC_TDC_ADDR = '1a39:0004/1a39:0004@000B:0000'
    FMC_TDC_BITSTREAM = '../firmwares/eva_tdc_for_v2.bit'
    FMC_TDC_CHANNEL_NB = 5
    
    FMC_DELAY_ADDR = '1a39:0004/1a39:0004@0005:0000'
    FMC_DELAY_BITSTREAM = '../firmwares/fmc_delay_spec.bin'

    # SPEC object declaration
    spec = rr.Gennum()

    ###########################################################################
    # TDC
    ###########################################################################

    # Bind SPEC object to FMC TDC card
    print "test 06"
    print "-----------------------------------------------------------------"
    print "---------------------------- FMC TDC ---------------------------- "
    print "\n_______________________________Info______________________________\n"
    print "FMC TDC address to parse: %s"%(FMC_TDC_ADDR)
    for name, value in spec.parse_addr(FMC_TDC_ADDR).iteritems():
        print "%s:0x%04X"%(name, value)
    spec.bind(FMC_TDC_ADDR)

    # Load FMC TDC firmware
    print "\n_________________________Initialisations_________________________\n"
    print "Loading FMC TDC firmware...",
    spec.load_firmware(FMC_TDC_BITSTREAM)
    time.sleep(2)
    print "Firmware loaded!"

    # TDC object declaration
    tdc = fmc_tdc.CFMCTDC(spec)

    # TDC configuration
    print "\n__________________________Configuration__________________________\n"
    tdc.config_acam()
    tdc.set_irq_tstamp_thresh(0x100)
    tdc.set_irq_time_thresh(0xFF)
    time.sleep(1)


    # Configuring DAC and PLL
    #print "\n_____________________Configuring DAC and PLL_____________________\n"
    #tdc.configure_mezz_dac(0xAA57) # nominal: xAA57, max: xFFFF, min: x0000
    #time.sleep(2)

    # Enable TDC channels and terminations
    #for ch in range(1,FMC_TDC_CHANNEL_NB+1):
        #tdc.channel_term(ch, 1)
    tdc.enable_channels()
    tdc.channel_term(1, 0)
    tdc.channel_term(2, 1)
    tdc.channel_term(3, 0)
    tdc.channel_term(4, 1)
    tdc.channel_term(5, 0)


    # Check ACAM status
    print "\n___________________________ACAM reset____________________________\n"
    tdc.reset_acam()
    print "\n___________________________ACAM status___________________________\n"
    acam_status_test = tdc.read_acam_status()-0xC4000800
    if acam_status_test == 0:
        print "ACAM status OK!"
    else:
        print "/!\ACAM not OK../!\ "


    # Readback all ACAM configuration regs
    print "\n_________________Reading back ACAM configuration_________________\n"
    tdc.readback_acam_config()


    # Enable TDC core interrupts
    # /!\ CAUTION!! /!\
    # In this test we are not using interrupts as we have seen that when having two
    # SPEC boards some interrupts may be missed after several iterations!!
    #print "\n____________________________IRQ mask_____________________________\n"
    #print('Set IRQ enable mask: %.4X')%tdc.set_irq_en_mask(0xC)


    # Enable timestamps aquisition
    print "\n_______________________Starting aquisition_______________________\n"
    tdc.start_acq()


    all_cable_delay_min = []
    all_cable_delay_max = []


    ###########################################################################
    # Fine Delay
    ###########################################################################

    print "\n-----------------------------------------------------------------"
    print "------------------------- FMC FINE DELAY ------------------------"
    # Bind SPEC object to FMC Fine Delay card
    print "Fine Delay address to parse %s"%(FMC_DELAY_ADDR)
    for name, value in spec.parse_addr(FMC_DELAY_ADDR).iteritems():
        print "%s:0x%04X"%(name, value)
    spec.bind(FMC_DELAY_ADDR)

    # Load FMC Fine Delay firmware
    print "\n\nLoading FMC Fine Delay firmware...",
    sys.stdout.flush()
    spec.load_firmware(FMC_DELAY_BITSTREAM)
    time.sleep(2)
    print "Firmware loaded!"

    # Fine Delay object declaration
    print "\n"
    fdelay = fdelay_lib.FineDelay(spec.get_fd())

    # Set UTC and Coarse time in the Fine Delay
    fdelay.set_time(0, 0)
    fd_time = fdelay_lib.fd_timestamp()
    fd_time = fdelay.get_time()
    print "\nFine Delay UTC time = %d, Coarse time = %d"%(fd_time.utc, fd_time.coarse)

    # Configure the Fine Delay as a pulse generator
    channel = 1 # must be 1, 2, 3 or 4
    enable = 1 # this one is obvious
    t_start_coarse = 0
    width = 100000     # pulse width 100 ns
    delta = 200000    # a pulse every 200 ns
    count = 64       # 64 pulses on each channel; 256 timestamps
    
    # File that keeps all the timestamps
    all_raw_r_tstamps_file = open("all_raw_r_tstamps_008_ch2_4_fanout_newFD.txt","a")
    all_cable_delay_file = open("all_cable_delay_008_ch2_4_fanout_newFD.txt","a")
    all_temper_file = open("all_temper_008_ch2_4_fanout_newFD.txt","a")

    # several iterations of sending pulses and retrieving timestamps 
    for m in range(500000):

        print "\n\n>>Iteration:%d"%m

        ###########################################################################
        # Fine Delay
        ###########################################################################

        # Bind SPEC object to FMC Fine Delay card
        spec.bind(FMC_DELAY_ADDR)

        time.sleep(0.3) # was 0.5; somehow it's needed..otherwise after many iterations i get crushes!

        # Configure the Fine Delay as a pulse generator
        t_start_utc = fdelay.get_time().utc+1 # pulse(s) generation start time (-> 2 seconds in the future)
        fdelay.conf_pulsegen(channel, enable, t_start_utc, t_start_coarse, width, delta, count)
        print "\nFine Delay: %d pulses ready to be sent in 1 sec!"%count   



        ###########################################################################
        # TDC
        ###########################################################################

        # Bind SPEC object to FMC TDC card
        spec.bind(FMC_TDC_ADDR)

        print "\n______________________TDC Precission testing_____________________\n"

        #tdc.check_irq()
        # /!\ CAUTION!! /!\
        # In this test we are not using interrupts as we have seen that when having two
        # SPEC boards some interrupts may be missed after several iterations!!
        # a time.sleep statement is used instead!!
        # In principle the TDC core memory is filled up with 256 timestamps,
        # then they are retrieved through a DMA
        # and then a new loop of sending and retrieving 256 new timestamps starts..
        time.sleep(0.2)

        print "The time now is: %s" %datetime.now()
        temper = tdc.mezz_get_temp()
        print "The temperature now is: %3.3f°C" %temper
        all_temper_file.write("%s\n" %temper)

        print "IRQ iteration: %d // Overflows: %d // IRQ source: %d // Write pointer: %d\n"%(m, tdc.get_overflow_counter(), tdc.get_irq_src(), tdc.get_pointer()),


        timestamps, data = tdc.get_timestamps(0)

        r_edge_timestamps = []
        f_edge_timestamps = []
        cable_delay_list = []
        all_cable_delay_avg = []
    
        for i in range(len(timestamps)):
             if ((timestamps[i][2] == 1)):# and (timestamps[i][1] == 1 or timestamps[i][1] == 3)):
                 r_edge_timestamps.append(timestamps[i][0])


        print "Number of r timestamps            : %d"%(len(r_edge_timestamps))

        for j in r_edge_timestamps:
            all_raw_r_tstamps_file.write("%20.2f\n" %j)


        r_edge_timestamps.sort()


        for k in range(0,len(r_edge_timestamps),2):
            cable_delay = r_edge_timestamps[k+1] - r_edge_timestamps[k]
            cable_delay_list.append(cable_delay)

        for l in cable_delay_list:
            all_cable_delay_file.write("%20.2f\n" %l)

        current_max = max(cable_delay_list)
        current_min = min(cable_delay_list)
        span = current_max-current_min
        avg = (sum(cable_delay_list, 0.0) / len(cable_delay_list))
        print "\nmax : %20.2f ps"%max(cable_delay_list)
        print "min : %20.2f ps"%min(cable_delay_list)
        print "span: %20.2f ps"%span
        print "average:  %20.2f ps"%avg

        if span > 800:
            print "Span messed up!"


        all_cable_delay_max.append(current_max)
        all_cable_delay_min.append(current_min)
        all_cable_delay_avg.append(avg)
        print "\nCurrent max: iteration %d,    %20.2f ps"%(all_cable_delay_max.index(max(all_cable_delay_max)), max(all_cable_delay_max))
        print "Current min: iteration %d,    %20.2f ps"%(all_cable_delay_min.index(min(all_cable_delay_min)),min(all_cable_delay_min))
        print "Current span:               %20.2f ps"%((max(all_cable_delay_max))-(min(all_cable_delay_min)))
        print "Current avg:               %20.2f ps"%(sum(all_cable_delay_avg, 0.0) / len(all_cable_delay_avg))


    # out of the for loop!
    all_cable_delay_file.close()
    all_temper_file.close()
    all_raw_r_tstamps_file.close()

    print "\n___________________________ACAM status___________________________\n"
    acam_status_test = tdc.read_acam_status()-0xC4000800
    if acam_status_test == 0:
        print "ACAM status OK!"
    else:
        print "/!\ACAM not OK../!\ "

    print "\n_________________Reading back ACAM configuration_________________\n"
    tdc.readback_acam_config()

    print "\n___________________________Statistics____________________________\n"
    print all_cable_delay_min
    print all_cable_delay_max
    print "#### Final span: %20.2f ps ####"%((max(all_cable_delay_max))-(min(all_cable_delay_min)))



    print "\n_______________________Stopping aquisition_______________________\n"
    tdc.stop_acq()

    print "\n-----------------------------------------------------------------\n\n\n"


if __name__ == '__main__' :
    main()
