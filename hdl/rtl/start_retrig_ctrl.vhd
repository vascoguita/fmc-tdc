-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

---------------------------------------------------------------------------------------------------
-- Title      : TDC core pkg
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Description: The unit provides the main components for the calculation of the "Coarse time" of |
--              the final timestamps. These components are sent to the data_formatting unit where |
--              the actual Coarse time calculation takes place.                                   |
--                                                                                                |
--              As a reminder, the final timestamp is a 128-bits word divided in four 32-bits     |
--              words with the following structure:                                               |
--                                                                                                |
--                [127:96]  Timestamp Metadata (ex. Channel, Slope)                               |
--                                                                                                |
--                 [95:64]  Local UTC time from the one_hz_generator; each bit represents 1 s     |
--                                                                                                |
--                 [63:32]  Coarse time within the current second; each bit represents 8 ns       |
--                                                                                                |
--                  [31:0]  Fine time to be added to the Coarse time: provided directly by ACAM;  |
--                          each bit represents 81.03 ps                                          |
--                                                                                                |
--              In I-Mode the ACAM chip provides unlimited measuring range with internal start    |
--              retriggers. ACAM is programmed to retrigger every (16*acam_clk_period) =          |
--              (64*clk_i_period) = 512 ns; the StartTimer in ACAM Reg 4 is set to 15. It counts  |
--              the number of retriggers after a Start pulse and upon the arrival of a Stop pulse |
--              and it sends this number in the "Start#" field of the timestamp.                  |
--              Unfortunately ACAM's counter of the retriggers has only 8 bits and can count up   |
--              to 256 retriggers. Within one second (our UTC time) there can be up to            |
--              1,953,125 retriggers, which is >> 256 and actually corresponds to 7629 overflows  |
--              of the ACAM counter. Therefore there is the need to follow ACAM and keep track of |
--              the overflows. The ACAM Interrupt flag (IrFlag pin 59) has been set to follow the |
--              highest bit of the Start# (through the ACAM Reg 12 bit 26) and like this we       |
--              manage to count retriggers synchronously to ACAM itself.                          |
--              For simplification, in the following figure we assume that two Stop signals arrive|
--              after less than 256 ACAM internal retriggers. Therefore in the timestamps that    |
--              ACAM will give the Start# field will represent the exact amount of retriggers     |
--              after the Start pulse.                                                            |
--              Note that the interval between this external Start pulse and the first internal   |
--              retrigger may vary; it is measured by the ACAM chip and stored as Start01 in ACAM |
--              Reg 10. Moreover, there is the StartOff1 offset added to each Hit time by ACAM    |
--              (this does not appear in this figure) made available in ACAM Reg 5.               |
--              However, in this TDC core application we are only interested in time differences  |
--              between Stop pulses (ex. Stop2 - Stop1) and not in the precise arrival time of a  |
--              Stop pulse. Since now both Start01 and StartOff1 are stable numbers affecting     |
--              equally all the Stop pulses, they would disappear during the subtraction (which   |
--              takes place at the software side) and therefore thay are used in our calculations.|
--                                                                                                |
-- Start        ____|-|__________________________________________________________________________ |
-- Retriggers   ________________|-|________________|-|________________|-|________________|-|_____ |
-- Stop1        _________________________________________________|-|_____________________________ |
-- Hit1                                            <------------->                                |
-- Stop2        _____________________________________________________________________________|-|_ |
-- Hit2                                                                                   <-->    |
-- Start01          <---------->                                                                  |
--                                                                                                |
--              Coming back now to our timestamp format {UTC second, Coarse time, Fine time}, we  |
--              have to somehow assosiate ACAM retriggers to the UTC time. Actually, ACAM has no  |
--              knowledge of the UTC time and the arrival of a new second happens completely      |
--              independently. As the following figure shows the final timestamp of a Stop pulse  |
--              is defined by the current UTC time plus the amount of time between that UTC and   |
--              the Stop pulse: (2)+(3). Part (3) is provided exclusively by the ACAM chip in the |
--              Start# and Hit time fields of the timestamp. The sum of (1)+(2) is multiples of   |
--              256 ACAM retriggers and can be defined by following the ACAM output IrFlag.       |
--              Now Part (1), is the one that associates the arrival of a UTC second with the ACAM|
--              time counting and is defined in this unit by following the ACAM retriggers.       |
--                                                                                                |
-- IrFlag     ______________|--------------|______________|-------------|... _____________|---    |
--             ___________________________  ___________________________       _____________       |
-- new UTC sec|               _|-|_       ||                           |     |                    |
-- Stop1      |                           ||                           | ... |      _|-|_         |
--            |___________________________||___________________________|     |______________      |
--                    (1)                                                                         |
--            |----------------|                                                                  |
--                                                  (2)                                           |
--                             |---------------------------------------------|                    |
--                                                                              (3)               |
--                                                                           |-------|            |
--                                                                                                |
--              To conclude, the final Coarse time is: (Part(2) + Part(3)_Start#)*Retrigger period|
--              and the  Fine time is : Part(3)_Hit                                               |
--                                                                                                |
---------------------------------------------------------------------------------------------------



--=================================================================================================
--                                       Libraries & Packages
--=================================================================================================

-- Standard library
library IEEE;
use IEEE.STD_LOGIC_1164.all;  -- std_logic definitions
use IEEE.NUMERIC_STD.all;     -- conversion functions-- Specific library
-- Specific library
library work;
use work.tdc_core_pkg.all;    -- definitions of types, constants, entities


library unisim;
use unisim.vcomponents.all;

--=================================================================================================
--                            Entity declaration for start_retrig_ctrl
--=================================================================================================

entity start_retrig_ctrl is
  port
    -- INPUTS
    -- Signal from the clk_rst_manager
    (clk_i                  : in std_logic;
     rst_i                  : in std_logic;
     -- Signal from the acam_timecontrol_interface
     int_flag_i             : in std_logic;
     int_flag_delay_i : in std_logic_vector(15 downto 0);

     -- Signal from the one_hz_generator unit
     utc_p_i                 : in  std_logic;
     -- OUTPUTS
     -- Signals to the data_formatting unit
     current_retrig_nb_o     : out std_logic_vector(31 downto 0);
     roll_over_incr_recent_o : out std_logic;
     clk_i_cycles_offset_o   : out std_logic_vector(31 downto 0);
     roll_over_nb_o          : out std_logic_vector(31 downto 0);
     retrig_nb_offset_o      : out std_logic_vector(31 downto 0));
end start_retrig_ctrl;


--=================================================================================================
--                                    architecture declaration
--=================================================================================================


architecture rtl of start_retrig_ctrl is

  signal clk_i_cycles_offset : std_logic_vector(31 downto 0);
  signal current_cycles      : std_logic_vector(31 downto 0);
  signal current_retrig_nb   : std_logic_vector(31 downto 0);
  signal retrig_nb_offset    : std_logic_vector(31 downto 0);
  signal roll_over_c         : unsigned(31 downto 0);

  signal int_flag_r, int_flag_f, int_flag, int_flag_d, int_flag_p : std_logic;

  constant c_full_retrig_period : integer := 64 * 256;

  signal retrig_cnt : unsigned(15 downto 0);

--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

-- retrigger #      :   0    1          127  128        255  256  257        383  384  385         511  512  513
-- retriggers       :  _|____|____...____|____|____...____|____|____|____...___|____|____|____...____|____|____|___
-- IrFlag           :  __________________|---------------------|____________________|---------------------|________
-- IrFlag_f_edge_p  :  ______________________________________|-|________________________________________|-|________
-- retrig_p         : |-|__|-|__ ... __|-|__|-|__ ... __|-|__|-|__|-|__ ...__|-|__|-|__|-|___ ...__|-|__|-|__|-|___
-- current_retrig_nb:  0    1          127  128         255   0    1         127  128  129         255   0    1
-- utc_p_i       : _____________________|-|_______________________________________________________________
-- roll_over_c      :                       0                 1                                          2
-- retrig_nb_offset :                      127
-- clk_i_cycles_offs:                      |..| (counts clk_i cycles from the pulse to the end of this retrigger)
--
-- At the moment that a new second arrives through the utc_p_i, we:
--  o keep note of the current_retrig_nb, 127 in this case (stored in retrig_nb_offset)
--  o keep note of the current_cycles, that is the number of clk_i cycles between the utc_p_i
--    and the next (128th) retrigger (stored in clk_i_cycles_offset)
--  o reinitialize the roll_over_c counter which starts counting rollovers of the current_retrig_nb
--
--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
-- In this more macroscopic example we have included a Stop pulse arriving to the ACAM chip.
-- Each one of the n boxes represents 256 ACAM internal retriggers, which through the IrFlag are
-- synchronous with the counters in this unit. The coarse time is the amount of clk_i cycles
-- between the utc_p_i pulse and the ACAM Stop pulse. To the coarse time we then have to add the
-- fine time, which is the very precise 81ps resolution time measured by the ACAM. Note that the
-- ACAM can only provide timing information within the last box: the Start# (bits 25:18) indicates
-- the amount of internal retriggers and the Hit (bits 16:0) indicates the fine timing. The time
-- difference between the utc_p_i pulse and the last box is calculated through the counters of
-- this unit: roll_over_c, retrig_nb_offset, clk_i_cycles_offset.

-- Note that since the counting in the roll_over_c starts from 0, we do not need to subtract 1
-- so as not to consider the last, n-th, box. Similarly, for the retrig_nb_offset and ACAM Start#,
-- to calculate the amount of complete retriggers that have preceded the arrival of the
-- utc_p_i and the Stop pulse respectively, we would have to subtract 1, but since counting
-- starts from zero, we don't.
-- Finally, note that the the current_cycles counter is a decreasing counter giving the amount of
-- clk_i cycles between the resing edge of the one_hz_pulse_i and the next retrigger.
-- Note that in this project we are only interested in time differences between
--                    _______________________________________  _________________________________________       ____________________
-- utc_p_i           |                           _|-|_       ||                                         |     |
-- ACAM Stop pulse   |                                       ||                                         |     |       _|-|_
--                   |                                       ||                                         | ... |
-- roll_over_c       |                             0         ||1                                        |     |n-1
--                   |_______________________________________||_________________________________________|     |____________________
--                                (1)
--                   |----------------------------|
--                                                                             (2)
--                                                |-----------------------------------------------------------|
--                                                                                                                (3)
--                                                                                                            |--------|
--                  (1): ((retrig_nb_offset + 1) * retrig_period) - (clk_i_cycles_offset)
--                  (2): (roll_over_c * 256 * retrig_period) - (the amount that (1) represents)
--                  (3): from ACAM tstamps: (Start# * retrig_period) + (Fine time: Hit)

--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --

  p_sample_int_flag_r : process(clk_i)
  begin
    if rising_edge(clk_i) then
      int_flag_r <= int_flag_i;
    end if;
  end process;

  p_sample_int_flag_f : process(clk_i)
  begin
    if falling_edge(clk_i) then
      int_flag_f <= int_flag_i;
    end if;
  end process;

  p_pulse_detect : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        int_flag_d <= '0';
        int_flag_p <= '0';
        int_flag   <= '0';
      else
        if(int_flag_delay_i(0) = '0') then
          int_flag <= int_flag_r;
        else
          int_flag <= int_flag_f;
        end if;

        int_flag_d <= int_flag;
        int_flag_p <= int_flag_d and not int_flag;
      end if;
    end if;
  end process;

  p_count_retrig_periods : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        retrig_cnt <= (others => '0');
      elsif int_flag_p = '1' then
        retrig_cnt(6 downto 0) <= unsigned(int_flag_delay_i(7 downto 1));
        for i in 7 to 15 loop
          retrig_cnt(i) <= int_flag_delay_i(8);
        end loop;
      else
        retrig_cnt <= retrig_cnt + 1;
      end if;
    end if;
  end process;

  current_cycles <= std_logic_vector(resize(63 - retrig_cnt(5 downto 0), 32));
  current_retrig_nb <= std_logic_vector(resize(retrig_cnt(13 downto 6), 32));

  roll_over_counter : process (clk_i)
  begin
    if rising_edge (clk_i) then
      if utc_p_i = '1' and retrig_cnt /= (c_full_retrig_period- 1) then
        roll_over_c <= x"00000000";

                                        -- the following case covers the rare possibility when utc_p_i and acam_intflag_f_edge_p_i
                                        -- arrive on the exact same moment
      elsif utc_p_i = '1' and retrig_cnt = (c_full_retrig_period - 1) then
        roll_over_c <= x"00000001";
      elsif retrig_cnt = (c_full_retrig_period - 1) then
        roll_over_c <= roll_over_c + "1";
      end if;
    end if;
  end process;


--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- When a new second starts, all values are captured and stored as offsets.
  -- when a timestamp arrives, these offsets will be subtracted in order
  -- to base the final timestamp with respect to the current second.
  capture_offset : process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i = '1' then
        clk_i_cycles_offset <= (others => '0');
        retrig_nb_offset    <= (others => '0');
      elsif utc_p_i = '1' then
        clk_i_cycles_offset <= current_cycles;
        retrig_nb_offset    <= current_retrig_nb;
      end if;
    end if;
  end process;

--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- outputs
  roll_over_incr_recent_o <= '1' when unsigned(current_retrig_nb) < 64 else '0';
  clk_i_cycles_offset_o   <= clk_i_cycles_offset;
  retrig_nb_offset_o      <= retrig_nb_offset;
  roll_over_nb_o          <= std_logic_vector(roll_over_c);
  current_retrig_nb_o     <= current_retrig_nb;  -- for debug



end architecture rtl;


--=================================================================================================
--                                        architecture end
--=================================================================================================
---------------------------------------------------------------------------------------------------
--                                      E N D   O F   F I L E
---------------------------------------------------------------------------------------------------
