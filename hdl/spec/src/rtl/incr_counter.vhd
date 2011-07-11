-- Created by : G. Penacoba
-- Creation Date: May 2011
-- Description: Stop counter. Configurable end_value and width.
--				Current count value and done signal available.
--				Done signal asserted simultaneous to value=end_value.
--				Needs a reset to restart.
-- Modified by:
-- Modification Date:
-- Modification consisted on:


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity incr_counter is
    generic(
        width           : integer :=32
    );
    port(
        clk             : in std_logic;
        end_value       : in std_logic_vector(width-1 downto 0);
        incr            : in std_logic;
        reset           : in std_logic;

        count_done      : out std_logic;
        current_value   : out std_logic_vector(width-1 downto 0)
    );
end incr_counter;

architecture rtl of incr_counter is

constant zeroes             : unsigned(width-1 downto 0):=(others=>'0');

signal end_minus_one        : unsigned(width-1 downto 0);
signal value                : unsigned(width-1 downto 0):=(others=>'0');    -- initialized to avoid simulation warnings

begin
	
count: process
begin
    if reset = '1' then
        count_done  <= '0';
        value       <= zeroes;
    elsif value = unsigned(end_value) then
        count_done  <= '1';
        value       <= unsigned(end_value);
    elsif incr ='1' then
        if value = end_minus_one then
            count_done  <= '1';
            value       <= value + "1";
        else
            count_done  <= '0';
            value       <= value + "1";
        end if;
    end if;
    wait until clk ='1';
end process;

current_value           <= std_logic_vector(value);
end_minus_one           <= unsigned(end_value) - "1";

end rtl;
