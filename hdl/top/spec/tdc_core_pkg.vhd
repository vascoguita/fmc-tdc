--_________________________________________________________________________________________________
--                                                                                                |
--                                           |TDC core|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                         tdc_core_pkg                                           |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         tdc_core_pkg.vhd                                                                  |
--                                                                                                |
-- Description  Package containing core wide constants and components                             |
--                                                                                                |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
--              Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
-- Date         04/2012                                                                           |
-- Version      v0.2                                                                              |
-- Depends on                                                                                     |
--                                                                                                |
----------------                                                                                  |
-- Last changes                                                                                   |
--     07/2011  v0.1  GP  First version                                                           |
--     04/2012  v0.2  EG  Revamping; Gathering of all the constants, declarations of all the      |
--                        units; Comments added, signals renamed                                  |
--                                                                                                |
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--                               GNU LESSER GENERAL PUBLIC LICENSE                                |
--                              ------------------------------------                              |
-- This source file is free software; you can redistribute it and/or modify it under the terms of |
-- the GNU Lesser General Public License as published by the Free Software Foundation; either     |
-- version 2.1 of the License, or (at your option) any later version.                             |
-- This source is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;       |
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.      |
-- See the GNU Lesser General Public License for more details.                                    |
-- You should have received a copy of the GNU Lesser General Public License along with this       |
-- source; if not, download it from http://www.gnu.org/licenses/lgpl-2.1.html                     |
---------------------------------------------------------------------------------------------------



--=================================================================================================
--                                      Libraries & Packages
--=================================================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.all; -- std_logic definitions
use IEEE.NUMERIC_STD.all;    -- conversion functions
use work.wishbone_pkg.all;
use work.sdb_meta_pkg.all;



--=================================================================================================
--                              Package declaration for tdc_core_pkg
--=================================================================================================
package tdc_core_pkg is

---------------------------------------------------------------------------------------------------
--                      Constant regarding the Mezzanine DAC configuration                       --
---------------------------------------------------------------------------------------------------
  -- Vout = Vref (DAC_WORD/ 65536); for Vout = 1.65V, with Vref = 2.5V the DAC_WORD = xA8F5
  constant c_DEFAULT_DAC_WORD : std_logic_vector(23 downto 0) := x"00A8F5";


---------------------------------------------------------------------------------------------------
--                              Constants regarding the SDB crossbar                             --
---------------------------------------------------------------------------------------------------
-- Note: All address in sdb and crossbar are BYTE addresses!
-- Note: All address in sdb and crossbar are BYTE addresses!

-- Master ports on the wishbone crossbar
  constant c_NUM_WB_MASTERS    : integer := 7;
  constant c_SLAVE_DMA         : integer := 0;  -- DMA controller in the Gennum core
  constant c_SLAVE_SPEC_ONEWIRE: integer := 1;  -- Carrier onewire interface
  constant c_SLAVE_SPEC_CSR    : integer := 2;  -- Info on SPEC control and status registers
  constant c_SLAVE_TDC_CORE    : integer := 3;  -- TDC core
  constant c_SLAVE_INT         : integer := 4;  -- Interrupt controller
  constant c_SLAVE_FMC_SYS_I2C : integer := 5;  -- Mezzanine system I2C interface (EEPROM)
  constant c_SLAVE_FMC_ONEWIRE : integer := 6;  -- Mezzanine onewire interface 

-- Slave port on the wishbone crossbar
  constant c_NUM_WB_SLAVES     : integer := 1;
  constant c_MASTER_GENNUM     : integer := 0;

  -- SDB header address
  constant c_SDB_ADDRESS : t_wishbone_address := x"00000000";

  -- Devices sdb description
  constant c_DMA_SDB_DEVICE : t_sdb_device :=
    (abi_class     => x"0000",               -- undocumented device
     abi_ver_major => x"01",
     abi_ver_minor => x"01",
     wbd_endian    => c_sdb_endian_big,
     wbd_width     => x"4",                  -- 32-bit port granularity
     sdb_component =>
       (addr_first  => x"0000000000000000",
        addr_last   => x"000000000000003F",
        product     =>
          (vendor_id => x"000000000000CE42", -- CERN
           device_id => x"00000601",
           version   => x"00000001",
           date      => x"20121116",
           name      => "WB-DMA.Control     ")));

  constant c_ONEWIRE_SDB_DEVICE : t_sdb_device :=
    (abi_class     => x"0000",               -- undocumented device
     abi_ver_major => x"01",
     abi_ver_minor => x"01",
     wbd_endian    => c_sdb_endian_big,
     wbd_width     => x"4",                  -- 32-bit port granularity
     sdb_component =>
       (addr_first  => x"0000000000000000",
        addr_last   => x"0000000000000007",
        product     =>
          (vendor_id => x"000000000000CE42", -- CERN
           device_id => x"00000602",
           version   => x"00000001",
           date      => x"20121116",
           name      => "WB-Onewire.Control ")));

  constant c_SPEC_CSR_SDB_DEVICE : t_sdb_device :=
    (abi_class     => x"0000",               -- undocumented device
     abi_ver_major => x"01",
     abi_ver_minor => x"01",
     wbd_endian    => c_sdb_endian_big,
     wbd_width     => x"4",                  -- 32-bit port granularity
     sdb_component =>
       (addr_first  => x"0000000000000000",
        addr_last   => x"000000000000001F",
        product     =>
          (vendor_id => x"000000000000CE42", -- CERN
           device_id => x"00000603",
           version   => x"00000001",
           date      => x"20121116",
           name      => "WB-SPEC-CSR        ")));

  constant c_TDC_SDB_DEVICE : t_sdb_device :=
    (abi_class     => x"0000",               -- undocumented device
     abi_ver_major => x"01",
     abi_ver_minor => x"01",
     wbd_endian    => c_sdb_endian_big,
     wbd_width     => x"4",                  -- 32-bit port granularity
     sdb_component =>
       (addr_first  => x"0000000000000000",
        addr_last   => x"00000000000001FF",
        product     =>
          (vendor_id => x"000000000000CE42", -- CERN
           device_id => x"00000604",
           version   => x"00000001",
           date      => x"20130429",
           name      => "WB-TDC-Core        ")));

  constant c_TDC_EIC_DEVICE : t_sdb_device :=
    (abi_class     => x"0000",               -- undocumented device
     abi_ver_major => x"01",
     abi_ver_minor => x"01",
     wbd_endian    => c_sdb_endian_big,
     wbd_width     => x"4",                  -- 32-bit port granularity
     sdb_component =>
       (addr_first  => x"0000000000000000",
        addr_last   => x"000000000000000F",
        product     =>
          (vendor_id => x"000000000000CE42", -- CERN
           device_id => x"00000605",         -- !!!!!"WB-FMC-ADC.EIC     " | md5sum | cut -c1-8
           version   => x"00000001",
           date      => x"20121116",
           name      => "WB-FMC-TDC.EIC     ")));


  constant c_I2C_SDB_DEVICE : t_sdb_device :=
    (abi_class     => x"0000",               -- undocumented device
     abi_ver_major => x"01",
     abi_ver_minor => x"01",
     wbd_endian    => c_sdb_endian_big,
     wbd_width     => x"4",                  -- 32-bit port granularity
     sdb_component =>
       (addr_first  => x"0000000000000000",
        addr_last   => x"000000000000001F",
        product     =>
          (vendor_id => x"000000000000CE42", -- CERN
           device_id => x"00000606",
           version   => x"00000001",
           date      => x"20121116",
           name      => "WB-I2C.Control     ")));

  constant c_DMA_EIC_SDB : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4",                 -- 32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"000000000000000F",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"d5735ab4",          -- echo "WB-DMA.EIC         " | md5sum | cut -c1-8
        version   => x"00000001",
        date      => x"20131204",
        name      => "WB-DMA.EIC         ")));

  constant c_TDC_EIC_SDB : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4",                 -- 32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"000000000000000F",
      product     => (
        vendor_id => x"000000000000CE42",  -- CERN
        device_id => x"26ec6086",          -- "WB-FMC-ADC.EIC     " | md5sum | cut -c1-8
        version   => x"00000001",
        date      => x"20131204",
        name      => "WB-FMC-ADC.EIC     ")));

  constant c_TDC_CONFIG_SDB_DEVICE : t_sdb_device :=
    (abi_class     => x"0000",               -- undocumented device
     abi_ver_major => x"01",
     abi_ver_minor => x"01",
     wbd_endian    => c_sdb_endian_big,
     wbd_width     => x"4",                  -- 32-bit port granularity
     sdb_component =>
       (addr_first  => x"0000000000000000",
        addr_last   => x"00000000000000FF",
        product     =>
          (vendor_id => x"000000000000CE42", -- CERN
           device_id => x"00000604",
           version   => x"00000001",
           date      => x"20130429",
           name      => "WB-TDC-Core-Config ")));


---------------------------------------------------------------------------------------------------
--                           Constants regarding 1 Hz pulse generation                           --
---------------------------------------------------------------------------------------------------

  -- for synthesis: 1 sec = x"07735940" clk_i cycles (1 clk_i cycle = 8ns)
  constant c_SYN_CLK_PERIOD : std_logic_vector(31 downto 0) := x"07735940";

  -- for simulation: 1 msec = x"0001E848" clk_i cycles (1 clk_i cycle = 8ns)
  constant c_SIM_CLK_PERIOD : std_logic_vector(31 downto 0) := x"0001E848";


---------------------------------------------------------------------------------------------------
--                         Vector with the 11 ACAM Configuration Registers                       --
---------------------------------------------------------------------------------------------------
  subtype config_register is std_logic_vector(31 downto 0);
  type config_vector      is array (10 downto 0) of config_register;


---------------------------------------------------------------------------------------------------
--                      Constants regarding addressing of the ACAM registers                     --
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Addresses of ACAM configuration registers to be written by the PCIe host
                                                                     -- corresponds to:
  constant c_ACAM_REG0_ADR  : std_logic_vector(7 downto 0) := x"00"; -- address 5000 of gnum BAR 0
  constant c_ACAM_REG1_ADR  : std_logic_vector(7 downto 0) := x"01"; -- address 5004 of gnum BAR 0
  constant c_ACAM_REG2_ADR  : std_logic_vector(7 downto 0) := x"02"; -- address 5008 of gnum BAR 0
  constant c_ACAM_REG3_ADR  : std_logic_vector(7 downto 0) := x"03"; -- address 500C of gnum BAR 0
  constant c_ACAM_REG4_ADR  : std_logic_vector(7 downto 0) := x"04"; -- address 5010 of gnum BAR 0
  constant c_ACAM_REG5_ADR  : std_logic_vector(7 downto 0) := x"05"; -- address 5014 of gnum BAR 0
  constant c_ACAM_REG6_ADR  : std_logic_vector(7 downto 0) := x"06"; -- address 5018 of gnum BAR 0
  constant c_ACAM_REG7_ADR  : std_logic_vector(7 downto 0) := x"07"; -- address 501C of gnum BAR 0
  constant c_ACAM_REG11_ADR : std_logic_vector(7 downto 0) := x"0B"; -- address 502C of gnum BAR 0
  constant c_ACAM_REG12_ADR : std_logic_vector(7 downto 0) := x"0C"; -- address 5030 of gnum BAR 0
  constant c_ACAM_REG14_ADR : std_logic_vector(7 downto 0) := x"0E"; -- address 5038 of gnum BAR 0


---------------------------------------------------------------------------------------------------
-- Addresses of ACAM read-only registers, to be written by the ACAM and used within the core to access ACAM timestamps
  constant c_ACAM_REG8_ADR  : std_logic_vector(7 downto 0) := x"08"; -- not accessible for writing from PCI-e
  constant c_ACAM_REG9_ADR  : std_logic_vector(7 downto 0) := x"09"; -- not accessible for writing from PCI-e
  constant c_ACAM_REG10_ADR : std_logic_vector(7 downto 0) := x"0A"; -- not accessible for writing from PCI-e


---------------------------------------------------------------------------------------------------
-- Addresses of ACAM configuration readback registers, to be written by the ACAM 
                                                                          -- corresponds to:
  constant c_ACAM_REG0_RDBK_ADR  : std_logic_vector(7 downto 0) := x"10"; -- address 5040 of the gnum BAR 0
  constant c_ACAM_REG1_RDBK_ADR  : std_logic_vector(7 downto 0) := x"11"; -- address 5044 of the gnum BAR 0
  constant c_ACAM_REG2_RDBK_ADR  : std_logic_vector(7 downto 0) := x"12"; -- address 5048 of the gnum BAR 0
  constant c_ACAM_REG3_RDBK_ADR  : std_logic_vector(7 downto 0) := x"13"; -- address 504C of the gnum BAR 0
  constant c_ACAM_REG4_RDBK_ADR  : std_logic_vector(7 downto 0) := x"14"; -- address 5050 of the gnum BAR 0
  constant c_ACAM_REG5_RDBK_ADR  : std_logic_vector(7 downto 0) := x"15"; -- address 5054 of the gnum BAR 0
  constant c_ACAM_REG6_RDBK_ADR  : std_logic_vector(7 downto 0) := x"16"; -- address 5058 of the gnum BAR 0
  constant c_ACAM_REG7_RDBK_ADR  : std_logic_vector(7 downto 0) := x"17"; -- address 505C of the gnum BAR 0
  constant c_ACAM_REG8_RDBK_ADR  : std_logic_vector(7 downto 0) := x"18"; -- address 5060 of the gnum BAR 0
  constant c_ACAM_REG9_RDBK_ADR  : std_logic_vector(7 downto 0) := x"19"; -- address 5064 of the gnum BAR 0
  constant c_ACAM_REG10_RDBK_ADR : std_logic_vector(7 downto 0) := x"1A"; -- address 5068 of the gnum BAR 0
  constant c_ACAM_REG11_RDBK_ADR : std_logic_vector(7 downto 0) := x"1B"; -- address 506C of the gnum BAR 0
  constant c_ACAM_REG12_RDBK_ADR : std_logic_vector(7 downto 0) := x"1C"; -- address 5070 of the gnum BAR 0
  constant c_ACAM_REG14_RDBK_ADR : std_logic_vector(7 downto 0) := x"1E"; -- address 5078 of the gnum BAR 0


---------------------------------------------------------------------------------------------------
--                    Constants regarding addressing of the TDC core registers                   --
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Addresses of TDC core Configuration registers to be written by the PCIe host
                                                                           -- corresponds to:
  constant c_STARTING_UTC_ADR     : std_logic_vector(7 downto 0) := x"20"; -- address 5080 of gnum BAR 0
  constant c_ACAM_INPUTS_EN_ADR   : std_logic_vector(7 downto 0) := x"21"; -- address 5084 of gnum BAR 0
  constant c_START_PHASE_ADR      : std_logic_vector(7 downto 0) := x"22"; -- address 5088 of gnum BAR 0
  constant c_ONE_HZ_PHASE_ADR     : std_logic_vector(7 downto 0) := x"23"; -- address 508C of gnum BAR 0

  constant c_IRQ_TSTAMP_THRESH_ADR: std_logic_vector(7 downto 0) := x"24"; -- address 5090 of gnum BAR 0
  constant c_IRQ_TIME_THRESH_ADR  : std_logic_vector(7 downto 0) := x"25"; -- address 5094 of gnum BAR 0
  constant c_DAC_WORD_ADR         : std_logic_vector(7 downto 0) := x"26"; -- address 5098 of gnum BAR 0

--  constant c_RESERVED1          : std_logic_vector(7 downto 0) := x"27"; -- address 509C of gnum BAR 0

---------------------------------------------------------------------------------------------------
-- Addresses of TDC core Status registers to be written by the different core units
                                                                           -- corresponds to:
  constant c_LOCAL_UTC_ADR        : std_logic_vector(7 downto 0) := x"28"; -- address 50A0 of gnum BAR 0
  constant c_IRQ_CODE_ADR         : std_logic_vector(7 downto 0) := x"29"; -- address 50A4 of gnum BAR 0
  constant c_WR_INDEX_ADR         : std_logic_vector(7 downto 0) := x"2A"; -- address 50A8 of gnum BAR 0
  constant c_CORE_STATUS_ADR      : std_logic_vector(7 downto 0) := x"2B"; -- address 50AC of gnum BAR 0

---------------------------------------------------------------------------------------------------
-- Address of TDC core Control register
                                                                           -- corresponds to:
  constant c_CTRL_REG_ADR         : std_logic_vector(7 downto 0) := x"3F"; -- address 50FC of gnum BAR 0


---------------------------------------------------------------------------------------------------
--                              Constants regarding ACAM retriggers                              --
---------------------------------------------------------------------------------------------------
  -- Number of clk_i cycles corresponding to the Acam retrigger period;
  -- through Acam Reg 4 StartTimer the chip is programmed to retrigger every:
  -- (15+1) * acam_ref_clk = (15+1) * 32 ns 
  -- x"00000040" * clk_i   =  64    * 8  ns
  -- 512 ns
  constant c_ACAM_RETRIG_PERIOD       : std_logic_vector(31 downto 0) := x"00000040";

  -- Used to multiply by 64, which is the retrigger period in clk_i cycles
  constant c_ACAM_RETRIG_PERIOD_SHIFT : integer :=  6;


---------------------------------------------------------------------------------------------------
--                              Constants regarding TDC & SPEC LEDs                              --
---------------------------------------------------------------------------------------------------

  constant c_SPEC_LED_PERIOD_SIM : std_logic_vector(31 downto 0) := x"00004E20"; -- 1   ms at 20  MHz
  constant c_SPEC_LED_PERIOD_SYN : std_logic_vector(31 downto 0) := x"01312D00"; -- 1    s at 20  MHz
  constant c_BLINK_LGTH_SYN      : std_logic_vector(31 downto 0) := x"00BEBC20"; -- 100 ms at 125 MHz
  constant c_BLINK_LGTH_SIM      : std_logic_vector(31 downto 0) := x"000004E2"; -- 10  us at 125 MHz
--c_RESET_WORD


---------------------------------------------------------------------------------------------------
--                            Constants regarding the Circular Buffer                            --
---------------------------------------------------------------------------------------------------
  constant c_CIRCULAR_BUFF_SIZE : unsigned(31 downto 0) := x"00000100";


---------------------------------------------------------------------------------------------------
--                           Constants regarding the One-Wire interface                          --
---------------------------------------------------------------------------------------------------
  constant c_FMC_ONE_WIRE_NB   : integer := 1;


---------------------------------------------------------------------------------------------------
--                            Constants regarding the Carrier CSR info                           --
---------------------------------------------------------------------------------------------------
  constant c_CARRIER_TYPE   : std_logic_vector(15 downto 0) := X"0001";




---------------------------------------------------------------------------------------------------
--                                      Components Declarations:                                 --
---------------------------------------------------------------------------------------------------

  component fmc_tdc_mezzanine is
  generic
    (g_span                 : integer := 32;
     g_width                : integer := 32;
     values_for_simul       : boolean := FALSE);
  port
    (-- TDC core
     clk_125m_i             : in    std_logic;
     rst_i                  : in    std_logic;
     acam_refclk_r_edge_p_i : in    std_logic;
     send_dac_word_p_o      : out   std_logic;
     dac_word_o             : out   std_logic_vector(23 downto 0);
     start_from_fpga_o      : out   std_logic;
     err_flag_i             : in    std_logic;
     int_flag_i             : in    std_logic;
     start_dis_o            : out   std_logic;
     stop_dis_o             : out   std_logic;
     data_bus_io            : inout std_logic_vector(27 downto 0);
     address_o              : out   std_logic_vector(3 downto 0);
     cs_n_o                 : out   std_logic;
     oe_n_o                 : out   std_logic;
     rd_n_o                 : out   std_logic;
     wr_n_o                 : out   std_logic;
     ef1_i                  : in    std_logic;
     ef2_i                  : in    std_logic;
     tdc_in_fpga_1_i        : in    std_logic;
     tdc_in_fpga_2_i        : in    std_logic;
     tdc_in_fpga_3_i        : in    std_logic;
     tdc_in_fpga_4_i        : in    std_logic;
     tdc_in_fpga_5_i        : in    std_logic;
     enable_inputs_o        : out   std_logic;
     term_en_1_o            : out   std_logic;
     term_en_2_o            : out   std_logic;
     term_en_3_o            : out   std_logic;
     term_en_4_o            : out   std_logic;
     term_en_5_o            : out   std_logic;
     tdc_led_status_o       : out   std_logic;
     tdc_led_trig1_o        : out   std_logic;
     tdc_led_trig2_o        : out   std_logic;
     tdc_led_trig3_o        : out   std_logic;
     tdc_led_trig4_o        : out   std_logic;
     tdc_led_trig5_o        : out   std_logic;
     -- WISHBONE interface with the GNUM/VME_core
     -- for the core configuration | core interrupts | 1Wire | I2C 
     wb_tdc_csr_adr_i       : in    std_logic_vector(31 downto 0);
     wb_tdc_csr_dat_i      : in    std_logic_vector(31 downto 0);
     wb_tdc_csr_cyc_i       : in    std_logic;
     wb_tdc_csr_sel_i       : in    std_logic_vector(3 downto 0);
     wb_tdc_csr_stb_i       : in    std_logic;
     wb_tdc_csr_we_i        : in    std_logic;
     wb_tdc_csr_dat_o       : out   std_logic_vector(31 downto 0);
     wb_tdc_csr_ack_o       : out   std_logic;
     wb_tdc_csr_stall_o     : out   std_logic;
     wb_irq_o               : out   std_logic;
     -- WISHBONE interface with the GNUM DMA/VME_core
     -- for the retreival of the timestamps
     wb_tdc_mem_adr_i       : in    std_logic_vector(31 downto 0); 
     wb_tdc_mem_dat_i       : in    std_logic_vector(31 downto 0);
     wb_tdc_mem_cyc_i       : in    std_logic;
     wb_tdc_mem_stb_i       : in    std_logic;
     wb_tdc_mem_we_i        : in    std_logic;
     wb_tdc_mem_dat_o       : out   std_logic_vector(31 downto 0);
     wb_tdc_mem_ack_o       : out   std_logic;
     wb_tdc_mem_stall_o     : out   std_logic;
     -- Interrupt pulses, for debug
     irq_tstamp_p_o         : out   std_logic;
     irq_time_p_o           : out   std_logic;
     irq_acam_err_p_o       : out   std_logic;
     -- I2C EEPROM interface
     sys_scl_b              : inout std_logic;
     sys_sda_b              : inout std_logic;
     -- 1-wire UniqueID&Thermometer interface
     one_wire_b             : inout std_logic);
  end component;


---------------------------------------------------------------------------------------------------
  component fmc_tdc_core
  generic
    (g_span              : integer := 32;
     g_width             : integer := 32;
     values_for_simul    : boolean := FALSE);
  port
    (clk_125m_i          : in std_logic;
     rst_i               : in  std_logic;
     acam_refclk_r_edge_p_i :in  std_logic;
     send_dac_word_p_o   : out  std_logic;
     dac_word_o          : out std_logic_vector(23 downto 0);
     start_from_fpga_o   : out std_logic;
     err_flag_i          : in std_logic; 
     int_flag_i          : in std_logic; 
     start_dis_o         : out std_logic;
     stop_dis_o          : out std_logic;
     data_bus_io         : inout std_logic_vector(27 downto 0);
     address_o           : out std_logic_vector(3 downto 0);
     cs_n_o              : out std_logic;
     oe_n_o              : out std_logic;
     rd_n_o              : out std_logic;
     wr_n_o              : out std_logic;
     ef1_i               : in std_logic;
     ef2_i               : in std_logic;
     tdc_in_fpga_1_i     : in std_logic;
     tdc_in_fpga_2_i     : in std_logic;
     tdc_in_fpga_3_i     : in std_logic;
     tdc_in_fpga_4_i     : in std_logic;
     tdc_in_fpga_5_i     : in std_logic;
     enable_inputs_o     : out std_logic;
     term_en_1_o         : out std_logic;
     term_en_2_o         : out std_logic;
     term_en_3_o         : out std_logic;
     term_en_4_o         : out std_logic;
     term_en_5_o         : out std_logic;
     tdc_led_status_o    : out std_logic;
     tdc_led_trig1_o     : out std_logic;
     tdc_led_trig2_o     : out std_logic;
     tdc_led_trig3_o     : out std_logic;
     tdc_led_trig4_o     : out std_logic;
     tdc_led_trig5_o     : out std_logic;
     irq_tstamp_p_o      : out std_logic;
     irq_time_p_o        : out std_logic;
     irq_acam_err_p_o    : out std_logic;
     tdc_config_wb_adr_i : in std_logic_vector(g_span-1 downto 0);
     tdc_config_wb_dat_i : in std_logic_vector(g_width-1 downto 0);
     tdc_config_wb_stb_i : in std_logic;
     tdc_config_wb_we_i  : in std_logic;
     tdc_config_wb_cyc_i : in std_logic;
     tdc_config_wb_dat_o : out std_logic_vector(g_width-1 downto 0);
     tdc_config_wb_ack_o : out std_logic;
     tdc_mem_wb_adr_i    : in std_logic_vector(31 downto 0);
     tdc_mem_wb_dat_i    : in std_logic_vector(31 downto 0);
     tdc_mem_wb_stb_i    : in std_logic;
     tdc_mem_wb_we_i     : in std_logic;
     tdc_mem_wb_cyc_i    : in std_logic;
     tdc_mem_wb_ack_o    : out std_logic;
     tdc_mem_wb_dat_o    : out std_logic_vector(31 downto 0);
     tdc_mem_wb_stall_o  : out std_logic); 
  end component;



---------------------------------------------------------------------------------------------------
  component decr_counter
    generic
      (width             : integer := 32);
    port
      (clk_i             : in std_logic;
       rst_i             : in std_logic;
       counter_load_i    : in std_logic;
       counter_top_i     : in std_logic_vector(width-1 downto 0);
      -------------------------------------------------------------
       counter_is_zero_o : out std_logic;
       counter_o         : out std_logic_vector(width-1 downto 0));
      -------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component free_counter is
    generic
      (width             : integer := 32);
    port
      (clk_i             : in std_logic;
       counter_en_i      : in std_logic;
       rst_i             : in std_logic;
       counter_top_i     : in std_logic_vector(width-1 downto 0);
      -------------------------------------------------------------
       counter_is_zero_o : out std_logic;
       counter_o         : out std_logic_vector(width-1 downto 0));
      -------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component incr_counter
    generic
      (width             : integer := 32);
    port
      (clk_i             : in std_logic;
       counter_top_i     : in std_logic_vector(width-1 downto 0);
       counter_incr_en_i : in std_logic;
       rst_i             : in std_logic;
      -------------------------------------------------------------
       counter_is_full_o : out std_logic;
       counter_o         : out std_logic_vector(width-1 downto 0));
      ------------------------------------------------------------- 
 end component;
---------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
  component start_retrig_ctrl
    generic
      (g_width                 : integer := 32);
    port
      (clk_i                   : in std_logic;
       rst_i                   : in std_logic;
       acam_intflag_f_edge_p_i : in std_logic;
       one_hz_p_i              : in std_logic;
      ----------------------------------------------------------------------
       roll_over_incr_recent_o : out std_logic;
       clk_i_cycles_offset_o   : out std_logic_vector(g_width-1 downto 0);
       roll_over_nb_o          : out std_logic_vector(g_width-1 downto 0);
       retrig_nb_offset_o      : out std_logic_vector(g_width-1 downto 0));
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component one_hz_gen
    generic
      (g_width                : integer := 32);
    port
      (acam_refclk_r_edge_p_i : in std_logic;
       clk_i                  : in std_logic;
       clk_period_i           : in std_logic_vector(g_width-1 downto 0);
       load_utc_p_i           : in std_logic;
       pulse_delay_i          : in std_logic_vector(g_width-1 downto 0);
       rst_i                  : in std_logic;
       starting_utc_i         : in std_logic_vector(g_width-1 downto 0);
      ----------------------------------------------------------------------
       local_utc_o            : out std_logic_vector(g_width-1 downto 0);
       one_hz_p_o             : out std_logic);
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component data_engine
    port
      (acam_ack_i            : in std_logic;
       acam_dat_i            : in std_logic_vector(31 downto 0);
       clk_i                 : in std_logic;
       rst_i                 : in std_logic;
       acam_ef1_i            : in std_logic;
       acam_ef1_meta_i     : in std_logic;
       acam_ef2_i            : in std_logic;
       acam_ef2_meta_i     : in std_logic;
       activate_acq_p_i      : in std_logic;
       deactivate_acq_p_i    : in std_logic;
       acam_wr_config_p_i    : in std_logic;
       acam_rdbk_config_p_i  : in std_logic;
       acam_rdbk_status_p_i  : in std_logic;
       acam_rdbk_ififo1_p_i  : in std_logic;
       acam_rdbk_ififo2_p_i  : in std_logic;
       acam_rdbk_start01_p_i : in std_logic;
       acam_rst_p_i          : in std_logic;
       acam_config_i         : in config_vector;
      ----------------------------------------------------------------------
       acam_adr_o            : out std_logic_vector(7 downto 0);
       acam_cyc_o            : out std_logic;
       acam_dat_o            : out std_logic_vector(31 downto 0);
       acam_stb_o            : out std_logic;
       acam_we_o             : out std_logic;
       acam_config_rdbk_o    : out config_vector;
       acam_status_o         : out std_logic_vector(31 downto 0);
       acam_ififo1_o         : out std_logic_vector(31 downto 0);
       acam_ififo2_o         : out std_logic_vector(31 downto 0);
       acam_start01_o        : out std_logic_vector(31 downto 0);
       acam_tstamp1_o        : out std_logic_vector(31 downto 0);
       acam_tstamp1_ok_p_o   : out std_logic;
       acam_tstamp2_o        : out std_logic_vector(31 downto 0);
       acam_tstamp2_ok_p_o   : out std_logic);
      ----------------------------------------------------------------------
  end component;



---------------------------------------------------------------------------------------------------
  component reg_ctrl
    generic
      (g_span                 : integer := 32;
       g_width                : integer := 32);
    port
      (clk_i                  : in std_logic;
       rst_i                  : in std_logic;
       tdc_config_wb_adr_i    : in std_logic_vector(g_span-1 downto 0);
       tdc_config_wb_cyc_i    : in std_logic;
       tdc_config_wb_dat_i    : in std_logic_vector(g_width-1 downto 0);
       tdc_config_wb_stb_i    : in std_logic;
       tdc_config_wb_we_i     : in std_logic;
       acam_config_rdbk_i     : in config_vector;
       acam_status_i          : in std_logic_vector(g_width-1 downto 0);
       acam_ififo1_i          : in std_logic_vector(g_width-1 downto 0);
       acam_ififo2_i          : in std_logic_vector(g_width-1 downto 0);
       acam_start01_i         : in std_logic_vector(g_width-1 downto 0);
       local_utc_i            : in std_logic_vector(g_width-1 downto 0);
       irq_code_i             : in std_logic_vector(g_width-1 downto 0);
       wr_index_i             : in std_logic_vector(g_width-1 downto 0);
       core_status_i          : in std_logic_vector(g_width-1 downto 0);
      ----------------------------------------------------------------------
       tdc_config_wb_ack_o    : out std_logic;
       tdc_config_wb_dat_o    : out std_logic_vector(g_width-1 downto 0);
       activate_acq_p_o       : out std_logic;
       deactivate_acq_p_o     : out std_logic;
       acam_wr_config_p_o     : out std_logic;
       acam_rdbk_config_p_o   : out std_logic;
       acam_rdbk_status_p_o   : out std_logic;
       acam_rdbk_ififo1_p_o   : out std_logic;
       acam_rdbk_ififo2_p_o   : out std_logic;
       acam_rdbk_start01_p_o  : out std_logic;
       acam_rst_p_o           : out std_logic;
       load_utc_p_o           : out std_logic;
       irq_tstamp_threshold_o : out std_logic_vector(g_width-1 downto 0);
       irq_time_threshold_o   : out std_logic_vector(g_width-1 downto 0);
       send_dac_word_p_o      : out std_logic; 
       dac_word_o             : out std_logic_vector(23 downto 0);
       dacapo_c_rst_p_o       : out std_logic;
       acam_config_o          : out config_vector;
       starting_utc_o         : out std_logic_vector(g_width-1 downto 0);
       acam_inputs_en_o       : out std_logic_vector(g_width-1 downto 0);
       start_phase_o          : out std_logic_vector(g_width-1 downto 0);
       one_hz_phase_o         : out std_logic_vector(g_width-1 downto 0));
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component acam_timecontrol_interface
    port
      (err_flag_i              : in std_logic;
       int_flag_i              : in std_logic;
       acam_refclk_r_edge_p_i  : in std_logic;
       clk_i                   : in std_logic;
       activate_acq_p_i        : in std_logic;
       rst_i                   : in std_logic;
       window_delay_i          : in std_logic_vector(31 downto 0);
      ----------------------------------------------------------------------
       start_from_fpga_o       : out std_logic;
       acam_errflag_r_edge_p_o : out std_logic;
       acam_errflag_f_edge_p_o : out std_logic;
       acam_intflag_f_edge_p_o : out std_logic);
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component data_formatting
    port
      (tstamp_wr_wb_ack_i      : in std_logic;
       tstamp_wr_dat_i         : in std_logic_vector(127 downto 0);
       acam_tstamp1_i          : in std_logic_vector(31 downto 0);
       acam_tstamp1_ok_p_i     : in std_logic;
       acam_tstamp2_i          : in std_logic_vector(31 downto 0);
       acam_tstamp2_ok_p_i     : in std_logic;
       clk_i                   : in std_logic;
       dacapo_c_rst_p_i        : in std_logic;
       rst_i                   : in std_logic;
       roll_over_incr_recent_i : in std_logic;
       clk_i_cycles_offset_i   : in std_logic_vector(31 downto 0);
       roll_over_nb_i          : in std_logic_vector(31 downto 0);
       local_utc_i             : in std_logic_vector(31 downto 0);
       retrig_nb_offset_i      : in std_logic_vector(31 downto 0);
       one_hz_p_i              : in std_logic;
      ----------------------------------------------------------------------
       tstamp_wr_wb_adr_o      : out std_logic_vector(7 downto 0);
       tstamp_wr_wb_cyc_o      : out std_logic;
       tstamp_wr_dat_o         : out std_logic_vector(127 downto 0);
       tstamp_wr_wb_stb_o      : out std_logic;
       tstamp_wr_wb_we_o       : out std_logic;
       tstamp_wr_p_o           : out std_logic;
       wr_index_o              : out std_logic_vector(31 downto 0));
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component irq_generator is
    generic
      (g_width                : integer := 32);
    port
      (clk_i                  : in std_logic;
       rst_i                  : in std_logic;
       irq_tstamp_threshold_i : in std_logic_vector(g_width-1 downto 0);
       irq_time_threshold_i   : in std_logic_vector(g_width-1 downto 0);
       activate_acq_p_i       : in std_logic;
       deactivate_acq_p_i     : in std_logic;
       tstamp_wr_p_i          : in std_logic;
       one_hz_p_i             : in std_logic;
       acam_errflag_r_edge_p_i: in std_logic;
      ----------------------------------------------------------------------
       irq_tstamp_p_o         : out std_logic;
       irq_acam_err_p_o       : out std_logic;
       irq_time_p_o           : out std_logic);
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component tdc_eic
    port
      (rst_n_i             : in     std_logic;
       clk_sys_i           : in     std_logic;
       wb_adr_i            : in     std_logic_vector(1 downto 0);
       wb_dat_i            : in     std_logic_vector(31 downto 0);
       wb_dat_o            : out    std_logic_vector(31 downto 0);
       wb_cyc_i            : in     std_logic;
       wb_sel_i            : in     std_logic_vector(3 downto 0);
       wb_stb_i            : in     std_logic;
       wb_we_i             : in     std_logic;
       wb_ack_o            : out    std_logic;
       wb_stall_o          : out    std_logic;
       wb_int_o            : out    std_logic;
       irq_tdc_tstamps_i   : in     std_logic;
       irq_tdc_time_i      : in     std_logic;
       irq_tdc_acam_err_i  : in     std_logic);
  end component tdc_eic;


---------------------------------------------------------------------------------------------------
  component dma_eic
    port
      (rst_n_i         : in  std_logic;
       clk_sys_i       : in  std_logic;
       wb_adr_i        : in  std_logic_vector(1 downto 0);
       wb_dat_i        : in  std_logic_vector(31 downto 0);
       wb_dat_o        : out std_logic_vector(31 downto 0);
       wb_cyc_i        : in  std_logic;
       wb_sel_i        : in  std_logic_vector(3 downto 0);
       wb_stb_i        : in  std_logic;
       wb_we_i         : in  std_logic;
       wb_ack_o        : out std_logic;
       wb_stall_o      : out std_logic;
       wb_int_o        : out std_logic;
       irq_dma_done_i  : in  std_logic;
       irq_dma_error_i : in  std_logic);
  end component dma_eic;

---------------------------------------------------------------------------------------------------
  component irq_controller
    port
      (clk_i       : in  std_logic;
       rst_n_i     : in  std_logic;
       irq_src_p_i : in  std_logic_vector(31 downto 0);
       wb_adr_i    : in  std_logic_vector(1 downto 0);
       wb_dat_i    : in  std_logic_vector(31 downto 0);
       wb_cyc_i    : in  std_logic;
       wb_sel_i    : in  std_logic_vector(3 downto 0);
       wb_stb_i    : in  std_logic;
       wb_we_i     : in  std_logic;
      ----------------------------------------------------------------------
       wb_dat_o    : out std_logic_vector(31 downto 0);
       wb_ack_o    : out std_logic;
       irq_p_o     : out std_logic);
  end component irq_controller;


---------------------------------------------------------------------------------------------------
  component clks_rsts_manager
    generic
      (nb_of_reg              : integer := 68);
    port
      (clk_20m_vcxo_i         : in std_logic;
       acam_refclk_p_i        : in std_logic;
       acam_refclk_n_i        : in std_logic;
       tdc_125m_clk_p_i       : in std_logic;
       tdc_125m_clk_n_i       : in std_logic;
       rst_n_i                : in std_logic;
       pll_status_i           : in std_logic;
       pll_sdo_i              : in std_logic;
       send_dac_word_p_i      : in std_logic;
       dac_word_i             : in std_logic_vector(23 downto 0);
      ----------------------------------------------------------------------
       tdc_125m_clk_o         : out std_logic;
       internal_rst_o         : out std_logic;
       acam_refclk_r_edge_p_o : out std_logic;
       pll_cs_n_o             : out std_logic;
       pll_dac_sync_n_o       : out std_logic;
       pll_sdi_o              : out std_logic;
       pll_sclk_o             : out std_logic;
       pll_status_o           : out std_logic);
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component carrier_csr
    port
      (rst_n_i                          : in  std_logic;
       wb_clk_i                         : in  std_logic;
       wb_addr_i                        : in  std_logic_vector(1 downto 0);
       wb_data_i                        : in  std_logic_vector(31 downto 0);
       wb_data_o                        : out std_logic_vector(31 downto 0);
       wb_cyc_i                         : in  std_logic;
       wb_sel_i                         : in  std_logic_vector(3 downto 0);
       wb_stb_i                         : in  std_logic;
       wb_we_i                          : in  std_logic;
       wb_ack_o                         : out std_logic;
       carrier_csr_carrier_pcb_rev_i    : in  std_logic_vector(3 downto 0);
       carrier_csr_carrier_reserved_i   : in  std_logic_vector(11 downto 0);
       carrier_csr_carrier_type_i       : in  std_logic_vector(15 downto 0);
       carrier_csr_stat_fmc_pres_i      : in  std_logic;
       carrier_csr_stat_p2l_pll_lck_i   : in  std_logic;
       carrier_csr_stat_sys_pll_lck_i   : in  std_logic;
       carrier_csr_stat_ddr3_cal_done_i : in  std_logic;
       carrier_csr_stat_reserved_i      : in  std_logic_vector(27 downto 0);
       carrier_csr_ctrl_led_green_o     : out std_logic;
       carrier_csr_ctrl_led_red_o       : out std_logic;
       carrier_csr_ctrl_dac_clr_n_o     : out std_logic;
       carrier_csr_ctrl_reserved_o      : out std_logic_vector(28 downto 0));
  end component carrier_csr;


---------------------------------------------------------------------------------------------------
  component leds_manager is
    generic
      (g_width          : integer := 32;
       values_for_simul : boolean := FALSE);
    port
      (clk_i            : in std_logic;
       rst_i            : in std_logic;
       one_hz_p_i       : in std_logic;
       acam_inputs_en_i : in std_logic_vector(g_width-1 downto 0);
       fordebug_i       : in std_logic_vector(5 downto 0);
      ----------------------------------------------------------------------
       tdc_led_status_o : out std_logic;
       tdc_led_trig1_o  : out std_logic;
       tdc_led_trig2_o  : out std_logic;
       tdc_led_trig3_o  : out std_logic;
       tdc_led_trig4_o  : out std_logic;
       tdc_led_trig5_o  : out std_logic);
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component acam_databus_interface
    port
      (ef1_i        : in std_logic;
       ef2_i        : in std_logic;
       data_bus_io  : inout std_logic_vector(27 downto 0);
       clk_i        : in std_logic;
       rst_i        : in std_logic;
       adr_i        : in std_logic_vector(7 downto 0);
       cyc_i        : in std_logic;
       dat_i        : in std_logic_vector(31 downto 0);
       stb_i        : in std_logic;
       we_i         : in std_logic;
      ----------------------------------------------------------------------
       adr_o        : out std_logic_vector(3 downto 0);
       cs_n_o       : out std_logic;
       oe_n_o       : out std_logic;
       rd_n_o       : out std_logic;
       wr_n_o       : out std_logic;
       ack_o        : out std_logic;
       ef1_o        : out std_logic;
       ef1_meta_o   : out std_logic;
       ef2_o        : out std_logic;
       ef2_meta_o   : out std_logic;
       dat_o        : out std_logic_vector(31 downto 0));
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component circular_buffer
    port
      (clk_i              : in std_logic;
       tstamp_wr_rst_i    : in std_logic; 
       tstamp_wr_stb_i    : in std_logic;
       tstamp_wr_cyc_i    : in std_logic;
       tstamp_wr_we_i     : in std_logic;
       tstamp_wr_adr_i    : in std_logic_vector(7 downto 0);
       tstamp_wr_dat_i    : in std_logic_vector(127 downto 0);
       tdc_mem_wb_rst_i   : in std_logic;
       tdc_mem_wb_stb_i   : in std_logic;
       tdc_mem_wb_cyc_i   : in std_logic;
       tdc_mem_wb_we_i    : in std_logic;
       tdc_mem_wb_adr_i   : in std_logic_vector(31 downto 0);
       tdc_mem_wb_dat_i   : in std_logic_vector(31 downto 0);
     --------------------------------------------------
       tstamp_wr_ack_p_o  : out std_logic;
       tstamp_wr_dat_o    : out std_logic_vector(127 downto 0);
       tdc_mem_wb_ack_o   : out std_logic;
       tdc_mem_wb_dat_o   : out std_logic_vector(31 downto 0);
       tdc_mem_wb_stall_o : out std_logic);
     --------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component blk_mem_circ_buff_v6_4
    port
      (clka : in std_logic;
       addra  : in std_logic_vector(7 downto 0);
       dina   : in std_logic_vector(127 downto 0);
       ena    : in std_logic;
       wea    : in std_logic_vector(0 downto 0);
       clkb   : in std_logic;
       addrb  : in std_logic_vector(9 downto 0);
       dinb   : in std_logic_vector(31 downto 0);
       enb    : in std_logic;
       web    : in std_logic_vector(0 downto 0);
     --------------------------------------------------
       douta  : out std_logic_vector(127 downto 0);
       doutb  : out std_logic_vector(31 downto 0));
     --------------------------------------------------
  end component;


end tdc_core_pkg;
--=================================================================================================
--                                        package body
--=================================================================================================
package body tdc_core_pkg is


end tdc_core_pkg;
--=================================================================================================
--                                         package end
--=================================================================================================
---------------------------------------------------------------------------------------------------
--                                      E N D   O F   F I L E
---------------------------------------------------------------------------------------------------