--_________________________________________________________________________________________________
--                                                                                                |
--                                           |SPEC TDC|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                         wr_spec_tdc                                            |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         wr_spec_tdc.vhd                                                                   |
--                                                                                                |
-- Description  TDC top level with White Rabbit support for a SPEC carrier.                       |
--              Figure 1 shows the architecture of the unit.                                      |
--                                                                                                |
--              For the communication with the PCIe, the ohwr.org GN4124 core is instantiated.    |
--                                                                                                |
--              The TDC mezzanine core is instantiated for the communication with the TDC board.  |
--              The White Rabbit core is controlling the DAC on each TDC mezzanine; the DAC is in |
--              turn controlling the PLL frequency. Once the PLL is synchronized to White Rabbit, |
--              the TDC core starts using the White Rabbit UTC for the timestamps calculations.   |
--              The VIC core is forwarding the interrupts coming from the TDC mezzanine core to   |
--                the GN4124 core.                                                                |
--              The carrier_info module provides general information on the SPEC PCB version, PLLs|
--                locking state etc.                                                              |
--              All the cores communicate with the GN4124 core through the SDB crossbar. The SDB  |
--              crossbar is responsible for managing the acess to the GN4124 core.                |
--                                                                                                |
--              The TDC mezzanine core is running at 125 MHz. Like this the TDC core can keep up  |
--              to speed with the maximum speed that the ACAM can be receiving timestamps.        |
--              All the other cores (White Rabbit, VIC, carrier csr, 1-Wire as well as the GN4124 |
--              WISHBONE) are running at 62.5 MHz                                                 |
--                                                                                                |
--              The 62.5MHz clock comes from an internal Xilinx FPGA PLL, using the 20MHz VCXO of |
--              the SPEC board.                                                                   |
--              The 125MHz clock for each TDC mezzanine comes from the PLL located on it.         |
--              A clks_rsts_manager unit is responsible for automatically configuring the PLL upon|
--              the FPGA startup, using the 62.5MHz clock. The clks_rsts_manager is keeping the   |
--              the TDC mezzanine core under reset until the respective PLL gets locked.          |
--                                                                                                |
--                ___________________________________________________________________________     |
--               |                                                                           |    |
--               |       ____________________________                 ___        _____       |    |
--               |      |                            |               |   |      |     |      |    |
--        |------|------|  WRabbit core, PHY, DAC    |  <----------> |   |      |     |      |    |
--       \/      |      |____________________________|               |   |      |     |      |    |
--   ________    |                            62.5MHz                |   |      |     |      |    |
--  |        |   |                                                   |   |      |     |      |    |
--  |  DAC   |<->|                                                   |   |      |  G  |      |    |
--  |  PLL   |                                                       |   |      |     |      |    |
--  |        |   |       ____________________________                | S |      |  N  |      |    |
--  |        |   |      |                            |               |   |      |     |      |    |
--  |  ACAM  |<->|------|       TDC wrapper          |<------------> |   |      |  4  |      |    |
--  |________|   |   |--|____________________________|               | D |      |     |      |    |
--   TDC mezz    |   |                        62.5MHz                |   |      |  1  |      |    |
--               |   |   ____________________________                |   |      |     |      |    |
--               |   |->|                            |               | B |      |  2  |      |    |
--               |      | Vector Interrupt Controller| <---------->  |   | <--> |     |      |    |
--               |      |____________________________|               |   |      |  4  |      |    |
--               |                            62.5MHz                |   |      |     |      |    |
--               |       ____________________________                |   |      |     |      |    |
--               |      |                            |               |   |      |     |      |    |
--               |      |        carrier_info        | <---------->  |   |      |     |      |    |
--               |      |____________________________|               |   |      |     |      |    |
--               |                            62.5MHz                |___|      |_____|      |    |
--               |                                                                           |    |
--               |      ______________________________________________                       |    |
-- SPEC LEDs  <->|     |___________________LEDs_______________________|                      |    |
--               |                                                                           |    |
--               |___________________________________________________________________________|    |
--                                                                                                |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
--              Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
--              Grzegorz Daniluk  (Grzegorz.Daniluk@cern.ch)
-- Date         06/2014                                                                           |
-- Version      v6                                                                                |
-- Depends on                                                                                     |
--                                                                                                |
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
--                      changed generation of rst_125m_mezz                                       |
--                      DAC reconfiguration+needed regs added                                     |
--     06/2012  v3  EG  Changes for v2 of TDC mezzanine                                           |
--                      Several pinout changes,                                                   |
--                      acam_ref_clk LVDS instead of CMOS,                                        |
--                      no PLL_LD only PLL_STATUS                                                 |
--     04/2013  v4  EG  added SDB; fixed bugs in data_formatting; added carrier CSR information   |
--     01/2014  v5  EG  added VIC and EIC in the TDC mezzanine                                    |
--     06/2014  v6  EG  added White Rabbit support                                                |
--     12/2017  v7  GD  Top file reorganized to benefit from WRPC Board wrapper.                  |
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tdc_core_pkg.all;
use work.gn4124_core_pkg.all;
use work.gencores_pkg.all;
use work.synthesis_descriptor.all;
use work.wishbone_pkg.all;
use work.wr_board_pkg.all;
use work.wr_spec_pkg.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity wr_spec_tdc is
  generic
    (g_simulation  : boolean := false);  -- this generic is set to TRUE
                                         -- when instantiated in a test-bench
  port(
    clk_125m_pllref_p_i : in std_logic;  -- 125 MHz PLL reference
    clk_125m_pllref_n_i : in std_logic;
    clk_125m_gtp_n_i    : in std_logic;  -- 125 MHz GTP reference
    clk_125m_gtp_p_i    : in std_logic;
    clk_20m_vcxo_i      : in std_logic;  -- 20 MHz VCXO

    wr_dac_sclk_o   : out std_logic;     -- PLL VCXO DAC Drive
    wr_dac_din_o    : out std_logic;
    wr_25dac_cs_n_o : out std_logic;
    wr_20dac_cs_n_o : out std_logic;

    sfp_txp_o         : out   std_logic;
    sfp_txn_o         : out   std_logic;
    sfp_rxp_i         : in    std_logic := '0';
    sfp_rxn_i         : in    std_logic := '1';
    sfp_mod_def0_i    : in    std_logic;  -- SFP detect pin
    sfp_mod_def1_b    : inout std_logic;  -- SFP scl
    sfp_mod_def2_b    : inout std_logic;  -- SFP sda
    sfp_rate_select_o : out   std_logic;
    sfp_tx_fault_i    : in    std_logic := '0';
    sfp_tx_disable_o  : out   std_logic;
    sfp_los_i         : in    std_logic := '0';

    uart_rxd_i        : in    std_logic := '1';
    uart_txd_o        : out   std_logic;
    flash_sclk_o      : out   std_logic;
    flash_ncs_o       : out   std_logic;
    flash_mosi_o      : out   std_logic;
    flash_miso_i      : in    std_logic;
    carrier_onewire_b : inout std_logic;  -- SPEC 1-wire
    button1_i         : in    std_logic := '1';

    ------------------------------------------------------------------------
    -- GN4124 PCI bridge pins
    ------------------------------------------------------------------------

    gn_rst_n   : in std_logic;           -- reset from gn4124 (rstout18_n)
    -- general purpose interface
    gn_gpio    : inout std_logic_vector(1 downto 0);  -- gpio[0] -> gn4124 gpio8
    -- pcie to local [inbound data] - rx
    gn_p2l_rdy    : out   std_logic;     -- rx buffer full flag
    gn_p2l_clkn   : in    std_logic;     -- receiver source synchronous clock-
    gn_p2l_clkp   : in    std_logic;     -- receiver source synchronous clock+
    gn_p2l_data   : in    std_logic_vector(15 downto 0);  -- parallel receive data
    gn_p2l_dframe : in    std_logic;     -- receive frame
    gn_p2l_valid  : in    std_logic;     -- receive data valid
    -- inbound buffer request/status
    gn_p_wr_req : in  std_logic_vector(1 downto 0);  -- pcie write request
    gn_p_wr_rdy : out std_logic_vector(1 downto 0);  -- pcie write ready
    gn_rx_error : out std_logic;                     -- receive error
    -- local to parallel [outbound data] - tx
    gn_l2p_data   : out std_logic_vector(15 downto 0);  -- parallel transmit data
    gn_l2p_dframe : out std_logic;       -- transmit data frame
    gn_l2p_valid  : out std_logic;       -- transmit data valid
    gn_l2p_clkn   : out std_logic;  -- transmitter source synchronous clock-
    gn_l2p_clkp   : out std_logic;  -- transmitter source synchronous clock+
    gn_l2p_edb    : out std_logic;       -- packet termination and discard
    -- outbound buffer status
    gn_l2p_rdy    : in std_logic;        -- tx buffer full flag
    gn_l_wr_rdy   : in std_logic_vector(1 downto 0);  -- local-to-pcie write
    gn_p_rd_d_rdy : in std_logic_vector(1 downto 0);  -- pcie-to-local read response data ready
    gn_tx_error   : in std_logic;        -- transmit error
    gn_vc_rdy     : in std_logic_vector(1 downto 0);  -- channel ready

    ------------------------------------------------------------------------
    -- Interface with the PLL AD9516 and DAC AD5662 on TDC mezzanine
    ------------------------------------------------------------------------
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
    enable_inputs_o   : out std_logic;  -- enables all 5 inputs
    term_en_1_o       : out std_logic;  -- Ch.1 termination enable of 50 Ohm termination
    term_en_2_o       : out std_logic;  -- Ch.2 termination enable of 50 Ohm termination
    term_en_3_o       : out std_logic;  -- Ch.3 termination enable of 50 Ohm termination
    term_en_4_o       : out std_logic;  -- Ch.4 termination enable of 50 Ohm termination
    term_en_5_o       : out std_logic;  -- Ch.5 termination enable of 50 Ohm termination
    -- LEDs on TDC mezzanine
    tdc_led_status_o  : out std_logic;  -- amber led on front pannel, division of 125 MHz tdc_clk
    tdc_led_trig1_o   : out std_logic;  -- amber led on front pannel, Ch.1 enable
    tdc_led_trig2_o   : out std_logic;  -- amber led on front pannel, Ch.2 enable
    tdc_led_trig3_o   : out std_logic;  -- amber led on front pannel, Ch.3 enable
    tdc_led_trig4_o   : out std_logic;  -- amber led on front pannel, Ch.4 enable
    tdc_led_trig5_o   : out std_logic;  -- amber led on front pannel, Ch.5 enable
    -- Input Logic on TDC mezzanine (not used currently)
    tdc_in_fpga_1_i   : in std_logic;   -- Ch.1 for ACAM, also received by FPGA
    tdc_in_fpga_2_i   : in std_logic;   -- Ch.2 for ACAM, also received by FPGA
    tdc_in_fpga_3_i   : in std_logic;   -- Ch.3 for ACAM, also received by FPGA
    tdc_in_fpga_4_i   : in std_logic;   -- Ch.4 for ACAM, also received by FPGA
    tdc_in_fpga_5_i   : in std_logic;   -- Ch.5 for ACAM, also received by FPGA
    -- I2C EEPROM interface on TDC mezzanine
    mezz_sys_scl_b    : inout std_logic := '1';  -- Mezzanine system EEPROM I2C clock
    mezz_sys_sda_b    : inout std_logic := '1';  -- Mezzanine system EEPROM I2C data
    -- 1-wire interface on TDC mezzanine
    mezz_onewire_b    : inout std_logic;

    -- font panel leds
    led_act_o     : out std_logic;
    led_link_o    : out std_logic;
    -- Carrier other signals
    pcb_ver_i     : in std_logic_vector(3 downto 0);  -- PCB version
    prsnt_m2c_n_i : in std_logic);    -- Mezzanine presence (active low)

end wr_spec_tdc;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of wr_spec_tdc is

---------------------------------------------------------------------------------------------------
--                                         SDB CONSTANTS                                         --
---------------------------------------------------------------------------------------------------

  constant c_SPEC_INFO_SDB_DEVICE : t_sdb_device :=
    (abi_class     => x"0000",          -- undocumented device
     abi_ver_major => x"01",
     abi_ver_minor => x"01",
     wbd_endian    => c_sdb_endian_big,
     wbd_width     => x"4",             -- 32-bit port granularity
     sdb_component =>
     (addr_first   => x"0000000000000000",
      addr_last    => x"000000000000001F",
      product =>
      (vendor_id   => x"000000000000CE42",  -- CERN
       device_id   => x"00000603",  -- "WB-SPEC.CSR        " | md5sum | cut -c1-8
       version     => x"00000001",
       date        => x"20121116",
       name        => "WB-SPEC.CSR        ")));

-- Note: All address in sdb and crossbar are BYTE addresses!

  -- Master ports on the wishbone crossbar
  constant c_NUM_WB_MASTERS     : integer := 4;
  constant c_WB_SLAVE_SPEC_INFO : integer := 0;  -- Info on SPEC control and status registers
  constant c_WB_SLAVE_VIC       : integer := 1;  -- Interrupt controller
  constant c_WB_SLAVE_TDC       : integer := 2;  -- TDC core configuration
  constant c_WB_SLAVE_WRC       : integer := 3;  -- White Rabbit PTP core

  -- SDB header address
  constant c_SDB_ADDRESS : t_wishbone_address := x"00000000";

  -- Slave port on the wishbone crossbar
  constant c_NUM_WB_SLAVES : integer := 1;
  constant c_MASTER_GENNUM : integer := 0;

  constant c_FMC_TDC_SDB_BRIDGE : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"0000FFFF", x"00000000");
  constant c_WRCORE_BRIDGE_SDB  : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"0003ffff", x"00030000");

  constant c_INTERCONNECT_LAYOUT : t_sdb_record_array(5 downto 0) :=
    (0 => f_sdb_embed_device (c_SPEC_INFO_SDB_DEVICE, x"00020000"),
     1 => f_sdb_embed_device (c_xwb_vic_sdb, x"00030000"),  -- c_xwb_vic_sdb described in the wishbone_pkg
     2 => f_sdb_embed_bridge (c_FMC_TDC_SDB_BRIDGE, x"00040000"),
     3 => f_sdb_embed_bridge (c_WRCORE_BRIDGE_SDB, x"00080000"),
     4 => f_sdb_embed_repo_url (c_SDB_REPO_URL),
     5 => f_sdb_embed_synthesis (c_sdb_synthesis_info));


---------------------------------------------------------------------------------------------------
--                                         VIC CONSTANT                                          --
---------------------------------------------------------------------------------------------------
  constant c_VIC_VECTOR_TABLE : t_wishbone_address_array(0 to 0) :=
    (0 => x"00043000");

---------------------------------------------------------------------------------------------------
--                                            Signals                                            --
---------------------------------------------------------------------------------------------------
  -- Clocks and resets
  signal clk_sys_62m5   : std_logic;
  signal rst_sys_62m5_n : std_logic;
  -- DAC configuration through PCIe/VME
  -- WISHBONE from crossbar master port
  signal cnx_master_out           : t_wishbone_master_out_array(c_NUM_WB_MASTERS-1 downto 0);
  signal cnx_master_in            : t_wishbone_master_in_array(c_NUM_WB_MASTERS-1 downto 0);
  -- WISHBONE to crossbar slave port
  signal cnx_slave_out            : t_wishbone_slave_out_array(c_NUM_WB_SLAVES-1 downto 0);
  signal cnx_slave_in             : t_wishbone_slave_in_array(c_NUM_WB_SLAVES-1 downto 0);
  signal gn_wb_adr                : std_logic_vector(31 downto 0);
  -- Carrier CSR info
  signal gn4124_status            : std_logic_vector(31 downto 0);
  -- VIC
  signal irq_to_gn4124            : std_logic;
  -- WRabbit time
  signal tm_link_up, tm_time_valid: std_logic;
  signal tm_dac_wr_p              : std_logic;
  signal tm_tai                   : std_logic_vector(39 downto 0);
  signal tm_cycles                : std_logic_vector(27 downto 0);
  signal tm_dac_value             : std_logic_vector(23 downto 0);
  signal tm_clk_aux_lock_en       : std_logic;
  signal tm_clk_aux_locked        : std_logic;
  -- EEPROM on mezzanine
  signal wrc_scl_out, wrc_scl_in  : std_logic;
  signal wrc_sda_out, wrc_sda_in  : std_logic;
  signal tdc_scl_oen, tdc_scl_in  : std_logic;
  signal tdc_sda_oen, tdc_sda_in  : std_logic;
  -- SFP EEPROM on mezzanine  
  signal sfp_scl_out, sfp_scl_in  : std_logic;
  signal sfp_sda_out, sfp_sda_in  : std_logic;
  -- Carrier 1-Wire
  signal wrc_owr_oe, wrc_owr_data : std_logic;
  -- aux

  signal tdc0_irq             : std_logic;
  signal tdc0_clk_125m        : std_logic;
  signal tdc0_soft_rst_n      : std_logic;
  signal carrier_info_fmc_rst : std_logic_vector(30 downto 0);

--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  tdc0_soft_rst_n <= carrier_info_fmc_rst(0) and rst_sys_62m5_n;

-------------------------------------------------------------------------------
--            SPEC Board Wrapper                                             --
-------------------------------------------------------------------------------

  cmp_xwrc_board_spec : xwrc_board_spec
    generic map (
      g_simulation                => f_bool2int(g_simulation),
      g_with_external_clock_input => FALSE,
      g_aux_clks                  => 1,
      g_dpram_initf               => "../../ip_cores/wr-cores/bin/wrpc/wrc_phy8.bram",
      g_fabric_iface              => PLAIN)
    port map (
      areset_n_i          => button1_i,
      areset_edge_n_i     => gn_rst_n,
      clk_20m_vcxo_i      => clk_20m_vcxo_i,
      clk_125m_pllref_p_i => clk_125m_pllref_p_i,
      clk_125m_pllref_n_i => clk_125m_pllref_n_i,
      clk_125m_gtp_n_i    => clk_125m_gtp_n_i,
      clk_125m_gtp_p_i    => clk_125m_gtp_p_i,
      clk_sys_62m5_o      => clk_sys_62m5,
      clk_aux_i(0)        => tdc0_clk_125m,
      rst_sys_62m5_n_o    => rst_sys_62m5_n,
      plldac_sclk_o       => wr_dac_sclk_o,
      plldac_din_o        => wr_dac_din_o,
      pll25dac_cs_n_o     => wr_25dac_cs_n_o,
      pll20dac_cs_n_o     => wr_20dac_cs_n_o,
      sfp_txp_o           => sfp_txp_o,
      sfp_txn_o           => sfp_txn_o,
      sfp_rxp_i           => sfp_rxp_i,
      sfp_rxn_i           => sfp_rxn_i,
      sfp_det_i           => sfp_mod_def0_i,
      sfp_sda_i           => sfp_sda_in,
      sfp_sda_o           => sfp_sda_out,
      sfp_scl_i           => sfp_scl_in,
      sfp_scl_o           => sfp_scl_out,
      sfp_rate_select_o   => sfp_rate_select_o,
      sfp_tx_fault_i      => sfp_tx_fault_i,
      sfp_tx_disable_o    => sfp_tx_disable_o,
      sfp_los_i           => sfp_los_i,
      eeprom_sda_i        => wrc_sda_in,
      eeprom_sda_o        => wrc_sda_out,
      eeprom_scl_i        => wrc_scl_in,
      eeprom_scl_o        => wrc_scl_out,
      onewire_i           => wrc_owr_data,
      onewire_oen_o       => wrc_owr_oe,
      uart_rxd_i          => uart_rxd_i,
      uart_txd_o          => uart_txd_o,
      flash_sclk_o        => flash_sclk_o,
      flash_ncs_o         => flash_ncs_o,
      flash_mosi_o        => flash_mosi_o,
      flash_miso_i        => flash_miso_i,
      wb_slave_o          => cnx_master_in(c_WB_SLAVE_WRC),
      wb_slave_i          => cnx_master_out(c_WB_SLAVE_WRC),
      tm_link_up_o        => tm_link_up,
      tm_dac_value_o      => tm_dac_value,
      tm_dac_wr_o(0)          => tm_dac_wr_p,
      tm_clk_aux_lock_en_i(0) => tm_clk_aux_lock_en,
      tm_clk_aux_locked_o(0)  => tm_clk_aux_locked,
      tm_time_valid_o     => tm_time_valid,
      tm_tai_o            => tm_tai,
      tm_cycles_o         => tm_cycles,
      led_link_o          => led_link_o,
      led_act_o           => led_act_o);

  -- Tristates for SFP EEPROM
  sfp_mod_def1_b <= '0' when sfp_scl_out = '0' else 'Z';
  sfp_mod_def2_b <= '0' when sfp_sda_out = '0' else 'Z';
  sfp_scl_in     <= sfp_mod_def1_b;
  sfp_sda_in     <= sfp_mod_def2_b;
  -- Tristates for 1-wire thermometer
  carrier_onewire_b <= '0' when wrc_owr_oe = '1' else 'Z';
  wrc_owr_data      <= carrier_onewire_b;

---------------------------------------------------------------------------------------------------
--                                     CSR WISHBONE CROSSBAR                                     --
---------------------------------------------------------------------------------------------------
--   0x00000 -> SDB
--   0x10000 -> Carrier 1-wire master
--   0x20000 -> Carrier CSR information
--   0x30000 -> Vector Interrupt Controller
--   0x40000 -> TDC mezzanine SDB
--     0x10000 -> TDC core configuration (including ACAM regs)
--     0x11000 -> TDC Mezzanine 1-wire master
--     0x12000 -> TDC Mezzanine Embedded Interrupt Controller
--     0x13000 -> TDC Mezzanine I2C master
--     0x14000 -> TDC core timestamps retrieval from memory
  cmp_sdb_crossbar : xwb_sdb_crossbar
    generic map
    (g_num_masters => c_NUM_WB_SLAVES,
     g_num_slaves  => c_NUM_WB_MASTERS,
     g_registered  => true,
     g_wraparound  => true,
     g_layout      => c_INTERCONNECT_LAYOUT,
     g_sdb_addr    => c_SDB_ADDRESS)
    port map
    (clk_sys_i => clk_sys_62m5,
     rst_n_i   => rst_sys_62m5_n,
     slave_i   => cnx_slave_in,
     slave_o   => cnx_slave_out,
     master_i  => cnx_master_in,
     master_o  => cnx_master_out);


---------------------------------------------------------------------------------------------------
--                                           GN4124 CORE                                         --
---------------------------------------------------------------------------------------------------
  cmp_gn4124_core : gn4124_core
    port map
    (rst_n_a_i    => gn_rst_n,
     status_o     => gn4124_status,
     ---------------------------------------------------------
     -- P2L Direction
     --
     -- Source Sync DDR related signals
     p2l_clk_p_i  => gn_p2l_clkp,
     p2l_clk_n_i  => gn_p2l_clkn,
     p2l_data_i   => gn_p2l_data,
     p2l_dframe_i => gn_p2l_dframe,
     p2l_valid_i  => gn_p2l_valid,
     -- P2L Control
     p2l_rdy_o    => gn_p2l_rdy,
     p_wr_req_i   => gn_p_wr_req,
     p_wr_rdy_o   => gn_p_wr_rdy,
     rx_error_o   => gn_rx_error,
     vc_rdy_i     => gn_vc_rdy,

     ---------------------------------------------------------
     -- L2P Direction
     --
     -- Source Sync DDR related signals
     l2p_clk_p_o  => gn_l2p_clkp,
     l2p_clk_n_o  => gn_l2p_clkn,
     l2p_data_o   => gn_l2p_data,
     l2p_dframe_o => gn_l2p_dframe,
     l2p_valid_o  => gn_l2p_valid,
     -- L2P Control
     l2p_edb_o    => gn_l2p_edb,
     l2p_rdy_i    => gn_l2p_rdy,
     l_wr_rdy_i   => gn_l_wr_rdy,
     p_rd_d_rdy_i => gn_p_rd_d_rdy,
     tx_error_i   => gn_tx_error,

     dma_irq_o => open,
     irq_p_i   => '0',
     irq_p_o   => open,

     -- CSR WISHBONE interface (master pipelined)
     csr_clk_i       => clk_sys_62m5,
     csr_adr_o       => gn_wb_adr,
     csr_dat_o       => cnx_slave_in(c_MASTER_GENNUM).dat,
     csr_sel_o       => cnx_slave_in(c_MASTER_GENNUM).sel,
     csr_stb_o       => cnx_slave_in(c_MASTER_GENNUM).stb,
     csr_we_o        => cnx_slave_in(c_MASTER_GENNUM).we,
     csr_cyc_o       => cnx_slave_in(c_MASTER_GENNUM).cyc,
     csr_dat_i       => cnx_slave_out(c_MASTER_GENNUM).dat,
     csr_ack_i       => cnx_slave_out(c_MASTER_GENNUM).ack,
     csr_stall_i     => cnx_slave_out(c_MASTER_GENNUM).stall,
     csr_err_i       => cnx_slave_out(c_MASTER_GENNUM).err,
     csr_rty_i       => cnx_slave_out(c_MASTER_GENNUM).rty,
     csr_int_i       => cnx_slave_out(c_MASTER_GENNUM).int,
     -- DMA: not used
     dma_clk_i       => clk_sys_62m5,
     dma_ack_i       => '1',
     dma_dat_i       => (others => '0'),
     dma_stall_i     => '0',
     dma_err_i       => '0',
     dma_rty_i       => '0',
     dma_int_i       => '0',
     dma_reg_clk_i   => clk_sys_62m5,
     dma_reg_adr_i   => (others => '0'),
     dma_reg_dat_i   => (others => '0'),
     dma_reg_sel_i   => (others => '0'),
     dma_reg_stb_i   => '0',
     dma_reg_we_i    => '0',
     dma_reg_cyc_i   => '0');

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Convert 32-bit word address into byte address for crossbar
  cnx_slave_in(c_MASTER_GENNUM).adr <= gn_wb_adr(29 downto 0) & "00";

  cmp_tdc_mezzanine : fmc_tdc_wrapper
    generic map (
      g_simulation          => g_simulation,
      g_with_direct_readout => false)
    port map (
      clk_sys_i            => clk_sys_62m5,
      rst_sys_n_i          => rst_sys_62m5_n,
      rst_n_a_i            => tdc0_soft_rst_n,
      pll_sclk_o           => pll_sclk_o,
      pll_sdi_o            => pll_sdi_o,
      pll_cs_o             => pll_cs_o,
      pll_dac_sync_o       => pll_dac_sync_o,
      pll_sdo_i            => pll_sdo_i,
      pll_status_i         => pll_status_i,
      tdc_clk_125m_p_i     => tdc_clk_125m_p_i,
      tdc_clk_125m_n_i     => tdc_clk_125m_n_i,
      acam_refclk_p_i      => acam_refclk_p_i,
      acam_refclk_n_i      => acam_refclk_n_i,
      start_from_fpga_o    => start_from_fpga_o,
      err_flag_i           => err_flag_i,
      int_flag_i           => int_flag_i,
      start_dis_o          => start_dis_o,
      stop_dis_o           => stop_dis_o,
      data_bus_io          => data_bus_io,
      address_o            => address_o,
      cs_n_o               => cs_n_o,
      oe_n_o               => oe_n_o,
      rd_n_o               => rd_n_o,
      wr_n_o               => wr_n_o,
      ef1_i                => ef1_i,
      ef2_i                => ef2_i,
      enable_inputs_o      => enable_inputs_o,
      term_en_1_o          => term_en_1_o,
      term_en_2_o          => term_en_2_o,
      term_en_3_o          => term_en_3_o,
      term_en_4_o          => term_en_4_o,
      term_en_5_o          => term_en_5_o,
      tdc_led_status_o     => tdc_led_status_o,
      tdc_led_trig1_o      => tdc_led_trig1_o,
      tdc_led_trig2_o      => tdc_led_trig2_o,
      tdc_led_trig3_o      => tdc_led_trig3_o,
      tdc_led_trig4_o      => tdc_led_trig4_o,
      tdc_led_trig5_o      => tdc_led_trig5_o,
      tdc_in_fpga_1_i      => tdc_in_fpga_1_i,
      tdc_in_fpga_2_i      => tdc_in_fpga_2_i,
      tdc_in_fpga_3_i      => tdc_in_fpga_3_i,
      tdc_in_fpga_4_i      => tdc_in_fpga_4_i,
      tdc_in_fpga_5_i      => tdc_in_fpga_5_i,
      mezz_scl_o           => tdc_scl_oen,
      mezz_sda_o           => tdc_sda_oen,
      mezz_scl_i           => tdc_scl_in,
      mezz_sda_i           => tdc_sda_in,
      mezz_one_wire_b      => mezz_onewire_b,
      tm_link_up_i         => tm_link_up,
      tm_time_valid_i      => tm_time_valid,
      tm_cycles_i          => tm_cycles,
      tm_tai_i             => tm_tai,
      tm_clk_aux_lock_en_o => tm_clk_aux_lock_en,
      tm_clk_aux_locked_i  => tm_clk_aux_locked,
      tm_clk_dmtd_locked_i => '1',
      tm_dac_value_i       => tm_dac_value,
      tm_dac_wr_i          => tm_dac_wr_p,
      slave_i              => cnx_master_out(c_WB_SLAVE_TDC),
      slave_o              => cnx_master_in(c_WB_SLAVE_TDC),
      irq_o                => tdc0_irq,
      clk_125m_tdc_o       => tdc0_clk_125m);


---------------------------------------------------------------------------------------------------
--                                              VIC                                              --
---------------------------------------------------------------------------------------------------
  cmp_vic : xwb_vic
    generic map
    (g_interface_mode      => PIPELINED,
     g_address_granularity => BYTE,
     g_num_interrupts      => 1,
     g_init_vectors        => c_VIC_VECTOR_TABLE)
    port map
    (clk_sys_i    => clk_sys_62m5,
     rst_n_i      => rst_sys_62m5_n,
     slave_i      => cnx_master_out(c_WB_SLAVE_VIC),
     slave_o      => cnx_master_in(c_WB_SLAVE_VIC),
     irqs_i(0)    => tdc0_irq,
     irq_master_o => irq_to_gn4124);

  gn_gpio(0) <= irq_to_gn4124;
  gn_gpio(1) <= '0';

---------------------------------------------------------------------------------------------------
--                                    Carrier CSR information                                    --
---------------------------------------------------------------------------------------------------
-- Information on carrier type, mezzanine presence, pcb version

  cmp_carrier_info : carrier_info
    port map
    (rst_n_i                           => rst_sys_62m5_n,
     clk_sys_i                         => clk_sys_62m5,
     wb_adr_i                          => cnx_master_out(c_WB_SLAVE_SPEC_INFO).adr(3 downto 2),
     wb_dat_i                          => cnx_master_out(c_WB_SLAVE_SPEC_INFO).dat,
     wb_dat_o                          => cnx_master_in(c_WB_SLAVE_SPEC_INFO).dat,
     wb_cyc_i                          => cnx_master_out(c_WB_SLAVE_SPEC_INFO).cyc,
     wb_sel_i                          => cnx_master_out(c_WB_SLAVE_SPEC_INFO).sel,
     wb_stb_i                          => cnx_master_out(c_WB_SLAVE_SPEC_INFO).stb,
     wb_we_i                           => cnx_master_out(c_WB_SLAVE_SPEC_INFO).we,
     wb_ack_o                          => cnx_master_in(c_WB_SLAVE_SPEC_INFO).ack,
     wb_stall_o                        => cnx_master_in(c_WB_SLAVE_SPEC_INFO).stall,
     carrier_info_carrier_pcb_rev_i    => pcb_ver_i,
     carrier_info_carrier_reserved_i   => (others => '0'),
     carrier_info_carrier_type_i       => c_CARRIER_TYPE,
     carrier_info_stat_fmc_pres_i      => prsnt_m2c_n_i,
     carrier_info_stat_p2l_pll_lck_i   => gn4124_status(0),
     -- SPEC board wrapper releases rst_sys_62m5_n only when system clock pll is
     -- locked. Therefore we report here '1' - pll locked
     carrier_info_stat_sys_pll_lck_i   => '1',
     carrier_info_stat_ddr3_cal_done_i => '0',
     carrier_info_stat_reserved_i      => x"0000000",

     carrier_info_ctrl_led_green_o  => open,
     carrier_info_ctrl_led_red_o    => open,
     carrier_info_ctrl_dac_clr_n_o  => open,
     carrier_info_ctrl_reserved_o   => open,
     carrier_info_rst_fmc0_n_o      => open,
     carrier_info_rst_fmc0_n_i      => '1',
     carrier_info_rst_fmc0_n_load_o => open,
     carrier_info_rst_reserved_o    => carrier_info_fmc_rst);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused wishbone signals
  cnx_master_in(c_WB_SLAVE_SPEC_INFO).err <= '0';
  cnx_master_in(c_WB_SLAVE_SPEC_INFO).rty <= '0';
  cnx_master_in(c_WB_SLAVE_SPEC_INFO).int <= '0';

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Tristates for TDC mezzanine EEPROM
  mezz_sys_scl_b <= '0' when (tdc_scl_oen = '0') else '0' when (wrc_scl_out = '0') else 'Z';
  mezz_sys_sda_b <= '0' when (tdc_sda_oen = '0') else '0' when (wrc_sda_out = '0') else 'Z';
  wrc_scl_in     <= mezz_sys_scl_b;
  wrc_sda_in     <= mezz_sys_sda_b;
  tdc_scl_in     <= mezz_sys_scl_b;
  tdc_sda_in     <= mezz_sys_sda_b;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
