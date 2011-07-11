----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : internal start number offset generator (start_nb_offset_gen)
--  author      : G. Penacoba
--  date        : May 2011
--  version     : Revision 1
--  description : generates the offset to be added to the start number provided by tha Acam
--                by counting the number of times the 1-Byte counter of the Acam is overloaded.
--                The result is then multiplied by 256 (shifted by 8).
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
--  entity declaration for start_nb_offset_gen
----------------------------------------------------------------------------------------------------
entity start_nb_offset_gen is
    generic(
        g_width             : integer :=32
    );
    port(
        acam_intflag_p_i    : in std_logic;
        clk_i               : in std_logic;
        one_hz_p_i          : in std_logic;
        reset_i             : in std_logic;

        start_nb_offset_o   : out std_logic_vector(g_width-1 downto 0)
    );
end start_nb_offset_gen;

----------------------------------------------------------------------------------------------------
--  architecture declaration for start_nb_offset_gen
----------------------------------------------------------------------------------------------------
architecture rtl of start_nb_offset_gen is

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

signal acam_intflag_p   : std_logic;
signal clk              : std_logic;
signal counter_reset    : std_logic;
signal offset_value     : std_logic_vector(g_width-1 downto 0);
signal offset_to_shift  : unsigned(g_width-1 downto 0);
signal one_hz_p         : std_logic;
signal reset            : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    acam_irflag_counter: incr_counter
    generic map(
        width           => g_width
    )
    port map(
        clk             => clk,
        end_value       => x"FFFFFFFF",
        incr            => acam_intflag_p,
        reset           => counter_reset,
        
        count_done      => open,
        current_value   => offset_value
    );
    
    counter_reset       <= reset or one_hz_p;
    offset_to_shift     <= unsigned(offset_value);
    start_nb_offset_o   <= std_logic_vector(shift_left(offset_to_shift,8));
    
    acam_intflag_p      <= acam_intflag_p_i;
    clk                 <= clk_i;
    one_hz_p            <= one_hz_p_i;
    reset               <= reset_i;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
