#!   /usr/bin/env   python
#    coding: utf8

# Copyright CERN, 2011
# Author: Matthieu Cattin <matthieu.cattin@cern.ch>
# Licence: GPL v2 or later.
# Website: http://www.ohwr.org

# Import system modules
import sys
import time
import os
import math

# Import common modules
import rr
from ptsexcept import *
import csr
import gn4124
import i2c
import onewire
import ds18b20
import eeprom_24aa64

# Add common modules location tp path
sys.path.append('../../../../')
sys.path.append('../../../../gnurabbit/python/')
sys.path.append('../../../../common/')


"""
FMC TDC class
"""
class CFMCTDC:


    # DMA WISHBONE adress
    GNUM_CSR_ADDR       = 0x04000

    # Carrier One Wire
    CARR_ONEWIRE_ADDR   = 0x04800

    # Carrier CSR info
    CARRIER_CSR_ADDR    = 0x04C00
    CSR_BSTM_TYPE       = 0x04

    # TDC core WISHBONE adress
    TDC_CORE_ADDR       = 0x05000

    # IRQ controller
    IRQ_CONTROLLER_ADDR = 0x05400
    IRQ_CTRL_SRC        = 0x04
    IRQ_CTRL_EN_MASK    = 0x08

    # Mezzanine I2C
    MEZZ_I2C_ADDR       = 0x05800
    MEZZ_EEPROM_ADDR    = 0x50

    # Mezzanine One Wire
    MEZZ_ONEWIRE_ADDR   = 0x05C00

    # ACAM register addresses and expected register contents
    ACAM_READBACK_ADDR = [0x40, 0x44, 0x48, 0x4C, 0X50, 0x54, 0x58, 0x5C, 0x60, 0x64, 0x68, 0x6C, 0x70, 0x78]
    ACAM_READBACK_REGS = [0xC1F0FC81, 0xC0000000, 0xC0000E02, 0xC0000000, 0xC200000F, 0xC00007D0, 0xC00000FC, 0xC0001FEA, 0x00000000, 0x00000000, 0x00000000, 0xC0FF0000, 0xC4000800, 0xC0000000]

    # DMA length in bytes
    DMA_LENGTH = 4096

    # Write pointer register
    WP_MASK = 0xFFF
    WP_OVERFLOW_MASK = 0xFFFFF000

    # Timestamp meta-data
    META_CHANNEL_MASK = 0x07 #0xF
    META_SLOPE_MASK = 0x10 #0xF0
    META_FIFO_LF_MASK = 0xF00
    META_FIFO_EF_MASK = 0xF000
    META_SLOPE = ['falling', 'rising']


###############################################################################################


    def __init__(self, bus):
        # Objects delcaration
        self.bus = bus;
        self.gnum = gn4124.CGN4124(self.bus, self.GNUM_CSR_ADDR)
        self.tdc_regs = csr.CCSR(self.bus, self.TDC_CORE_ADDR)
        self.irq_controller = csr.CCSR(self.bus, self.IRQ_CONTROLLER_ADDR)
        self.carrier_csr = csr.CCSR(self.bus, self.CARRIER_CSR_ADDR)

        # Set GNUM local bus frequency
        self.gnum.set_local_bus_freq(160)
        print "Gennum local bus clock %d MHz"%(self.gnum.get_local_bus_freq())
        time.sleep(2)

        # Reset FPGA
        print "Resetting FPGA"
        self.gnum.rstout33_cycle()
        time.sleep(3)

	# I2C mezzanine
        self.mezz_i2c = i2c.COpenCoresI2C(self.bus, self.MEZZ_I2C_ADDR, 249)
        self.mezz_eeprom_24aa64 = eeprom_24aa64.C24AA64(self.mezz_i2c, self.MEZZ_EEPROM_ADDR)

	# One Wire mezzanine
	self.mezz_onewire = onewire.COpenCoresOneWire(self.bus, self.MEZZ_ONEWIRE_ADDR, 624, 124)
        self.mezz_ds18b20 = ds18b20.CDS18B20(self.mezz_onewire, 0)

	# One Wire carrier
	self.carr_onewire = onewire.COpenCoresOneWire(self.bus, self.CARR_ONEWIRE_ADDR, 624, 124)
        self.carr_ds18b20 = ds18b20.CDS18B20(self.carr_onewire, 0)

        # Get physical addresses of the memory pages for DMA transfer
        self.dma_pages = self.gnum.get_physical_addr()


###############################################################################################

    # Read bitstream type
    def read_bitstream_type(self):
        return self.carrier_csr.rd_reg(0x04)

    # Returns mezzanine unique ID
    def mezz_get_unique_id(self):
        return self.mezz_ds18b20.read_serial_number()


    # Returns mezzanine temperature
    def mezz_get_temp(self):
        serial_number = self.mezz_ds18b20.read_serial_number()
        if(serial_number == -1):
            return -1
        else:
            return self.mezz_ds18b20.read_temp(serial_number)


    # Returns carrier unique ID
    def carr_get_unique_id(self):
        return self.carr_ds18b20.read_serial_number()


    # Returns carrier temperature
    def carr_get_temp(self):
        serial_number = self.carr_ds18b20.read_serial_number()
        if(serial_number == -1):
            return -1
        else:
            return self.carr_ds18b20.read_temp(serial_number)


    # scan FMC i2c bus
    def mezz_i2c_scan(self):
        print 'Scanning I2C bus...',
        return self.mezz_i2c.scan()

    # write to EEPROM on system i2c bus
    def mezz_i2c_eeprom_write(self, addr, data):
        return self.mezz_eeprom_24aa64.wr_data(addr, data)

    # read from  EEPROM on system i2c bus
    def mezz_i2c_eeprom_read(self, addr, size):
        return self.mezz_eeprom_24aa64.rd_data(addr, size)


    # Configures ACAM    
    def config_acam(self):
        print "Loading ACAM and TDC core registers"
        self.tdc_regs.wr_reg(0x00, 0x1F0FC81)
        self.tdc_regs.wr_reg(0x04, 0x0)
        self.tdc_regs.wr_reg(0x08, 0xE02)
        self.tdc_regs.wr_reg(0x0C, 0x0)
        self.tdc_regs.wr_reg(0x10, 0x200000F)
        self.tdc_regs.wr_reg(0x14, 0x7D0)
        self.tdc_regs.wr_reg(0x18, 0x3)
        self.tdc_regs.wr_reg(0x1C, 0x1FEA)
        self.tdc_regs.wr_reg(0x2C, 0xFF0000)
        self.tdc_regs.wr_reg(0x30, 0x4000000)
        self.tdc_regs.wr_reg(0x38, 0x0)
        self.tdc_regs.wr_reg(0xFC, 0x4)
        time.sleep(1)

    def load_acam_config(self):
        print "Loading ACAM configuration"
        self.tdc_regs.wr_reg(0xFC, 0x4)
        time.sleep(1)

    def reset_acam(self):
        print "Reseting ACAM"
        self.tdc_regs.wr_reg(0xFC, 0x100)
        time.sleep(1)


   # Configures DAC and PLL
    def configure_mezz_dac(self, dac_word):
        print "Configuring mezzanine DAC"
        self.tdc_regs.wr_reg(0x98, dac_word)
        self.tdc_regs.wr_reg(0xFC, 0x800)
        time.sleep(2)


#    def readback_acam_config(self):
#        self.tdc_regs.wr_reg(0xFC, 0x8)
#        time.sleep(1)
#        acam_regs = []
#        for i in range(len(self.ACAM_READBACK_REGS)):
#            acam_regs.append (self.tdc_regs.rd_reg(i))
#            if (self.tdc_regs.rd_reg(i) == self.ACAM_READBACK_REGS[i]):
#                print "ACAM IC8: reg 0x%02X: 0x%08X OK"%(i, self.tdc_regs.rd_reg(i))
#            else:
#                print "ERROR! ACAM IC8: reg 0x%02X: received 0x%08X; expected 0x%08X"%(i, self.tdc_regs.rd_reg(i), self.ACAM_READBACK_REGS[i])
#        return acam_regs


    def readback_acam_config(self):
        self.tdc_regs.wr_reg(0xFC, 0x8)
        time.sleep(1)
        acam_regs = []
        for i in self.ACAM_READBACK_ADDR:
            acam_regs.append (self.tdc_regs.rd_reg(i))
            #print "ACAM IC8: reg 0x%02X: 0x%08X OK"%(i, self.tdc_regs.rd_reg(i))
        return acam_regs

    # Read ACAM status register
    def read_acam_status(self):
        self.tdc_regs.wr_reg(0xFC, 0x10)
        return self.tdc_regs.rd_reg(0x70)

    def enable_channels(self):
        print "Enabling channels"
        self.tdc_regs.wr_bit(0x84, 7, 1)

    def disable_channels(self):
        print "Disabling channels"
        self.tdc_regs.wr_bit(0x84, 7, 0)

    def channel_term(self, channel, enable):
        self.tdc_regs.wr_bit(0x84, channel-1, enable)
        #print "0x%08X"%self.tdc_regs.rd_reg(0x84)

    def set_utc(self, utc):
        self.tdc_regs.wr_reg(0x80, utc)
        self.tdc_regs.wr_reg(0xFC, 0x200)

    def get_utc(self):
        return self.tdc_regs.rd_reg(0xA0)

    def start_acq(self):
        self.tdc_regs.wr_reg(0xFC, 0x1)
        print "Aquisition started!"


    def tdc_core_test(self):
        for i in range(0,150,4):
            print "Iteration %d: reg[%.3X]: 0x%.8X" %(i/4, i, self.tdc_regs.rd_reg(i))
            time.sleep(0.5)
        return self.tdc_regs.rd_reg(0xFC)


    #...dummy...#
    def generate_dummy_irq(self):
        self.tdc_regs.wr_reg(0xFC, 0x80000000)
        print "Generating dummy IRQ.."
    #...dummy...#



    def set_irq_tstamp_thresh(self,tstamp_thresh):
        print "Setting IRQ timestamps threshold"
        self.tdc_regs.wr_reg(0x90, tstamp_thresh) # irq tstaps threshold; only 9 LSbits are significant

    def set_irq_time_thresh(self, time_thresh):
        print "Setting IRQ time threshold"
        self.tdc_regs.wr_reg(0x94, time_thresh) # irq time (sec) threshold

    def stop_acq(self):
        self.tdc_regs.wr_reg(0xFC, 0x2)
        print "Aquisition stopped."

    def get_pointer(self):
        return (self.WP_MASK & self.tdc_regs.rd_reg(0xA8))

    def get_overflow_counter(self):
        return ((self.WP_OVERFLOW_MASK & self.tdc_regs.rd_reg(0xA8)) >> 12)

    # Set IRQ enable mask
    def set_irq_en_mask(self, mask):
        self.irq_controller.wr_reg(self.IRQ_CTRL_EN_MASK, mask)
        return self.irq_controller.rd_reg(self.IRQ_CTRL_EN_MASK)

    # Get IRQ source
    def get_irq_src(self):
        return self.irq_controller.rd_reg(self.IRQ_CTRL_SRC)

    # Clear IRQ source
    def clear_irq_src(self, src):
        self.irq_controller.wr_bit(self.IRQ_CTRL_SRC, src, 1)

    # Check for IRQs
    def check_irq(self, verbose=0):
        self.gnum.irq_en()
        self.gnum.wait_irq()
        if(verbose):
            print('#################!!!!GN4124 interrupt occured!!!!#################')


    def get_timestamps(self, verbose=0):
        # Read the number of bytes to be read from the board
        dma_length_tmp = self.get_pointer()
        if dma_length_tmp == 0: # add overflow> 0 
            dma_length = 4096
        else:
            dma_length = dma_length_tmp
        carrier_addr = 0x0

        # Calculate the number of DMA item required to get the data
        items_required = int(math.ceil(dma_length/float(self.DMA_LENGTH)))
        if(128 < items_required):
            print('Required items: %d')%items_required
            raise Exception('Current gn4124 class only supports up to 128 items.')
        if(verbose):
            print('Required items: %d')%items_required

        # Configure DMA
        for num in range(items_required):
            if(items_required == num+1):
                next_item = 0
                item_length = (dma_length-(num*self.DMA_LENGTH))
            else:
                next_item = 1
                item_length = self.DMA_LENGTH
            if(0 == num):
                item_start_addr = carrier_addr
            else:
                item_start_addr = carrier_addr + (num*self.DMA_LENGTH)
            if(verbose):
                print("item nb:%d item_carrier_addr:0x%.8X item_host_addr:0x%.8X item_length:%d next_item:%d)")%(num,item_start_addr,self.dma_pages[num+1],item_length,next_item)
            self.gnum.add_dma_item(item_start_addr, self.dma_pages[num+1], item_length, 0, next_item)
        if(verbose):
            if(items_required > 1):
                items = self.gnum.get_memory_page(0)
                print('DMA items:')
                for i in range(items_required*8):
                    print('%.4X: %.8X')%(i*4,items[i])

        # Start DMA
        dma_finished = 0
        if(verbose):
            print "Start DMA"
        self.gnum.start_dma()

        """
        # Poll on DMA status
        print "Wait for DMA done"
        while('Done' == self.gnum.get_dma_status()):
            time.sleep(0.01)
        print "DMA done!"
        """

        # Wait for end of DMA interrupt
        if(verbose):
            print('Wait GN4124 interrupt')
        self.gnum.wait_irq()
        if(verbose):
            print('GN4124 interrupt occured')
        """
        print('irq mask:%.4X')%self.get_irq_en_mask() if(verbose)
        while(0 == dma_finished):
            irq_src = self.get_irq_source()
            if(verbose):
                print('IRQ source : %.4X')%irq_src
                print('DMA status: %s')%self.gnum.get_dma_status()
            if(irq_src & self.IRQ_SRC_DMA_END):
                print('IRQ source : %.4X')%irq_src if(verbose)
                self.clear_irq_source(self.IRQ_SRC_DMA_END)
                print('IRQ source : %.4X')%self.get_irq_source() if(verbose)
                dma_finished = 1
            time.sleep(0.005)
        print('DMA finished!') if(verbose)
        """
        # Retrieve data from host memory
        data = []
        for i in range(items_required):
            data += self.gnum.get_memory_page(i+1)
        if(verbose):
            print('data length:%d')%(len(data)*4)
            for i in range(len(data)):
                print data[i]

        # Format timestamps
        if(verbose):
            print "Timestamps retreived:"
        raw_timestamps = []
        timestamps = []
        for i in range(0,dma_length/4,4):
            # timestamp value
            timestamp = data[i+2] * 1E12 + data[i+1] * 8E3 + data[i] * 81.03
            # timestamp metadata
            channel = self.META_CHANNEL_MASK & data[i+3]
            slope = ((self.META_SLOPE_MASK & data[i+3]) >> 4)
            fifo_lf = ((self.META_FIFO_LF_MASK & data[i+3]) >> 8)
            fifo_ef = ((self.META_FIFO_EF_MASK & data[i+3]) >> 12)
            # putting everything together
            raw_timestamps.append((data[i+3]<<96)+(data[i+2]<<64)+(data[i+1]<<32)+data[i])
            timestamps.append([timestamp, channel, slope, fifo_lf, fifo_ef])
            #if(verbose):
            #    print "[%03d] sec:%20.3f channel:%d slope:%7s fifo_lf:%d fifo_ef:%d"%(i/4,timestamp, channel, self.META_SLOPE[slope], fifo_lf, fifo_ef)


        eurika = 0
        for i in range(0,dma_length/4,8):
            # for debug check if UTC second changes
            if (data[i+2] != data[i+6]):
                print "Euriika! second changed in these timestamps"
                eurika = 1

        if(verbose):
            print "Number of timestamps = %d" % (len(timestamps))
            for i in range(len(timestamps)):
                print timestamps[i]

        return timestamps, data, eurika


if __name__ == '__main__' :
    main()
