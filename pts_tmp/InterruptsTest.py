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
import termcolor
from termcolor import colored

# Add common modules location to path
sys.path.append('../../../')
sys.path.append('../../../gnurabbit/python/')
sys.path.append('../../../common/')

# Import common modules
from ptsexcept import *
import rr

# Import specific modules
import fmc_tdc
sys.path.append('../../../../fmc_delay/software/python/')
import fdelay_lib


"""
test04: Test the write pointer and the interrupts occurence
Use of FD board
2 TDC channels need to be receiving pulses
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
    tdc.set_irq_tstamp_thresh(0x100) # set to max 256 tstamps
    tdc.set_irq_time_thresh(0x10)    # 16 secs
    time.sleep(1)

    tdc.enable_channels()
    for ch in range(1,FMC_TDC_CHANNEL_NB+1):
        tdc.channel_term(ch, 1)

    print "\n___________________________ACAM reset____________________________\n"
    tdc.reset_acam()
    print "\n___________________________ACAM status___________________________\n"
    acam_status_test = tdc.read_acam_status()-0xC4000800
    if acam_status_test == 0:
        print "ACAM status OK!"
    else:
        print "/!\ACAM not OK../!\ "


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
    t_start_utc = fdelay.get_time().utc+4 # pulse(s) generation start time (-> 2 seconds in the future)
    t_start_coarse = 0
    width = 200000 # pulse width 200 ns
    delta = 100000000000 # a pulse every 100 ms
    count = 645 # 645 pulses on each channel = 2580 tstamps
    
    fdelay.conf_pulsegen(channel, enable, t_start_utc, t_start_coarse, width, delta, count)
    fdelay.conf_pulsegen(channel+1, enable, t_start_utc, t_start_coarse+50, width, delta, count)

    

    ###########################################################################
    # TDC
    ###########################################################################
    print "\n-----------------------------------------------------------------"
    print "---------------------------- FMC TDC ---------------------------- "
    # Bind SPEC object to FMC TDC card
    spec.bind(FMC_TDC_ADDR)

    print "\n___________________________ACAM status___________________________\n"
    acam_status_test = tdc.read_acam_status()-0xC4000800
    if acam_status_test == 0:
        print "ACAM status OK!"
    else:
        print "/!\ACAM not OK../!\ "

    print "\n_________________Reading back ACAM configuration_________________\n"
    tdc.readback_acam_config()

    # Enables TDC core interrupts
    print "\n____________________________IRQ mask_____________________________\n"
    print('Set IRQ enable mask: %.4X')%tdc.set_irq_en_mask(0xC)

    print "\n_______________________Starting aquisition_______________________\n"
    tdc.start_acq()

    print "\n__________________________IRQs testing___________________________\n"

    # An IRQ is raised every 256 timestamps or if >0 and < 256 timestamps have been
    # accumulated and 8 secs have passed since the last IRQ.
    # In this test in total 2580 timestaps should be registered by the FPGA.
    # Therefore we are expecting 11 IRQs:
    #   10 IRQs for the first 2560 timestamps
    #   1 IRQ for the last 20, 8 secs after the 10th IRQ
    # For the first 10, upon IRQ arrival the write pointer should be 0, indicating
    # that 256 timestamps have been written.
    # For the last IRQ the write pointer should be 320 which is the number of bytes 
    # for 20 128-bits-long timestamps

    # ToDooo:put time exit!!!if more than 1 min has passed (in case irqs have not arrived, exit)

    tdc_wr_ptr_list = []
    tdc_overflow_list = []
    irq_src_list = []

    for i in range(11):
        tdc.check_irq(0)
        irq_src = tdc.get_irq_src()
        print "IRQ iteration: %d // Overflows: %d // IRQ source: %d // Write pointer: %d \r"%(i, tdc.get_overflow_counter(), irq_src, tdc.get_pointer()),
        sys.stdout.flush()
        tdc.clear_irq_src(int(math.log(irq_src,2)))
        irq_src_list.append(irq_src)
        tdc_wr_ptr_list.append(tdc.get_pointer())
        tdc_overflow_list.append(tdc.get_overflow_counter())

    print "\nOverflow counter upon IRQ:",
    print tdc_overflow_list
    print "IRQ sources              :",
    print irq_src_list
    print "Write pointer upon IRQ   :",
    print tdc_wr_ptr_list

    if (tdc_wr_ptr_list == [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 320]) and (tdc_overflow_list == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10]) and (irq_src_list == [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 8]):
        print ('\nIRQ test sucessful :)')
    else:
        print ('\n/!\IRQ test failed..:( ')

    print "\n_______________________Stopping aquisition_______________________\n"
    tdc.stop_acq()

    print "\n-----------------------------------------------------------------\n\n\n"


if __name__ == '__main__' :
    main()
