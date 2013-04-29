--_________________________________________________________________________________________________
--                                                                                                |
--                                           |TDC core|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                         irq_generator                                          |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         irq_generator.vhd                                                                 |
--                                                                                                |
-- Description  Interrupts generator: the unit generates two interrups:                           |
--                o irq_tstamp_p_o is a 1 clk_i long pulse when the amount of timestamps written in |
--                  the circular_buffer since the last interrupt or the aquisition start exceeds  |
--                  the PCIe settable threshold irq_tstamp_threshold_o                            |
--                o irq_time_p_o is a 1 clk_i long pulse when some timestamps have been written in  |
--                  the circular_buffer (>0) and the amount of time passed the last interrupt or  |
--                  the aquisition start exceeds the PCIe settable threshold irq_time_threshold_o |
--                                                                                                |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
--              Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
-- Date         05/2012                                                                           |
-- Version      v0.1                                                                              |
-- Depends on                                                                                     |
--                                                                                                |
----------------                                                                                  |
-- Last changes                                                                                   |
--     05/2011  v0.1  EG  First version                                                           |
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
--                            Entity declaration for irq_generator
--=================================================================================================
entity irq_generator is
  generic
    (g_width                : integer := 32);
  port
  -- INPUTS
     -- Signal from the clk_rst_manager
    (clk_i                  : in std_logic;  -- 125 MHz clk
     rst_i                  : in std_logic;  -- general reset

     irq_tstamp_threshold_i : in std_logic_vector(g_width-1 downto 0);
     irq_time_threshold_i   : in std_logic_vector(g_width-1 downto 0);

     -- Signal from the reg_ctrl unit 
     activate_acq_p_i       : in std_logic;  -- activates tstamps aquisition from ACAM
     deactivate_acq_p_i     : in std_logic;  -- deactivates tstamps aquisition

     -- Signals from the data_formatting unit
     tstamp_wr_p_i          : in std_logic;  -- pulse upon storage of a new timestamp

     -- Signal from the one_hz_gen unit
     one_hz_p_i             : in std_logic;  -- pulse upon new second


  -- OUTPUTS
     -- Signals to the wb_irq_controller
     irq_tstamp_p_o         : out std_logic;  -- amount of tstamps > tstamps_threshold
     irq_time_p_o           : out std_logic); -- amount of tstamps < tstamps_threshold but time > time_threshold

end irq_generator;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of irq_generator is

  constant ZERO                                             : std_logic_vector (8 downto 0):= "000000000";
  type t_irq_st is (IDLE, TSTAMP_AND_TIME_COUNTING, RAISE_IRQ_TSTAMP, RAISE_IRQ_TIME);
  signal irq_st, nxt_irq_st                                 : t_irq_st;
  signal tstamps_c_rst, time_c_rst, tstamps_c_en, time_c_en : std_logic;
  signal tstamps_c_incr_en, time_c_incr_en                  : std_logic;
  signal tstamps_c                                          : std_logic_vector(8 downto 0); 
  signal time_c                                             : std_logic_vector(g_width-1 downto 0);


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin


--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --

---------------------------------------------------------------------------------------------------
--                                     INTERRUPTS GENERATOR                                      --
---------------------------------------------------------------------------------------------------

  IRQ_generator_seq: process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i ='1' then
        irq_st <= IDLE;
      else
        irq_st <= nxt_irq_st;
      end if;
    end if;
  end process;

---------------------------------------------------------------------------------------------------
  IRQ_generator_comb: process (irq_st, activate_acq_p_i, deactivate_acq_p_i, tstamps_c,
                                  irq_tstamp_threshold_i, irq_time_threshold_i, time_c)
  begin
    case irq_st is

      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when IDLE =>
                -----------------------------------------------
                   irq_tstamp_p_o <= '0';
                   irq_time_p_o   <= '0';
                   tstamps_c_rst  <= '1';
                   time_c_rst     <= '1';
                   tstamps_c_en   <= '0';
                   time_c_en      <= '0';
                -----------------------------------------------
                   if activate_acq_p_i = '1' then
                     nxt_irq_st   <= TSTAMP_AND_TIME_COUNTING;
                   else
                     nxt_irq_st   <= IDLE;
                   end if;

       --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when TSTAMP_AND_TIME_COUNTING =>
                -----------------------------------------------
                   irq_tstamp_p_o <= '0';
                   irq_time_p_o   <= '0';
                   tstamps_c_rst  <= '0';
                   time_c_rst     <= '0';
                   tstamps_c_en   <= '1';
                   time_c_en      <= '1';
                -----------------------------------------------
                   if deactivate_acq_p_i = '1' then
                     nxt_irq_st   <= IDLE;
                   elsif tstamps_c > ZERO and tstamps_c >= irq_tstamp_threshold_i(8 downto 0) then -- not >= ZERO!!
                     nxt_irq_st   <= RAISE_IRQ_TSTAMP;
                   elsif time_c >= irq_time_threshold_i and tstamps_c > ZERO then
                     nxt_irq_st   <= RAISE_IRQ_TIME;
                   else
                     nxt_irq_st   <= TSTAMP_AND_TIME_COUNTING;
                   end if;

      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when RAISE_IRQ_TSTAMP =>
                -----------------------------------------------
                   irq_tstamp_p_o <= '1';
                   irq_time_p_o   <= '0';
                   tstamps_c_rst  <= '1';
                   time_c_rst     <= '1';
                   tstamps_c_en   <= '0';
                   time_c_en      <= '0';
                -----------------------------------------------
                   if deactivate_acq_p_i = '1' then
                     nxt_irq_st   <= IDLE;
                   else
                     nxt_irq_st   <= TSTAMP_AND_TIME_COUNTING;
                   end if;

      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when RAISE_IRQ_TIME =>
                -----------------------------------------------
                   irq_tstamp_p_o <= '0';
                   irq_time_p_o   <= '1';
                   tstamps_c_rst  <= '1';
                   time_c_rst     <= '1';
                   tstamps_c_en   <= '0';
                   time_c_en      <= '0';
                -----------------------------------------------
                   if deactivate_acq_p_i = '1' then
                     nxt_irq_st   <= IDLE;
                   else
                     nxt_irq_st   <= TSTAMP_AND_TIME_COUNTING;
                   end if;

      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when others =>
                -----------------------------------------------
                   irq_tstamp_p_o <= '0';
                   irq_time_p_o   <= '0';
                   tstamps_c_rst  <= '1';
                   time_c_rst     <= '1';
                   tstamps_c_en   <= '0';
                   time_c_en      <= '0';
                -----------------------------------------------
                   nxt_irq_st     <= IDLE;
    end case;
  end process;



---------------------------------------------------------------------------------------------------
--                                      TIMESTAMPS COUNTER                                       --
---------------------------------------------------------------------------------------------------
-- Incremental counter counting the amount of timestamps written since the last interrupt or the
-- last reset. The counter counts up to 255 which is the circular buffer size.
  tstamps_counter: incr_counter
    generic map
      (width             => 9)   -- counting up to 255
    port map
      (clk_i             => clk_i,
       rst_i             => tstamps_c_rst,  
       counter_top_i     => "100000000",
       counter_incr_en_i => tstamps_c_incr_en,
       counter_is_full_o => open,
     -------------------------------------------
       counter_o         => tstamps_c);
     -------------------------------------------
    tstamps_c_incr_en    <= tstamps_c_en and tstamp_wr_p_i;



---------------------------------------------------------------------------------------------------
--                                         TIME COUNTER                                          --
---------------------------------------------------------------------------------------------------
-- Incremental counter counting the time in seconds since the last interrupt or the last reset.
  time_counter: incr_counter
    generic map
      (width             => g_width)
    port map
      (clk_i             => clk_i,
       rst_i             => time_c_rst,  
       counter_top_i     => x"FFFFFFFF",
       counter_incr_en_i => time_c_incr_en,
       counter_is_full_o => open,
     -------------------------------------------
       counter_o         => time_c);
     -------------------------------------------
    time_c_incr_en       <= time_c_en and one_hz_p_i;

    
end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
