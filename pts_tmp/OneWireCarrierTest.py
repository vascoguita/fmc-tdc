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


FAMILY_CODE = 0x28

"""
test01: Carrier One Wire
"""
def main (default_directory='.'):

    # Constants declaration

    FMC_TDC_ADDR = '1a39:0004/1a39:0004@000B:0000'
    FMC_TDC_BITSTREAM = '../firmwares/eva_tdc_for_v2.bit'
    FMC_TDC_CHANNEL_NB = 5
    
    # SPEC object declaration
    spec = rr.Gennum()

    ###########################################################################
    # TDC
    ###########################################################################

    # Bind SPEC object to FMC TDC card
    print "\n-----------------------------------------------------------------"
    print "---------------------------- FMC TDC ---------------------------- "
    print "---------------------- Carrier 1 wire test ----------------------"
    print "\n_______________________________Info______________________________\n"
    print "FMC TDC address to parse: %s"%(FMC_TDC_ADDR)
    for name, value in spec.parse_addr(FMC_TDC_ADDR).iteritems():
        print "%s:0x%04X"%(name, value)

    spec.bind(FMC_TDC_ADDR)

    print "\n_________________________Initialisations_________________________\n"
    # Load FMC TDC firmware
    print "Loading FMC TDC firmware...",
    spec.load_firmware(FMC_TDC_BITSTREAM)
    time.sleep(2)
    print "Firmware loaded!"

    # TDC object declaration
    tdc = fmc_tdc.CFMCTDC(spec)

    ########################################################################

    # Read unique ID and print to log
    print "\n________________________Carrier unique ID________________________\n"
    unique_id = tdc.carr_get_unique_id()
    if(unique_id == -1):
        print('/!\Cannot read DS18D20 1-wire thermometer/!\ ')
    else:
        print('Unique ID: %.12X') % unique_id

    # Read temperatur and print to log
    print "\n_______________________Carrier temperature_______________________\n"
    temp = tdc.carr_get_temp()
    print('Carrier temperature: %3.3f°C') % temp
    if((unique_id & 0xFF) != FAMILY_CODE):
        family_code = unique_id & 0xFF
        print('family code: 0x%.8X') % family_code

    print "\n-----------------------------------------------------------------"

if __name__ == '__main__' :
    main()
