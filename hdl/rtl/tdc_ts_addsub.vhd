-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

-------------------------------------------------------------------------------
-- Title      : Pipelined timestamp subtractor
-- Project    : FMC TDC Core
-------------------------------------------------------------------------------
-- File       : tdc_ts_sub.vhd
-- Author     : Tomasz Wlostowski
-- Company    : CERN
-- Created    : 2011-08-29
-- Last update: 2019-09-29
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Pipelined timestamp adder with re-normalization of the result.
-- Adds a to b, producing normalized timestamp q. A timestmap is normalized when
-- the 0 <= frac < g_frac_range, 0 <= coarse <= g_coarse_range-1 and utc >= 0.
-- For correct operation of renormalizer, input timestamps must meet the
-- following constraints:
-- 1. 0 <= a_tai + b_tai < 2**32 - 1
-- 2. 0 <= a_frac < g_frac_range
-- 3. -g_frac_range / 2 <= b_frac < g_frac_range / 2
-- 4. -g_coarse_range+1 <= (a_coarse + b_coarse) <= 3*g_coarse_range-1
-------------------------------------------------------------------------------
--
-- Copyright (c) 2011 CERN / BE-CO-HT
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tdc_core_pkg.all;

-- adds q = a + b, b can be a NEGATIVE timestamp (i.e. a negative offset)
entity tdc_ts_addsub is
  generic(
    g_frac_range : integer := 4096;
    g_coarse_range : integer := 125000000
    );

  port(
    clk_i   : in std_logic;
    rst_n_i : in std_logic;

    valid_i  : in std_logic;  -- when HI, a_* and b_* contain valid timestamps
    enable_i : in std_logic := '1';     -- pipeline enable

    a_i : in t_tdc_timestamp;
    b_i : in t_tdc_timestamp;

    valid_o    : out std_logic;
    q_o    : out t_tdc_timestamp
    );
end tdc_ts_addsub;

architecture rtl of tdc_ts_addsub is

  constant c_NUM_PIPELINE_STAGES : integer := 4;

  type t_internal_sum is record
    tai     : signed(32 downto 0);
    coarse  : signed(31 downto 0);
    frac    : signed(15 downto 0);
    channel : std_logic_vector(2 downto 0);
    meta    : std_logic_vector(31 downto 0);
    slope   : std_logic;
  end record;

  type t_internal_sum_array is array (integer range <>) of t_internal_sum;

  signal pipe : std_logic_vector(c_NUM_PIPELINE_STAGES-1 downto 0);
  signal sums : t_internal_sum_array(0 to c_NUM_PIPELINE_STAGES-1);

  signal ovf_frac   : std_logic;
  signal unf_frac   : std_logic;
  signal ovf_coarse : std_logic_vector(1 downto 0);
  signal unf_coarse : std_logic_vector(1 downto 0);

begin  -- rtl

  -- Pipeline stage 0: just subtract the two timestamps field by field
  p_stage0 : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        pipe(0) <= '0';
      elsif(enable_i = '1') then
        pipe(0) <= valid_i;

        sums(0).channel <= a_i.channel;
        sums(0).slope   <= a_i.slope;
        sums(0).meta    <= a_i.meta;

        sums(0).tai    <= signed(resize(unsigned(a_i.tai) + unsigned(b_i.tai), 33));
        sums(0).coarse <= signed(a_i.coarse) + signed(b_i.coarse);
        sums(0).frac   <= signed(resize(signed('0' & a_i.frac), 16) + resize(signed(b_i.frac), 16));
      else
        pipe(0) <= '0';
      end if;
    end if;
  end process;

  unf_frac <= '1' when sums(0).frac < 0 else '0';
  ovf_frac <= '1' when sums(0).frac >= g_frac_range else '0';

  -- Pipeline stage 1: check the fractional difference for underflow and eventually adjust
  -- the coarse difference
  p_stage1 : process(clk_i)
  begin
    if rising_edge(clk_i) then

      if rst_n_i = '0' then
        pipe(1) <= '0';
      else
        pipe(1) <= pipe(0);

        sums(1) <= sums(0);
        sums(1) <= sums(0);
        sums(1) <= sums(0);

        if(ovf_frac = '1') then
          sums(1).frac   <= sums(0).frac - g_frac_range;
          sums(1).coarse <= sums(0).coarse + 1;
        elsif (unf_frac = '1') then
          sums(1).frac   <= sums(0).frac + g_frac_range;
          sums(1).coarse <= sums(0).coarse - 1;
        else
          sums(1).frac   <= sums(0).frac;
          sums(1).coarse <= sums(0).coarse;
        end if;

      end if;
    end if;
  end process;


  -- Pipeline stage 2: check the coarse sum for under/overflows
  p_stage2 : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        pipe(2) <= '0';
      else

        sums(2) <= sums(1);
        pipe(2) <= pipe(1);

        if(sums(1).coarse < 0) then
          unf_coarse <= "10";
        elsif(sums(1).coarse <= -g_coarse_range) then
          unf_coarse <= "01";
        else
          unf_coarse <= "00";
        end if;

        if ( sums(1).coarse >= g_coarse_range ) then
          ovf_coarse <= "10";
        elsif ( sums(1).coarse >= 2*g_coarse_range ) then
          ovf_coarse <= "01";
        else
          ovf_coarse <= "00";
        end if;

      end if;
    end if;
  end process;

  -- Pipeline stage 3: adjust the coarse & TAI sums according to normalize the
  -- previously detected under/overflows
  p_stage3 : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        pipe(3) <= '0';
      else

        pipe(3) <= pipe(2);
        sums(3) <= sums(2);

        if(unf_coarse = "10") then
          sums(3).coarse <= sums(2).coarse + g_coarse_range;
          sums(3).tai    <= sums(2).tai - 1;
        elsif(unf_coarse = "01") then
          sums(3).coarse <= sums(2).coarse + 2*g_coarse_range;
          sums(3).tai    <= sums(2).tai - 2;
        elsif(ovf_coarse = "10" ) then
          sums(3).coarse <= sums(2).coarse - g_coarse_range;
          sums(3).tai    <= sums(2).tai + 1;
        elsif(ovf_coarse = "01") then
          sums(3).coarse <= sums(2).coarse - 2*g_coarse_range;
          sums(3).tai    <= sums(2).tai + 2;
        else
          sums(3).coarse <= sums(2).coarse;
          sums(3).tai    <= sums(2).tai;
        end if;

      end if;
    end if;
  end process;

  -- clip the extra bits and output the result
  valid_o     <= pipe(c_NUM_PIPELINE_STAGES-1);
  q_o.tai     <= std_logic_vector(sums(c_NUM_PIPELINE_STAGES-1).tai(31 downto 0));
  q_o.coarse  <= std_logic_vector(sums(c_NUM_PIPELINE_STAGES-1).coarse(31 downto 0));
  q_o.frac    <= std_logic_vector(sums(c_NUM_PIPELINE_STAGES-1).frac(11 downto 0));
  q_o.slope   <= sums(c_NUM_PIPELINE_STAGES-1).slope;
  q_o.meta    <= sums(c_NUM_PIPELINE_STAGES-1).meta;
  q_o.channel <= sums(c_NUM_PIPELINE_STAGES-1).channel;
end rtl;
