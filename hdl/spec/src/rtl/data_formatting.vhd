----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : timestamp data formatting (data_formatting)
--  author      : G. Penacoba
--  date        : May 2011
--  version     : Revision 1
--  description : formats the timestamp coming from the acam plus the coarse timing 
--                plus the UTC time
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
--  entity declaration for data_formatting
----------------------------------------------------------------------------------------------------
entity data_formatting is
    generic(
        g_width             : integer :=32
    );
    port(
        acam_start01_i          : in std_logic_vector(16 downto 0);
        acam_timestamp_i        : in std_logic_vector(28 downto 0);
        acam_timestamp_valid_i  : in std_logic;
        clk_i                   : in std_logic;
        reset_i                 : in std_logic;
        start_nb_offset_i       : in std_logic_vector(g_width-1 downto 0);
        utc_current_time_i      : in std_logic_vector(g_width-1 downto 0);

        full_timestamp_o        : out std_logic_vector(3*g_width-1 downto 0);
        full_timestamp_valid_o  : out std_logic
    );
end data_formatting;

----------------------------------------------------------------------------------------------------
--  architecture declaration for data_formatting
----------------------------------------------------------------------------------------------------
architecture rtl of data_formatting is

signal acam_channel                 : std_logic_vector(2 downto 0);
signal acam_fine_timestamp          : std_logic_vector(16 downto 0);
signal acam_start01                 : std_logic_vector(16 downto 0);
signal acam_timestamp               : std_logic_vector(28 downto 0);
signal acam_timestamp_valid         : std_logic;
signal clk                          : std_logic;
signal reset                        : std_logic;
signal start_nb_offset              : std_logic_vector(g_width-1 downto 0);
signal utc_current_time             : std_logic_vector(g_width-1 downto 0);

signal full_timestamp               : std_logic_vector(3*g_width-1 downto 0);
signal full_timestamp_valid         : std_logic;

signal reserved                     : std_logic_vector(2 downto 0):=(others=>'0');
signal u_start_nb_offset            : unsigned(g_width-1 downto 0);
signal u_acam_start_nb              : unsigned(7 downto 0);
signal start_nb                     : std_logic_vector(g_width-1 downto 0);

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    full_timestamp_register: process
    begin
        if reset ='1' then
            full_timestamp          <= (others=>'0');
        elsif acam_timestamp_valid ='1' then
    
            full_timestamp(95 downto 64)            <= utc_current_time;
            full_timestamp(63 downto 40)            <= start_nb(23 downto 0);
            full_timestamp(39 downto 23)            <= acam_fine_timestamp;
            full_timestamp(22 downto 6)             <= acam_start01;
            full_timestamp(5 downto 3)              <= acam_channel;
            full_timestamp(2 downto 0)              <= reserved;
        end if;
        wait until clk ='1';
    end process;
        
    valid_onetick_signal: process
    begin
        full_timestamp_valid                    <= acam_timestamp_valid;
        wait until clk ='1';
    end process;
    
    acam_start01                        <= acam_start01_i;
    acam_timestamp                      <= acam_timestamp_i;
    acam_timestamp_valid                <= acam_timestamp_valid_i;
    clk                                 <= clk_i;
    reset                               <= reset_i;
    start_nb_offset                     <= start_nb_offset_i;
    utc_current_time                    <= utc_current_time_i;
    
    full_timestamp_o                    <= full_timestamp;
    full_timestamp_valid_o              <= full_timestamp_valid;
    
    u_start_nb_offset                   <= unsigned(start_nb_offset);
    u_acam_start_nb                     <= unsigned(acam_timestamp(25 downto 18));
    start_nb                            <= std_logic_vector(u_start_nb_offset + u_acam_start_nb);
    
    acam_fine_timestamp                 <= acam_timestamp(16 downto 0);
    acam_channel                        <= acam_timestamp(28 downto 26);

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
