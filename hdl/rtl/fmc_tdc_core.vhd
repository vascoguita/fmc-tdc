--_________________________________________________________________________________________________
--                                                                                                |
--                                           |TDC core|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                         fmc_tdc_core                                           |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         fmc_tdc_core.vhd                                                                  |
--                                                                                                |
-- Description  The TDC core top level instanciates all the modules needed to provide to the      |
--              PCIe/VME interface the timestamps generated in the ACAM chip.                     |
--                                                                                                |
--              Figure 1 shows the architecture of this core.                                     |
--                                                                                                |
--              Each timestamp is a 128-bit word with the following structure:                    |
--                [31:0]   Fine time                             | each bit represents 81.03 ps   |
--                [63:32]  Coarse time within the current second | each bit represents 8 ns       |
--                [95:64]  Local UTC time                        | each bit represents 1 s        |
--                [127:96] Metadata                              | rising/falling tstamp, Channel |
--                                                                                                |
--              As the structure indicates, each timestamp is referred to a UTC second; the coarse|
--              and fine time indicate with 81.03 ps resolution the amount of time passed after   |
--              the last UTC second. The one_hz_gen unit is responsible for keeping the UTC time; |
--              currently this timekeeping depends on a TDC local oscillator, but future upgrades | 
--              of the core would provide White Rabbit accuracy.                                  |
--              Timestamps are formated to the structure above within the data_formatting unit and|
--              are stored in the circular_buffer unit, where the GNUM/VME core have direct access|
--                                                                                                |
--              In this application, the ACAM is used in I-Mode which provides unlimited measuring|
--              range with internal start retriggers. ACAM's counter of retriggers however is not |
--              large enough and there is the need to follow the retriggers inside the core; the  |
--              start_retrig_ctrl unit is responsible for that.                                   |
--                                                                                                |
--              The acam_databus_interface implements the communication with the ACAM for its     |
--              configuration as well as for the timestamps retreival.                            |
--              The acam_timecontrol_interface is mainly responsible for delivering to the ACAM   |
--              the start pulse, to which all timestamps are related.                             |
--                                                                                                |
--              The regs_ctrl implements the communication with the GNUM/VME interface for the    |
--              configuration of this core and of the ACAM.                                       |
--              The data_engine is managing the transfering of the configuration registers from   |
--              the regs_ctrl to the ACAM chip; it is also managing the timestamps'               |
--              acquisition from the ACAM chip, making it available to the data_formatting unit.  |
--                                                                                                |
--              The core is providing an interrupt in any of the following 3 cases:               |
--               o accumulation of timestamps larger than the settable threshold                  |
--               o more time passed than the settable time threshold and >=1 timestamps arrived   |
--               o error occured in the ACAM chip                                                 |
--                                                                                                |
--              The clks_rsts_manager unit is providing 125 MHz clock and resets to the core.     |
--             _________________________________________________________                          |
--            |                                                         |                         |
--            |    ________________     ____________                    |                         |
--            |   |  ____________  |   |            |    ___________    |                         |
--            |   | |            | |   |            |   |           |   |                         |
--            |   | |  ACAM time | |   |            |   |  irq gen  |   |                         |
--            |   | |    ctrl    | |   |            |   |___________|   |                         |
--            |   | |____________| |   |            |    ___________    |        ______           |
--            |   |  ____________  |   |            |   |           |   |       |      |          |
--            |   | |            | |   |    data    |   |           |   |       |      |          |
--            |   | | ACAM data  | |   |   engine   |   |           |   |       |      |          |
--            |   | |    ctrl    | |   |            |   |           |   |       |      |          |
--            |   | |____________| |   |            |   |   regs    |   |  -->  |      |          |
--            |   |________________|   |            |   |   ctrl    |   |  <--  |      |          |
--  ACAM <--  |       fine time        |            |   |           |   |       |      |          |
--  chip -->  |      ____________      |            |   |           |   |       | VME  |          |
--            |     |            |     |            |   |           |   |       | core |          |
--            |     |   start    |     |            |   |           |   |       |      |          |
--            |     |   retrig   |     |            |   |           |   |       |      |          |
--            |     |____________|     |            |   |           |   |       |      |          |
--            |      coarse time       |            |   |           |   |       |      |          |
--            |                        |            |   |           |   |       |      |          |
--            |      ____________      |____________|   |___________|   |       |      |          |
--            |     |            |                       ___________    |       |      |          |
--            |     |  1 Hz gen  |      ____________    |           |   |       |      |          |
--            |     |____________|     |            |   | circular  |   |  -->  |      |          |
--            |        UTC time        |   data     |   |  buffer   |   |  <--  |      |          |
--            |                        | formating  |   |           |   |       |      |          |
--            |    _________________   |____________|   |___________|   |       |      |          |
--            |   |____TDC LEDs_____|                                   |       |______|          |
--            |                                                         |                         |
--            |_________________________________________________________|                         |
--                                                              TDC core                          |
--             _________________________________________________________                          |
--            |                                                         |                         |
--            |                     clks_rsts_manager                   |                         |
--            |_________________________________________________________|                         |
--                                                                                                |
--                           Figure 1: TDC core architecture                                      |
--                                                                                                |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
--              Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
-- Date         09/2013                                                                           |
-- Version      v5.1                                                                              |
-- Depends on                                                                                     |
--                                                                                                |
----------------                                                                                  |
-- Last changes                                                                                   |
--     05/2011  v1  GP  First version                                                             |
--     06/2012  v2  EG  Revamping; Comments added, signals renamed                                |
--                      removed LEDs from top level                                               |
--                      new gnum core integrated                                                  |
--                      carrier 1 wire master added                                               |
--                      mezzanine I2C master added                                                |
--                      mezzanine 1 wire master added                                             |
--                      interrupts generator added                                                |
--                      changed generation of rst_i                                               |
--                      DAC reconfiguration+needed regs added                                     |
--     06/2012  v3  EG  Changes for v2 of TDC mezzanine                                           |
--                      Several pinout changes,                                                   |
--                      acam_ref_clk LVDS instead of CMOS,                                        |
--                      no PLL_LD only PLL_STATUS                                                 |
--     04/2013  v4  EG  created fmc_tdc_core module; before was all on fmc_tdc_core               |
--     07/2013  v5  EG  removed the clks_rsts_manager from the core; will go to top level         |
--     09/2013  v5.1EG  added block of comments and archirecture drawing                          |
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
--                                       Libraries & Packages
--=================================================================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tdc_core_pkg.all;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;


--=================================================================================================
--                                Entity declaration for fmc_tdc_core
--=================================================================================================
entity fmc_tdc_core is
  generic
    (g_span                 : integer := 32;                              -- address span in bus interfaces
     g_width                : integer := 32;                              -- data width in bus interfaces
     values_for_simul       : boolean := FALSE);                          -- this generic is set to TRUE
                                                                          -- when instantiated in a test-bench
  port
    (-- Clock and reset
     clk_125m_i             : in    std_logic;                            -- 125 MHz clk from the PLL on the TDC mezz
     rst_i                  : in    std_logic;                            -- global reset, synched to clk_125m_i
     acam_refclk_r_edge_p_i : in    std_logic;                            -- rising edge on 31.25MHz ACAM reference clock
     send_dac_word_p_o      : out   std_logic;                            -- command from PCIe/VME to reconfigure the TDC mezz DAC with dac_word_o
     dac_word_o             : out   std_logic_vector(23 downto 0);        -- new DAC configuration word from PCIe/VME
     -- Signals for the timing interface with the ACAM on TDC mezzanine
     start_from_fpga_o      : out   std_logic;                            -- start pulse
     err_flag_i             : in    std_logic;                            -- error flag
     int_flag_i             : in    std_logic;                            -- interrupt flag
     start_dis_o            : out   std_logic;                            -- start disable, not used
     stop_dis_o             : out   std_logic;                            -- stop disable, not used
     -- Signals for the data interface with the ACAM on TDC mezzanine
     data_bus_io            : inout std_logic_vector(27 downto 0);
     address_o              : out   std_logic_vector(3 downto 0);
     cs_n_o                 : out   std_logic;                            -- chip select   for ACAM
     oe_n_o                 : out   std_logic;                            -- output enable for ACAM
     rd_n_o                 : out   std_logic;                            -- read   signal for ACAM
     wr_n_o                 : out   std_logic;                            -- write  signal for ACAM
     ef1_i                  : in    std_logic;                            -- empty flag of ACAM iFIFO1
     ef2_i                  : in    std_logic;                            -- empty flag of ACAM iFIFO2
     -- Signals for the Input Logic on TDC mezzanine
     enable_inputs_o        : out   std_logic;                            -- enables all 5 inputs
     term_en_1_o            : out   std_logic;                            -- Ch.1 termination enable of 50 Ohm termination
     term_en_2_o            : out   std_logic;                            -- Ch.2 termination enable of 50 Ohm termination
     term_en_3_o            : out   std_logic;                            -- Ch.3 termination enable of 50 Ohm termination
     term_en_4_o            : out   std_logic;                            -- Ch.4 termination enable of 50 Ohm termination
     term_en_5_o            : out   std_logic;                            -- Ch.5 termination enable of 50 Ohm termination
     -- LEDs on TDC mezzanine
     tdc_led_status_o       : out   std_logic;                            -- amber led on front pannel, division of clk_125m_i
     tdc_led_trig1_o        : out   std_logic;                            -- amber led on front pannel, Ch.1 termination
     tdc_led_trig2_o        : out   std_logic;                            -- amber led on front pannel, Ch.2 termination
     tdc_led_trig3_o        : out   std_logic;                            -- amber led on front pannel, Ch.3 termination
     tdc_led_trig4_o        : out   std_logic;                            -- amber led on front pannel, Ch.4 termination
     tdc_led_trig5_o        : out   std_logic;                            -- amber led on front pannel, Ch.5 termination
     -- TDC input signals, also arriving to the FPGA; not used currently
     tdc_in_fpga_1_i        : in    std_logic;                            -- TDC input Ch.1, not used
     tdc_in_fpga_2_i        : in    std_logic;                            -- TDC input Ch.2, not used
     tdc_in_fpga_3_i        : in    std_logic;                            -- TDC input Ch.3, not used
     tdc_in_fpga_4_i        : in    std_logic;                            -- TDC input Ch.4, not used
     tdc_in_fpga_5_i        : in    std_logic;                            -- TDC input Ch.5, not used
     -- Interrupts
     irq_tstamp_p_o         : out   std_logic;                            -- if amount of tstamps > tstamps_threshold
     irq_time_p_o           : out   std_logic;                            -- if 0 < amount of tstamps < tstamps_threshold and time > time_threshold
     irq_acam_err_p_o       : out   std_logic;                            -- if ACAM err_flag_i is activated
    -- WISHBONE bus interface with the PCIe/VME core for the configuration of the TDC core
     tdc_config_wb_adr_i    : in    std_logic_vector(g_span-1 downto 0);  -- WISHBONE classic address
     tdc_config_wb_dat_i    : in    std_logic_vector(g_width-1 downto 0); -- WISHBONE classic data in
     tdc_config_wb_stb_i    : in    std_logic;                            -- WISHBONE classic strobe
     tdc_config_wb_we_i     : in    std_logic;                            -- WISHBONE classic write enable
     tdc_config_wb_cyc_i    : in    std_logic;                            -- WISHBONE classic cycle
     tdc_config_wb_ack_o    : out   std_logic;                            -- WISHBONE classic acknowledge
     tdc_config_wb_dat_o    : out   std_logic_vector(g_width-1 downto 0); -- WISHBONE classic data out
    -- WISHBONE bus interface with the PCIe/VME core for the retrieval of the timestamps from the TDC core memory
     tdc_mem_wb_adr_i       : in    std_logic_vector(31 downto 0);        -- WISHBONE pipelined address
     tdc_mem_wb_dat_i       : in    std_logic_vector(31 downto 0);        -- WISHBONE pipelined data in
     tdc_mem_wb_stb_i       : in    std_logic;                            -- WISHBONE pipelined strobe
     tdc_mem_wb_we_i        : in    std_logic;                            -- WISHBONE pipelined write enable
     tdc_mem_wb_cyc_i       : in    std_logic;                            -- WISHBONE pipelined cycle
     tdc_mem_wb_ack_o       : out   std_logic;                            -- WISHBONE pipelined acknowledge
     tdc_mem_wb_dat_o       : out   std_logic_vector(31 downto 0);        -- WISHBONE pipelined data out
     tdc_mem_wb_stall_o     : out   std_logic);                           -- WISHBONE pipelined stall
end fmc_tdc_core;


--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of fmc_tdc_core is

  -- ACAM communication
  signal acm_adr                                            : std_logic_vector(7 downto 0);
  signal acm_cyc, acm_stb, acm_we, acm_ack                  : std_logic;
  signal acm_dat_r, acm_dat_w                               : std_logic_vector(g_width-1 downto 0);
  signal acam_ef1, acam_ef2, acam_ef1_meta, acam_ef2_meta   : std_logic;
  signal acam_errflag_f_edge_p, acam_errflag_r_edge_p       : std_logic;
  signal acam_intflag_f_edge_p                              : std_logic;
  signal acam_tstamp1, acam_tstamp2                         : std_logic_vector(g_width-1 downto 0);
  signal acam_tstamp1_ok_p, acam_tstamp2_ok_p               : std_logic;
  -- control unit
  signal activate_acq_p, deactivate_acq_p, load_acam_config : std_logic;
  signal read_acam_config, read_acam_status, read_ififo1    : std_logic;
  signal read_ififo2, read_start01, reset_acam, load_utc    : std_logic;
  signal clear_dacapo_counter, roll_over_incr_recent        : std_logic;
  signal pulse_delay, window_delay, clk_period              : std_logic_vector(g_width-1 downto 0);
  signal starting_utc, acam_status, acam_inputs_en          : std_logic_vector(g_width-1 downto 0);
  signal acam_ififo1, acam_ififo2, acam_start01             : std_logic_vector(g_width-1 downto 0);
  signal irq_tstamp_threshold, irq_time_threshold           : std_logic_vector(g_width-1 downto 0);
  signal local_utc, wr_index                                : std_logic_vector(g_width-1 downto 0);
  signal acam_config, acam_config_rdbk                      : config_vector;
  signal tstamp_wr_p                                        : std_logic;
  -- retrigger control
  signal clk_i_cycles_offset, roll_over_nb, retrig_nb_offset: std_logic_vector(g_width-1 downto 0);
  signal one_hz_p                                           : std_logic;
  -- circular buffer
  signal circ_buff_class_adr                                : std_logic_vector(7 downto 0);
  signal circ_buff_class_stb, circ_buff_class_cyc           : std_logic;
  signal circ_buff_class_we, circ_buff_class_ack            : std_logic;
  signal circ_buff_class_data_wr, circ_buff_class_data_rd   : std_logic_vector(4*g_width-1 downto 0);
  --LED
  signal led_fordebug                                       : std_logic_vector(5 downto 0);


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

---------------------------------------------------------------------------------------------------
--                                   TDC REGISTERS CONTROLLER                                    --
---------------------------------------------------------------------------------------------------
  reg_control_block: reg_ctrl
  generic map
    (g_span                => g_span,
     g_width               => g_width)
  port map
    (clk_i                 => clk_125m_i,
     rst_i                 => rst_i,
     tdc_config_wb_adr_i   => tdc_config_wb_adr_i,
     tdc_config_wb_dat_i   => tdc_config_wb_dat_i,
     tdc_config_wb_stb_i   => tdc_config_wb_stb_i,
     tdc_config_wb_we_i    => tdc_config_wb_we_i,
     tdc_config_wb_cyc_i   => tdc_config_wb_cyc_i,
     tdc_config_wb_ack_o   => tdc_config_wb_ack_o,
     tdc_config_wb_dat_o   => tdc_config_wb_dat_o,
     activate_acq_p_o      => activate_acq_p,
     deactivate_acq_p_o    => deactivate_acq_p,
     acam_wr_config_p_o    => load_acam_config,
     acam_rdbk_config_p_o  => read_acam_config,
     acam_rdbk_status_p_o  => read_acam_status,
     acam_rdbk_ififo1_p_o  => read_ififo1,
     acam_rdbk_ififo2_p_o  => read_ififo2,
     acam_rdbk_start01_p_o => read_start01,
     acam_rst_p_o          => reset_acam,
     load_utc_p_o          => load_utc,
     dacapo_c_rst_p_o      => clear_dacapo_counter,
     acam_config_rdbk_i    => acam_config_rdbk,
     acam_status_i         => acam_status,
     acam_ififo1_i         => acam_ififo1,
     acam_ififo2_i         => acam_ififo2,
     acam_start01_i        => acam_start01,
     local_utc_i           => local_utc,
     irq_code_i            => x"00000000",
     core_status_i         => x"00000000",
     wr_index_i            => wr_index,
     acam_config_o         => acam_config,
     starting_utc_o        => starting_utc,
     acam_inputs_en_o      => acam_inputs_en,
     start_phase_o         => window_delay,
     irq_tstamp_threshold_o=> irq_tstamp_threshold,
     irq_time_threshold_o  => irq_time_threshold,
     send_dac_word_p_o     => send_dac_word_p_o,
     dac_word_o            => dac_word_o,
     one_hz_phase_o        => pulse_delay);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- termination enable registers
  term_enable_regs: process (clk_125m_i)
  begin
    if rising_edge (clk_125m_i) then
      if rst_i = '1' then
        enable_inputs_o <= '0';
        term_en_5_o     <= '0';
        term_en_4_o     <= '0';
        term_en_3_o     <= '0';
        term_en_2_o     <= '0';
        term_en_1_o     <= '0';
      else
        enable_inputs_o <= acam_inputs_en(7);
        term_en_5_o     <= acam_inputs_en(4);
        term_en_4_o     <= acam_inputs_en(3);
        term_en_3_o     <= acam_inputs_en(2);
        term_en_2_o     <= acam_inputs_en(1);
        term_en_1_o     <= acam_inputs_en(0);
      end if;
    end if;
  end process;


---------------------------------------------------------------------------------------------------
--                                       ONE HZ GENERATOR                                        --
---------------------------------------------------------------------------------------------------
  one_second_block: one_hz_gen
  generic map
    (g_width                => g_width)
  port map
    (acam_refclk_r_edge_p_i => acam_refclk_r_edge_p_i,
     clk_i                  => clk_125m_i,
     clk_period_i           => clk_period,
     load_utc_p_i           => load_utc,
     pulse_delay_i          => pulse_delay,
     rst_i                  => rst_i,
     starting_utc_i         => starting_utc,
     local_utc_o            => local_utc,
     one_hz_p_o             => one_hz_p);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
    clk_period              <= c_SIM_CLK_PERIOD when values_for_simul else c_SYN_CLK_PERIOD;


---------------------------------------------------------------------------------------------------
--                                   ACAM TIMECONTROL INTERFACE                                  --
---------------------------------------------------------------------------------------------------
  acam_timing_block: acam_timecontrol_interface
  port map
    (err_flag_i              => err_flag_i,
     int_flag_i              => int_flag_i,
     start_from_fpga_o       => start_from_fpga_o,
     acam_refclk_r_edge_p_i  => acam_refclk_r_edge_p_i,
     clk_i                   => clk_125m_i,
     activate_acq_p_i        => activate_acq_p,
     rst_i                   => rst_i,
     window_delay_i          => window_delay,
     acam_errflag_f_edge_p_o => acam_errflag_f_edge_p,
     acam_errflag_r_edge_p_o => acam_errflag_r_edge_p,
     acam_intflag_f_edge_p_o => acam_intflag_f_edge_p);


---------------------------------------------------------------------------------------------------
--                                     ACAM DATABUS INTERFACE                                    --
---------------------------------------------------------------------------------------------------
  acam_data_block: acam_databus_interface
  port map
    (ef1_i        => ef1_i,
     ef2_i        => ef2_i,
     data_bus_io  => data_bus_io,
     adr_o        => address_o,
     cs_n_o       => cs_n_o,
     oe_n_o       => oe_n_o,
     rd_n_o       => rd_n_o,
     wr_n_o       => wr_n_o,
     ef1_o        => acam_ef1,
     ef1_meta_o   => acam_ef1_meta,
     ef2_o        => acam_ef2,
     ef2_meta_o   => acam_ef2_meta,
     clk_i        => clk_125m_i,
     rst_i        => rst_i,
     adr_i        => acm_adr,
     cyc_i        => acm_cyc,
     dat_i        => acm_dat_w,
     stb_i        => acm_stb,
     we_i         => acm_we,
     ack_o        => acm_ack,
     dat_o        => acm_dat_r);


---------------------------------------------------------------------------------------------------
--                                ACAM START RETRIGGER CONTROLLER                                --
---------------------------------------------------------------------------------------------------
  start_retrigger_block: start_retrig_ctrl
  generic map
    (g_width                 => g_width)
  port map
    (acam_intflag_f_edge_p_i => acam_intflag_f_edge_p,
     clk_i                   => clk_125m_i,
     one_hz_p_i              => one_hz_p,
     rst_i                   => rst_i,
     roll_over_incr_recent_o => roll_over_incr_recent,
     clk_i_cycles_offset_o   => clk_i_cycles_offset,
     roll_over_nb_o          => roll_over_nb,
     retrig_nb_offset_o      => retrig_nb_offset);


---------------------------------------------------------------------------------------------------
--                                          DATA ENGINE                                          --
---------------------------------------------------------------------------------------------------
  data_engine_block: data_engine
  port map
    (acam_ack_i            => acm_ack,
     acam_dat_i            => acm_dat_r,
     acam_adr_o            => acm_adr,
     acam_cyc_o            => acm_cyc,
     acam_dat_o            => acm_dat_w,
     acam_stb_o            => acm_stb,
     acam_we_o             => acm_we,
     clk_i                 => clk_125m_i,
     rst_i                 => rst_i,
     acam_ef1_i            => acam_ef1,
     acam_ef1_meta_i       => acam_ef1_meta,
     acam_ef2_i            => acam_ef2,
     acam_ef2_meta_i       => acam_ef2_meta,
     activate_acq_p_i      => activate_acq_p,
     deactivate_acq_p_i    => deactivate_acq_p,
     acam_wr_config_p_i    => load_acam_config,
     acam_rdbk_config_p_i  => read_acam_config,
     acam_rdbk_status_p_i  => read_acam_status,
     acam_rdbk_ififo1_p_i  => read_ififo1,
     acam_rdbk_ififo2_p_i  => read_ififo2,
     acam_rdbk_start01_p_i => read_start01,
     acam_rst_p_i          => reset_acam,
     acam_config_i         => acam_config,
     acam_config_rdbk_o    => acam_config_rdbk,
     acam_status_o         => acam_status,
     acam_ififo1_o         => acam_ififo1,
     acam_ififo2_o         => acam_ififo2,
     acam_start01_o        => acam_start01,
     acam_tstamp1_o        => acam_tstamp1,
     acam_tstamp1_ok_p_o   => acam_tstamp1_ok_p,
     acam_tstamp2_o        => acam_tstamp2,
     acam_tstamp2_ok_p_o   => acam_tstamp2_ok_p);


---------------------------------------------------------------------------------------------------
--                                       DATA FORMATTING                                         --
---------------------------------------------------------------------------------------------------
  data_formatting_block: data_formatting
  port map
    (clk_i                   => clk_125m_i,
     rst_i                   => rst_i,
     tstamp_wr_wb_ack_i      => circ_buff_class_ack,
     tstamp_wr_dat_i         => circ_buff_class_data_rd,
     tstamp_wr_wb_adr_o      => circ_buff_class_adr,
     tstamp_wr_wb_cyc_o      => circ_buff_class_cyc,
     tstamp_wr_dat_o         => circ_buff_class_data_wr,
     tstamp_wr_wb_stb_o      => circ_buff_class_stb,
     tstamp_wr_wb_we_o       => circ_buff_class_we,
     acam_tstamp1_i          => acam_tstamp1,
     acam_tstamp1_ok_p_i     => acam_tstamp1_ok_p,
     acam_tstamp2_i          => acam_tstamp2,
     acam_tstamp2_ok_p_i     => acam_tstamp2_ok_p,
     dacapo_c_rst_p_i        => clear_dacapo_counter,
     roll_over_incr_recent_i => roll_over_incr_recent,
     clk_i_cycles_offset_i   => clk_i_cycles_offset,
     roll_over_nb_i          => roll_over_nb,
     retrig_nb_offset_i      => retrig_nb_offset,
     one_hz_p_i              => one_hz_p,
     local_utc_i             => local_utc,
     tstamp_wr_p_o           => tstamp_wr_p,
     wr_index_o              => wr_index);


---------------------------------------------------------------------------------------------------
--                                     INTERRUPTS GENERATOR                                      --
---------------------------------------------------------------------------------------------------
  interrupts_generator: irq_generator
  generic map
    (g_width                 => 32)
  port map
    (clk_i                   => clk_125m_i,
     rst_i                   => rst_i,
     irq_tstamp_threshold_i  => irq_tstamp_threshold,
     irq_time_threshold_i    => irq_time_threshold,
     acam_errflag_r_edge_p_i => acam_errflag_r_edge_p,
     activate_acq_p_i        => activate_acq_p,
     deactivate_acq_p_i      => deactivate_acq_p,
     tstamp_wr_p_i           => tstamp_wr_p,
     one_hz_p_i              => one_hz_p,
     irq_tstamp_p_o          => irq_tstamp_p_o,
     irq_time_p_o            => irq_time_p_o,
     irq_acam_err_p_o        => irq_acam_err_p_o);


---------------------------------------------------------------------------------------------------
--                                        CIRCULAR BUFFER                                        --
---------------------------------------------------------------------------------------------------
  circular_buffer_block: circular_buffer
  port map
   (clk_i              => clk_125m_i,
    tstamp_wr_rst_i    => rst_i,
    tstamp_wr_adr_i    => circ_buff_class_adr,
    tstamp_wr_cyc_i    => circ_buff_class_cyc,
    tstamp_wr_dat_i    => circ_buff_class_data_wr,
    tstamp_wr_stb_i    => circ_buff_class_stb,
    tstamp_wr_we_i     => circ_buff_class_we,
    tstamp_wr_ack_p_o  => circ_buff_class_ack,
    tstamp_wr_dat_o    => circ_buff_class_data_rd,
    tdc_mem_wb_rst_i   => rst_i,
    tdc_mem_wb_adr_i   => tdc_mem_wb_adr_i,
    tdc_mem_wb_cyc_i   => tdc_mem_wb_cyc_i,
    tdc_mem_wb_dat_i   => tdc_mem_wb_dat_i,
    tdc_mem_wb_stb_i   => tdc_mem_wb_stb_i,
    tdc_mem_wb_we_i    => tdc_mem_wb_we_i,
    tdc_mem_wb_ack_o   => tdc_mem_wb_ack_o,
    tdc_mem_wb_dat_o   => tdc_mem_wb_dat_o,
    tdc_mem_wb_stall_o => tdc_mem_wb_stall_o);


---------------------------------------------------------------------------------------------------
--                                              TDC LEDs                                         --
---------------------------------------------------------------------------------------------------  
  TDCboard_leds: leds_manager
  generic map
    (g_width          => 32,
     values_for_simul => values_for_simul)
  port map
    (clk_i            => clk_125m_i,
     rst_i            => rst_i,
     one_hz_p_i       => one_hz_p,
     acam_inputs_en_i => acam_inputs_en,
     fordebug_i       => led_fordebug,
     tdc_led_status_o => tdc_led_status_o,
     tdc_led_trig1_o  => tdc_led_trig1_o,
     tdc_led_trig2_o  => tdc_led_trig2_o,
     tdc_led_trig3_o  => tdc_led_trig3_o,
     tdc_led_trig4_o  => tdc_led_trig4_o,
     tdc_led_trig5_o  => tdc_led_trig5_o);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  led_fordebug <= (others => '0');


---------------------------------------------------------------------------------------------------
--                               ACAM start_dis/ stop_dis, not used                              --
--------------------------------------------------------------------------------------------------- 
  start_dis_o <= '0';
  stop_dis_o  <= '0';


end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------