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
--  to do: NEEDS TO BE COMPLETELY REVAMPED AFTER DECISION FOR UNIQUE START. ROLL OVER COUNTER etc..
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
        clk                     : in std_logic;
        one_hz_p_i              : in std_logic;
        reset_i                 : in std_logic;
        retrig_period_i         : in std_logic_vector(g_width-1 downto 0);
        
        clk_cycles_offset_o     : out std_logic_vector(g_width-1 downto 0);
        current_roll_over_o     : out std_logic_vector(g_width-1 downto 0);
        retrig_nb_offset_o      : out std_logic_vector(g_width-1 downto 0)
    );
end start_retrigger_control;

----------------------------------------------------------------------------------------------------
--  architecture declaration for start_retrigger_control
----------------------------------------------------------------------------------------------------
architecture rtl of start_retrigger_control is

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

signal acam_fall_intflag_p      : std_logic;
signal acam_rise_intflag_p      : std_logic;
signal add_roll_over            : std_logic;
signal clk_cycles_offset        : std_logic_vector(g_width-1 downto 0);
signal current_cycles           : std_logic_vector(g_width-1 downto 0);
signal current_retrig_nb        : std_logic_vector(g_width-1 downto 0);
signal one_hz_p                 : std_logic;
signal reset                    : std_logic;
signal retrig_nb_offset         : std_logic_vector(g_width-1 downto 0);
signal retrig_nb_reset          : std_logic;
signal retrig_p                 : std_logic;
signal retrig_period            : std_logic_vector(g_width-1 downto 0);
signal retrig_period_reset      : std_logic;
signal roll_over_reset          : std_logic;
signal roll_over_value          : std_logic_vector(g_width-1 downto 0);

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    retrig_period_counter: free_counter
    generic map(
        width           => g_width
    )
    port map(
        clk             => clk,
        enable          => '1',
        reset           => retrig_period_reset,
        start_value     => retrig_period,
        
        count_done      => retrig_p,
        current_value   => current_cycles
    );
    
    retrig_nb_counter: incr_counter
    generic map(
        width           => g_width
    )
    port map(
        clk             => clk,
        end_value       => x"00000100",
        incr            => retrig_p,
        reset           => retrig_nb_reset,
        
        count_done      => open,
        current_value   => current_retrig_nb
    );
    -- These two counters keep a track of the current internal start retrigger
    -- of the Acam in parallel with the Acam itself
    
    roll_over_counter: incr_counter
    generic map(
        width           => g_width
    )
    port map(
        clk             => clk,
        end_value       => x"FFFFFFFF",
        incr            => add_roll_over,
        reset           => roll_over_reset,
        
        count_done      => open,
        current_value   => roll_over_value
    );
    -- This counter keeps track of the number of overflows of the Acam counter
    -- for the internal start retrigger
    
    capture_offset: process
    begin
        if reset ='1' then
            clk_cycles_offset       <= (others=>'0');
            retrig_nb_offset        <= (others=>'0');
        elsif one_hz_p ='1' then
            clk_cycles_offset       <= current_cycles;
            retrig_nb_offset        <= current_retrig_nb;
        end if;
        wait until clk ='1';
    end process;
    -- When a new second starts, all values are captured and stored as offsets.
    -- when a timestamps arrives, these offset will be subrstracted in order
    -- to base the final timestamp with respect to the current second.
    
    retrig_period_reset             <= acam_fall_intflag_p;
    retrig_nb_reset                 <= acam_fall_intflag_p;
    roll_over_reset                 <= one_hz_p;
    add_roll_over                   <= acam_fall_intflag_p;
    
    -- inputs
    acam_fall_intflag_p         <= acam_fall_intflag_p_i;
    acam_rise_intflag_p         <= acam_rise_intflag_p_i;
    one_hz_p                    <= one_hz_p_i;
    reset                       <= reset_i;
    retrig_period               <= retrig_period_i;
    
    -- outputs
    clk_cycles_offset_o         <= clk_cycles_offset;
    retrig_nb_offset_o          <= retrig_nb_offset;
    current_roll_over_o         <= roll_over_value;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
