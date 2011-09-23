----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : one hertz pulse generator (one_hz_gen)
--  author      : G. Penacoba
--  date        : May 2011
--  version     : Revision 1
--  description : generates one pulse every second synchronously with the acam reference clock
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
        g_width         : integer :=32
    );
    port(
        acam_refclk_i   : in std_logic;
        clk_i           : in std_logic;
        clock_period_i  : in std_logic_vector(g_width-1 downto 0);
        pulse_delay_i   : in std_logic_vector(g_width-1 downto 0);
        reset_i         : in std_logic;

        one_hz_p_o      : out std_logic
    );
end one_hz_gen;

----------------------------------------------------------------------------------------------------
--  architecture declaration for one_hz_gen
----------------------------------------------------------------------------------------------------
architecture rtl of one_hz_gen is

    component free_counter
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

constant constant_delay     : unsigned(3 downto 0):=x"4";

signal clk                  : std_logic;
signal one_hz_p_pre         : std_logic;
signal one_hz_p_post        : std_logic;
signal onesec_counter_en    : std_logic;
signal refclk_edge          : std_logic;
signal reset                : std_logic;
signal s_acam_refclk        : unsigned(3 downto 0);
signal total_delay          : std_logic_vector(g_width-1 downto 0);


----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    sync_acam_refclk: process
    begin
        if reset ='1' then
            s_acam_refclk       <= (others=>'0');
        else
            s_acam_refclk       <= shift_right(s_acam_refclk,1);
            s_acam_refclk(3)    <= acam_refclk_i;
        end if;
        wait until clk ='1';
    end process;
    
    onesec_trigger: process
    begin
        if reset ='1' then
            onesec_counter_en   <= '0';
        elsif refclk_edge ='1' then
            onesec_counter_en   <= '1';
        end if;
        wait until clk ='1';
    end process;

    clock_periods_counter: free_counter
    generic map(
        width           => g_width
    )
    port map(
        clk             => clk_i,
        enable          => onesec_counter_en,
        reset           => reset_i,
        start_value     => clock_period_i,

        count_done      => one_hz_p_pre,
        current_value   => open
    );

    pulse_delayer_counter: countdown_counter
    generic map(
        width           => g_width
    )
    port map(
        clk             => clk_i,
        reset           => reset_i,
        start           => one_hz_p_pre,
        start_value     => total_delay,

        count_done      => one_hz_p_post,
        current_value   => open
    );
    
    clk                 <= clk_i;
    reset               <= reset_i;
    
    refclk_edge         <= not(s_acam_refclk(3)) and
                           s_acam_refclk(2) and
                           s_acam_refclk(1) and 
                           not(s_acam_refclk(0));
                           
    total_delay         <= std_logic_vector(unsigned(pulse_delay_i)+constant_delay);

    one_hz_p_o          <= one_hz_p_post;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
