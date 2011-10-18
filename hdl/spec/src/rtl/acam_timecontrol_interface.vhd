----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : acam chip timing control interface (acam_timecontrol_interface)
--  author      : G. Penacoba
--  date        : May 2011
--  version     : Revision 1
--  description : interface with the acam chip pins for control and timing
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
--  entity declaration for acam_timing_interface
----------------------------------------------------------------------------------------------------
entity acam_timecontrol_interface is
    generic(
        g_width                 : integer :=32
    );
    port(
        -- signals external to the chip: interface with acam
        err_flag_i              : in std_logic;
        int_flag_i              : in std_logic;

        start_dis_o             : out std_logic;
        start_from_fpga_o       : out std_logic;
        stop_dis_o              : out std_logic;

        -- signals internal to the chip: interface with other modules
        acam_refclk_i           : in std_logic;
        clk_i                   : in std_logic;
        start_trig_i            : in std_logic;
        reset_i                 : in std_logic;
        window_delay_i          : in std_logic_vector(g_width-1 downto 0);
        
        acam_rise_errflag_p_o   : out std_logic;
        acam_fall_errflag_p_o   : out std_logic;
        acam_rise_intflag_p_o   : out std_logic;
        acam_fall_intflag_p_o   : out std_logic
    );
end acam_timecontrol_interface;

----------------------------------------------------------------------------------------------------
--  architecture declaration for acam_timecontrol_interface
----------------------------------------------------------------------------------------------------
architecture rtl of acam_timecontrol_interface is

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

signal acam_refclk          : std_logic;
signal clk                  : std_logic;
signal counter_reset        : std_logic;
signal counter_value        : std_logic_vector(g_width-1 downto 0);
signal refclk_edge          : std_logic;
signal refclk_r             : unsigned(3 downto 0);
signal reset                : std_logic;
signal int_flag_r           : unsigned(2 downto 0);
signal err_flag_r           : unsigned(2 downto 0);

signal start_dis            : std_logic;
signal start_from_fpga      : std_logic;
signal start_trig           : std_logic;
signal start_trig_r         : unsigned(2 downto 0);
signal start_trig_edge      : std_logic;
signal start_trig_received  : std_logic;
signal waitingfor_refclk    : std_logic;
signal window_active        : std_logic;
signal window_delay         : std_logic_vector(g_width-1 downto 0);
signal window_inverted      : std_logic;
signal window_prepulse      : std_logic;
signal window_start         : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    sync_err_flag: process      -- synchronisation registers for ERR external signal
    begin
        if reset ='1' then
            err_flag_r      <= (others=>'0');
        else
            err_flag_r      <= shift_right(err_flag_r,1);
            err_flag_r(2)   <= err_flag_i;
        end if;
        wait until clk ='1';
    end process;
    
    sync_int_flag: process      -- synchronisation registers for INT external signal
    begin
        if reset ='1' then
            int_flag_r      <= (others=>'0');
        else
            int_flag_r      <= shift_right(int_flag_r,1);
            int_flag_r(2)   <= int_flag_i;
        end if;
        wait until clk ='1';
    end process;

    acam_fall_errflag_p_o           <= not(err_flag_r(1)) and err_flag_r(0);
    acam_rise_errflag_p_o           <= err_flag_r(1) and not(err_flag_r(0));

    acam_fall_intflag_p_o           <= not(int_flag_r(1)) and int_flag_r(0);
    acam_rise_intflag_p_o           <= int_flag_r(1) and not(int_flag_r(0));


    -- generation of the start pulse and the enable window:
    -- the start pulse originates from an internal signal
    -- at the same time, the StartDis is de-asserted.

    window_delayer_counter: countdown_counter           -- all signals are synchronized
    generic map(                                        -- to the refclk of the ACAM
        width           => g_width                      -- But their delays are configurable.
    )
    port map(
        clk             => clk,
        reset           => reset,
        start           => window_prepulse,
        start_value     => window_delay,

        count_done      => window_start,
        current_value   => open
    );
    
    window_active_counter: incr_counter                 -- Defines the de-assertion window
    generic map(                                        -- for the StartDisable signal
        width           => g_width
    )
    port map(
        clk             => clk,
        end_value       => x"00000004",
        incr            => start_trig_received,
        reset           => counter_reset,
        
        count_done      => window_inverted,
        current_value   => counter_value
    );
    
    window_active           <= not(window_inverted) and start_trig_received;

    -- After many tests with the ACAM chip, the Start Disable feature
    -- doesn't seem to be stable. It has therefore been decided to
    -- avoid its usage.

--    start_disable_control: process
--    begin
--        if reset ='1' then
--            start_dis       <='1';
--        else
--            start_dis       <= not(window_active);
--        end if;
--        wait until clk ='1';
--    end process;
    
    start_dis           <= '0';
    
    start_pulse_from_fpga: process                          -- Start pulse in the middle of the
    begin                                                   -- de-assertion window of StartDisable
        if reset ='1' then
            start_from_fpga     <= '0';
        elsif counter_value >= x"00000001" and counter_value <= x"00000002" then
            start_from_fpga     <= '1';
        else
            start_from_fpga     <= '0';
        end if;
        wait until clk ='1';
    end process;
    
    -- synchronization with refclk when the start_trig signal is received.
    ready_to_trigger: process
    begin
        if reset ='1' then  
                            waitingfor_refclk       <= '0';
        elsif start_trig_edge ='1' then
                            waitingfor_refclk       <= '1';
        elsif refclk_edge ='1' then
                            waitingfor_refclk       <= '0';
        end if;
        wait until clk ='1';
    end process;

    actual_trigger_received: process                -- signal needed to exclude the generation of
    begin                                           -- the start_from_fpga after a general reset
        if reset ='1' then  
                            start_trig_received     <= '0';
        elsif window_start ='1' then
                            start_trig_received     <= '1';
        elsif counter_value =x"00000004" then
                            start_trig_received     <= '0';
        end if;
        wait until clk ='1';
    end process;

    inputs_synchronizer: process
    begin
        if reset ='1' then
            start_trig_r          <= (others=>'0');
            refclk_r              <= (others=>'0');
        else
            start_trig_r          <= shift_right(start_trig_r,1);
            start_trig_r(2)       <= start_trig;
            
            refclk_r              <= shift_right(refclk_r,1);
            refclk_r(3)           <= acam_refclk;
        end if;
        wait until clk ='1';
    end process;
    
    refclk_edge             <= refclk_r(3) and
                            not(refclk_r(2)) and
                            not(refclk_r(1)) and 
                            refclk_r(0);
                           
    start_trig_edge         <= start_trig_r(2) and 
                            not(start_trig_r(1)) and 
                            not(start_trig_r(0));

    window_prepulse         <= waitingfor_refclk and refclk_edge;
    counter_reset           <= reset or window_start;
    
    -- inputs
    clk                     <= clk_i;
    reset                   <= reset_i;
    start_trig              <= start_trig_i;
    acam_refclk             <= acam_refclk_i;
    window_delay            <= window_delay_i;
    
    -- outputs
    start_dis_o             <= start_dis;    
    start_from_fpga_o       <= start_from_fpga;
    stop_dis_o              <= '0';

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
