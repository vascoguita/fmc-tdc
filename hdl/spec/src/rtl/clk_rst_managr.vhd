----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : Clock and reset management unit (clk_rst_managr.vhd)
--  author      : G. Penacoba
--  date        : May 2011
--  version     : Revision 2
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
        nb_of_reg               : integer:=68;
        values_for_simulation   : boolean:=FALSE
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

subtype t_wd            is std_logic_vector(15 downto 0);
subtype t_byte          is std_logic_vector(7 downto 0);
type t_instr            is array (nb_of_reg-1 downto 0) of t_wd;
type t_stream           is array (nb_of_reg-1 downto 0) of t_byte;

type t_pll_init_st      is (start, sending_instruction, sending_data, rest, done);

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
constant reg_018        : t_byte:=x"07";
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

constant sim_reset      : std_logic_vector(31 downto 0):=x"00000400";
constant syn_reset      : std_logic_vector(31 downto 0):=x"00004E20";


signal pll_init_st              : t_pll_init_st;
signal nxt_pll_init_st          : t_pll_init_st;

signal config_reg               : t_stream;
signal address                  : t_instr;

signal acam_refclk_buf          : std_logic;
signal spec_clk_buf             : std_logic;
signal tdc_clk_buf              : std_logic;
        
signal acam_refclk              : std_logic;
signal pll_sclk                 : std_logic;
signal spec_clk                 : std_logic;
signal tdc_clk                  : std_logic;

signal bit_being_sent           : std_logic;
signal word_being_sent          : t_wd;
signal bit_index                : integer range 15 downto 0;
signal byte_index               : integer range nb_of_reg-1 downto 0;

signal silly_altern             : std_logic;
signal gnum_reset               : std_logic;
signal gral_incr                : std_logic;
signal gral_reset_duration      : std_logic_vector(31 downto 0);
signal inv_reset                : std_logic;
signal cs                       : std_logic;

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
        O  => tdc_clk_buf,                -- Buffer output
        I  => tdc_clk_p_i,                -- Diff_p buffer input (connect directly to top-level port)
        IB => tdc_clk_n_i                 -- Diff_n buffer input (connect directly to top-level port)
    );

    tdc_clk125_gbuf : BUFG
    port map (
        O => tdc_clk,
        I => tdc_clk_buf
    );

    spec_clk_ibuf : IBUFG
    port map (
        I => spec_clk_i,
        O => spec_clk_buf
    );

    spec_clk_gbuf : BUFG
    port map (
        O => spec_clk,
        I => spec_clk_buf
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
        end_value           => gral_reset_duration,
        incr                => gral_incr,
        reset               => gnum_reset,
        
        count_done          => inv_reset,
        current_value       => open
    );
    
    gral_reset_duration          <= sim_reset when values_for_simulation
                                    else syn_reset;
    
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
            
            if bit_index = 0 
            and pll_sclk = '1' then
                nxt_pll_init_st <= sending_data;
            else
                nxt_pll_init_st <= sending_instruction;
            end if;
        
        when sending_data =>
            cs                  <= '0';
            
            if bit_index = 0 
            and pll_sclk = '1' then
                nxt_pll_init_st <= rest;
            else
                nxt_pll_init_st <= sending_data;
            end if;

        when rest =>
            cs                  <= '1';
            
            if pll_sclk = '1' then
                if byte_index = 0 then
                    nxt_pll_init_st     <= done;
                else
                    nxt_pll_init_st     <= sending_instruction;
                end if;
            else
                    nxt_pll_init_st     <= rest;
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
            bit_index   <= 15;
        elsif cs ='1' then
            bit_index   <= 15;
        elsif pll_sclk ='1' then
            if bit_index = 0 then
                bit_index   <= 7;
            else
                bit_index   <= bit_index -1;
            end if;
        end if;
    
        if gnum_reset ='1' then
            byte_index  <= nb_of_reg -1;
        elsif pll_init_st = rest and pll_sclk ='1' then
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
    
    bit_being_sent      <= word_being_sent(bit_index);
    
    word_being_sent     <= address(byte_index)  when pll_init_st = sending_instruction
                            else x"00" & config_reg(byte_index);

    -- Assignement of the values to be sent for the configurations of the PLL
    -------------------------------------------------------------------------
    -- according to the datasheet the register 232 should be written last
    -- to validate the transfer from the buffer to the valid registers

    -- the 16-bit instruction word indicates always a write cycle of byte
    address(0)           <= x"0232";
    address(1)           <= x"0000";
    address(2)           <= x"0001";
    address(3)           <= x"0002";
    address(4)           <= x"0003";
    address(5)           <= x"0004";

    address(6)           <= x"0010";
    address(7)           <= x"0011";
    address(8)           <= x"0012";
    address(9)           <= x"0013";
    address(10)          <= x"0014";
    address(11)          <= x"0015";
    address(12)          <= x"0016";
    address(13)          <= x"0017";
    address(14)          <= x"0018";
    address(15)          <= x"0019";
    address(16)          <= x"001A";
    address(17)          <= x"001B";
    address(18)          <= x"001C";
    address(19)          <= x"001D";
    address(20)          <= x"001E";
    address(21)          <= x"001F";

    address(22)          <= x"00A0";
    address(23)          <= x"00A1";
    address(24)          <= x"00A2";
    address(25)          <= x"00A3";
    address(26)          <= x"00A4";
    address(27)          <= x"00A5";
    address(28)          <= x"00A6";
    address(29)          <= x"00A7";
    address(30)          <= x"00A8";
    address(31)          <= x"00A9";
    address(32)          <= x"00AA";
    address(33)          <= x"00AB";

    address(34)          <= x"00F0";
    address(35)          <= x"00F1";
    address(36)          <= x"00F2";
    address(37)          <= x"00F3";
    address(38)          <= x"00F4";
    address(39)          <= x"00F5";

    address(40)          <= x"0140";
    address(41)          <= x"0141";
    address(42)          <= x"0142";
    address(43)          <= x"0143";

    address(44)          <= x"0190";
    address(45)          <= x"0191";
    address(46)          <= x"0192";
    address(47)          <= x"0193";
    address(48)          <= x"0194";
    address(49)          <= x"0195";
    address(50)          <= x"0196";
    address(51)          <= x"0197";
    address(52)          <= x"0198";

    address(53)          <= x"0199";
    address(54)          <= x"019A";
    address(55)          <= x"019B";
    address(56)          <= x"019C";
    address(57)          <= x"019D";
    address(58)          <= x"019E";
    address(59)          <= x"019F";

    address(60)          <= x"01A0";
    address(61)          <= x"01A1";
    address(62)          <= x"01A2";
    address(63)          <= x"01A3";

    address(64)          <= x"01E0";
    address(65)          <= x"01E1";

    address(66)          <= x"0230";
    address(67)          <= x"0231";
    
    config_reg(0)        <= reg_232;
    config_reg(1)        <= reg_000;
    config_reg(2)        <= reg_001;
    config_reg(3)        <= reg_002;
    config_reg(4)        <= reg_003;
    config_reg(5)        <= reg_004;

    config_reg(6)        <= reg_010;
    config_reg(7)        <= reg_011;
    config_reg(8)        <= reg_012;
    config_reg(9)        <= reg_013;
    config_reg(10)       <= reg_014;
    config_reg(11)       <= reg_015;
    config_reg(12)       <= reg_016;
    config_reg(13)       <= reg_017;
    config_reg(14)       <= reg_018;
    config_reg(15)       <= reg_019;
    config_reg(16)       <= reg_01A;
    config_reg(17)       <= reg_01B;
    config_reg(18)       <= reg_01C;
    config_reg(19)       <= reg_01D;
    config_reg(20)       <= reg_01E;
    config_reg(21)       <= reg_01F;

    config_reg(22)       <= reg_0A0;
    config_reg(23)       <= reg_0A1;
    config_reg(24)       <= reg_0A2;
    config_reg(25)       <= reg_0A3;
    config_reg(26)       <= reg_0A4;
    config_reg(27)       <= reg_0A5;
    config_reg(28)       <= reg_0A6;
    config_reg(29)       <= reg_0A7;
    config_reg(30)       <= reg_0A8;
    config_reg(31)       <= reg_0A9;
    config_reg(32)       <= reg_0AA;
    config_reg(33)       <= reg_0AB;

    config_reg(34)       <= reg_0F0;
    config_reg(35)       <= reg_0F1;
    config_reg(36)       <= reg_0F2;
    config_reg(37)       <= reg_0F3;
    config_reg(38)       <= reg_0F4;
    config_reg(39)       <= reg_0F5;

    config_reg(40)       <= reg_140;
    config_reg(41)       <= reg_141;
    config_reg(42)       <= reg_142;
    config_reg(43)       <= reg_143;

    config_reg(44)       <= reg_190;
    config_reg(45)       <= reg_191;
    config_reg(46)       <= reg_192;
    config_reg(47)       <= reg_193;
    config_reg(48)       <= reg_194;
    config_reg(49)       <= reg_195;
    config_reg(50)       <= reg_196;
    config_reg(51)       <= reg_197;
    config_reg(52)       <= reg_198;

    config_reg(53)       <= reg_199;
    config_reg(54)       <= reg_19A;
    config_reg(55)       <= reg_19B;
    config_reg(56)       <= reg_19C;
    config_reg(57)       <= reg_19D;
    config_reg(58)       <= reg_19E;
    config_reg(59)       <= reg_19F;

    config_reg(60)       <= reg_1A0;
    config_reg(61)       <= reg_1A1;
    config_reg(62)       <= reg_1A2;
    config_reg(63)       <= reg_1A3;

    config_reg(64)       <= reg_1E0;
    config_reg(65)       <= reg_1E1;

    config_reg(66)       <= reg_230;
    config_reg(67)       <= reg_231;
    
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
