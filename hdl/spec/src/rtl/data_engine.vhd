----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : data polling engine (data_engine)
--  author      : G. Penacoba
--  date        : June 2011
--  version     : Revision 1
--  description : engine polling data continuouly from the acam interface provided the FIFO is not 
--                empty. acts as a wishbone master.
--  dependencies:
--  references  :
--  modified by :
--
----------------------------------------------------------------------------------------------------
--  last changes:
----------------------------------------------------------------------------------------------------
--  to do: REPLACE THE POLLING BY INTERRUPT FROM THE EMPTY SIGNALS. ADD RESET ACAM COMMAND
--        AND GET STATUS COMMAND
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
        g_width             : integer :=32
    );
    port(
        -- wishbone master signals internal to the chip: interface with other modules
        ack_i                   : in std_logic;
        dat_i                   : in std_logic_vector(g_width-1 downto 0);

        adr_o                   : out std_logic_vector(19 downto 0);
        cyc_o                   : out std_logic;
        dat_o                   : out std_logic_vector(g_width-1 downto 0);
        stb_o                   : out std_logic;
        we_o                    : out std_logic;
        
        -- signals internal to the chip: interface with other modules
        acam_config_reg_i       : in config_vector;
        clk_i                   : in std_logic;
        load_acam_config_i      : in std_logic;
        one_hz_p_i              : in std_logic;
        reset_i                 : in std_logic;
        
        acam_start01_o          : out std_logic_vector(16 downto 0);
        acam_timestamp_o        : out std_logic_vector(28 downto 0);
        acam_timestamp_valid_o  : out std_logic
    );
end data_engine;

----------------------------------------------------------------------------------------------------
--  architecture declaration for data_engine
----------------------------------------------------------------------------------------------------
architecture rtl of data_engine is

type engine_state_ty                is (idle, wr_config, rest_wr, rd_timestamp, rest_rd);
signal engine_st, nxt_engine_st     : engine_state_ty;

signal ef1                          : std_logic;
signal ef2                          : std_logic;

signal clk                          : std_logic;
signal reset                        : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    data_engine_seq_fsm: process
    begin
        if reset ='1' then
            engine_st           <= idle;
        else
            engine_st           <= nxt_engine_st;
        end if;
        wait until clk ='1';
    end process;
    
--    data_engine_comb_fsm: process
--    begin
--    case engine_st is
--        when waiting =>
--            

    -- inputs
    clk                 <= clk_i;
    reset               <= reset_i;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
