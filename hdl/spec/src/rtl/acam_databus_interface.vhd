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
--  last changes:
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
        g_width             : integer :=32
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

        -- wishbone slave signals internal to the chip: interface with other modules
        clk_i                   : in std_logic;
        reset_i                 : in std_logic;

        adr_i                   : in std_logic_vector(19 downto 0);
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

type t_acam_interface                   is (idle, rd_start, read, rd_ack, wr_start, write, wr_ack);

signal acam_data_st, nxt_acam_data_st     : t_acam_interface;

signal ef1                      : std_logic;
signal ef2                      : std_logic;
signal lf1                      : std_logic;
signal lf2                      : std_logic;

signal clk                      : std_logic;
signal reset                    : std_logic;
signal adr                      : std_logic_vector(19 downto 0);
signal cyc                      : std_logic;
signal stb                      : std_logic;
signal we                       : std_logic;
signal cs                       : std_logic;
signal rd                       : std_logic;
signal wr                       : std_logic;
signal ack                      : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    databus_access_seq_fsm: process
    begin
        if reset ='1' then
            acam_data_st        <= idle;
        else
            acam_data_st        <= nxt_acam_data_st;
        end if;
        wait until clk ='1';
    end process;
    
    databus_access_comb_fsm: process(acam_data_st, stb, cyc, we)
    begin
    case acam_data_st is
        when idle =>
            ack                 <= '0';
            cs                  <= '0';
            rd                  <= '0';
            wr                  <= '0';
            if stb ='1' and cyc ='1' then
                if we = '1' then
                    nxt_acam_data_st    <= wr_start;
                else
                    nxt_acam_data_st    <= rd_start;
                end if;
            else
                nxt_acam_data_st    <= idle;
            end if;
            
        when rd_start =>
            ack                 <= '0';
            cs                  <= '1';
            rd                  <= '1';
            wr                  <= '0';
            
            nxt_acam_data_st    <= read;
            
        when read =>
            ack                 <= '0';
            cs                  <= '1';
            rd                  <= '1';
            wr                  <= '0';
            
            nxt_acam_data_st    <= rd_ack;

        when rd_ack =>
            ack                 <= '1';
            cs                  <= '1';
            rd                  <= '1';
            wr                  <= '0';

            nxt_acam_data_st    <= idle;
            
        when wr_start =>
            ack                 <= '0';
            cs                  <= '1';
            rd                  <= '0';
            wr                  <= '1';
            
            nxt_acam_data_st    <= write;
            
        when write =>
            ack                 <= '0';
            cs                  <= '1';
            rd                  <= '0';
            wr                  <= '1';
            
            nxt_acam_data_st    <= wr_ack;
            
        when wr_ack =>
            ack                 <= '1';
            cs                  <= '0';
            rd                  <= '0';
            wr                  <= '0';

            nxt_acam_data_st    <= idle;
            
        when others =>
            ack                 <= '0';
            cs                  <= '0';
            rd                  <= '0';
            wr                  <= '0';

            nxt_acam_data_st    <= idle;
    end case;
    end process;
    
    -- inputs from other blocks    
    clk                         <= clk_i;
    reset                       <= reset_i;

    adr                         <= adr_i;
    cyc                         <= cyc_i;
    data_bus_io                 <= dat_i(27 downto 0) when we='1' else (others =>'Z');
    stb                         <= stb_i;
    we                          <= we_i;
    
    -- outputs to other blocks
    ack_o                       <= ack;
    dat_o                       <= ef1 & ef2 & lf1 & lf2 & data_bus_io;

    -- inputs from the ACAM
    ef1                         <= ef1_i;
    ef2                         <= ef2_i;
    lf1                         <= lf1_i;
    lf2                         <= lf2_i;

    -- outputs to the ACAM
    address_o                   <= adr(3 downto 0);
    cs_n_o                      <= not(cs);
    oe_n_o                      <= '1';
    rd_n_o                      <= not(rd);
    wr_n_o                      <= not(wr);

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
