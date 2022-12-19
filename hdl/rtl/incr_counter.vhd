-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+


---------------------------------------------------------------------------------------------------
-- Title      :  incriment counter
---------------------------------------------------------------------------------------------------
-- Description: Stop counter. Configurable "counter_top_i" and "width".
--              "Current count value" and "counting done" signals available.
--              "Counting done" signal asserted simultaneous to"current count value=counter_top_i"
--              Needs a rst_i to restart.
---------------------------------------------------------------------------------------------------


--=================================================================================================
--                                       Libraries & Packages
--=================================================================================================

-- Standard library
library IEEE;
use IEEE.STD_LOGIC_1164.all; -- std_logic definitions
use IEEE.NUMERIC_STD.all;    -- conversion functions


--=================================================================================================
--                            Entity declaration for incr_counter
--=================================================================================================

entity incr_counter is
  generic
    (width             : integer := 32);                        -- default size
  port
  -- INPUTS
     -- Signals from the clk_rst_manager
    (clk_i             : in std_logic;
     rst_i             : in std_logic;

     -- Signals from any unit
     counter_top_i     : in std_logic_vector(width-1 downto 0); -- max value to be counted; when reached
                                                                -- counter stays at it, until a reset
     counter_incr_en_i : in std_logic;                          -- enables counting

  -- OUTPUTS
     -- Signals to any unit
     counter_o         : out std_logic_vector(width-1 downto 0);
     counter_is_full_o : out std_logic);                        -- counter reahed counter_top_i value

  end incr_counter;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of incr_counter is

  constant zeroes : unsigned(width-1 downto 0) := (others=>'0');
  signal counter  : unsigned(width-1 downto 0) := (others=>'0'); -- init to avoid sim warnings


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

  incr_counting: process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i = '1' then
        counter_is_full_o   <= '0';
        counter             <= zeroes;

      elsif counter = unsigned (counter_top_i) then
        counter_is_full_o   <= '1';
        counter             <= unsigned (counter_top_i);

      elsif counter_incr_en_i ='1' then

        if counter = unsigned(counter_top_i) - "1" then
          counter_is_full_o <= '1';
          counter           <= counter + "1";
        else
          counter_is_full_o <= '0';
          counter           <= counter + "1";
        end if;

      end if;
    end if;
  end process;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  counter_o                 <= std_logic_vector(counter);


end architecture rtl;
--=================================================================================================
--                                        architecture end
--=================================================================================================
---------------------------------------------------------------------------------------------------
--                                      E N D   O F   F I L E
---------------------------------------------------------------------------------------------------
