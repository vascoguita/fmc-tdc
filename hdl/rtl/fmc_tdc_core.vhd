-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+


---------------------------------------------------------------------------------------------------
-- Title      : FMC TDC Core
---------------------------------------------------------------------------------------------------
-- Description  The TDC core top level instantiates all the modules needed to provide to the
--              GN4124/VME interface the timestamps generated in the ACAM chip.

--              A timestamp is referred to a UTC second;
--              the coarse and fine time indicate with 81.03 ps resolution the amount of time
--              passed after the last UTC second.
--              If the White Rabbit synchronization has been established, the UTC time comes from
--              the White Rabbit core. Otherwise, the one_hz_gen unit is responsible for keeping
--              the local UTC time relaying on the local TDC oscillator.
--              Timestamps are formatted to the structure above within the data_formatting unit
--
--              In this application, the ACAM is used in I-Mode which provides unlimited measuring
--              range with internal start retriggers. ACAM's counter of retriggers however is not
--              large enough and there is the need to follow the retriggers inside the core; the
--              start_retrig_ctrl unit is responsible for that.
--
--              The acam_databus_interface implements the communication with the ACAM for its
--              configuration as well as for the timestamps retrieval.
--              The acam_timecontrol_interface is mainly responsible for delivering to the ACAM
--              the start pulse, to which all timestamps are related.
--
--              The regs_ctrl implements the communication with the GN4124/VME interface for the
--              configuration of this core and of the ACAM.
--              The data_engine is managing the transferring of the configuration registers from
--              the regs_ctrl to the ACAM chip; it is also managing the timestamps'
--              acquisition from the ACAM chip, making it available to the data_formatting unit.
--
--              The clks_rsts_manager unit is providing 125 MHz clock and resets to the core.
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
use work.genram_pkg.all;


--=================================================================================================
--                                Entity declaration for fmc_tdc_core
--=================================================================================================
entity fmc_tdc_core is
  generic (
      g_SPAN                   : integer := 32;  -- address span in bus interfaces
      g_WIDTH                  : integer := 32;  -- data width in bus interfaces
      g_SIMULATION             : boolean := FALSE;
      -- Enable filtering based on pulse width. This will have the following effects:
      -- * Suppress theforwarding of negative slope timestamps.
      -- * Delay the forwarding of timestamps until after the falling edge timestamp.
      -- Once enabled, all pulses wider than 1 second or narrower than
      -- g_pulse_width_filter_min will be dropped.
      g_PULSE_WIDTH_FILTER     : boolean := true;
      -- In 8ns ticks.
      g_PULSE_WIDTH_FILTER_MIN : natural := 12;
      g_USE_DMA_READOUT        : boolean := FALSE;
      g_USE_FIFO_READOUT       : boolean := FALSE);
  port (
      clk_sys_i   : in std_logic;
      rst_sys_n_i : in std_logic;

      clk_tdc_i   : in std_logic;       -- 125 MHz reference from the PLL
      rst_tdc_n_i : in std_logic;       -- global reset, synched to clk_tdc_i

      acam_refclk_r_edge_p_i : in    std_logic;  -- rising edge on 31.25MHz ACAM reference clock
      send_dac_word_p_o      : out   std_logic;  -- command from GN4124/VME to reconfigure the TDC mezz DAC with dac_word_o
      dac_word_o             : out   std_logic_vector(23 downto 0);  -- new DAC configuration word from GN4124/VME
      -- Signals for the timing interface with the ACAM on TDC mezzanine
      start_from_fpga_o      : out   std_logic;  -- start pulse
      err_flag_i             : in    std_logic;  -- error flag
      int_flag_i             : in    std_logic;  -- interrupt flag
      start_dis_o            : out   std_logic;  -- start disable, not used
      stop_dis_o             : out   std_logic;  -- disables all acam channels
      -- Signals for the data interface with the ACAM on TDC mezzanine
      data_bus_io            : inout std_logic_vector(27 downto 0);
      address_o              : out   std_logic_vector(3 downto 0);
      cs_n_o                 : out   std_logic;  -- chip select   for ACAM
      oe_n_o                 : out   std_logic;  -- output enable for ACAM
      rd_n_o                 : out   std_logic;  -- read   signal for ACAM
      wr_n_o                 : out   std_logic;  -- write  signal for ACAM
      ef1_i                  : in    std_logic;  -- empty flag of ACAM iFIFO1
      ef2_i                  : in    std_logic;  -- empty flag of ACAM iFIFO2
      -- Signals for the Input Logic on TDC mezzanine
      enable_inputs_o        : out   std_logic;  -- enables all 5 inputs
      term_en_1_o            : out   std_logic;  -- Ch.1 termination enable of 50 Ohm termination
      term_en_2_o            : out   std_logic;  -- Ch.2 termination enable of 50 Ohm termination
      term_en_3_o            : out   std_logic;  -- Ch.3 termination enable of 50 Ohm termination
      term_en_4_o            : out   std_logic;  -- Ch.4 termination enable of 50 Ohm termination
      term_en_5_o            : out   std_logic;  -- Ch.5 termination enable of 50 Ohm termination
      -- LEDs on TDC mezzanine
      tdc_led_stat_o         : out   std_logic;  -- amber led on front pannel, division of clk_tdc_i
      tdc_led_trig_o         : out   std_logic_vector(4 downto 0); -- one amber led on front pannel per Ch

      -- White Rabbit control and status registers
      wrabbit_status_reg_i : in  std_logic_vector(g_WIDTH-1 downto 0);
      wrabbit_ctrl_reg_o   : out std_logic_vector(g_WIDTH-1 downto 0);
      -- White Rabbit timing
      wrabbit_synched_i    : in  std_logic;
      wrabbit_tai_p_i      : in  std_logic;
      wrabbit_tai_i        : in  std_logic_vector(31 downto 0);

      -- WISHBONE bus interface with the GN4124/VME core for the configuration
      -- of the TDC core (clk_sys)
      cfg_slave_i : in  t_wishbone_slave_in;
      cfg_slave_o : out t_wishbone_slave_out;

      ts_offset_i       : in  t_tdc_timestamp_array(4 downto 0);
      reset_seq_i       : in  std_logic_vector(4 downto 0);
      raw_enable_i      : in  std_logic_vector(4 downto 0);

      timestamp_o         : out t_tdc_timestamp_array(4 downto 0);
      timestamp_valid_o   : out std_logic_vector(4 downto 0);
      timestamp_valid_p_o : out std_logic_vector(4 downto 0);
      timestamp_ready_i   : in  std_logic_vector(4 downto 0);

      channel_enable_o : out std_logic_vector(4 downto 0);
      irq_threshold_o  : out std_logic_vector(9 downto 0);
      irq_timeout_o    : out std_logic_vector(9 downto 0);

      fmc_id_i         : in std_logic);
end fmc_tdc_core;


--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of fmc_tdc_core is

  -- ACAM communication
  signal acm_adr                                             : std_logic_vector(7 downto 0);
  signal acm_cyc, acm_stb, acm_we, acm_ack                   : std_logic;
  signal acm_dat_r, acm_dat_w                                : std_logic_vector(g_WIDTH-1 downto 0);
  signal acam_ef1, acam_ef2                                  : std_logic;
  signal acam_tstamp1, acam_tstamp2                          : std_logic_vector(g_WIDTH-1 downto 0);
  signal acam_tstamp1_ok_p, acam_tstamp2_ok_p                : std_logic;
  -- control unit
  signal activate_acq_p, deactivate_acq_p, load_acam_config  : std_logic;
  signal read_acam_config, read_acam_status, read_ififo1     : std_logic;
  signal read_ififo2, read_start01, reset_acam, load_utc     : std_logic;
  signal roll_over_incr_recent                               : std_logic;
  signal clk_period                                          : std_logic_vector(g_WIDTH-1 downto 0);
  signal starting_utc, acam_inputs_en                        : std_logic_vector(g_WIDTH-1 downto 0);
  signal acam_ififo1, acam_ififo2, acam_start01              : std_logic_vector(g_WIDTH-1 downto 0);
  signal irq_tstamp_threshold, irq_time_threshold            : std_logic_vector(g_WIDTH-1 downto 0);
  signal local_utc                                           : std_logic_vector(g_WIDTH-1 downto 0);
  signal acam_config, acam_config_rdbk                       : config_vector;
  signal start_from_fpga, state_active_p                     : std_logic;
  -- retrigger control
  signal clk_i_cycles_offset, roll_over_nb, retrig_nb_offset : std_logic_vector(g_WIDTH-1 downto 0);
  signal local_utc_p                                         : std_logic;
  signal current_retrig_nb                                   : std_logic_vector(g_WIDTH-1 downto 0);
  -- UTC
  signal utc_p                                               : std_logic;
  signal utc, wrabbit_ctrl_reg                               : std_logic_vector(g_WIDTH-1 downto 0);

  -- LEDs
  signal term_enable_tdc     : std_logic_vector(4 downto 0);

  signal raw_timestamp_valid : std_logic;
  signal raw_timestamp       : t_acam_timestamp;

  signal final_timestamp_valid : std_logic_vector(4 downto 0);
  signal final_timestamp_ready : std_logic_vector(4 downto 0);
  signal final_timestamp       : t_tdc_timestamp_array(4 downto 0);


  signal channel_enable_tdc : std_logic_vector(4 downto 0);
  signal channel_enable_sys : std_logic_vector(4 downto 0);

  signal rst_sys, rst_tdc : std_logic;
  signal core_status      : std_logic_vector(31 downto 0);


  signal gen_fake_ts_enable  : std_logic;
  signal gen_fake_ts_channel : std_logic_vector(2 downto 0);
  signal gen_fake_ts_period  : std_logic_vector(27 downto 0);
  signal int_flag_delay : std_logic_vector(15 downto 0);

--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

  rst_sys <= not rst_sys_n_i;
  rst_tdc <= not rst_tdc_n_i;
---------------------------------------------------------------------------------------------------
--                                   TDC REGISTERS CONTROLLER                                    --
---------------------------------------------------------------------------------------------------

  core_status(0)           <= '1' when g_USE_DMA_READOUT  else '0';
  core_status(1)           <= '1' when g_USE_FIFO_READOUT else '0';
  core_status(2)           <= fmc_id_i;
  core_status(31 downto 3) <= (others => '0');

  reg_control_block : entity work.reg_ctrl
    generic map
    (g_span  => g_span,
     g_WIDTH => g_WIDTH)
    port map
    (clk_tdc_i   => clk_tdc_i,
     rst_tdc_n_i => rst_tdc_n_i,
     clk_sys_i   => clk_sys_i,
     rst_sys_n_i => rst_sys_n_i,

     slave_i => cfg_slave_i,
     slave_o => cfg_slave_o,

     activate_acq_p_o       => activate_acq_p,
     deactivate_acq_p_o     => deactivate_acq_p,
     acam_wr_config_p_o     => load_acam_config,
     acam_rdbk_config_p_o   => read_acam_config,
     acam_rdbk_status_p_o   => read_acam_status,
     acam_rdbk_ififo1_p_o   => read_ififo1,
     acam_rdbk_ififo2_p_o   => read_ififo2,
     acam_rdbk_start01_p_o  => read_start01,
     acam_rst_p_o           => reset_acam,
     load_utc_p_o           => load_utc,
     acam_config_rdbk_i     => acam_config_rdbk,
     acam_ififo1_i          => acam_ififo1,
     acam_ififo2_i          => acam_ififo2,
     acam_start01_i         => acam_start01,
     local_utc_i            => utc,
     core_status_i          => core_status,
     wrabbit_status_reg_i   => wrabbit_status_reg_i,
     wrabbit_ctrl_reg_o     => wrabbit_ctrl_reg,
     acam_config_o          => acam_config,
     starting_utc_o         => starting_utc,
     acam_inputs_en_o       => acam_inputs_en,
     irq_tstamp_threshold_o => irq_tstamp_threshold,
     irq_time_threshold_o   => irq_time_threshold,
     send_dac_word_p_o      => send_dac_word_p_o,
     dac_word_o             => dac_word_o,
     -----------------------------------------------------------
     gen_fake_ts_period_o   => gen_fake_ts_period,  -- for debug
     gen_fake_ts_enable_o   => gen_fake_ts_enable,  -- for debug
     gen_fake_ts_channel_o  => gen_fake_ts_channel, -- for debug
     int_flag_delay_o       => int_flag_delay       -- for debug
     );

  process(clk_tdc_i)
  begin
    if rising_edge(clk_tdc_i) then
      irq_threshold_o <= irq_tstamp_threshold(9 downto 0);
      irq_timeout_o   <= irq_time_threshold(9 downto 0);
    end if;
  end process;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  wrabbit_ctrl_reg_o <= wrabbit_ctrl_reg;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- termination enable registers
  term_enable_regs : process (clk_tdc_i)
  begin
    if rising_edge (clk_tdc_i) then
      if rst_tdc_n_i = '0' then
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
--                                   LOCAL ONE HZ GENERATOR                                      --
---------------------------------------------------------------------------------------------------
  local_one_second_block : entity work.local_pps_gen
    generic map (
      g_WIDTH => g_WIDTH)
    port map (
      acam_refclk_r_edge_p_i => acam_refclk_r_edge_p_i,
      clk_i                  => clk_tdc_i,
      clk_period_i           => clk_period,
      load_utc_p_i           => load_utc,
      rst_i                  => rst_tdc,
      starting_utc_i         => starting_utc,
      local_utc_o            => local_utc,
      local_utc_p_o          => local_utc_p);

  clk_period <= work.tdc_core_pkg.f_pick(g_simulation, c_SIM_CLK_PERIOD, c_SYN_CLK_PERIOD);

---------------------------------------------------------------------------------------------------
--                                   ACAM TIMECONTROL INTERFACE                                  --
---------------------------------------------------------------------------------------------------
  acam_timing_block : entity work.acam_timecontrol_interface
    port map (
     start_from_fpga_o       => start_from_fpga,
     stop_dis_o              => stop_dis_o,
     utc_p_i                 => utc_p,
     clk_i                   => clk_tdc_i,
     activate_acq_p_i        => activate_acq_p,
     state_active_p_i        => state_active_p,
     deactivate_acq_p_i      => deactivate_acq_p,
     rst_i                   => rst_tdc);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --

  start_from_fpga_o <= start_from_fpga;


---------------------------------------------------------------------------------------------------
--                                     ACAM DATABUS INTERFACE                                    --
---------------------------------------------------------------------------------------------------
  acam_data_block : entity work.acam_databus_interface
    port map
    (ef1_i       => ef1_i,
     ef2_i       => ef2_i,
     data_bus_io => data_bus_io,
     adr_o       => address_o,
     cs_n_o      => cs_n_o,
     oe_n_o      => oe_n_o,
     rd_n_o      => rd_n_o,
     wr_n_o      => wr_n_o,
     ef1_o       => acam_ef1,
     ef2_o       => acam_ef2,
     clk_i       => clk_tdc_i,
     rst_i       => rst_tdc,
     adr_i       => acm_adr,
     cyc_i       => acm_cyc,
     dat_i       => acm_dat_w,
     stb_i       => acm_stb,
     we_i        => acm_we,
     ack_o       => acm_ack,
     dat_o       => acm_dat_r);


---------------------------------------------------------------------------------------------------
--                                ACAM START RETRIGGER CONTROLLER                                --
---------------------------------------------------------------------------------------------------
  start_retrigger_block : entity work.start_retrig_ctrl
    port map
    (
     int_flag_delay_i        => int_flag_delay,     -- for debug
     int_flag_i              => int_flag_i,
     clk_i                   => clk_tdc_i,
     utc_p_i                 => utc_p,
     rst_i                   => rst_tdc,
     current_retrig_nb_o     => current_retrig_nb,  -- for debug
     roll_over_incr_recent_o => roll_over_incr_recent,
     clk_i_cycles_offset_o   => clk_i_cycles_offset,
     roll_over_nb_o          => roll_over_nb,
     retrig_nb_offset_o      => retrig_nb_offset);


---------------------------------------------------------------------------------------------------
--                                          DATA ENGINE                                          --
---------------------------------------------------------------------------------------------------
  data_engine_block : entity work.data_engine
    generic map (
      g_simulation => g_simulation)
    port map
    (acam_ack_i            => acm_ack,
     acam_dat_i            => acm_dat_r,
     acam_adr_o            => acm_adr,
     acam_cyc_o            => acm_cyc,
     acam_dat_o            => acm_dat_w,
     acam_stb_o            => acm_stb,
     acam_we_o             => acm_we,
     clk_i                 => clk_tdc_i,
     rst_i                 => rst_tdc,
     acam_ef1_i            => acam_ef1,
     acam_ef2_i            => acam_ef2,
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
     start_from_fpga_i     => start_from_fpga,
     state_active_p_o      => state_active_p,
     acam_config_rdbk_o    => acam_config_rdbk,
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
  data_formatting_block : entity work.data_formatting
    port map
    (clk_i                   => clk_tdc_i,
     rst_i                   => rst_tdc,
     acam_tstamp1_i          => acam_tstamp1,
     acam_tstamp1_ok_p_i     => acam_tstamp1_ok_p,
     acam_tstamp2_i          => acam_tstamp2,
     acam_tstamp2_ok_p_i     => acam_tstamp2_ok_p,
     roll_over_incr_recent_i => roll_over_incr_recent,
     clk_i_cycles_offset_i   => clk_i_cycles_offset,
     roll_over_nb_i          => roll_over_nb,
     retrig_nb_offset_i      => retrig_nb_offset,
     current_retrig_nb_i     => current_retrig_nb,
     utc_p_i                 => utc_p,
     utc_i                   => utc,
     gen_fake_ts_period_i    => gen_fake_ts_period,
     gen_fake_ts_enable_i    => gen_fake_ts_enable,
     gen_fake_ts_channel_i   => gen_fake_ts_channel,
     timestamp_o             => raw_timestamp,
     timestamp_valid_o       => raw_timestamp_valid
     );


---------------------------------------------------------------------------------------------------
--                                   TSTAMP FINAL FORMAT                                         --
--                     ADDITION OF FIXED OFFSETS (PER CHANNEL CALIBRATION)                       --
--                                FILTERING BY PULSE WIDTH                                       --
---------------------------------------------------------------------------------------------------
  U_FilterAndConvert : entity work.timestamp_convert_filter
    generic map (
      g_pulse_width_filter     => g_PULSE_WIDTH_FILTER,
      g_pulse_width_filter_min => g_PULSE_WIDTH_FILTER_MIN)
    port map (
      clk_tdc_i   => clk_tdc_i,
      rst_tdc_n_i => rst_tdc_n_i,
      clk_sys_i   => clk_sys_i,
      rst_sys_n_i => rst_sys_n_i,
      enable_i     => channel_enable_sys,
      ts_i         => raw_timestamp,
      ts_valid_i   => raw_timestamp_valid,
      ts_o         => final_timestamp,
      ts_valid_o   => final_timestamp_valid,
      ts_valid_p_o => timestamp_valid_p_o,
      ts_ready_i   => final_timestamp_ready,
      ts_offset_i  => ts_offset_i,
      reset_seq_i  => reset_seq_i,
      raw_enable_i => raw_enable_i -- not used
      );


---------------------------------------------------------------------------------------------------
--                                       UTC timing source                                       --
---------------------------------------------------------------------------------------------------
  utc   <= wrabbit_tai_i   when wrabbit_synched_i = '1' else local_utc;
  utc_p <= wrabbit_tai_p_i when wrabbit_synched_i = '1' else local_utc_p;

  timestamp_valid_o     <= final_timestamp_valid;
  final_timestamp_ready <= timestamp_ready_i;
  timestamp_o           <= final_timestamp;

---------------------------------------------------------------------------------------------------
--                                              TDC LEDs                                         --
---------------------------------------------------------------------------------------------------
  TDCboard_leds : entity work.leds_manager
    generic map (
      g_WIDTH      => 32,
      g_simulation => g_simulation)
    port map (
      clk_i            => clk_tdc_i,
      rst_i            => rst_tdc,
      utc_p_i          => utc_p,
      tstamp_valid_p_i => final_timestamp_valid,
      term_en_i        => term_enable_tdc,
      tdc_led_stat_o   => tdc_led_stat_o,
      tdc_led_trig_o   => tdc_led_trig_o);

---------------------------------------------------------------------------------------------------
--                                    ACAM start_dis, not used                                   --
---------------------------------------------------------------------------------------------------
  start_dis_o <= '0';

  U_Sync_ChannelEnable : entity work.gc_sync_register
    generic map (
      g_WIDTH => 5)
    port map (
      clk_i     => clk_sys_i,
      rst_n_a_i => rst_sys_n_i,
      d_i       => channel_enable_tdc,
      q_o       => channel_enable_sys);

  term_enable_tdc    <= acam_inputs_en(4 downto 0);
  channel_enable_tdc <= acam_inputs_en(20 downto 16);
  channel_enable_o   <= channel_enable_sys;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
