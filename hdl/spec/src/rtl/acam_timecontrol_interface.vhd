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
        clk_i                   : in std_logic;
        start_trig_i            : in std_logic;
        reset_i                 : in std_logic;
        
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

signal clk                  : std_logic;
signal counter_reset        : std_logic;

signal start_trig           : std_logic;
signal reset                : std_logic;
signal s_int_flag           : unsigned(2 downto 0);
signal s_err_flag           : unsigned(2 downto 0);

signal start_dis            : std_logic;
signal start_from_fpga      : std_logic;
signal start_window         : std_logic;
signal start_window_reg     : unsigned(2 downto 0);
signal start_window_edge    : std_logic;
signal window_inverted      : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    sync_err_flag: process      -- synchronisation registers for ERR external signal
    begin
        if reset ='1' then
            s_err_flag      <= (others=>'0');
        else
            s_err_flag      <= shift_right(s_err_flag,1);
            s_err_flag(2)   <= err_flag_i;
        end if;
        wait until clk ='1';
    end process;
    
    sync_int_flag: process      -- synchronisation registers for INT external signal
    begin
        if reset ='1' then
            s_int_flag      <= (others=>'0');
        else
            s_int_flag      <= shift_right(s_int_flag,1);
            s_int_flag(2)   <= int_flag_i;
        end if;
        wait until clk ='1';
    end process;

    acam_fall_errflag_p_o           <= not(s_err_flag(1)) and s_err_flag(0);
    acam_rise_errflag_p_o           <= s_err_flag(1) and not(s_err_flag(0));

    acam_fall_intflag_p_o           <= not(s_int_flag(1)) and s_int_flag(0);
    acam_rise_intflag_p_o           <= s_int_flag(1) and not(s_int_flag(0));


    -- generation of the start pulse and the enable window:
    -- the start pulse originates from an internal signal
    -- at the same time, the StartDis is de-asserted.

    window_counter: incr_counter
    generic map(
        width           => g_width
    )
    port map(
        clk             => clk,
        end_value       => x"00000004",
        incr            => '1',
        reset           => counter_reset,
        
        count_done      => window_inverted,
        current_value   => open
    );
    
    start_window            <= not(window_inverted);

    start_disable_control: process
    begin
        if reset ='1' then
            start_dis       <='1';
        else
            start_dis       <= not(start_window);
        end if;
        wait until clk ='1';
    end process;
    
    start_window_synchronizer: process
    begin
        if reset ='1' then
            start_window_reg        <= (others=>'0');
        else
            start_window_reg        <= shift_right(start_window_reg,1);
            start_window_reg(2)     <= start_window;
        end if;
        wait until clk ='1';
    end process;
    
    start_pulse: process
    begin
        if reset ='1' then
            start_from_fpga     <= '0';
        elsif start_window_edge ='1' then
            start_from_fpga     <= '1';
        else
            start_from_fpga     <= '0';
        end if;
        wait until clk ='1';
    end process;
    
    counter_reset           <= reset or start_trig;
    start_window_edge       <= start_window_reg(2) and not(start_window_reg(1)) and not(start_window_reg(0));
    
    -- inputs
    clk                     <= clk_i;
    reset                   <= reset_i;
    start_trig              <= start_trig_i;
    
    -- outputs
    start_dis_o             <= start_dis;    
    start_from_fpga_o       <= start_from_fpga;
    stop_dis_o              <= '0';

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
