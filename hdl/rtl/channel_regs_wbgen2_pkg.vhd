-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for Channel registers
---------------------------------------------------------------------------------------
-- File           : channel_regs_wbgen2_pkg.vhd
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

package ch_reg_wbgen2_pkg is
  
  
  -- Input registers (user design -> WB slave)
  
  type t_ch_reg_in_registers is record
    delta1_i                                 : std_logic_vector(31 downto 0);
    delta2_i                                 : std_logic_vector(31 downto 0);
    delta3_i                                 : std_logic_vector(31 downto 0);
    csr_delta_ready_i                        : std_logic;
  end record;
  
  constant c_ch_reg_in_registers_init_value: t_ch_reg_in_registers := (
    delta1_i => (others => '0'),
    delta2_i => (others => '0'),
    delta3_i => (others => '0'),
    csr_delta_ready_i => '0'
  );
  
  -- Output registers (WB slave -> user design)
  
  type t_ch_reg_out_registers is record
    offset1_o                                : std_logic_vector(31 downto 0);
    offset2_o                                : std_logic_vector(31 downto 0);
    offset3_o                                : std_logic_vector(31 downto 0);
    csr_delta_read_o                         : std_logic;
    csr_rst_seq_o                            : std_logic;
    csr_delta_ref_o                          : std_logic_vector(2 downto 0);
    csr_raw_mode_o                           : std_logic;
  end record;
  
  constant c_ch_reg_out_registers_init_value: t_ch_reg_out_registers := (
    offset1_o => (others => '0'),
    offset2_o => (others => '0'),
    offset3_o => (others => '0'),
    csr_delta_read_o => '0',
    csr_rst_seq_o => '0',
    csr_delta_ref_o => (others => '0'),
    csr_raw_mode_o => '0'
  );
  
  function "or" (left, right: t_ch_reg_in_registers) return t_ch_reg_in_registers;
  function f_x_to_zero (x:std_logic) return std_logic;
  function f_x_to_zero (x:std_logic_vector) return std_logic_vector;
  
  component channel_regs is
    port (
      rst_n_i                                  : in     std_logic;
      clk_sys_i                                : in     std_logic;
      slave_i                                  : in     t_wishbone_slave_in;
      slave_o                                  : out    t_wishbone_slave_out;
      int_o                                    : out    std_logic;
      regs_i                                   : in     t_ch_reg_in_registers;
      regs_o                                   : out    t_ch_reg_out_registers
    );
  end component;
  
end package;

package body ch_reg_wbgen2_pkg is
  function f_x_to_zero (x:std_logic) return std_logic is
  begin
    if x = '1' then
      return '1';
    else
      return '0';
    end if;
  end function;
  
  function f_x_to_zero (x:std_logic_vector) return std_logic_vector is
    variable tmp: std_logic_vector(x'length-1 downto 0);
  begin
    for i in 0 to x'length-1 loop
      if(x(i) = '1') then
        tmp(i):= '1';
      else
        tmp(i):= '0';
      end if; 
    end loop; 
    return tmp;
  end function;
  
  function "or" (left, right: t_ch_reg_in_registers) return t_ch_reg_in_registers is
    variable tmp: t_ch_reg_in_registers;
  begin
    tmp.delta1_i := f_x_to_zero(left.delta1_i) or f_x_to_zero(right.delta1_i);
    tmp.delta2_i := f_x_to_zero(left.delta2_i) or f_x_to_zero(right.delta2_i);
    tmp.delta3_i := f_x_to_zero(left.delta3_i) or f_x_to_zero(right.delta3_i);
    tmp.csr_delta_ready_i := f_x_to_zero(left.csr_delta_ready_i) or f_x_to_zero(right.csr_delta_ready_i);
    return tmp;
  end function;

end package body;
