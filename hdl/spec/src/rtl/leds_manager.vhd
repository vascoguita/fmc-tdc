--_________________________________________________________________________________________________
--                                                                                                |
--                                           |TDC core|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                       leds_manager                                             |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         leds_manager.vhd                                                                  |
--                                                                                                |
-- Description  Generation of the signals that drive the LEDs on the TDC mezzanine and SPEC       |
--              carrier boards.                                                                   |
--              There are 6 LEDs on the front panel of the TDC mezzanine board:                   |
--                                        ______                                                  |
--                                       |      |                                                 |
--                                       | O  O |   1, 2                                          |
--                                       | O  O |   3, 4                                          |
--                                       | O  O |   5, 6                                          |
--                                       |______|                                                 |
--                                                                                                |
--              TDC LED  1 orange: division of the 125 MHz clock; one hz pulses                   |
--              TDC LED  2 orange: Channel 1 terminatio enable                                    |
--              TDC LED  3 orange: Channel 2 terminatio enable                                    |
--              TDC LED  4 orange: Channel 3 terminatio enable                                    |
--              TDC LED  5 orange: Channel 4 terminatio enable                                    |
--              TDC LED  6 orange: Channel 5 terminatio enable                                    |
--                                                                                                |
--              And further down 2 LEDs on the front panel of the SPEC carrier board:             |
--                                        ______                                                  |
--                                       | O  O |   1, 2                                          |
--                                       |______|                                                 |
--                                                                                                |
--              SPEC LED 1 green : PLL status (DLD)                                               |
--              SPEC LED 2 red   : division of the 20 MHz clock                                   |
--                                                                                                |
--              There are also 4 LEDs and 2 buttons on the PCB of the SPEC carrier:               |
--                                    _______________                                             |
--                                   |  O  O  O  O   |   aux LEDs 1, 2, 3, 4                      |
--                                   |   __     __   |                                            |
--                                   |  |__|   |__|  |   aux buttons 1, 2                         |
--                                   |_______________|                                            |
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
    (clk_20mhz_i       : in std_logic;  -- 20  MHz clock
     clk_125mhz_i      : in std_logic;  -- 125 MHz clock
     gnum_rst_i        : in std_logic;  -- reset from the PCI-e, synched with 20 MHz clk
     internal_rst_i    : in std_logic;  -- core internal reset, synched with 125 MHz clk

     -- Signal from the PLL
     pll_status_i       : in std_logic;  -- PLL lock detect

     -- Signals from the buttons on the SPEC PCB
     spec_aux_butt_1_i : in std_logic;  -- SPEC PCB button 1 (PB1)
     spec_aux_butt_2_i : in std_logic;  -- SPEC PCB button 2 (PB2)

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
     tdc_led_trig5_o   : out std_logic; -- TDC  LED 6: Channel 5 input enable

     -- Signals to the LEDs on the SPEC front panel
     spec_led_green_o  : out std_logic; -- SPEC LED 1: PLL lock detect
     spec_led_red_o    : out std_logic; -- SPEC LED 2: division of 20 MHz

     -- Signals to the LEDs on the SPEC PCB
     spec_aux_led_1_o  : out std_logic; -- SPEC PCB LED 1 (LD2)
     spec_aux_led_2_o  : out std_logic; -- SPEC PCB LED 2 (LD3)
     spec_aux_led_3_o  : out std_logic; -- SPEC PCB LED 3 (LD4)
     spec_aux_led_4_o  : out std_logic);-- SPEC PCB LED 4 (LD5)

end leds_manager;


--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of leds_manager is

  signal spec_led_blink_done, spec_led_period_done, tdc_led_blink_done : std_logic;
  signal spec_led_period, visible_blink_length                         : std_logic_vector(g_width-1 downto 0);

begin
---------------------------------------------------------------------------------------------------
--                                     TDC FRONT PANEL LED 1                                     --
---------------------------------------------------------------------------------------------------  
  
---------------------------------------------------------------------------------------------------

  tdc_led_blink_counter: decr_counter
  port map
    (clk_i             => clk_125mhz_i,
     rst_i             => internal_rst_i,
     counter_load_i    => one_hz_p_i,
     counter_top_i     => visible_blink_length,
     counter_is_zero_o => tdc_led_blink_done,
     counter_o         => open);

---------------------------------------------------------------------------------------------------
  tdc_led: process (clk_125mhz_i)
  begin
    if rising_edge (clk_125mhz_i) then
      if internal_rst_i ='1' then
        tdc_led_status_o <= '0';
      elsif one_hz_p_i ='1' then
        tdc_led_status_o <= '1';
      elsif tdc_led_blink_done = '1' then
        tdc_led_status_o <= '0';
      end if;
    end if;
  end process;


---------------------------------------------------------------------------------------------------
--                                    TDC FRONT PANEL LEDs 2-6                                   --
--------------------------------------------------------------------------------------------------- 
---------------------------------------------------------------------------------------------------
  all_outputs: process (clk_125mhz_i)
  begin
    if rising_edge (clk_125mhz_i) then
      tdc_led_trig5_o  <= acam_inputs_en_i(4) and acam_inputs_en_i(7);
      tdc_led_trig4_o  <= acam_inputs_en_i(3) and acam_inputs_en_i(7);
      tdc_led_trig3_o  <= acam_inputs_en_i(2) and acam_inputs_en_i(7);
      tdc_led_trig2_o  <= acam_inputs_en_i(1) and acam_inputs_en_i(7);
      tdc_led_trig1_o  <= acam_inputs_en_i(0) and acam_inputs_en_i(7);
    end if;
  end process;


---------------------------------------------------------------------------------------------------
--                                     SPEC FRONT PANEL LED 1                                    --
--------------------------------------------------------------------------------------------------- 
  spec_led_green_o     <= pll_status_i;


---------------------------------------------------------------------------------------------------
--                                     SPEC FRONT PANEL LED 2                                    --
---------------------------------------------------------------------------------------------------  
---------------------------------------------------------------------------------------------------
  spec_led_period_counter: free_counter
  port map
    (clk_i             => clk_20mhz_i,
     counter_en_i      => '1',
     rst_i             => gnum_rst_i,
     counter_top_i     => spec_led_period,
     counter_is_zero_o => spec_led_period_done,
     counter_o         => open);

    --  --  --  --  --  --  --  --
   spec_led_period     <= c_SPEC_LED_PERIOD_SIM when values_for_simulation else c_SPEC_LED_PERIOD_SYN;

---------------------------------------------------------------------------------------------------
  spec_led_blink_counter: decr_counter
    port map
      (clk_i             => clk_20mhz_i,
       rst_i             => gnum_rst_i,
       counter_load_i    => spec_led_period_done,
       counter_top_i     => visible_blink_length,
       counter_is_zero_o => spec_led_blink_done,
       counter_o         => open);

    --  --  --  --  --  --  --  --
  visible_blink_length <= c_BLINK_LGTH_SIM when values_for_simulation else c_BLINK_LGTH_SYN;

---------------------------------------------------------------------------------------------------
  spec_led: process (clk_20mhz_i)
  begin
    if rising_edge (clk_20mhz_i) then
      if gnum_rst_i ='1' then
        spec_led_red_o <= '0';
      elsif spec_led_period_done ='1' then
        spec_led_red_o <= '1';
      elsif spec_led_blink_done ='1' then
        spec_led_red_o <= '0';
      end if;
    end if;
  end process;


---------------------------------------------------------------------------------------------------
--                                    SPEC PCB LEDs and BUTTONs                                  --
---------------------------------------------------------------------------------------------------
-- Note: all spec_aux signals are active low

---------------------------------------------------------------------------------------------------
  button_with_20MHz_clk: process (clk_20mhz_i)
  begin
    if rising_edge (clk_20mhz_i) then
      spec_aux_led_2_o <= spec_aux_butt_1_i;
      spec_aux_led_1_o <= spec_aux_butt_1_i;
    end if;
  end process;

---------------------------------------------------------------------------------------------------
  button_with_125MHz_clk: process (clk_125mhz_i)
  begin
    if rising_edge (clk_125mhz_i) then
      spec_aux_led_3_o <= spec_aux_butt_2_i;
      spec_aux_led_4_o <= spec_aux_butt_2_i;
    end if;
  end process;


end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------