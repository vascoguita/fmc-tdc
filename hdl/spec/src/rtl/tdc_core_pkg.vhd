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

-- Standard library
library IEEE;
use IEEE.STD_LOGIC_1164.all; -- std_logic definitions
use IEEE.NUMERIC_STD.all;    -- conversion functions



--=================================================================================================
--                              Package declaration for tdc_core_pkg
--=================================================================================================
package tdc_core_pkg is

---------------------------------------------------------------------------------------------------
--                           Constants regarding 1 Hz pulse generation                           --
---------------------------------------------------------------------------------------------------

  -- for synthesis: 1 sec = x"07735940" clk_i cycles (1 clk_i cycle = 8ns)
  constant c_SYN_CLK_PERIOD : std_logic_vector(31 downto 0) := x"07735940";

  -- for simulation: 1 msec = x"0001E848" clk_i cycles (1 clk_i cycle = 8ns)
  constant c_SIM_CLK_PERIOD : std_logic_vector(31 downto 0) := x"0001E848";


---------------------------------------------------------------------------------------------------
--                     Constants regarding TDC core and GNUM core addressing                     --
---------------------------------------------------------------------------------------------------
  constant c_BAR0_APERTURE           : integer := 18;  -- nb of bits for 32-bit word address (= byte aperture - 2)
  constant c_CSR_WB_SLAVES_NB        : integer := 6;
  --------------------------------------------------
  constant c_CSR_WB_DMA_CONFIG       : integer := 0;
  constant c_CSR_WB_TDC_CORE         : integer := 1;
  constant c_CSR_WB_CARRIER_ONE_WIRE : integer := 2;
  constant c_CSR_WB_FMC_SYS_I2C      : integer := 3;
  constant c_CSR_WB_FMC_ONE_WIRE     : integer := 4;
  constant c_CSR_WB_IRQ_CTRL         : integer := 5;

  constant c_FMC_ONE_WIRE_NB         : integer := 1;

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
  constant c_ACAM_REG0_ADR  : std_logic_vector(7 downto 0) := x"00"; -- address 20000 of gnum BAR 0
  constant c_ACAM_REG1_ADR  : std_logic_vector(7 downto 0) := x"01"; -- address 20004 of gnum BAR 0
  constant c_ACAM_REG2_ADR  : std_logic_vector(7 downto 0) := x"02"; -- address 20008 of gnum BAR 0
  constant c_ACAM_REG3_ADR  : std_logic_vector(7 downto 0) := x"03"; -- address 2000C of gnum BAR 0
  constant c_ACAM_REG4_ADR  : std_logic_vector(7 downto 0) := x"04"; -- address 20010 of gnum BAR 0
  constant c_ACAM_REG5_ADR  : std_logic_vector(7 downto 0) := x"05"; -- address 20014 of gnum BAR 0
  constant c_ACAM_REG6_ADR  : std_logic_vector(7 downto 0) := x"06"; -- address 20018 of gnum BAR 0
  constant c_ACAM_REG7_ADR  : std_logic_vector(7 downto 0) := x"07"; -- address 2001C of gnum BAR 0
  constant c_ACAM_REG11_ADR : std_logic_vector(7 downto 0) := x"0B"; -- address 2002C of gnum BAR 0
  constant c_ACAM_REG12_ADR : std_logic_vector(7 downto 0) := x"0C"; -- address 20030 of gnum BAR 0
  constant c_ACAM_REG14_ADR : std_logic_vector(7 downto 0) := x"0E"; -- address 20038 of gnum BAR 0


---------------------------------------------------------------------------------------------------
-- Addresses of ACAM read-only registers, to be written by the ACAM and used within the core to access ACAM timestamps
  constant c_ACAM_REG8_ADR  : std_logic_vector(7 downto 0) := x"08"; -- not accessible for writing from PCI-e
  constant c_ACAM_REG9_ADR  : std_logic_vector(7 downto 0) := x"09"; -- not accessible for writing from PCI-e
  constant c_ACAM_REG10_ADR : std_logic_vector(7 downto 0) := x"0A"; -- not accessible for writing from PCI-e


---------------------------------------------------------------------------------------------------
-- Addresses of ACAM configuration readback registers, to be written by the ACAM 
                                                                          -- corresponds to:
  constant c_ACAM_REG0_RDBK_ADR  : std_logic_vector(7 downto 0) := x"10"; -- address 20040 of the gnum BAR 0
  constant c_ACAM_REG1_RDBK_ADR  : std_logic_vector(7 downto 0) := x"11"; -- address 20044 of the gnum BAR 0
  constant c_ACAM_REG2_RDBK_ADR  : std_logic_vector(7 downto 0) := x"12"; -- address 20048 of the gnum BAR 0
  constant c_ACAM_REG3_RDBK_ADR  : std_logic_vector(7 downto 0) := x"13"; -- address 2004C of the gnum BAR 0
  constant c_ACAM_REG4_RDBK_ADR  : std_logic_vector(7 downto 0) := x"14"; -- address 20050 of the gnum BAR 0
  constant c_ACAM_REG5_RDBK_ADR  : std_logic_vector(7 downto 0) := x"15"; -- address 20054 of the gnum BAR 0
  constant c_ACAM_REG6_RDBK_ADR  : std_logic_vector(7 downto 0) := x"16"; -- address 20058 of the gnum BAR 0
  constant c_ACAM_REG7_RDBK_ADR  : std_logic_vector(7 downto 0) := x"17"; -- address 2005C of the gnum BAR 0
  constant c_ACAM_REG8_RDBK_ADR  : std_logic_vector(7 downto 0) := x"18"; -- address 20060 of the gnum BAR 0
  constant c_ACAM_REG9_RDBK_ADR  : std_logic_vector(7 downto 0) := x"19"; -- address 20064 of the gnum BAR 0
  constant c_ACAM_REG10_RDBK_ADR : std_logic_vector(7 downto 0) := x"1A"; -- address 20068 of the gnum BAR 0
  constant c_ACAM_REG11_RDBK_ADR : std_logic_vector(7 downto 0) := x"1B"; -- address 2006C of the gnum BAR 0
  constant c_ACAM_REG12_RDBK_ADR : std_logic_vector(7 downto 0) := x"1C"; -- address 20070 of the gnum BAR 0
  constant c_ACAM_REG14_RDBK_ADR : std_logic_vector(7 downto 0) := x"1E"; -- address 20078 of the gnum BAR 0


---------------------------------------------------------------------------------------------------
--                    Constants regarding addressing of the TDC core registers                   --
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Addresses of TDC core Configuration registers to be written by the PCIe host
                                                                           -- corresponds to:
  constant c_STARTING_UTC_ADR     : std_logic_vector(7 downto 0) := x"20"; -- address 20080 of gnum BAR 0
  constant c_ACAM_INPUTS_EN_ADR   : std_logic_vector(7 downto 0) := x"21"; -- address 20084 of gnum BAR 0
  constant c_START_PHASE_ADR      : std_logic_vector(7 downto 0) := x"22"; -- address 20088 of gnum BAR 0
  constant c_ONE_HZ_PHASE_ADR     : std_logic_vector(7 downto 0) := x"23"; -- address 2008C of gnum BAR 0

  constant c_IRQ_TSTAMP_THRESHOLD : std_logic_vector(7 downto 0) := x"24"; -- address 20090 of gnum BAR 0
  constant c_IRQ_TIME_THRESHOLD   : std_logic_vector(7 downto 0) := x"25"; -- address 20090 of gnum BAR 0
--  constant c_RESERVED0          : std_logic_vector(7 downto 0) := x"26"; -- address 20098 of gnum BAR 0
--  constant c_RESERVED1          : std_logic_vector(7 downto 0) := x"27"; -- address 2009C of gnum BAR 0

---------------------------------------------------------------------------------------------------
-- Addresses of TDC core Status registers to be written by the different core units
                                                                           -- corresponds to:
  constant c_LOCAL_UTC_ADR        : std_logic_vector(7 downto 0) := x"28"; -- address 200A0 of gnum BAR 0
  constant c_IRQ_CODE_ADR         : std_logic_vector(7 downto 0) := x"29"; -- address 200A4 of gnum BAR 0
  constant c_WR_INDEX_ADR         : std_logic_vector(7 downto 0) := x"2A"; -- address 200A8 of gnum BAR 0
  constant c_CORE_STATUS_ADR      : std_logic_vector(7 downto 0) := x"2B"; -- address 200AC of gnum BAR 0

---------------------------------------------------------------------------------------------------
-- Address of TDC core Control register
                                                                           -- corresponds to:
  constant c_CTRL_REG_ADR         : std_logic_vector(7 downto 0) := x"3F"; -- address 200FC of gnum BAR 0


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

--  c_RESET_WORD


---------------------------------------------------------------------------------------------------
--                            Constants regarding the Circular Buffer                            --
---------------------------------------------------------------------------------------------------
  constant c_CIRCULAR_BUFF_SIZE : unsigned(31 downto 0) := x"00000100";


---------------------------------------------------------------------------------------------------
--                                      Components Declarations:                                 --
---------------------------------------------------------------------------------------------------


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
       clk_i_cycles_offset_o   : out std_logic_vector(g_width-1 downto 0);
       current_roll_over_o     : out std_logic_vector(g_width-1 downto 0);
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
       acam_ef1_synch1_i     : in std_logic;
       acam_ef2_i            : in std_logic;
       acam_ef2_synch1_i     : in std_logic;
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
       gnum_csr_adr_i         : in std_logic_vector(g_span-1 downto 0);
       gnum_csr_cyc_i         : in std_logic;
       gnum_csr_dat_i         : in std_logic_vector(g_width-1 downto 0);
       gnum_csr_stb_i         : in std_logic;
       gnum_csr_we_i          : in std_logic;
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
       gnum_csr_ack_o         : out std_logic;
       gnum_csr_dat_o         : out std_logic_vector(g_width-1 downto 0);
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
       start_dis_o             : out std_logic;
       start_from_fpga_o       : out std_logic;
       stop_dis_o              : out std_logic;
       acam_errflag_r_edge_p_o : out std_logic;
       acam_errflag_f_edge_p_o : out std_logic;
       acam_intflag_f_edge_p_o : out std_logic);
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component data_formatting
    port
      (tstamp_wr_wb_ack_i    : in std_logic;
       tstamp_wr_dat_i       : in std_logic_vector(127 downto 0);
       acam_tstamp1_i        : in std_logic_vector(31 downto 0);
       acam_tstamp1_ok_p_i   : in std_logic;
       acam_tstamp2_i        : in std_logic_vector(31 downto 0);
       acam_tstamp2_ok_p_i   : in std_logic;
       clk_i                 : in std_logic;
       dacapo_c_rst_p_i      : in std_logic;
       rst_i                 : in std_logic;
       clk_i_cycles_offset_i : in std_logic_vector(31 downto 0);
       current_roll_over_i   : in std_logic_vector(31 downto 0);
       local_utc_i           : in std_logic_vector(31 downto 0);
       retrig_nb_offset_i    : in std_logic_vector(31 downto 0);
      ----------------------------------------------------------------------
       tstamp_wr_wb_adr_o    : out std_logic_vector(7 downto 0);
       tstamp_wr_wb_cyc_o    : out std_logic;
       tstamp_wr_dat_o       : out std_logic_vector(127 downto 0);
       tstamp_wr_wb_stb_o    : out std_logic;
       tstamp_wr_wb_we_o     : out std_logic;
       tstamp_wr_p_o         : out std_logic;
       wr_index_o            : out std_logic_vector(31 downto 0));
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
      ----------------------------------------------------------------------
       irq_tstamp_p_o         : out std_logic;
       irq_time_p_o           : out std_logic);
      ----------------------------------------------------------------------
  end component;


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
      (nb_of_reg              : integer := 68;
       values_for_simulation  : boolean := FALSE);
    port
      (acam_refclk_i        : in std_logic;
       pll_ld_i             : in std_logic;
       pll_refmon_i         : in std_logic;
       pll_sdo_i            : in std_logic;
       pll_status_i         : in std_logic;
       gnum_rst_i           : in std_logic;
       spec_clk_i           : in std_logic;
       tdc_clk_p_i          : in std_logic;
       tdc_clk_n_i          : in std_logic;
      ----------------------------------------------------------------------
       acam_refclk_r_edge_p_o : out std_logic;
       internal_rst_o       : out std_logic;
       pll_cs_o             : out std_logic;
       pll_dac_sync_o       : out std_logic;
       pll_sdi_o            : out std_logic;
       pll_sclk_o           : out std_logic;
       spec_clk_o           : out std_logic;
       tdc_clk_o            : out std_logic);
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component acam_databus_interface
    port
      (ef1_i        : in std_logic;
       ef2_i        : in std_logic;
       lf1_i        : in std_logic; -- not used i think
       lf2_i        : in std_logic; -- not used i think
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
       ef1_synch1_o : out std_logic;
       ef2_o        : out std_logic;
       ef2_synch1_o : out std_logic;
       dat_o        : out std_logic_vector(31 downto 0));
      ----------------------------------------------------------------------
  end component;


---------------------------------------------------------------------------------------------------
  component circular_buffer
    port
      (clk_i             : in std_logic;
       tstamp_wr_rst_i   : in std_logic; 
       tstamp_wr_stb_i   : in std_logic;
       tstamp_wr_cyc_i   : in std_logic;
       tstamp_wr_we_i    : in std_logic;
       tstamp_wr_adr_i   : in std_logic_vector(7 downto 0);
       tstamp_wr_dat_i   : in std_logic_vector(127 downto 0);
       gnum_dma_rst_i    : in std_logic;
       gnum_dma_stb_i    : in std_logic;
       gnum_dma_cyc_i    : in std_logic;
       gnum_dma_we_i     : in std_logic;
       gnum_dma_adr_i    : in std_logic_vector(31 downto 0);
       gnum_dma_dat_i    : in std_logic_vector(31 downto 0);
     --------------------------------------------------
       tstamp_wr_ack_p_o : out std_logic;
       tstamp_wr_dat_o   : out std_logic_vector(127 downto 0);
       gnum_dma_ack_o    : out std_logic;
       gnum_dma_dat_o    : out std_logic_vector(31 downto 0);
       gnum_dma_stall_o  : out std_logic);
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


---------------------------------------------------------------------------------------------------
  component wb_addr_decoder
    generic
      (g_WINDOW_SIZE  : integer := 18;   -- Number of bits to address periph on the board (32-bit word address)
       g_WB_SLAVES_NB : integer := 2);
    port
    (clk_i       : in std_logic;
     rst_n_i     : in std_logic;
     wbm_adr_i   : in  std_logic_vector(31 downto 0);
     wbm_dat_i   : in  std_logic_vector(31 downto 0);
     wbm_sel_i   : in  std_logic_vector(3 downto 0);
     wbm_stb_i   : in  std_logic;
     wbm_we_i    : in  std_logic;
     wbm_cyc_i   : in  std_logic;
     wb_dat_i    : in  std_logic_vector((32*g_WB_SLAVES_NB)-1 downto 0);
     wb_ack_i    : in  std_logic_vector(g_WB_SLAVES_NB-1 downto 0);
     wb_stall_i  : in  std_logic_vector(g_WB_SLAVES_NB-1 downto 0);
      -------------------------------------------------------------
     wbm_dat_o   : out std_logic_vector(31 downto 0);
     wbm_ack_o   : out std_logic; 
     wbm_stall_o : out std_logic;
     wb_adr_o    : out std_logic_vector(31 downto 0);
     wb_dat_o    : out std_logic_vector(31 downto 0);
     wb_sel_o    : out std_logic_vector(3 downto 0);
     wb_stb_o    : out std_logic;
     wb_we_o     : out std_logic;
     wb_cyc_o    : out std_logic_vector(g_WB_SLAVES_NB-1 downto 0));
      -------------------------------------------------------------
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