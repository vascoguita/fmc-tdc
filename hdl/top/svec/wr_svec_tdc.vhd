-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

---------------------------------------------------------------------------------------------------
-- Title      : TDC on SVEC with WR support
---------------------------------------------------------------------------------------------------
-- Description: Two TDC mezzanine cores are instantiated, for the boards on FMC1 and FMC2
--              The svec_base_wr provides White Rabbit and host communication.
--              Readout interface: per-channel FIFOs
--
--              Rising-edges belonging to pulses <96 ns are timestamped;
--              pulses < 96ns and falling edge timestamps are ignored
--
--              The speed for the VME core is 62.5 MHz. The TDC mezzanine cores
--              internally operate at 125 MHz, but the wishbone bus works still
--              at system-wide 62.5 MHz clock.
--
--              The 62.5 MHz clock comes from an internal Xilinx FPGA PLL, using the 20MHz VCXO of
--              the SVEC board.
--
--              The 125 MHz clock for each TDC mezzanine comes from the PLL located on it.
--
--              Upon powering up of the FPGA as well as after a VME reset, the whole logic gets
--              reset (FMC1 125 MHz, FMC2 125 MHz and 62.5 MHz). This also triggers a
--              reprogramming of the mezzanines' PLL through the clks_rsts_manager units.
--              An extra software reset is implemented for the TDC mezzanine cores, using the
--              reset bits of the carrier_info core. Such a reset also triggers the reprogramming
--              of the mezzanines' PLL.
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
use work.vme64x_pkg.all;
use work.wr_board_pkg.all;
use work.wr_svec_pkg.all;
use work.sourceid_wr_svec_tdc_pkg;

library UNISIM;
use UNISIM.vcomponents.all;

--=================================================================================================
--                                   Entity declaration for top_tdc
--=================================================================================================
entity wr_svec_tdc is
  generic
    (g_WRPC_INITF                  : string  := "../../ip_cores/wr-cores/bin/wrpc/wrc_phy8.bram";
     g_USE_FIFO_READOUT            : boolean := TRUE;
     g_USE_DMA_READOUT             : boolean := FALSE;
     g_SIMULATION                  : integer := 0;
     g_USE_FAKE_TIMESTAMPS_FOR_SIM : boolean := FALSE  -- when instantiated in a test-bench
     );

  port (

    -- VCXO clock, PoR
    rst_n_i                : in std_logic;           -- Reset from system fpga
    clk_20m_vcxo_i         : in    std_logic;        -- 20 MHz VCXO
    -- 125 MHz PLL reference
    clk_125m_pllref_p_i    : in    std_logic;
    clk_125m_pllref_n_i    : in    std_logic;
    -- 125 MHz GTP reference
    clk_125m_gtp_p_i       : in    std_logic;
    clk_125m_gtp_n_i       : in    std_logic;
    -- SFP
    sfp_txp_o              : out   std_logic;
    sfp_txn_o              : out   std_logic;
    sfp_rxp_i              : in    std_logic := '0';
    sfp_rxn_i              : in    std_logic := '1';
    sfp_mod_def0_i         : in    std_logic;        -- SFP detect pin
    sfp_mod_def1_b         : inout std_logic;        -- SFP scl
    sfp_mod_def2_b         : inout std_logic;        -- SFP sda
    sfp_rate_select_o      : out   std_logic;
    sfp_tx_fault_i         : in    std_logic := '0';
    sfp_tx_disable_o       : out   std_logic;
    sfp_los_i              : in    std_logic := '0';
    -- Serial DAC
    pll20dac_din_o         : out   std_logic;
    pll20dac_sclk_o        : out   std_logic;
    pll20dac_sync_n_o      : out   std_logic;
    pll25dac_din_o         : out   std_logic;
    pll25dac_sclk_o        : out   std_logic;
    pll25dac_sync_n_o      : out   std_logic;
    -- UART
    uart_rxd_i             : in    std_logic := '1';
    uart_txd_o             : out   std_logic;
    -- 1-wire
    onewire_b              : inout std_logic;
    -- SPI Flash
    spi_sclk_o             : out   std_logic;
    spi_ncs_o              : out   std_logic;
    spi_mosi_o             : out   std_logic;
    spi_miso_i             : in    std_logic;
    -- I2C EEPROM
    carrier_scl_b          : inout std_logic;
    carrier_sda_b          : inout std_logic;
    -- SVEC PCB version
    pcbrev_i               : in    std_logic_vector(4 downto 0);
    -- Mezzanines presence
    fmc0_prsnt_m2c_n_i      : in    std_logic;        -- Presence of mezzanine #1
    fmc1_prsnt_m2c_n_i      : in    std_logic;        -- Presence of mezzanine #2
    -- SVEC Front panel LEDs
    fp_led_line_oen_o      : out   std_logic_vector(1 downto 0);
    fp_led_line_o          : out   std_logic_vector(1 downto 0);
    fp_led_column_o        : out   std_logic_vector(3 downto 0);
    -- SVEC Front panel LEDs and LEMOs
    fp_gpio1_b      : out std_logic;  -- PPS output
    fp_gpio2_b      : out std_logic;  -- Ref clock div2 output
    fp_gpio3_b      : in  std_logic;  -- ext 10MHz clock input
    fp_gpio4_b      : in  std_logic;  -- ext PPS input
    fp_term_en_o    : out std_logic_vector(4 downto 1);
    fp_gpio1_a2b_o  : out std_logic;
    fp_gpio2_a2b_o  : out std_logic;
    fp_gpio34_a2b_o : out std_logic;

    -- VME interface
    vme_as_n_i             : in    std_logic;
    vme_sysreset_n_i       : in    std_logic;
    vme_write_n_i          : in    std_logic;
    vme_am_i               : in    std_logic_vector(5 downto 0);
    vme_ds_n_i             : in    std_logic_vector(1 downto 0);
    vme_ga_i               : in    std_logic_vector(4 downto 0);
    vme_berr_o             : inout std_logic;
    vme_dtack_n_o          : inout std_logic;
    vme_retry_n_o          : out   std_logic;
    vme_retry_oe_o         : out   std_logic;
    vme_lword_n_b          : inout std_logic;
    vme_addr_b             : inout std_logic_vector(31 downto 1);
    vme_data_b             : inout std_logic_vector(31 downto 0);
    vme_gap_i              : in    std_logic;
    vme_irq_o              : out   std_logic_vector(7 downto 1);
    vme_iack_n_i           : in    std_logic;
    vme_iackin_n_i         : in    std_logic;
    vme_iackout_n_o        : out   std_logic;
    vme_dtack_oe_o         : inout std_logic;
    vme_data_dir_o         : inout std_logic;
    vme_data_oe_n_o        : inout std_logic;
    vme_addr_dir_o         : inout std_logic;
    vme_addr_oe_n_o        : inout std_logic;

    -- TDC mezzanine board on FMC slot 1
    -- TDC1 PLL AD9516 and DAC AD5662 interface
    fmc0_tdc_pll_sclk_o        : out   std_logic;
    fmc0_tdc_pll_sdi_o         : out   std_logic;
    fmc0_tdc_pll_cs_n_o        : out   std_logic;
    fmc0_tdc_pll_dac_sync_o    : out   std_logic;
    fmc0_tdc_pll_sdo_i         : in    std_logic;
    fmc0_tdc_pll_status_i      : in    std_logic;
    fmc0_tdc_clk_125m_p_i      : in    std_logic;
    fmc0_tdc_clk_125m_n_i      : in    std_logic;
    fmc0_tdc_acam_refclk_p_i   : in    std_logic;
    fmc0_tdc_acam_refclk_n_i   : in    std_logic;
    -- TDC1 ACAM timing interface
    fmc0_tdc_start_from_fpga_o : out   std_logic;
    fmc0_tdc_err_flag_i        : in    std_logic;
    fmc0_tdc_int_flag_i        : in    std_logic;
    fmc0_tdc_start_dis_o       : out   std_logic;
    fmc0_tdc_stop_dis_o        : out   std_logic;
    -- TDC1 ACAM data interface
    fmc0_tdc_data_bus_io       : inout std_logic_vector(27 downto 0);
    fmc0_tdc_address_o         : out   std_logic_vector(3 downto 0);
    fmc0_tdc_cs_n_o            : out   std_logic;
    fmc0_tdc_oe_n_o            : out   std_logic;
    fmc0_tdc_rd_n_o            : out   std_logic;
    fmc0_tdc_wr_n_o            : out   std_logic;
    fmc0_tdc_ef1_i             : in    std_logic;
    fmc0_tdc_ef2_i             : in    std_logic;
    -- TDC1 Input Logic
    fmc0_tdc_enable_inputs_o   : out   std_logic;
    fmc0_tdc_term_en_1_o       : out   std_logic;
    fmc0_tdc_term_en_2_o       : out   std_logic;
    fmc0_tdc_term_en_3_o       : out   std_logic;
    fmc0_tdc_term_en_4_o       : out   std_logic;
    fmc0_tdc_term_en_5_o       : out   std_logic;
    -- TDC1 1-wire UniqueID & Thermometer
    fmc0_onewire_b             : inout std_logic;
    -- TDC1 EEPROM I2C
    fmc0_scl_b                 : inout std_logic;
    fmc0_sda_b                 : inout std_logic;
    -- TDC1 LEDs
    fmc0_tdc_led_status_o      : out   std_logic;
    fmc0_tdc_led_trig1_o       : out   std_logic;
    fmc0_tdc_led_trig2_o       : out   std_logic;
    fmc0_tdc_led_trig3_o       : out   std_logic;
    fmc0_tdc_led_trig4_o       : out   std_logic;
    fmc0_tdc_led_trig5_o       : out   std_logic;
    -- TDC1 Input channels, also arriving to the FPGA (not used for the moment)
    fmc0_tdc_in_fpga_1_i       : in    std_logic;
    fmc0_tdc_in_fpga_2_i       : in    std_logic;
    fmc0_tdc_in_fpga_3_i       : in    std_logic;
    fmc0_tdc_in_fpga_4_i       : in    std_logic;
    fmc0_tdc_in_fpga_5_i       : in    std_logic;

    -- TDC mezzanine board on FMC slot 2
    -- TDC2 PLL AD9516 and DAC AD5662 interface
    fmc1_tdc_pll_sclk_o        : out   std_logic;
    fmc1_tdc_pll_sdi_o         : out   std_logic;
    fmc1_tdc_pll_cs_n_o        : out   std_logic;
    fmc1_tdc_pll_dac_sync_o  : out   std_logic;
    fmc1_tdc_pll_sdo_i         : in    std_logic;
    fmc1_tdc_pll_status_i      : in    std_logic;
    fmc1_tdc_clk_125m_p_i      : in    std_logic;
    fmc1_tdc_clk_125m_n_i      : in    std_logic;
    fmc1_tdc_acam_refclk_p_i   : in    std_logic;
    fmc1_tdc_acam_refclk_n_i   : in    std_logic;
    -- TDC2 ACAM timing interface
    fmc1_tdc_start_from_fpga_o : out   std_logic;
    fmc1_tdc_err_flag_i        : in    std_logic;
    fmc1_tdc_int_flag_i        : in    std_logic;
    fmc1_tdc_start_dis_o       : out   std_logic;
    fmc1_tdc_stop_dis_o        : out   std_logic;
    -- TDC2 ACAM data interface
    fmc1_tdc_data_bus_io       : inout std_logic_vector(27 downto 0);
    fmc1_tdc_address_o         : out   std_logic_vector(3 downto 0);
    fmc1_tdc_cs_n_o            : out   std_logic;
    fmc1_tdc_oe_n_o            : out   std_logic;
    fmc1_tdc_rd_n_o            : out   std_logic;
    fmc1_tdc_wr_n_o            : out   std_logic;
    fmc1_tdc_ef1_i             : in    std_logic;
    fmc1_tdc_ef2_i             : in    std_logic;
    -- TDC2 Input Logic
    fmc1_tdc_enable_inputs_o   : out   std_logic;
    fmc1_tdc_term_en_1_o       : out   std_logic;
    fmc1_tdc_term_en_2_o       : out   std_logic;
    fmc1_tdc_term_en_3_o       : out   std_logic;
    fmc1_tdc_term_en_4_o       : out   std_logic;
    fmc1_tdc_term_en_5_o       : out   std_logic;
    -- TDC2 1-wire UniqueID & Thermometer
    fmc1_onewire_b             : inout std_logic;
    -- TDC2 EEPROM I2C
    fmc1_scl_b                 : inout std_logic;
    fmc1_sda_b                 : inout std_logic;
    -- TDC2 LEDs
    fmc1_tdc_led_status_o      : out   std_logic;
    fmc1_tdc_led_trig1_o       : out   std_logic;
    fmc1_tdc_led_trig2_o       : out   std_logic;
    fmc1_tdc_led_trig3_o       : out   std_logic;
    fmc1_tdc_led_trig4_o       : out   std_logic;
    fmc1_tdc_led_trig5_o       : out   std_logic;
    -- TDC2 Input channels, also arriving to the FPGA (not used for the moment)
    fmc1_tdc_in_fpga_1_i       : in    std_logic;
    fmc1_tdc_in_fpga_2_i       : in    std_logic;
    fmc1_tdc_in_fpga_3_i       : in    std_logic;
    fmc1_tdc_in_fpga_4_i       : in    std_logic;
    fmc1_tdc_in_fpga_5_i       : in    std_logic);
end wr_svec_tdc;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of wr_svec_tdc is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  -- Number of masters attached to the primary wishbone crossbar
  constant c_NUM_WB_MASTERS : integer := 1;

  -- Number of slaves attached to the primary wishbone crossbar
  constant c_NUM_WB_SLAVES     : integer := 3;
  constant c_WB_SLAVE_METADATA : integer := 0;
  constant c_WB_SLAVE_FMC0_TDC : integer := 1;  -- FMC slot 1 TDC mezzanine
  constant c_WB_SLAVE_FMC1_TDC : integer := 2;  -- FMC slot 2 TDC mezzanine

  -- Primary Wishbone master(s) offsets
  constant c_WB_MASTER_VME     : integer := 0;

  -- Convention metadata base address
  constant c_METADATA_ADDR  : t_wishbone_address := x"0000_4000";

  -- Primary wishbone crossbar layout
  constant c_WB_LAYOUT_ADDR :
    t_wishbone_address_array(c_NUM_WB_SLAVES - 1 downto 0) := (
      c_WB_SLAVE_METADATA => c_METADATA_ADDR,
      c_WB_SLAVE_FMC0_TDC  => x"0001_0000",
      c_WB_SLAVE_FMC1_TDC  => x"0002_0000");

-- mask is 18 bits long and is active-low
  constant c_WB_LAYOUT_MASK :
    t_wishbone_address_array(c_NUM_WB_SLAVES - 1 downto 0) := (
      c_WB_SLAVE_METADATA  => x"0003_ffc0",  -- 0x40 bytes: not(0x40   -1) = not(0x3F)   = c0
      c_WB_SLAVE_FMC0_TDC  => x"0003_0000",
      c_WB_SLAVE_FMC1_TDC  => x"0003_0000");


---------------------------------------------------------------------------------------------------
--                                            Signals                                            --
---------------------------------------------------------------------------------------------------

  -- Clocks/ reset
  -- CLOCK DOMAIN: 62.5 MHz system clock derived from clk_20m_vcxo_i by a Xilinx PLL: clk_62m5_sys
  signal clk_sys_62m5      : std_logic;
  -- CLOCK DOMAIN: 125 MHz clock from PLL on TDC1 and TDC2
  signal clk_ref_125m      : std_logic;
  signal clk_ref_div2      : std_logic;
  signal clk_dmtd_125m     : std_logic;
  signal fmc0_tdc_clk_125m : std_logic;
  signal fmc1_tdc_clk_125m : std_logic;
  signal areset_n          : std_logic;

---------------------------------------------------------------------------------------------------
  -- Resets
  -- system reset, synched with 62.5 MHz clock,driven by the VME reset and power-up reset pins.
  signal rst_sys_62m5_n    : std_logic;
  -- reset input to the clks_rsts_manager units of the two TDC cores;
  -- this reset initiates the configuration of the mezzanines PLL

---------------------------------------------------------------------------------------------------
  -- White Rabbit signals to TDC mezzanines
  signal tm_link_up, tm_time_valid            : std_logic;
  signal tm_tai                               : std_logic_vector(39 downto 0);
  signal tm_cycles                            : std_logic_vector(27 downto 0);
  signal tm_clk_aux_lock_en, tm_clk_aux_locked: std_logic_vector(1 downto 0);
  signal pps, pps_led                         : std_logic;
  -- White Rabbit signals to clks_rsts_manager
  signal tm_dac_value                         : std_logic_vector(23 downto 0);
  signal tm_dac_wr_p                          : std_logic_vector(1 downto 0);

---------------------------------------------------------------------------------------------------
 -- Crossbar
  -- WISHBONE from crossbar master port
  signal cnx_master_out : t_wishbone_master_out_array(c_NUM_WB_MASTERS-1 downto 0);
  signal cnx_master_in  : t_wishbone_master_in_array (c_NUM_WB_MASTERS-1 downto 0);
  -- WISHBONE to crossbar slave port
  signal cnx_slave_out  : t_wishbone_slave_out_array (c_NUM_WB_SLAVES-1 downto 0);
  signal cnx_slave_in   : t_wishbone_slave_in_array  (c_NUM_WB_SLAVES-1 downto 0);

---------------------------------------------------------------------------------------------------
-- Interrupts
  signal irq_vector : std_logic_vector(1 downto 0);

---------------------------------------------------------------------------------------------------
-- Mezzanines EEPROM
  signal fmc0_scl_oen, fmc0_scl_in    : std_logic;
  signal fmc0_sda_oen, fmc0_sda_in    : std_logic;
  signal fmc1_scl_oen, fmc1_scl_in    : std_logic;
  signal fmc1_sda_oen, fmc1_sda_in    : std_logic;

  -- LEDs
  signal led_state                            : std_logic_vector(15 downto 0);
  signal fmc0_tdc_ef, fmc1_tdc_ef             : std_logic;
  signal led_fmc0_tdc_ef, led_fmc1_tdc_ef     : std_logic;
  signal led_vme_access                       : std_logic;
  signal wr_led_act, wr_led_link              : std_logic;

--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  areset_n <= vme_sysreset_n_i and rst_n_i;

---------------------------------------------------------------------------------------------------
--                                 TDC specific Metadata ROM                                     --
---------------------------------------------------------------------------------------------------


  cmp_xwb_metadata : entity work.xwb_metadata
    generic map (
      g_VENDOR_ID    => x"0000_10DC",
      g_DEVICE_ID    => x"574E_0002", -- SVEC + 2xTDC
      g_VERSION      => sourceid_wr_svec_tdc_pkg.version,
      g_CAPABILITIES => x"0000_0000",
      g_COMMIT_ID    => sourceid_wr_svec_tdc_pkg.sourceid)
    port map (
      clk_i   => clk_sys_62m5,
      rst_n_i => rst_sys_62m5_n,
      wb_i    => cnx_slave_in(c_WB_SLAVE_METADATA),
      wb_o    => cnx_slave_out(c_WB_SLAVE_METADATA));

---------------------------------------------------------------------------------------------------
--                                      SVEC Board Base                                       --
---------------------------------------------------------------------------------------------------
  inst_svec_base : entity work.svec_base_wr
    generic map (
      g_WITH_VIC      => TRUE,
      g_WITH_ONEWIRE  => FALSE,
      g_WITH_SPI      => FALSE,
      g_WITH_WR       => TRUE,
      g_WITH_DDR4     => FALSE,
      g_WITH_DDR5     => FALSE,
      g_APP_OFFSET    => c_METADATA_ADDR,
      g_NUM_USER_IRQ  => 2,
      g_DPRAM_INITF   => g_WRPC_INITF,
      g_AUX_CLKS      => 2,
      g_FABRIC_IFACE  => plain,
      g_SIMULATION    => g_SIMULATION)
    port map (
      ---------------------------------------------------------
      -- Clocks/ Resets
      ---------------------------------------------------------
      rst_n_i              => areset_n,
      clk_125m_pllref_p_i  => clk_125m_pllref_p_i,
      clk_125m_pllref_n_i  => clk_125m_pllref_n_i,
      clk_20m_vcxo_i       => clk_20m_vcxo_i,
      clk_125m_gtp_n_i     => clk_125m_gtp_n_i,
      clk_125m_gtp_p_i     => clk_125m_gtp_p_i,
      clk_aux_i(0)         => fmc0_tdc_clk_125m,
      clk_aux_i(1)         => fmc1_tdc_clk_125m,
      clk_10m_ext_i        => '0',
      pps_ext_i            => '0',
      clk_dmtd_125m_o      => clk_dmtd_125m,
      clk_sys_62m5_o       => clk_sys_62m5,
      rst_sys_62m5_n_o     => rst_sys_62m5_n,
      clk_ref_125m_o       => clk_ref_125m,
      rst_ref_125m_n_o     => open,
      ---------------------------------------------------------
      -- VME interface
      ---------------------------------------------------------
      vme_write_n_i        => vme_write_n_i,
      vme_sysreset_n_i     => vme_sysreset_n_i,
      vme_retry_oe_o       => vme_retry_oe_o,
      vme_retry_n_o        => vme_retry_n_o,
      vme_lword_n_b        => vme_lword_n_b,
      vme_iackout_n_o      => vme_iackout_n_o,
      vme_iackin_n_i       => vme_iackin_n_i,
      vme_iack_n_i         => vme_iack_n_i,
      vme_gap_i            => vme_gap_i,
      vme_dtack_oe_o       => vme_dtack_oe_o,
      vme_dtack_n_o        => vme_dtack_n_o,
      vme_ds_n_i           => vme_ds_n_i,
      vme_data_oe_n_o      => vme_data_oe_n_o,
      vme_data_dir_o       => vme_data_dir_o,
      vme_berr_o           => vme_berr_o,
      vme_as_n_i           => vme_as_n_i,
      vme_addr_oe_n_o      => vme_addr_oe_n_o,
      vme_addr_dir_o       => vme_addr_dir_o,
      vme_irq_o            => vme_irq_o,
      vme_ga_i             => vme_ga_i,
      vme_data_b           => vme_data_b,
      vme_am_i             => vme_am_i,
      vme_addr_b           => vme_addr_b,
      ---------------------------------------------------------
      -- Carrier peripherals
      ---------------------------------------------------------
      -- 1-wire
      onewire_b            => onewire_b,
      -- EEPROM
      carrier_scl_b        => carrier_scl_b,
      carrier_sda_b        => carrier_sda_b,
      -- PCB version
      pcbrev_i             => pcbrev_i,
      -- SPI flash
      spi_sclk_o           => spi_sclk_o,
      spi_ncs_o            => spi_ncs_o,
      spi_mosi_o           => spi_mosi_o,
      spi_miso_i           => spi_miso_i,
      -- UART
      uart_rxd_i           => uart_rxd_i,
      uart_txd_o           => uart_txd_o,
      -- LEDs
      led_link_o           => wr_led_link,
      led_act_o            => wr_led_act,
      ---------------------------------------------------------
      -- SPI interface to DACs
      ---------------------------------------------------------
      plldac_sclk_o        => pll20dac_sclk_o,
      plldac_din_o         => pll20dac_din_o,
      pll20dac_din_o       => pll20dac_din_o,
      pll20dac_sclk_o      => pll20dac_sclk_o,
      pll20dac_sync_n_o    => pll20dac_sync_n_o,
      pll25dac_din_o       => pll25dac_din_o,
      pll25dac_sclk_o      => pll25dac_sclk_o,
      pll25dac_sync_n_o    => pll25dac_sync_n_o,
      ---------------------------------------------------------
      -- SFP
      ---------------------------------------------------------
      sfp_txp_o            => sfp_txp_o,
      sfp_txn_o            => sfp_txn_o,
      sfp_rxp_i            => sfp_rxp_i,
      sfp_rxn_i            => sfp_rxn_i,
      sfp_mod_def0_i       => sfp_mod_def0_i,
      sfp_mod_def1_b       => sfp_mod_def1_b,
      sfp_mod_def2_b       => sfp_mod_def2_b,
      sfp_rate_select_o    => sfp_rate_select_o,
      sfp_tx_fault_i       => sfp_tx_fault_i,
      sfp_tx_disable_o     => sfp_tx_disable_o,
      sfp_los_i            => sfp_los_i,
      ---------------------------------------------------------
      -- White Rabbit
      ---------------------------------------------------------
      tm_link_up_o         => tm_link_up,
      tm_time_valid_o      => tm_time_valid,
      tm_tai_o             => tm_tai,
      tm_cycles_o          => tm_cycles,
      tm_dac_value_o       => tm_dac_value,
      tm_dac_wr_o          => tm_dac_wr_p,
      tm_clk_aux_lock_en_i => tm_clk_aux_lock_en,
      tm_clk_aux_locked_o  => tm_clk_aux_locked,
      pps_p_o              => pps,
      pps_led_o            => pps_led,
      link_ok_o            => open,
      ---------------------------------------------------------
      -- IRQ
      ---------------------------------------------------------
      irq_user_i           => irq_vector,
      ---------------------------------------------------------
      -- FMC TDC application
      ---------------------------------------------------------
      -- FMC EEPROM I2C
      fmc0_scl_b           => fmc0_scl_b,
      fmc0_sda_b           => fmc0_sda_b,
      fmc1_scl_b           => fmc1_scl_b,
      fmc1_sda_b           => fmc1_sda_b,
      -- FMC presence
      fmc0_prsnt_m2c_n_i   => fmc0_prsnt_m2c_n_i,
      fmc1_prsnt_m2c_n_i   => fmc1_prsnt_m2c_n_i,
      -- FMC TDC application
      app_wb_o             => cnx_master_out(c_WB_MASTER_VME),
      app_wb_i             => cnx_master_in(c_WB_MASTER_VME));


---------------------------------------------------------------------------------------------------
--                                     CSR WISHBONE CROSSBAR                                     --
---------------------------------------------------------------------------------------------------
--   0x20000 -> TDC mezzanine SDBfmc

--  0x10000 -> SVEC carrier UnidueID&Thermometer 1-wire
--  0x20000 -> SVEC CSR information
--  0x30000 -> VIC
--  0x40000 -> TDC board on FMC#1
--  0x60000 -> TDC board on FMC#2
--  0x80000 -> White Rabbit core

  cmp_sdb_crossbar : xwb_crossbar
  generic map
    (g_num_masters => c_NUM_WB_MASTERS,
     g_num_slaves  => c_NUM_WB_SLAVES,
     g_registered  => TRUE,
     g_ADDRESS     => c_WB_LAYOUT_ADDR,
     g_MASK        => c_WB_LAYOUT_MASK)
  port map
    (clk_sys_i => clk_sys_62m5,
     rst_n_i   => rst_sys_62m5_n,
     slave_i   => cnx_master_out,
     slave_o   => cnx_master_in,
     master_i  => cnx_slave_out,
     master_o  => cnx_slave_in);


---------------------------------------------------------------------------------------------------
--                                           TDC BOARD 0                                         --
---------------------------------------------------------------------------------------------------

   cmp_tdc_mezzanine_1: entity work.fmc_tdc_wrapper
    generic map (
      g_SIMULATION                  => f_int2bool(g_SIMULATION),
      g_WITH_DIRECT_READOUT         => FALSE, -- true: for embedded applications, like WRTD
      g_USE_DMA_READOUT             => g_USE_DMA_READOUT,
      g_USE_FIFO_READOUT            => g_USE_FIFO_READOUT,
      g_USE_FAKE_TIMESTAMPS_FOR_SIM => g_USE_FAKE_TIMESTAMPS_FOR_SIM)
    port map (
      clk_sys_i            => clk_sys_62m5,
      rst_sys_n_i          => rst_sys_62m5_n,
      rst_n_a_i            => rst_sys_62m5_n, ------------ to be removed
      fmc_id_i             => '0', -- '0' for SPEC; '0' and '1' for each of the TDCs of SVEC
      fmc_present_n_i      => fmc0_prsnt_m2c_n_i,
      pll_sclk_o           => fmc0_tdc_pll_sclk_o,
      pll_sdi_o            => fmc0_tdc_pll_sdi_o,
      pll_cs_o             => fmc0_tdc_pll_cs_n_o,
      pll_dac_sync_o       => fmc0_tdc_pll_dac_sync_o,
      pll_sdo_i            => fmc0_tdc_pll_sdo_i,
      pll_status_i         => fmc0_tdc_pll_status_i,
      tdc_clk_125m_p_i     => fmc0_tdc_clk_125m_p_i,
      tdc_clk_125m_n_i     => fmc0_tdc_clk_125m_n_i,
      acam_refclk_p_i      => fmc0_tdc_acam_refclk_p_i,
      acam_refclk_n_i      => fmc0_tdc_acam_refclk_n_i,
      start_from_fpga_o    => fmc0_tdc_start_from_fpga_o,
      err_flag_i           => fmc0_tdc_err_flag_i,
      int_flag_i           => fmc0_tdc_int_flag_i,
      start_dis_o          => fmc0_tdc_start_dis_o,
      stop_dis_o           => fmc0_tdc_stop_dis_o,
      data_bus_io          => fmc0_tdc_data_bus_io,
      address_o            => fmc0_tdc_address_o,
      cs_n_o               => fmc0_tdc_cs_n_o,
      oe_n_o               => fmc0_tdc_oe_n_o,
      rd_n_o               => fmc0_tdc_rd_n_o,
      wr_n_o               => fmc0_tdc_wr_n_o,
      ef1_i                => fmc0_tdc_ef1_i,
      ef2_i                => fmc0_tdc_ef2_i,
      enable_inputs_o      => fmc0_tdc_enable_inputs_o,
      term_en_1_o          => fmc0_tdc_term_en_1_o,
      term_en_2_o          => fmc0_tdc_term_en_2_o,
      term_en_3_o          => fmc0_tdc_term_en_3_o,
      term_en_4_o          => fmc0_tdc_term_en_4_o,
      term_en_5_o          => fmc0_tdc_term_en_5_o,
      tdc_led_stat_o       => fmc0_tdc_led_status_o,
      tdc_led_trig_o(0)    => fmc0_tdc_led_trig1_o,
      tdc_led_trig_o(1)    => fmc0_tdc_led_trig2_o,
      tdc_led_trig_o(2)    => fmc0_tdc_led_trig3_o,
      tdc_led_trig_o(3)    => fmc0_tdc_led_trig4_o,
      tdc_led_trig_o(4)    => fmc0_tdc_led_trig5_o,

      mezz_scl_i           => fmc0_scl_in,
      mezz_sda_i           => fmc0_sda_in,
      mezz_scl_o           => fmc0_scl_oen,
      mezz_sda_o           => fmc0_sda_oen,
      mezz_one_wire_b      => fmc0_onewire_b,

      tm_link_up_i         => tm_link_up,
      tm_time_valid_i      => tm_time_valid,
      tm_cycles_i          => tm_cycles,
      tm_tai_i             => tm_tai,
      tm_clk_aux_lock_en_o => tm_clk_aux_lock_en(0),
      tm_clk_aux_locked_i  => tm_clk_aux_locked(0),
      tm_clk_dmtd_locked_i => '1',
      tm_dac_value_i       => tm_dac_value,
      tm_dac_wr_i          => tm_dac_wr_p(0),

      slave_i              => cnx_slave_in(c_WB_SLAVE_FMC0_TDC),
      slave_o              => cnx_slave_out(c_WB_SLAVE_FMC0_TDC),

      irq_o                => irq_vector(0),
      clk_125m_tdc_o       => fmc0_tdc_clk_125m);

-------------------------------------------------------------------------
  fmc1_scl_b   <= '0' when (fmc1_scl_oen = '0') else 'Z';
  fmc1_sda_b   <= '0' when (fmc1_sda_oen = '0') else 'Z';
  fmc0_scl_in  <= fmc0_scl_b;
  fmc0_sda_in  <= fmc0_sda_b;


---------------------------------------------------------------------------------------------------
--                                           TDC BOARD 1                                         --
---------------------------------------------------------------------------------------------------

  cmp_tdc_mezzanine_2: entity work.fmc_tdc_wrapper
    generic map (
      g_SIMULATION                  => f_int2bool(g_SIMULATION),
      g_WITH_DIRECT_READOUT         => FALSE, -- true: for embedded applications, like WRTD
      g_USE_DMA_READOUT             => g_USE_DMA_READOUT,
      g_USE_FIFO_READOUT            => TRUE,
      g_USE_FAKE_TIMESTAMPS_FOR_SIM => g_USE_FAKE_TIMESTAMPS_FOR_SIM)
    port map (
      clk_sys_i            => clk_sys_62m5,
      rst_sys_n_i          => rst_sys_62m5_n,
      rst_n_a_i            => rst_sys_62m5_n, ------------ to be removed
      fmc_id_i             => '1', -- '0' for SPEC; '0' and '1' for each of the TDCs of SVEC
      fmc_present_n_i      => fmc1_prsnt_m2c_n_i,
      pll_sclk_o           => fmc1_tdc_pll_sclk_o,
      pll_sdi_o            => fmc1_tdc_pll_sdi_o,
      pll_cs_o             => fmc1_tdc_pll_cs_n_o,
      pll_dac_sync_o       => fmc1_tdc_pll_dac_sync_o,
      pll_sdo_i            => fmc1_tdc_pll_sdo_i,
      pll_status_i         => fmc1_tdc_pll_status_i,
      tdc_clk_125m_p_i     => fmc1_tdc_clk_125m_p_i,
      tdc_clk_125m_n_i     => fmc1_tdc_clk_125m_n_i,
      acam_refclk_p_i      => fmc1_tdc_acam_refclk_p_i,
      acam_refclk_n_i      => fmc1_tdc_acam_refclk_n_i,
      start_from_fpga_o    => fmc1_tdc_start_from_fpga_o,
      err_flag_i           => fmc1_tdc_err_flag_i,
      int_flag_i           => fmc1_tdc_int_flag_i,
      start_dis_o          => fmc1_tdc_start_dis_o,
      stop_dis_o           => fmc1_tdc_stop_dis_o,
      data_bus_io          => fmc1_tdc_data_bus_io,
      address_o            => fmc1_tdc_address_o,
      cs_n_o               => fmc1_tdc_cs_n_o,
      oe_n_o               => fmc1_tdc_oe_n_o,
      rd_n_o               => fmc1_tdc_rd_n_o,
      wr_n_o               => fmc1_tdc_wr_n_o,
      ef1_i                => fmc1_tdc_ef1_i,
      ef2_i                => fmc1_tdc_ef2_i,
      enable_inputs_o      => fmc1_tdc_enable_inputs_o,
      term_en_1_o          => fmc1_tdc_term_en_1_o,
      term_en_2_o          => fmc1_tdc_term_en_2_o,
      term_en_3_o          => fmc1_tdc_term_en_3_o,
      term_en_4_o          => fmc1_tdc_term_en_4_o,
      term_en_5_o          => fmc1_tdc_term_en_5_o,
      tdc_led_stat_o       => fmc1_tdc_led_status_o,
      tdc_led_trig_o(0)    => fmc1_tdc_led_trig1_o,
      tdc_led_trig_o(1)    => fmc1_tdc_led_trig2_o,
      tdc_led_trig_o(2)    => fmc1_tdc_led_trig3_o,
      tdc_led_trig_o(3)    => fmc1_tdc_led_trig4_o,
      tdc_led_trig_o(4)    => fmc1_tdc_led_trig5_o,

      mezz_scl_i           => fmc1_scl_in,
      mezz_sda_i           => fmc1_sda_in,
      mezz_scl_o           => fmc1_scl_oen,
      mezz_sda_o           => fmc1_sda_oen,
      mezz_one_wire_b      => fmc1_onewire_b,

      tm_link_up_i         => tm_link_up,
      tm_time_valid_i      => tm_time_valid,
      tm_cycles_i          => tm_cycles,
      tm_tai_i             => tm_tai,
      tm_clk_aux_lock_en_o => tm_clk_aux_lock_en(1),
      tm_clk_aux_locked_i  => tm_clk_aux_locked(1),
      tm_clk_dmtd_locked_i => '1',
      tm_dac_value_i       => tm_dac_value,
      tm_dac_wr_i          => tm_dac_wr_p(1),

      slave_i              => cnx_slave_in(c_WB_SLAVE_FMC1_TDC),
      slave_o              => cnx_slave_out(c_WB_SLAVE_FMC1_TDC),

      irq_o                => irq_vector(1),
      clk_125m_tdc_o       => fmc1_tdc_clk_125m);

-------------------------------------------------------------------------
  fmc1_scl_b   <= '0' when (fmc1_scl_oen = '0') else 'Z';
  fmc1_sda_b   <= '0' when (fmc1_sda_oen = '0') else 'Z';
  fmc1_scl_in  <= fmc1_scl_b;
  fmc1_sda_in  <= fmc1_sda_b;



---------------------------------------------------------------------------------------------------
--                                     LEDs SVEC front panel                                     --
---------------------------------------------------------------------------------------------------
  cmp_LED_ctrler : gc_bicolor_led_ctrl
  generic map
    (g_NB_COLUMN     => 4,
     g_NB_LINE       => 2,
     g_CLK_FREQ      => 62500000,  -- in Hz
     g_REFRESH_RATE  => 250)       -- in Hz
  port map
    (rst_n_i         => rst_sys_62m5_n,
     clk_i           => clk_sys_62m5,
     led_intensity_i => "1100100", -- in %
     led_state_i     => led_state,
     column_o        => fp_led_column_o,
     line_o          => fp_led_line_o,
     line_oen_o      => fp_led_line_oen_o);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- led_state bits : 15                              0
  --                   ---------------------------------
  -- fp led number  :  | 5 | 6 | 7 | 8 | 1 | 2 | 3 | 4 |

  -- LED 1: White Rabbit act
  led_state(7  downto  6) <= c_LED_RED   when wr_led_link          = '1' else c_LED_OFF;
  -- LED 2: White Rabbit link
  led_state(5  downto  4) <= c_LED_GREEN when wr_led_link          = '1' else c_LED_OFF;
  -- LED 3: TDC1 empty flag
  led_state(3  downto  2) <= c_LED_GREEN when led_fmc0_tdc_ef      = '1' else c_LED_OFF;
  -- LED 4: TDC2 empty flag
  led_state(1  downto  0) <= c_LED_GREEN when led_fmc1_tdc_ef      = '1' else c_LED_OFF;
  -- LED 5: VME access
  led_state(15 downto 14) <= c_LED_GREEN when led_vme_access       = '1' else c_LED_OFF;
  -- LED 6: WR PPS blink
  led_state(13 downto 12) <= c_LED_GREEN when pps_led              = '1' else c_LED_OFF;
  -- LED 7: TDC1 locked to White Rabbit
  led_state(11 downto 10) <= c_LED_GREEN when tm_clk_aux_locked(0) = '1' else c_LED_OFF;
  -- LED 8: TDC2 locked to White Rabbit
  led_state(9  downto  8) <= c_LED_GREEN when tm_clk_aux_locked(1) = '1' else c_LED_OFF;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_drive_VME_access_LED: gc_extend_pulse
  generic map
    (g_width    => 5000000)
  port map
    (clk_i      => clk_sys_62m5,
     rst_n_i    => rst_sys_62m5_n,
     pulse_i    => cnx_slave_in(c_WB_MASTER_VME).cyc,
     extended_o => led_vme_access);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_drive_fmc0_tdc_EF_LED: gc_extend_pulse
  generic map
    (g_width    => 5000000)
  port map
    (clk_i      => clk_sys_62m5,
     rst_n_i    => rst_sys_62m5_n,
     pulse_i    => fmc0_tdc_ef,
     extended_o => led_fmc0_tdc_ef);
  --  --  --  --  --  --  --
  fmc0_tdc_ef <= not(fmc0_tdc_ef1_i) or not(fmc0_tdc_ef2_i);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_drive_fmc1_tdc_EF_LED: gc_extend_pulse
  generic map
    (g_width    => 5000000)
  port map
    (clk_i      => clk_sys_62m5,
     rst_n_i    => rst_sys_62m5_n,
     pulse_i    => fmc1_tdc_ef,
     extended_o => led_fmc1_tdc_ef);
  --  --  --  --  --  --  --
  fmc1_tdc_ef <= not(fmc1_tdc_ef1_i) or not(fmc1_tdc_ef2_i);


  -- Div by 2 reference clock to LEMO connector
  process(clk_ref_125m)
  begin
    if rising_edge(clk_ref_125m) then
      clk_ref_div2 <= not clk_ref_div2;
    end if;
  end process;

  -- Front panel IO configuration
  fp_gpio1_b      <= pps;
  fp_gpio2_b      <= clk_ref_div2;


  fp_term_en_o    <= (others => '0');
  fp_gpio1_a2b_o  <= '1';
  fp_gpio2_a2b_o  <= '1';
  fp_gpio34_a2b_o <= '0';


end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
