-- Created by : G. Penacoba
-- Creation Date: May 2011
-- Description: Stop counter. Configurable start_value and width.
--				Current count value and done signal available.
--				Done signal asserted simultaneous to value=0.
--              Countdown is launched each time start is asserted
--              for one clock tick.
-- Modified by:
-- Modification Date:
-- Modification consisted on:


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity countdown_counter is
    generic(
        width           : integer :=32
    );
    port(
        clk             : in std_logic;
        reset           : in std_logic;
        start           : in std_logic;
        start_value     : in std_logic_vector(width-1 downto 0);

        count_done      : out std_logic;
        current_value   : out std_logic_vector(width-1 downto 0)
    );
end countdown_counter;

architecture rtl of countdown_counter is

constant zeroes : unsigned(width-1 downto 0):=(others=>'0');

signal one      : unsigned(width-1 downto 0);
signal value    : unsigned(width-1 downto 0):=(others=>'0');    -- initialized to avoid simulation warnings

begin
	
decount: process
begin
    if reset = '1' then
        count_done  <= '0';
        value       <= zeroes;
    elsif start='1' then
        count_done  <= '0';
        value       <= unsigned(start_value) - "1";
    elsif value = zeroes then
        count_done  <= '0';
        value       <= zeroes;
    elsif value = one then
        count_done  <= '1';
        value       <= value - "1";
    else
        count_done  <= '0';
        value       <= value - "1";
    end if;
    wait until clk ='1';
end process;

current_value       <= std_logic_vector(value);
one                 <= zeroes + "1";

end rtl;
