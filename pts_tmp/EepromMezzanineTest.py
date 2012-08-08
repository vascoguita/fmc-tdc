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

# Add common modules location tp path
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
test02: Test Mezzanine EEPROM
"""

EEPROM_ADDR = 0x50

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
    print "------------------- Mezzanine I2C EEPROM test -------------------"
    print "\n_______________________________Info______________________________\n"
    print "FMC TDC address to parse: %s"%(FMC_TDC_ADDR)
    for name, value in spec.parse_addr(FMC_TDC_ADDR).iteritems():
        print "%s:0x%04X"%(name, value)

    print "\n_________________________Initialisations_________________________\n"
    # Load FMC TDC firmware
    print "Loading FMC Fine Delay firmware...",
    spec.load_firmware(FMC_TDC_BITSTREAM)
    time.sleep(2)
    print "Firmware loaded!"

    # TDC object declaration
    tdc = fmc_tdc.CFMCTDC(spec)

    #########################################################################

    print "\n_____________________________I2C test____________________________\n"
    # Scan FMC i2c bus
    periph_addr = tdc.mezz_i2c_scan()

    # Check that the EEPROM is detected on the I2C bus
    if(0 == len(periph_addr)):
        print"No peripheral detected on system management I2C bus"
    else:
        if(1 != len(periph_addr)):
            print"Signal integrity problem detected on system management I2C bus, %d devices detected instead of 1"%(len(periph_addr))
        else:
            if(EEPROM_ADDR != periph_addr[0]):
                print"Wrong device mounted on system management I2C bus, address is:0x%.2X expected:0x%.2X"%(periph_addr[0],EEPROM_ADDR)

    # Write, read back and compare
    addr = 0x20
    wr_data = [0x55, 0xAA, 0x00, 0xFF]
    rd_data = []
    print('Writting data at EEPROM address 0x%.2X: ')%addr,
    print wr_data
    tdc.mezz_i2c_eeprom_write(addr, wr_data)
    time.sleep(0.1)
    print('Reading data from EEPROM address 0x%.2X:')%addr,
    rd_data = tdc.mezz_i2c_eeprom_read(addr, len(wr_data))
    print rd_data
    if(rd_data != wr_data):
        raise PtsError('/!\Cannot access EEPROM at address 0x%.2X/!\ '%(EEPROM_ADDR))
    else:
        print('\n!Data comparison OK!')

    print "\n-----------------------------------------------------------------"

if __name__ == '__main__' :
    main()
