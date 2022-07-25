-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for Channel registers
---------------------------------------------------------------------------------------
-- File           : channel_regs.vhd
-- Author         : auto-generated by wbgen2 from wbgen/channel_regs.wb
-- Created        : Thu Sep 26 16:43:02 2019
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE wbgen/channel_regs.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wishbone_pkg.all;

use work.ch_reg_wbgen2_pkg.all;


entity channel_regs is
  port (
    rst_n_i                                  : in     std_logic;
    clk_sys_i                                : in     std_logic;
    slave_i                                  : in     t_wishbone_slave_in;
    slave_o                                  : out    t_wishbone_slave_out;
    int_o                                    : out    std_logic;
    regs_i                                   : in     t_ch_reg_in_registers;
    regs_o                                   : out    t_ch_reg_out_registers
  );
end channel_regs;

architecture syn of channel_regs is

signal ch_reg_offset1_int                       : std_logic_vector(31 downto 0);
signal ch_reg_offset2_int                       : std_logic_vector(31 downto 0);
signal ch_reg_offset3_int                       : std_logic_vector(31 downto 0);
signal ch_reg_csr_delta_read_dly0               : std_logic      ;
signal ch_reg_csr_delta_read_int                : std_logic      ;
signal ch_reg_csr_rst_seq_dly0                  : std_logic      ;
signal ch_reg_csr_rst_seq_int                   : std_logic      ;
signal ch_reg_csr_delta_ref_int                 : std_logic_vector(2 downto 0);
signal ch_reg_csr_raw_mode_int                  : std_logic      ;
signal ack_sreg                                 : std_logic_vector(9 downto 0);
signal rddata_reg                               : std_logic_vector(31 downto 0);
signal wrdata_reg                               : std_logic_vector(31 downto 0);
signal bwsel_reg                                : std_logic_vector(3 downto 0);
signal rwaddr_reg                               : std_logic_vector(2 downto 0);
signal ack_in_progress                          : std_logic      ;
signal wr_int                                   : std_logic      ;
signal rd_int                                   : std_logic      ;
signal allones                                  : std_logic_vector(31 downto 0);
signal allzeros                                 : std_logic_vector(31 downto 0);

begin
-- Some internal signals assignments
  wrdata_reg <= slave_i.dat;
-- 
-- Main register bank access process.
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      ack_sreg <= "0000000000";
      ack_in_progress <= '0';
      rddata_reg <= "00000000000000000000000000000000";
      ch_reg_offset1_int <= "00000000000000000000000000000000";
      ch_reg_offset2_int <= "00000000000000000000000000000000";
      ch_reg_offset3_int <= "00000000000000000000000000000000";
      ch_reg_csr_delta_read_int <= '0';
      ch_reg_csr_rst_seq_int <= '0';
      ch_reg_csr_delta_ref_int <= "000";
      ch_reg_csr_raw_mode_int <= '0';
    elsif rising_edge(clk_sys_i) then
-- advance the ACK generator shift register
      ack_sreg(8 downto 0) <= ack_sreg(9 downto 1);
      ack_sreg(9) <= '0';
      if (ack_in_progress = '1') then
        if (ack_sreg(0) = '1') then
          ch_reg_csr_delta_read_int <= '0';
          ch_reg_csr_rst_seq_int <= '0';
          ack_in_progress <= '0';
        else
        end if;
      else
        if ((slave_i.cyc = '1') and (slave_i.stb = '1')) then
          case rwaddr_reg(2 downto 0) is
          when "000" => 
            if (slave_i.we = '1') then
            end if;
            rddata_reg(31 downto 0) <= regs_i.delta1_i;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "001" => 
            if (slave_i.we = '1') then
            end if;
            rddata_reg(31 downto 0) <= regs_i.delta2_i;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "010" => 
            if (slave_i.we = '1') then
            end if;
            rddata_reg(31 downto 0) <= regs_i.delta3_i;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "011" => 
            if (slave_i.we = '1') then
              ch_reg_offset1_int <= wrdata_reg(31 downto 0);
            end if;
            rddata_reg(31 downto 0) <= ch_reg_offset1_int;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "100" => 
            if (slave_i.we = '1') then
              ch_reg_offset2_int <= wrdata_reg(31 downto 0);
            end if;
            rddata_reg(31 downto 0) <= ch_reg_offset2_int;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "101" => 
            if (slave_i.we = '1') then
              ch_reg_offset3_int <= wrdata_reg(31 downto 0);
            end if;
            rddata_reg(31 downto 0) <= ch_reg_offset3_int;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "110" => 
            if (slave_i.we = '1') then
              ch_reg_csr_delta_read_int <= wrdata_reg(1);
              ch_reg_csr_rst_seq_int <= wrdata_reg(2);
              ch_reg_csr_delta_ref_int <= wrdata_reg(5 downto 3);
              ch_reg_csr_raw_mode_int <= wrdata_reg(6);
            end if;
            rddata_reg(0) <= regs_i.csr_delta_ready_i;
            rddata_reg(1) <= '0';
            rddata_reg(2) <= '0';
            rddata_reg(5 downto 3) <= ch_reg_csr_delta_ref_int;
            rddata_reg(6) <= ch_reg_csr_raw_mode_int;
            rddata_reg(7) <= 'X';
            rddata_reg(8) <= 'X';
            rddata_reg(9) <= 'X';
            rddata_reg(10) <= 'X';
            rddata_reg(11) <= 'X';
            rddata_reg(12) <= 'X';
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
            rddata_reg(16) <= 'X';
            rddata_reg(17) <= 'X';
            rddata_reg(18) <= 'X';
            rddata_reg(19) <= 'X';
            rddata_reg(20) <= 'X';
            rddata_reg(21) <= 'X';
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(2) <= '1';
            ack_in_progress <= '1';
          when others =>
-- prevent the slave from hanging the bus on invalid address
            ack_in_progress <= '1';
            ack_sreg(0) <= '1';
          end case;
        end if;
      end if;
    end if;
  end process;
  
  
-- Drive the data output bus
  slave_o.dat <= rddata_reg;
-- Delta Timestamp Word 1 (TAI cycles, signed)
-- Delta Timestamp Word 2 (8ns ticks, unsigned)
-- Delta Timestamp Word 3 (fractional part, unsigned)
-- Channel Offset Word 1 (TAI cycles, signed)
  regs_o.offset1_o <= ch_reg_offset1_int;
-- Channel Offset Word 2 (8ns ticks, unsigned)
  regs_o.offset2_o <= ch_reg_offset2_int;
-- Channel Offset Word 3 (fractional part, unsigned)
  regs_o.offset3_o <= ch_reg_offset3_int;
-- Delta Timestamp Ready
-- Read Delta Timestamp
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      ch_reg_csr_delta_read_dly0 <= '0';
      regs_o.csr_delta_read_o <= '0';
    elsif rising_edge(clk_sys_i) then
      ch_reg_csr_delta_read_dly0 <= ch_reg_csr_delta_read_int;
      regs_o.csr_delta_read_o <= ch_reg_csr_delta_read_int and (not ch_reg_csr_delta_read_dly0);
    end if;
  end process;
  
  
-- Reset Sequence Counter
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      ch_reg_csr_rst_seq_dly0 <= '0';
      regs_o.csr_rst_seq_o <= '0';
    elsif rising_edge(clk_sys_i) then
      ch_reg_csr_rst_seq_dly0 <= ch_reg_csr_rst_seq_int;
      regs_o.csr_rst_seq_o <= ch_reg_csr_rst_seq_int and (not ch_reg_csr_rst_seq_dly0);
    end if;
  end process;
  
  
-- Delta Timestamp Reference Channel
  regs_o.csr_delta_ref_o <= ch_reg_csr_delta_ref_int;
-- Raw readout mode
  regs_o.csr_raw_mode_o <= ch_reg_csr_raw_mode_int;
  rwaddr_reg <= slave_i.adr(4 downto 2);
  slave_o.stall <= (not ack_sreg(0)) and (slave_i.stb and slave_i.cyc);
  slave_o.err <= '0';
  slave_o.rty <= '0';
-- ACK signal generation. Just pass the LSB of ACK counter.
  slave_o.ack <= ack_sreg(0);
end syn;
