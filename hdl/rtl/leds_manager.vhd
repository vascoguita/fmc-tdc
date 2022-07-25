-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

--_________________________________________________________________________________________________
--                                                                                                |
--                                           |TDC core|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                         leds_manager                                           |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         leds_manager.vhd                                                                  |
--                                                                                                |
-- Description  Generation of the signals that drive the LEDs on the TDC mezzanine.               |
--              There are 6 LEDs on the front panel of the TDC mezzanine board:                   |
--                                        ______                                                  |
--                                       |      |                                                 |
--                                       | O  O |   1, 2                                          |
--                                       | O  O |   3, 4                                          |
--                                       | O  O |   5, STA                                        |
--                                       |______|                                                 |
--                                                                                                |
--              TDC LEDs: blink upon the generation of a valid timestamp                          |
--              Inverted blinking (LED permanently ON without pulses in the input) indicates the  |
--              50 Ohm termination is active on the channel.                                      |
--                                                                                                |
--              TDC LED STA orange:division of the 125 MHz clock; one hz pulses                   |
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
use IEEE.NUMERIC_STD.all;    -- conversion functions
-- Specific libraries
library work;
use work.tdc_core_pkg.all;   -- definitions of types, constants, entities
use work.gencores_pkg.all;


--=================================================================================================
--                            Entity declaration for leds_manager
--=================================================================================================

entity leds_manager is
  generic
    (g_width      : integer := 32;
     g_simulation : boolean := false);
  port
    -- INPUTS
    -- Signals from the clks_rsts_manager
    (clk_i            : in std_logic;  -- 125 MHz clock
     rst_i            : in std_logic;  -- core internal reset, synched with 125 MHz clk

     -- Signal from the one_hz_generator unit
     utc_p_i          : in std_logic;

     tstamp_valid_p_i : in std_logic_vector(4 downto 0); -- pulse upon writing valid tstamp to FIFO
     term_en_i        : in std_logic_vector(4 downto 0);

     -- OUTPUTS
     -- Signals to the LEDs on the TDC front panel
     tdc_led_stat_o   : out std_logic;                   -- LED STA: division of 125 MHz
     tdc_led_trig_o   : out std_logic_vector(4 downto 0));-- LED 2..5: Blinking indicates generation 
                                                         --           of a valid tstamp;  
                                                         --           permanently ON without pulses
                                                         -- in the input indicates 50Ohm termination 

end leds_manager;


--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of leds_manager is

  signal tdc_led_blink_done   : std_logic;
  signal visible_blink_length : std_logic_vector(g_width-1 downto 0);
  signal rst_n                : std_logic;
  signal tdc_led_trig         : std_logic_vector (4 downto 0);

begin
---------------------------------------------------------------------------------------------------
--                                   TDC FRONT PANEL LED STA                                     --
---------------------------------------------------------------------------------------------------  

---------------------------------------------------------------------------------------------------
  tdc_status_led_blink_counter : decr_counter
    port map
    (clk_i             => clk_i,
     rst_i             => rst_i,
     counter_load_i    => utc_p_i,
     counter_top_i     => visible_blink_length,
     counter_is_zero_o => tdc_led_blink_done,
     counter_o         => open);

---------------------------------------------------------------------------------------------------
  tdc_status_led_gener : process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i = '1' then
        tdc_led_stat_o <= '0';
      elsif utc_p_i = '1' then
        tdc_led_stat_o <= '1';
      elsif tdc_led_blink_done = '1' then
        tdc_led_stat_o <= '0';
      end if;
    end if;
  end process;

  visible_blink_length <= c_BLINK_LGTH_SIM when g_simulation else c_BLINK_LGTH_SYN;


---------------------------------------------------------------------------------------------------
--                                   TDC FRONT PANEL LEDs CH 1-5                                 --
--------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------
  rst_n <= not(rst_i);


  cmp_extend_ch1_pulse : gc_extend_pulse
    generic map
    (g_width => 5000000)
    port map
    (clk_i      => clk_i,
     rst_n_i    => rst_n,
     pulse_i    => tstamp_valid_p_i(0),
     extended_o => tdc_led_trig(0));

  cmp_extend_ch2_pulse : gc_extend_pulse
    generic map
    (g_width => 5000000)
    port map
    (clk_i      => clk_i,
     rst_n_i    => rst_n,
     pulse_i    => tstamp_valid_p_i(1),
     extended_o => tdc_led_trig(1));

  cmp_extend_ch3_pulse : gc_extend_pulse
    generic map
    (g_width => 5000000)
    port map
    (clk_i      => clk_i,
     rst_n_i    => rst_n,
     pulse_i    => tstamp_valid_p_i(2),
     extended_o => tdc_led_trig(2));

  cmp_extend_ch4_pulse : gc_extend_pulse
    generic map
    (g_width => 5000000)
    port map
    (clk_i      => clk_i,
     rst_n_i    => rst_n,
     pulse_i    => tstamp_valid_p_i(3),
     extended_o => tdc_led_trig(3));

  cmp_extend_ch5_pulse : gc_extend_pulse
    generic map
    (g_width => 5000000)
    port map
    (clk_i      => clk_i,
     rst_n_i    => rst_n,
     pulse_i    => tstamp_valid_p_i(4),
     extended_o => tdc_led_trig(4));

  tdc_led_trig_o(0) <= tdc_led_trig(0) xor term_en_i(0);
  tdc_led_trig_o(1) <= tdc_led_trig(1) xor term_en_i(1);
  tdc_led_trig_o(2) <= tdc_led_trig(2) xor term_en_i(2);
  tdc_led_trig_o(3) <= tdc_led_trig(3) xor term_en_i(3);
  tdc_led_trig_o(4) <= tdc_led_trig(4) xor term_en_i(4);

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
