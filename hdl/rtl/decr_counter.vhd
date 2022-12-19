-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

---------------------------------------------------------------------------------------------------
-- Title      :  Free-running counter
---------------------------------------------------------------------------------------------------
-- Description  Stop counter. Configurable "counter_top_i" and "width".
--              "Current count value" and "counting done" signals available.
--              "Counter done" signal asserted simultaneous to "current count value = 0".
--              Countdown is launched each time "counter_load_i" is asserted for one clock tick.
---------------------------------------------------------------------------------------------------


--=================================================================================================
--                                       Libraries & Packages
--=================================================================================================

-- Standard library
library IEEE;
use IEEE.STD_LOGIC_1164.all; -- std_logic definitions
use IEEE.NUMERIC_STD.all;    -- conversion functions


--=================================================================================================
--                            Entity declaration for decr_counter
--=================================================================================================

entity decr_counter is

  generic
    (width             : integer := 32);                        -- default size
  port
  -- INPUTS
     -- Signals from the clk_rst_manager
    (clk_i             : in std_logic;
     rst_i             : in std_logic;

     -- Signals from any unit
     counter_load_i    : in std_logic;                          -- loads counter with counter_top_i value
     counter_top_i     : in std_logic_vector(width-1 downto 0); -- counter start value


  -- OUTPUTS
     -- Signals to any unit
     counter_o         : out std_logic_vector(width-1 downto 0);
     counter_is_zero_o : out std_logic);                        -- counter empty indication

end decr_counter;


--=================================================================================================
--                                    architecture declaration
--=================================================================================================

architecture rtl of decr_counter is

  constant zeroes : unsigned(width-1 downto 0):=(others=>'0');
  signal one      : unsigned(width-1 downto 0);
  signal counter  : unsigned(width-1 downto 0) := (others=>'0'); -- init to avoid sim warnings


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

  decr_counting: process (clk_i)
  begin
    if rising_edge (clk_i) then

      if rst_i = '1' then
        counter_is_zero_o <= '0';
        counter           <= zeroes;

      elsif counter_load_i = '1' then
        counter_is_zero_o <= '0';
        counter           <= unsigned(counter_top_i) - "1";

      elsif counter = zeroes then
        counter_is_zero_o <= '0';
        counter           <= zeroes;

      elsif counter = one then
        counter_is_zero_o <= '1';
        counter           <= counter - "1";

      else
        counter_is_zero_o <= '0';
        counter           <= counter - "1";
      end if;
    end if;
  end process;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  counter_o   <= std_logic_vector(counter);
  one         <= zeroes + "1";


end architecture rtl;
--=================================================================================================
--                                        architecture end
--=================================================================================================
---------------------------------------------------------------------------------------------------
--                                      E N D   O F   F I L E
---------------------------------------------------------------------------------------------------
