----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : start retrigger control and internal start number offset generator 
--              (start_retrigger_control)
--  author      : G. Penacoba
--  date        : July 2011
--  version     : Revision 1
--  description : launches the start pulses and the ACAM generates the internal start retriggers.
--                Also generates the offset to be added to the start number provided by tha Acam
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
use work.tdc_core_pkg.all;

----------------------------------------------------------------------------------------------------
--  entity declaration for start_retrigger_control
----------------------------------------------------------------------------------------------------
entity start_retrigger_control is
    generic(
        g_width                 : integer :=32
    );
    port(
        acam_rise_intflag_p_i   : in std_logic;
        acam_fall_intflag_p_i   : in std_logic;
        clk_i                   : in std_logic;
        one_hz_p_i              : in std_logic;
        reset_i                 : in std_logic;
        
        start_nb_offset_o       : out std_logic_vector(g_width-1 downto 0);
        start_trig_o            : out std_logic
    );
end start_retrigger_control;

----------------------------------------------------------------------------------------------------
--  architecture declaration for start_retrigger_control
----------------------------------------------------------------------------------------------------
architecture rtl of start_retrigger_control is

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

signal acam_fall_intflag_p      : std_logic;
signal acam_rise_intflag_p      : std_logic;
signal acam_halfcounter_gone    : std_logic;
signal add_offset               : std_logic;
signal clk                      : std_logic;
signal counter_reset            : std_logic;
signal offset_value             : std_logic_vector(g_width-1 downto 0);
signal offset_to_shift          : unsigned(g_width-1 downto 0);
signal one_hz_p                 : std_logic;
signal reset                    : std_logic;
signal start_nb_offset          : std_logic_vector(g_width-1 downto 0);
signal start_trig           : std_logic;

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
        incr            => add_offset,
        reset           => counter_reset,
        
        count_done      => open,
        current_value   => offset_value
    );
    
    halfcounter_monitor: process                    -- The halfcounter monitor is needed to make
    begin                                           -- sure that the falling edge pulse received 
        if reset ='1' or one_hz_p ='1' then         -- corresponds to a real overflow of the ACAM
            acam_halfcounter_gone       <= '0';     -- counter and not to a different reason,
        elsif acam_rise_intflag_p ='1' then         -- for example a reset. 
            acam_halfcounter_gone       <= '1';     -- This way the start_nb_offset will really 
        elsif acam_fall_intflag_p ='1' then         -- track the number of internal start retriggers
            acam_halfcounter_gone       <= '0';     -- inside the ACAM.
        end if;
        wait until clk ='1';
    end process;
    
    add_offset          <= acam_fall_intflag_p and acam_halfcounter_gone;
    counter_reset       <= reset or one_hz_p;
    offset_to_shift     <= unsigned(offset_value);
    start_nb_offset     <= std_logic_vector(shift_left(offset_to_shift,8));
    start_trig          <= one_hz_p;
    
    -- inputs
    acam_fall_intflag_p <= acam_fall_intflag_p_i;
    acam_rise_intflag_p <= acam_rise_intflag_p_i;
    clk                 <= clk_i;
    one_hz_p            <= one_hz_p_i;
    reset               <= reset_i;
    
    -- outputs
    start_nb_offset_o   <= start_nb_offset;
    start_trig_o        <= start_trig;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
