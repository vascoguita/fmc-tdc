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
        g_retrig_period_shift   : integer :=8;
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
        clk                     : in std_logic;
        clear_dacapo_counter_i     : in std_logic;
        reset_i                 : in std_logic;
        clk_cycles_offset_i     : in std_logic_vector(g_width-1 downto 0);
        current_roll_over_i     : in std_logic_vector(g_width-1 downto 0);
        local_utc_i             : in std_logic_vector(g_width-1 downto 0);
        retrig_nb_offset_i      : in std_logic_vector(g_width-1 downto 0);

        wr_index_o              : out std_logic_vector(g_width-1 downto 0)
    );
end data_formatting;

----------------------------------------------------------------------------------------------------
--  architecture declaration for data_formatting
----------------------------------------------------------------------------------------------------
architecture rtl of data_formatting is

constant buff_size                  : unsigned(g_width-1 downto 0):= x"00000100";

signal acam_timestamp1              : std_logic_vector(g_width-1 downto 0);
signal acam_timestamp1_valid        : std_logic;
signal acam_timestamp2              : std_logic_vector(g_width-1 downto 0);
signal acam_timestamp2_valid        : std_logic;

signal acam_channel                 : std_logic_vector(2 downto 0);
signal acam_fifo_ef                 : std_logic;
signal acam_fifo_lf                 : std_logic;
signal acam_fine_timestamp          : std_logic_vector(16 downto 0);
signal acam_slope                   : std_logic;
signal acam_start_nb                : std_logic_vector(7 downto 0);

signal reset                        : std_logic;
signal clk_cycles_offset            : std_logic_vector(g_width-1 downto 0);
signal current_roll_over            : std_logic_vector(g_width-1 downto 0);
signal retrig_nb_offset             : std_logic_vector(g_width-1 downto 0);

signal un_acam_start_nb             : unsigned(g_width-1 downto 0);
signal un_clk_cycles_offset         : unsigned(g_width-1 downto 0);
signal un_nb_of_retrig              : unsigned(g_width-1 downto 0);
signal un_nb_of_cycles              : unsigned(g_width-1 downto 0);
signal un_retrig_from_roll_over     : unsigned(g_width-1 downto 0);
signal un_retrig_nb_offset          : unsigned(g_width-1 downto 0);
signal un_roll_over                 : unsigned(g_width-1 downto 0);

signal full_timestamp               : std_logic_vector(4*g_width-1 downto 0);
signal metadata                     : std_logic_vector(g_width-1 downto 0);
signal local_utc                    : std_logic_vector(g_width-1 downto 0);
signal coarse_time                  : std_logic_vector(g_width-1 downto 0);
signal fine_time                    : std_logic_vector(g_width-1 downto 0);

signal clear_dacapo_counter         : std_logic;
signal dacapo_counter               : unsigned(g_width-13 downto 0);
signal wr_pointer                   : unsigned(7 downto 0);
constant address_128bit_shift       : std_logic_vector(3 downto 0):= x"0";

signal mem_ack                      : std_logic;
signal mem_data_rd                  : std_logic_vector(4*g_width-1 downto 0);

signal mem_adr                      : std_logic_vector(g_span-1 downto 0);
signal mem_cyc                      : std_logic;
signal mem_data_wr                  : std_logic_vector(4*g_width-1 downto 0);
signal mem_stb                      : std_logic;
signal mem_we                       : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin
    
    -- classic wishbone to write the full timestamps into the circular buffer memory
    pushing_data_to_buffer: process
    begin
        if reset ='1' then
            mem_cyc         <= '0';
            mem_stb         <= '0';
            mem_we          <= '0';
        elsif acam_timestamp1_valid ='1' or acam_timestamp2_valid ='1' then    
            mem_cyc         <= '1';
            mem_stb         <= '1';
            mem_we          <= '1';
        elsif mem_ack ='1' then
            mem_cyc         <= '0';
            mem_stb         <= '0';
            mem_we          <= '0';
        end if;
        wait until clk ='1';
    end process;
    
    -- the wr_pointer indicates which one is the next address to write
    -- it will be used by the PCIe host to configure the DMA coherently
    pointer_update: process
    begin
        if reset ='1' then
            wr_pointer      <= (others=>'0');
        elsif mem_cyc ='1' and mem_stb ='1' and mem_we ='1' and mem_ack ='1' then
            if wr_pointer = buff_size - 1 then
                wr_pointer  <= (others=>'0');
            else
                wr_pointer  <= wr_pointer + 1;
            end if;
        end if;
        wait until clk ='1';
    end process;
    
    -- the Da Capo counter indicates the number of times the circular buffer has been written completely
    -- it is cleared by the PCIe host.
    dacapo_counter_update: process
    begin
        if reset ='1' then
            dacapo_counter         <= (others=>'0');
        elsif clear_dacapo_counter ='1' then
            dacapo_counter         <= (others=>'0');
        elsif mem_cyc ='1' and mem_stb ='1' and mem_we ='1' and mem_ack ='1'
            and wr_pointer = buff_size - 1 then
            dacapo_counter         <= dacapo_counter + 1;
        end if;
        wait until clk ='1';
    end process;
    
    -- the 28-bits word received from the Acam is interpreted according to the datasheet
    -- and the corresponding values will be used to build the full timestamp
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
    
    mem_adr                                 <= x"000000" & std_logic_vector(wr_pointer);
    mem_data_wr                             <= full_timestamp;
        
    -- the full timestamp is a 128-bits word divided in four 32-bits words
    -- the highest weight word contains the metadata for each timestamp
    -- the following 32-bits word contains the local UTC time with 1s resolution
    -- then the coarse timing of the timestamp within the current second with 8 ns resolution
    -- finally the fine time for the timestamp with 81.03 ps resolution
    
    full_timestamp(127 downto 96)           <= metadata;
    full_timestamp(95 downto 64)            <= local_utc;
    full_timestamp(63 downto 32)            <= coarse_time;
    full_timestamp(31 downto 0)             <= fine_time;

    -- the metadata field contains extra information about the timestamp
    metadata                                <= x"0000" 
                                            & "000" & acam_fifo_ef
                                            & "000" & acam_fifo_lf
                                            & "000" & acam_slope
                                            & "0" & acam_channel;


    -- the UTC time is updated every second by the one_hz_pulse    
    local_utc                               <= local_utc_i;

    -- the coarse time is expressed as the number of 125 MHz clock cycles since the last one_hz_pulse.
    -- Since the clk and the pulse are derived from the same PLL, any offset between them is constant 
    -- and will cancel when substracting timestamps.

    coarse_time                             <= std_logic_vector(un_nb_of_cycles);
    
    -- all the values needed for the calculations have to be converted to unsigned

    un_acam_start_nb                        <= unsigned(x"000000" & acam_start_nb);
    un_clk_cycles_offset                    <= unsigned(clk_cycles_offset);
    un_retrig_nb_offset                     <= unsigned(retrig_nb_offset);
    un_roll_over                            <= unsigned(current_roll_over);

    -- the number of roll-overs of the ACAM internal start retrigger counter is converted to a number
    -- of internal start retriggers.

    un_retrig_from_roll_over                <= shift_left(un_roll_over,8); -- shifted left to multiply by 256
    
    -- the actual number of internal start retriggers actually occurred is calculated by subtracting the offset number
    -- already present when the one_hz_pulse arrives, and adding the start nb provided by the ACAM.

    un_nb_of_retrig                         <=  un_retrig_from_roll_over
                                                - un_retrig_nb_offset
                                                + un_acam_start_nb;
    -- finally, the coarse time is obtained by multiplying by the number of clk cycles in an internal
    -- start retrigger period and adding the number of clk cycles still to be discounted when the
    -- one_hz_pulse arrives.

    un_nb_of_cycles                         <= shift_left(un_nb_of_retrig - 1,g_retrig_period_shift) 
                                                + un_clk_cycles_offset;
    
    -- the fine time is directly provided by the ACAM as a number of BINs since the last
    -- internal retrigger.
    fine_time                               <= x"000" 
                                            & "000" 
                                            & acam_fine_timestamp;

    -- inputs
    acam_timestamp1                     <= acam_timestamp1_i;
    acam_timestamp1_valid               <= acam_timestamp1_valid_i;
    acam_timestamp2                     <= acam_timestamp2_i;
    acam_timestamp2_valid               <= acam_timestamp2_valid_i;

    clear_dacapo_counter                <= clear_dacapo_counter_i;
    reset                               <= reset_i;
    clk_cycles_offset                   <= clk_cycles_offset_i;
    retrig_nb_offset                    <= retrig_nb_offset_i;
    current_roll_over                   <= current_roll_over_i;

    mem_ack                             <= ack_i;
    mem_data_rd                         <= dat_i;

    -- outputs
--    wr_pointer_o                        <= dacapo_flag & std_logic_vector(wr_pointer(g_width-6 downto 0)) & x"0";
    wr_index_o                          <= std_logic_vector(dacapo_counter) & std_logic_vector(wr_pointer) & address_128bit_shift;
    
    adr_o                               <= mem_adr;
    cyc_o                               <= mem_cyc;
    dat_o                               <= mem_data_wr;
    stb_o                               <= mem_stb;
    we_o                                <= mem_we;
    
end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
