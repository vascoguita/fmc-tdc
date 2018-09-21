--_________________________________________________________________________________________________
--                                                                                                |
--                                           |SPEC TDC|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                        spec_top_fmc_tdc                                        |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         spec_top_fmc_tdc.vhd                                                              |
--                                                                                                |
-- Description  TDC top level for a SPEC carrier. Figure 1 shows the architecture of the unit.    |
--                                                                                                |
--              For the communication with the PCIe, the ohwr.org GN4124 core is instantiated.    |
--                                                                                                |
--              The TDC mezzanine core is instantiated for the communication with the TDC board.  |
--              The VIC core is forwarding the interrupts coming from the TDC mezzanine core to   |
--                the GN4124 core.                                                                |
--              The carrier_info module provides general information on the SPEC PCB version, PLLs |
--                locking state etc.                                                              |
--              The 1-Wire core provides communication with the SPEC Thermometer&UniqueID chip.   |
--              All the cores communicate with the GN4124 core through the SDB crossbar. The SDB  |
--              crossbar is responsible for managing the acess to the GN4124 core.                |
--                                                                                                |
--              The speed of all the cores (TDC mezzanine, VIC, carrier csr, 1-Wire as well as    |
--              the GN4124 core) is 125MHz.                                                       |
--                                                                                                |
--              The 125MHz clock comes from the PLL located on the TDC mezzanine board.           |
--              The clks_rsts_manager unit is responsible for automatically configuring the PLL   |
--              upon the FPGA startup or after a PCIe reset, using the 20MHz VCXO on the SPEC     |
--              carrier board. The clks_rsts_manager is keeping all the rest of the logic under   |
--              reset until the PLL gets locked.                                                  |
--                                                                                                |
--                __________________________________________________________________              |
--   ________    |                                           ___        _____       |             |
--  |        |   |            ___________________           |   |      |     |      |             |
--  |  PLL   |<->|           | clks rsts manager |          |   |      |     |      |             |
--  |  DAC   |   |           |___________________|          |   |      |     |      |             |
--  |        |   |       ____________________________       |   |      |     |      |             |
--  |        |   |      |                            | \    |   |      |     |      |             |
--  |  ACAM  |<->|      |       TDC mezzanine        |  \   |   |      |     |      |             |
--  |________|   |   |--|____________________________|   \  |   |      |  G  |      |             |
--   TDC mezz    |   |                                    \ |   |      |     |      |             |
--               |   |   ____________________________       | S |      |  N  |      |             |
--               |   |->|                            |      |   |      |     |      |             |
--               |      | Vector Interrupt Controller| ---- | D | <--> |  4  |      |             |
--               |      |____________________________|      |   |      |     |      |             |
--               |                                          | B |      |  1  |      |             |
--               |       ____________________________       |   |      |     |      |             |
--               |      |                            |      |   |      |  2  |      |             |
-- SPEC 1Wire <->|      |          1-Wire            | ---- |   |      |     |      |             |
--               |      |____________________________|      |   |      |  4  |      |             |
--               |                                        / |   |      |     |      |             |
--               |       ____________________________    /  |   |      |     |      |             |
--               |      |                            |  /   |   |      |     |      |             |
--               |      |        carrier_info         | /    |   |      |     |      |             |
--               |      |____________________________|      |   |      |     |      |             |
--               |                                          |___|      |_____|      |             |
--               |                                                                  |             |
--               |      ______________________________________________              |             |
-- SPEC LEDs  <->|     |___________________LEDs_______________________|             |             |
--               |                                                                  |             |
--               |__________________________________________________________________|             |
--                                                                                                |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
--              Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
-- Date         01/2014                                                                           |
-- Version      v5 (see sdb_meta_pkg)                                                             |
-- Depends on                                                                                     |
--
----------------                                                                                  |
-- Last changes                                                                                   |
--     05/2011  v1  GP  First version                                                             |
--     06/2012  v2  EG  Revamping; Comments added, signals renamed                                |
--                      removed LEDs from top level                                               |
--                      new GN4124 core integrated                                                |
--                      carrier 1 wire master added                                               |
--                      mezzanine I2C master added                                                |
--                      mezzanine 1 wire master added                                             |
--                      interrupts generator added                                                |
--                      changed generation of rst_125m_mezz                                         |
--                      DAC reconfiguration+needed regs added                                     |
--     06/2012  v3  EG  Changes for v2 of TDC mezzanine                                           |
--                      Several pinout changes,                                                   |
--                      acam_ref_clk LVDS instead of CMOS,                                        |
--                      no PLL_LD only PLL_STATUS                                                 |
--     04/2013  v4  EG  added SDB; fixed bugs in data_formatting; added carrier CSR information   |
--     01/2014  v5  EG  added VIC and EIC in the TDC mezzanine                                    |
--                                                                                                |
----------------------------------------------/!\-------------------------------------------------|
-- Note for eva: Remember the design is synthesised with Synplify Premier with DP (tdc_syn.prj)   |
-- For PAR use the tdc_par_script.tcl commands in Xilinx ISE!                                     |
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
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tdc_core_pkg.all;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;

library UNISIM;
use UNISIM.vcomponents.all;

--=================================================================================================
--                            Entity declaration for spec_top_fmc_tdc
--=================================================================================================
entity fmc_tdc_wrapper is
  generic
    (
      -- reduces some timeouts to speed up simulation
      g_simulation                  : boolean := false;
      -- implement direct TDC timestamp readout FIFO, used in the WR Node projects
      g_with_direct_readout         : boolean := false;
      g_use_dma_readout             : boolean := false;
      g_use_fifo_readout            : boolean := false;
      g_use_fake_timestamps_for_sim : boolean := false
      );
  port
    (
      clk_sys_i   : in std_logic;
      rst_sys_n_i : in std_logic;
      rst_n_a_i   : in std_logic;

      -- Interface with the PLL AD9516 and DAC AD5662 on TDC mezzanine
      pll_sclk_o       : out std_logic;  -- SPI clock
      pll_sdi_o        : out std_logic;  -- data line for PLL and DAC
      pll_cs_o         : out std_logic;  -- PLL chip select
      pll_dac_sync_o   : out std_logic;  -- DAC chip select
      pll_sdo_i        : in  std_logic;  -- not used for the moment
      pll_status_i     : in  std_logic;  -- PLL Digital Lock Detect, active high
      tdc_clk_125m_p_i : in  std_logic;  -- 125 MHz differential clock: system clock
      tdc_clk_125m_n_i : in  std_logic;  -- 125 MHz differential clock: system clock
      acam_refclk_p_i  : in  std_logic;  -- 31.25 MHz differential clock: ACAM ref clock
      acam_refclk_n_i  : in  std_logic;  -- 31.25 MHz differential clock: ACAM ref clock

      -- Timing interface with the ACAM on TDC mezzanine
      start_from_fpga_o : out   std_logic;  -- start signal
      err_flag_i        : in    std_logic;  -- error flag
      int_flag_i        : in    std_logic;  -- interrupt flag
      start_dis_o       : out   std_logic;  -- start disable, not used
      stop_dis_o        : out   std_logic;  -- stop disable, not used
      -- Data interface with the ACAM on TDC mezzanine
      data_bus_io       : inout std_logic_vector(27 downto 0);
      address_o         : out   std_logic_vector(3 downto 0);
      cs_n_o            : out   std_logic;  -- chip select for ACAM
      oe_n_o            : out   std_logic;  -- output enable for ACAM
      rd_n_o            : out   std_logic;  -- read  signal for ACAM
      wr_n_o            : out   std_logic;  -- write signal for ACAM
      ef1_i             : in    std_logic;  -- empty flag iFIFO1
      ef2_i             : in    std_logic;  -- empty flag iFIFO2

      -- Enable of input Logic on TDC mezzanine
      enable_inputs_o : out std_logic;  -- enables all 5 inputs
      term_en_1_o     : out std_logic;  -- Ch.1 termination enable of 50 Ohm termination
      term_en_2_o     : out std_logic;  -- Ch.2 termination enable of 50 Ohm termination
      term_en_3_o     : out std_logic;  -- Ch.3 termination enable of 50 Ohm termination
      term_en_4_o     : out std_logic;  -- Ch.4 termination enable of 50 Ohm termination
      term_en_5_o     : out std_logic;  -- Ch.5 termination enable of 50 Ohm termination

      -- LEDs on TDC mezzanine
      tdc_led_status_o : out std_logic;  -- amber led on front pannel, division of 125 MHz tdc_clk
      tdc_led_trig1_o  : out std_logic;  -- amber led on front pannel, Ch.1 enable
      tdc_led_trig2_o  : out std_logic;  -- amber led on front pannel, Ch.2 enable
      tdc_led_trig3_o  : out std_logic;  -- amber led on front pannel, Ch.3 enable
      tdc_led_trig4_o  : out std_logic;  -- amber led on front pannel, Ch.4 enable
      tdc_led_trig5_o  : out std_logic;  -- amber led on front pannel, Ch.5 enable


      -- I2C EEPROM interface on TDC mezzanine
      mezz_scl_o : out std_logic;
      mezz_sda_o : out std_logic;

      mezz_scl_i : in std_logic;
      mezz_sda_i : in std_logic;


      -- 1-wire interface on TDC mezzanine
      mezz_one_wire_b : inout std_logic;

      ---------------------------------------------------------------------------
      -- WhiteRabbit time/frequency sync (see WR Core documentation)
      ---------------------------------------------------------------------------

      tm_link_up_i         : in  std_logic;
      tm_time_valid_i      : in  std_logic;
      tm_cycles_i          : in  std_logic_vector(27 downto 0);
      tm_tai_i             : in  std_logic_vector(39 downto 0);
      tm_clk_aux_lock_en_o : out std_logic;
      tm_clk_aux_locked_i  : in  std_logic;
      tm_clk_dmtd_locked_i : in  std_logic;
      tm_dac_value_i       : in  std_logic_vector(23 downto 0);
      tm_dac_wr_i          : in  std_logic;


      slave_i : in  t_wishbone_slave_in;
      slave_o : out t_wishbone_slave_out;

      direct_slave_i : in  t_wishbone_slave_in := cc_dummy_slave_in;
      direct_slave_o : out t_wishbone_slave_out;

      dma_wb_o : out t_wishbone_master_out;
      dma_wb_i : in  t_wishbone_master_in := cc_dummy_master_in;

      irq_o : out std_logic;

      -- local PLL clock output (for WR PTP Core clock disciplining)
      clk_125m_tdc_o : out std_logic;


      sim_timestamp_i       : in  t_tdc_timestamp := c_dummy_timestamp;
      sim_timestamp_valid_i : in  std_logic       := '0';
      sim_timestamp_ready_o : out std_logic
      );

end fmc_tdc_wrapper;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of fmc_tdc_wrapper is

  component fmc_tdc_direct_readout is
    port (
      clk_tdc_i             : in  std_logic;
      rst_tdc_n_i           : in  std_logic;
      clk_sys_i             : in  std_logic;
      rst_sys_n_i           : in  std_logic;
      direct_timestamp_i    : in  std_logic_vector(127 downto 0);
      direct_timestamp_wr_i : in  std_logic;
      direct_slave_i        : in  t_wishbone_slave_in;
      direct_slave_o        : out t_wishbone_slave_out);
  end component fmc_tdc_direct_readout;

  -- WRabbit clocks
  signal clk_125m_mezz                  : std_logic;
  signal rst_125m_mezz_n, rst_125m_mezz : std_logic;
  signal acam_refclk_r_edge_p           : std_logic;
  -- DAC configuration through PCIe/VME
  signal send_dac_word_p                : std_logic;
  signal dac_word                       : std_logic_vector(23 downto 0);
  -- WRabbit time

  signal pll_sclk, pll_sdi, pll_dac_sync : std_logic;

  signal fmc_eic_irq       : std_logic;
  signal fmc_eic_irq_synch : std_logic_vector(1 downto 0);

  signal tdc_scl_out, tdc_scl_oen, tdc_sda_out, tdc_sda_oen : std_logic;

  signal direct_timestamp    : std_logic_vector(127 downto 0);
  signal direct_timestamp_wr : std_logic;

  constant c_cnx_slave_ports  : integer := 2;
  constant c_cnx_master_ports : integer := 2;

  constant c_master_wrnc : integer := 0;
  constant c_master_host : integer := 1;

  constant c_slave_direct : integer := 0;
  constant c_slave_regs   : integer := 1;

  signal cnx_master_in  : t_wishbone_master_in_array(c_cnx_master_ports-1 downto 0);
  signal cnx_master_out : t_wishbone_master_out_array(c_cnx_master_ports-1 downto 0);

  constant c_cfg_base_addr : t_wishbone_address_array(c_cnx_master_ports-1 downto 0) :=
    (c_slave_direct => x"00008000",     -- Direct I/O
     c_slave_regs   => x"00000000");    -- Mezzanine regs

  constant c_cfg_base_mask : t_wishbone_address_array(c_cnx_master_ports-1 downto 0) :=
    (c_slave_direct => x"00008000",
     c_slave_regs   => x"00008000");

  signal wr_dac_din, wr_dac_sclk, wr_dac_sync_n : std_logic;

  signal pll_cs : std_logic;


begin

  gen_with_direct_readout : if g_with_direct_readout generate

    cmp_mux_host_registers : xwb_crossbar
      generic map (
        g_num_masters => c_cnx_slave_ports,
        g_num_slaves  => c_cnx_master_ports,
        g_registered  => true,
        g_address     => c_cfg_base_addr,
        g_mask        => c_cfg_base_mask)
      port map (
        clk_sys_i => clk_sys_i,
        rst_n_i   => rst_sys_n_i,

        slave_i(c_master_wrnc) => direct_slave_i,
        slave_i(c_master_host) => slave_i,

        slave_o(c_master_wrnc) => direct_slave_o,
        slave_o(c_master_host) => slave_o,

        master_i => cnx_master_in,
        master_o => cnx_master_out);

    cmp_direct_readout : fmc_tdc_direct_readout
      port map (
        clk_tdc_i             => clk_125m_mezz,
        rst_tdc_n_i           => rst_125m_mezz_n,
        clk_sys_i             => clk_sys_i,
        rst_sys_n_i           => rst_sys_n_i,
        direct_timestamp_i    => direct_timestamp,
        direct_timestamp_wr_i => direct_timestamp_wr,
        direct_slave_i        => cnx_master_out(c_slave_direct),
        direct_slave_o        => cnx_master_in(c_slave_direct));


  end generate gen_with_direct_readout;

  gen_without_direct_readout : if not g_with_direct_readout generate
    cnx_master_out(c_slave_regs) <= slave_i;
    slave_o                      <= cnx_master_in(c_slave_regs);
  end generate gen_without_direct_readout;


  cmp_tdc_clks_rsts_mgment : entity work.clks_rsts_manager
    generic map
    (nb_of_reg    => 68,
     g_simulation => g_simulation)
    port map
    (clk_sys_i              => clk_sys_i,
     acam_refclk_p_i        => acam_refclk_p_i,
     acam_refclk_n_i        => acam_refclk_n_i,
     tdc_125m_clk_p_i       => tdc_clk_125m_p_i,
     tdc_125m_clk_n_i       => tdc_clk_125m_n_i,
     rst_n_i                => rst_n_a_i,
     pll_sdo_i              => pll_sdo_i,
     pll_status_i           => pll_status_i,
     send_dac_word_p_i      => '0',
     dac_word_i             => x"000000",
     acam_refclk_r_edge_p_o => acam_refclk_r_edge_p,
     wrabbit_dac_value_i    => x"000000",
     wrabbit_dac_wr_p_i     => '0',
     internal_rst_o         => rst_125m_mezz,
     pll_cs_n_o             => pll_cs,
     pll_dac_sync_n_o       => pll_dac_sync,
     pll_sdi_o              => pll_sdi,
     pll_sclk_o             => pll_sclk,
     tdc_125m_clk_o         => clk_125m_mezz,
     pll_status_o           => open);


  U_WR_DAC : gc_serial_dac
    generic map (
      g_num_data_bits  => 16,
      g_num_extra_bits => 8,
      g_num_cs_select  => 1,
      g_sclk_polarity  => 0)
    port map (
      clk_i         => clk_sys_i,
      rst_n_i       => rst_sys_n_i,
      value_i       => tm_dac_value_i(15 downto 0),
      cs_sel_i      => "1",
      load_i        => tm_dac_wr_i,
      sclk_divsel_i => "010",
      dac_cs_n_o(0) => wr_dac_sync_n,
      dac_sclk_o    => wr_dac_sclk,
      dac_sdata_o   => wr_dac_din);



  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  rst_125m_mezz_n <= not rst_125m_mezz;
  pll_dac_sync_o  <= wr_dac_sync_n;
  pll_sdi_o       <= pll_sdi  when pll_cs = '0' else wr_dac_din;
  pll_sclk_o      <= pll_sclk when pll_cs = '0' else wr_dac_sclk;
  pll_cs_o        <= pll_cs;



  clk_125m_tdc_o <= clk_125m_mezz;
---------------------------------------------------------------------------------------------------
--                                            TDC BOARD                                          --
---------------------------------------------------------------------------------------------------
  cmp_tdc_mezz : entity work.fmc_tdc_mezzanine
    generic map
    (g_span                        => 32,
     g_width                       => 32,
     g_simulation                  => g_simulation,
     g_use_fifo_readout            => g_use_fifo_readout,
     g_use_dma_readout             => g_use_dma_readout,
     g_use_fake_timestamps_for_sim => g_use_fake_timestamps_for_sim)
    port map
    -- 62M5 clk and reset
    (clk_sys_i   => clk_sys_i,
     rst_sys_n_i => rst_sys_n_i,
     -- 125M clk and reset
     clk_tdc_i   => clk_125m_mezz,
     rst_tdc_n_i => rst_125m_mezz_n,

     -- Wishbone
     slave_i => cnx_master_out(c_slave_regs),
     slave_o => cnx_master_in(c_slave_regs),

     dma_wb_i => dma_wb_i,
     dma_wb_o => dma_wb_o,

     -- Interrupt line from EIC
     wb_irq_o => irq_o,

     -- Configuration of the DAC on the TDC mezzanine, non White Rabbit
     acam_refclk_r_edge_p_i => acam_refclk_r_edge_p,
     send_dac_word_p_o      => send_dac_word_p,
     dac_word_o             => dac_word,
     -- ACAM interface
     start_from_fpga_o      => start_from_fpga_o,
     err_flag_i             => err_flag_i,
     int_flag_i             => int_flag_i,
     start_dis_o            => start_dis_o,
     stop_dis_o             => stop_dis_o,
     data_bus_io            => data_bus_io,
     address_o              => address_o,
     cs_n_o                 => cs_n_o,
     oe_n_o                 => oe_n_o,
     rd_n_o                 => rd_n_o,
     wr_n_o                 => wr_n_o,
     ef1_i                  => ef1_i,
     ef2_i                  => ef2_i,
     -- Input channels enable
     enable_inputs_o        => enable_inputs_o,
     term_en_1_o            => term_en_1_o,
     term_en_2_o            => term_en_2_o,
     term_en_3_o            => term_en_3_o,
     term_en_4_o            => term_en_4_o,
     term_en_5_o            => term_en_5_o,
     -- LEDs on TDC mezzanine
     tdc_led_status_o       => tdc_led_status_o,
     tdc_led_trig1_o        => tdc_led_trig1_o,
     tdc_led_trig2_o        => tdc_led_trig2_o,
     tdc_led_trig3_o        => tdc_led_trig3_o,
     tdc_led_trig4_o        => tdc_led_trig4_o,
     tdc_led_trig5_o        => tdc_led_trig5_o,
     -- WISHBONE interface with the GN4124 core

     -- White Rabbit
     wrabbit_link_up_i         => tm_link_up_i,
     wrabbit_time_valid_i      => tm_time_valid_i,
     wrabbit_cycles_i          => tm_cycles_i,
     wrabbit_utc_i             => tm_tai_i(31 downto 0),
     wrabbit_clk_aux_lock_en_o => tm_clk_aux_lock_en_o,
     wrabbit_clk_aux_locked_i  => tm_clk_aux_locked_i,
     wrabbit_clk_dmtd_locked_i => '1',  -- FIXME: fan out real signal from the WRCore
     wrabbit_dac_value_i       => tm_dac_value_i,
     wrabbit_dac_wr_p_i        => tm_dac_wr_i,

     -- EEPROM I2C on TDC mezzanine
     i2c_scl_oen_o            => tdc_scl_oen,
     i2c_scl_i                => mezz_scl_i,
     i2c_sda_oen_o            => tdc_sda_oen,
     i2c_sda_i                => mezz_sda_i,
     i2c_scl_o                => tdc_scl_out,
     i2c_sda_o                => tdc_sda_out,
     -- 1-Wire on TDC mezzanine
     onewire_b                => mezz_one_wire_b,
     direct_timestamp_o       => direct_timestamp,
     direct_timestamp_valid_o => direct_timestamp_wr,

     sim_timestamp_ready_o => sim_timestamp_ready_o,
     sim_timestamp_valid_i => sim_timestamp_valid_i,
     sim_timestamp_i       => sim_timestamp_i);


  mezz_scl_o <= '0' when tdc_scl_out = '0' and tdc_scl_oen = '0' else '1';
  mezz_sda_o <= '0' when tdc_sda_out = '0' and tdc_sda_oen = '0' else '1';



end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
