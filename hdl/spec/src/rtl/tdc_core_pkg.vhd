----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : Package for TDC core (tdc_core_pkg.vhd)
--  author      : G. Penacoba
--  date        : Jul 2011
--  version     : Revision 1
--  description : Package containing core wide constants and components
--  dependencies:
--  references  :
--  modified by :
--
----------------------------------------------------------------------------------------------------
--  last changes:
----------------------------------------------------------------------------------------------------
--  to do:
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

----------------------------------------------------------------------------------------------------
-- Package declaration
----------------------------------------------------------------------------------------------------
package tdc_core_pkg is

    component countdown_counter
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
    end component;

    component free_counter is
    generic(
        width           : integer :=32
    );
    port(
        clk             : in std_logic;
        enable          : in std_logic;
        reset           : in std_logic;
        start_value     : in std_logic_vector(width-1 downto 0);

        count_done      : out std_logic;
        current_value   : out std_logic_vector(width-1 downto 0)
    );
    end component;

    component incr_counter
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
    end component;
constant data_width             : integer:=32;
constant tdc_led_period_sim     : std_logic_vector(data_width-1 downto 0):=x"0000F424";
constant tdc_led_period_syn     : std_logic_vector(data_width-1 downto 0):=x"03B9ACA0";
constant spec_led_period_sim    : std_logic_vector(data_width-1 downto 0):=x"00004E20";
constant spec_led_period_syn    : std_logic_vector(data_width-1 downto 0):=x"01312D00";
constant visible_blink_length   : std_logic_vector(data_width-1 downto 0):=x"00BEBC20";

end tdc_core_pkg;

----------------------------------------------------------------------------------------------------
-- Package body
----------------------------------------------------------------------------------------------------
package body tdc_core_pkg is
end tdc_core_pkg;
