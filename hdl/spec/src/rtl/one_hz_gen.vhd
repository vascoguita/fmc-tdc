----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : one hertz pulse generator (one_hz_gen)
--  author      : G. Penacoba
--  date        : May 2011
--  version     : Revision 1
--  description : generates one pulse every second synchronously with the acam reference clock.
--                  The phase with the reference clock can be adjusted.
--                  It also keeps track of the UTC time based on the local clock
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
--  entity declaration for one_hz_gen
----------------------------------------------------------------------------------------------------
entity one_hz_gen is
    generic(
        g_width                 : integer :=32
    );
    port(
        acam_refclk_edge_p_i    : in std_logic;
        clk                     : in std_logic;
        clock_period_i          : in std_logic_vector(g_width-1 downto 0); -- nb of clock periods for 1s
        load_utc_i              : in std_logic;
        pulse_delay_i           : in std_logic_vector(g_width-1 downto 0); -- nb of clock periods phase delay
        reset_i                 : in std_logic;                            -- with respect to reference clock
        starting_utc_i          : in std_logic_vector(g_width-1 downto 0);

        local_utc_o             : out std_logic_vector(g_width-1 downto 0);
        one_hz_p_o              : out std_logic
    );
end one_hz_gen;

----------------------------------------------------------------------------------------------------
--  architecture declaration for one_hz_gen
----------------------------------------------------------------------------------------------------
architecture rtl of one_hz_gen is

    component free_counter
    generic(
        width                   : integer :=32
    );
    port(
        clk                     : in std_logic;
        enable                  : in std_logic;
        reset                   : in std_logic;
        start_value             : in std_logic_vector(width-1 downto 0);

        count_done              : out std_logic;
        current_value           : out std_logic_vector(width-1 downto 0)
    );
    end component;

    component countdown_counter
    generic(
        width                   : integer :=32
    );
    port(
        clk                     : in std_logic;
        reset                   : in std_logic;
        start                   : in std_logic;
        start_value             : in std_logic_vector(width-1 downto 0);

        count_done              : out std_logic;
        current_value           : out std_logic_vector(width-1 downto 0)
    );
    end component;

constant constant_delay         : unsigned(g_width-1 downto 0):=x"00000004";

signal local_utc                : unsigned(g_width-1 downto 0);
signal load_utc                 : std_logic;
signal one_hz_p_pre             : std_logic;
signal one_hz_p_post            : std_logic;
signal onesec_counter_en        : std_logic;
signal acam_refclk_edge_p       : std_logic;
signal reset                    : std_logic;
signal starting_utc             : std_logic_vector(g_width-1 downto 0);
signal total_delay              : std_logic_vector(g_width-1 downto 0);


----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    clock_periods_counter: free_counter
    generic map(
        width                   => g_width
    )
    port map(
        clk                     => clk,
        enable                  => onesec_counter_en,
        reset                   => reset_i,
        start_value             => clock_period_i,

        count_done              => one_hz_p_pre,
        current_value           => open
    );

    pulse_delayer_counter: countdown_counter
    generic map(
        width                   => g_width
    )
    port map(
        clk                     => clk,
        reset                   => reset_i,
        start                   => one_hz_p_pre,
        start_value             => total_delay,

        count_done              => one_hz_p_post,
        current_value           => open
    );
    
    onesec_trigger: process
    begin
        if reset ='1' then
            onesec_counter_en   <= '0';
        elsif acam_refclk_edge_p ='1' then
            onesec_counter_en   <= '1';
        end if;
        wait until clk ='1';
    end process;

    utc_counter: process
    begin   
        if reset ='1' then
            local_utc           <= (others=>'0');
        elsif load_utc ='1' then
            local_utc           <= unsigned(starting_utc);
        elsif one_hz_p_post ='1' then
            local_utc           <= local_utc + 1;
        end if;
        wait until clk ='1';
    end process;
    
    total_delay                 <= std_logic_vector(unsigned(pulse_delay_i)+constant_delay);

    -- inputs
    acam_refclk_edge_p          <= acam_refclk_edge_p_i;
    reset                       <= reset_i;
    load_utc                    <= load_utc_i;
    starting_utc                <= starting_utc_i;
    
    -- output
    local_utc_o                 <= std_logic_vector(local_utc);
    one_hz_p_o                  <= one_hz_p_post;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
