----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : Clock and reset management unit (clk_rst_managr.vhd)
--  author      : G. Penacoba
--  date        : May 2011
--  version     : Revision 1
--  description : independent block that uses the spec clk to parameterize
--                the TDC mezzanine PLL that will be used by all the other
--                blocks. Includes input clk buffers for Xilinx Spartan6.
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

library UNISIM;
use UNISIM.vcomponents.all;

----------------------------------------------------------------------------------------------------
--  entity declaration for clk_rst_managr
----------------------------------------------------------------------------------------------------
entity clk_rst_managr is
    generic(
        nb_of_reg               : integer:=563
    );
    port(
        acam_refclk_i           : in std_logic;
        pll_ld_i                : in std_logic;
        pll_refmon_i            : in std_logic;
        pll_sdo_i               : in std_logic;
        pll_status_i            : in std_logic;
        gnum_reset_i            : in std_logic;
        spec_clk_i              : in std_logic;
        tdc_clk_p_i             : in std_logic;
        tdc_clk_n_i             : in std_logic;
        
        acam_refclk_o           : out std_logic;
        general_reset_o         : out std_logic;
        pll_cs_o                : out std_logic;
        pll_dac_sync_o          : out std_logic;
        pll_sdi_o               : out std_logic;
        pll_sclk_o              : out std_logic;
        spec_clk_o              : out std_logic;
        tdc_clk_o               : out std_logic
    );
end clk_rst_managr;

----------------------------------------------------------------------------------------------------
--  architecture declaration for clk_rst_managr
----------------------------------------------------------------------------------------------------
architecture rtl of clk_rst_managr is

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

subtype t_byte          is std_logic_vector(7 downto 0);
type t_instr            is array (1 downto 0) of t_byte;
type t_stream           is array (nb_of_reg-1 downto 0) of t_byte;

type t_pll_init_st      is (start, sending_instruction, sending_data, done);

-- the PLL circuit AD9516-4 needs to be configured through 68 registers
-- the values and addresses are obtained from a dedicated Analog Devices
-- software and from the datasheet.

constant reg_000        : t_byte:=x"18";
constant reg_001        : t_byte:=x"00";
constant reg_002        : t_byte:=x"10";
constant reg_003        : t_byte:=x"C3";
constant reg_004        : t_byte:=x"00";

constant reg_010        : t_byte:=x"7C";
constant reg_011        : t_byte:=x"01";
constant reg_012        : t_byte:=x"00";
constant reg_013        : t_byte:=x"03";
constant reg_014        : t_byte:=x"09";
constant reg_015        : t_byte:=x"00";
constant reg_016        : t_byte:=x"04";
constant reg_017        : t_byte:=x"00";
constant reg_018        : t_byte:=x"06";
constant reg_019        : t_byte:=x"00";
constant reg_01A        : t_byte:=x"00";
constant reg_01B        : t_byte:=x"00";
constant reg_01C        : t_byte:=x"02";
constant reg_01D        : t_byte:=x"00";
constant reg_01E        : t_byte:=x"00";
constant reg_01F        : t_byte:=x"0E";

constant reg_0A0        : t_byte:=x"01";
constant reg_0A1        : t_byte:=x"00";
constant reg_0A2        : t_byte:=x"00";
constant reg_0A3        : t_byte:=x"01";
constant reg_0A4        : t_byte:=x"00";
constant reg_0A5        : t_byte:=x"00";
constant reg_0A6        : t_byte:=x"01";
constant reg_0A7        : t_byte:=x"00";
constant reg_0A8        : t_byte:=x"00";
constant reg_0A9        : t_byte:=x"01";
constant reg_0AA        : t_byte:=x"00";
constant reg_0AB        : t_byte:=x"00";

constant reg_0F0        : t_byte:=x"0A";
constant reg_0F1        : t_byte:=x"0A";
constant reg_0F2        : t_byte:=x"0A";
constant reg_0F3        : t_byte:=x"0A";
constant reg_0F4        : t_byte:=x"0A";
constant reg_0F5        : t_byte:=x"0A";

constant reg_140        : t_byte:=x"4A";
constant reg_141        : t_byte:=x"5A";
constant reg_142        : t_byte:=x"43";
constant reg_143        : t_byte:=x"42";

constant reg_190        : t_byte:=x"00";
constant reg_191        : t_byte:=x"80";
constant reg_192        : t_byte:=x"00";
constant reg_193        : t_byte:=x"00";
constant reg_194        : t_byte:=x"80";
constant reg_195        : t_byte:=x"00";
constant reg_196        : t_byte:=x"00";
constant reg_197        : t_byte:=x"80";
constant reg_198        : t_byte:=x"00";

constant reg_199        : t_byte:=x"22";
constant reg_19A        : t_byte:=x"00";
constant reg_19B        : t_byte:=x"11";
constant reg_19C        : t_byte:=x"00";
constant reg_19D        : t_byte:=x"00";
constant reg_19E        : t_byte:=x"22";
constant reg_19F        : t_byte:=x"00";

constant reg_1A0        : t_byte:=x"11";
constant reg_1A1        : t_byte:=x"20";
constant reg_1A2        : t_byte:=x"00";
constant reg_1A3        : t_byte:=x"00";

constant reg_1E0        : t_byte:=x"00";
constant reg_1E1        : t_byte:=x"02";

constant reg_230        : t_byte:=x"00";
constant reg_231        : t_byte:=x"00";
constant reg_232        : t_byte:=x"01";

-- the 16-bit instruction word indicates a write cycle
-- in streaming mode starting in address 231
constant instr_wd_msb   : t_byte:=x"62";
constant instr_wd_lsb   : t_byte:=x"31";

constant blank          : t_byte:=x"00";

signal blank_registers  : boolean;
signal pll_init_st      : t_pll_init_st;
signal nxt_pll_init_st  : t_pll_init_st;

signal stream           : t_stream:=(others => blank);
signal instruction      : t_instr;

signal acam_refclk_buf  : std_logic;
signal spec_clk_buf     : std_logic;
signal tdc_clk_buf      : std_logic;

signal acam_refclk      : std_logic;
signal pll_sclk         : std_logic;
signal spec_clk         : std_logic;
signal tdc_clk          : std_logic;

signal bit_being_sent   : std_logic;
signal byte_being_sent  : t_byte;
signal bit_index        : integer range 7 downto 0;
signal byte_index       : integer range nb_of_reg-1 downto 0;

signal silly_altern     : std_logic;
signal gnum_reset       : std_logic;
signal gral_incr        : std_logic;
signal inv_reset        : std_logic;
signal cs               : std_logic;


----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    --Clock input buffer instantiations
    -----------------------------------
    tdc_clk125_ibuf : IBUFDS
    generic map (
        DIFF_TERM    => false,            -- Differential Termination
        IBUF_LOW_PWR => true,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        IOSTANDARD   => "DEFAULT"
    )
    port map (
        I  => tdc_clk_p_i,                -- Diff_p buffer input (connect directly to top-level port)
        IB => tdc_clk_n_i,                -- Diff_n buffer input (connect directly to top-level port)
        O  => tdc_clk_buf                 -- Buffer output
    );

    tdc_clk125_gbuf : BUFG
    port map (
        I => tdc_clk_buf,
        O => tdc_clk
    );

    spec_clk_ibuf : IBUFG
    port map (
        I => spec_clk_i,
        O => spec_clk_buf
    );

    spec_clk_gbuf : BUFG
    port map (
        I => spec_clk_buf,
        O => spec_clk
    );

--    acam_refclk_ibuf : IBUFG
--    port map (
--        I => acam_refclk_i,
--        O => acam_refclk_buf
--    );
--
--    acam_refclk_gbuf : BUFG
--    port map (
--        O => acam_refclk,
--        I => acam_refclk_buf
--    );
    acam_refclk     <= acam_refclk_i;
    
    general_poreset: incr_counter
    port map(
        clk                 => spec_clk,
        end_value           => x"0000007D",     -- 125 clk ticks
        incr                => gral_incr,
        reset               => gnum_reset,
        
        count_done          => inv_reset,
        current_value       => open
    );
    
    silly: process
    begin
        if gnum_reset ='1' then
            silly_altern        <= '0';
        else
            silly_altern        <= not(silly_altern);
        end if;
        wait until spec_clk ='1';
    end process;
    
    gral_reset_incr: process(silly_altern, tdc_clk)
    begin
        if silly_altern ='0' then
            gral_incr       <= '0';
        elsif rising_edge(tdc_clk) then
            gral_incr       <= '1';
        end if;
    end process;
    
    -- Processes for initialization of the PLL
    ------------------------------------------
    pll_initialization_seq: process
    begin
        if gnum_reset ='1' then
            pll_init_st     <= start;
        else
            pll_init_st     <= nxt_pll_init_st;
        end if;
        wait until spec_clk ='1';
    end process;
    
    pll_initialization_comb: process(pll_init_st, byte_index, bit_index, pll_sclk)
    begin
        case pll_init_st is
        when start =>
            cs                  <= '1';
            
            if pll_sclk ='1' then
                nxt_pll_init_st     <= sending_instruction;
            else
                nxt_pll_init_st     <= start;
            end if;
        
        when sending_instruction =>
            cs                  <= '0';
            
            if byte_index = 0 
            and bit_index = 0 
            and pll_sclk = '1' then
                nxt_pll_init_st <= sending_data;
            else
                nxt_pll_init_st <= sending_instruction;
            end if;
        
        when sending_data =>
            cs                  <= '0';
            
            if byte_index = 0 
            and bit_index = 0 
            and pll_sclk = '1' then
                nxt_pll_init_st <= done;
            else
                nxt_pll_init_st <= sending_data;
            end if;

        when done =>
            cs                  <= '1';
            
            nxt_pll_init_st     <= done;
            
        when others =>
            cs                  <= '1';
            
            nxt_pll_init_st     <= start;
        end case;
    end process;
    
    index_control: process
    begin
        if gnum_reset ='1' then
            bit_index   <= 7;
        elsif pll_sclk ='1' 
        and cs ='0' then
            if bit_index = 0 then
                bit_index   <= 7;
            else
                bit_index   <= bit_index -1;
            end if;
        end if;
    
        if gnum_reset ='1' then
            byte_index  <= 1;
        elsif pll_sclk ='1' 
        and cs ='0' 
        and bit_index = 0 then
            if byte_index = 0 then
                byte_index  <= nb_of_reg-1;
            else
                byte_index  <= byte_index -1;
            end if;
        end if;
        wait until spec_clk ='1';
    end process;
    
    pll_sclk_generator: process
    begin
        if gnum_reset ='1' then
            pll_sclk        <= '0';
        else
            pll_sclk        <= not(pll_sclk);
        end if;
        wait until spec_clk ='1';
    end process;
    
    bit_being_sent      <= byte_being_sent(bit_index);
    
    byte_being_sent     <= instruction(byte_index)  when pll_init_st = sending_instruction
--                            else blank              when blank_registers
                            else stream(byte_index);
                            
--    blank_registers     <= TRUE when    (5   < byte_index and byte_index < 17)
--                                or      (32  < byte_index and byte_index < 161)
--                                or      (172 < byte_index and byte_index < 241)
--                                or      (246 < byte_index and byte_index < 321)
--                                or      (324 < byte_index and byte_index < 401)
--                                or      (420 < byte_index and byte_index < 481)
--                                or      (482 < byte_index and byte_index < 561)
--                                else FALSE;

    -- Assignement of the values to be sent for the configurations of the PLL
    -------------------------------------------------------------------------
    instruction(1)      <= instr_wd_msb;
    instruction(0)      <= instr_wd_lsb;

    -- according to the datasheet the register 232 should be written last
    -- to validate the transfer from the buffer to the valid registers
    stream(0)           <= reg_232;
    stream(1)           <= reg_000;
    stream(2)           <= reg_001;
    stream(3)           <= reg_002;
    stream(4)           <= reg_003;
    stream(5)           <= reg_004;
    
    stream(17)          <= reg_010;
    stream(18)          <= reg_011;
    stream(19)          <= reg_012;
    stream(20)          <= reg_013;
    stream(21)          <= reg_014;
    stream(22)          <= reg_015;
    stream(23)          <= reg_016;
    stream(24)          <= reg_017;
    stream(25)          <= reg_018;
    stream(26)          <= reg_019;
    stream(27)          <= reg_01A;
    stream(28)          <= reg_01B;
    stream(29)          <= reg_01C;
    stream(30)          <= reg_01D;
    stream(31)          <= reg_01E;
    stream(32)          <= reg_01F;

    stream(161)         <= reg_0A0;
    stream(162)         <= reg_0A1;
    stream(163)         <= reg_0A2;
    stream(164)         <= reg_0A3;
    stream(165)         <= reg_0A4;
    stream(166)         <= reg_0A5;
    stream(167)         <= reg_0A6;
    stream(168)         <= reg_0A7;
    stream(169)         <= reg_0A8;
    stream(170)         <= reg_0A9;
    stream(171)         <= reg_0AA;
    stream(172)         <= reg_0AB;

    stream(241)         <= reg_0F0;
    stream(242)         <= reg_0F1;
    stream(243)         <= reg_0F2;
    stream(244)         <= reg_0F3;
    stream(245)         <= reg_0F4;
    stream(246)         <= reg_0F5;

    stream(321)         <= reg_140;
    stream(322)         <= reg_141;
    stream(323)         <= reg_142;
    stream(324)         <= reg_143;

    stream(401)         <= reg_190;
    stream(402)         <= reg_191;
    stream(403)         <= reg_192;
    stream(404)         <= reg_193;
    stream(405)         <= reg_194;
    stream(406)         <= reg_195;
    stream(407)         <= reg_196;
    stream(408)         <= reg_197;
    stream(409)         <= reg_198;

    stream(410)         <= reg_199;
    stream(411)         <= reg_19A;
    stream(412)         <= reg_19B;
    stream(413)         <= reg_19C;
    stream(414)         <= reg_19D;
    stream(415)         <= reg_19E;
    stream(416)         <= reg_19F;

    stream(417)         <= reg_1A0;
    stream(418)         <= reg_1A1;
    stream(419)         <= reg_1A2;
    stream(420)         <= reg_1A3;

    stream(481)         <= reg_1E0;
    stream(482)         <= reg_1E1;

    stream(561)         <= reg_230;
    stream(562)         <= reg_231;
    
    -- Input and Output signals
    ---------------------------    
    gnum_reset          <= gnum_reset_i;
    
    acam_refclk_o       <= acam_refclk;
    general_reset_o     <= not(inv_reset);
    pll_cs_o            <= cs;
    pll_sdi_o           <= bit_being_sent;
    pll_sclk_o          <= pll_sclk;
    spec_clk_o          <= spec_clk;
    tdc_clk_o           <= tdc_clk;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
