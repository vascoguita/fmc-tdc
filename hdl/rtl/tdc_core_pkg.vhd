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
use work.gencores_pkg.all;


--=================================================================================================
--                              Package declaration for tdc_core_pkg
--=================================================================================================
package tdc_core_pkg is



  type t_raw_acam_timestamp is record
    seconds               : std_logic_vector(31 downto 0);  -- 32
    acam_bins             : std_logic_vector(16 downto 0);  -- 32 + 17 = 49
    acam_start_nb : std_logic_vector(7 downto 0);      
    roll_over_incr_recent : std_logic;
    clk_i_cycles_offset   : std_logic_vector(7 downto 0);   -- 60 + 8 = 68
    roll_over_nb          : std_logic_vector(15 downto 0);  -- 68 + 16 = 84
    retrig_nb_offset      : std_logic_vector(8 downto 0);   -- 84 + 9 = 93
    current_retrig_nb     : std_logic_vector(8 downto 0);   -- 93 + 9 = 102
    channel               : std_logic_vector(2 downto 0);   -- 102 + 3 = 105
    slope                 : std_logic;                      -- 105 + 1 = 106
    seq                   : std_logic_vector(23 downto 0);  -- 106 + 22 = 128
                                     -- (raw mode data)
  end record;

  type t_acam_timestamp is record
    raw : t_raw_acam_timestamp;
    tai : std_logic_vector(31 downto 0);
    coarse : std_logic_vector( 31 downto 0);
    n_bins : std_logic_vector(16 downto 0);
    channel : std_logic_vector(2 downto 0);
    slope : std_logic;
    meta : std_logic_vector(31 downto 0);
  end record;
  
  
  constant c_dummy_raw_acam_timestamp : t_raw_acam_timestamp :=
    (
      x"00000000",
      "00000000000000000",
      x"00",
      '0',
      x"00",
      x"0000",
      "000000000",
      "000000000",
      "000",
      '0',
      "000000000000000000000000"
      );
  
  type t_tdc_timestamp is record
    raw : t_raw_acam_timestamp;
    slope : std_logic;
    channel : std_logic_vector(2 downto 0);
    frac : std_logic_vector(11 downto 0);
    coarse : std_logic_vector(31 downto 0);
    tai : std_logic_vector(31 downto 0);
    seq : std_logic_vector(31 downto 0);
    meta : std_logic_vector(31 downto 0);
  end record;

  constant c_dummy_timestamp : t_tdc_timestamp :=
    ( c_dummy_raw_acam_timestamp, '0', "000", x"000", x"00000000", x"00000000", x"00000000", x"00000000" );
  
  type t_tdc_timestamp_array is array(integer range<>) of t_tdc_timestamp;
  
---------------------------------------------------------------------------------------------------
--                      Constant regarding the Mezzanine DAC configuration                       --
---------------------------------------------------------------------------------------------------
  -- Vout = Vref (DAC_WORD/ 65536); for Vout = 1.65V, with Vref = 2.5V the DAC_WORD = xA8F5
  constant c_DEFAULT_DAC_WORD : std_logic_vector(23 downto 0) := x"00A8F5";


---------------------------------------------------------------------------------------------------
--                        Constants regarding the SDB Devices Definitions                        --
---------------------------------------------------------------------------------------------------
-- Note: All address in sdb and crossbar are BYTE addresses!

  -- Devices sdb description
  constant c_TDC_ONEWIRE_SDB_DEVICE : t_sdb_device :=
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
           device_id => x"00006602",         -- "WB-Onewire.Control " | md5sum | cut -c1-8
           version   => x"00000001",
           date      => x"20180910",
           name      => "TDC-Onewire-Regs   ")));

  constant c_SPEC_INFO_SDB_DEVICE : t_sdb_device :=
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
           device_id => x"00000603",         -- "WB-SPEC.CSR        " | md5sum | cut -c1-8
           version   => x"00000001",
           date      => x"20121116",
           name      => "WB-SPEC.CSR        ")));

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
           device_id => x"00000605",         -- "WB-FMC-ADC.EIC     " | md5sum | cut -c1-8
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
           device_id => x"00000606",         -- "WB-I2C.Control     " | md5sum | cut -c1-8
           version   => x"00000001",
           date      => x"20121116",
           name      => "WB-I2C.Control     ")));

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
        device_id => x"26ec6086",          -- "WB-FMC-TDC.EIC     " | md5sum | cut -c1-8
        version   => x"00000001",
        date      => x"20131204",
        name      => "WB-FMC-TDC.EIC     ")));

  constant c_TDC_CONFIG_SDB_DEVICE : t_sdb_device :=
    (abi_class     => x"0000",               -- undocumented device
     abi_ver_major => x"02",
     abi_ver_minor => x"01",
     wbd_endian    => c_sdb_endian_big,
     wbd_width     => x"4",                  -- 32-bit port granularity
     sdb_component =>
       (addr_first  => x"0000000000000000",
        addr_last   => x"00000000000000FF",
        product     =>
          (vendor_id => x"000000000000CE42", -- CERN
           device_id => x"00000604",         -- "WB-TDC-Core-Config " | md5sum | cut -c1-8
           version   => x"00000001",
           date      => x"20130429",
           name      => "WB-TDC-Core-Config ")));

  constant c_TDC_FIFO_SDB_DEVICE : t_sdb_device :=
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
           device_id => x"00000622",         -- "WB-TDC-Mem         " | md5sum | cut -c1-8
           version   => x"00000001",
           date      => x"20150415",
           name      => "WB-TDC-TsFIFO      ")));


    constant c_TDC_DMA_SDB_DEVICE : t_sdb_device :=
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
           device_id => x"00000623",         -- "WB-TDC-Mem         " | md5sum | cut -c1-8
           version   => x"00000001",
           date      => x"20150415",
           name      => "WB-TDC-TsDMAEngine ")));


---------------------------------------------------------------------------------------------------
--                           Constants regarding 1 Hz pulse generation                           --
---------------------------------------------------------------------------------------------------

  -- for synthesis: 1 sec = x"07735940" clk_i cycles (1 clk_i cycle = 8ns)
  constant c_SYN_CLK_PERIOD : std_logic_vector(31 downto 0) := x"07735940";

  -- for simulation: 1 msec = x"0001E848" clk_i cycles (1 clk_i cycle = 8ns)
  constant c_SIM_CLK_PERIOD : std_logic_vector(31 downto 0) := x"00001000";


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
  constant c_ACAM_REG0_ADR  : std_logic_vector(7 downto 0) := x"00"; -- address 0x51000 of GN4124 BAR 0
  constant c_ACAM_REG1_ADR  : std_logic_vector(7 downto 0) := x"01"; -- address 0x51004 of GN4124 BAR 0
  constant c_ACAM_REG2_ADR  : std_logic_vector(7 downto 0) := x"02"; -- address 0x51008 of GN4124 BAR 0
  constant c_ACAM_REG3_ADR  : std_logic_vector(7 downto 0) := x"03"; -- address 0x5100C of GN4124 BAR 0
  constant c_ACAM_REG4_ADR  : std_logic_vector(7 downto 0) := x"04"; -- address 0x51010 of GN4124 BAR 0
  constant c_ACAM_REG5_ADR  : std_logic_vector(7 downto 0) := x"05"; -- address 0x51014 of GN4124 BAR 0
  constant c_ACAM_REG6_ADR  : std_logic_vector(7 downto 0) := x"06"; -- address 0x51018 of GN4124 BAR 0
  constant c_ACAM_REG7_ADR  : std_logic_vector(7 downto 0) := x"07"; -- address 0x5101C of GN4124 BAR 0
  constant c_ACAM_REG11_ADR : std_logic_vector(7 downto 0) := x"0B"; -- address 0x5102C of GN4124 BAR 0
  constant c_ACAM_REG12_ADR : std_logic_vector(7 downto 0) := x"0C"; -- address 0x51030 of GN4124 BAR 0
  constant c_ACAM_REG14_ADR : std_logic_vector(7 downto 0) := x"0E"; -- address 0x51038 of GN4124 BAR 0


---------------------------------------------------------------------------------------------------
-- Addresses of ACAM read-only registers, to be written by the ACAM and used within the core to access ACAM timestamps
  constant c_ACAM_REG8_ADR  : std_logic_vector(7 downto 0) := x"08"; -- not accessible for writing from PCI-e
  constant c_ACAM_REG9_ADR  : std_logic_vector(7 downto 0) := x"09"; -- not accessible for writing from PCI-e
  constant c_ACAM_REG10_ADR : std_logic_vector(7 downto 0) := x"0A"; -- not accessible for writing from PCI-e


---------------------------------------------------------------------------------------------------
-- Addresses of ACAM configuration readback registers, to be written by the ACAM 
                                                                          -- corresponds to:
  constant c_ACAM_REG0_RDBK_ADR  : std_logic_vector(7 downto 0) := x"10"; -- address 0x51040 of the GN4124 BAR 0
  constant c_ACAM_REG1_RDBK_ADR  : std_logic_vector(7 downto 0) := x"11"; -- address 0x51044 of the GN4124 BAR 0
  constant c_ACAM_REG2_RDBK_ADR  : std_logic_vector(7 downto 0) := x"12"; -- address 0x51048 of the GN4124 BAR 0
  constant c_ACAM_REG3_RDBK_ADR  : std_logic_vector(7 downto 0) := x"13"; -- address 0x5104C of the GN4124 BAR 0
  constant c_ACAM_REG4_RDBK_ADR  : std_logic_vector(7 downto 0) := x"14"; -- address 0x51050 of the GN4124 BAR 0
  constant c_ACAM_REG5_RDBK_ADR  : std_logic_vector(7 downto 0) := x"15"; -- address 0x51054 of the GN4124 BAR 0
  constant c_ACAM_REG6_RDBK_ADR  : std_logic_vector(7 downto 0) := x"16"; -- address 0x51058 of the GN4124 BAR 0
  constant c_ACAM_REG7_RDBK_ADR  : std_logic_vector(7 downto 0) := x"17"; -- address 0x5105C of the GN4124 BAR 0
  constant c_ACAM_REG8_RDBK_ADR  : std_logic_vector(7 downto 0) := x"18"; -- address 0x51060 of the GN4124 BAR 0
  constant c_ACAM_REG9_RDBK_ADR  : std_logic_vector(7 downto 0) := x"19"; -- address 0x51064 of the GN4124 BAR 0
  constant c_ACAM_REG10_RDBK_ADR : std_logic_vector(7 downto 0) := x"1A"; -- address 0x51068 of the GN4124 BAR 0
  constant c_ACAM_REG11_RDBK_ADR : std_logic_vector(7 downto 0) := x"1B"; -- address 0x5106C of the GN4124 BAR 0
  constant c_ACAM_REG12_RDBK_ADR : std_logic_vector(7 downto 0) := x"1C"; -- address 0x51070 of the GN4124 BAR 0
  constant c_ACAM_REG14_RDBK_ADR : std_logic_vector(7 downto 0) := x"1E"; -- address 0x51078 of the GN4124 BAR 0


---------------------------------------------------------------------------------------------------
--                    Constants regarding addressing of the TDC core registers                   --
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Addresses of TDC core Configuration registers to be written by the PCIe host
                                                                           -- corresponds to:
  constant c_STARTING_UTC_ADR     : std_logic_vector(7 downto 0) := x"20"; -- address 0x51080 of GN4124 BAR 0
  constant c_ACAM_INPUTS_EN_ADR   : std_logic_vector(7 downto 0) := x"21"; -- address 0x51084 of GN4124 BAR 0
  constant c_START_PHASE_ADR      : std_logic_vector(7 downto 0) := x"22"; -- address 0x51088 of GN4124 BAR 0
  constant c_ONE_HZ_PHASE_ADR     : std_logic_vector(7 downto 0) := x"23"; -- address 0x5108C of GN4124 BAR 0

  constant c_IRQ_TSTAMP_THRESH_ADR: std_logic_vector(7 downto 0) := x"24"; -- address 0x51090 of GN4124 BAR 0
  constant c_IRQ_TIME_THRESH_ADR  : std_logic_vector(7 downto 0) := x"25"; -- address 0x51094 of GN4124 BAR 0
  constant c_DAC_WORD_ADR         : std_logic_vector(7 downto 0) := x"26"; -- address 0x51098 of GN4124 BAR 0

  constant c_DEACT_CHAN_ADR       : std_logic_vector(7 downto 0) := x"27"; -- address 0x5109C of GN4124 BAR 0

---------------------------------------------------------------------------------------------------
-- Addresses of TDC core Status registers to be written by the different core units
                                                                           -- corresponds to:
  constant c_LOCAL_UTC_ADR        : std_logic_vector(7 downto 0) := x"28"; -- address 0x510A0 of GN4124 BAR 0
  constant c_IRQ_CODE_ADR         : std_logic_vector(7 downto 0) := x"29"; -- address 0x510A4 of GN4124 BAR 0
  constant c_WR_INDEX_ADR         : std_logic_vector(7 downto 0) := x"2A"; -- address 0x510A8 of GN4124 BAR 0
  constant c_CORE_STATUS_ADR      : std_logic_vector(7 downto 0) := x"2B"; -- address 0x510AC of GN4124 BAR 0

---------------------------------------------------------------------------------------------------
-- Addresses of the White Rabbit control and status registers

  constant c_WRABBIT_STATUS_ADR   : std_logic_vector(7 downto 0) := x"2C"; -- address 0x510B0 of GN4124 BAR 0
  constant c_WRABBIT_CTRL_ADR     : std_logic_vector(7 downto 0) := x"2D"; -- address 0x510B4 of GN4124 BAR 0

  constant c_TEST0_ADR     : std_logic_vector(7 downto 0) := x"2E"; -- address 0x510B4 of GN4124 BAR 0
  constant c_TEST1_ADR     : std_logic_vector(7 downto 0) := x"2f"; -- address 0x510B4 of GN4124 BAR 0

---------------------------------------------------------------------------------------------------
-- Address of TDC core Control register
                                                                           -- corresponds to:
  constant c_CTRL_REG_ADR         : std_logic_vector(7 downto 0) := x"3F"; -- address 0x510FC of GN4124 BAR 0


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
  constant c_FMC_ONEWIRE_NB   : integer := 1;


---------------------------------------------------------------------------------------------------
--                            Constants regarding the Carrier CSR info                           --
---------------------------------------------------------------------------------------------------
  constant c_CARRIER_TYPE   : std_logic_vector(15 downto 0) := X"0001";


---------------------------------------------------------------------------------------------------
--                                      Components Declarations                                  --
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------


  component fmc_tdc_mezzanine is
  generic
    (g_with_wrabbit_core       : boolean := TRUE;
     g_span                    : integer := 32;
     g_width                   : integer := 32;
     g_simulation          : boolean := FALSE);
   port
    -- TDC core
    (

      -- System clock & reset (Wishbone)
     clk_sys_i                 : in    std_logic; -- 62.5 MHz clock
     rst_sys_n_i               : in    std_logic; -- reset for 62.5 MHz logic

     -- TDC 125 MHz reference & Reset (FMC)
     clk_tdc_i               : in    std_logic; -- 125 MHz clock
     rst_tdc_i               : in    std_logic; -- reset for 125 MHz logic

         -- WISHBONE interface with the GN4124/VME_core (clk_sys)
     -- for the core configuration | timestamps retrieval | core interrupts | 1Wire | I2C 

     slave_i: in t_wishbone_slave_in;
     slave_o: out t_wishbone_slave_out;
     
     wb_irq_o                  : out   std_logic;

     acam_refclk_r_edge_p_i    : in    std_logic;
     send_dac_word_p_o         : out   std_logic;
     dac_word_o                : out   std_logic_vector(23 downto 0);
     -- Interface with ACAM
     start_from_fpga_o         : out   std_logic;
     err_flag_i                : in    std_logic;
     int_flag_i                : in    std_logic;
     start_dis_o               : out   std_logic;
     stop_dis_o                : out   std_logic;
     data_bus_io               : inout std_logic_vector(27 downto 0);
     address_o                 : out   std_logic_vector(3 downto 0);
     cs_n_o                    : out   std_logic;
     oe_n_o                    : out   std_logic;
     rd_n_o                    : out   std_logic;
     wr_n_o                    : out   std_logic;
     ef1_i                     : in    std_logic;
     ef2_i                     : in    std_logic;
     -- Channels termination 
     enable_inputs_o           : out   std_logic;
     term_en_1_o               : out   std_logic;
     term_en_2_o               : out   std_logic;
     term_en_3_o               : out   std_logic;
     term_en_4_o               : out   std_logic;
     term_en_5_o               : out   std_logic;
     -- TDC board LEDs
     tdc_led_status_o          : out   std_logic;
     tdc_led_trig1_o           : out   std_logic;
     tdc_led_trig2_o           : out   std_logic;
     tdc_led_trig3_o           : out   std_logic;
     tdc_led_trig4_o           : out   std_logic;
     tdc_led_trig5_o           : out   std_logic;
     -- White Rabbit core
     wrabbit_link_up_i         : in    std_logic;
     wrabbit_time_valid_i      : in    std_logic;
     wrabbit_cycles_i          : in    std_logic_vector(27 downto 0);
     wrabbit_utc_i             : in    std_logic_vector(31 downto 0);
     wrabbit_clk_aux_lock_en_o : out   std_logic;
     wrabbit_clk_aux_locked_i  : in    std_logic;
     wrabbit_clk_dmtd_locked_i : in    std_logic;
     wrabbit_dac_value_i       : in    std_logic_vector(23 downto 0);
     wrabbit_dac_wr_p_i        : in    std_logic;

 

     -- I2C EEPROM interface
     i2c_scl_o                 : out   std_logic;
     i2c_scl_oen_o             : out   std_logic;
     i2c_scl_i                 : in    std_logic;
     i2c_sda_oen_o             : out   std_logic;
     i2c_sda_o                 : out   std_logic;
     i2c_sda_i                 : in    std_logic;
    -- 1-Wire interface
     onewire_b                 : inout std_logic;
     direct_timestamp_o : out std_logic_vector(127 downto 0);
     direct_timestamp_stb_o : out std_logic
);

  end component;


---------------------------------------------------------------------------------------------------
  component fmc_tdc_core is
    generic (
      g_span       : integer;
      g_width      : integer;
      g_simulation : boolean);
    port (
      clk_sys_i              : in    std_logic;
      rst_n_sys_i            : in    std_logic;
      clk_tdc_i              : in    std_logic;
      rst_tdc_i              : in    std_logic;
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
      wrabbit_status_reg_i   : in    std_logic_vector(g_width-1 downto 0);
      wrabbit_ctrl_reg_o     : out   std_logic_vector(g_width-1 downto 0);
      wrabbit_synched_i      : in    std_logic;
      wrabbit_tai_p_i        : in    std_logic;
      wrabbit_tai_i          : in    std_logic_vector(31 downto 0);
      cfg_slave_i            : in    t_wishbone_slave_in;
      cfg_slave_o            : out   t_wishbone_slave_out;
      timestamp_o            : out   t_tdc_timestamp;
      timestamp_stb_o        : out   std_logic;
      channel_enable_o       : out   std_logic_vector(4 downto 0);
      irq_threshold_o        : out   std_logic_vector(9 downto 0);
      irq_timeout_o          : out   std_logic_vector(9 downto 0));
  end component fmc_tdc_core;
  
---------------------------------------------------------------------------------------------------
  component wrabbit_sync is
  generic
    (g_simulation        : boolean;
     g_with_wrabbit_core : boolean);
  port
    (clk_sys_i                 : in  std_logic;
     rst_n_sys_i               : in  std_logic;
     clk_ref_i                 : in  std_logic;
     rst_n_ref_i               : in  std_logic;
     wrabbit_dac_value_i       : in  std_logic_vector(23 downto 0);
     wrabbit_dac_wr_p_i        : in  std_logic;
     wrabbit_link_up_i         : in  std_logic;
     wrabbit_time_valid_i      : in  std_logic; -- this is i te clk_ref_0 domain, no??
     wrabbit_clk_aux_lock_en_o : out std_logic;
     wrabbit_clk_aux_locked_i  : in  std_logic;
     wrabbit_clk_dmtd_locked_i : in  std_logic;
     wrabbit_synched_o         : out std_logic;
     wrabbit_reg_i             : in  std_logic_vector(31 downto 0);
     wrabbit_reg_o             : out std_logic_vector(31 downto 0));
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
       utc_p_i                 : in std_logic;
      ----------------------------------------------------------------------
       current_retrig_nb_o     : out std_logic_vector(g_width-1 downto 0);
       roll_over_incr_recent_o : out std_logic;
       clk_i_cycles_offset_o   : out std_logic_vector(g_width-1 downto 0);
       roll_over_nb_o          : out std_logic_vector(g_width-1 downto 0);
       retrig_nb_offset_o      : out std_logic_vector(g_width-1 downto 0));
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component local_pps_gen
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
       local_utc_p_o          : out std_logic);
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
  component reg_ctrl is
    generic (
      g_span  : integer := 32;
      g_width : integer := 32);
    port (
      clk_sys_i              : in  std_logic;
      rst_n_sys_i            : in  std_logic;
      clk_tdc_i              : in  std_logic;
      rst_tdc_i              : in  std_logic;
      slave_i                : in  t_wishbone_slave_in;
      slave_o                : out t_wishbone_slave_out;
      acam_config_rdbk_i     : in  config_vector;
      acam_ififo1_i          : in  std_logic_vector(g_width-1 downto 0);
      acam_ififo2_i          : in  std_logic_vector(g_width-1 downto 0);
      acam_start01_i         : in  std_logic_vector(g_width-1 downto 0);
      local_utc_i            : in  std_logic_vector(g_width-1 downto 0);
      core_status_i          : in  std_logic_vector(g_width-1 downto 0);
      irq_code_i             : in  std_logic_vector(g_width-1 downto 0);
      wrabbit_status_reg_i   : in  std_logic_vector(g_width-1 downto 0);
      acam_config_o          : out config_vector;
      activate_acq_p_o       : out std_logic;
      deactivate_acq_p_o     : out std_logic;
      acam_wr_config_p_o     : out std_logic;
      acam_rdbk_config_p_o   : out std_logic;
      acam_rst_p_o           : out std_logic;
      acam_rdbk_status_p_o   : out std_logic;
      acam_rdbk_ififo1_p_o   : out std_logic;
      acam_rdbk_ififo2_p_o   : out std_logic;
      acam_rdbk_start01_p_o  : out std_logic;
      send_dac_word_p_o      : out std_logic;
      dac_word_o             : out std_logic_vector(23 downto 0);
      load_utc_p_o           : out std_logic;
      starting_utc_o         : out std_logic_vector(g_width-1 downto 0);
      irq_tstamp_threshold_o : out std_logic_vector(g_width-1 downto 0);
      irq_time_threshold_o   : out std_logic_vector(g_width-1 downto 0);
      one_hz_phase_o         : out std_logic_vector(g_width-1 downto 0);
      acam_inputs_en_o       : out std_logic_vector(g_width-1 downto 0);
      wrabbit_ctrl_reg_o     : out std_logic_vector(g_width-1 downto 0);
      start_phase_o          : out std_logic_vector(g_width-1 downto 0);
      gen_fake_ts_enable_o  : out std_logic;
      gen_fake_ts_period_o  : out std_logic_vector(27 downto 0);
      gen_fake_ts_channel_o : out std_logic_vector(2 downto 0)
    );
  end component reg_ctrl;
---------------------------------------------------------------------------------------------------
  component acam_timecontrol_interface
    port
      (err_flag_i              : in std_logic;
       int_flag_i              : in std_logic;
       acam_refclk_r_edge_p_i  : in std_logic;
       utc_p_i                 : in std_logic;
       clk_i                   : in std_logic;
       activate_acq_p_i        : in std_logic;
       rst_i                   : in std_logic;
	   state_active_p_i        : in std_logic;
	   deactivate_acq_p_i      : in std_logic;
      ----------------------------------------------------------------------
       start_from_fpga_o       : out std_logic;
       stop_dis_o              : out   std_logic;
       acam_errflag_r_edge_p_o : out std_logic;
       acam_errflag_f_edge_p_o : out std_logic;
       acam_intflag_f_edge_p_o : out std_logic);
      ----------------------------------------------------------------------
  end component;
  
  component data_formatting is
    port (
      clk_i                   : in  std_logic;
      rst_i                   : in  std_logic;
      acam_tstamp1_ok_p_i     : in  std_logic;
      acam_tstamp1_i          : in  std_logic_vector(31 downto 0);
      acam_tstamp2_ok_p_i     : in  std_logic;
      acam_tstamp2_i          : in  std_logic_vector(31 downto 0);
      utc_i                   : in  std_logic_vector(31 downto 0);
      roll_over_incr_recent_i : in  std_logic;
      clk_i_cycles_offset_i   : in  std_logic_vector(31 downto 0);
      roll_over_nb_i          : in  std_logic_vector(31 downto 0);
      retrig_nb_offset_i      : in  std_logic_vector(31 downto 0);
      utc_p_i                 : in  std_logic;
      gen_fake_ts_enable_i  : in std_logic;
      gen_fake_ts_period_i  : in std_logic_vector(27 downto 0);
      gen_fake_ts_channel_i : in std_logic_vector(2 downto 0);
      timestamp_o             : out std_logic_vector(127 downto 0);
      timestamp_valid_o       : out std_logic);
  end component data_formatting;




  component tdc_eic is
    port (
      rst_n_i         : in  std_logic;
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
      irq_tdc_fifo1_i : in  std_logic;
      irq_tdc_fifo2_i : in  std_logic;
      irq_tdc_fifo3_i : in  std_logic;
      irq_tdc_fifo4_i : in  std_logic;
      irq_tdc_fifo5_i : in  std_logic);
  end component tdc_eic;


---------------------------------------------------------------------------------------------------
  component clks_rsts_manager
    generic
      (nb_of_reg              : integer := 68);
    port
      (clk_sys_i              : in std_logic;
       acam_refclk_p_i        : in std_logic;
       acam_refclk_n_i        : in std_logic;
       tdc_125m_clk_p_i       : in std_logic;
       tdc_125m_clk_n_i       : in std_logic;
       rst_n_i                : in std_logic;
       pll_status_i           : in std_logic;
       pll_sdo_i              : in std_logic;
       send_dac_word_p_i      : in std_logic;
       dac_word_i             : in std_logic_vector(23 downto 0);
       wrabbit_dac_wr_p_i     : in std_logic;
       wrabbit_dac_value_i    : in std_logic_vector(23 downto 0);
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
  component carrier_info
    port
      (rst_n_i                           : in  std_logic;
       clk_sys_i                         : in  std_logic;
       wb_adr_i                          : in  std_logic_vector(1 downto 0);
       wb_dat_i                          : in  std_logic_vector(31 downto 0);
       wb_dat_o                          : out std_logic_vector(31 downto 0);
       wb_cyc_i                          : in  std_logic;
       wb_sel_i                          : in  std_logic_vector(3 downto 0);
       wb_stb_i                          : in  std_logic;
       wb_we_i                           : in  std_logic;
       wb_ack_o                          : out std_logic;
       wb_stall_o                        : out std_logic;
       carrier_info_carrier_pcb_rev_i    : in  std_logic_vector(3 downto 0);
       carrier_info_carrier_reserved_i   : in  std_logic_vector(11 downto 0);
       carrier_info_carrier_type_i       : in  std_logic_vector(15 downto 0);
       carrier_info_stat_fmc_pres_i      : in  std_logic;
       carrier_info_stat_p2l_pll_lck_i   : in  std_logic;
       carrier_info_stat_sys_pll_lck_i   : in  std_logic;
       carrier_info_stat_ddr3_cal_done_i : in  std_logic;
       carrier_info_stat_reserved_i      : in  std_logic_vector(27 downto 0);
       carrier_info_ctrl_led_green_o     : out std_logic;
       carrier_info_ctrl_led_red_o       : out std_logic;
       carrier_info_ctrl_dac_clr_n_o     : out std_logic;
       carrier_info_ctrl_reserved_o      : out std_logic_vector(28 downto 0);
       carrier_info_rst_fmc0_n_o         : out std_logic;
       carrier_info_rst_fmc0_n_i         : in  std_logic;
       carrier_info_rst_fmc0_n_load_o    : out std_logic;
       carrier_info_rst_reserved_o       : out std_logic_vector(30 downto 0));
  end component carrier_info;



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



  component fmc_tdc_wrapper is
    generic (
      g_simulation          : boolean := false;
      g_with_direct_readout : boolean := false);
    port (
      clk_sys_i            : in    std_logic;
      rst_sys_n_i          : in    std_logic;
      rst_n_a_i            : in    std_logic;
      pll_sclk_o           : out   std_logic;
      pll_sdi_o            : out   std_logic;
      pll_cs_o             : out   std_logic;
      pll_dac_sync_o       : out   std_logic;
      pll_sdo_i            : in    std_logic;
      pll_status_i         : in    std_logic;
      tdc_clk_125m_p_i     : in    std_logic;
      tdc_clk_125m_n_i     : in    std_logic;
      acam_refclk_p_i      : in    std_logic;
      acam_refclk_n_i      : in    std_logic;
      start_from_fpga_o    : out   std_logic;
      err_flag_i           : in    std_logic;
      int_flag_i           : in    std_logic;
      start_dis_o          : out   std_logic;
      stop_dis_o           : out   std_logic;
      data_bus_io          : inout std_logic_vector(27 downto 0);
      address_o            : out   std_logic_vector(3 downto 0);
      cs_n_o               : out   std_logic;
      oe_n_o               : out   std_logic;
      rd_n_o               : out   std_logic;
      wr_n_o               : out   std_logic;
      ef1_i                : in    std_logic;
      ef2_i                : in    std_logic;
      enable_inputs_o      : out   std_logic;
      term_en_1_o          : out   std_logic;
      term_en_2_o          : out   std_logic;
      term_en_3_o          : out   std_logic;
      term_en_4_o          : out   std_logic;
      term_en_5_o          : out   std_logic;
      tdc_led_status_o     : out   std_logic;
      tdc_led_trig1_o      : out   std_logic;
      tdc_led_trig2_o      : out   std_logic;
      tdc_led_trig3_o      : out   std_logic;
      tdc_led_trig4_o      : out   std_logic;
      tdc_led_trig5_o      : out   std_logic;
      mezz_scl_o           : out std_logic;
      mezz_sda_o           : out std_logic;
      mezz_scl_i           : in std_logic;
      mezz_sda_i           : in std_logic;
      mezz_one_wire_b      : inout std_logic;
      tm_link_up_i         : in    std_logic;
      tm_time_valid_i      : in    std_logic;
      tm_cycles_i          : in    std_logic_vector(27 downto 0);
      tm_tai_i             : in    std_logic_vector(39 downto 0);
      tm_clk_aux_lock_en_o : out   std_logic;
      tm_clk_aux_locked_i  : in    std_logic;
      tm_clk_dmtd_locked_i : in    std_logic;
      tm_dac_value_i       : in    std_logic_vector(23 downto 0);
      tm_dac_wr_i          : in    std_logic;
      slave_i              : in    t_wishbone_slave_in := cc_dummy_master_out;
      slave_o              : out   t_wishbone_slave_out;
      direct_slave_i       : in    t_wishbone_slave_in := cc_dummy_master_out;
      direct_slave_o       : out   t_wishbone_slave_out;
      irq_o                : out   std_logic;
      clk_125m_tdc_o       : out   std_logic);
  end component fmc_tdc_wrapper;
  

  function f_pick(cond:boolean; if_true: std_logic_vector; if_false: std_logic_vector) return std_logic_vector;

  function f_pack_raw_acam_timestamp ( ts : t_raw_acam_timestamp ) return std_logic_vector;
  

  
  
end tdc_core_pkg;
--=================================================================================================
--                                        package body
--=================================================================================================
package body tdc_core_pkg is

  function f_pick(cond:boolean; if_true: std_logic_vector; if_false: std_logic_vector) return std_logic_vector is
    begin
      if(cond) then
        return if_true;
        else
          return if_false;
          end if;
      end f_pick;

  function f_pack_raw_acam_timestamp ( ts : t_raw_acam_timestamp ) return std_logic_vector is
    variable rv : std_logic_vector(127 downto 0);
  begin
    rv(31 downto 0) := ts.seconds;
    rv(48 downto 32) := ts.acam_bins(16 downto 0);
    rv(56 downto 49) := ts.acam_start_nb;
    rv(57) := ts.roll_over_incr_recent;
    rv(65 downto 58) := ts.clk_i_cycles_offset;
    rv(81 downto 66) := ts.roll_over_nb;
    rv(90 downto 82) := ts.retrig_nb_offset;
    rv(99 downto 91) := ts.current_retrig_nb;
    rv(102 downto 100) := ts.channel;
    rv(103) := ts.slope;
    rv(127 downto 104) := ts.seq;
    
    return rv;
  end f_pack_raw_acam_timestamp;

end tdc_core_pkg;
--=================================================================================================
--                                         package end
--=================================================================================================
---------------------------------------------------------------------------------------------------
--                                      E N D   O F   F I L E
---------------------------------------------------------------------------------------------------

