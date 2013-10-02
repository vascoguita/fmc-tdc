--_________________________________________________________________________________________________
--                                                                                                |
--                                           |TDC core|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                            top_tdc                                             |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         top_tdc.vhd                                                                       |
--                                                                                                |
-- Description  TDC top level for SVEC. Figure 1 shows the architecture of this unit.             |
--                o Two TDC mezzanine cores are instanciated, for the boards on FMC1 and FMC2     |
--                o The IRQ controller is managing the interrupts coming from both TDC cores      |
--                o The carrier_csr module provides general information on the SVEC PCB version,  |
--                  PLLs locking state etc                                                        |
--                o The 1-Wire core provides communication with the SVEC Thermometer&UniqueID chip|
--              All these cores communicate with the VME core through the SDB crossbar. The SDB   |
--              crossbar is responsible for managing the acess to the VME core.                   |
--                                                                                                |
--              The speed for the VME core is 62.5MHz. The TDC mezzanine cores however operate at |
--              125MHz. The crossing from the 62.5MHz world to the 125MHz world takes place       | 
--              through dedicated clock_crossing cores.                                           |
--                                                                                                |
--              The 62.5MHz clock comes from an internal Xilinx FPGA PLL, using the 20MHz VCXO of |
--              the SVEC board.                                                                   |
--                                                                                                |
--              The 125MHz clock for each TDC mezzanine comes from the PLL located on it.         |
--              A clks_rsts_manager unit is responsible for automatically configuring the PLL upon|
--              the FPGA startup, using the 20MHz VCXO on the SVEC board. The clks_rsts_manager is|
--              keeping the TDC mezzanine core under reset until the respective PLL gets locked.  |
--                                                                                                |
--              Upon powering up of the FPGA as well as after a VME reset, the whole logic gets   |
--              reset (FMC1 125MHz, FMC2 125MHz and 62.5MHz). This also triggers a reprogramming  |
--              of the mezzanines' PLL through the clks_rsts_manager units.                       |
--              An extra software reset is implemented for the TDC mezzanine cores, using resevred|
--              bits of the carrier_csr core. Such a reset also triggers the reprogramming of the |
--              mezzanines' PLL.                                                                  |
--                                                                                                |
--                __________________________________________________________________              |
--               |       ____________________________        ___        _____       |             |
--               |      |   ____________   _______   |      |   |      |     |      |             |
--               |      |  |            | | clk   |  | \    |   |      |     |      |             |
--               |      |  | TDC mezz 1 | | cross |  |  \   |   |      |     |      |             |
--         FMC1  |      |  |____________| |_______|  |   \  |   |      |     |      |             |
--               |      |     ___________________    |    \ |   |      |     |      |             |
--               |      |    |_clks_rsts_manager_|   |      |   |      |     |      |             |
--               |      |____________________________|      |   |      |     |      |             |
--               |                        FMC1 125MHz       |   |      |     |      |             |
--               |       ____________________________       |   |      |     |      |             |
--               |      |   ____________   _______   |      |   |      |     |      |             |
--               |      |  |            | | clk   |  |      |   |      |     |      |             |
--               |      |  | TDC mezz 2 | | cross |  |      | S |      |  V  |      |             |
--         FMC2  |      |  |____________| |_______|  | ---- |   |      |     |      |             |
--               |      |     ___________________    |      |   |      |     |      |             |
--               |      |    |_clks_rsts_manager_|   |      |   |      |     |      |             |
--               |      |____________________________|      | D | <--> |  M  |      |             |
--               |                        FMC2 125MHz       |   |      |     |      |             |
--               |       ____________________________       |   |      |     |      |             |
--               |      |                            |      |   |      |     |      |             |
--               |      |      IRQ controller        | ---- | B |      |  E  |      |             |
--               |      |____________________________|      |   |      |     |      |             |
--               |                             62.5MHz      |   |      |     |      |             |
--               |       ____________________________       |   |      |     |      |             |
--               |      |                            |      |   |      |     |      |             |
-- SVEC 1W chip  |      |          1-Wire            | ---- |   |      |     |      |             |
--               |      |____________________________|      |   |      |     |      |             |
--               |                            62.5MHz     / |   |      |     |      |             |
--               |       ____________________________    /  |   |      |     |      |             |
--               |      |                            |  /   |   |      |     |      |             |
--               |      |        Carrier_CSR         | /    |   |      |     |      |             |
--               |      |____________________________|      |   |      |     |      |             |
--               |                                          |___|      |_____|      |             |
--               |                                         62.5MHZ     62.5MHz      |             |
--               |      ______________________________________________              |             |
--               |     |___________________LEDs_______________________|             |             |
--               |                                                                  |             |
--               |__________________________________________________________________|             |
--                                                                                                |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
--              Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
-- Date         08/2013                                                                           |
-- Version      v4                                                                                |
-- Depends on                                                                                     |
--                                                                                                |
----------------                                                                                  |
-- Last changes                                                                                   |
--     08/2013  v4  EG  design for SVEC; two cores; synchronizer between vme and the cores        |
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
use work.sdb_meta_pkg.all;
use work.bicolor_led_ctrl_pkg.all;
library UNISIM;
use UNISIM.vcomponents.all;


--=================================================================================================
--                                   Entity declaration for top_tdc
--=================================================================================================
entity top_tdc is
  generic
    (g_span                  : integer := 32;      -- address span in bus interfaces
     g_width                 : integer := 32;      -- data width in bus interfaces
     values_for_simul        : boolean := false);  -- this generic is set to TRUE
                                                   -- when instantiated in a test-bench
  port
    (-- Carrier PoR
      por_n_i                : in    std_logic;
     -- Carrier 20MHz VCXO
      clk_20m_vcxo_i         : in    std_logic;
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
      tdc1_one_wire_b        : inout std_logic;
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
      tdc2_one_wire_b        : inout std_logic;
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
      tdc2_in_fpga_5_i       : in    std_logic;

     -- Carrier other signals
      -- SVEC 1-wire UniqueID & Thermometer
      carrier_one_wire_b     : inout std_logic;
      -- SVEC PCB version
      pcb_ver_i              : in    std_logic_vector(3 downto 0);
      -- Mezzanines presence
      tdc1_prsntm2c_n_i      : in std_logic;
      tdc2_prsntm2c_n_i      : in std_logic;
      -- SVEC Front panel LEDs
      fp_led_line_oen_o      : out std_logic_vector(1 downto 0);
      fp_led_line_o          : out std_logic_vector(1 downto 0);
      fp_led_column_o        : out std_logic_vector(3 downto 0));
end top_tdc;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of top_tdc is

---------------------------------------------------------------------------------------------------
--                                           CONSTANTS                                           --
---------------------------------------------------------------------------------------------------
  -- Constant regarding the Carrier type
  constant c_CARRIER_TYPE   : std_logic_vector(15 downto 0) := x"0002";
    --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Constants regarding the SDB crossbar
  constant c_NUM_WB_SLAVES  : integer := 1;
  constant c_NUM_WB_MASTERS : integer := 5;
  constant c_MASTER_VME     : integer := 0;
    --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  
  constant c_SLAVE_SVEC_1W   : integer := 0;  -- SVEC 1wire interface
  constant c_SLAVE_SVEC_INFO : integer := 1;  -- SVEC control and status registers
  constant c_SLAVE_IRQ       : integer := 2;  -- Interrupt controller
  constant c_SLAVE_TDC0      : integer := 3;  -- TIMETAG core for time-tagging
  constant c_SLAVE_TDC1      : integer := 4;  -- TIMETAG core for time-tagging

  constant c_SDB_ADDRESS         : t_wishbone_address := x"00000000";
  constant c_FMC_TDC0_SDB_BRIDGE : t_sdb_bridge       := f_xwb_bridge_manual_sdb(x"0001FFFF", x"00000000");
  constant c_FMC_TDC1_SDB_BRIDGE : t_sdb_bridge       := f_xwb_bridge_manual_sdb(x"0001FFFF", x"00000000");

  constant c_INTERCONNECT_LAYOUT : t_sdb_record_array(7 downto 0) :=
    (0 => f_sdb_embed_device     (c_ONEWIRE_SDB_DEVICE,  x"00010000"),
     1 => f_sdb_embed_device     (c_SPEC_CSR_SDB_DEVICE, x"00020000"),
     2 => f_sdb_embed_device     (c_INT_SDB_DEVICE,      x"00030000"),
     3 => f_sdb_embed_bridge     (c_FMC_TDC0_SDB_BRIDGE, x"00040000"),
     4 => f_sdb_embed_bridge     (c_FMC_TDC1_SDB_BRIDGE, x"00060000"),
     5 => f_sdb_embed_repo_url   (c_SDB_REPO_URL),
     6 => f_sdb_embed_synthesis  (c_SDB_SYNTHESIS),
     7 => f_sdb_embed_integration(c_SDB_INTEGRATION));


---------------------------------------------------------------------------------------------------
--                                            Signals                                            --
---------------------------------------------------------------------------------------------------

 -- Clocks
  -- CLOCK DOMAIN: 20 MHz VCXO clock on SVEC carrier board: clk_20m_vcxo_i
  signal clk_20m_vcxo_buf, clk_20m_vcxo       : std_logic;
  -- CLOCK DOMAIN: 62.5 MHz system clock derived from clk_20m_vcxo_i by a Xilinx PLL: clk_62m5_sys
  signal clk_62m5_sys, pllout_clk_sys         : std_logic;
  signal pllout_clk_sys_fb, sys_locked        : std_logic;
  -- CLOCK DOMAIN: 125 MHz clock from PLL on TDC1: tdc1_clk_125m
  signal tdc1_clk_125m                        : std_logic;
  signal tdc1_acam_refclk_r_edge_p            : std_logic;
  signal tdc1_send_dac_word_p                 : std_logic;
  signal tdc1_dac_word                        : std_logic_vector(23 downto 0);
  signal tdc1_slave_in                        : t_wishbone_slave_in;
  signal tdc1_slave_out                       : t_wishbone_slave_out;
  signal tdc1_irq_acam_err_p                  : std_logic;
  signal tdc1_irq_tstamp_p, tdc1_irq_time_p   : std_logic;
  -- CLOCK DOMAIN: 125 MHz clock from PLL on TDC2: tdc2_clk_125m
  signal tdc2_clk_125m                        : std_logic;
  signal tdc2_acam_refclk_r_edge_p            : std_logic;
  signal tdc2_send_dac_word_p                 : std_logic;
  signal tdc2_dac_word                        : std_logic_vector(23 downto 0);
  signal tdc2_slave_in                        : t_wishbone_slave_in;
  signal tdc2_slave_out                       : t_wishbone_slave_out;
  signal tdc2_irq_acam_err_p                  : std_logic;
  signal tdc2_irq_tstamp_p, tdc2_irq_time_p   : std_logic;

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
  signal carrier_csr_reserved_out             : std_logic_vector(28 downto 0);
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
  signal irq_sources                          : std_logic_vector(31 downto 0);
  signal tdc1_irq_tstamps, tdc2_irq_tstamps   : std_logic;

---------------------------------------------------------------------------------------------------
 -- Carrier other signals
  signal mezz_pll_status                      : std_logic_vector(11 downto 0);
  signal carrier_owr_en, carrier_owr_i        : std_logic_vector(c_FMC_ONE_WIRE_NB - 1 downto 0);
  -- LEDs
  signal led_state                            : std_logic_vector(15 downto 0);
  signal tdc1_ef, tdc2_ef, led_tdc1_ef        : std_logic;
  signal led_tdc2_ef, led_tdc2_pll_status     : std_logic;
  signal led_tdc1_pll_status, led_vme_access  : std_logic;
  signal led_clk_62m5_divider                 : unsigned(22 downto 0);
  signal led_clk_62m5_aux                     : std_logic_vector(7 downto 0);
  signal led_clk_62m5                         : std_logic;


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

---------------------------------------------------------------------------------------------------
--                                         Power On Reset                                        --
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
     CLKFBOUT_MULT      => 50,         -- 20 MHz x 50 = 1 GHz
     CLKFBOUT_PHASE     => 0.000,
     CLKOUT0_DIVIDE     => 16,         -- 62.5 MHz
     CLKOUT0_PHASE      => 0.000,
     CLKOUT0_DUTY_CYCLE => 0.500,
     CLKOUT1_DIVIDE     => 16,         -- 125 MHz, not used
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
--                                          TDC1 125MHz                                          --
---------------------------------------------------------------------------------------------------
  cmp_tdc1_clks_rsts_mgment : clks_rsts_manager
  generic map
    (nb_of_reg                 => 68)
  port map
    (clk_20m_vcxo_i            => clk_20m_vcxo_buf,
     acam_refclk_p_i           => tdc1_acam_refclk_p_i,
     acam_refclk_n_i           => tdc1_acam_refclk_n_i,
     tdc_125m_clk_p_i          => tdc1_125m_clk_p_i,
     tdc_125m_clk_n_i          => tdc1_125m_clk_n_i,
     rst_n_i                   => tdc1_soft_rst_n, -- just use the system-wide reset to boostrap PLLs
     pll_sdo_i                 => tdc1_pll_sdo_i,
     pll_status_i              => tdc1_pll_status_i,
     send_dac_word_p_i         => tdc1_send_dac_word_p,
     dac_word_i                => tdc1_dac_word,
     acam_refclk_r_edge_p_o    => tdc1_acam_refclk_r_edge_p,
     internal_rst_o            => tdc1_general_rst,
     pll_cs_n_o                => tdc1_pll_cs_n_o,
     pll_dac_sync_n_o          => tdc1_pll_dac_sync_n_o,
     pll_sdi_o                 => tdc1_pll_sdi_o,
     pll_sclk_o                => tdc1_pll_sclk_o,
     tdc_125m_clk_o            => tdc1_clk_125m,
     pll_status_o              => open);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  tdc1_general_rst_n          <= not tdc1_general_rst;
  tdc1_soft_rst_n             <= carrier_csr_reserved_out(0) and rst_n_sys;


---------------------------------------------------------------------------------------------------
--                      TDC1 domains crossing: tdc1_clk_125m <-> clk_62m5_sys                    --
---------------------------------------------------------------------------------------------------
  cmp_clks_crossing_ft0 : xwb_clock_crossing
  port map
    (slave_clk_i    => clk_62m5_sys,  -- Slave control port: VME interface at 62.5 MHz 
     slave_rst_n_i  => rst_n_sys,
     slave_i        => cnx_master_out(c_SLAVE_TDC0),
     slave_o        => cnx_master_in(c_SLAVE_TDC0),
     master_clk_i   => tdc1_clk_125m, -- Master reader port: TDC core at 125 MHz
     master_rst_n_i => tdc1_general_rst_n,
     master_i       => tdc1_slave_out,
     master_o       => tdc1_slave_in);


---------------------------------------------------------------------------------------------------
--                                          TDC2 125MHz                                          --
---------------------------------------------------------------------------------------------------
  cmp_tdc2_clks_rsts_mgment : clks_rsts_manager
  generic map
    (nb_of_reg                 => 68)
  port map
    (clk_20m_vcxo_i            => clk_20m_vcxo_buf,
     acam_refclk_p_i           => tdc2_acam_refclk_p_i,
     acam_refclk_n_i           => tdc2_acam_refclk_n_i,
     tdc_125m_clk_p_i          => tdc2_125m_clk_p_i,
     tdc_125m_clk_n_i          => tdc2_125m_clk_n_i,
     rst_n_i                   => tdc2_soft_rst_n,
     pll_sdo_i                 => tdc2_pll_sdo_i,
     pll_status_i              => tdc2_pll_status_i,
     send_dac_word_p_i         => tdc2_send_dac_word_p,
     dac_word_i                => tdc2_dac_word,
     acam_refclk_r_edge_p_o    => tdc2_acam_refclk_r_edge_p,
     internal_rst_o            => tdc2_general_rst,
     pll_cs_n_o                => tdc2_pll_cs_n_o,
     pll_dac_sync_n_o          => tdc2_pll_dac_sync_n_o,
     pll_sdi_o                 => tdc2_pll_sdi_o,
     pll_sclk_o                => tdc2_pll_sclk_o,
     tdc_125m_clk_o            => tdc2_clk_125m,
     pll_status_o              => open);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  tdc2_general_rst_n           <= not tdc2_general_rst;
  tdc2_soft_rst_n              <= carrier_csr_reserved_out(1) and rst_n_sys;


---------------------------------------------------------------------------------------------------
--                     TDC2 domains crossing: tdc2_clk_125m <-> clk_62m5_sys                     --
---------------------------------------------------------------------------------------------------
  cmp_clks_crossing_ft1 : xwb_clock_crossing
  port map
    (slave_clk_i    => clk_62m5_sys,  -- Slave control port: VME interface at 62.5 MHz 
     slave_rst_n_i  => rst_n_sys,
     slave_i        => cnx_master_out(c_SLAVE_TDC1),
     slave_o        => cnx_master_in(c_SLAVE_TDC1),
     master_clk_i   => tdc2_clk_125m, -- Master reader port: TDC core at 125 MHz
     master_rst_n_i => tdc2_general_rst_n,
     master_i       => tdc2_slave_out,
     master_o       => tdc2_slave_in);


---------------------------------------------------------------------------------------------------
--                                     CSR WISHBONE CROSSBAR                                     --
---------------------------------------------------------------------------------------------------
-- WISHBONE crossbar
--  0x10000 -> SVEC carrier UnidueID&Thermometer 1-wire
--  0x20000 -> SVEC CSR information
--  0x30000 -> Interrupts
--  0x40000 -> TDC board on FMC1
--  0x60000 -> TDC board on FMC2

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
  port map (
      clk_i           => clk_62m5_sys,
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
  VME_DATA_b          <= VME_DATA_b_out    when VME_DATA_DIR_int = '1' else (others => 'Z');
  VME_ADDR_b          <= VME_ADDR_b_out    when VME_ADDR_DIR_int = '1' else (others => 'Z');
  VME_LWORD_n_b       <= VME_LWORD_n_b_out when VME_ADDR_DIR_int = '1' else 'Z';
  VME_ADDR_DIR_o      <= VME_ADDR_DIR_int;
  VME_DATA_DIR_o      <= VME_DATA_DIR_int;


---------------------------------------------------------------------------------------------------
--                                            TDC BOARD 1                                        --
---------------------------------------------------------------------------------------------------

  cmp_tdc_board1 : fmc_tdc_mezzanine
  generic map
    (g_span                 => g_span,
     g_width                => g_width,
     values_for_simul       => values_for_simul)
  port map
    (-- clocks, resets, dac
      clk_125m_i             => tdc1_clk_125m,
      rst_i                  => tdc1_general_rst,
      acam_refclk_r_edge_p_i => tdc1_acam_refclk_r_edge_p,
      send_dac_word_p_o      => tdc1_send_dac_word_p,
      dac_word_o             => tdc1_dac_word,
      -- ACAM
      start_from_fpga_o      => tdc1_start_from_fpga_o,
      err_flag_i             => tdc1_err_flag_i,
      int_flag_i             => tdc1_int_flag_i,
      start_dis_o            => tdc1_start_dis_o,
      stop_dis_o             => tdc1_stop_dis_o,
      data_bus_io            => tdc1_data_bus_io,
      address_o              => tdc1_address_o,
      cs_n_o                 => tdc1_cs_n_o,
      oe_n_o                 => tdc1_oe_n_o,
      rd_n_o                 => tdc1_rd_n_o,
      wr_n_o                 => tdc1_wr_n_o,
      ef1_i                  => tdc1_ef1_i,
      ef2_i                  => tdc1_ef2_i,
      -- Input channels enable
      enable_inputs_o        => tdc1_enable_inputs_o,
      term_en_1_o            => tdc1_term_en_1_o,
      term_en_2_o            => tdc1_term_en_2_o,
      term_en_3_o            => tdc1_term_en_3_o,
      term_en_4_o            => tdc1_term_en_4_o,
      term_en_5_o            => tdc1_term_en_5_o,
      -- Input channels to FPGA (not used)
      tdc_in_fpga_1_i        => tdc1_in_fpga_1_i,
      tdc_in_fpga_2_i        => tdc1_in_fpga_2_i,
      tdc_in_fpga_3_i        => tdc1_in_fpga_3_i,
      tdc_in_fpga_4_i        => tdc1_in_fpga_4_i,
      tdc_in_fpga_5_i        => tdc1_in_fpga_5_i,
      -- LEDs and buttons on TDC and SPEC
      tdc_led_status_o       => tdc1_led_status_o,
      tdc_led_trig1_o        => tdc1_led_trig1_o,
      tdc_led_trig2_o        => tdc1_led_trig2_o,
      tdc_led_trig3_o        => tdc1_led_trig3_o,
      tdc_led_trig4_o        => tdc1_led_trig4_o,
      tdc_led_trig5_o        => tdc1_led_trig5_o,
      -- Interrupts
      irq_tstamp_p_o         => tdc1_irq_tstamp_p,
      irq_time_p_o           => tdc1_irq_time_p,
      irq_acam_err_p_o       => tdc1_irq_acam_err_p,
      -- WISHBONE interface with the GNUM/VME_core
      wb_tdc_mezz_adr_i      => tdc1_slave_in.adr,
      wb_tdc_mezz_dat_i      => tdc1_slave_in.dat,
      wb_tdc_mezz_dat_o      => tdc1_slave_out.dat,
      wb_tdc_mezz_cyc_i      => tdc1_slave_in.cyc,
      wb_tdc_mezz_sel_i      => tdc1_slave_in.sel,
      wb_tdc_mezz_stb_i      => tdc1_slave_in.stb,
      wb_tdc_mezz_we_i       => tdc1_slave_in.we,
      wb_tdc_mezz_ack_o      => tdc1_slave_out.ack,
      wb_tdc_mezz_stall_o    => tdc1_slave_out.stall,
      -- TDC board EEPROM I2C EEPROM interface
      sys_scl_b              => tdc1_scl_b,
      sys_sda_b              => tdc1_sda_b,
      -- 1-wire UniqueID&Thermometer interface
      mezz_one_wire_b        => tdc1_one_wire_b);


---------------------------------------------------------------------------------------------------
--                                            TDC BOARD 2                                        --
---------------------------------------------------------------------------------------------------
  cmp_tdc_board2 : fmc_tdc_mezzanine
  generic map
    (g_span                 => g_span,
     g_width                => g_width,
     values_for_simul       => values_for_simul)
  port map
    (-- clocks, resets, dac
      clk_125m_i             => tdc2_clk_125m,
      rst_i                  => tdc2_general_rst,
      acam_refclk_r_edge_p_i => tdc2_acam_refclk_r_edge_p,
      send_dac_word_p_o      => tdc2_send_dac_word_p,
      dac_word_o             => tdc2_dac_word,
      -- ACAM
      start_from_fpga_o      => tdc2_start_from_fpga_o,
      err_flag_i             => tdc2_err_flag_i,
      int_flag_i             => tdc2_int_flag_i,
      start_dis_o            => tdc2_start_dis_o,
      stop_dis_o             => tdc2_stop_dis_o,
      data_bus_io            => tdc2_data_bus_io,
      address_o              => tdc2_address_o,
      cs_n_o                 => tdc2_cs_n_o,
      oe_n_o                 => tdc2_oe_n_o,
      rd_n_o                 => tdc2_rd_n_o,
      wr_n_o                 => tdc2_wr_n_o,
      ef1_i                  => tdc2_ef1_i,
      ef2_i                  => tdc2_ef2_i,
      -- Input channels enable
      enable_inputs_o        => tdc2_enable_inputs_o,
      term_en_1_o            => tdc2_term_en_1_o,
      term_en_2_o            => tdc2_term_en_2_o,
      term_en_3_o            => tdc2_term_en_3_o,
      term_en_4_o            => tdc2_term_en_4_o,
      term_en_5_o            => tdc2_term_en_5_o,
      -- Input channels to FPGA (not used)
      tdc_in_fpga_1_i        => tdc2_in_fpga_1_i,
      tdc_in_fpga_2_i        => tdc2_in_fpga_2_i,
      tdc_in_fpga_3_i        => tdc2_in_fpga_3_i,
      tdc_in_fpga_4_i        => tdc2_in_fpga_4_i,
      tdc_in_fpga_5_i        => tdc2_in_fpga_5_i,
      -- LEDs and buttons on TDC and SPEC
      tdc_led_status_o       => tdc2_led_status_o,
      tdc_led_trig1_o        => tdc2_led_trig1_o,
      tdc_led_trig2_o        => tdc2_led_trig2_o,
      tdc_led_trig3_o        => tdc2_led_trig3_o,
      tdc_led_trig4_o        => tdc2_led_trig4_o,
      tdc_led_trig5_o        => tdc2_led_trig5_o,
      -- Interrupts
      irq_tstamp_p_o         => tdc2_irq_tstamp_p,
      irq_time_p_o           => tdc2_irq_time_p,
      irq_acam_err_p_o       => tdc2_irq_acam_err_p,
      -- WISHBONE interface with the GNUM/VME_core
      wb_tdc_mezz_adr_i      => tdc2_slave_in.adr,
      wb_tdc_mezz_dat_i      => tdc2_slave_in.dat,
      wb_tdc_mezz_dat_o      => tdc2_slave_out.dat,
      wb_tdc_mezz_cyc_i      => tdc2_slave_in.cyc,
      wb_tdc_mezz_sel_i      => tdc2_slave_in.sel,
      wb_tdc_mezz_stb_i      => tdc2_slave_in.stb,
      wb_tdc_mezz_we_i       => tdc2_slave_in.we,
      wb_tdc_mezz_ack_o      => tdc2_slave_out.ack,
      wb_tdc_mezz_stall_o    => tdc2_slave_out.stall,
      -- TDC board EEPROM I2C EEPROM interface
      sys_scl_b              => tdc2_scl_b,
      sys_sda_b              => tdc2_sda_b,
      -- 1-wire UniqueID&Thermometer interface
      mezz_one_wire_b        => tdc2_one_wire_b);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused WISHBONE signals
  tdc1_slave_out.err <= '0';
  tdc1_slave_out.rty <= '0';
  tdc1_slave_out.int <= '0';


---------------------------------------------------------------------------------------------------
--                                     INTERRUPTS CONTROLLER                                     --
---------------------------------------------------------------------------------------------------
-- IRQ sources
-- 0 -> number of timestamps reached threshold or number of seconds passed reached threshold (TDC1)
-- 1 -> ACAM error                                                                           (TDC1)
-- 2 -> number of timestamps reached threshold or number of seconds passed reached threshold (TDC2)
-- 3 -> ACAM error                                                                           (TDC2)
-- 4-31 -> unused

  cmp_irq_controller : irq_controller
  port map
    (clk_sys_i           => clk_62m5_sys,
     rst_n_i             => rst_n_sys,
     wb_adr_i            => cnx_master_out(c_SLAVE_IRQ).adr(3 downto 2),
     wb_dat_i            => cnx_master_out(c_SLAVE_IRQ).dat,
     wb_dat_o            => cnx_master_in(c_SLAVE_IRQ).dat,
     wb_cyc_i            => cnx_master_out(c_SLAVE_IRQ).cyc,
     wb_sel_i            => cnx_master_out(c_SLAVE_IRQ).sel,
     wb_stb_i            => cnx_master_out(c_SLAVE_IRQ).stb,
     wb_we_i             => cnx_master_out(c_SLAVE_IRQ).we,
     wb_ack_o            => cnx_master_in(c_SLAVE_IRQ).ack,
     wb_stall_o          => cnx_master_in(c_SLAVE_IRQ).stall,
     wb_int_o            => irq_to_vmecore,
     irq_tdc1_tstamps_i  => irq_sources(0),
     irq_tdc1_acam_err_i => irq_sources(1),
     irq_tdc2_tstamps_i  => irq_sources(2),
     irq_tdc2_acam_err_i => irq_sources(3));


  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused wishbone signals
  cnx_master_in(c_SLAVE_IRQ).err   <= '0';
  cnx_master_in(c_SLAVE_IRQ).rty   <= '0';
  cnx_master_in(c_SLAVE_IRQ).int   <= '0';

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- since the TDC cores work in their PLL clock domains (tdc1_clk_125m and tdc2_clk_125m)
  -- and the rest works with the system clock (clk_62m5_sys) we need to synchronize
  -- interrupt pulses.
  cmp_sync_irq0 : gc_pulse_synchronizer
  port map
    (clk_in_i  => tdc1_clk_125m,
     clk_out_i => clk_62m5_sys,
     rst_n_i   => rst_n_sys,
     d_p_i     => tdc1_irq_tstamps,
     q_p_o     => irq_sources(0));
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_sync_irq1 : gc_pulse_synchronizer
  port map
    (clk_in_i  => tdc1_clk_125m,
     clk_out_i => clk_62m5_sys,
     rst_n_i   => rst_n_sys,
     d_p_i     => tdc1_irq_acam_err_p,
     q_p_o     => irq_sources(1));
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_sync_irq2 : gc_pulse_synchronizer
  port map
    (clk_in_i  => tdc2_clk_125m,
     clk_out_i => clk_62m5_sys,
     rst_n_i   => rst_n_sys,
     d_p_i     => tdc2_irq_tstamps,
     q_p_o     => irq_sources(2));
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_sync_irq3 : gc_pulse_synchronizer
  port map
    (clk_in_i  => tdc2_clk_125m,
     clk_out_i => clk_62m5_sys,
     rst_n_i   => rst_n_sys,
     d_p_i     => tdc2_irq_acam_err_p,
     q_p_o     => irq_sources(3));
--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  tdc1_irq_tstamps         <= tdc1_irq_tstamp_p or tdc1_irq_time_p;
  tdc2_irq_tstamps         <= tdc2_irq_tstamp_p or tdc2_irq_time_p;
  irq_sources(31 downto 4) <= (others => '0');


---------------------------------------------------------------------------------------------------
--                    Carrier 1-wire MASTER DS18B20 (thermometer + unique ID)                    --
---------------------------------------------------------------------------------------------------

  cmp_carrier_onewire : xwb_onewire_master
  generic map
    (g_interface_mode      => PIPELINED,
     g_address_granularity => BYTE,
     g_num_ports           => 1,
     g_ow_btp_normal       => "5.0",
     g_ow_btp_overdrive    => "1.0")
  port map
    (clk_sys_i   => clk_62m5_sys,
     rst_n_i     => rst_n_sys,
     slave_i     => cnx_master_out(c_SLAVE_SVEC_1W),
     slave_o     => cnx_master_in(c_SLAVE_SVEC_1W),
     desc_o      => open,
     owr_pwren_o => open,
     owr_en_o    => carrier_owr_en,
     owr_i       => carrier_owr_i);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  carrier_one_wire_b <= '0' when carrier_owr_en(0) = '1' else 'Z';
  carrier_owr_i(0)   <= carrier_one_wire_b;


---------------------------------------------------------------------------------------------------
--                                    Carrier CSR information                                    --
---------------------------------------------------------------------------------------------------
-- Information on carrier type, mezzanine presence, pcb version
  cmp_carrier_csr : carrier_csr
  port map
    (rst_n_i                          => rst_n_sys,
     wb_clk_i                         => clk_62m5_sys,
     wb_addr_i                        => cnx_master_out(c_SLAVE_SVEC_INFO).adr(3 downto 2),
     wb_data_i                        => cnx_master_out(c_SLAVE_SVEC_INFO).dat,
     wb_data_o                        => cnx_master_in(c_SLAVE_SVEC_INFO).dat,
     wb_cyc_i                         => cnx_master_out(c_SLAVE_SVEC_INFO).cyc,
     wb_sel_i                         => cnx_master_out(c_SLAVE_SVEC_INFO).sel,
     wb_stb_i                         => cnx_master_out(c_SLAVE_SVEC_INFO).stb,
     wb_we_i                          => cnx_master_out(c_SLAVE_SVEC_INFO).we,
     wb_ack_o                         => cnx_master_in(c_SLAVE_SVEC_INFO).ack,
     carrier_csr_carrier_pcb_rev_i    => pcb_ver_i,
     carrier_csr_carrier_reserved_i   => mezz_pll_status,
     carrier_csr_carrier_type_i       => c_CARRIER_TYPE,
     carrier_csr_stat_fmc_pres_i      => '1',  -- don't care, the golden BS
                                               -- will do that for us
     carrier_csr_stat_p2l_pll_lck_i   => '0',
     carrier_csr_stat_sys_pll_lck_i   => '0',
     carrier_csr_stat_ddr3_cal_done_i => '0',
     carrier_csr_stat_reserved_i      => x"0C0FFEE",  -- for debugging
     carrier_csr_ctrl_led_green_o     => open,
     carrier_csr_ctrl_led_red_o       => open,
     carrier_csr_ctrl_dac_clr_n_o     => open,
     carrier_csr_ctrl_reserved_o      => carrier_csr_reserved_out); -- TDC mezzanine cores reset
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused wishbone signals
  cnx_master_in(c_SLAVE_SVEC_INFO).err   <= '0';
  cnx_master_in(c_SLAVE_SVEC_INFO).rty   <= '0';
  cnx_master_in(c_SLAVE_SVEC_INFO).stall <= '0';
  cnx_master_in(c_SLAVE_SVEC_INFO).int   <= '0';
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  mezz_pll_status <= (0 => tdc1_pll_status_i,
                      1 => tdc2_pll_status_i,
                      others => '0');


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

  -- LED 1: TDC1 PLL status
  led_state(7  downto  6) <= c_LED_RED when led_tdc1_pll_status = '1' else c_LED_OFF;
  -- LED 2: TDC2 PLL status
  led_state(5  downto  4) <= c_LED_RED when led_tdc2_pll_status = '1' else c_LED_OFF;
  -- LED 3: TDC1 empty flag
  led_state(3  downto  2) <= c_LED_GREEN when led_tdc1_ef       = '1' else c_LED_OFF;
  -- LED 4: TDC1 empty flag
  led_state(1  downto  0) <= c_LED_GREEN when led_tdc2_ef       = '1' else c_LED_OFF;
  -- LED 5: VME access
  led_state(15 downto 14) <= c_LED_GREEN when led_vme_access    = '1' else c_LED_OFF;
  -- LED 6: blinking using clk_62m5_sys
  led_state(13 downto 12) <= c_LED_GREEN when led_clk_62m5      = '1' else c_LED_OFF;
  -- LED 7: not used, permanently green
  led_state(11 downto 10) <= c_LED_GREEN;
  -- LED 8: not used, permanently red
  led_state(9  downto  8) <= c_LED_RED;

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
  cmp_drive_TDC1_PLL_stat_LED: gc_extend_pulse
  generic map
    (g_width    => 5000000)
  port map
    (clk_i      => clk_62m5_sys,
     rst_n_i    => rst_n_sys,
     pulse_i    => tdc2_pll_status_i,
     extended_o => led_tdc2_pll_status);
                    
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_drive_TDC2_PLL_stat_LED: gc_extend_pulse
  generic map
    (g_width    => 5000000)
  port map
    (clk_i      => clk_62m5_sys,
     rst_n_i    => rst_n_sys,
     pulse_i    => tdc1_pll_status_i,
     extended_o => led_tdc1_pll_status);

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