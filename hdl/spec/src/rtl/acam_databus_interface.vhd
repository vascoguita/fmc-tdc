----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : acam chip data interface (acam_databus_interface)
--  author      : G. Penacoba
--  date        : May 2011
--  version     : Revision 1
--  description : interface with the acam chip pins for data acquisition and register configuration.
--                acts as a wishbone slave.
--  dependencies:
--  references  :
--  modified by :
--
----------------------------------------------------------------------------------------------------
--  last changes: Added registers for the outputs.
----------------------------------------------------------------------------------------------------
--  to do:
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

----------------------------------------------------------------------------------------------------
--  entity declaration for acam_databus_interface
----------------------------------------------------------------------------------------------------
entity acam_databus_interface is
    generic(
        g_span                  : integer :=32;
        g_width                 : integer :=32
    );
    port(
        -- signals external to the chip: interface with acam
        ef1_i                   : in std_logic;
        ef2_i                   : in std_logic;
        lf1_i                   : in std_logic;
        lf2_i                   : in std_logic;

        data_bus_io             : inout std_logic_vector(27 downto 0);
        address_o               : out std_logic_vector(3 downto 0);
        cs_n_o                  : out std_logic;
        oe_n_o                  : out std_logic;
        rd_n_o                  : out std_logic;
        wr_n_o                  : out std_logic;

        -- signals internal to the chip: interface with other modules
        acam_ef1_o              : out std_logic;
        acam_ef1_meta_o         : out std_logic;
        acam_ef2_o              : out std_logic;
        acam_ef2_meta_o         : out std_logic;
        acam_lf1_o              : out std_logic;
        acam_lf2_o              : out std_logic;

        -- wishbone slave signals internal to the chip: interface with other modules
        clk                     : in std_logic;
        reset_i                 : in std_logic;

        adr_i                   : in std_logic_vector(g_span-1 downto 0);
        cyc_i                   : in std_logic;
        dat_i                   : in std_logic_vector(g_width-1 downto 0);
        stb_i                   : in std_logic;
        we_i                    : in std_logic;

        ack_o                   : out std_logic;
        dat_o                   : out std_logic_vector(g_width-1 downto 0)
    );
end acam_databus_interface;

----------------------------------------------------------------------------------------------------
--  architecture declaration for acam_databus_interface
----------------------------------------------------------------------------------------------------
architecture rtl of acam_databus_interface is

type t_acam_interface                   is (IDLE, RD_START, RD_FETCH, RD_ACK, WR_START, WR_PUSH, WR_ACK);

signal acam_data_st, nxt_acam_data_st     : t_acam_interface;

signal ef1_r                    : std_logic_vector(1 downto 0);
signal ef2_r                    : std_logic_vector(1 downto 0);
signal lf1_r                    : std_logic_vector(1 downto 0);
signal lf2_r                    : std_logic_vector(1 downto 0);

signal reset                    : std_logic;
signal adr                      : std_logic_vector(g_span-1 downto 0);
signal cyc                      : std_logic;
signal stb                      : std_logic;
signal we                       : std_logic;
signal cs                       : std_logic;
signal cs_extend                : std_logic;
signal rd                       : std_logic;
signal rd_extend                : std_logic;
signal wr                       : std_logic;
signal wr_extend                : std_logic;
signal wr_remove                : std_logic;
signal ack                      : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin
    
    -- the following state machine implements the slave side of the Wishbone interface
    -- and converts the signals for the Acam proprietary bus interface
    
    databus_access_seq_fsm: process
    begin
        if reset ='1' then
            acam_data_st        <= IDLE;
        else
            acam_data_st        <= nxt_acam_data_st;
        end if;
        wait until clk ='1';
    end process;
    
    databus_access_comb_fsm: process(acam_data_st, stb, cyc, we)
    begin
    case acam_data_st is
        when IDLE =>
            ack                 <= '0';
            cs_extend           <= '0';
            rd_extend           <= '0';
            wr_extend           <= '0';
            wr_remove           <= '0';
            if stb ='1' and cyc ='1' then
                if we = '1' then
                    nxt_acam_data_st    <= WR_START;
                else
                    nxt_acam_data_st    <= RD_START;
                end if;
            else
                nxt_acam_data_st    <= IDLE;
            end if;
            
        when RD_START =>
            ack                 <= '0';
            cs_extend           <= '1';
            rd_extend           <= '1';
            wr_extend           <= '0';
            wr_remove           <= '0';
            
            nxt_acam_data_st    <= RD_FETCH;
            
        when RD_FETCH =>
            ack                 <= '0';
            cs_extend           <= '1';
            rd_extend           <= '1';
            wr_extend           <= '0';
            wr_remove           <= '0';
            
            nxt_acam_data_st    <= RD_ACK;

        when RD_ACK =>
            ack                 <= '1';
            cs_extend           <= '0';
            rd_extend           <= '0';
            wr_extend           <= '0';
            wr_remove           <= '0';

            nxt_acam_data_st    <= IDLE;
            
        when WR_START =>
            ack                 <= '0';
            cs_extend           <= '1';
            rd_extend           <= '0';
            wr_extend           <= '1';
            wr_remove           <= '0';
            
            nxt_acam_data_st    <= WR_PUSH;
            
        when WR_PUSH =>
            ack                 <= '0';
            cs_extend           <= '0';
            rd_extend           <= '0';
            wr_extend           <= '0';
            wr_remove           <= '1';
            
            nxt_acam_data_st    <= WR_ACK;
            
        when WR_ACK =>
            ack                 <= '1';
            cs_extend           <= '0';
            rd_extend           <= '0';
            wr_extend           <= '0';
            wr_remove           <= '0';

            nxt_acam_data_st    <= IDLE;
            
        when others =>
            ack                 <= '0';
            cs_extend           <= '0';
            rd_extend           <= '0';
            wr_extend           <= '0';
            wr_remove           <= '0';

            nxt_acam_data_st    <= IDLE;
    end case;
    end process;
    
    cs          <= ((stb and cyc)               or cs_extend) and not(ack);
    rd          <= ((stb and cyc and not(we))   or rd_extend) and not(ack);
    wr          <= ((stb and cyc and we)        or wr_extend) and not(wr_remove) and not(ack);      -- the wr signal
                                                                                                    -- has to be
                                                                                                    -- removed to 
                                                                                                    -- respect the
                                                                                                    -- Acam specs
    
    -- inputs from other blocks    
    reset                       <= reset_i;

    adr                         <= adr_i;
    cyc                         <= cyc_i;
    data_bus_io                 <= dat_i(27 downto 0) when we='1' else (others =>'Z');
    stb                         <= stb_i;
    we                          <= we_i;
    
    -- outputs to other blocks
    acam_ef1_o                  <= ef1_r(0);        -- this signal is perfectly synchronized
    acam_ef1_meta_o             <= ef1_r(1);        -- this signal could be metastable but
                                                    -- not when we plan to use it...    
    acam_ef2_o                  <= ef2_r(0);
    acam_ef2_meta_o             <= ef2_r(1);
    
    acam_lf1_o                  <= lf1_r(0);
    acam_lf2_o                  <= lf2_r(0);
    ack_o                       <= ack;
    dat_o                       <= ef1_r(0) & ef2_r(0) & lf1_r(0) & lf2_r(0) & data_bus_io;

    -- inputs from the ACAM
    
    input_registers: process
    begin
        if reset ='1' then
            ef1_r                       <= (others =>'1');
            ef2_r                       <= (others =>'1');
            lf1_r                       <= (others =>'0');
            lf2_r                       <= (others =>'0');
        else
            ef1_r                       <= ef1_i & ef1_r(1);
            ef2_r                       <= ef2_i & ef2_r(1);
            lf1_r                       <= lf1_i & lf1_r(1);
            lf2_r                       <= lf2_i & lf2_r(1);
        end if;
        wait until clk ='1';
    end process;

    -- outputs to the ACAM
    address_o                   <= adr(3 downto 0);
    
    output_registers: process
    begin
        if reset ='1' then
            cs_n_o                      <= '1';
            rd_n_o                      <= '1';
            wr_n_o                      <= '1';
        else
            cs_n_o                      <= not(cs);
            rd_n_o                      <= not(rd);
            wr_n_o                      <= not(wr);
        end if;
        wait until clk ='1';
    end process;

    oe_n_o                      <= '1';

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
