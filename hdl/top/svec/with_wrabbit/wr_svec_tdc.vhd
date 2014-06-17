--_________________________________________________________________________________________________
--                                                                                                |
--                                           |SVEC TDC|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                          wr_svec_tdc                                           |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         wr_svec_tdc.vhd                                                                   |
--                                                                                                |
-- Description  TDC top level for SVEC with White Rabbit.                                         |
--              Figure 1 shows the architecture of this unit.                                     |
--                o Two TDC mezzanine cores are instantiated, for the boards on FMC1 and FMC2     |
--                o The White Rabbit core is controlling the DAC on each TDC mezzanine; the DAC   |
--                  is in turn controlling the PLL frequency. Once the PLL is synchronized to     |
--                  White Rabbit, the TDC core starts using the White Rabbit UTC for the          |
--                  timestamps calculations.                                                      |
--                o The VIC is managing the interrupts coming from both TDC EIC cores             |
--                o The carrier_info module provides general information on the SVEC PCB version, |
--                  PLLs locking state etc                                                        |
--                o The 1-Wire core provides communication with the SVEC Thermometer&UniqueID chip|
--              All these cores communicate with the VME core through the WISHBONE.               |
--              The SDB crossbar is mapping the different slaves into the WISHBONE address space. |
--                                                                                                |
--              The speed for the VME core is 62.5 MHz. The TDC mezzanine cores however operate at|
--              125 MHz (like this the TDC core can keep up to speed with the maximum speed the   |
--              ACAM can be receiving timestamps). The crossing from the 62.5 MHz world to the    |
--              125 MHz world takes place through dedicated clock_crossing modules.               |
--                                                                                                |
--              The 62.5 MHz clock comes from an internal Xilinx FPGA PLL, using the 20MHz VCXO of|
--              the SVEC board.                                                                   |
--                                                                                                |
--              The 125 MHz clock for each TDC mezzanine comes from the PLL located on it.        |
--              A clks_rsts_manager unit is responsible for automatically configuring the PLL upon|
--              the FPGA startup, using the 62.5 MHz clock. The clks_rsts_manager is keeping the  |
--              the TDC mezzanine core under reset until the respective PLL gets locked.          |
--                                                                                                |
--              Upon powering up of the FPGA as well as after a VME reset, the whole logic gets   |
--              reset (FMC1 125 MHz, FMC2 125 MHz and 62.5 MHz). This also triggers a             |
--              reprogramming of the mezzanines' PLL through the clks_rsts_manager units.         |
--              An extra software reset is implemented for the TDC mezzanine cores, using the     |
--              reset bits of the carrier_info core. Such a reset also triggers the reprogramming |
--              of the mezzanines' PLL.                                                           |
--                                                                                                |
--                __________________________________________________________________              |
--               |                                                                  |             |
--               |       ____________________________                               |             |
--               |      |                            |       ___                    |             |
--               |  |---|  WRabbit core, PHY, DAC    |\     |   |                   |             |
--               |  |   |____________________________| \    |   |                   |             |
--               |                             62.5MHz   \  |   |                   |             |
--               |  |    ____________________________      \|   |       _____       |             |
--               |  |   |   ____________   _______   |      |   |      |     |      |             |
--               |  |---|->|            | | clk   |  |      |   |      |     |      |             |
--               |  |   |  | TDC mezz 1 | | cross |  |      |   |      |     |      |             |
--         FMC1  |  |   |  |____________| |_______|  |\     |   |      |     |      |             |
--               |  |   |    FMC1 125MHz             | \    |   |      |     |      |             |
--               |  |   |     ___________________    |   \  |   |      |     |      |             |
--               |  |---|--->|_clks_rsts_manager_|   |    \ |   |      |     |      |             |
--               |  |   |____________________________|     \|   |      |     |      |             |
--               |  |                                       |   |      |     |      |             |
--               |  |    ____________________________       |   |      |     |      |             |
--               |  |   |   ____________   _______   |      |   |      |     |      |             |
--               |  |   |  |            | | clk   |  |      |   |      |     |      |             |
--               |  |---|->| TDC mezz 2 | | cross |  |      | S |      |  V  |      |             |
--         FMC2  |  |   |  |____________| |_______|  | ---- |   |      |     |      |             |
--               |  |   |    FMC2 125MHz             |      |   |      |     |      |             |
--               |  |   |     ___________________    |      |   |      |     |      |             |
--               |  |---|--->|_clks_rsts_manager_|   |      |   |      |     |      |             |
--               |      |____________________________|      | D | <--> |  M  |      |             |
--               |                                          |   |      |     |      |             |
--               |       ____________________________       |   |      |     |      |             |
--               |      |                            |      |   |      |     |      |             |
--               |      |             VIC            | ---- | B |      |  E  |      |             |
--               |      |____________________________|      |   |      |     |      |             |
--               |                             62.5MHz      |   |      |     |      |             |
--               |       ____________________________       |   |      |     |      |             |
--               |      |                            |      |   |      |     |      |             |
-- SVEC 1W chip  |      |          1-Wire            | ---- |   |      |     |      |             |
--               |      |____________________________|      |   |      |     |      |             |
--               |                            62.5MHz     / |   |      |     |      |             |
--               |       ____________________________    /  |   |      |     |      |             |
--               |      |                            |  /   |   |      |     |      |             |
--               |      |        carrier_info        | /    |   |      |     |      |             |
--               |      |____________________________|      |   |      |     |      |             |
--               |                            62.5MHz       |___|      |_____|      |             |
--               |                                         62.5MHZ     62.5MHz      |             |
--               |      ______________________________________________              |             |
--               |     |___________________LEDs_______________________|             |             |
--               |                                                                  |             |
--               |__________________________________________________________________|             |
--                                                                                                |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
--              Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
-- Date         05/2014                                                                           |
-- Version      v5                                                                                |
-- Depends on                                                                                     |
--                                                                                                |
----------------                                                                                  |
-- Last changes                                                                                   |
--     08/2013  v4  EG  design for SVEC; two cores; synchronizer between vme and the cores        |
--     05/2014  v5  EG  added White Rabbit                                                        |
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
--                                       Libraries & Packages
--=================================================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tdc_core_pkg.all;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;
use work.wrcore_pkg.all;
use work.wr_fabric_pkg.all;
use work.wr_xilinx_pkg.all;
use work.bicolor_led_ctrl_pkg.all;
library UNISIM;
use UNISIM.vcomponents.all;

use work.synthesis_descriptor.all;

--=================================================================================================
--                                   Entity declaration for top_tdc
--=================================================================================================
entity wr_svec_tdc is
  generic
    (g_span                  : integer := 32;          -- address span in bus interfaces
     g_width                 : integer := 32;          -- data width in bus interfaces
     values_for_simul        : boolean := false);      -- this generic is set to TRUE
                                                       -- when instantiated in a test-bench
  port
    (-- SVEC carrier
      -- VCXO clock, PoR
      por_n_i                : in    std_logic;        -- PoR
      clk_20m_vcxo_i         : in    std_logic;        -- 20 MHz VCXO
      -- 125 MHz PLL reference
      clk_125m_pllref_p_i    : in    std_logic;
      clk_125m_pllref_n_i    : in    std_logic;
      -- 125 MHz GTP reference
      clk_125m_gtp_p_i       : in    std_logic;
      clk_125m_gtp_n_i       : in    std_logic;
      -- SFP
      sfp_txp_o              : out   std_logic;
      sfp_txn_o              : out   std_logic;
      sfp_rxp_i              : in    std_logic := '0';
      sfp_rxn_i              : in    std_logic := '1';
      sfp_mod_def0_b         : in    std_logic;        -- SFP detect pin
      sfp_mod_def1_b         : inout std_logic;        -- SFP scl
      sfp_mod_def2_b         : inout std_logic;        -- SFP sda
      sfp_rate_select_b      : inout std_logic := '0';
      sfp_tx_fault_i         : in    std_logic := '0';
      sfp_tx_disable_o       : out   std_logic;
      sfp_los_i              : in    std_logic := '0';
      -- Serial DAC
      pll20dac_din_o         : out   std_logic;
      pll20dac_sclk_o        : out   std_logic;
      pll20dac_sync_n_o      : out   std_logic;
      pll25dac_din_o         : out   std_logic;
      pll25dac_sclk_o        : out   std_logic;
      pll25dac_sync_n_o      : out   std_logic;
      -- UART
      uart_rxd_i             : in    std_logic := '1';
      uart_txd_o             : out   std_logic;
      -- 1-wire
      carrier_onewire_b      : inout std_logic;        
      -- SVEC PCB version
      pcb_ver_i              : in    std_logic_vector(3 downto 0);
      -- Mezzanines presence
      tdc1_prsntm2c_n_i      : in    std_logic;        -- Presence of mezzanine #1
      tdc2_prsntm2c_n_i      : in    std_logic;        -- Presence of mezzanine #2
      -- SVEC Front panel LEDs
      fp_led_line_oen_o      : out   std_logic_vector(1 downto 0);
      fp_led_line_o          : out   std_logic_vector(1 downto 0);
      fp_led_column_o        : out   std_logic_vector(3 downto 0);

     -- VME interface
      VME_AS_n_i             : in    std_logic;
      VME_RST_n_i            : in    std_logic;
      VME_WRITE_n_i          : in    std_logic;
      VME_AM_i               : in    std_logic_vector(5 downto 0);
      VME_DS_n_i             : in    std_logic_vector(1 downto 0);
      VME_GA_i               : in    std_logic_vector(5 downto 0);
      VME_BERR_o             : inout std_logic;
      VME_DTACK_n_o          : inout std_logic;
      VME_RETRY_n_o          : out   std_logic;
      VME_RETRY_OE_o         : out   std_logic;
      VME_LWORD_n_b          : inout std_logic;
      VME_ADDR_b             : inout std_logic_vector(31 downto 1);
      VME_DATA_b             : inout std_logic_vector(31 downto 0);
      VME_BBSY_n_i           : in    std_logic;
      VME_IRQ_n_o            : out   std_logic_vector(6 downto 0);
      VME_IACK_n_i           : in    std_logic;
      VME_IACKIN_n_i         : in    std_logic;
      VME_IACKOUT_n_o        : out   std_logic;
      VME_DTACK_OE_o         : inout std_logic;
      VME_DATA_DIR_o         : inout std_logic;
      VME_DATA_OE_N_o        : inout std_logic;
      VME_ADDR_DIR_o         : inout std_logic;
      VME_ADDR_OE_N_o        : inout std_logic;

     -- TDC mezzanine board on FMC slot 1
      -- TDC1 PLL AD9516 and DAC AD5662 interface
      tdc1_pll_sclk_o        : out   std_logic;
      tdc1_pll_sdi_o         : out   std_logic;
      tdc1_pll_cs_n_o        : out   std_logic;
      tdc1_pll_dac_sync_n_o  : out   std_logic;
      tdc1_pll_sdo_i         : in    std_logic;
      tdc1_pll_status_i      : in    std_logic;
      tdc1_125m_clk_p_i      : in    std_logic;
      tdc1_125m_clk_n_i      : in    std_logic;
      tdc1_acam_refclk_p_i   : in    std_logic;
      tdc1_acam_refclk_n_i   : in    std_logic;
      -- TDC1 ACAM timing interface
      tdc1_start_from_fpga_o : out   std_logic;
      tdc1_err_flag_i        : in    std_logic;
      tdc1_int_flag_i        : in    std_logic;
      tdc1_start_dis_o       : out   std_logic;
      tdc1_stop_dis_o        : out   std_logic;
      -- TDC1 ACAM data interface
      tdc1_data_bus_io       : inout std_logic_vector(27 downto 0);
      tdc1_address_o         : out   std_logic_vector(3 downto 0);
      tdc1_cs_n_o            : out   std_logic;
      tdc1_oe_n_o            : out   std_logic;
      tdc1_rd_n_o            : out   std_logic;
      tdc1_wr_n_o            : out   std_logic;
      tdc1_ef1_i             : in    std_logic;
      tdc1_ef2_i             : in    std_logic;
      -- TDC1 Input Logic
      tdc1_enable_inputs_o   : out   std_logic;
      tdc1_term_en_1_o       : out   std_logic;
      tdc1_term_en_2_o       : out   std_logic;
      tdc1_term_en_3_o       : out   std_logic;
      tdc1_term_en_4_o       : out   std_logic;
      tdc1_term_en_5_o       : out   std_logic;
      -- TDC1 1-wire UniqueID & Thermometer
      tdc1_onewire_b         : inout std_logic;
      -- TDC1 EEPROM I2C
      tdc1_scl_b             : inout std_logic;
      tdc1_sda_b             : inout std_logic;
      -- TDC1 LEDs
      tdc1_led_status_o      : out   std_logic;
      tdc1_led_trig1_o       : out   std_logic;
      tdc1_led_trig2_o       : out   std_logic;
      tdc1_led_trig3_o       : out   std_logic;
      tdc1_led_trig4_o       : out   std_logic;
      tdc1_led_trig5_o       : out   std_logic;
      -- TDC1 Input channels, also arriving to the FPGA (not used for the moment)
      tdc1_in_fpga_1_i       : in    std_logic;
      tdc1_in_fpga_2_i       : in    std_logic;
      tdc1_in_fpga_3_i       : in    std_logic;
      tdc1_in_fpga_4_i       : in    std_logic;
      tdc1_in_fpga_5_i       : in    std_logic;

     -- TDC mezzanine board on FMC slot 2
      -- TDC2 PLL AD9516 and DAC AD5662 interface
      tdc2_pll_sclk_o        : out   std_logic;
      tdc2_pll_sdi_o         : out   std_logic;
      tdc2_pll_cs_n_o        : out   std_logic;
      tdc2_pll_dac_sync_n_o  : out   std_logic;
      tdc2_pll_sdo_i         : in    std_logic;
      tdc2_pll_status_i      : in    std_logic;
      tdc2_125m_clk_p_i      : in    std_logic;
      tdc2_125m_clk_n_i      : in    std_logic;
      tdc2_acam_refclk_p_i   : in    std_logic;
      tdc2_acam_refclk_n_i   : in    std_logic;
      -- TDC2 ACAM timing interface
      tdc2_start_from_fpga_o : out   std_logic;
      tdc2_err_flag_i        : in    std_logic;
      tdc2_int_flag_i        : in    std_logic;
      tdc2_start_dis_o       : out   std_logic;
      tdc2_stop_dis_o        : out   std_logic;
      -- TDC2 ACAM data interface
      tdc2_data_bus_io       : inout std_logic_vector(27 downto 0);
      tdc2_address_o         : out   std_logic_vector(3 downto 0);
      tdc2_cs_n_o            : out   std_logic;
      tdc2_oe_n_o            : out   std_logic;
      tdc2_rd_n_o            : out   std_logic;
      tdc2_wr_n_o            : out   std_logic;
      tdc2_ef1_i             : in    std_logic;
      tdc2_ef2_i             : in    std_logic;
      -- TDC2 Input Logic
      tdc2_enable_inputs_o   : out   std_logic;
      tdc2_term_en_1_o       : out   std_logic;
      tdc2_term_en_2_o       : out   std_logic;
      tdc2_term_en_3_o       : out   std_logic;
      tdc2_term_en_4_o       : out   std_logic;
      tdc2_term_en_5_o       : out   std_logic;
      -- TDC2 1-wire UniqueID & Thermometer
      tdc2_onewire_b         : inout std_logic;
      -- TDC2 EEPROM I2C
      tdc2_scl_b             : inout std_logic;
      tdc2_sda_b             : inout std_logic;
      -- TDC2 LEDs
      tdc2_led_status_o      : out   std_logic;
      tdc2_led_trig1_o       : out   std_logic;
      tdc2_led_trig2_o       : out   std_logic;
      tdc2_led_trig3_o       : out   std_logic;
      tdc2_led_trig4_o       : out   std_logic;
      tdc2_led_trig5_o       : out   std_logic;
      -- TDC2 Input channels, also arriving to the FPGA (not used for the moment)
      tdc2_in_fpga_1_i       : in    std_logic;
      tdc2_in_fpga_2_i       : in    std_logic;
      tdc2_in_fpga_3_i       : in    std_logic;
      tdc2_in_fpga_4_i       : in    std_logic;
      tdc2_in_fpga_5_i       : in    std_logic);
end wr_svec_tdc;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of wr_svec_tdc is

---------------------------------------------------------------------------------------------------
--                                         SDB CONSTANTS                                         --
---------------------------------------------------------------------------------------------------
  -- Constant regarding the Carrier type
  constant c_CARRIER_TYPE   : std_logic_vector(15 downto 0) := x"0002";
    --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Constants regarding the SDB crossbar
  constant c_NUM_WB_SLAVES  : integer := 1;
  constant c_NUM_WB_MASTERS : integer := 6;
  constant c_MASTER_VME     : integer := 0;
    --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  constant c_SLAVE_SVEC_1W   : integer := 0;  -- SVEC 1wire interface
  constant c_SLAVE_SVEC_INFO : integer := 1;  -- SVEC carrier info
  constant c_SLAVE_VIC       : integer := 2;  -- Vector Interrupt controller
  constant c_SLAVE_TDC0      : integer := 3;  -- TDC mezzanine #1
  constant c_SLAVE_TDC1      : integer := 4;  -- TDC mezzanine #2
  constant c_SLAVE_WRCORE    : integer := 5;  -- White Rabbit PTP core

  constant c_SDB_ADDRESS         : t_wishbone_address := x"00000000";
  constant c_FMC_TDC1_SDB_BRIDGE : t_sdb_bridge       := f_xwb_bridge_manual_sdb(x"0001FFFF", x"00000000");
  constant c_FMC_TDC2_SDB_BRIDGE : t_sdb_bridge       := f_xwb_bridge_manual_sdb(x"0001FFFF", x"00000000");
  constant c_WRCORE_BRIDGE_SDB   : t_sdb_bridge       := f_xwb_bridge_manual_sdb(x"0003ffff", x"00030000");

  constant c_INTERCONNECT_LAYOUT : t_sdb_record_array(7 downto 0) :=
    (0 => f_sdb_embed_device     (c_ONEWIRE_SDB_DEVICE,   x"00010000"),
     1 => f_sdb_embed_device     (c_SVEC_INFO_SDB_DEVICE, x"00020000"),
     2 => f_sdb_embed_device     (c_xwb_vic_sdb,          x"00030000"),
     3 => f_sdb_embed_bridge     (c_FMC_TDC1_SDB_BRIDGE,  x"00040000"),
     4 => f_sdb_embed_bridge     (c_FMC_TDC2_SDB_BRIDGE,  x"00060000"),
     5 => f_sdb_embed_bridge     (c_WRCORE_BRIDGE_SDB,    x"00080000"),
     6 => f_sdb_embed_repo_url   (c_SDB_REPO_URL),
     7 => f_sdb_embed_synthesis  (c_sdb_synthesis_info));


---------------------------------------------------------------------------------------------------
--                                         VIC CONSTANT                                          --
---------------------------------------------------------------------------------------------------
  constant c_VIC_VECTOR_TABLE : t_wishbone_address_array(0 to 1) :=
    (0 => x"00052000",
     1 => x"00072000");


---------------------------------------------------------------------------------------------------
--                                            Signals                                            --
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
 -- Clocks
  -- CLOCK DOMAIN: 20 MHz VCXO clock on SVEC carrier board: clk_20m_vcxo_i
  signal clk_20m_vcxo_buf, clk_20m_vcxo       : std_logic;
  -- CLOCK DOMAIN: 62.5 MHz system clock derived from clk_20m_vcxo_i by a Xilinx PLL: clk_62m5_sys
  signal clk_62m5_sys, pllout_clk_sys         : std_logic;
  signal pllout_clk_sys_fb, sys_locked        : std_logic;
  -- CLOCK DOMAIN: 125 MHz clock from PLL on TDC1: tdc1_125m_clk
  signal tdc1_125m_clk                        : std_logic;
  signal tdc1_acam_refclk_r_edge_p            : std_logic;
  signal tdc1_send_dac_word_p                 : std_logic;
  signal tdc1_dac_word                        : std_logic_vector(23 downto 0);
  signal tdc1_slave_in                        : t_wishbone_slave_in;
  signal tdc1_slave_out                       : t_wishbone_slave_out;
  signal tdc1_irq_acam_err_p                  : std_logic;
  signal tdc1_irq_tstamp_p, tdc1_irq_time_p   : std_logic;
  -- CLOCK DOMAIN: 125 MHz clock from PLL on TDC2: tdc2_125m_clk
  signal tdc2_125m_clk                        : std_logic;
  signal tdc2_acam_refclk_r_edge_p            : std_logic;
  signal tdc2_send_dac_word_p                 : std_logic;
  signal tdc2_dac_word                        : std_logic_vector(23 downto 0);
  signal tdc2_slave_in                        : t_wishbone_slave_in;
  signal tdc2_slave_out                       : t_wishbone_slave_out;
  signal tdc2_irq_acam_err_p                  : std_logic;
  signal tdc2_irq_tstamp_p, tdc2_irq_time_p   : std_logic;
  -- WHITE RABBIT CLOCKS:
  signal pllout_clk_dmtd, pllout_clk_fb_dmtd  : std_logic;
  signal pllout_clk_fb_pllref                 : std_logic;
  signal clk_125m_pllref, clk_125m_gtp        : std_logic;
  signal clk_dmtd                             : std_logic;
  attribute buffer_type                       : string;  --" {bufgdll | ibufg | bufgp | ibuf | bufr | none}";
  attribute buffer_type of clk_125m_pllref    : signal is "BUFG";

---------------------------------------------------------------------------------------------------
 -- Resets
  -- asynchronous reset from the FPGA inputs VME_RST_n_i and por_n_i
  signal por_rst_n_a                          : std_logic;
  signal powerup_rst_cnt                      : unsigned(7 downto 0) := "00000000";
  -- system reset, synched with 62.5 MHz clock,driven by the VME reset and power-up reset pins.
  signal rst_n_sys                            : std_logic;
  -- reset input to the clks_rsts_manager units of the two TDC cores;
  -- this reset initiates the configuration of the mezzanines PLL
  signal tdc1_soft_rst_n                      : std_logic; -- driven by carrier CSR reserved bit 0
  signal tdc2_soft_rst_n                      : std_logic; -- driven by carrier CSR reserved bit 1
  signal carrier_info_fmc_rst                 : std_logic_vector(30 downto 0);
  signal carrier_info_stat_reserv             : std_logic_vector(27 downto 0);
  -- output reset of the clks_rsts_manager units;
  -- this reset is released when the 125 MHz from the mezzanines PLL is available
  signal tdc1_general_rst, tdc1_general_rst_n : std_logic;
  signal tdc2_general_rst, tdc2_general_rst_n : std_logic;

---------------------------------------------------------------------------------------------------
 -- VME interface
  signal VME_DATA_b_out                       : std_logic_vector(31 downto 0);
  signal VME_ADDR_b_out                       : std_logic_vector(31 downto 1);
  signal VME_LWORD_n_b_out                    : std_logic;
  signal VME_DATA_DIR_int                     : std_logic;
  signal VME_ADDR_DIR_int                     : std_logic;

---------------------------------------------------------------------------------------------------
  -- White Rabbit signals to TDC mezzanine
  signal tm_link_up, tm_time_valid            : std_logic;
  signal tm_utc                               : std_logic_vector(39 downto 0);
  signal tm_cycles                            : std_logic_vector(27 downto 0);
  signal tm_clk_aux_lock_en, tm_clk_aux_locked: std_logic_vector(1 downto 0);
  -- White Rabbit signals to clks_rsts_manager
  signal tm_dac_value                         : std_logic_vector(23 downto 0);
  signal tm_dac_wr_p                          : std_logic_vector(1 downto 0);
  -- White Rabbit PHY
  signal phy_tx_data, phy_rx_data             : std_logic_vector(7 downto 0);
  signal phy_tx_k, phy_tx_disparity, phy_rx_k : std_logic;
  signal phy_tx_enc_err, phy_rx_rbclk         : std_logic;
  signal phy_rx_enc_err, phy_rst, phy_loopen  : std_logic;
  signal phy_rx_bitslide                      : std_logic_vector(3 downto 0);
  -- White Rabbit serial DAC
  signal dac_hpll_load_p1, dac_dpll_load_p1   : std_logic;
  signal dac_hpll_data, dac_dpll_data         : std_logic_vector(15 downto 0);
  -- White Rabbit to mezzanine EEPROM
  signal wrc_scl_out, wrc_scl_in              : std_logic;
  signal wrc_sda_out, wrc_sda_in              : std_logic;
  -- White Rabbit to SFP EEPROM
  signal sfp_scl_out, sfp_scl_in              : std_logic;
  signal sfp_sda_out, sfp_sda_in              : std_logic;
  -- White Rabbit Carrier 1-Wire
  signal wrc_owr_en, wrc_owr_in               : std_logic_vector(1 downto 0);

---------------------------------------------------------------------------------------------------
 -- Crossbar
  -- WISHBONE from crossbar master port
  signal cnx_master_out                       : t_wishbone_master_out_array(c_NUM_WB_MASTERS-1 downto 0);
  signal cnx_master_in                        : t_wishbone_master_in_array (c_NUM_WB_MASTERS-1 downto 0);
  -- WISHBONE to crossbar slave port
  signal cnx_slave_out                        : t_wishbone_slave_out_array (c_NUM_WB_SLAVES-1 downto 0);
  signal cnx_slave_in                         : t_wishbone_slave_in_array  (c_NUM_WB_SLAVES-1 downto 0);

---------------------------------------------------------------------------------------------------
-- Interrupts
  signal irq_to_vmecore                       : std_logic;
  signal tdc1_irq, tdc2_irq                   : std_logic;
  signal tdc1_irq_synch, tdc2_irq_synch       : std_logic_vector (1 downto 0);

---------------------------------------------------------------------------------------------------
-- Mezzanines EEPROM
  signal tdc1_scl_out, tdc1_scl_in            : std_logic; 
  signal tdc1_sda_out, tdc1_sda_in            : std_logic;
  signal tdc1_scl_oen, tdc1_sda_oen           : std_logic;
  signal tdc2_scl_out, tdc2_scl_in            : std_logic;
  signal tdc2_sda_out, tdc2_sda_in            : std_logic;
  signal tdc2_scl_oen, tdc2_sda_oen           : std_logic;

---------------------------------------------------------------------------------------------------
 -- Carrier other signals
  signal mezz_pll_status                      : std_logic_vector(11 downto 0);
  signal carrier_owr_en, carrier_owr_i        : std_logic_vector(c_FMC_ONEWIRE_NB - 1 downto 0);
  -- LEDs
  signal led_state                            : std_logic_vector(15 downto 0);
  signal tdc1_ef, tdc2_ef, led_tdc1_ef        : std_logic;
  signal led_tdc2_ef, led_vme_access          : std_logic;
  signal led_clk_62m5_divider                 : unsigned(22 downto 0);
  signal led_clk_62m5_aux                     : std_logic_vector(7 downto 0);
  signal led_clk_62m5                         : std_logic;
  signal wrabbit_led_red, wrabbit_led_green   : std_logic;


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

---------------------------------------------------------------------------------------------------
--                                     62.5 MHz system clock                                     --
---------------------------------------------------------------------------------------------------

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  svec_clk_ibuf : IBUFG
  port map
  (I => clk_20m_vcxo_i,
   O => clk_20m_vcxo_buf);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_sys_clk_pll : PLL_BASE
  generic map
    (BANDWIDTH          => "OPTIMIZED",
     CLK_FEEDBACK       => "CLKFBOUT",
     COMPENSATION       => "INTERNAL",
     DIVCLK_DIVIDE      => 1,
     CLKFBOUT_MULT      => 50,    -- 20 MHz x 50 = 1 GHz
     CLKFBOUT_PHASE     => 0.000,
     CLKOUT0_DIVIDE     => 16,    -- 62.5 MHz
     CLKOUT0_PHASE      => 0.000,
     CLKOUT0_DUTY_CYCLE => 0.500,
     CLKOUT1_DIVIDE     => 16,    -- 125 MHz, not used
     CLKOUT1_PHASE      => 0.000,
     CLKOUT1_DUTY_CYCLE => 0.500,
     CLKOUT2_DIVIDE     => 16,
     CLKOUT2_PHASE      => 0.000,
     CLKOUT2_DUTY_CYCLE => 0.500,
     CLKIN_PERIOD       => 50.0,
     REF_JITTER         => 0.016)
  port map
    (CLKFBOUT => pllout_clk_sys_fb,
     CLKOUT0  => pllout_clk_sys,
     CLKOUT1  => open,
     CLKOUT2  => open,
     CLKOUT3  => open,
     CLKOUT4  => open,
     CLKOUT5  => open,
     LOCKED   => sys_locked,
     RST      => '0',
     CLKFBIN  => pllout_clk_sys_fb,
     CLKIN    => clk_20m_vcxo_buf);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_clk_sys_buf : BUFG
  port map
    (O => clk_62m5_sys,
     I => pllout_clk_sys);


---------------------------------------------------------------------------------------------------
--                                         62.5 MHz Reset                                        --
---------------------------------------------------------------------------------------------------
-- SVEC power-up reset in the clk_62m5_sys domain: rst_n_sys is asserted asynchronously upon VME
-- reset or SVEC AFPGA power-on reset. If none of these signals is asserted at startup, the process
-- waits for the system clock PLL to lock + additional 256 clk_62m5_sys cycles before de-asserting
-- the reset.

  p_powerup_reset : process(clk_62m5_sys, por_rst_n_a)
  begin
    if(por_rst_n_a = '0') then
      rst_n_sys           <= '0';
    elsif rising_edge(clk_62m5_sys) then
      if sys_locked = '1' then
        if(powerup_rst_cnt = "11111111") then
          rst_n_sys       <= '1';
        else
          rst_n_sys       <= '0';
          powerup_rst_cnt <= powerup_rst_cnt + 1;
        end if;
      else
        rst_n_sys         <= '0';
        powerup_rst_cnt   <= "00000000";
      end if;
    end if;
  end process;
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  por_rst_n_a <= VME_RST_n_i and por_n_i;


---------------------------------------------------------------------------------------------------
--                                         TDC#1 125 MHz                                         --
---------------------------------------------------------------------------------------------------
  cmp_tdc1_clks_rsts_mgment : clks_rsts_manager
  generic map
    (nb_of_reg                 => 68)
  port map
    (clk_sys_i                 => clk_62m5_sys,
     acam_refclk_p_i           => tdc1_acam_refclk_p_i,
     acam_refclk_n_i           => tdc1_acam_refclk_n_i,
     tdc_125m_clk_p_i          => tdc1_125m_clk_p_i,
     tdc_125m_clk_n_i          => tdc1_125m_clk_n_i,
     rst_n_i                   => tdc1_soft_rst_n, -- software reset; needs to be released for TDC core to startup
     pll_sdo_i                 => tdc1_pll_sdo_i,
     pll_status_i              => tdc1_pll_status_i,
     send_dac_word_p_i         => tdc1_send_dac_word_p,
     dac_word_i                => tdc1_dac_word,
     acam_refclk_r_edge_p_o    => tdc1_acam_refclk_r_edge_p,
     wrabbit_dac_value_i       => tm_dac_value,
     wrabbit_dac_wr_p_i        => tm_dac_wr_p(0),
     internal_rst_o            => tdc1_general_rst,
     pll_cs_n_o                => tdc1_pll_cs_n_o,
     pll_dac_sync_n_o          => tdc1_pll_dac_sync_n_o,
     pll_sdi_o                 => tdc1_pll_sdi_o,
     pll_sclk_o                => tdc1_pll_sclk_o,
     tdc_125m_clk_o            => tdc1_125m_clk,
     pll_status_o              => open);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  tdc1_general_rst_n          <= not tdc1_general_rst;
  tdc1_soft_rst_n             <= carrier_info_fmc_rst(0) and rst_n_sys;


---------------------------------------------------------------------------------------------------
--                                          TDC#2 125 MHz                                        --
---------------------------------------------------------------------------------------------------
  cmp_tdc2_clks_rsts_mgment : clks_rsts_manager
  generic map
    (nb_of_reg                 => 68)
  port map
    (clk_sys_i                 => clk_62m5_sys,
     acam_refclk_p_i           => tdc2_acam_refclk_p_i,
     acam_refclk_n_i           => tdc2_acam_refclk_n_i,
     tdc_125m_clk_p_i          => tdc2_125m_clk_p_i,
     tdc_125m_clk_n_i          => tdc2_125m_clk_n_i,
     rst_n_i                   => tdc2_soft_rst_n, -- software reset; needs to be released for TDC core to startup
     pll_sdo_i                 => tdc2_pll_sdo_i,
     pll_status_i              => tdc2_pll_status_i,
     send_dac_word_p_i         => tdc2_send_dac_word_p,
     dac_word_i                => tdc2_dac_word,
     acam_refclk_r_edge_p_o    => tdc2_acam_refclk_r_edge_p,
     wrabbit_dac_value_i       => tm_dac_value,
     wrabbit_dac_wr_p_i        => tm_dac_wr_p(1),
     internal_rst_o            => tdc2_general_rst,
     pll_cs_n_o                => tdc2_pll_cs_n_o,
     pll_dac_sync_n_o          => tdc2_pll_dac_sync_n_o,
     pll_sdi_o                 => tdc2_pll_sdi_o,
     pll_sclk_o                => tdc2_pll_sclk_o,
     tdc_125m_clk_o            => tdc2_125m_clk,
     pll_status_o              => open);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  tdc2_general_rst_n           <= not tdc2_general_rst;
  tdc2_soft_rst_n              <= carrier_info_fmc_rst(1) and rst_n_sys;


---------------------------------------------------------------------------------------------------
--                                      62.5 MHz DMTD clock                                      --
---------------------------------------------------------------------------------------------------

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_dmtd_clk_pll : PLL_BASE
  generic map
    (BANDWIDTH          => "OPTIMIZED",
     CLK_FEEDBACK       => "CLKFBOUT",
     COMPENSATION       => "INTERNAL",
     DIVCLK_DIVIDE      => 1,
     CLKFBOUT_MULT      => 50,
     CLKFBOUT_PHASE     => 0.000,
     CLKOUT0_DIVIDE     => 16,         -- 62.5 MHz
     CLKOUT0_PHASE      => 0.000,
     CLKOUT0_DUTY_CYCLE => 0.500,
     CLKOUT1_DIVIDE     => 16,         -- not used
     CLKOUT1_PHASE      => 0.000,
     CLKOUT1_DUTY_CYCLE => 0.500,
     CLKOUT2_DIVIDE     => 8,
     CLKOUT2_PHASE      => 0.000,
     CLKOUT2_DUTY_CYCLE => 0.500,
     CLKIN_PERIOD       => 50.0,
     REF_JITTER         => 0.016)
  port map
    (CLKFBOUT           => pllout_clk_fb_dmtd,
     CLKOUT0            => pllout_clk_dmtd,
     CLKOUT1            => open,
     CLKOUT2            => open,
     CLKOUT3            => open,
     CLKOUT4            => open,
     CLKOUT5            => open,
     LOCKED             => open,
     RST                => '0',
     CLKFBIN            => pllout_clk_fb_dmtd,
     CLKIN              => clk_20m_vcxo_buf);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_clk_dmtd_buf : BUFG
  port map
    (O => clk_dmtd,
     I => pllout_clk_dmtd);


---------------------------------------------------------------------------------------------------
--                               125 MHz clk for White Rabbit core                               --
---------------------------------------------------------------------------------------------------

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  U_Buf_CLK_PLL : IBUFGDS
  generic map
    (DIFF_TERM    => true,
     IBUF_LOW_PWR => true)       -- Low power (TRUE) vs. performance (FALSE) setting for referenced
  port map
    (O  => clk_125m_pllref,      -- Buffer output
     I  => clk_125m_pllref_p_i,  -- Diff_p buffer input (connect directly to top-level port)
     IB => clk_125m_pllref_n_i); -- Diff_n buffer input (connect directly to top-level port)

     --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  U_Buf_CLK_GTP : IBUFDS
  generic map
    (DIFF_TERM   => true,
     IBUF_LOW_PWR => false)
  port map
    (O  => clk_125m_gtp,
     I  => clk_125m_gtp_p_i,
     IB => clk_125m_gtp_n_i);


---------------------------------------------------------------------------------------------------
--                                  White Rabbit Core + PHY                                      --
---------------------------------------------------------------------------------------------------

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  U_WR_CORE : xwr_core
  generic map
    (g_simulation                => 0,
     g_phys_uart                 => true,
     g_virtual_uart              => true,
     g_with_external_clock_input => false,
     g_aux_clks                  => 2,
     g_ep_rxbuf_size             => 1024,
     g_dpram_initf               => "wrc.ram",
     g_dpram_size                => 90112/4,
     g_interface_mode            => PIPELINED,
     g_address_granularity       => BYTE,
     g_softpll_enable_debugger   => false)
  port map
    (clk_sys_i                   => clk_62m5_sys,
     clk_dmtd_i                  => clk_dmtd,
     clk_ref_i                   => clk_125m_pllref,
     clk_aux_i(0)                => tdc1_125m_clk,
     clk_aux_i(1)                => tdc2_125m_clk,
     rst_n_i                     => rst_n_sys,
     -- DAC
     dac_hpll_load_p1_o          => dac_hpll_load_p1,
     dac_hpll_data_o             => dac_hpll_data,
     dac_dpll_load_p1_o          => dac_dpll_load_p1,
     dac_dpll_data_o             => dac_dpll_data,
     -- PHY
     phy_ref_clk_i               => clk_125m_pllref,
     phy_tx_data_o               => phy_tx_data,
     phy_tx_k_o                  => phy_tx_k,
     phy_tx_disparity_i          => phy_tx_disparity,
     phy_tx_enc_err_i            => phy_tx_enc_err,
     phy_rx_data_i               => phy_rx_data,
     phy_rx_rbclk_i              => phy_rx_rbclk,
     phy_rx_k_i                  => phy_rx_k,
     phy_rx_enc_err_i            => phy_rx_enc_err,
     phy_rx_bitslide_i           => phy_rx_bitslide,
     phy_rst_o                   => phy_rst,
     phy_loopen_o                => phy_loopen,
     -- SPEC LEDs
     led_act_o                   => wrabbit_led_red,
     led_link_o                  => wrabbit_led_green,
     -- SFP
     scl_o                       => wrc_scl_out,
     scl_i                       => wrc_scl_in,
     sda_o                       => wrc_sda_out,
     sda_i                       => wrc_sda_in,
     sfp_scl_o                   => sfp_scl_out,
     sfp_scl_i                   => sfp_scl_in,
     sfp_sda_o                   => sfp_sda_out,
     sfp_sda_i                   => sfp_sda_in,
     sfp_det_i                   => sfp_mod_def0_b,

     uart_rxd_i                  => uart_rxd_i,
     uart_txd_o                  => uart_txd_o,
     -- 1-wire
     owr_en_o                    => wrc_owr_en,
     owr_i                       => wrc_owr_in,
     -- WISHBONE
     slave_i                     => cnx_master_out(c_SLAVE_WRCORE),
     slave_o                     => cnx_master_in(c_SLAVE_WRCORE),
     -- Timimg info for TDC core
     tm_link_up_o                => tm_link_up,
     tm_dac_value_o              => tm_dac_value,
     tm_dac_wr_o                 => tm_dac_wr_p,
     tm_clk_aux_lock_en_i        => tm_clk_aux_lock_en,
     tm_clk_aux_locked_o         => tm_clk_aux_locked,
     tm_time_valid_o             => tm_time_valid,
     tm_tai_o                    => tm_utc,
     tm_cycles_o                 => tm_cycles,
     -- not used
     btn1_i                      => '0',
     btn2_i                      => '0',
     pps_p_o                     => open,
     -- aux reset
     rst_aux_n_o                 => open);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  U_GTP : wr_gtp_phy_spartan6
  generic map
    (g_simulation       => 0,
     g_enable_ch0       => 0,
     g_enable_ch1       => 1)
  port map
    (gtp_clk_i          => clk_125m_gtp,
     ch0_ref_clk_i      => clk_125m_pllref,
     ch0_tx_data_i      => x"00",
     ch0_tx_k_i         => '0',
     ch0_tx_disparity_o => open,
     ch0_tx_enc_err_o   => open,
     ch0_rx_rbclk_o     => open,
     ch0_rx_data_o      => open,
     ch0_rx_k_o         => open,
     ch0_rx_enc_err_o   => open,
     ch0_rx_bitslide_o  => open,
     ch0_rst_i          => '1',
     ch0_loopen_i       => '0',
     ch1_ref_clk_i      => clk_125m_pllref,
     ch1_tx_data_i      => phy_tx_data,
     ch1_tx_k_i         => phy_tx_k,
     ch1_tx_disparity_o => phy_tx_disparity,
     ch1_tx_enc_err_o   => phy_tx_enc_err,
     ch1_rx_data_o      => phy_rx_data,
     ch1_rx_rbclk_o     => phy_rx_rbclk,
     ch1_rx_k_o         => phy_rx_k,
     ch1_rx_enc_err_o   => phy_rx_enc_err,
     ch1_rx_bitslide_o  => phy_rx_bitslide,
     ch1_rst_i          => phy_rst,
     ch1_loopen_i       => '0', -- phy_loopen,
     pad_txn0_o         => open,
     pad_txp0_o         => open,
     pad_rxn0_i         => '0',
     pad_rxp0_i         => '0',
     pad_txn1_o         => sfp_txn_o,
     pad_txp1_o         => sfp_txp_o,
     pad_rxn1_i         => sfp_rxn_i,
     pad_rxp1_i         => sfp_rxp_i);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  U_DAC_Helper : spec_serial_dac
  generic map
    (g_num_data_bits  => 16,
     g_num_extra_bits => 8,
     g_num_cs_select  => 1)
  port map
    (clk_i            => clk_62m5_sys,
     rst_n_i          => rst_n_sys,
     value_i          => dac_hpll_data,
     cs_sel_i         => "1",
     load_i           => dac_hpll_load_p1,
     sclk_divsel_i    => "010",
     dac_cs_n_o(0)    => pll20dac_sync_n_o,
     dac_sclk_o       => pll20dac_sclk_o,
     dac_sdata_o      => pll20dac_din_o,
     xdone_o          => open);

  U_DAC_Main : spec_serial_dac
  generic map
    (g_num_data_bits  => 16,
     g_num_extra_bits => 8,
     g_num_cs_select  => 1)
  port map
    (clk_i         => clk_62m5_sys,
     rst_n_i       => rst_n_sys,
     value_i       => dac_dpll_data,
     cs_sel_i      => "1",
     load_i        => dac_dpll_load_p1,
     sclk_divsel_i => "010",
     dac_cs_n_o(0) => pll25dac_sync_n_o,
     dac_sclk_o    => pll25dac_sclk_o,
     dac_sdata_o   => pll25dac_din_o,
     xdone_o       => open);


  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Tristates for mezzanine EEPROM
  tdc1_scl_b   <= tdc1_scl_out when (tdc1_scl_oen = '0') else '0' when (wrc_scl_out = '0') else 'Z';
  tdc1_sda_b   <= tdc1_sda_out when (tdc1_sda_oen = '0') else '0' when (wrc_sda_out = '0') else 'Z';
  wrc_scl_in   <= tdc1_scl_b;
  wrc_sda_in   <= tdc1_sda_b;
  tdc1_scl_in  <= tdc1_scl_b;
  tdc1_sda_in  <= tdc1_sda_b;

  tdc2_scl_b   <= tdc2_scl_out when (tdc2_scl_oen = '0') else 'Z';
  tdc2_sda_b   <= tdc2_sda_out when (tdc2_sda_oen = '0') else 'Z';


  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Tristates for SFP EEPROM
  sfp_mod_def1_b      <= '0' when sfp_scl_out = '0' else 'Z';
  sfp_mod_def2_b      <= '0' when sfp_sda_out = '0' else 'Z';
  sfp_scl_in          <= sfp_mod_def1_b;
  sfp_sda_in          <= sfp_mod_def2_b;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  carrier_onewire_b   <= '0' when wrc_owr_en(0) = '1' else 'Z';
  wrc_owr_in(0)       <= carrier_onewire_b;
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --

  -- The SFP is permanently enabled.
  sfp_tx_disable_o <= '0';

---------------------------------------------------------------------------------------------------
--                                     CSR WISHBONE CROSSBAR                                     --
---------------------------------------------------------------------------------------------------
-- WISHBONE crossbar
--  0x10000 -> SVEC carrier UnidueID&Thermometer 1-wire
--  0x20000 -> SVEC CSR information
--  0x30000 -> VIC
--  0x40000 -> TDC board on FMC#1
--  0x60000 -> TDC board on FMC#2
--  0x80000 -> White Rabbit core

  cmp_sdb_crossbar : xwb_sdb_crossbar
  generic map
    (g_num_masters => c_NUM_WB_SLAVES,
     g_num_slaves  => c_NUM_WB_MASTERS,
     g_registered  => true,
     g_wraparound  => true,
     g_layout      => c_INTERCONNECT_LAYOUT,
     g_sdb_addr    => c_SDB_ADDRESS)
  port map
    (clk_sys_i => clk_62m5_sys,
     rst_n_i   => rst_n_sys,
     slave_i   => cnx_slave_in,
     slave_o   => cnx_slave_out,
     master_i  => cnx_master_in,
     master_o  => cnx_master_out);


---------------------------------------------------------------------------------------------------
--                                           VME CORE                                            --
---------------------------------------------------------------------------------------------------
  U_VME_Core : xvme64x_core
  port map
    (clk_i           => clk_62m5_sys,
     rst_n_i         => rst_n_sys,
     VME_AS_n_i      => VME_AS_n_i,
     VME_RST_n_i     => VME_RST_n_i,
     VME_WRITE_n_i   => VME_WRITE_n_i,
     VME_AM_i        => VME_AM_i,
     VME_DS_n_i      => VME_DS_n_i,
     VME_GA_i        => VME_GA_i,
     VME_BERR_o      => VME_BERR_o,
     VME_DTACK_n_o   => VME_DTACK_n_o,
     VME_RETRY_n_o   => VME_RETRY_n_o,
     VME_RETRY_OE_o  => VME_RETRY_OE_o,
     VME_LWORD_n_b_i => VME_LWORD_n_b,
     VME_LWORD_n_b_o => VME_LWORD_n_b_out,
     VME_ADDR_b_i    => VME_ADDR_b,
     VME_DATA_b_o    => VME_DATA_b_out,
     VME_ADDR_b_o    => VME_ADDR_b_out,
     VME_DATA_b_i    => VME_DATA_b,
     VME_IRQ_n_o     => VME_IRQ_n_o,
     VME_IACK_n_i    => VME_IACK_n_i,
     VME_IACKIN_n_i  => VME_IACKIN_n_i,
     VME_IACKOUT_n_o => VME_IACKOUT_n_o,
     VME_DTACK_OE_o  => VME_DTACK_OE_o,
     VME_DATA_DIR_o  => VME_DATA_DIR_int,
     VME_DATA_OE_N_o => VME_DATA_OE_N_o,
     VME_ADDR_DIR_o  => VME_ADDR_DIR_int,
     VME_ADDR_OE_N_o => VME_ADDR_OE_N_o,
     master_o        => cnx_slave_in (c_MASTER_VME),
     master_i        => cnx_slave_out(c_MASTER_VME),
     irq_i           => irq_to_vmecore);
 --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  VME_DATA_b         <= VME_DATA_b_out    when VME_DATA_DIR_int = '1' else (others => 'Z');
  VME_ADDR_b         <= VME_ADDR_b_out    when VME_ADDR_DIR_int = '1' else (others => 'Z');
  VME_LWORD_n_b      <= VME_LWORD_n_b_out when VME_ADDR_DIR_int = '1' else 'Z';
  VME_ADDR_DIR_o     <= VME_ADDR_DIR_int;
  VME_DATA_DIR_o     <= VME_DATA_DIR_int;


---------------------------------------------------------------------------------------------------
--                                            TDC BOARD #1                                       --
---------------------------------------------------------------------------------------------------

  cmp_tdc1 : fmc_tdc_mezzanine
  generic map
    (g_with_wrabbit_core       => TRUE,
     g_span                    => g_span,
     g_width                   => g_width,
     values_for_simul          => values_for_simul)
  port map
    (clk_sys_i                 => clk_62m5_sys,
     rst_sys_n_i               => rst_n_sys,
     -- 125M clk and reset
     clk_ref_0_i               => tdc1_125m_clk,
     rst_ref_0_i               => tdc1_general_rst,
     acam_refclk_r_edge_p_i    => tdc1_acam_refclk_r_edge_p,
     send_dac_word_p_o         => tdc1_send_dac_word_p,
     dac_word_o                => tdc1_dac_word,
     -- ACAM
     start_from_fpga_o         => tdc1_start_from_fpga_o,
     err_flag_i                => tdc1_err_flag_i,
     int_flag_i                => tdc1_int_flag_i,
     start_dis_o               => tdc1_start_dis_o,
     stop_dis_o                => tdc1_stop_dis_o,
     data_bus_io               => tdc1_data_bus_io,
     address_o                 => tdc1_address_o,
     cs_n_o                    => tdc1_cs_n_o,
     oe_n_o                    => tdc1_oe_n_o,
     rd_n_o                    => tdc1_rd_n_o,
     wr_n_o                    => tdc1_wr_n_o,
     ef1_i                     => tdc1_ef1_i,
     ef2_i                     => tdc1_ef2_i,
     -- Input channels enable
     enable_inputs_o           => tdc1_enable_inputs_o,
     term_en_1_o               => tdc1_term_en_1_o,
     term_en_2_o               => tdc1_term_en_2_o,
     term_en_3_o               => tdc1_term_en_3_o,
     term_en_4_o               => tdc1_term_en_4_o,
     term_en_5_o               => tdc1_term_en_5_o,
     -- Input channels to FPGA (not used)
     tdc_in_fpga_1_i           => tdc1_in_fpga_1_i,
     tdc_in_fpga_2_i           => tdc1_in_fpga_2_i,
     tdc_in_fpga_3_i           => tdc1_in_fpga_3_i,
     tdc_in_fpga_4_i           => tdc1_in_fpga_4_i,
     tdc_in_fpga_5_i           => tdc1_in_fpga_5_i,
     -- LEDs and buttons on TDC and SPEC
     tdc_led_status_o          => tdc1_led_status_o,
     tdc_led_trig1_o           => tdc1_led_trig1_o,
     tdc_led_trig2_o           => tdc1_led_trig2_o,
     tdc_led_trig3_o           => tdc1_led_trig3_o,
     tdc_led_trig4_o           => tdc1_led_trig4_o,
     tdc_led_trig5_o           => tdc1_led_trig5_o,
     -- WISHBONE interface with the GNUM/VME_core
     wb_tdc_csr_adr_i          => tdc1_slave_in.adr,
     wb_tdc_csr_dat_i          => tdc1_slave_in.dat,
     wb_tdc_csr_dat_o          => tdc1_slave_out.dat,
     wb_tdc_csr_cyc_i          => tdc1_slave_in.cyc,
     wb_tdc_csr_sel_i          => tdc1_slave_in.sel,
     wb_tdc_csr_stb_i          => tdc1_slave_in.stb,
     wb_tdc_csr_we_i           => tdc1_slave_in.we,
     wb_tdc_csr_ack_o          => tdc1_slave_out.ack,
     wb_tdc_csr_stall_o        => tdc1_slave_out.stall,
    -- White Rabbit
     wrabbit_link_up_i         => tm_link_up,
     wrabbit_time_valid_i      => tm_time_valid,
     wrabbit_cycles_i          => tm_cycles,
     wrabbit_utc_i             => tm_utc(31 downto 0),
     wrabbit_clk_aux_lock_en_o => tm_clk_aux_lock_en(0),
     wrabbit_clk_aux_locked_i  => tm_clk_aux_locked(0),
     wrabbit_clk_dmtd_locked_i => '1', -- FIXME: fan out real signal from the WRCore
     wrabbit_dac_value_i       => tm_dac_value,   -- only for debug
     wrabbit_dac_wr_p_i        => tm_dac_wr_p(0), -- only for debug
     -- Interrupts
     wb_irq_o                  => tdc1_irq,
    -- EEPROM I2C on TDC mezzanine
     i2c_scl_oen_o             => tdc1_scl_oen,
     i2c_scl_i                 => tdc1_scl_in,
     i2c_sda_oen_o             => tdc1_sda_oen,
     i2c_sda_i                 => tdc1_sda_in,
     i2c_scl_o                 => tdc1_scl_out,
     i2c_sda_o                 => tdc1_sda_out,
     -- 1-wire UniqueID&Thermometer interface
     onewire_b                 => tdc1_onewire_b);


---------------------------------------------------------------------------------------------------
--                     TDC#1 domains crossing: tdc1_125m_clk <-> clk_62m5_sys                    --
---------------------------------------------------------------------------------------------------
  cmp_tdc1_clks_crossing : xwb_clock_crossing
  port map
    (slave_clk_i    => clk_62m5_sys,  -- Slave control port: VME interface at 62.5 MHz
     slave_rst_n_i  => rst_n_sys,
     slave_i        => cnx_master_out(c_SLAVE_TDC0),
     slave_o        => cnx_master_in(c_SLAVE_TDC0),
     master_clk_i   => tdc1_125m_clk, -- Master reader port: TDC core at 125 MHz
     master_rst_n_i => tdc1_general_rst_n,
     master_i       => tdc1_slave_out,
     master_o       => tdc1_slave_in);


---------------------------------------------------------------------------------------------------
--                                            TDC BOARD #2                                       --
---------------------------------------------------------------------------------------------------
  cmp_tdc2 : fmc_tdc_mezzanine
  generic map
    (g_with_wrabbit_core       => TRUE,
     g_span                    => g_span,
     g_width                   => g_width,
     values_for_simul          => values_for_simul)
  port map
    (clk_sys_i                 => clk_62m5_sys,
     rst_sys_n_i               => rst_n_sys,
     -- 125M clk and reset
     clk_ref_0_i               => tdc2_125m_clk,
     rst_ref_0_i               => tdc2_general_rst,
     acam_refclk_r_edge_p_i    => tdc2_acam_refclk_r_edge_p,
     send_dac_word_p_o         => tdc2_send_dac_word_p,
     dac_word_o                => tdc2_dac_word,  
     -- ACAM
     start_from_fpga_o         => tdc2_start_from_fpga_o,
     err_flag_i                => tdc2_err_flag_i,
     int_flag_i                => tdc2_int_flag_i,
     start_dis_o               => tdc2_start_dis_o,
     stop_dis_o                => tdc2_stop_dis_o,
     data_bus_io               => tdc2_data_bus_io,
     address_o                 => tdc2_address_o,
     cs_n_o                    => tdc2_cs_n_o,
     oe_n_o                    => tdc2_oe_n_o,
     rd_n_o                    => tdc2_rd_n_o,
     wr_n_o                    => tdc2_wr_n_o,
     ef1_i                     => tdc2_ef1_i,
     ef2_i                     => tdc2_ef2_i,
     -- Input channels enable
     enable_inputs_o           => tdc2_enable_inputs_o,
     term_en_1_o               => tdc2_term_en_1_o,
     term_en_2_o               => tdc2_term_en_2_o,
     term_en_3_o               => tdc2_term_en_3_o,
     term_en_4_o               => tdc2_term_en_4_o,
     term_en_5_o               => tdc2_term_en_5_o,
     -- Input channels to FPGA (not used)
     tdc_in_fpga_1_i           => tdc2_in_fpga_1_i,
     tdc_in_fpga_2_i           => tdc2_in_fpga_2_i,
     tdc_in_fpga_3_i           => tdc2_in_fpga_3_i,
     tdc_in_fpga_4_i           => tdc2_in_fpga_4_i,
     tdc_in_fpga_5_i           => tdc2_in_fpga_5_i,
     -- LEDs and buttons on TDC and SPEC
     tdc_led_status_o          => tdc2_led_status_o,
     tdc_led_trig1_o           => tdc2_led_trig1_o,
     tdc_led_trig2_o           => tdc2_led_trig2_o,
     tdc_led_trig3_o           => tdc2_led_trig3_o,
     tdc_led_trig4_o           => tdc2_led_trig4_o,
     tdc_led_trig5_o           => tdc2_led_trig5_o,
     -- WISHBONE interface with the GNUM/VME_core
     wb_tdc_csr_adr_i          => tdc2_slave_in.adr,
     wb_tdc_csr_dat_i          => tdc2_slave_in.dat,
     wb_tdc_csr_dat_o          => tdc2_slave_out.dat,
     wb_tdc_csr_cyc_i          => tdc2_slave_in.cyc,
     wb_tdc_csr_sel_i          => tdc2_slave_in.sel,
     wb_tdc_csr_stb_i          => tdc2_slave_in.stb,
     wb_tdc_csr_we_i           => tdc2_slave_in.we,
     wb_tdc_csr_ack_o          => tdc2_slave_out.ack,
     wb_tdc_csr_stall_o        => tdc2_slave_out.stall,
     -- White Rabbit
     wrabbit_link_up_i         => tm_link_up,
     wrabbit_time_valid_i      => tm_time_valid,
     wrabbit_cycles_i          => tm_cycles,
     wrabbit_utc_i             => tm_utc(31 downto 0),
     wrabbit_clk_aux_lock_en_o => tm_clk_aux_lock_en(1),
     wrabbit_clk_aux_locked_i  => tm_clk_aux_locked(1),
     wrabbit_clk_dmtd_locked_i => '1', -- FIXME: fan out real signal from the WRCore
     wrabbit_dac_value_i       => tm_dac_value,   -- only for debug
     wrabbit_dac_wr_p_i        => tm_dac_wr_p(1), -- only for debug
     -- Interrupts
     wb_irq_o                  => tdc2_irq,
    -- EEPROM I2C on TDC mezzanine
     i2c_scl_oen_o             => tdc2_scl_oen,
     i2c_scl_i                 => tdc2_scl_in,
     i2c_sda_oen_o             => tdc2_sda_oen,
     i2c_sda_i                 => tdc2_sda_in,
     i2c_scl_o                 => tdc2_scl_out,
     i2c_sda_o                 => tdc2_sda_out,
     -- 1-wire UniqueID&Thermometer interface
     onewire_b                 => tdc2_onewire_b);
  -- --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused WISHBONE signals
  tdc1_slave_out.err <= '0';
  tdc1_slave_out.rty <= '0';
  tdc1_slave_out.int <= '0';


---------------------------------------------------------------------------------------------------
--                    TDC#2 domains crossing: tdc2_125m_clk <-> clk_62m5_sys                     --
---------------------------------------------------------------------------------------------------
  cmp_tdc2_clks_crossing : xwb_clock_crossing
  port map
    (slave_clk_i    => clk_62m5_sys,  -- Slave control port: VME interface at 62.5 MHz
     slave_rst_n_i  => rst_n_sys,
     slave_i        => cnx_master_out(c_SLAVE_TDC1),
     slave_o        => cnx_master_in(c_SLAVE_TDC1),
     master_clk_i   => tdc2_125m_clk, -- Master reader port: TDC core at 125 MHz
     master_rst_n_i => tdc2_general_rst_n,
     master_i       => tdc2_slave_out,
     master_o       => tdc2_slave_in);


---------------------------------------------------------------------------------------------------
--                                 VECTOR INTERRUPTS CONTROLLER                                  --
---------------------------------------------------------------------------------------------------

  cmp_irq_vic : xwb_vic
  generic map
    (g_interface_mode      => PIPELINED,
     g_address_granularity => BYTE,
     g_num_interrupts      => 2,
     g_init_vectors        => c_VIC_VECTOR_TABLE)
  port map
    (clk_sys_i             => clk_62m5_sys,
     rst_n_i               => rst_n_sys,
     slave_i               => cnx_master_out(c_SLAVE_VIC),
     slave_o               => cnx_master_in(c_SLAVE_VIC),
     irqs_i(0)             => tdc1_irq_synch(1),
     irqs_i(1)             => tdc2_irq_synch(1),
     irq_master_o          => irq_to_vmecore);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- since the TDC cores work in their PLL clock domains (tdc1_125m_clk and tdc2_125m_clk)
  -- and the rest works with the system clock (clk_62m5_sys) interrupt pulses need to be
  -- synchronized
  irq_pulse_synchronizer: process (clk_62m5_sys)
  begin
    if rising_edge (clk_62m5_sys) then
      if rst_n_sys = '0' then
        tdc1_irq_synch <= (others => '0');
        tdc2_irq_synch <= (others => '0');
      else
        tdc1_irq_synch <= tdc1_irq_synch(0) & tdc1_irq;
        tdc2_irq_synch <= tdc2_irq_synch(0) & tdc2_irq;
      end if;
    end if;
  end process;


---------------------------------------------------------------------------------------------------
--                                    Carrier CSR information                                    --
---------------------------------------------------------------------------------------------------
-- Information on carrier type, mezzanine presence, pcb version
-- Also added software resets for the clks_rsts_manager units
  cmp_carrier_info : carrier_info
  port map
    (rst_n_i                           => rst_n_sys,
     clk_sys_i                         => clk_62m5_sys,
     wb_adr_i                          => cnx_master_out(c_SLAVE_SVEC_INFO).adr(3 downto 2),
     wb_dat_i                          => cnx_master_out(c_SLAVE_SVEC_INFO).dat,
     wb_dat_o                          => cnx_master_in(c_SLAVE_SVEC_INFO).dat,
     wb_cyc_i                          => cnx_master_out(c_SLAVE_SVEC_INFO).cyc,
     wb_sel_i                          => cnx_master_out(c_SLAVE_SVEC_INFO).sel,
     wb_stb_i                          => cnx_master_out(c_SLAVE_SVEC_INFO).stb,
     wb_we_i                           => cnx_master_out(c_SLAVE_SVEC_INFO).we,
     wb_ack_o                          => cnx_master_in(c_SLAVE_SVEC_INFO).ack,
     wb_stall_o                        => cnx_master_in(c_SLAVE_SVEC_INFO).stall,
     carrier_info_carrier_pcb_rev_i    => pcb_ver_i,
     carrier_info_carrier_reserved_i   => (others => '0'),
     carrier_info_carrier_type_i       => c_CARRIER_TYPE,
     carrier_info_stat_fmc_pres_i      => '0', -- put tdc1_prsnt_m2c_n_i
     carrier_info_stat_p2l_pll_lck_i   => '0',
     carrier_info_stat_sys_pll_lck_i   => sys_locked,
     carrier_info_stat_ddr3_cal_done_i => '0',
     carrier_info_stat_reserved_i      => (others => '0'),
     carrier_info_ctrl_led_green_o     => open,
     carrier_info_ctrl_led_red_o       => open,
     carrier_info_ctrl_dac_clr_n_o     => open,
     carrier_info_ctrl_reserved_o      => open,
     carrier_info_rst_fmc0_n_o         => open,
     carrier_info_rst_fmc0_n_i         => '1',
     carrier_info_rst_fmc0_n_load_o    => open,
     carrier_info_rst_reserved_o       => carrier_info_fmc_rst);  -- TDC mezzanine cores reset

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused wishbone signals
  cnx_master_in(c_SLAVE_SVEC_INFO).err   <= '0';
  cnx_master_in(c_SLAVE_SVEC_INFO).rty   <= '0';
  cnx_master_in(c_SLAVE_SVEC_INFO).int   <= '0';


---------------------------------------------------------------------------------------------------
--                                     LEDs SVEC front panel                                     --
---------------------------------------------------------------------------------------------------
  cmp_LED_ctrler : bicolor_led_ctrl
  generic map
    (g_NB_COLUMN     => 4,
     g_NB_LINE       => 2,
     g_CLK_FREQ      => 62500000,  -- in Hz
     g_REFRESH_RATE  => 250)       -- in Hz
  port map
    (rst_n_i         => rst_n_sys,
     clk_i           => clk_62m5_sys,
     led_intensity_i => "1100100", -- in %
     led_state_i     => led_state,
     column_o        => fp_led_column_o,
     line_o          => fp_led_line_o,
     line_oen_o      => fp_led_line_oen_o);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- led_state bits : 15                              0
  --                   ---------------------------------
  -- fp led number  :  | 5 | 6 | 7 | 8 | 1 | 2 | 3 | 4 |

  -- LED 1: White Rabbit act
  led_state(7  downto  6) <= c_LED_RED   when wrabbit_led_red      = '1' else c_LED_OFF;
  -- LED 2: White Rabbit link
  led_state(5  downto  4) <= c_LED_GREEN when wrabbit_led_green    = '1' else c_LED_OFF;
  -- LED 3: TDC1 empty flag
  led_state(3  downto  2) <= c_LED_GREEN when led_tdc1_ef          = '1' else c_LED_OFF;
  -- LED 4: TDC2 empty flag
  led_state(1  downto  0) <= c_LED_GREEN when led_tdc2_ef          = '1' else c_LED_OFF;
  -- LED 5: VME access
  led_state(15 downto 14) <= c_LED_GREEN when led_vme_access       = '1' else c_LED_OFF;
  -- LED 6: blinking using clk_62m5_sys
  led_state(13 downto 12) <= c_LED_GREEN when led_clk_62m5         = '1' else c_LED_OFF;
  -- LED 7: TDC1 locked to White Rabbit
  led_state(11 downto 10) <= c_LED_GREEN when tm_clk_aux_locked(0) = '1' else c_LED_OFF;
  -- LED 8: TDC2 locked to White Rabbit
  led_state(9  downto  8) <= c_LED_GREEN when tm_clk_aux_locked(1) = '1' else c_LED_OFF;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_drive_VME_access_LED: gc_extend_pulse
  generic map
    (g_width    => 5000000)
  port map
    (clk_i      => clk_62m5_sys,
     rst_n_i    => rst_n_sys,
     pulse_i    => cnx_slave_in(c_MASTER_VME).cyc,
     extended_o => led_vme_access);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_drive_TDC1_EF_LED: gc_extend_pulse
  generic map
    (g_width    => 5000000)
  port map
    (clk_i      => clk_62m5_sys,
     rst_n_i    => rst_n_sys,
     pulse_i    => tdc1_ef,
     extended_o => led_tdc1_ef);
  --  --  --  --  --  --  --
  tdc1_ef <= not(tdc1_ef1_i) or not(tdc1_ef2_i);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_drive_TDC2_EF_LED: gc_extend_pulse
  generic map
    (g_width    => 5000000)
  port map
    (clk_i      => clk_62m5_sys,
     rst_n_i    => rst_n_sys,
     pulse_i    => tdc2_ef,
     extended_o => led_tdc2_ef);
  --  --  --  --  --  --  --
  tdc2_ef <= not(tdc2_ef1_i) or not(tdc2_ef2_i);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  clk_62m5_sys_drive_led : process (clk_62m5_sys)
  begin
    if rising_edge(clk_62m5_sys) then

      if(rst_n_sys = '0') then
        led_clk_62m5_aux     <= "01111111";
        led_clk_62m5_divider <= (others => '0');
      else
        led_clk_62m5_divider <= led_clk_62m5_divider+ 1;
        if(led_clk_62m5_divider = 0) then
          led_clk_62m5_aux   <= led_clk_62m5_aux(6 downto 0) & led_clk_62m5_aux(7);
        end if;
      end if;
    end if;
  end process;
  --  --  --  --  --
led_clk_62m5 <= led_clk_62m5_aux(0);


end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------