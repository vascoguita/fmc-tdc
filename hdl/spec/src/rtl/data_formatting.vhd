----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : timestamp data formatting (data_formatting)
--  author      : G. Penacoba
--  date        : May 2011
--  version     : Revision 1
--  description : formats the timestamp coming from the acam plus the coarse timing 
--                plus the UTC time and writes it to the circular buffer
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
        g_span                  : integer :=32;
        g_width                 : integer :=32
    );
    port(
        -- wishbone master signals internal to the chip: interface with the circular buffer
        ack_i                   : in std_logic;
        dat_i                   : in std_logic_vector(4*g_width-1 downto 0);

        adr_o                   : out std_logic_vector(g_span-1 downto 0);
        cyc_o                   : out std_logic;
        dat_o                   : out std_logic_vector(4*g_width-1 downto 0);
        stb_o                   : out std_logic;
        we_o                    : out std_logic;
        
        -- signals internal to the chip: interface with other modules
        acam_timestamp1_i       : in std_logic_vector(g_width-1 downto 0);
        acam_timestamp1_valid_i : in std_logic;
        acam_timestamp2_i       : in std_logic_vector(g_width-1 downto 0);
        acam_timestamp2_valid_i : in std_logic;
        clk_i                   : in std_logic;
        clear_dacapo_flag_i     : in std_logic;
        reset_i                 : in std_logic;
        start_nb_offset_i       : in std_logic_vector(g_width-1 downto 0);
        utc_current_time_i      : in std_logic_vector(g_width-1 downto 0);

        wr_pointer_o            : out std_logic_vector(g_width-1 downto 0)
    );
end data_formatting;

----------------------------------------------------------------------------------------------------
--  architecture declaration for data_formatting
----------------------------------------------------------------------------------------------------
architecture rtl of data_formatting is

signal acam_channel                 : std_logic_vector(2 downto 0);
signal acam_fifo_ef                 : std_logic;
signal acam_fifo_lf                 : std_logic;
signal acam_fine_timestamp          : std_logic_vector(16 downto 0);
signal acam_slope                   : std_logic;
signal acam_start_nb                : std_logic_vector(7 downto 0);

signal acam_timestamp1              : std_logic_vector(g_width-1 downto 0);
signal acam_timestamp1_valid        : std_logic;
signal acam_timestamp2              : std_logic_vector(g_width-1 downto 0);
signal acam_timestamp2_valid        : std_logic;
signal clk                          : std_logic;
signal reset                        : std_logic;
signal start_nb_offset              : std_logic_vector(g_width-1 downto 0);
signal utc_current_time             : std_logic_vector(g_width-1 downto 0);

signal full_timestamp               : std_logic_vector(4*g_width-1 downto 0);
signal metadata                     : std_logic_vector(g_width-1 downto 0);
signal local_utc                    : std_logic_vector(g_width-1 downto 0);
signal coarse_time                  : std_logic_vector(g_width-1 downto 0);
signal fine_time                    : std_logic_vector(g_width-1 downto 0);

signal clear_dacapo_flag            : std_logic;
signal dacapo_flag                  : std_logic;
signal wr_pointer                   : unsigned(g_width-1 downto 0);

signal mem_ack                      : std_logic;
signal mem_data_rd                  : std_logic_vector(4*g_width-1 downto 0);

signal mem_adr                      : std_logic_vector(g_span-1 downto 0);
signal mem_cyc                      : std_logic;
signal mem_data_wr                  : std_logic_vector(4*g_width-1 downto 0);
signal mem_stb                      : std_logic;
signal mem_we                       : std_logic;

--signal reserved                     : std_logic_vector(2 downto 0):=(others=>'0');
--signal u_start_nb_offset            : unsigned(g_width-1 downto 0);
--signal u_acam_start_nb              : unsigned(7 downto 0);
--signal start_nb                     : std_logic_vector(g_width-1 downto 0);

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin
    
    pushing_data_to_buffer: process
    begin
        if reset ='1' then
--            mem_adr         <= (others =>'0');
            mem_cyc         <= '0';
--            mem_data_wr     <= (others =>'0');
            mem_stb         <= '0';
            mem_we          <= '0';
        elsif acam_timestamp1_valid ='1' or acam_timestamp2_valid ='1' then    
--            mem_adr         <= std_logic_vector(wr_pointer);
            mem_cyc         <= '1';
--            mem_data_wr     <= full_timestamp;
            mem_stb         <= '1';
            mem_we          <= '1';
        elsif mem_ack ='1' then
--            mem_adr         <= std_logic_vector(wr_pointer);
            mem_cyc         <= '0';
--            mem_data_wr     <= full_timestamp;
            mem_stb         <= '0';
            mem_we          <= '0';
        end if;
        wait until clk ='1';
    end process;
    
    pointer_update: process
    begin
        if reset ='1' then
            wr_pointer      <= (others=>'0');
        elsif mem_cyc ='1' and mem_stb ='1' and mem_we ='1' and mem_ack ='1' then
            if wr_pointer = 127 then
                wr_pointer  <= (others=>'0');
            else
                wr_pointer  <= wr_pointer + 1;
            end if;
        end if;
        wait until clk ='1';
    end process;
    
    dacapo_flag_update: process
    begin
        if reset ='1' then
            dacapo_flag         <= '0';
        elsif clear_dacapo_flag ='1' then
            dacapo_flag         <= '0';
        elsif wr_pointer = 127 then
            dacapo_flag         <= '1';
        end if;
        wait until clk ='1';
    end process;
    
    acam_data_slicing: process
    begin   
        if reset ='1' then  
            acam_channel                    <= (others =>'0');
            acam_fifo_ef                    <= '0';
            acam_fifo_lf                    <= '0';
            acam_fine_timestamp             <= (others =>'0');
            acam_slope                      <= '0';
            acam_start_nb                   <= (others =>'0');
        elsif acam_timestamp1_valid ='1' then
            acam_channel                    <= "0" & acam_timestamp1(27 downto 26);
            acam_fifo_ef                    <= acam_timestamp1(31);
            acam_fifo_lf                    <= acam_timestamp1(29);
            acam_fine_timestamp             <= acam_timestamp1(16 downto 0);
            acam_slope                      <= acam_timestamp1(17);
            acam_start_nb                   <= acam_timestamp1(25 downto 18);
        elsif acam_timestamp2_valid ='1' then
            acam_channel                    <= "1" & acam_timestamp2(27 downto 26);
            acam_fifo_ef                    <= acam_timestamp2(30);
            acam_fifo_lf                    <= acam_timestamp2(28);
            acam_fine_timestamp             <= acam_timestamp2(16 downto 0);
            acam_slope                      <= acam_timestamp2(17);
            acam_start_nb                   <= acam_timestamp2(25 downto 18);
        end if;
        wait until clk ='1';
    end process;
    
    metadata                                <= x"0000" 
                                            & "000" & acam_fifo_ef
                                            & "000" & acam_fifo_lf
                                            & "000" & acam_slope
                                            & "0" & acam_channel;
    
    local_utc                               <= utc_current_time;

    coarse_time                             <= x"000000" 
                                            & acam_start_nb;

    fine_time                               <= x"000" 
                                            & "000" 
                                            & acam_fine_timestamp;

    full_timestamp(127 downto 96)           <= metadata;
    full_timestamp(95 downto 64)            <= local_utc;
    full_timestamp(63 downto 32)            <= coarse_time;
    full_timestamp(31 downto 0)             <= fine_time;

    mem_adr                                 <= std_logic_vector(wr_pointer);
    mem_data_wr                             <= full_timestamp;
        
    -- inputs
    acam_timestamp1                     <= acam_timestamp1_i;
    acam_timestamp1_valid               <= acam_timestamp1_valid_i;
    acam_timestamp2                     <= acam_timestamp2_i;
    acam_timestamp2_valid               <= acam_timestamp2_valid_i;

    clk                                 <= clk_i;
    clear_dacapo_flag                   <= clear_dacapo_flag_i;
    reset                               <= reset_i;
    start_nb_offset                     <= start_nb_offset_i;
    utc_current_time                    <= utc_current_time_i;

    mem_ack                             <= ack_i;
    mem_data_rd                         <= dat_i;

    -- outputs
    wr_pointer_o                        <= dacapo_flag & std_logic_vector(wr_pointer(g_width-4 downto 0)) & "00";

    adr_o                               <= mem_adr;
    cyc_o                               <= mem_cyc;
    dat_o                               <= mem_data_wr;
    stb_o                               <= mem_stb;
    we_o                                <= mem_we;
    
--    u_start_nb_offset                   <= unsigned(start_nb_offset);
--    u_acam_start_nb                     <= unsigned(acam_timestamp(25 downto 18));
--    start_nb                            <= std_logic_vector(u_start_nb_offset + u_acam_start_nb);
    

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
