---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for Simple Pulse Width Modulation Controller
---------------------------------------------------------------------------------------
-- File           : simple_pwm_wbgen2_pkg.vhd
-- Author         : auto-generated by wbgen2 from simple_pwm_wb.wb
-- Created        : Mon May 20 15:36:44 2013
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE simple_pwm_wb.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package spwm_wbgen2_pkg is
  
  
  -- Input registers (user design -> WB slave)
  
  type t_spwm_in_registers is record
    cr_presc_i                               : std_logic_vector(15 downto 0);
    cr_period_i                              : std_logic_vector(15 downto 0);
    sr_n_channels_i                          : std_logic_vector(3 downto 0);
    dr0_i                                    : std_logic_vector(15 downto 0);
    dr1_i                                    : std_logic_vector(15 downto 0);
    dr2_i                                    : std_logic_vector(15 downto 0);
    dr3_i                                    : std_logic_vector(15 downto 0);
    dr4_i                                    : std_logic_vector(15 downto 0);
    dr5_i                                    : std_logic_vector(15 downto 0);
    dr6_i                                    : std_logic_vector(15 downto 0);
    dr7_i                                    : std_logic_vector(15 downto 0);
    end record;
  
  constant c_spwm_in_registers_init_value: t_spwm_in_registers := (
    cr_presc_i => (others => '0'),
    cr_period_i => (others => '0'),
    sr_n_channels_i => (others => '0'),
    dr0_i => (others => '0'),
    dr1_i => (others => '0'),
    dr2_i => (others => '0'),
    dr3_i => (others => '0'),
    dr4_i => (others => '0'),
    dr5_i => (others => '0'),
    dr6_i => (others => '0'),
    dr7_i => (others => '0')
    );
    
    -- Output registers (WB slave -> user design)
    
    type t_spwm_out_registers is record
      cr_presc_o                               : std_logic_vector(15 downto 0);
      cr_presc_load_o                          : std_logic;
      cr_period_o                              : std_logic_vector(15 downto 0);
      cr_period_load_o                         : std_logic;
      dr0_o                                    : std_logic_vector(15 downto 0);
      dr0_load_o                               : std_logic;
      dr1_o                                    : std_logic_vector(15 downto 0);
      dr1_load_o                               : std_logic;
      dr2_o                                    : std_logic_vector(15 downto 0);
      dr2_load_o                               : std_logic;
      dr3_o                                    : std_logic_vector(15 downto 0);
      dr3_load_o                               : std_logic;
      dr4_o                                    : std_logic_vector(15 downto 0);
      dr4_load_o                               : std_logic;
      dr5_o                                    : std_logic_vector(15 downto 0);
      dr5_load_o                               : std_logic;
      dr6_o                                    : std_logic_vector(15 downto 0);
      dr6_load_o                               : std_logic;
      dr7_o                                    : std_logic_vector(15 downto 0);
      dr7_load_o                               : std_logic;
      end record;
    
    constant c_spwm_out_registers_init_value: t_spwm_out_registers := (
      cr_presc_o => (others => '0'),
      cr_presc_load_o => '0',
      cr_period_o => (others => '0'),
      cr_period_load_o => '0',
      dr0_o => (others => '0'),
      dr0_load_o => '0',
      dr1_o => (others => '0'),
      dr1_load_o => '0',
      dr2_o => (others => '0'),
      dr2_load_o => '0',
      dr3_o => (others => '0'),
      dr3_load_o => '0',
      dr4_o => (others => '0'),
      dr4_load_o => '0',
      dr5_o => (others => '0'),
      dr5_load_o => '0',
      dr6_o => (others => '0'),
      dr6_load_o => '0',
      dr7_o => (others => '0'),
      dr7_load_o => '0'
      );
    function "or" (left, right: t_spwm_in_registers) return t_spwm_in_registers;
    function f_x_to_zero (x:std_logic) return std_logic;
    function f_x_to_zero (x:std_logic_vector) return std_logic_vector;
end package;

package body spwm_wbgen2_pkg is
function f_x_to_zero (x:std_logic) return std_logic is
begin
if(x = 'X' or x = 'U') then
return '0';
else
return x;
end if; 
end function;
function f_x_to_zero (x:std_logic_vector) return std_logic_vector is
variable tmp: std_logic_vector(x'length-1 downto 0);
begin
for i in 0 to x'length-1 loop
if(x(i) = 'X' or x(i) = 'U') then
tmp(i):= '0';
else
tmp(i):=x(i);
end if; 
end loop; 
return tmp;
end function;
function "or" (left, right: t_spwm_in_registers) return t_spwm_in_registers is
variable tmp: t_spwm_in_registers;
begin
tmp.cr_presc_i := f_x_to_zero(left.cr_presc_i) or f_x_to_zero(right.cr_presc_i);
tmp.cr_period_i := f_x_to_zero(left.cr_period_i) or f_x_to_zero(right.cr_period_i);
tmp.sr_n_channels_i := f_x_to_zero(left.sr_n_channels_i) or f_x_to_zero(right.sr_n_channels_i);
tmp.dr0_i := f_x_to_zero(left.dr0_i) or f_x_to_zero(right.dr0_i);
tmp.dr1_i := f_x_to_zero(left.dr1_i) or f_x_to_zero(right.dr1_i);
tmp.dr2_i := f_x_to_zero(left.dr2_i) or f_x_to_zero(right.dr2_i);
tmp.dr3_i := f_x_to_zero(left.dr3_i) or f_x_to_zero(right.dr3_i);
tmp.dr4_i := f_x_to_zero(left.dr4_i) or f_x_to_zero(right.dr4_i);
tmp.dr5_i := f_x_to_zero(left.dr5_i) or f_x_to_zero(right.dr5_i);
tmp.dr6_i := f_x_to_zero(left.dr6_i) or f_x_to_zero(right.dr6_i);
tmp.dr7_i := f_x_to_zero(left.dr7_i) or f_x_to_zero(right.dr7_i);
return tmp;
end function;
end package body;
