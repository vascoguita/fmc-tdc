----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : data managing engine (data_engine)
--  author      : G. Penacoba
--  date        : June 2011
--  version     : Revision 1
--  description : engine managing the configuration and acquisition modes of operation for the ACAM.
--                  in acquisition mode: monitors permanently the Empty Flags of the ACAM iFIFOs
--                  and reads timestamps accordingly.
--                  when acquisition mode is inactive: allows the configuration and readback of ACAM
--                  registers.
--                  Acts as a wishbone master.
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
--  entity declaration for data_engine
----------------------------------------------------------------------------------------------------
entity data_engine is
    generic(
        g_span                  : integer :=32;
        g_width                 : integer :=32
    );
    port(
        -- wishbone master signals internal to the chip: interface with the ACAM data core
        ack_i                   : in std_logic;
        dat_i                   : in std_logic_vector(g_width-1 downto 0);

        adr_o                   : out std_logic_vector(g_span-1 downto 0);
        cyc_o                   : out std_logic;
        dat_o                   : out std_logic_vector(g_width-1 downto 0);
        stb_o                   : out std_logic;
        we_o                    : out std_logic;
        
        -- signals internal to the chip: interface with other modules
        clk_i                   : in std_logic;
        reset_i                 : in std_logic;
        acam_ef1_i              : in std_logic;
        acam_ef2_i              : in std_logic;

        activate_acq_i          : in std_logic;
        deactivate_acq_i        : in std_logic;
        load_acam_config_i      : in std_logic;
        read_acam_config_i      : in std_logic;
        read_acam_status_i      : in std_logic;
        read_ififo1_i           : in std_logic;
        read_ififo2_i           : in std_logic;
        read_start01_i          : in std_logic;
        reset_acam_i            : in std_logic;
        acam_config_i           : in config_vector;
        
        acam_config_rdbk_o      : out config_vector;
        acam_status_o           : out std_logic_vector(g_width-1 downto 0);
        acam_ififo1_o           : out std_logic_vector(g_width-1 downto 0);
        acam_ififo2_o           : out std_logic_vector(g_width-1 downto 0);
        acam_start01_o          : out std_logic_vector(g_width-1 downto 0);
        acam_timestamp1_o       : out std_logic_vector(g_width-1 downto 0);
        acam_timestamp1_valid_o : out std_logic;
        acam_timestamp2_o       : out std_logic_vector(g_width-1 downto 0);
        acam_timestamp2_valid_o : out std_logic
    );
end data_engine;

----------------------------------------------------------------------------------------------------
--  architecture declaration for data_engine
----------------------------------------------------------------------------------------------------
architecture rtl of data_engine is

type engine_state_ty                is (active, inactive, get_stamp1, get_stamp2,
                                        wr_config, rdbk_config, rd_status, rd_ififo1, rd_ififo2, rd_start01, wr_reset);
signal engine_st, nxt_engine_st     : engine_state_ty;

signal acam_ef1                     : std_logic;
signal acam_ef2                     : std_logic;

signal acam_ack                     : std_logic;
signal acam_adr                     : std_logic_vector(7 downto 0);
signal acam_cyc                     : std_logic;
signal acam_stb                     : std_logic;
signal acam_we                      : std_logic;
signal acam_data_rd                 : std_logic_vector(g_width-1 downto 0);
signal acam_data_wr                 : std_logic_vector(g_width-1 downto 0);

signal clk                          : std_logic;
signal reset                        : std_logic;

signal activate_acq                 : std_logic;
signal deactivate_acq               : std_logic;
signal load_acam_config             : std_logic;
signal read_acam_config             : std_logic;
signal read_acam_status             : std_logic;
signal read_ififo1                  : std_logic;
signal read_ififo2                  : std_logic;
signal read_start01                 : std_logic;
signal reset_acam                   : std_logic;

signal config_adr_counter           : unsigned(7 downto 0);

signal acam_config                  : config_vector;
signal acam_config_rdbk             : config_vector;

signal acam_status                  : std_logic_vector(g_width-1 downto 0);
signal acam_ififo1                  : std_logic_vector(g_width-1 downto 0);
signal acam_ififo2                  : std_logic_vector(g_width-1 downto 0);
signal acam_start01                 : std_logic_vector(g_width-1 downto 0);

signal acam_timestamp1              : std_logic_vector(g_width-1 downto 0);
signal acam_timestamp1_valid        : std_logic;
signal acam_timestamp2              : std_logic_vector(g_width-1 downto 0);
signal acam_timestamp2_valid        : std_logic;

signal reset_word                   : std_logic_vector(g_width-1 downto 0);
signal reg4                         : std_logic_vector(g_width-1 downto 0);

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    data_engine_seq_fsm: process
    begin
        if reset ='1' then
            engine_st           <= inactive;
        else
            engine_st           <= nxt_engine_st;
        end if;
        wait until clk ='1';
    end process;
    
    data_engine_comb_fsm: process(engine_st, activate_acq, deactivate_acq, acam_ef1, acam_ef2,
                                    load_acam_config, read_acam_config, read_acam_status, 
                                    read_ififo1, read_ififo2, read_start01, reset_acam, 
                                    acam_ack, acam_adr)
    begin
    case engine_st is
        when inactive =>
            acam_cyc                <= '0';
            acam_stb                <= '0';
            acam_we                 <= '0';
            
            if activate_acq ='1'        then
                nxt_engine_st               <= active;
            elsif load_acam_config ='1' then
                nxt_engine_st               <= wr_config;
            elsif read_acam_config ='1' then
                nxt_engine_st               <= rdbk_config;
            elsif read_acam_status ='1' then
                nxt_engine_st               <= rd_status;
            elsif read_ififo1 ='1'      then
                nxt_engine_st               <= rd_ififo1;
            elsif read_ififo2 ='1'      then
                nxt_engine_st               <= rd_ififo2;
            elsif read_start01 ='1'     then
                nxt_engine_st               <= rd_start01;
            elsif reset_acam ='1'       then
                nxt_engine_st               <= wr_reset;
            else
                nxt_engine_st               <= inactive;
            end if;

        when active =>
            acam_cyc                <= '0';
            acam_stb                <= '0';
            acam_we                 <= '0';
            
            if deactivate_acq ='1'      then
                nxt_engine_st               <= inactive;
            elsif acam_ef1 ='0'         then
                nxt_engine_st               <= get_stamp1;
            elsif acam_ef2 ='0'         then
                nxt_engine_st               <= get_stamp2;
            else
                nxt_engine_st               <= active;
            end if;

        when get_stamp1 =>
            acam_cyc                <= '1';
            acam_stb                <= '1';
            acam_we                 <= '0';

            if acam_ack ='1' then
                if acam_ef2 ='0' then
                    nxt_engine_st   <= get_stamp2;
                elsif acam_ef1 ='0' then
                    nxt_engine_st   <= get_stamp1;
                else
                    nxt_engine_st   <= active;
                end if;
            else
                nxt_engine_st       <= get_stamp1;
            end if;
        
        when get_stamp2 =>
            acam_cyc                <= '1';
            acam_stb                <= '1';
            acam_we                 <= '0';

            if acam_ack ='1' then
                if acam_ef1 ='0' then
                    nxt_engine_st   <= get_stamp1;
                elsif acam_ef2 ='0' then
                    nxt_engine_st   <= get_stamp2;
                else
                    nxt_engine_st   <= active;
                end if;
            else
                nxt_engine_st       <= get_stamp2;
            end if;
        
        when wr_config =>
            acam_cyc                <= '1';
            acam_stb                <= '1';
            acam_we                 <= '1';
            
            if acam_ack ='1' and acam_adr =x"0E" then
                nxt_engine_st       <= inactive;
            else
                nxt_engine_st       <= wr_config;
            end if;
        
        when rdbk_config =>
            acam_cyc                <= '1';
            acam_stb                <= '1';
            acam_we                 <= '0';

            if acam_ack ='1' and acam_adr =x"0E" then
                nxt_engine_st       <= inactive;
            else
                nxt_engine_st       <= rdbk_config;
            end if;
        
        when rd_status =>
            acam_cyc                <= '1';
            acam_stb                <= '1';
            acam_we                 <= '0';

            if acam_ack ='1' then
                nxt_engine_st       <= inactive;
            else
                nxt_engine_st       <= rd_status;
            end if;
            
        when rd_ififo1 =>
            acam_cyc                <= '1';
            acam_stb                <= '1';
            acam_we                 <= '0';

            if acam_ack ='1' then
                nxt_engine_st       <= inactive;
            else
                nxt_engine_st       <= rd_ififo1;
            end if;
        
        when rd_ififo2 =>
            acam_cyc                <= '1';
            acam_stb                <= '1';
            acam_we                 <= '0';

            if acam_ack ='1' then
                nxt_engine_st       <= inactive;
            else
                nxt_engine_st       <= rd_ififo2;
            end if;
        
        when rd_start01 =>
            acam_cyc                <= '1';
            acam_stb                <= '1';
            acam_we                 <= '0';

            if acam_ack ='1' then
                nxt_engine_st       <= inactive;
            else
                nxt_engine_st       <= rd_start01;
            end if;
        
        when wr_reset =>
            acam_cyc                <= '1';
            acam_stb                <= '1';
            acam_we                 <= '1';

            if acam_ack ='1' then
                nxt_engine_st       <= inactive;
            else
                nxt_engine_st       <= wr_reset;
            end if;
        
        when others =>
            acam_cyc                <= '0';
            acam_stb                <= '0';
            acam_we                 <= '0';
            
            nxt_engine_st           <= inactive;
        end case;
    end process;
    
    address_generation: process(engine_st, config_adr_counter)
    begin
        case engine_st is
        when inactive =>
                        acam_adr    <= x"00";
        when active =>
                        acam_adr    <= x"00";
        when get_stamp1 =>
                        acam_adr    <= x"08";
        when get_stamp2 =>
                        acam_adr    <= x"09";
        when wr_config =>
                        acam_adr    <= std_logic_vector(config_adr_counter);
        when rdbk_config =>
                        acam_adr    <= std_logic_vector(config_adr_counter);
        when rd_status =>
                        acam_adr    <= x"0C";
        when rd_ififo1 =>
                        acam_adr    <= x"08";
        when rd_ififo2 =>
                        acam_adr    <= x"09";
        when rd_start01 =>
                        acam_adr    <= x"0A";
        when wr_reset =>
                        acam_adr    <= x"04";
        when others =>
                        acam_adr    <= x"00";
        end case;
    end process;
    
    config_adr: process             -- process to generate the valid addresses 
    begin                           -- for the ACAM config registers
        if reset ='1' then
            config_adr_counter      <= x"00";

        elsif load_acam_config ='1' or read_acam_config ='1' then
            config_adr_counter      <= x"00";
        
        elsif acam_ack ='1' then
            if config_adr_counter= x"0E" then
                config_adr_counter      <= x"0E";
            elsif config_adr_counter= x"0C" then
                config_adr_counter      <= x"0E";
            elsif config_adr_counter= x"07" then
                config_adr_counter      <= x"0B";
            else
                config_adr_counter      <= config_adr_counter + 1;
            end if;
        end if;
        wait until clk ='1';
    end process;

    data_config_decoding: process(acam_adr, engine_st, acam_config, reset_word)
    begin
        case acam_adr is
        when x"00" =>
            acam_data_wr             <= acam_config(0);
        when x"01" =>
            acam_data_wr             <= acam_config(1);
        when x"02" =>
            acam_data_wr             <= acam_config(2);
        when x"03" =>
            acam_data_wr             <= acam_config(3);
        when x"04" =>
            if engine_st = wr_reset then
                acam_data_wr             <= reset_word;
            else
                acam_data_wr             <= acam_config(4);
            end if;
        when x"05" =>
            acam_data_wr             <= acam_config(5);
        when x"06" =>
            acam_data_wr             <= acam_config(6);
        when x"07" =>
            acam_data_wr             <= acam_config(7);
        when x"0B" =>
            acam_data_wr             <= acam_config(8);
        when x"0C" =>
            acam_data_wr             <= acam_config(9);
        when x"0E" =>
            acam_data_wr             <= acam_config(10);
        when others =>
            acam_data_wr             <= (others =>'0');
        end case;
    end process;

    data_readback_decoding: process
    begin
        if reset ='1' then
            acam_config_rdbk(0)      <= (others =>'0');
            acam_config_rdbk(1)      <= (others =>'0');
            acam_config_rdbk(2)      <= (others =>'0');
            acam_config_rdbk(3)      <= (others =>'0');
            acam_config_rdbk(4)      <= (others =>'0');
            acam_config_rdbk(5)      <= (others =>'0');
            acam_config_rdbk(6)      <= (others =>'0');
            acam_config_rdbk(7)      <= (others =>'0');
            acam_config_rdbk(8)      <= (others =>'0');
            acam_config_rdbk(9)      <= (others =>'0');
            acam_config_rdbk(10)     <= (others =>'0');

            acam_ififo1              <= (others =>'0');
            acam_ififo2              <= (others =>'0');
            acam_start01             <= (others =>'0');
        elsif acam_cyc ='1' and acam_stb ='1' and acam_ack ='1' and acam_we ='0' then
            if acam_adr= x"00" then
                acam_config_rdbk(0)         <= acam_data_rd;
            end if;
            if acam_adr= x"01" then
                acam_config_rdbk(1)         <= acam_data_rd;
            end if;
            if acam_adr= x"02" then
                acam_config_rdbk(2)         <= acam_data_rd;
            end if;
            if acam_adr= x"03" then
                acam_config_rdbk(3)         <= acam_data_rd;
            end if;
            if acam_adr= x"04" then
                acam_config_rdbk(4)         <= acam_data_rd;
            end if;
            if acam_adr= x"05" then
                acam_config_rdbk(5)         <= acam_data_rd;
            end if;
            if acam_adr= x"06" then
                acam_config_rdbk(6)         <= acam_data_rd;
            end if;
            if acam_adr= x"07" then
                acam_config_rdbk(7)         <= acam_data_rd;
            end if;
            if acam_adr= x"0B" then
                acam_config_rdbk(8)         <= acam_data_rd;
            end if;
            if acam_adr= x"0C" then
                acam_config_rdbk(9)         <= acam_data_rd;
            end if;
            if acam_adr= x"0E" then
                acam_config_rdbk(10)        <= acam_data_rd;
            end if;

            if acam_adr= x"08" then
                acam_ififo1                 <= acam_data_rd;
            end if;
            if acam_adr= x"09" then
                acam_ififo2                 <= acam_data_rd;
            end if;
            if acam_adr= x"0A" then
                acam_start01                <= acam_data_rd;
            end if;
        end if;
        wait until clk ='1';
    end process;
    
    acam_timestamp1             <= acam_data_rd;
    acam_timestamp2             <= acam_data_rd;

    acam_timestamp1_valid       <= '1' when (acam_ack ='1' and engine_st = get_stamp1)
                                    else '0';
    acam_timestamp2_valid       <= '1' when (acam_ack ='1' and engine_st = get_stamp2)
                                    else '0';

    acam_status                 <= acam_config_rdbk(9);
    reg4                        <= acam_config(4);
    reset_word                  <= reg4(31 downto 24) & "01" & reg4(21 downto 0);

    -- inputs
    clk                         <= clk_i;
    reset                       <= reset_i;
    acam_ack                    <= ack_i;
    acam_data_rd                <= dat_i;
    acam_ef1                    <= acam_ef1_i;
    acam_ef2                    <= acam_ef2_i;
    
    activate_acq                <= activate_acq_i;
    deactivate_acq              <= deactivate_acq_i;
    load_acam_config            <= load_acam_config_i;
    read_acam_config            <= read_acam_config_i;
    read_acam_status            <= read_acam_status_i;
    read_ififo1                 <= read_ififo1_i;
    read_ififo2                 <= read_ififo2_i;
    read_start01                <= read_start01_i;
    reset_acam                  <= reset_acam_i;
    acam_config                 <= acam_config_i;
    
    --outputs
    adr_o                       <= x"000000" & acam_adr;
    cyc_o                       <= acam_cyc;
    dat_o                       <= acam_data_wr;
    stb_o                       <= acam_stb;
    we_o                        <= acam_we;
    
    acam_config_rdbk_o          <= acam_config_rdbk;
    acam_status_o               <= acam_status;
    acam_ififo1_o               <= acam_ififo1;
    acam_ififo2_o               <= acam_ififo2;
    acam_start01_o              <= acam_start01;
    
    acam_timestamp1_o           <= acam_timestamp1;
    acam_timestamp2_o           <= acam_timestamp2;

    acam_timestamp1_valid_o     <= acam_timestamp1_valid;
    acam_timestamp2_valid_o     <= acam_timestamp2_valid;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
