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
    (g_WRPC_INITF    : string  := "../../ip_cores/wr-cores/bin/wrpc/wrc_phy8.bram";
     g_simulation                  : boolean := false;
     g_use_dma_readout             : boolean := true;
     g_use_fake_timestamps_for_sim : boolean := false  -- when instantiated in a test-bench
     );

  port(
    -- Reset button
    button1_n_i         : in  std_logic := '1';

    -- Clocks
    clk_20m_vcxo_i      : in std_logic;  -- 20 MHz VCXO
    clk_125m_pllref_p_i : in std_logic;  -- 125 MHz PLL reference
    clk_125m_pllref_n_i : in std_logic;
    clk_125m_gtp_n_i    : in std_logic;  -- 125 MHz GTP reference
    clk_125m_gtp_p_i    : in std_logic;

    -- DAC interface 20MHz and 25MHz VCXO
    pll25dac_cs_n_o : out std_logic;          -- 25MHz VCXO
    pll20dac_cs_n_o : out std_logic;          -- 20MHz VCXO
    plldac_din_o    : out std_logic;
    plldac_sclk_o   : out std_logic;

    -- SFP
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

    -- SPEC 1-wire interface
    onewire_b : inout std_logic; --  DS18B20 thermometer + uniqueID

    -- SPEC front panel leds
    led_act_o     : out std_logic;
    led_link_o    : out std_logic;

    -- SPEC PCB version
    pcbrev_i     : in  std_logic_vector(3 downto 0);

    -- UART
    uart_rxd_i        : in    std_logic := '1';
    uart_txd_o        : out   std_logic;

    -- Flash SPI
    spi_sclk_o : out std_logic;
    spi_ncs_o  : out std_logic;
    spi_mosi_o : out std_logic;
    spi_miso_i : in  std_logic := 'L';

    -- DDR (bank 3)
    ddr_a_o       : out   std_logic_vector(13 downto 0);
    ddr_ba_o      : out   std_logic_vector(2 downto 0);
    ddr_cas_n_o   : out   std_logic;
    ddr_ck_n_o    : out   std_logic;
    ddr_ck_p_o    : out   std_logic;
    ddr_cke_o     : out   std_logic;
    ddr_dq_b      : inout std_logic_vector(15 downto 0);
    ddr_ldm_o     : out   std_logic;
    ddr_ldqs_n_b  : inout std_logic;
    ddr_ldqs_p_b  : inout std_logic;
    ddr_odt_o     : out   std_logic;
    ddr_ras_n_o   : out   std_logic;
    ddr_reset_n_o : out   std_logic;
    ddr_rzq_b     : inout std_logic;
    ddr_udm_o     : out   std_logic;
    ddr_udqs_n_b  : inout std_logic;
    ddr_udqs_p_b  : inout std_logic;
    ddr_we_n_o    : out   std_logic;

    -- GN4124 interface
    gn_rst_n_i    : in  std_logic;      -- reset from gn4124 (rstout18_n)
    gn_gpio_b       : inout std_logic_vector(1 downto 0);  -- gpio[0] -> gn4124 gpio8
    -- pcie to local [inbound data] - rx
    gn_p2l_rdy_o    : out std_logic;      -- rx buffer full flag
    gn_p2l_clk_n_i   : in  std_logic;      -- receiver source synchronous clock-
    gn_p2l_clk_p_i   : in  std_logic;      -- receiver source synchronous clock+
    gn_p2l_data_i   : in  std_logic_vector(15 downto 0);  -- parallel receive data
    gn_p2l_dframe_i : in  std_logic;      -- receive frame
    gn_p2l_valid_i  : in  std_logic;      -- receive data valid
    -- inbound buffer request/status
    gn_p_wr_req_i   : in  std_logic_vector(1 downto 0);  -- pcie write request
    gn_p_wr_rdy_o   : out std_logic_vector(1 downto 0);  -- pcie write ready
    gn_rx_error_o   : out std_logic;      -- receive error
    -- local to parallel [outbound data] - tx
    gn_l2p_data_o   : out std_logic_vector(15 downto 0);  -- parallel transmit data
    gn_l2p_dframe_o : out std_logic;      -- transmit data frame
    gn_l2p_valid_o  : out std_logic;      -- transmit data valid
    gn_l2p_clk_n_o  : out std_logic;  -- transmitter source synchronous clock-
    gn_l2p_clk_p_o  : out std_logic;  -- transmitter source synchronous clock+
    gn_l2p_edb_o    : out std_logic;      -- packet termination and discard
    -- outbound buffer status
    gn_l2p_rdy_i    : in  std_logic;      -- tx buffer full flag
    gn_l_wr_rdy_i   : in  std_logic_vector(1 downto 0);  -- local-to-pcie write
    gn_p_rd_d_rdy_i : in  std_logic_vector(1 downto 0);  -- pcie-to-local read response data ready
    gn_tx_error_i   : in  std_logic;      -- transmit error
    gn_vc_rdy_i     : in  std_logic_vector(1 downto 0);  -- channel ready

    ------------------------------------------------------------------------
    -- FMC slot
    ------------------------------------------------------------------------
    fmc0_tdc_pll_sclk_o       : out std_logic;   -- SPI clock
    fmc0_tdc_pll_sdi_o        : out std_logic;   -- data line for PLL and DAC
    fmc0_tdc_pll_cs_o         : out std_logic;   -- PLL chip select
    fmc0_tdc_pll_dac_sync_o   : out std_logic;   -- DAC chip select
    fmc0_tdc_pll_sdo_i        : in  std_logic;   -- not used for the moment
    fmc0_tdc_pll_status_i     : in  std_logic;   -- PLL Digital Lock Detect, active high
    fmc0_tdc_clk_125m_p_i     : in  std_logic;   -- 125 MHz differential clock: system clock
    fmc0_tdc_clk_125m_n_i     : in  std_logic;   -- 125 MHz differential clock: system clock
    fmc0_tdc_acam_refclk_p_i  : in  std_logic;   -- 31.25 MHz differential clock: ACAM ref clock
    fmc0_tdc_acam_refclk_n_i  : in  std_logic;   -- 31.25 MHz differential clock: ACAM ref clock

    -- Timing interface with the ACAM on TDC mezzanine
    fmc0_tdc_start_from_fpga_o : out   std_logic;  -- start signal
    fmc0_tdc_err_flag_i        : in    std_logic;  -- error flag
    fmc0_tdc_int_flag_i        : in    std_logic;  -- interrupt flag
    fmc0_tdc_start_dis_o       : out   std_logic;  -- start disable, not used
    fmc0_tdc_stop_dis_o        : out   std_logic;  -- stop disable, not used
    -- Data interface with the ACAM on TDC mezzanine
    fmc0_tdc_data_bus_io       : inout std_logic_vector(27 downto 0);
    fmc0_tdc_address_o         : out   std_logic_vector(3 downto 0);
    fmc0_tdc_cs_n_o            : out   std_logic;  -- chip select for ACAM
    fmc0_tdc_oe_n_o            : out   std_logic;  -- output enable for ACAM
    fmc0_tdc_rd_n_o            : out   std_logic;  -- read  signal for ACAM
    fmc0_tdc_wr_n_o            : out   std_logic;  -- write signal for ACAM
    fmc0_tdc_ef1_i             : in    std_logic;  -- empty flag iFIFO1
    fmc0_tdc_ef2_i             : in    std_logic;  -- empty flag iFIFO2
    -- Enable of input Logic on TDC mezzanine
    fmc0_tdc_enable_inputs_o   : out   std_logic;  -- enables all 5 inputs
    fmc0_tdc_term_en_1_o       : out   std_logic;  -- Ch.1 termination enable of 50 Ohm termination
    fmc0_tdc_term_en_2_o       : out   std_logic;  -- Ch.2 termination enable of 50 Ohm termination
    fmc0_tdc_term_en_3_o       : out   std_logic;  -- Ch.3 termination enable of 50 Ohm termination
    fmc0_tdc_term_en_4_o       : out   std_logic;  -- Ch.4 termination enable of 50 Ohm termination
    fmc0_tdc_term_en_5_o       : out   std_logic;  -- Ch.5 termination enable of 50 Ohm termination
    -- LEDs on TDC mezzanine
    fmc0_tdc_led_status_o  : out   std_logic;  -- amber led on front pannel, division of 125 MHz tdc_clk
    fmc0_tdc_led_trig1_o   : out   std_logic;  -- amber led on front pannel, Ch.1 enable
    fmc0_tdc_led_trig2_o   : out   std_logic;  -- amber led on front pannel, Ch.2 enable
    fmc0_tdc_led_trig3_o   : out   std_logic;  -- amber led on front pannel, Ch.3 enable
    fmc0_tdc_led_trig4_o   : out   std_logic;  -- amber led on front pannel, Ch.4 enable
    fmc0_tdc_led_trig5_o   : out   std_logic;  -- amber led on front pannel, Ch.5 enable
    -- Input Logic on TDC mezzanine (not used currently)
    fmc0_tdc_in_fpga_1_i   : in    std_logic;  -- Ch.1 for ACAM, also received by FPGA
    fmc0_tdc_in_fpga_2_i   : in    std_logic;  -- Ch.2 for ACAM, also received by FPGA
    fmc0_tdc_in_fpga_3_i   : in    std_logic;  -- Ch.3 for ACAM, also received by FPGA
    fmc0_tdc_in_fpga_4_i   : in    std_logic;  -- Ch.4 for ACAM, also received by FPGA
    fmc0_tdc_in_fpga_5_i   : in    std_logic;  -- Ch.5 for ACAM, also received by FPGA
    -- I2C EEPROM interface on TDC mezzanine
    fmc0_scl_b             : inout std_logic := '1';  -- Mezzanine system EEPROM I2C clock
    fmc0_sda_b             : inout std_logic := '1';  -- Mezzanine system EEPROM I2C data
    -- 1-wire interface on TDC mezzanine
    fmc0_tdc_onewire_b    : inout std_logic;  -- Mezzanine presence (active low)
    -- Presence of a mezzanine
    fmc0_prsnt_m2c_n_i : in  std_logic;

    -- Auxiliary pins
    aux_leds_o : out std_logic_vector(3 downto 0)   
 
    -- Bypass GN4124 core, useful only in simulation
    -- Feed fake timestamps bypassing acam - used only in simulation
    -- synthesis translate_off
;
    sim_wb_i : in  t_wishbone_slave_in := cc_dummy_slave_in;
    sim_wb_o : out t_wishbone_slave_out;

    sim_timestamp_i       : in  t_tdc_timestamp := c_dummy_timestamp;
    sim_timestamp_valid_i : in  std_logic       := '0';
    sim_timestamp_ready_o : out std_logic
-- synthesis translate_on
    );

end wr_spec_tdc;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of wr_spec_tdc is

  function f_bool2int (x : boolean) return integer is
  begin
    if(x) then
      return 1;
    else
      return 0;
    end if;
  end f_bool2int;


  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------

 -- Number of masters attached to the primary wishbone crossbar
  constant c_NUM_WB_MASTERS    : integer := 1;

  -- Number of slaves attached to the primary wishbone crossbar
  constant c_NUM_WB_SLAVES     : integer := 2;

  -- Primary Wishbone master(s) offsets
  constant c_WB_MASTER_GENNUM  : integer := 0;

  -- Primary Wishbone slave(s) offsets
  constant c_WB_SLAVE_METADATA : integer := 0;
  constant c_WB_SLAVE_FMC_TDC  : integer := 1;  -- TDC core configuration(??)

  -- Convention metadata base address
  constant c_METADATA_ADDR : t_wishbone_address := x"0000_2000";

  -- Primary wishbone crossbar layout
  constant c_WB_LAYOUT_ADDR :
    t_wishbone_address_array(c_NUM_WB_SLAVES - 1 downto 0) := (
      c_WB_SLAVE_METADATA => c_METADATA_ADDR,
      c_WB_SLAVE_FMC_TDC  => x"0002_0000");

-- mask is 18 bits long and is active-low
  constant c_WB_LAYOUT_MASK :
    t_wishbone_address_array(c_NUM_WB_SLAVES - 1 downto 0) := (
      c_WB_SLAVE_METADATA => x"0003_ffc0",  -- 0x40    bytes  : not(0x40   -1) = not(0x3F)   = c0
      c_WB_SLAVE_FMC_TDC  => x"0002_0000");

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  -- Clocks and resets
  signal clk_sys_62m5, rst_sys_62m5_n   : std_logic;
  signal clk_ref_125m, rst_ref_125m_n   : std_logic;
  signal tdc0_clk_125m  : std_logic; -- WR aux cloxk
  -- WISHBONE from crossbar master port
  signal cnx_master_out            : t_wishbone_master_out_array(c_NUM_WB_MASTERS-1 downto 0);
  signal cnx_master_in             : t_wishbone_master_in_array(c_NUM_WB_MASTERS-1 downto 0);

  -- WISHBONE to crossbar slave port
  signal cnx_slave_out             : t_wishbone_slave_out_array(c_NUM_WB_SLAVES-1 downto 0);
  signal cnx_slave_in              : t_wishbone_slave_in_array(c_NUM_WB_SLAVES-1 downto 0);
  signal gn_wb_adr                 : std_logic_vector(31 downto 0);

  -- WRPC TM interface and status
  signal tm_link_up, tm_time_valid : std_logic;
  signal tm_dac_wr_p               : std_logic;
  signal tm_tai                    : std_logic_vector(39 downto 0);
  signal tm_cycles                 : std_logic_vector(27 downto 0);
  signal tm_dac_value              : std_logic_vector(23 downto 0);
  signal tm_clk_aux_lock_en        : std_logic;
  signal tm_clk_aux_locked         : std_logic;
  signal wrabbit_en, pps_led            : std_logic;

  -- Interrupts and status
  signal ddr_wr_fifo_empty  : std_logic;  -- not used
  signal fmc0_irq           : std_logic;
  signal irq_vector         : std_logic_vector(0 downto 0);
  signal gn4124_access      : std_logic;

  -- FMC TDC
  signal tdc_scl_oen, tdc_scl_in   : std_logic;
  signal tdc_sda_oen, tdc_sda_in   : std_logic;
  -- aux


  signal tdc0_soft_rst_n : std_logic;

  signal ddr3_tdc_adr : std_logic_vector(31 downto 0);

  signal powerup_rst_cnt      : unsigned(7 downto 0) := "00000000";
  signal carrier_info_fmc_rst : std_logic_vector(30 downto 0);



  signal tdc_dma_out : t_wishbone_master_out;
  signal tdc_dma_in  : t_wishbone_master_in;


  -- Wishbone buses from FMC ADC cores to DDR controller
  signal fmc0_wb_ddr_in  : t_wishbone_master_in;
  signal fmc0_wb_ddr_out : t_wishbone_master_out;

  -- Simulation
  signal sim_ts_valid, sim_ts_ready : std_logic;
  signal sim_ts                     : t_tdc_timestamp;

  signal ddr3_status : std_logic_vector(31 downto 0);

  function f_to_string(x : boolean) return string is
  begin
    if x then
      return "TRUE";
    else
      return "FALSE";
    end if;
  end f_to_string;
  signal dma_reg_adr : std_logic_vector(31 downto 0);




--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

  -- synthesis translate_off
  sim_ts                <= sim_timestamp_i;
  sim_ts_valid          <= sim_timestamp_valid_i;
  sim_timestamp_ready_o <= sim_ts_ready;
  -- synthesis translate_on

  cmp_xwb_metadata : entity work.xwb_metadata
    generic map (
      g_VENDOR_ID    => x"0000_10DC",
      g_DEVICE_ID    => x"574E_0001", -- WRTD Node (WN) 1
      g_VERSION      => x"0100_0000",
      g_CAPABILITIES => x"0000_0000",
      g_COMMIT_ID    => (others => '0'))
    port map (
      clk_i   => clk_sys_62m5,
      rst_n_i => rst_sys_62m5_n,
      wb_i    => cnx_slave_in(c_WB_SLAVE_METADATA),
      wb_o    => cnx_slave_out(c_WB_SLAVE_METADATA));

-------------------------------------------------------------------------------
--            SPEC Board Wrapper                                             --
-------------------------------------------------------------------------------
  inst_spec_base : entity work.spec_base_wr
    generic map (
      g_WITH_VIC      => TRUE,
      g_WITH_ONEWIRE  => FALSE,
      g_WITH_SPI      => FALSE,
      g_WITH_WR       => TRUE,
      g_WITH_DDR      => TRUE,
      g_DDR_DATA_SIZE => 32,
      g_APP_OFFSET    => c_METADATA_ADDR,
      g_NUM_USER_IRQ  => 1,
      g_DPRAM_INITF   => g_WRPC_INITF,
      g_AUX_CLKS      => 1,
      g_FABRIC_IFACE  => PLAIN,
      g_SIMULATION    => g_SIMULATION)
    port map (
      ---------------------------------------------------------
      -- Clocks/ Resets
      ---------------------------------------------------------
      -- 20MHz VCXO
      clk_20m_vcxo_i      => clk_20m_vcxo_i,
      -- 125MHz PLL reference
      clk_125m_pllref_p_i => clk_125m_pllref_p_i,
      clk_125m_pllref_n_i => clk_125m_pllref_n_i,
      -- 125MHz GTP reference
      clk_125m_gtp_n_i    => clk_125m_gtp_n_i,
      clk_125m_gtp_p_i    => clk_125m_gtp_p_i,
      -- 62.5MHz System Clk generated from Xilinx internal PLL 
      clk_62m5_sys_o      => clk_sys_62m5,
      rst_62m5_sys_n_o    => rst_sys_62m5_n,
      -- 125Hz Ref Clk generated from Xilinx internal PLL
      clk_125m_ref_o      => clk_ref_125m,
      rst_125m_ref_n_o    => rst_ref_125m_n,
      ---------------------------------------------------------
      -- GN4124 
      ---------------------------------------------------------
      -- Reset from gn4124 (rstout18_n)
      gn_rst_n_i          => gn_rst_n_i,
      -- PCIe-2-Local inbound data - rx
      gn_p2l_clk_n_i      => gn_p2l_clk_n_i,
      gn_p2l_clk_p_i      => gn_p2l_clk_p_i,
      gn_p2l_rdy_o        => gn_p2l_rdy_o,
      gn_p2l_dframe_i     => gn_p2l_dframe_i,
      gn_p2l_valid_i      => gn_p2l_valid_i,
      gn_p2l_data_i       => gn_p2l_data_i,
      -- PCIe-2-Local inbound buffer request/status
      gn_p_wr_req_i       => gn_p_wr_req_i,
      gn_rx_error_o       => gn_rx_error_o,
      gn_p_wr_rdy_o       => gn_p_wr_rdy_o,
      -- Local-2-Parallel outbound data - tx
      gn_l2p_clk_n_o      => gn_l2p_clk_n_o,
      gn_l2p_clk_p_o      => gn_l2p_clk_p_o,
      gn_l2p_valid_o      => gn_l2p_valid_o,
      gn_l2p_dframe_o     => gn_l2p_dframe_o,
      gn_l2p_edb_o        => gn_l2p_edb_o,
      gn_l2p_data_o       => gn_l2p_data_o,
      -- Local-2-Parallel outbound buffer status
      gn_l2p_rdy_i        => gn_l2p_rdy_i,
      gn_l_wr_rdy_i       => gn_l_wr_rdy_i,
      gn_p_rd_d_rdy_i     => gn_p_rd_d_rdy_i,
      gn_tx_error_i       => gn_tx_error_i,
      gn_vc_rdy_i         => gn_vc_rdy_i,
      -- GPIO
      gn_gpio_b           => gn_gpio_b,
      ---------------------------------------------------------
      -- Carrier peripherals
      ---------------------------------------------------------
      -- LEDs and Buttons
      led_act_o           => led_act_o,
      led_link_o          => led_link_o,
      button1_n_i         => button1_n_i,
      -- PCB version 
      pcbrev_i            => pcbrev_i,
      -- 1-wire
      onewire_b           => onewire_b,
      -- SPI flash
      spi_sclk_o          => spi_sclk_o,
      spi_ncs_o           => spi_ncs_o,
      spi_mosi_o          => spi_mosi_o,
      spi_miso_i          => spi_miso_i,
      -- UART 
      uart_rxd_i          => uart_rxd_i,
      uart_txd_o          => uart_txd_o,
      ---------------------------------------------------------
      -- SPI interface to DACs
      ---------------------------------------------------------
      plldac_sclk_o       => plldac_sclk_o,
      plldac_din_o        => plldac_din_o,
      pll25dac_cs_n_o     => pll25dac_cs_n_o,
      pll20dac_cs_n_o     => pll20dac_cs_n_o,
      ---------------------------------------------------------
      -- SFP
      ---------------------------------------------------------
      sfp_txp_o           => sfp_txp_o,
      sfp_txn_o           => sfp_txn_o,
      sfp_rxp_i           => sfp_rxp_i,
      sfp_rxn_i           => sfp_rxn_i,
      sfp_mod_def0_i      => sfp_mod_def0_i,
      sfp_mod_def1_b      => sfp_mod_def1_b,
      sfp_mod_def2_b      => sfp_mod_def2_b,
      sfp_rate_select_o   => sfp_rate_select_o,
      sfp_tx_fault_i      => sfp_tx_fault_i,
      sfp_tx_disable_o    => sfp_tx_disable_o,
      sfp_los_i           => sfp_los_i,
      ---------------------------------------------------------
      -- DDR (bank 3)
      ---------------------------------------------------------
      ddr_a_o             => ddr_a_o,
      ddr_ba_o            => ddr_ba_o,
      ddr_cas_n_o         => ddr_cas_n_o,
      ddr_ck_n_o          => ddr_ck_n_o,
      ddr_ck_p_o          => ddr_ck_p_o,
      ddr_cke_o           => ddr_cke_o,
      ddr_dq_b            => ddr_dq_b,
      ddr_ldm_o           => ddr_ldm_o,
      ddr_ldqs_n_b        => ddr_ldqs_n_b,
      ddr_ldqs_p_b        => ddr_ldqs_p_b,
      ddr_odt_o           => ddr_odt_o,
      ddr_ras_n_o         => ddr_ras_n_o,
      ddr_reset_n_o       => ddr_reset_n_o,
      ddr_rzq_b           => ddr_rzq_b,
      ddr_udm_o           => ddr_udm_o,
      ddr_udqs_n_b        => ddr_udqs_n_b,
      ddr_udqs_p_b        => ddr_udqs_p_b,
      ddr_we_n_o          => ddr_we_n_o,
      ----------------------------------
      ddr_dma_clk_i       => clk_ref_125m,
      ddr_dma_rst_n_i     => rst_ref_125m_n,
      ddr_dma_wb_cyc_i    => fmc0_wb_ddr_out.cyc,
      ddr_dma_wb_stb_i    => fmc0_wb_ddr_out.stb,
      ddr_dma_wb_adr_i    => fmc0_wb_ddr_out.adr,
      ddr_dma_wb_sel_i    => fmc0_wb_ddr_out.sel,
      ddr_dma_wb_we_i     => fmc0_wb_ddr_out.we,
      ddr_dma_wb_dat_i    => fmc0_wb_ddr_out.dat,
      ddr_dma_wb_ack_o    => fmc0_wb_ddr_in.ack,
      ddr_dma_wb_stall_o  => fmc0_wb_ddr_in.stall,
      ddr_dma_wb_dat_o    => fmc0_wb_ddr_in.dat,
      ddr_wr_fifo_empty_o => ddr_wr_fifo_empty, -- not used
      ---------------------------------------------------------
      -- IRQ
      ---------------------------------------------------------
      irq_user_i          => irq_vector,
      ---------------------------------------------------------
      -- White Rabbit
      ---------------------------------------------------------
      wrf_src_o           => open,
      wrf_src_i           => open,
      wrf_snk_o           => open,
      wrf_snk_i           => open,
      tm_link_up_o        => tm_link_up,
      tm_time_valid_o     => tm_time_valid,
      tm_tai_o            => tm_tai,
      tm_cycles_o         => tm_cycles,
      pps_p_o             => open,
      pps_led_o           => pps_led,
      link_ok_o           => wrabbit_en,
      -- Aux clocks control
      clk_aux_i(0)        => tdc0_clk_125m,
      tm_dac_value_o      => tm_dac_value,
      tm_dac_wr_o(0)      => tm_dac_wr_p,
      tm_clk_aux_lock_en_i(0)=> tm_clk_aux_lock_en,
      tm_clk_aux_locked_o(0)=> tm_clk_aux_locked,

      ---------------------------------------------------------
      -- FMC TDC application
      ---------------------------------------------------------
      -- FMC EEPROM I2C
      fmc0_scl_b          => fmc0_scl_b,
      fmc0_sda_b          => fmc0_sda_b,
      -- FMC presence 
      fmc0_prsnt_m2c_n_i  => fmc0_prsnt_m2c_n_i,
      -- FMC TDC application 
      app_wb_o            => cnx_master_out(c_WB_MASTER_GENNUM),
      app_wb_i            => cnx_master_in(c_WB_MASTER_GENNUM));

---------------------------------------------------------------------------------------------------
--                                     CSR WISHBONE CROSSBAR                                     --
---------------------------------------------------------------------------------------------------
--   0x20000 -> TDC mezzanine SDBfmc
--     0x21000 -> TDC Mezzanine 1-wire master
--     0x22000 -> TDC core configuration (including ACAM regs)
--     0x23000 -> TDC Mezzanine Embedded Interrupt Controller
--     0x24000 -> TDC Mezzanine I2C master
--     0x25000 -> TDC core FIFO ch1 timestamps retrieval
--     0x25100 -> TDC core FIFO ch1 timestamps retrieval
--     0x25200 -> TDC core FIFO ch1 timestamps retrieval
--     0x25300 -> TDC core FIFO ch1 timestamps retrieval
--     0x25400 -> TDC core FIFO ch1 timestamps retrieval
  cmp_crossbar : xwb_crossbar
    generic map (
      g_VERBOSE     => FALSE,
      g_NUM_MASTERS => c_NUM_WB_MASTERS,
      g_NUM_SLAVES  => c_NUM_WB_SLAVES,
      g_REGISTERED  => TRUE,
      g_ADDRESS     => c_WB_LAYOUT_ADDR,
      g_MASK        => c_WB_LAYOUT_MASK)
    port map (
      clk_sys_i => clk_sys_62m5,
      rst_n_i   => rst_sys_62m5_n,
      slave_i   => cnx_master_out,
      slave_o   => cnx_master_in,
      master_i  => cnx_slave_out,
      master_o  => cnx_slave_in);

  cmp_fmc_tdc_mezzanine : entity work.fmc_tdc_wrapper
    generic map (
      g_simulation                  => g_simulation,
      g_with_direct_readout         => false, -- for embedded applications, like WRTD
      g_use_dma_readout             => g_use_dma_readout,
      g_use_fifo_readout            => TRUE,
      g_use_fake_timestamps_for_sim => g_use_fake_timestamps_for_sim)
    port map (
      clk_sys_i            => clk_sys_62m5,
      rst_sys_n_i          => rst_sys_62m5_n,
      rst_n_a_i            => rst_sys_62m5_n, ------------ to be removed
      fmc_id_i             => '0', -- '0' for SPEC; '0' and '1' for each of the TDCs of SVEC
      pll_sclk_o           => fmc0_tdc_pll_sclk_o,
      pll_sdi_o            => fmc0_tdc_pll_sdi_o,
      pll_cs_o             => fmc0_tdc_pll_cs_o,
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

      mezz_scl_o           => tdc_scl_oen,
      mezz_sda_o           => tdc_sda_oen,
      mezz_scl_i           => tdc_scl_in,
      mezz_sda_i           => tdc_sda_in,

      mezz_one_wire_b      => fmc0_tdc_onewire_b,

      tm_link_up_i         => tm_link_up,
      tm_time_valid_i      => tm_time_valid,
      tm_cycles_i          => tm_cycles,
      tm_tai_i             => tm_tai,
      tm_clk_aux_lock_en_o => tm_clk_aux_lock_en,
      tm_clk_aux_locked_i  => tm_clk_aux_locked,
      tm_clk_dmtd_locked_i => '1',
      tm_dac_value_i       => tm_dac_value,
      tm_dac_wr_i          => tm_dac_wr_p,

      slave_i              => cnx_slave_in(c_WB_SLAVE_FMC_TDC),
      slave_o              => cnx_slave_out(c_WB_SLAVE_FMC_TDC),
      dma_wb_i             => fmc0_wb_ddr_in,
      dma_wb_o             => fmc0_wb_ddr_out,

      irq_o                => irq_vector(0),
      clk_125m_tdc_o       => tdc0_clk_125m);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  fmc0_wb_ddr_in.err <= '0';
  fmc0_wb_ddr_in.rty <= '0';

  -- Tristates for TDC mezzanine EEPROM
  fmc0_scl_b <= '0' when (tdc_scl_oen = '0') else 'Z';
  fmc0_sda_b <= '0' when (tdc_sda_oen = '0') else 'Z';
  tdc_scl_in     <= fmc0_scl_b;
  tdc_sda_in     <= fmc0_sda_b;

  ------------------------------------------------------------------------------
  -- Carrier LEDs
  ------------------------------------------------------------------------------

  cmp_pci_access_led : gc_extend_pulse
    generic map (
      g_width => 2500000)
    port map (
      clk_i      => clk_sys_62m5,
      rst_n_i    => rst_sys_62m5_n,
      pulse_i    => cnx_slave_in(c_WB_MASTER_GENNUM).cyc,
      extended_o => gn4124_access);

  aux_leds_o(0) <= not gn4124_access;
  aux_leds_o(1) <= '1';
  aux_leds_o(2) <= not tm_time_valid;
  aux_leds_o(3) <= not pps_led;


------------------------------------------------------------------------------
  -- check if they are needed
  ------------------------------------------------------------------------------
  -------------ddr3_tdc_adr    <= "00" & tdc_dma_out.adr(31 downto 2);
  -------------dma_reg_adr <= "00" & cnx_master_out(c_WB_SLAVE_DMA).adr(31 downto 2);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Convert 32-bit word address into byte address for crossbar
  ------------cnx_slave_in(c_MASTER_GENNUM).adr <= gn_wb_adr(29 downto 0) & "00";





end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
