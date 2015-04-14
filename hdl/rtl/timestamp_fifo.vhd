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
use work.wishbone_pkg.all;
use work.gencores_pkg.all;

entity timestamp_fifo is
  generic (
    g_channel : integer
    );
  port (
    clk_sys_i   : in std_logic;
    clk_tdc_i   : in std_logic;
    rst_n_sys_i : in std_logic;
    rst_tdc_i   : in std_logic;

    -- WB slave, system clock
    slave_i : in  t_wishbone_slave_in;
    slave_o : out t_wishbone_slave_out;

    irq_o : out std_logic;              -- IRQ line, level high, system clock

    enable_i : in std_logic;            -- channel enable, TDC clock
    tick_i   : in std_logic;            -- 1ms tick, TDC clock


    irq_threshold_i : in std_logic_vector(9 downto 0);
    irq_timeout_i   : in std_logic_vector(9 downto 0);

    timestamp_i       : in std_logic_vector(127 downto 0);
    timestamp_valid_i : in std_logic
    );

end entity;

architecture rtl of timestamp_fifo is

  component timestamp_fifo_wb is
    port (
      rst_n_i    : in  std_logic;
      clk_sys_i  : in  std_logic;
      wb_adr_i   : in  std_logic_vector(3 downto 0);
      wb_dat_i   : in  std_logic_vector(31 downto 0);
      wb_dat_o   : out std_logic_vector(31 downto 0);
      wb_cyc_i   : in  std_logic;
      wb_sel_i   : in  std_logic_vector(3 downto 0);
      wb_stb_i   : in  std_logic;
      wb_we_i    : in  std_logic;
      wb_ack_o   : out std_logic;
      wb_stall_o : out std_logic;
      clk_tdc_i  : in  std_logic;
      regs_i     : in  t_tsf_in_registers;
      regs_o     : out t_tsf_out_registers);
  end component timestamp_fifo_wb;

  signal tmr_timeout : unsigned(9 downto 0);
  signal buf_irq_int : std_logic;
  signal buf_count   : unsigned(9 downto 0);

  signal last_ts    : std_logic_vector(127 downto 0);
  signal regs_in    : t_tsf_in_registers;
  signal regs_out   : t_tsf_out_registers;
  signal channel_id : std_logic_vector(2 downto 0);

  signal ts_match : std_logic;
begin

  U_WB_Slave : timestamp_fifo_wb
    port map (
      rst_n_i    => rst_n_sys_i,
      clk_sys_i  => clk_sys_i,
      wb_adr_i   => slave_i.adr(5 downto 2),
      wb_dat_i   => slave_i.dat,
      wb_dat_o   => slave_o.dat,
      wb_cyc_i   => slave_i.cyc,
      wb_sel_i   => slave_i.sel,
      wb_stb_i   => slave_i.stb,
      wb_we_i    => slave_i.we,
      wb_ack_o   => slave_o.ack,
      wb_stall_o => slave_o.stall,
      clk_tdc_i  => clk_tdc_i,
      regs_i     => regs_in,
      regs_o     => regs_out);

  buf_count <= unsigned(regs_out.fifo_wr_usedw_o);

  ts_match <= '1' when timestamp_valid_i = '1' and unsigned(timestamp_i(98 downto 96)) = g_channel else '0';
  
  p_fifo_write : process(clk_tdc_i)
  begin
    if rising_edge(clk_tdc_i) then
      if rst_tdc_i = '1' then
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

  p_latch_last_timestamp : process(clk_tdc_i)
  begin
    if rising_edge(clk_tdc_i) then
      if rst_tdc_i = '1' then
        regs_in.ltsctl_valid_i <= '0';
      else
        if (enable_i = '1' and ts_match = '1') then
          regs_in.ltsctl_valid_i <= '1';
          last_ts                <= timestamp_i;
        elsif (regs_out.ltsctl_valid_o = '0' and regs_out.ltsctl_valid_load_o = '1') then
          regs_in.ltsctl_valid_i <= '0';
        end if;

        if (regs_out.ltsctl_valid_o = '0' and regs_out.ltsctl_valid_load_o = '1') then
          regs_in.lts0_i <= last_ts(127 downto 96);
          regs_in.lts1_i <= last_ts(95 downto 64);
          regs_in.lts2_i <= last_ts(63 downto 32);
          regs_in.lts3_i <= last_ts(31 downto 0);
        end if;
      end if;
    end if;
  end process;

  p_coalesce_irq : process(clk_tdc_i)
  begin
    if rising_edge(clk_tdc_i) then
      if rst_tdc_i = '1' or enable_i = '0' then
        buf_irq_int <= '0';
      else
        if(buf_count = 0) then
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
          if(buf_count > unsigned(irq_threshold_i(9 downto 0))) then
            buf_irq_int <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  U_Sync_IRQ : gc_sync_ffs
    port map (
      clk_i    => clk_sys_i,
      rst_n_i  => rst_n_sys_i,
      data_i   => buf_irq_int,
      synced_o => irq_o);

end rtl;
