-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

-------------------------------------------------------------------------------
-- Title      : WR synch
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: Generates the internal time base used to synchronize the TDC
-- and programmable pulse generators to an internal or WR-provided timescale.
-- Also interfaces the TDC core with an optional White Rabbit PTP core.
-------------------------------------------------------------------------------

library ieee;
-- Standard library
library IEEE;
use IEEE.std_logic_1164.all; -- std_logic definitions
use IEEE.NUMERIC_STD.all;    -- conversion functions
-- Specific library
library work;
use work.tdc_core_pkg.all;   -- definitions of types, constants, entities
use work.genram_pkg.all;
use work.gencores_pkg.all;

entity wrabbit_sync is

  generic
    (g_simulation        : boolean; -- when true, reduces some timeouts to speed up simulations
     g_with_wrabbit_core : boolean);
  port(
    clk_sys_i   : in std_logic;
    rst_n_sys_i : in std_logic;

    clk_ref_i   : in std_logic;
    rst_n_ref_i : in std_logic;

    -------------------------------------------------------------------------------
    -- White Rabbit Counter sync input
    -------------------------------------------------------------------------------
    wrabbit_dac_value_i       : in    std_logic_vector(23 downto 0);
    wrabbit_dac_wr_p_i        : in    std_logic;

    wrabbit_link_up_i         : in  std_logic;

    -- when HI, wrabbit_utc_i and wrabbit_coarse_i contain a valid time value and
    -- clk_ref_i is in-phase with the remote WR master
    wrabbit_time_valid_i      : in  std_logic; -- this is i te clk_ref_0 domain, no??

    -- 1: tells the WR core to lock the FMC's local oscillator to the WR
    -- reference clock. 0: keep the oscillator free running.
    wrabbit_clk_aux_lock_en_o : out std_logic;

    -- 1: FMC's Local oscillator locked to WR reference
    wrabbit_clk_aux_locked_i  : in  std_logic;

    -- 1: Carrier's DMTD clock is locked (to WR reference or local FMC oscillator)
    wrabbit_clk_dmtd_locked_i : in  std_logic;

    wrabbit_synched_o         : out std_logic;

    -- Wishbone regs
    wrabbit_reg_i             : in  std_logic_vector(31 downto 0);
    wrabbit_reg_o             : out std_logic_vector(31 downto 0));

end wrabbit_sync;

architecture rtl of wrabbit_sync is

  -- System clock frequency in Hz
  constant c_SYS_CLK_FREQ : integer        := 62500000;
  -- FSM timeout period calculation
  impure function f_eval_timeout return integer is
  begin
    if(g_simulation) then
      return 100;
    else
      return c_SYS_CLK_FREQ/1000;          -- 1ms state timeout
    end if;
  end f_eval_timeout;
  constant c_wrabbit_STATE_TIMEOUT         : integer := f_eval_timeout;

  -- FSM
  type   t_wrabbit_sync_state is (wrabbit_CORE_OFFLINE, wrabbit_WAIT_READY, wrabbit_SYNCING, wrabbit_SYNCED);
  signal wrabbit_state                     : t_wrabbit_sync_state;
  signal wrabbit_state_changed             : std_logic;
  signal wrabbit_state_syncing             : std_logic;
  signal wrabbit_clk_aux_lock_en           : std_logic;
    -- FSM timeout counter
  signal tmo_restart, tmo_hit              : std_logic;
  signal tmo_cntr                          : unsigned(f_log2_size(c_wrabbit_STATE_TIMEOUT)-1 downto 0);
  -- synchronizers
  signal wrabbit_en, time_valid            : std_logic;
  signal clk_aux_locked, link_up           : std_logic;
  signal state_syncing, clk_aux_lock_en    : std_logic;
  -- aux
  signal with_wrabbit_core                 : std_logic;
  signal dac_p_c                           : unsigned(23 downto 0); -- for debug


begin

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Synchronization of the wrabbit_reg_i(0) of the reg_ctrl unit to the 62.5 MHz domain

  input_synchronizer : gc_sync_ffs
    port map (
      clk_i    => clk_sys_i,
      rst_n_i  => '1',
      data_i   => wrabbit_reg_i(0),
      synced_o => wrabbit_en);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- FSM timeout counter
  p_timeout_counter : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_n_sys_i = '0' or tmo_restart = '1' or tmo_hit = '1' then
        tmo_cntr <= (others => '0');
        tmo_hit  <= '0';
      else
        tmo_cntr <= tmo_cntr + 1;
        if(tmo_cntr = c_wrabbit_STATE_TIMEOUT) then
          tmo_hit <= '1';
        end if;
      end if;
    end if;
  end process;
  tmo_restart <= wrabbit_state_changed;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- FSM
  gen_with_wr_core : if(g_with_wrabbit_core) generate
  p_whiterabbit_fsm : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_n_sys_i = '0' then
        wrabbit_state               <= wrabbit_CORE_OFFLINE;
        wrabbit_state_changed       <= '0';
      else
        case wrabbit_state is
          when wrabbit_CORE_OFFLINE =>
            wrabbit_clk_aux_lock_en <= '0';

            if(wrabbit_link_up_i = '1' and tmo_hit = '1') then
              wrabbit_state         <= wrabbit_WAIT_READY;
              wrabbit_state_changed <= '1';
            else
              wrabbit_state_changed <= '0';
            end if;

          when wrabbit_WAIT_READY =>
            wrabbit_clk_aux_lock_en <= '0';

            if(wrabbit_link_up_i = '0') then
              wrabbit_state         <= wrabbit_CORE_OFFLINE;
              wrabbit_state_changed <= '1';
            elsif(wrabbit_time_valid_i = '1' and tmo_hit = '1' and wrabbit_en = '1') then
              wrabbit_state_changed <= '1';
              wrabbit_state         <= wrabbit_SYNCING;
            else
              wrabbit_state_changed <= '0';
            end if;

          when wrabbit_SYNCING =>
            wrabbit_clk_aux_lock_en <= '1';

            if(wrabbit_time_valid_i = '0' or wrabbit_en = '0') then
              wrabbit_state         <= wrabbit_WAIT_READY;
              wrabbit_state_changed <= '1';
            elsif(wrabbit_clk_aux_locked_i = '1' and tmo_hit = '1') then
              wrabbit_state         <= wrabbit_SYNCED;
              wrabbit_state_changed <= '1';
            else
              wrabbit_state_changed <= '0';
            end if;

          when wrabbit_SYNCED =>

            if(wrabbit_time_valid_i = '0' or wrabbit_en = '0' or wrabbit_clk_aux_locked_i = '0') then
              wrabbit_state         <= wrabbit_SYNCING;
              wrabbit_state_changed <= '1';
            else
              wrabbit_state_changed <= '0';
            end if;
          end case;
        end if;
      end if;
    end process;
  end generate gen_with_wr_core;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Synchronization of the outputs to the 125 MHz domain to be used by the reg_ctrl unit
  outputs_synchronizer1 : gc_sync_ffs
    port map (
      clk_i    => clk_ref_i,
      rst_n_i  => '1',
      data_i   => wrabbit_clk_aux_locked_i,
      synced_o => clk_aux_locked);

  outputs_synchronizer2 : gc_sync_ffs
    port map (
      clk_i    => clk_ref_i,
      rst_n_i  => '1',
      data_i   => wrabbit_link_up_i,
      synced_o => link_up);

  outputs_synchronizer3 : gc_sync_ffs
    port map (
      clk_i    => clk_ref_i,
      rst_n_i  => '1',
      data_i   => wrabbit_state_syncing,
      synced_o => state_syncing);

  outputs_synchronizer4 : gc_sync_ffs
    port map (
      clk_i    => clk_ref_i,
      rst_n_i  => '1',
      data_i   => wrabbit_clk_aux_lock_en,
      synced_o => clk_aux_lock_en);

  outputs_synchronizer5 : gc_sync_ffs
    port map (
      clk_i    => clk_ref_i,
      rst_n_i  => '1',
      data_i   => wrabbit_time_valid_i,
      synced_o => time_valid);

  with_wrabbit_core           <= '1' when g_with_wrabbit_core else '0';
  wrabbit_synched_o           <= clk_aux_locked  and with_wrabbit_core;
  wrabbit_clk_aux_lock_en_o   <= clk_aux_lock_en and with_wrabbit_core;
  wrabbit_state_syncing       <= '1' when ((wrabbit_state = wrabbit_SYNCING or wrabbit_state = wrabbit_SYNCED) and with_wrabbit_core = '1') else '0';

  wrabbit_reg_o(0)            <= '1'; -- reserved
  wrabbit_reg_o(1)            <= with_wrabbit_core;
  wrabbit_reg_o(2)            <= link_up          and with_wrabbit_core;
  wrabbit_reg_o(3)            <= state_syncing    and with_wrabbit_core;
  wrabbit_reg_o(4)            <= clk_aux_locked   and with_wrabbit_core;
  wrabbit_reg_o(5)            <= time_valid       and with_wrabbit_core;
  wrabbit_reg_o(6)            <= wrabbit_reg_i(0) and with_wrabbit_core;
  wrabbit_reg_o(7)            <= clk_aux_locked   and with_wrabbit_core;
  wrabbit_reg_o(8)            <= time_valid       and with_wrabbit_core;
  wrabbit_reg_o(9)            <= clk_aux_lock_en  and with_wrabbit_core;
  wrabbit_reg_o(15 downto 10) <= (others => '0') when with_wrabbit_core = '1' else std_logic_vector(dac_p_c(5 downto 0));
  wrabbit_reg_o(31 downto 16) <= (others => '0') when with_wrabbit_core = '1' else wrabbit_dac_value_i(15 downto 0);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- used only for debug
  p_dac_p_counter : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_n_sys_i = '0' then
        dac_p_c   <= (others => '0');
      else
        if dac_p_c = "111111111111111111111111" then
          dac_p_c <= (others => '0');
        elsif wrabbit_dac_wr_p_i = '1' then
          dac_p_c <= dac_p_c + 1;
        end if;
      end if;
    end if;
  end process;

end rtl;
