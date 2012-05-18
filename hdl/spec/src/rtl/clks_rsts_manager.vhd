--_________________________________________________________________________________________________
--                                                                                                |
--                                           |TDC core|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                       clks_rsts_manager                                        |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         clks_rsts_manager.vhd                                                             |
--                                                                                                |
-- Description  Independent block that uses the spec_clk_i to parameterize the TDC mezzanine PLL  |
--              that will be used by all the other blocks.                                        |
--              Includes input clk_i buffers for Xilinx Spartan6.                                 |
--                                                                                                |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
-- Date         05/2011                                                                           |
-- Version      v0.1                                                                              |
-- Depends on                                                                                     |
--                                                                                                |
----------------                                                                                  |
-- Last changes                                                                                   |
--     05/2011  v0.1  GP  First version                                                           |
--     04/2012  v0.2  EG  Added DFFs to the pll_sdi_o, pll_cs_o outputs                           |
--                        Changed completely the internal reset generation; now it depends        |
--                        on the pll_ld activation                                                |
--                        General revamping, comments added, signals renamed                      |
--                                                                                                |
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--                               GNU LESSER GENERAL PUBLIC LICENSE                                |
--                              ------------------------------------                              |
-- This source file is free software; you can redistribute it and/or modify it under the terms of |
-- the GNU Lesser General Public License as published by the Free Software Foundation; either     |
-- version 2.1 of the License, or (at your option) any later version.                             |
-- This source is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;       |
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.      |
-- See the GNU Lesser General Public License for more details.                                    |
-- You should have received a copy of the GNU Lesser General Public License along with this       |
-- source; if not, download it from http://www.gnu.org/licenses/lgpl-2.1.html                     |
---------------------------------------------------------------------------------------------------


--=================================================================================================
--                                       Libraries & Packages
--=================================================================================================

-- Standard library
library IEEE;
use IEEE.STD_LOGIC_1164.all; -- std_logic definitions
use IEEE.NUMERIC_STD.all;    -- conversion functions-- Specific library
-- Specific libraries
library work;
use work.tdc_core_pkg.all;   -- definitions of types, constants, entities
library UNISIM;
use UNISIM.vcomponents.all;


--=================================================================================================
--                            Entity declaration for clks_rsts_manager
--=================================================================================================

entity clks_rsts_manager is
  generic
    (nb_of_reg              : integer := 68;
     values_for_simulation  : boolean := FALSE);
  port
  -- INPUTS
    (spec_clk_i             : in std_logic;
     acam_refclk_i          : in std_logic;
     tdc_clk_p_i            : in std_logic;
     tdc_clk_n_i            : in std_logic;

     gnum_rst_i             : in std_logic;

     pll_ld_i               : in std_logic;  -- PLL lock detect
     pll_refmon_i           : in std_logic;
     pll_sdo_i              : in std_logic;
     pll_status_i           : in std_logic;  -- not used

  -- OUTPUTS
     acam_refclk_r_edge_p_o : out std_logic;
     internal_rst_o         : out std_logic;

     pll_cs_o               : out std_logic;
     pll_dac_sync_o         : out std_logic; -- not used
     pll_sdi_o              : out std_logic;
     pll_sclk_o             : out std_logic;

     spec_clk_o             : out std_logic;
     tdc_clk_o              : out std_logic);

end clks_rsts_manager;


--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of clks_rsts_manager is

  subtype t_wd        is std_logic_vector(15 downto 0);
  subtype t_byte      is std_logic_vector(7 downto 0);
  type t_instr        is array (nb_of_reg-1 downto 0) of t_wd;
  type t_stream       is array (nb_of_reg-1 downto 0) of t_byte;
  type t_pll_init_st  is (start, sending_instruction, sending_data, rest, done);

-- The PLL circuit AD9516-4 needs to be configured through 68 registers. The values and addresses
-- are obtained from a dedicated Analog Devices software and from the datasheet.
  constant REG_000 : t_byte := x"18"; 
  constant REG_001 : t_byte := x"00";
  constant REG_002 : t_byte := x"10";
  constant REG_003 : t_byte := x"C3";
  constant REG_004 : t_byte := x"00";

  constant REG_010 : t_byte := x"7C";
  constant REG_011 : t_byte := x"01";
  constant REG_012 : t_byte := x"00";
  constant REG_013 : t_byte := x"03";
  constant REG_014 : t_byte := x"09";
  constant REG_015 : t_byte := x"00";
  constant REG_016 : t_byte := x"04";
  constant REG_017 : t_byte := x"00";
  constant REG_018 : t_byte := x"07";
  constant REG_019 : t_byte := x"00";
  constant REG_01A : t_byte := x"00";
  constant REG_01B : t_byte := x"00";
  constant REG_01C : t_byte := x"02";
  constant REG_01D : t_byte := x"00";
  constant REG_01E : t_byte := x"00";
  constant REG_01F : t_byte := x"0E";

  constant REG_0A0 : t_byte := x"01";
  constant REG_0A1 : t_byte := x"00";
  constant REG_0A2 : t_byte := x"00";
  constant REG_0A3 : t_byte := x"01";
  constant REG_0A4 : t_byte := x"00";
  constant REG_0A5 : t_byte := x"00";
  constant REG_0A6 : t_byte := x"01";
  constant REG_0A7 : t_byte := x"00";
  constant REG_0A8 : t_byte := x"00";
  constant REG_0A9 : t_byte := x"01";
  constant REG_0AA : t_byte := x"00";
  constant REG_0AB : t_byte := x"00";

  constant REG_0F0 : t_byte := x"0A";
  constant REG_0F1 : t_byte := x"0A";
  constant REG_0F2 : t_byte := x"0A";
  constant REG_0F3 : t_byte := x"0A";
  constant REG_0F4 : t_byte := x"0A";
  constant REG_0F5 : t_byte := x"0A";

  constant REG_140 : t_byte := x"4A";
  constant REG_141 : t_byte := x"5A";
  constant REG_142 : t_byte := x"43";
  constant REG_143 : t_byte := x"42";

  constant REG_190 : t_byte := x"00";
  constant REG_191 : t_byte := x"80";
  constant REG_192 : t_byte := x"00";
  constant REG_193 : t_byte := x"00";
  constant REG_194 : t_byte := x"80";
  constant REG_195 : t_byte := x"00";
  constant REG_196 : t_byte := x"00";
  constant REG_197 : t_byte := x"80";
  constant REG_198 : t_byte := x"00";

  constant REG_199 : t_byte := x"22";
  constant REG_19A : t_byte := x"00";
  constant REG_19B : t_byte := x"11";
  constant REG_19C : t_byte := x"00";
  constant REG_19D : t_byte := x"00";
  constant REG_19E : t_byte := x"22";
  constant REG_19F : t_byte := x"00";

  constant REG_1A0 : t_byte := x"11";
  constant REG_1A1 : t_byte := x"20";
  constant REG_1A2 : t_byte := x"00";
  constant REG_1A3 : t_byte := x"00";

  constant REG_1E0 : t_byte := x"00";
  constant REG_1E1 : t_byte := x"02";

  constant REG_230 : t_byte := x"00";
  constant REG_231 : t_byte := x"00";
  constant REG_232 : t_byte := x"01";

  constant SIM_RST : std_logic_vector(31 downto 0):= x"00000400";
  constant SYN_RST : std_logic_vector(31 downto 0):= x"00004E20";
-- this value may still need adjustment according to the dispersion
-- in the performance of the PLL observed during the production tests

  signal pll_init_st, nxt_pll_init_st             : t_pll_init_st;
  signal config_reg                               : t_stream;
  signal address                                  : t_instr;

  signal spec_clk_buf, tdc_clk_buf                : std_logic;

  signal acam_refclk_r                            : std_logic_vector(2 downto 0);
  signal pll_sclk, spec_clk, tdc_clk, internal_rst: std_logic;
  signal pll_ld_synch, internal_rst_synch         : std_logic_vector (1 downto 0);

  signal bit_being_sent                           : std_logic;
  signal word_being_sent                          : t_wd;
  signal bit_index                                : integer range 15 downto 0;
  signal byte_index                               : integer range nb_of_reg-1 downto 0;

  signal cs_n                                     : std_logic;


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin


---------------------------------------------------------------------------------------------------
--                              Clock input buffer instantiations                                --
---------------------------------------------------------------------------------------------------  

  tdc_clk125_ibuf : IBUFDS
    generic map 
      (DIFF_TERM    => false, -- Differential Termination
       IBUF_LOW_PWR => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
       IOSTANDARD   => "DEFAULT")
    port map
      (O  => tdc_clk_buf,     -- Buffer output
       I  => tdc_clk_p_i,     -- Diff_p buffer input (connect directly to top-level port)
       IB => tdc_clk_n_i);    -- Diff_n buffer input (connect directly to top-level port)

  tdc_clk125_gbuf : BUFG
    port map
      (O => tdc_clk,
       I => tdc_clk_buf);

  spec_clk_ibuf : IBUFG
    port map
      (I => spec_clk_i,
       O => spec_clk_buf);

  spec_clk_gbuf : BUFG
    port map
      (O => spec_clk,
       I => spec_clk_buf);

  --  --  --  --  --  --  --  --
  spec_clk_o <= spec_clk;
  tdc_clk_o  <= tdc_clk;


---------------------------------------------------------------------------------------------------
--                                    General Internal Reset                                     --
--------------------------------------------------------------------------------------------------- 
-- The following processes generate a general internal reset signal for all the rest of the core.
-- This internal reset is triggered by the reset signal coming from the GNUM chip. The idea is to
-- keep the internal reset asserted until the clock signal received from the PLL is stable.

---------------------------------------------------------------------------------------------------
-- Synchronous process PLL_LD_synchronizer: Synchronization of the pll_ld_i input to the spec_clk,
-- using a set of 2 registers.
  FD_RXD_synchronizer: process (spec_clk)
  begin
    if rising_edge (spec_clk) then
      if gnum_rst_i = '1' then
        pll_ld_synch   <= (others => '0');
      else
        pll_ld_synch   <= pll_ld_synch(0) & pll_ld_i;
      end if;
    end if;
  end process;

---------------------------------------------------------------------------------------------------
-- Synchronous process Internal_rst_generation: Generation of a reset signal for as long as the PLL
-- is not locked. As soon as the pll_ld is received the internal reset is released.
-- Note that the level of the pll_ld signal rather than its rising edge is used, as the in case of
-- a gnum_rst during operation with the pll already locked the pll_ld will remain active and no
-- edge will appear.
  Internal_rst_generation: process (spec_clk)
  begin
    if rising_edge (spec_clk) then
      if gnum_rst_i = '1' then
        internal_rst     <= '1';
      else
        if pll_ld_synch(1) = '1' then
          internal_rst   <= '0';
        else
          internal_rst   <= '1';
        end if;
      end if;
    end if;
  end process;

---------------------------------------------------------------------------------------------------
-- Synchronous process internal_rst_synchronizer: Synchronization of the internal_rst signal to the
-- tdc_clk, using a set of 2 registers.
  internal_rst_synchronizer: process (tdc_clk)
  begin
    if rising_edge (tdc_clk) then
      internal_rst_synch <= internal_rst_synch(0) & internal_rst;
    end if;
  end process;

  internal_rst_o <= internal_rst_synch(1);



---------------------------------------------------------------------------------------------------
--                            Processes for initialization of the PLL                            --
--------------------------------------------------------------------------------------------------- 

---------------------------------------------------------------------------------------------------
  pll_initialization_seq: process (spec_clk)
  begin
    if rising_edge (spec_clk) then
      if gnum_rst_i ='1' then
        pll_init_st     <= start;
      else
        pll_init_st     <= nxt_pll_init_st;
      end if;
    end if;
  end process;

---------------------------------------------------------------------------------------------------
  pll_initialization_comb: process (pll_init_st, byte_index, bit_index, pll_sclk)
  begin
    case pll_init_st is

     --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when start =>
       -----------------------------------
        cs_n                  <= '1';
       -----------------------------------
        if pll_sclk ='1' then
          nxt_pll_init_st     <= sending_instruction;
        else
          nxt_pll_init_st     <= start;
        end if;

     --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --        
      when sending_instruction =>
       -----------------------------------
          cs_n                <= '0';
       -----------------------------------
          if bit_index = 0 and pll_sclk = '1' then
            nxt_pll_init_st   <= sending_data;
          else
            nxt_pll_init_st   <= sending_instruction;
          end if;

     --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when sending_data =>
       -----------------------------------
          cs_n                <= '0';
       -----------------------------------

          if bit_index = 0 and pll_sclk = '1' then
            nxt_pll_init_st   <= rest;
          else
             nxt_pll_init_st  <= sending_data;
         end if;

     --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when rest =>
       -----------------------------------
          cs_n                <= '1';
       -----------------------------------
          if pll_sclk = '1' then
            if byte_index = 0 then
              nxt_pll_init_st <= done;
            else
              nxt_pll_init_st <= sending_instruction;
            end if;
          else
            nxt_pll_init_st   <= rest;
          end if;

     --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when done =>
       -----------------------------------
            cs_n              <= '1';
       -----------------------------------
            nxt_pll_init_st   <= done;

     --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when others =>
       -----------------------------------
            cs_n              <= '1';
       -----------------------------------
            nxt_pll_init_st   <= start;

        end case;
    end process;


---------------------------------------------------------------------------------------------------
  index_control: process (spec_clk)
  begin
    if rising_edge (spec_clk) then

      if gnum_rst_i = '1' then
        bit_index     <= 15;
      elsif cs_n = '1' then
        bit_index     <= 15;
      elsif pll_sclk = '1' then
        if bit_index = 0 then
          bit_index   <= 7;
        else
          bit_index   <= bit_index -1;
        end if;
      end if;
    
      if gnum_rst_i = '1' then
        byte_index    <= nb_of_reg -1;
      elsif pll_init_st = rest and pll_sclk = '1' then
        if byte_index = 0 then
          byte_index  <= nb_of_reg-1;
        else
          byte_index  <= byte_index -1;
        end if;
      end if;
    end if;
  end process;

---------------------------------------------------------------------------------------------------    
  pll_sclk_generator: process (spec_clk) -- transitions take place on the falling edge of sclk
  begin
    if rising_edge (spec_clk) then
      if gnum_rst_i ='1' then
        pll_sclk    <= '0';
      else
        pll_sclk    <= not(pll_sclk);
      end if;
    end if;
  end process;

--  --  --  --  --  --  --  --
  bit_being_sent    <= word_being_sent(bit_index);
  word_being_sent   <= address(byte_index)  when pll_init_st = sending_instruction
                                              else x"00" & config_reg(byte_index);

---------------------------------------------------------------------------------------------------    
  Output_regs: process (spec_clk)
  begin
    if rising_edge (spec_clk) then
      if gnum_rst_i = '1' then
        pll_cs_o    <= '1';
        pll_sdi_o   <= '0';
      else
        if pll_sclk = '1' then
          pll_cs_o  <= cs_n;
          pll_sdi_o <= bit_being_sent;
        end if;
      end if;
    end if;
  end process;

  pll_sclk_o      <= pll_sclk;


---------------------------------------------------------------------------------------------------
--            Assignement of the values to be sent for the configurations of the PLL             --
--------------------------------------------------------------------------------------------------- 
-- According to the datasheet the register 232 should be written last to validate the transfer
-- from the buffer to the valid registers.
-- The 16-bit instruction word indicates always a write cycle of byte.

-- -- -- -- -- -- -- -- -- -- -- -- -- --
  address(0)     <= x"0232";
  address(1)     <= x"0000";
  address(2)     <= x"0001";
  address(3)     <= x"0002";
  address(4)     <= x"0003";
  address(5)     <= x"0004";
  --------------------------
  address(6)     <= x"0010";
  address(7)     <= x"0011";
  address(8)     <= x"0012";
  address(9)     <= x"0013";
  address(10)    <= x"0014";
  address(11)    <= x"0015";
  address(12)    <= x"0016";
  address(13)    <= x"0017";
  address(14)    <= x"0018";
  address(15)    <= x"0019";
  address(16)    <= x"001A";
  address(17)    <= x"001B";
  address(18)    <= x"001C";
  address(19)    <= x"001D";
  address(20)    <= x"001E";
  address(21)    <= x"001F";
  --------------------------
  address(22)    <= x"00A0";
  address(23)    <= x"00A1";
  address(24)    <= x"00A2";
  address(25)    <= x"00A3";
  address(26)    <= x"00A4";
  address(27)    <= x"00A5";
  address(28)    <= x"00A6";
  address(29)    <= x"00A7";
  address(30)    <= x"00A8";
  address(31)    <= x"00A9";
  address(32)    <= x"00AA";
  address(33)    <= x"00AB";
  --------------------------
  address(34)    <= x"00F0";
  address(35)    <= x"00F1";
  address(36)    <= x"00F2";
  address(37)    <= x"00F3";
  address(38)    <= x"00F4";
  address(39)    <= x"00F5";
  --------------------------
  address(40)    <= x"0140";
  address(41)    <= x"0141";
  address(42)    <= x"0142";
  address(43)    <= x"0143";
  --------------------------
  address(44)    <= x"0190";
  address(45)    <= x"0191";
  address(46)    <= x"0192";
  address(47)    <= x"0193";
  address(48)    <= x"0194";
  address(49)    <= x"0195";
  address(50)    <= x"0196";
  address(51)    <= x"0197";
  address(52)    <= x"0198";
  --------------------------
  address(53)    <= x"0199";
  address(54)    <= x"019A";
  address(55)    <= x"019B";
  address(56)    <= x"019C";
  address(57)    <= x"019D";
  address(58)    <= x"019E";
  address(59)    <= x"019F";
  --------------------------
  address(60)    <= x"01A0";
  address(61)    <= x"01A1";
  address(62)    <= x"01A2";
  address(63)    <= x"01A3";
  --------------------------
  address(64)    <= x"01E0";
  address(65)    <= x"01E1";
  --------------------------
  address(66)    <= x"0230";
  address(67)    <= x"0231";

-- -- -- -- -- -- -- -- -- -- -- -- -- --
  config_reg(0)  <= REG_232;
  config_reg(1)  <= REG_000;
  config_reg(2)  <= REG_001;
  config_reg(3)  <= REG_002;
  config_reg(4)  <= REG_003;
  config_reg(5)  <= REG_004;
  --------------------------
  config_reg(6)  <= REG_010;
  config_reg(7)  <= REG_011;
  config_reg(8)  <= REG_012;
  config_reg(9)  <= REG_013;
  config_reg(10) <= REG_014;
  config_reg(11) <= REG_015;
  config_reg(12) <= REG_016;
  config_reg(13) <= REG_017;
  config_reg(14) <= REG_018;
  config_reg(15) <= REG_019;
  config_reg(16) <= REG_01A;
  config_reg(17) <= REG_01B;
  config_reg(18) <= REG_01C;
  config_reg(19) <= REG_01D;
  config_reg(20) <= REG_01E;
  config_reg(21) <= REG_01F;
  --------------------------
  config_reg(22) <= REG_0A0;
  config_reg(23) <= REG_0A1;
  config_reg(24) <= REG_0A2;
  config_reg(25) <= REG_0A3;
  config_reg(26) <= REG_0A4;
  config_reg(27) <= REG_0A5;
  config_reg(28) <= REG_0A6;
  config_reg(29) <= REG_0A7;
  config_reg(30) <= REG_0A8;
  config_reg(31) <= REG_0A9;
  config_reg(32) <= REG_0AA;
  config_reg(33) <= REG_0AB;
  --------------------------
  config_reg(34) <= REG_0F0;
  config_reg(35) <= REG_0F1;
  config_reg(36) <= REG_0F2;
  config_reg(37) <= REG_0F3;
  config_reg(38) <= REG_0F4;
  config_reg(39) <= REG_0F5;
  --------------------------
  config_reg(40) <= REG_140;
  config_reg(41) <= REG_141;
  config_reg(42) <= REG_142;
  config_reg(43) <= REG_143;
  --------------------------
  config_reg(44) <= REG_190;
  config_reg(45) <= REG_191;
  config_reg(46) <= REG_192;
  config_reg(47) <= REG_193;
  config_reg(48) <= REG_194;
  config_reg(49) <= REG_195;
  config_reg(50) <= REG_196;
  config_reg(51) <= REG_197;
  config_reg(52) <= REG_198;
  --------------------------
  config_reg(53) <= REG_199;
  config_reg(54) <= REG_19A;
  config_reg(55) <= REG_19B;
  config_reg(56) <= REG_19C;
  config_reg(57) <= REG_19D;
  config_reg(58) <= REG_19E;
  config_reg(59) <= REG_19F;
  --------------------------
  config_reg(60) <= REG_1A0;
  config_reg(61) <= REG_1A1;
  config_reg(62) <= REG_1A2;
  config_reg(63) <= REG_1A3;
  --------------------------
  config_reg(64) <= REG_1E0;
  config_reg(65) <= REG_1E1;
  --------------------------
  config_reg(66) <= REG_230;
  config_reg(67) <= REG_231;
-- -- -- -- -- -- -- -- -- -- -- -- -- --


---------------------------------------------------------------------------------------------------
--                               ACAM Reference Clock Synchronizer                               --
--------------------------------------------------------------------------------------------------- 
  acam_refclk_synchronizer: process (tdc_clk)
  begin
    if rising_edge (tdc_clk) then
      if internal_rst_synch(1) = '1' then
        acam_refclk_r <= (others=>'0');
      else
        acam_refclk_r <= acam_refclk_i & acam_refclk_r(2 downto 1);
      end if;
    end if;
  end process;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --   
  acam_refclk_r_edge_p_o    <= acam_refclk_r(1) and not(acam_refclk_r(0));


end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
