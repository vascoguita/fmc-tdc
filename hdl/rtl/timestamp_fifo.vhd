-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

--_________________________________________________________________________________________________
--                                                                                                |
--                                           |TDC core|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

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

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

use work.tsf_wbgen2_pkg.all;
use work.tdc_core_pkg.all;
use work.wishbone_pkg.all;
use work.gencores_pkg.all;

entity timestamp_fifo is
  generic (
    g_enable : boolean;
    g_channel : integer
    );
  port (
    clk_sys_i   : in std_logic;
    rst_sys_n_i : in std_logic;

    -- WB slave, system clock
    slave_i : in  t_wishbone_slave_in;
    slave_o : out t_wishbone_slave_out;

    irq_o : out std_logic;              -- IRQ line, level high, system clock

    enable_i : in std_logic;            -- channel enable, TDC clock
    tick_i   : in std_logic;            -- 1ms tick, TDC clock

    irq_threshold_i : in std_logic_vector(9 downto 0);
    irq_timeout_i : in std_logic_vector(9 downto 0);

    timestamp_i       : in t_tdc_timestamp_array(4 downto 0);
    timestamp_valid_i : in std_logic_vector(4 downto 0);

    ts_offset_o : out t_tdc_timestamp;
    reset_seq_o : out std_logic;
    raw_enable_o : out std_logic
    );

end entity;

architecture rtl of timestamp_fifo is

  signal tmr_timeout : unsigned(9 downto 0);
  signal buf_irq_int : std_logic;
  signal buf_count   : unsigned(9 downto 0);

  signal regs_in    : t_tsf_in_registers;
  signal regs_out   : t_tsf_out_registers;

  signal ts_match : std_logic;

  signal timestamp_with_seq : std_logic_vector(127 downto 0);

  signal ref_valid : std_logic;
  signal ref_ts : t_tdc_timestamp;
  signal ref_channel : integer range 0 to 4;
  signal sub_valid : std_logic;
  signal sub_in_valid, sub_out_valid : std_logic;
  signal sub_result : t_tdc_timestamp;
  signal sub_result_latched : t_tdc_timestamp;
  signal sub_out_valid_latched : std_logic;

begin

  --  Registers decoder
  U_WB_Slave : entity work.timestamp_fifo_wb
    port map (
      rst_n_i   => rst_sys_n_i,
      clk_sys_i => clk_sys_i,
      slave_i   => slave_i,
      slave_o   => slave_o,
      regs_i    => regs_in,
      regs_o    => regs_out);

  --  Common parts
  ts_offset_o.tai <= regs_out.offset1_o;
  ts_offset_o.coarse <= regs_out.offset2_o;
  ts_offset_o.frac <= regs_out.offset3_o(11 downto 0);
  reset_seq_o <= regs_out.csr_rst_seq_o;
  raw_enable_o <= regs_out.csr_raw_mode_o;

  --  Enable the fifo part only if the fifo readout is enabled.
  gen_fifos: if g_enable generate
    timestamp_with_seq(31 downto 0)    <= std_logic_vector(resize(unsigned(timestamp_i(g_channel).tai), 32));
    timestamp_with_seq(63 downto 32)   <= std_logic_vector(resize(unsigned(timestamp_i(g_channel).coarse), 32));
    timestamp_with_seq(95 downto 64)   <= std_logic_vector(resize(unsigned(timestamp_i(g_channel).frac), 32));
    timestamp_with_seq(98 downto 96)   <= timestamp_i(g_channel).channel;
    timestamp_with_seq(99)            <= timestamp_i(g_channel).slope;
    timestamp_with_seq(127 downto 100) <= timestamp_i(g_channel).seq(27 downto 0);

    buf_count <= resize(unsigned(regs_out.fifo_wr_usedw_o), 10);

    ts_match <= timestamp_valid_i(g_channel);

    p_fifo_write : process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if rst_sys_n_i = '0' then
          regs_in.fifo_wr_req_i <= '0';
        else

          if(enable_i = '1' and regs_out.fifo_wr_full_o = '0' and ts_match = '1') then
            regs_in.fifo_wr_req_i <= '1';
          else
            regs_in.fifo_wr_req_i <= '0';
          end if;
        end if;
      end if;
    end process;

    regs_in.fifo_ts0_i <= timestamp_with_seq(31 downto 0);
    regs_in.fifo_ts1_i <= timestamp_with_seq(63 downto 32);
    regs_in.fifo_ts2_i <= timestamp_with_seq(95 downto 64);
    regs_in.fifo_ts3_i <= timestamp_with_seq(127 downto 96);

    p_latch_ref_timestamp : process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if rst_sys_n_i = '0' or enable_i = '0' then
          ref_valid <= '0';
        else
          -- latch only the last rising edge TS
          if (enable_i = '1' and timestamp_valid_i(ref_channel) = '1') then
            ref_valid <= '1';
            ref_ts    <= timestamp_i(ref_channel);
          end if;
        end if;
      end if;
    end process;

    sub_valid <= ref_valid and ts_match;

    U_Subtractor: entity work.tdc_ts_sub
      port map (
        clk_i    => clk_sys_i,
        rst_n_i  => rst_sys_n_i,
        valid_i  => sub_in_valid,
        enable_i => enable_i,
        a_i      => timestamp_i(g_channel),
        b_i      => ref_ts,
        valid_o  => sub_out_valid,
        q_o      => sub_result);

    p_latch_deltas : process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if rst_sys_n_i = '0' or enable_i = '0' then
          sub_out_valid_latched <= '0';
        else
          if regs_out.csr_delta_read_o = '1' then
            sub_out_valid_latched <= '0';
            regs_in.delta1_i <= sub_result_latched.tai;
            regs_in.delta2_i <= sub_result_latched.coarse;
            regs_in.delta3_i <= x"00000" & sub_result_latched.frac;
          end if;

          if(sub_out_valid = '1') then
            sub_out_valid_latched <= '1';
            sub_result_latched <= sub_result;
          end if;
        end if;
      end if;
    end process;

    regs_in.csr_delta_ready_i <= sub_out_valid_latched;

    p_coalesce_irq : process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if rst_sys_n_i = '0' or enable_i = '0' then
          buf_irq_int <= '0';
        else
          if(regs_out.fifo_wr_empty_o = '1') then
            buf_irq_int <= '0';
            tmr_timeout <= (others => '0');
          else
            -- Simple interrupt coalescing :

            -- Case 1: There is some data in the buffer
            -- (but not exceeding the threshold) - assert the IRQ line after a
            -- certain timeout.
            if(buf_irq_int = '0') then
              if(tmr_timeout = unsigned(irq_timeout_i(9 downto 0))) then
                buf_irq_int <= '1';
                tmr_timeout <= (others => '0');
              elsif(tick_i = '1') then
                tmr_timeout <= tmr_timeout + 1;
              end if;
            end if;

            -- Case 2: amount of data exceeded the threshold - assert the IRQ
            -- line immediately.
            if(regs_out.fifo_wr_full_o = '1' or (buf_count > unsigned(irq_threshold_i(9 downto 0)))) then
              buf_irq_int <= '1';
            end if;
          end if;
        end if;
      end if;
    end process;

    irq_o <= buf_irq_int;
  end generate;

  --  Disable the fifo part.  Unfortunately even when the fifos are disabled we still need a few
  --  register of the map.
  gen_no_fifos: if not g_enable generate
    regs_in.fifo_wr_req_i <= '0';
    irq_o <= '0';
    regs_in.fifo_ts0_i <= (others => '0');
    regs_in.fifo_ts1_i <= (others => '0');
    regs_in.fifo_ts2_i <= (others => '0');
    regs_in.fifo_ts3_i <= (others => '0');
    regs_in.delta1_i <= (others => '0');
    regs_in.delta2_i <= (others => '0');
    regs_in.delta3_i <= (others => '0');
    regs_in.csr_delta_ready_i <= '0';
  end generate;

end rtl;
