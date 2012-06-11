--_________________________________________________________________________________________________
--                                                                                                |
--                                           |TDC core|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                        data_formatting                                         |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         data_formatting.vhd                                                               |
--                                                                                                |
-- Description  timestamp data formatting.                                                        |
--              formats the timestamp coming from the acam plus the coarse timing                 |
--              plus the UTC time and writes it to the circular buffer                            |
--                                                                                                |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
--              Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
-- Date         04/2012                                                                           |
-- Version      v0.11                                                                             |
-- Depends on                                                                                     |
--                                                                                                |
----------------                                                                                  |
-- Last changes                                                                                   |
--     05/2011  v0.1  GP  First version                                                           |
--     04/2012  v0.11 EG  Revamping; Comments added, signals renamed                              |
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
-- Specific library
library work;
use work.tdc_core_pkg.all;   -- definitions of types, constants, entities


--=================================================================================================
--                            Entity declaration for data_formatting
--=================================================================================================
entity data_formatting is
  port
  -- INPUTS
     -- Signal from the clk_rst_manager
    (clk_i                   : in std_logic; -- 125 MHz clk
     rst_i                   : in std_logic; -- general reset

     -- Signals from the circular_buffer unit: WISHBONE classic
     tstamp_wr_wb_ack_i      : in std_logic; -- tstamp writing WISHBONE acknowledge
     tstamp_wr_dat_i         : in std_logic_vector(127 downto 0); -- not used

     -- Signals from the data_engine unit
     acam_tstamp1_i          : in std_logic_vector(31 downto 0);   -- 32 bits tstamp to be treated and stored;
                                                                 -- includes ef1 & ef2 & lf1 & lf2 & 28 bits tstamp from FIFO1
     acam_tstamp1_ok_p_i     : in std_logic; -- tstamp2 valid indicator
     acam_tstamp2_i          : in std_logic_vector(31 downto 0);   -- 32 bits tstamp to be treated and stored;
                                                                 -- includes ef1 & ef2 & lf1 & lf2 & 28 bits tstamp from FIFO2
     acam_tstamp2_ok_p_i     : in std_logic; -- tstamp2 valid indicator

     -- Signals from the reg_ctrl unit
     dacapo_c_rst_p_i        : in std_logic; -- instruction from PCIe to clear dacapo flag

     -- Signals from the one_hz_gen unit
     local_utc_i             : in std_logic_vector(31 downto 0);   -- local UTC time

     -- Signals from the start_retrig_ctrl unit
     roll_over_incr_recent_i : in std_logic;
     clk_i_cycles_offset_i   : in std_logic_vector(31 downto 0);
     roll_over_nb_i          : in std_logic_vector(31 downto 0);
     retrig_nb_offset_i      : in std_logic_vector(31 downto 0);

     -- Signal from the one_hz_generator unit
     one_hz_p_i              : in std_logic;


  -- OUTPUTS
     -- Signals to the circular_buffer unit: WISHBONE classic
     tstamp_wr_wb_cyc_o      : out std_logic;                      -- tstamp writing WISHBONE cycle
     tstamp_wr_wb_stb_o      : out std_logic;                      -- tstamp writing WISHBONE strobe
     tstamp_wr_wb_we_o       : out std_logic;                      -- tstamp writing WISHBONE write enable
     tstamp_wr_wb_adr_o      : out std_logic_vector(7 downto 0);   -- WISHBONE adr to write to
     tstamp_wr_dat_o         : out std_logic_vector(127 downto 0); -- tstamp to write

     -- Signal to the irq_generator unit
     tstamp_wr_p_o           : out std_logic;                      -- pulse upon storage of a new tstamp

     -- Signal to the reg_ctrl unit
     wr_index_o              : out std_logic_vector(31 downto 0)); -- index of last byte written
                                                                   -- note that the index is provided
                                                                   -- #bytes, as the PCIe expects
                                                                   -- (not in #128-bits-words)

end data_formatting;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of data_formatting is

  constant c_MULTIPLY_BY_SIXTEEN                              : std_logic_vector(3 downto 0) := x"0";
  -- ACAM timestamp fields
  signal acam_channel                                         : std_logic_vector(2 downto 0);
  signal acam_slope, acam_fifo_ef, acam_fifo_lf               : std_logic;
  signal acam_fine_timestamp                                  : std_logic_vector(16 downto 0);
  signal acam_start_nb                                        : std_logic_vector(7 downto 0);
  -- timestamp manipulations
  signal un_acam_start_nb, un_clk_i_cycles_offset             : unsigned(31 downto 0);
  signal un_roll_over, un_nb_of_retrig, un_retrig_nb_offset   : unsigned(31 downto 0);
  signal un_nb_of_cycles, un_retrig_from_roll_over            : unsigned(31 downto 0);
  signal acam_start_nb_32                                     : std_logic_vector(31 downto 0);
  -- final timestamp fields
  signal full_timestamp                                       : std_logic_vector(127 downto 0);
  signal metadata, local_utc, coarse_time, fine_time          : std_logic_vector(31 downto 0);
  -- circular buffer timestamp writings WISHBONE interface
  signal tstamp_wr_cyc, tstamp_wr_stb, tstamp_wr_we           : std_logic;
  -- circular buffer counters
  signal dacapo_counter                                       : unsigned(19 downto 0);
  signal wr_index                                             : unsigned(7 downto 0);

  -- signal previous_clk_i_cycles_offset                         : std_logic_vector(31 downto 0);
  -- signal previous_retrig_nb_offset, previous_roll_over_nb     : std_logic_vector(31 downto 0);


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin
 
---------------------------------------------------------------------------------------------------
--                                WISHBONE STB, CYC, WE, ADR                                     --
---------------------------------------------------------------------------------------------------   
-- WISHBONE_master_signals: Generation of the WISHBONE classic signals STB, CYC, WE that initiate
-- writes to the circular_buffer memory. Upon acam_tstamp1_ok_p_i or acam_tstamp2_ok_p_i activation
-- the process activates the STB, CYC, WE signals and waits for an ACK; as soon as the ACK arrives
-- (and the tstamps are written in the memory) STB, CYC and WE are deactivated and a new
-- acam_tstamp1_ok_p_i or acam_tstamp2_ok_p_i pulse is awaited to initiate a new write cycle.
-- Reminder: timestamps (acam_tstamp1_ok_p_i or acam_tstamp2_ok_p_i pulses) can arrive at maximum
-- every 4 clk_i cycles (31.25 MHz).

-- clk_i              : __|-|__|-|__|-|__|-|__|-|__|-|__|-|__|-|__|-|__|-|__|-|__ ...
-- acam_tstamp1_ok_p  : ____________|----|______________|----|___________________ ...
-- tstamp_wr_wb_dat   : _________________<    one tstamp    ><  another tstamp  > ...
-- tstamp_wr_wb_adr   :         address 0         ><    address 1    ><  address 2...
-- tstamp_wr_stb      : _________________|--------|_________|---------|__________ ...
-- tstamp_wr_ack      : ______________________|---|______________|----|__________ ...

  WISHBONE_master_signals: process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i = '1' then
        tstamp_wr_stb <= '0';
        tstamp_wr_cyc <= '0';
        tstamp_wr_we  <= '0';

      elsif acam_tstamp1_ok_p_i ='1' or acam_tstamp2_ok_p_i ='1' then    
        tstamp_wr_stb <= '1';
        tstamp_wr_cyc <= '1';
        tstamp_wr_we  <= '1';

      elsif tstamp_wr_wb_ack_i = '1' then
        tstamp_wr_stb <= '0';
        tstamp_wr_cyc <= '0';
        tstamp_wr_we  <= '0';
      end if;
    end if;
  end process;
 
--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
-- tstamp_wr_wb_adr: the process keeps track of the place in the memory the next timestamp is to be
-- written; wr_index indicates which one is the next address to write to.
-- The index is also used by the PCIe host to configure the DMA coherently (DMALENR register)
  tstamp_wr_wb_adr: process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i ='1' then
        wr_index      <= (others => '0');

      elsif tstamp_wr_cyc = '1' and tstamp_wr_stb = '1' and tstamp_wr_we = '1' and tstamp_wr_wb_ack_i = '1' then

        if wr_index = c_CIRCULAR_BUFF_SIZE - 1 then
          wr_index    <= (others => '0'); -- when memory completed, restart from the beginning
        else
          wr_index    <= wr_index + 1;    -- otherwise write to the next one
        end if;

      end if;
    end if;
  end process;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  tstamp_wr_p_o      <= tstamp_wr_cyc and tstamp_wr_stb and tstamp_wr_we and tstamp_wr_wb_ack_i;
  tstamp_wr_wb_adr_o <= std_logic_vector(wr_index);
  wr_index_o         <= std_logic_vector(dacapo_counter) & std_logic_vector(wr_index) & c_MULTIPLY_BY_SIXTEEN;
                     -- "& c_MULTIPLY_BY_SIXTEEN" for the convertion to the number of 8-bits-words
                     -- for the configuration of the DMA


---------------------------------------------------------------------------------------------------
--                                         Da Capo flag                                          --
---------------------------------------------------------------------------------------------------     
-- dacapo_counter_update: the Da Capo counter indicates the number of times the circular buffer
-- has been written completely; it can be cleared by the PCIe host.
  dacapo_counter_update: process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i ='1' or dacapo_c_rst_p_i = '1' then
        dacapo_counter <= (others => '0');

      elsif tstamp_wr_cyc = '1' and tstamp_wr_stb = '1' and tstamp_wr_we = '1' and
            tstamp_wr_wb_ack_i = '1' and wr_index = c_CIRCULAR_BUFF_SIZE - 1 then
        dacapo_counter <= dacapo_counter + 1;
      end if;
    end if;
  end process;


---------------------------------------------------------------------------------------------------
--                                   Final Timestamp Formatting                                  --
---------------------------------------------------------------------------------------------------   
-- tstamp_formatting: slicing of the 32-bits word acam_tstamp1_i and acam_tstamp2_i as received
-- from the data_engine unit, to construct the final timestamps to be stored in the circular_buffer

-- acam_tstamp1_i, acam_tstamp2_i have the following structure:
--   [16:0]   Stop-Start     \
--   [17]     Slope           \ ACAM 28 bits word
--   [25:18]  Start number   /
--   [27:26]  Channel Code  /

--   [28]     lf2           \
--   [29]     lf1            \ empty and load flags (added by the acam_databus_interface unit)
--   [30]     ef2            /
--   [31]     ef1           /

-- The final timestamp written in the circular_buffer is a 128-bits word divided in four
-- 32-bits words with the following structure:
--   [31:0]   Fine time to be added to the Coarse time: "00..00" & 16 bit Stop-Start;
--                                          each bit represents 81.03 ps

--   [63:32]  Coarse time within the current second, caclulated from the: Start number,
--            clk_i_cycles_offset_i, retrig_nb_offset_i, roll_over_nb_i 
--                                          each bit represents 8 ns

--   [95:64]  Local UTC time coming from the one_hz_generator;
--                                          each bit represents 1s

--   [127:96] Metadata for each timestamp: "00..00" & lf & ef & Slope & Channel

  tstamp_formatting: process (clk_i)
  begin   
    if rising_edge (clk_i) then
      if rst_i ='1' then  
        acam_channel        <= (others => '0');
        acam_fifo_ef        <= '0';
        acam_fifo_lf        <= '0';
        acam_fine_timestamp <= (others => '0');
        acam_slope          <= '0';
        acam_start_nb       <= (others => '0');

      elsif acam_tstamp1_ok_p_i = '1' then
        acam_channel        <= "0" & acam_tstamp1_i(27 downto 26);
        acam_fifo_ef        <= acam_tstamp1_i(31);
        acam_fifo_lf        <= acam_tstamp1_i(29);
        acam_fine_timestamp <= acam_tstamp1_i(16 downto 0);
        acam_slope          <= acam_tstamp1_i(17);
        acam_start_nb       <= acam_tstamp1_i(25 downto 18);

      elsif acam_tstamp2_ok_p_i ='1' then
        acam_channel        <= "1" & acam_tstamp2_i(27 downto 26);
        acam_fifo_ef        <= acam_tstamp2_i(30);
        acam_fifo_lf        <= acam_tstamp2_i(28);
        acam_fine_timestamp <= acam_tstamp2_i(16 downto 0);
        acam_slope          <= acam_tstamp2_i(17);
        acam_start_nb       <= acam_tstamp2_i(25 downto 18);
      end if;
    end if;
  end process;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- reg_info_of_previous_sec: process (clk_i)
  -- begin   
    -- if rising_edge (clk_i) then
      -- if rst_i = '1' then
        -- previous_clk_i_cycles_offset <= (others => '0');
        -- previous_retrig_nb_offset    <= (others => '0');
        -- previous_roll_over_nb        <= (others => '0');

      -- elsif one_hz_p_i = '1' then
        -- previous_clk_i_cycles_offset <= clk_i_cycles_offset_i;
        -- previous_retrig_nb_offset    <= retrig_nb_offset_i;
        -- previous_roll_over_nb        <= roll_over_nb_i;
      -- end if;
    -- end if;
  -- end process;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  full_timestamp(31 downto 0)   <= fine_time;
  full_timestamp(63 downto 32)  <= coarse_time;
  full_timestamp(95 downto 64)  <= local_utc;
  full_timestamp(127 downto 96) <= metadata;
  tstamp_wr_dat_o               <= full_timestamp;

  --un_clk_i_cycles_offset        <= unsigned(previous_clk_i_cycles_offset) when retrig_nb_offset_i = acam_start_nb_32  
  --                                 else unsigned(clk_i_cycles_offset_i);
  --un_retrig_nb_offset           <= unsigned(previous_retrig_nb_offset) when retrig_nb_offset_i = acam_start_nb_32 
  --                                 else unsigned(retrig_nb_offset_i);
  --un_roll_over                  <= unsigned(previous_roll_over_nb) when retrig_nb_offset_i = acam_start_nb_32  
  --                                 else unsigned(roll_over_nb_i);

  -- all the values needed for the calculations have to be converted to unsigned
  acam_start_nb_32              <= x"000000" & acam_start_nb;
  un_acam_start_nb              <= unsigned(acam_start_nb_32);
  un_clk_i_cycles_offset        <= unsigned(clk_i_cycles_offset_i);
  un_retrig_nb_offset           <= unsigned(retrig_nb_offset_i);
  un_roll_over                  <= unsigned(roll_over_nb_i);

  -- the number of roll-overs of the ACAM internal start retrigger counter is converted to a number
  -- of internal start retriggers.
  -- shifted left to multiply by 256
  un_retrig_from_roll_over      <= shift_left(un_roll_over-1, 8) when roll_over_incr_recent_i = '1' and un_acam_start_nb > 192
                                   else shift_left(un_roll_over, 8);


  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- fine time: directly provided by ACAM as a number of BINs since the last internal retrigger
  fine_time                     <= x"000" & "000" & acam_fine_timestamp;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- local UTC: updated every second by the one_hz_pulse unit
  local_utc                     <= local_utc_i;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  
  -- coarse time: expressed as the number of 125 MHz clock cycles since the last one_hz_pulse.
  -- Since the clk_i and the pulse are derived from the same PLL, any offset between them is constant 
  -- and will cancel when substracting timestamps.
  coarse_time                   <= std_logic_vector(un_nb_of_cycles);
    
  -- the number of internal start retriggers actually occurred is calculated by subtracting the offset number
  -- already present when the one_hz_pulse arrives, and adding the start nb provided by the ACAM.
  un_nb_of_retrig               <=  un_retrig_from_roll_over - un_retrig_nb_offset + un_acam_start_nb;

  -- finally, the coarse time is obtained by multiplying by the number of clk_i cycles in an internal
  -- start retrigger period and adding the number of clk_i cycles still to be discounted when the
  -- one_hz_pulse arrives.
  un_nb_of_cycles               <= shift_left(un_nb_of_retrig-1, c_ACAM_RETRIG_PERIOD_SHIFT) + un_clk_i_cycles_offset;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  
  -- metadata: information about the timestamp
  metadata                      <= acam_start_nb &
                                   roll_over_nb_i(15 downto 0) &
                                   -- x"0000"              & -- 16 bits         (MSB)
                                   -- "000" & acam_fifo_ef & -- 4 bits in total
                                   -- "000" & acam_fifo_lf & -- 4 bits in total
                                   "000" & acam_slope   & -- 4 bits in total
                                   "0"   & acam_channel;  -- 4 bits in total (LSB)



---------------------------------------------------------------------------------------------------
--                                            Outputs                                            --
---------------------------------------------------------------------------------------------------   
-- wr_pointer_o <= dacapo_flag & std_logic_vector(wr_index(g_width-6 downto 0)) & x"0";

   tstamp_wr_wb_cyc_o      <= tstamp_wr_cyc;
   tstamp_wr_wb_stb_o      <= tstamp_wr_stb;
   tstamp_wr_wb_we_o       <= tstamp_wr_we;
    
end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
