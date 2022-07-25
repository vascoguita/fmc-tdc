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
--                                    acam_timecontrol_interface                                  |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         acam_timecontrol_interface.vhd                                                    |
--                                                                                                |
-- Description  Interface with the ACAM chip pins for control and timing.                         |
--              the start pulse is sent only once upon the activation of the acquisition,         |
--              synchronously to the utc_p_i                                                      |
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
use IEEE.STD_LOGIC_1164.all;            -- std_logic definitions
use IEEE.NUMERIC_STD.all;     -- conversion functions-- Specific library
-- Specific library
library work;
use work.tdc_core_pkg.all;    -- definitions of types, constants, entities
use work.gencores_pkg.all;


--=================================================================================================
--                       Entity declaration for acam_timecontrol_interface
--=================================================================================================

entity acam_timecontrol_interface is
  port
    -- INPUTS
    -- Signals from the clk_rst_manager unit
    (clk_i                  : in std_logic;  -- 125 MHz clock
     rst_i                  : in std_logic;  -- reset

     -- upc_p from the WRabbit or the local generator 
     utc_p_i : in std_logic;

     -- Signals from the data_engine unit
     state_active_p_i : in std_logic;   -- the core ready to follow the ACAM EF

     -- Signals from the reg_ctrl unit
     activate_acq_p_i   : in std_logic;  -- signal from GN4124/VME to start following the ACAM chip
                                         -- for tstamps aquisition
     deactivate_acq_p_i : in std_logic;  -- acquisition deactivated


     -- OUTPUTS
     -- Signals to the ACAM chip
     start_from_fpga_o : out std_logic;

     stop_dis_o              : out std_logic);

end entity;
  
--=================================================================================================
architecture rtl of acam_timecontrol_interface is

  signal acam_intflag_f_edge_p, stop_dis_d1                      : std_logic;
  signal start_pulse, wait_for_utc, rst_n, wait_for_state_active : std_logic;

--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

---------------------------------------------------------------------------------------------------
--                            IntFlag and ERRflag Input Synchronizers                            --
---------------------------------------------------------------------------------------------------   

  rst_n <= not(rst_i);

---------------------------------------------------------------------------------------------------
--                                  start_from_fpga_o generation                                 --
---------------------------------------------------------------------------------------------------
-- send the start_from_fpga_o after the activate_acq_p_i (coming from the reg_ctrl unit) and
-- after the state_active_p_i (coming from the data_engine unit).
-- The pulse is synchronous to the utc_p_i

  start_pulse_from_fpga : process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i = '1' or deactivate_acq_p_i = '1' then
        wait_for_utc          <= '0';
        start_pulse           <= '0';
        wait_for_state_active <= '0';
        stop_dis_d1           <= '1';
      else
        if activate_acq_p_i = '1' then
          wait_for_utc <= '1';
          start_pulse  <= '0';
        elsif utc_p_i = '1' and wait_for_utc = '1' then
          wait_for_utc          <= '0';
          start_pulse           <= '1';
          wait_for_state_active <= '1';
        elsif wait_for_state_active = '1' and state_active_p_i = '1' then
          -- data_engine starts following ACAM EF
          stop_dis_d1           <= '0';
          wait_for_state_active <= '0';
        else
          start_pulse <= '0';
        end if;
      end if;
    end if;
  end process;

  stop_dis_extra_dff : process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i = '1'  then
        stop_dis_o <= '1';
      else
        stop_dis_o <= stop_dis_d1;
		end if;
	end if;
  end process;

--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  extend_pulse : gc_extend_pulse
    generic map (g_width => 4)
    port map
    (clk_i      => clk_i,
     rst_n_i    => rst_n,
     pulse_i    => start_pulse,
     extended_o => start_from_fpga_o);


end architecture rtl;
--=================================================================================================
--                                        architecture end
--=================================================================================================
---------------------------------------------------------------------------------------------------
--                                      E N D   O F   F I L E
---------------------------------------------------------------------------------------------------
