-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

---------------------------------------------------------------------------------------------------
-- Title      :   Timestamp data formatting
---------------------------------------------------------------------------------------------------
-- Description:  Formats in a 128-bit word the 
--                o fine timestamps coming directly from the ACAM
--                o plus the coarse timing internally measured in the core
--                o plus the UTC time, coming from the WRabbit core if synchronization is
--                  established or from the internal local counter
---------------------------------------------------------------------------------------------------


--=================================================================================================
--                                       Libraries & Packages
--=================================================================================================

-- Standard library
library IEEE;
use IEEE.STD_LOGIC_1164.all;            -- std_logic definitions
use IEEE.NUMERIC_STD.all;     -- conversion functions-- Specific library
-- Specific library
library work;
use work.tdc_core_pkg.all;    -- definitions of types, constants, entities


--=================================================================================================
--                            Entity declaration for data_formatting
--=================================================================================================
entity data_formatting is
  port
    -- INPUTS
    -- Signal from the clk_rst_manager
    (clk_i : in std_logic;              -- 125 MHz clk
     rst_i : in std_logic;              -- general reset

     -- Signals from the data_engine unit
     acam_tstamp1_ok_p_i : in std_logic;  -- tstamp1 valid indicator
     acam_tstamp1_i      : in std_logic_vector(31 downto 0);  -- 32 bits tstamp to be treated and stored;
                                          -- includes ef1 & ef2 & 0 & 0 & 28 bits tstamp from FIFO1
     acam_tstamp2_ok_p_i : in std_logic;  -- tstamp2 valid indicator
     acam_tstamp2_i      : in std_logic_vector(31 downto 0);  -- 32 bits tstamp to be treated and stored;
                                          -- includes ef1 & ef2 & 0 & 0 & 28 bits tstamp from FIFO2

     -- Signals from the one_hz_gen unit
     utc_i : in std_logic_vector(31 downto 0);  -- local UTC time

     -- Signals from the start_retrig_ctrl unit
     roll_over_incr_recent_i : in std_logic;
     clk_i_cycles_offset_i   : in std_logic_vector(31 downto 0);
     roll_over_nb_i          : in std_logic_vector(31 downto 0);
     retrig_nb_offset_i      : in std_logic_vector(31 downto 0);
     current_retrig_nb_i     : in std_logic_vector(31 downto 0);

     gen_fake_ts_enable_i  : in std_logic;
     gen_fake_ts_period_i  : in std_logic_vector(27 downto 0);
     gen_fake_ts_channel_i : in std_logic_vector(2 downto 0);

     -- Signal from the WRabbit core or the one_hz_generator unit
     utc_p_i : in std_logic;

     -- OUTPUTS

     timestamp_o       : out t_acam_timestamp;
     timestamp_valid_o : out std_logic

     );

end data_formatting;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of data_formatting is

  -- ACAM timestamp fields
  signal acam_channel                                         : std_logic_vector(2 downto 0);
  signal acam_slope                                           : std_logic;
  signal acam_fine_timestamp                                  : std_logic_vector(16 downto 0);
  signal acam_start_nb                                        : unsigned(7 downto 0);
  -- timestamp manipulations
  signal un_acam_start_nb, un_clk_i_cycles_offset             : unsigned(31 downto 0);
  signal un_roll_over, un_nb_of_retrig, un_retrig_nb_offset   : unsigned(31 downto 0);
  signal un_nb_of_cycles, un_retrig_from_roll_over            : unsigned(31 downto 0);
  signal acam_start_nb_32                                     : unsigned(31 downto 0);
  -- final timestamp fields
  signal full_timestamp                                       : std_logic_vector(127 downto 0);
  signal metadata, utc, coarse_time, fine_time                : std_logic_vector(31 downto 0);
  -- coarse time calculations
  signal tstamp_on_first_retrig_case1                         : std_logic;
  signal tstamp_on_first_retrig_case2                         : std_logic;
  signal coarse_zero                                          : std_logic;  -- for debug
  signal un_previous_clk_i_cycles_offset                      : unsigned(31 downto 0);
  signal un_previous_retrig_nb_offset                         : unsigned(31 downto 0);
  signal un_previous_roll_over_nb                             : unsigned(31 downto 0);
  signal un_current_retrig_nb_offset, un_current_roll_over_nb : unsigned(31 downto 0);
  signal un_current_retrig_from_roll_over                     : unsigned(31 downto 0);
  signal un_acam_fine_time                                    : unsigned(31 downto 0);
  signal previous_utc                                         : std_logic_vector(31 downto 0);
  signal timestamp_valid_int                                  : std_logic;

  signal fake_cnt_coarse : unsigned(27 downto 0);
  signal fake_cnt_period : unsigned(27 downto 0);
  signal fake_cnt_tai    : unsigned(31 downto 0);
  signal fake_ts_valid   : std_logic;

  signal timestamp_valid_int_d : std_logic;

  signal raw_ts, raw_ts_d : t_raw_acam_timestamp;

--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

  p_gen_timestamp_valid : process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i = '1' then
        timestamp_valid_int <= '0';
      else
        timestamp_valid_int   <= acam_tstamp1_ok_p_i or acam_tstamp2_ok_p_i;
        timestamp_valid_int_d <= timestamp_valid_int;
      end if;
    end if;
  end process;

---------------------------------------------------------------------------------------------------
-- Final Timestamp Formatting
---------------------------------------------------------------------------------------------------
-- tstamp_formatting: slicing of the 32-bits word acam_tstamp1_i and acam_tstamp2_i as received
-- from the data_engine unit, to construct the final timestamps

-- acam_tstamp1_i, acam_tstamp2_i have the following structure:
--   [16:0]   Stop-Start     \
--   [17]     Slope           \ ACAM 28 bits word
--   [25:18]  Start number   /
--   [27:26]  Channel Code  /

--   [28]      0            \
--   [29]      0             \ empty and load flags (added by the acam_databus_interface unit)
--   [30]     ef2            /
--   [31]     ef1           /

-- The final timestamp is a 128-bits word divided in four
-- 32-bits words with the following structure:
--   [31:0]   Fine time to be added to the Coarse time: "00..00" & 16 bit Stop-Start;
--                                          each bit represents 81.03 ps

--   [63:32]  Coarse time within the current second, caclulated from the: Start number,
--            clk_i_cycles_offset_i, retrig_nb_offset_i, roll_over_nb_i
--                                          each bit represents 8 ns

--   [95:64]  Local UTC time coming from the one_hz_generator;
--                                          each bit represents 1s

--   [127:96] Metadata for each timestamp: Slope(rising or falling tstamp), Channel

  tstamp_formatting : process (clk_i)  -- ACAM data handling DFF #2 (DFF #1 refers to the registering of the acam_tstamp1/2_ok_p)
  begin
    if rising_edge (clk_i) then
      if rst_i = '1' then
        acam_channel        <= (others => '0');
        acam_fine_timestamp <= (others => '0');
        acam_slope          <= '0';
        acam_start_nb       <= (others => '0');

      elsif acam_tstamp1_ok_p_i = '1' then
        acam_channel        <= "0" & acam_tstamp1_i(27 downto 26);
        acam_fine_timestamp <= acam_tstamp1_i(16 downto 0);
        acam_slope          <= acam_tstamp1_i(17);
        acam_start_nb       <= unsigned(acam_tstamp1_i(25 downto 18));

      elsif acam_tstamp2_ok_p_i = '1' then
        acam_channel        <= "1" & acam_tstamp2_i(27 downto 26);
        acam_fine_timestamp <= acam_tstamp2_i(16 downto 0);
        acam_slope          <= acam_tstamp2_i(17);
        acam_start_nb       <= unsigned(acam_tstamp2_i(25 downto 18));
      end if;
    end if;
  end process;

  p_tstamp_raw_latch : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if timestamp_valid_int = '1' then
        raw_ts.seconds       <= utc_i;
        raw_ts.acam_bins     <= acam_fine_timestamp;
        raw_ts.acam_start_nb <= std_logic_vector(acam_start_nb);
        raw_ts.slope         <= acam_slope;
        raw_ts.channel       <= acam_channel;
        raw_ts.roll_over_incr_recent <= roll_over_incr_recent_i;
        raw_ts.clk_i_cycles_offset <= clk_i_cycles_offset_i(7 downto 0);
        raw_ts.roll_over_nb <= roll_over_nb_i(15 downto 0);
        raw_ts.retrig_nb_offset <= retrig_nb_offset_i(8 downto 0);
        raw_ts.current_retrig_nb <= current_retrig_nb_i(8 downto 0);
      end if;
      raw_ts_d <= raw_ts;
    end if;
  end process;


  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  reg_info_of_previous_sec : process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i = '1' then
        un_previous_clk_i_cycles_offset <= (others => '0');
        un_previous_retrig_nb_offset    <= (others => '0');
        un_previous_roll_over_nb        <= (others => '0');
        previous_utc                    <= (others => '0');
      elsif utc_p_i = '1' then
        un_previous_clk_i_cycles_offset <= unsigned(clk_i_cycles_offset_i);
        un_previous_retrig_nb_offset    <= unsigned(retrig_nb_offset_i);
        un_previous_roll_over_nb        <= unsigned(roll_over_nb_i);
        previous_utc                    <= utc_i;
      end if;
    end if;
  end process;


  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- all the values needed for the calculations have to be converted to unsigned
  un_acam_fine_time           <= unsigned(fine_time);
  acam_start_nb_32            <= x"000000" & acam_start_nb;
  un_acam_start_nb            <= unsigned(acam_start_nb_32);
  un_current_retrig_nb_offset <= unsigned(retrig_nb_offset_i);
  un_current_roll_over_nb     <= unsigned(roll_over_nb_i);

  un_current_retrig_from_roll_over <= shift_left(un_current_roll_over_nb-1, 8) when roll_over_incr_recent_i = '1' and un_acam_start_nb > 192 and un_current_roll_over_nb > 0
                                      else shift_left(un_current_roll_over_nb, 8);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- The following process makes essential calculations for the definition of the coarse time.
  -- Regarding the signals: un_clk_i_cycles_offset, un_retrig_nb_offset, utc it has to be defined
  -- if the values that characterize the current second or the one previous to it should be used.
  -- In the case where: a timestamp came on the same retgigger after a new second
  -- (un_current_retrig_from_roll_over is 0 and un_acam_start_nb = un_current_retrig_nb_offset)
  -- the values of the previous second should be used.
  -- Also, according to the ACAM documentation there is an indeterminacy to whether the fine time refers
  -- to the previous retrigger or the current one. The equation described on line 386 describes
  -- the case where: a timestamp came on the same retgigger after a new second but the ACAM assigned
  -- it to the previous retrigger (the "un_current_retrig_from_roll_over = 0" describes that a new second
  -- has arrived; the "un_acam_fine_time > 6318" desribes a fine time that is referred to the previous retrigger;
  -- 6318 * 81ps = 512ns which is a complete ACAM retrigger).

  -- Regarding the un_retrig_from_roll_over, i.e. number of roll-overs of the ACAM-internal-start-retrigger-counter,
  -- it has to be converted to a number of internal start retriggers, multiplying by 256 i.e. shifting left!
  -- Note that if a new tstamp has arrived from the ACAM when the roll_over has just been increased, there are chances
  -- the tstamp belongs to the previous roll-over value. This is because the moment the IrFlag is taken into account
  -- in the FPGA is different from the moment the tstamp has arrived to the ACAM (several clk_i cycles to empty ACAM FIFOs).
  -- So if in a timestamp the start_nb from the ACAM is close to the upper end (close to 255) and on the moment the timestamp
  -- is being treated in the FPGA the IrFlag has recently been tripped it means that for the formatting of the tstamp the
  -- previous value of the roll_over_c should be considered (before the IrFlag tripping).
  -- Eva: have to calculate better the amount of tstamps that could have been accumulated before the rollover changes;
  -- the current value we put "192" is not well studied for all cases!!

  coarse_time_intermed_calcul : process (clk_i)  -- ACAM data handling DFF #3; at the next cycle (#4) the data is written in memory
  begin
    if rising_edge (clk_i) then
      if rst_i = '1' then
        un_clk_i_cycles_offset   <= (others => '0');
        un_retrig_nb_offset      <= (others => '0');
        un_retrig_from_roll_over <= (others => '0');
        utc                      <= (others => '0');
        coarse_zero              <= '0';
      else
        -- ACAM tstamp arrived on the same retgigger after a new second
        if (un_acam_start_nb+un_current_retrig_from_roll_over = un_current_retrig_nb_offset) or
          (un_acam_start_nb = un_current_retrig_nb_offset-1 and un_acam_fine_time > 6318 and (un_current_retrig_from_roll_over = 0)) then

          coarse_zero              <= '1';
          un_clk_i_cycles_offset   <= un_previous_clk_i_cycles_offset;
          un_retrig_nb_offset      <= un_previous_retrig_nb_offset;
          utc                      <= previous_utc;
          un_retrig_from_roll_over <= shift_left(un_previous_roll_over_nb, 8);

        else
          un_clk_i_cycles_offset <= unsigned(clk_i_cycles_offset_i);
          un_retrig_nb_offset    <= unsigned(retrig_nb_offset_i);
          utc                    <= utc_i;
          coarse_zero            <= '0';
          if acam_start_nb = 255 and unsigned(current_retrig_nb_i) = 0 then
            un_retrig_from_roll_over <= shift_left(unsigned(roll_over_nb_i)-1, 8);
          else
            un_retrig_from_roll_over <= shift_left(unsigned(roll_over_nb_i), 8);
          end if;
        end if;
      end if;
    end if;
  end process;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- the number of internal start retriggers actually occurred is calculated by subtracting the offset number
  -- already present when the one_hz_pulse arrives, and adding the start nb provided by the ACAM.
  un_nb_of_retrig <= un_retrig_from_roll_over - (un_retrig_nb_offset) + un_acam_start_nb;

  -- finally, the coarse time is obtained by multiplying by the number of clk_i cycles in an internal
  -- start retrigger period and adding the number of clk_i cycles still to be discounted when the
  -- one_hz_pulse arrives.
  un_nb_of_cycles <= shift_left(un_nb_of_retrig, c_ACAM_RETRIG_PERIOD_SHIFT) + un_clk_i_cycles_offset;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- coarse time: expressed as the number of 125 MHz clock cycles since the last one_hz_pulse.
  -- Since the clk_i and the pulse are derived from the same PLL, any offset between them is constant
  -- and will cancel when subtracting timestamps.
  coarse_time <= std_logic_vector(un_nb_of_cycles);  -- when coarse_zero = '0' else std_logic_vector(64-unsigned(clk_i_cycles_offset_i));

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- fine time: directly provided by ACAM as a number of BINs since the last internal retrigger
  fine_time <= x"000" & "000" & acam_fine_timestamp;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- metadata: information about the timestamp
  -- for debug
  metadata(31 downto 24) <= std_logic_vector(acam_start_nb(7 downto 0));
  metadata(23)           <= coarse_zero;
  metadata(22 downto 15) <= std_logic_vector(un_retrig_nb_offset(7 downto 0));
  metadata(14 downto 12) <= std_logic_vector(roll_over_nb_i(2 downto 0));
  metadata(11 downto 5)  <= std_logic_vector(un_clk_i_cycles_offset(6 downto 0));
   -- 5 LSbits used for slope and acam_channel
  metadata(4)            <= acam_slope;
  metadata(3)            <= roll_over_incr_recent_i;
  metadata(2 downto 0)   <= acam_channel;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if gen_fake_ts_enable_i = '0' then
        fake_cnt_coarse <= (others => '0');
        fake_cnt_tai    <= (others => '0');
        fake_cnt_period <= (others => '0');
      else
        if unsigned(gen_fake_ts_period_i) = fake_cnt_period then
          fake_cnt_period <= (others => '0');
          fake_ts_valid   <= '1';
        else
          fake_cnt_period <= fake_cnt_period + 1;
          fake_ts_valid   <= '0';
        end if;

        if fake_cnt_coarse = 124999999 then
          fake_cnt_coarse <= (others => '0');
          fake_cnt_tai    <= fake_cnt_tai + 1;
        else
          fake_cnt_coarse <= fake_cnt_coarse + 1;
        end if;
      end if;
    end if;
  end process;


  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
      else
        if(gen_fake_ts_enable_i = '1' and fake_ts_valid = '1')then
          timestamp_o.slope   <= '1';
          timestamp_o.channel <= gen_fake_ts_channel_i;
          timestamp_o.n_bins  <= (others => '0');
          timestamp_o.coarse  <= std_logic_vector(resize(fake_cnt_coarse, 32));
          timestamp_o.tai     <= std_logic_vector(fake_cnt_tai);
          timestamp_valid_o   <= '1';
        elsif(timestamp_valid_int_d = '1') then
          timestamp_o.raw <= raw_ts_d;
          timestamp_o.slope   <= acam_slope;
          timestamp_o.channel <= acam_channel;
          timestamp_o.n_bins  <= fine_time(16 downto 0);
          timestamp_o.coarse  <= coarse_time;
          timestamp_o.tai     <= utc(31 downto 0);
          timestamp_o.meta <= x"000" & std_logic_vector(acam_start_nb(6 downto 0)) & fine_time(12 downto 0);

          timestamp_valid_o   <= '1';
        else
          timestamp_valid_o <= '0';
        end if;
      end if;
    end if;
  end process;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
