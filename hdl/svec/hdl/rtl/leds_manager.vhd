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
--                                       | O  O |   5, 6                                          |
--                                       |______|                                                 |
--                                                                                                |
--              TDC LED  1 orange: division of the 125 MHz clock; one hz pulses                   |
--              TDC LED  2 orange: Channel 1 termination enable                                   |
--              TDC LED  3 orange: Channel 2 termination enable                                   |
--              TDC LED  4 orange: Channel 3 termination enable                                   |
--              TDC LED  5 orange: Channel 4 termination enable                                   |
--              TDC LED  6 orange: Channel 5 termination enable                                   |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
-- Date         05/2012                                                                           |
-- Version      v0.3                                                                              |
-- Depends on                                                                                     |
--                                                                                                |
----------------                                                                                  |
-- Last changes                                                                                   |
--     05/2012  v0.1  EG  First version                                                           |
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



--=================================================================================================
--                            Entity declaration for leds_manager
--=================================================================================================

entity leds_manager is
  generic
    (g_width                : integer := 32;
     values_for_simulation  : boolean := FALSE);
  port
  -- INPUTS
     -- Signals from the clks_rsts_manager
    (clk_i             : in std_logic;  -- 125 MHz clock
     rst_i             : in std_logic;  -- core internal reset, synched with 125 MHz clk

     -- Signal from the one_hz_generator unit
     one_hz_p_i        : in std_logic;

     -- Signal from the reg_ctrl unit
     acam_inputs_en_i  : in std_logic_vector(g_width-1 downto 0); -- enable for the ACAM channels;
                                        -- activation comes through dedicated reg c_ACAM_INPUTS_EN_ADR


  -- OUTPUTS
     -- Signals to the LEDs on the TDC front panel
     tdc_led_status_o  : out std_logic; -- TDC  LED 1: division of 125 MHz
     tdc_led_trig1_o   : out std_logic; -- TDC  LED 2: Channel 1 input enable
     tdc_led_trig2_o   : out std_logic; -- TDC  LED 3: Channel 2 input enable
     tdc_led_trig3_o   : out std_logic; -- TDC  LED 4: Channel 3 input enable
     tdc_led_trig4_o   : out std_logic; -- TDC  LED 5: Channel 4 input enable
     tdc_led_trig5_o   : out std_logic);-- TDC  LED 6: Channel 5 input enable

end leds_manager;


--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of leds_manager is

  signal tdc_led_blink_done                    : std_logic;
  signal spec_led_period, visible_blink_length : std_logic_vector(g_width-1 downto 0);


begin
---------------------------------------------------------------------------------------------------
--                                     TDC FRONT PANEL LED 1                                     --
---------------------------------------------------------------------------------------------------  
  
---------------------------------------------------------------------------------------------------

  tdc_led_blink_counter: decr_counter
  port map
    (clk_i             => clk_i,
     rst_i             => rst_i,
     counter_load_i    => one_hz_p_i,
     counter_top_i     => visible_blink_length,
     counter_is_zero_o => tdc_led_blink_done,
     counter_o         => open);

---------------------------------------------------------------------------------------------------
  tdc_led: process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i ='1' then
        tdc_led_status_o <= '0';
      elsif one_hz_p_i ='1' then
        tdc_led_status_o <= '1';
      elsif tdc_led_blink_done = '1' then
        tdc_led_status_o <= '0';
      end if;
    end if;
  end process;

  visible_blink_length <= c_BLINK_LGTH_SIM when values_for_simulation else c_BLINK_LGTH_SYN;


---------------------------------------------------------------------------------------------------
--                                    TDC FRONT PANEL LEDs 2-6                                   --
--------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------
  all_outputs: process (clk_i)
  begin
    if rising_edge (clk_i) then
      tdc_led_trig5_o  <= acam_inputs_en_i(4) and acam_inputs_en_i(7);
      tdc_led_trig4_o  <= acam_inputs_en_i(3) and acam_inputs_en_i(7);
      tdc_led_trig3_o  <= acam_inputs_en_i(2) and acam_inputs_en_i(7);
      tdc_led_trig2_o  <= acam_inputs_en_i(1) and acam_inputs_en_i(7);
      tdc_led_trig1_o  <= acam_inputs_en_i(0) and acam_inputs_en_i(7);
    end if;
  end process;



end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------