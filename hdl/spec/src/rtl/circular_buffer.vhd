----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : RAM circular buffer for timestamp storage (circular_buffer)
--  author      : G. Penacoba
--  date        : Oct 2011
--  version     : Revision 1
--  description : contains the RAM block (512 x 32) and the wishbone slave interfaces.
--                From the side of the timestamps coming from the ACAM the wishbone interface is
--                classic. On the side of the DMA access from the PCI, the wishbone interface is
--                pipelined.
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
--  entity declaration for circular_buffer
----------------------------------------------------------------------------------------------------
entity circular_buffer is
    generic(
        g_width             : integer :=32
    );
    port(
        -- wishbone classic slave signals to interface RAM with the internal modules providing the timestamps
        class_clk_i             : in std_logic;
        class_reset_i           : in std_logic;

        class_adr_i             : in std_logic_vector(19 downto 0);
        class_cyc_i             : in std_logic;
        class_dat_i             : in std_logic_vector(4*g_width-1 downto 0);
        class_stb_i             : in std_logic;
        class_we_i              : in std_logic;

        class_ack_o             : out std_logic;
        class_dat_o             : out std_logic_vector(4*g_width-1 downto 0);

        -- wishbone pipelined slave signals to interface RAM with gnum core for DMA access from PCI-e
        pipe_clk_i              : in std_logic;
        pipe_reset_i            : in std_logic;

        pipe_adr_i              : in std_logic_vector(19 downto 0);
        pipe_cyc_i              : in std_logic;
        pipe_dat_i              : in std_logic_vector(g_width-1 downto 0);
        pipe_stb_i              : in std_logic;
        pipe_we_i               : in std_logic;

        pipe_ack_o              : out std_logic;
        pipe_dat_o              : out std_logic_vector(g_width-1 downto 0);
        pipe_stall_o            : out std_logic
    );
end circular_buffer;

----------------------------------------------------------------------------------------------------
--  architecture declaration for circular_buffer
----------------------------------------------------------------------------------------------------
architecture rtl of circular_buffer is

component blk_mem_gen_v6_2
    port(
    clka    : in std_logic;
    addra   : in std_logic_vector(6 downto 0);
    dina    : in std_logic_vector(127 downto 0);
    wea     : in std_logic_vector(0 downto 0);
    douta   : out std_logic_vector(127 downto 0);

    clkb    : in std_logic;
    addrb   : in std_logic_vector(8 downto 0);
    dinb    : in std_logic_vector(31 downto 0);
    web     : in std_logic_vector(0 downto 0);
    doutb   : out std_logic_vector(31 downto 0)
    );
end component;

type t_wb_classic_mem_interface             is (idle, acknowledge);
type t_wb_pipelined_mem_interface           is (idle, mem_access, mem_access_and_acknowledge, acknowledge);

signal wb_classic_st, nxt_wb_classic_st     : t_wb_classic_mem_interface;
signal wb_pipelined_st, nxt_wb_pipelined_st : t_wb_pipelined_mem_interface;

signal class_ack                            : std_logic;
signal class_adr                            : std_logic_vector(6 downto 0);
signal class_clk                            : std_logic;
signal class_cyc                            : std_logic;
signal class_data_rd                        : std_logic_vector(4*g_width-1 downto 0);
signal class_data_wr                        : std_logic_vector(4*g_width-1 downto 0);
signal class_reset                          : std_logic;
signal class_stb                            : std_logic;
signal class_we                             : std_logic_vector(0 downto 0);

signal pipe_ack                             : std_logic;
signal pipe_adr                             : std_logic_vector(8 downto 0);
signal pipe_clk                             : std_logic;
signal pipe_cyc                             : std_logic;
signal pipe_data_rd                         : std_logic_vector(g_width-1 downto 0);
signal pipe_data_wr                         : std_logic_vector(g_width-1 downto 0);
signal pipe_reset                           : std_logic;
signal pipe_stb                             : std_logic;
signal pipe_we                              : std_logic_vector(0 downto 0);

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

--    classic_seq_fsm: process
--    begin
--        if class_reset ='1' then
--            wb_classic_st        <= idle;
--        else
--            wb_classic_st        <= nxt_wb_classic_st;
--        end if;
--        wait until class_clk ='1';
--    end process;
--    
--    classic_comb_fsm: process(wb_classic_st, class_stb, class_cyc)
--    begin
--    case wb_classic_st is
--        when idle =>
--            class_ack           <= '0';
--
--            if class_stb ='1' and class_cyc ='1' then
--                nxt_wb_classic_st    <= acknowledge;
--            else
--                nxt_wb_classic_st    <= idle;
--            end if;
--            
--        when acknowledge =>
--            class_ack           <= '1';
--            
--            nxt_wb_classic_st   <= idle;
--            
--        when others =>
--            class_ack           <= '0';
--
--            nxt_wb_classic_st   <= idle;
--    end case;
--    end process;

    wishbone_classic_compatible_interface: process
    begin
        if class_reset ='1' then
            class_ack           <= '0';
        else
            class_ack           <= class_stb and class_cyc;
        end if;
        wait until class_clk ='1';
    end process;

    pipelined_seq_fsm: process
    begin
        if pipe_reset ='1' then
            wb_pipelined_st        <= idle;
        else
            wb_pipelined_st        <= nxt_wb_pipelined_st;
        end if;
        wait until pipe_clk ='1';
    end process;
    
    pipelined_comb_fsm: process(wb_pipelined_st, pipe_stb, pipe_cyc)
    begin
    case wb_pipelined_st is
        when idle =>
            pipe_ack            <= '0';

            if pipe_stb ='1' and pipe_cyc ='1' then
                nxt_wb_pipelined_st     <= mem_access;
            else
                nxt_wb_pipelined_st     <= idle;
            end if;
            
        when mem_access =>
            pipe_ack            <= '0';

            if pipe_stb ='1' and pipe_cyc ='1' then
                nxt_wb_pipelined_st     <= mem_access_and_acknowledge;
            else
                nxt_wb_pipelined_st     <= acknowledge;
            end if;
            
        when mem_access_and_acknowledge =>
            pipe_ack            <= '1';

            if pipe_stb ='1' and pipe_cyc ='1' then
                nxt_wb_pipelined_st     <= mem_access_and_acknowledge;
            else
                nxt_wb_pipelined_st     <= acknowledge;
            end if;
            
        when acknowledge =>
            pipe_ack            <= '1';

            if pipe_stb ='1' and pipe_cyc ='1' then
                nxt_wb_pipelined_st     <= mem_access;
            else
                nxt_wb_pipelined_st     <= idle;
            end if;

        when others =>
            pipe_ack            <= '0';

            nxt_wb_pipelined_st <= idle;
    end case;
    end process;
    
    memory_block: blk_mem_gen_v6_2
    port map(
        clka        => class_clk,
        addra       => class_adr,
        dina        => class_data_wr,
        wea         => class_we,
        douta       => class_data_rd,
        
        clkb        => pipe_clk,
        addrb       => pipe_adr,
        dinb        => pipe_data_wr,
        web         => pipe_we,
        doutb       => pipe_data_rd
    );

    -- inputs from other blocks    
    class_clk                   <= class_clk_i;
    class_reset                 <= class_reset_i;

    class_adr                   <= class_adr_i(6 downto 0);
    class_cyc                   <= class_cyc_i;
    class_data_wr               <= class_dat_i;
    class_stb                   <= class_stb_i;
    class_we(0)                 <= class_we_i;
    
    pipe_clk                    <= pipe_clk_i;
    pipe_reset                  <= pipe_reset_i;

    pipe_adr                    <= pipe_adr_i(8 downto 0);
    pipe_cyc                    <= pipe_cyc_i;
    pipe_data_wr                <= pipe_dat_i;
    pipe_stb                    <= pipe_stb_i;
    pipe_we(0)                  <= pipe_we_i;
    
    -- outputs to other blocks
    class_ack_o                 <= class_ack;
    class_dat_o                 <= class_data_rd;
    
    pipe_ack_o                  <= pipe_ack;
    pipe_dat_o                  <= pipe_data_rd;
    pipe_stall_o                <= '0';

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
