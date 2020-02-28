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
use work.ch_reg_wbgen2_pkg.all;
use work.tdc_core_pkg.all;
use work.wishbone_pkg.all;
use work.gencores_pkg.all;

entity timestamp_fifo is
  generic (
    g_USE_FIFO_READOUT : boolean := TRUE);
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

    timestamp_i       : in t_tdc_timestamp;
    timestamp_valid_i : in std_logic;

    ts_offset_o : out t_tdc_timestamp;
    reset_seq_o : out std_logic;
    raw_enable_o : out std_logic
    );

end entity;

architecture rtl of timestamp_fifo is

  signal tmr_timeout : unsigned(9 downto 0);
  signal buf_irq_int : std_logic;
  signal buf_count   : unsigned(9 downto 0);

  signal last_ts    : std_logic_vector(127 downto 0);
  signal channel_id : std_logic_vector(2 downto 0);

  signal timestamp_with_seq : std_logic_vector(127 downto 0);

  signal ref_valid : std_logic;
  signal ref_ts : t_tdc_timestamp;
  signal sub_valid : std_logic;
  signal sub_in_valid, sub_out_valid : std_logic;
  signal sub_result : t_tdc_timestamp;
  signal sub_result_latched : t_tdc_timestamp;
  signal sub_out_valid_latched : std_logic;

  signal channel_reg_in        : t_ch_reg_in_registers;
  signal channel_reg_out       : t_ch_reg_out_registers;
  signal channel_reg_slave_in  : t_wishbone_slave_in;
  signal channel_reg_slave_out : t_wishbone_slave_out;

  signal fifo_reg_in        : t_tsf_in_registers;
  signal fifo_reg_out       : t_tsf_out_registers;
  signal fifo_reg_slave_in  : t_wishbone_slave_in;
  signal fifo_reg_slave_out : t_wishbone_slave_out;

begin

  -- Hack to maintain backward compatibility with previous
  -- versions of the code when channel_regs and fifo_regs were
  -- part of the same wbgen source, and the FIFO registers were
  -- right after the channel registers.
  --
  -- For this to work now and in the future (without editing),
  -- slave_i.adr must be byte addressed, and there can be no more
  -- than 8 32-bit channel registers.
  p_wb_mux : process (channel_reg_slave_out, fifo_reg_slave_out, slave_i) is
  begin
    -- register access
    if slave_i.adr(5) = '0' then
      channel_reg_slave_in <= slave_i;
      slave_o              <= channel_reg_slave_out;
      fifo_reg_slave_in    <= c_DUMMY_WB_SLAVE_IN;
    -- FIFO access
    else
      fifo_reg_slave_in        <= slave_i;
      fifo_reg_slave_in.adr(5) <= '0';
      slave_o                  <= fifo_reg_slave_out;
      channel_reg_slave_in     <= c_DUMMY_WB_SLAVE_IN;
    end if;
  end process p_wb_mux;

  U_CHANNEL_REG_WB_Slave : channel_regs
    port map (
      rst_n_i   => rst_sys_n_i,
      clk_sys_i => clk_sys_i,
      slave_i   => channel_reg_slave_in,
      slave_o   => channel_reg_slave_out,
      regs_i    => channel_reg_in,
      regs_o    => channel_reg_out);

  ts_offset_o.tai    <= channel_reg_out.offset1_o;
  ts_offset_o.coarse <= channel_reg_out.offset2_o;
  ts_offset_o.frac   <= channel_reg_out.offset3_o(11 downto 0);

  reset_seq_o <= channel_reg_out.csr_rst_seq_o;

  raw_enable_o <= channel_reg_out.csr_raw_mode_o;

  gen_without_fifo_readout : if not g_USE_FIFO_READOUT generate
    fifo_reg_slave_out <= c_DUMMY_WB_SLAVE_OUT;
    fifo_reg_out       <= c_tsf_out_registers_init_value;
    irq_o              <= '0';
  end generate gen_without_fifo_readout;

  gen_with_fifo_readout : if g_USE_FIFO_READOUT generate

    timestamp_with_seq(31 downto 0)    <= std_logic_vector(resize(unsigned(timestamp_i.tai), 32));
    timestamp_with_seq(63 downto 32)   <= std_logic_vector(resize(unsigned(timestamp_i.coarse), 32));
    timestamp_with_seq(95 downto 64)   <= std_logic_vector(resize(unsigned(timestamp_i.frac), 32));
    timestamp_with_seq(98 downto 96)   <= timestamp_i.channel;
    timestamp_with_seq(99)             <= timestamp_i.slope;
    timestamp_with_seq(127 downto 100) <= timestamp_i.seq(27 downto 0);


    U_FIFO_WB_Slave : timestamp_fifo_wb
      port map (
        rst_n_i   => rst_sys_n_i,
        clk_sys_i => clk_sys_i,
        slave_i   => fifo_reg_slave_in,
        slave_o   => fifo_reg_slave_out,
        regs_i    => fifo_reg_in,
        regs_o    => fifo_reg_out);

    buf_count <= resize(unsigned(fifo_reg_out.fifo_wr_usedw_o), 10);

    p_fifo_write : process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if rst_sys_n_i = '0' then
          fifo_reg_in.fifo_wr_req_i <= '0';
        else

          if(enable_i = '1' and fifo_reg_out.fifo_wr_full_o = '0' and timestamp_valid_i = '1') then
            fifo_reg_in.fifo_wr_req_i <= '1';
          else
            fifo_reg_in.fifo_wr_req_i <= '0';
          end if;
        end if;
      end if;
    end process;

    fifo_reg_in.fifo_ts0_i <= timestamp_with_seq(31 downto 0);
    fifo_reg_in.fifo_ts1_i <= timestamp_with_seq(63 downto 32);
    fifo_reg_in.fifo_ts2_i <= timestamp_with_seq(95 downto 64);
    fifo_reg_in.fifo_ts3_i <= timestamp_with_seq(127 downto 96);

    p_coalesce_irq : process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if rst_sys_n_i = '0' or enable_i = '0' then
          buf_irq_int <= '0';
        else
          if(fifo_reg_out.fifo_wr_empty_o = '1') then
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
            if(fifo_reg_out.fifo_wr_full_o = '1' or
               (buf_count > unsigned(irq_threshold_i(9 downto 0)))) then
              buf_irq_int <= '1';
            end if;
          end if;
        end if;
      end if;
    end process;

    irq_o <= buf_irq_int;

  end generate gen_with_fifo_readout;

end rtl;
