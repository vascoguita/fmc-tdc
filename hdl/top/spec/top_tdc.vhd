--_________________________________________________________________________________________________
--                                                                                                |
--                                           |TDC core|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                            top_tdc                                             |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         top_tdc.vhd                                                                       |
--                                                                                                |
-- Description  TDC top level                                                                     |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
--              Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
-- Date         06/2012                                                                           |
-- Version      v3                                                                                |
-- Depends on                                                                                     |
--                                                                                                |
----------------                                                                                  |
-- Last changes                                                                                   |
--     05/2011  v1  GP  First version                                                             |
--     06/2012  v2  EG  Revamping; Comments added, signals renamed                                |
--                      removed LEDs from top level                                               |
--                      new gnum core integrated                                                  |
--                      carrier 1 wire master added                                               |
--                      mezzanine I2C master added                                                |
--                      mezzanine 1 wire master added                                             |
--                      interrupts generator added                                                |
--                      changed generation of general_rst                                         | 
--                      DAC reconfiguration+needed regs added                                     |
--     06/2012  v3  EG  Changes for v2 of TDC mezzanine                                           |
--                      Several pinout changes,                                                   |
--                      acam_ref_clk LVDS instead of CMOS,                                        |
--                      no PLL_LD only PLL_STATUS                                                 |
--     04/2013  v4  EG  added SDB; fixed bugs in data_formatting; added carrier CSR information   |
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
use work.gn4124_core_pkg.all;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;
use work.sdb_meta_pkg.all;
library UNISIM;
use UNISIM.vcomponents.all;

--=================================================================================================
--                                   Entity declaration for top_tdc
--=================================================================================================
entity top_tdc is
  generic
    (g_span             : integer :=32;                       -- address span in bus interfaces
     g_width            : integer :=32;                       -- data width in bus interfaces
     values_for_simul   : boolean :=FALSE);                   -- this generic is set to TRUE
                                                              -- when instantiated in a test-bench
  port
    (-- Signals for the GNUM interface
     rst_n_a_i          : in    std_logic;
     -- P2L Direction
     p2l_clk_p_i        : in    std_logic;                    -- Receiver Source Synchronous Clock+
     p2l_clk_n_i        : in    std_logic;                    -- Receiver Source Synchronous Clock-
     p2l_data_i         : in    std_logic_vector(15 downto 0);-- Parallel receive data
     p2l_dframe_i       : in    std_logic;                    -- Receive Frame
     p2l_valid_i        : in    std_logic;                    -- Receive Data Valid
     p2l_rdy_o          : out   std_logic;                    -- Rx Buffer Full Flag
     p_wr_req_i         : in    std_logic_vector(1 downto 0); -- PCIe Write Request
     p_wr_rdy_o         : out   std_logic_vector(1 downto 0); -- PCIe Write Ready
     rx_error_o         : out   std_logic;                    -- Receive Error
     vc_rdy_i           : in    std_logic_vector(1 downto 0); -- Virtual channel ready
     -- L2P Direction
     l2p_clk_p_o        : out   std_logic;                    -- Transmitter Source Synchronous Clock+ (freq set in GN4124 config registers)
     l2p_clk_n_o        : out   std_logic;                    -- Transmitter Source Synchronous Clock- (freq set in GN4124 config registers)
     l2p_data_o         : out   std_logic_vector(15 downto 0);-- Parallel transmit data
     l2p_dframe_o       : out   std_logic;                    -- Transmit Data Frame
     l2p_valid_o        : out   std_logic;                    -- Transmit Data Valid
     l2p_edb_o          : out   std_logic;                    -- Packet termination and discard
     l2p_rdy_i          : in    std_logic;                    -- Tx Buffer Full Flag
     l_wr_rdy_i         : in    std_logic_vector(1 downto 0); -- Local-to-PCIe Write
     p_rd_d_rdy_i       : in    std_logic_vector(1 downto 0); -- PCIe-to-Local Read Response Data Ready
     tx_error_i         : in    std_logic;                    -- Transmit Error
     irq_p_o            : inout std_logic;                    -- Interrupt request pulse to GN4124 GPIO 8
     irq_aux_p_o        : inout std_logic;                    -- Interrupt request pulse to GN4124 GPIO 9, aux signal

     -- Signals for the interface with the PLL AD9516 and DAC AD5662 on TDC mezzanine
     pll_sclk_o         : out   std_logic;                    -- SPI clock
     pll_sdi_o          : out   std_logic;                    -- data line for PLL and DAC
     pll_cs_o           : out   std_logic;                    -- PLL chip select
     pll_dac_sync_o     : out   std_logic;                    -- DAC chip select
     pll_sdo_i          : in    std_logic;                    -- not used for the moment
     pll_status_i       : in    std_logic;                    -- PLL Digital Lock Detect, active high
     tdc_clk_p_i        : in    std_logic;                    -- 125 MHz differential clock: system clock
     tdc_clk_n_i        : in    std_logic;                    -- 125 MHz differential clock: system clock
     acam_refclk_p_i    : in    std_logic;                    -- 31.25 MHz differential clock: ACAM ref clock
     acam_refclk_n_i    : in    std_logic;                    -- 31.25 MHz differential clock: ACAM ref clock
     -- Signals for the timing interface with the ACAM on TDC mezzanine
     start_from_fpga_o  : out   std_logic;                    -- start signal
     err_flag_i         : in    std_logic;                    -- error flag
     int_flag_i         : in    std_logic;                    -- interrupt flag
     start_dis_o        : out   std_logic;                    -- start disable, not used
     stop_dis_o         : out   std_logic;                    -- stop disable, not used
     -- Signals for the data interface with the ACAM on TDC mezzanine
     data_bus_io        : inout std_logic_vector(27 downto 0);
     address_o          : out   std_logic_vector(3 downto 0);
     cs_n_o             : out   std_logic;                    -- chip select for ACAM
     oe_n_o             : out   std_logic;                    -- output enable for ACAM
     rd_n_o             : out   std_logic;                    -- read  signal for ACAM
     wr_n_o             : out   std_logic;                    -- write signal for ACAM
     ef1_i              : in    std_logic;                    -- empty flag iFIFO1
     ef2_i              : in    std_logic;                    -- empty flag iFIFO2
     -- Signals for the Input Logic on TDC mezzanine
     tdc_in_fpga_1_i    : in    std_logic;                    -- Ch.1 for ACAM, also received by FPGA
     tdc_in_fpga_2_i    : in    std_logic;                    -- Ch.2 for ACAM, also received by FPGA
     tdc_in_fpga_3_i    : in    std_logic;                    -- Ch.3 for ACAM, also received by FPGA
     tdc_in_fpga_4_i    : in    std_logic;                    -- Ch.4 for ACAM, also received by FPGA
     tdc_in_fpga_5_i    : in    std_logic;                    -- Ch.5 for ACAM, also received by FPGA
     -- Signals for the Input Logic on TDC mezzanine
     enable_inputs_o    : out   std_logic;                    -- enables all 5 inputs
     term_en_1_o        : out   std_logic;                    -- Ch.1 termination enable of 50 Ohm termination
     term_en_2_o        : out   std_logic;                    -- Ch.2 termination enable of 50 Ohm termination
     term_en_3_o        : out   std_logic;                    -- Ch.3 termination enable of 50 Ohm termination
     term_en_4_o        : out   std_logic;                    -- Ch.4 termination enable of 50 Ohm termination
     term_en_5_o        : out   std_logic;                    -- Ch.5 termination enable of 50 Ohm termination
     -- LEDs on TDC mezzanine
     tdc_led_status_o   : out   std_logic;                    -- amber led on front pannel, division of 125 MHz tdc_clk
     tdc_led_trig1_o    : out   std_logic;                    -- amber led on front pannel, Ch.1 enable
     tdc_led_trig2_o    : out   std_logic;                    -- amber led on front pannel, Ch.2 enable
     tdc_led_trig3_o    : out   std_logic;                    -- amber led on front pannel, Ch.3 enable
     tdc_led_trig4_o    : out   std_logic;                    -- amber led on front pannel, Ch.4 enable
     tdc_led_trig5_o    : out   std_logic;                    -- amber led on front pannel, Ch.5 enable
     -- Clock from the SPEC carrier
     spec_clk_i         : in    std_logic ;                   -- 20 MHz clock from VCXO on SPEC
     -- Signal for the 1-wire interface (DS18B20 thermometer + unique ID) on SPEC carrier
     carrier_one_wire_b : inout std_logic;
     -- Signals for the I2C EEPROM interface on TDC mezzanine
     sys_scl_b          : inout std_logic;                    -- Mezzanine system I2C clock (EEPROM)
     sys_sda_b          : inout std_logic;                    -- Mezzanine system I2C data (EEPROM)
     -- Signal for the 1-wire interface (DS18B20 thermometer + unique ID) on TDC mezzanine
     mezz_one_wire_b    : inout std_logic;
     -- Carrier other signals
     pcb_ver_i          : in    std_logic_vector(3 downto 0); -- PCB version
     prsnt_m2c_n_i      : in    std_logic;                    -- Mezzanine presence (active low)
     spec_led_green_o   : out   std_logic;                    -- Green LED on SPEC front pannel, PLL status
     spec_led_red_o     : out   std_logic;                    -- Red LED on SPEC front pannel
     spec_aux0_i        : in    std_logic;                    -- Button on SPEC board
     spec_aux1_i        : in    std_logic;                    -- Button on SPEC board
     spec_aux2_o        : out   std_logic;                    -- Red LED on spec board
     spec_aux3_o        : out   std_logic;                    -- Red LED on spec board
     spec_aux4_o        : out   std_logic;                    -- Red LED on spec board
     spec_aux5_o        : out   std_logic);                   -- Red LED on spec board

end top_tdc;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of top_tdc is


  -- SDB header address
  constant c_SDB_ADDRESS : t_wishbone_address := x"00000000";

  -- Constants regarding the SDB crossbar
  -- Slave port on the wishbone crossbar
  constant c_NUM_WB_SLAVES   : integer := 1;
  constant c_MASTER_GENNUM   : integer := 0;
  -- Master ports on the wishbone crossbar
  constant c_NUM_WB_MASTERS  : integer := 6;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  
  constant c_SLAVE_DMA         : integer := 0;  -- DMA controller in the Gennum core
  constant c_SLAVE_SPEC_ONEWIRE: integer := 1;  -- Carrier onewire interface
  constant c_SLAVE_SPEC_CSR    : integer := 2;  -- Info on SPEC control and status registers
  constant c_SLAVE_VIC         : integer := 3;  -- Interrupt controller
  constant c_SLAVE_DMA_EIC     : integer := 4;  -- DMA interrupt controller
  constant c_SLAVE_TDC         : integer := 5;  -- TDC core configuration

  constant c_FMC_TDC_SDB_BRIDGE : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"00001FFF", x"00000000");

  constant c_INTERCONNECT_LAYOUT : t_sdb_record_array(8 downto 0) :=
    (0 => f_sdb_embed_device     (c_DMA_SDB_DEVICE,     x"00001000"),
     1 => f_sdb_embed_device     (c_ONEWIRE_SDB_DEVICE, x"00001100"),
     2 => f_sdb_embed_device     (c_SPEC_CSR_SDB_DEVICE,x"00001200"),
     3 => f_sdb_embed_device     (c_xwb_vic_sdb,        x"00001300"), -- c_xwb_vic_sdb described in the wishbone_pkg
     4 => f_sdb_embed_device     (c_DMA_EIC_SDB,        x"00001400"),
     5 => f_sdb_embed_bridge     (c_FMC_TDC_SDB_BRIDGE, x"00002000"),
     6 => f_sdb_embed_repo_url   (c_SDB_REPO_URL),
     7 => f_sdb_embed_synthesis  (c_SDB_SYNTHESIS),
     8 => f_sdb_embed_integration(c_SDB_INTEGRATION));

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  
  -- VIC default vector setting
  constant c_VIC_VECTOR_TABLE : t_wishbone_address_array(0 to 1) :=
    (0 => x"00003200",
     1 => x"00001400");

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  
  -- clocks and resets
  signal clk, general_rst_n, general_rst, clk_125m                           : std_logic;
  signal clk_20m_vcxo_buf, clk_20m_vcxo, acam_refclk_r_edge_p       : std_logic;
  -- DAC configuration
  signal send_dac_word_p                              : std_logic;
  signal dac_word                                     : std_logic_vector(23 downto 0);
  -- WISHBONE GNUM DMA
  signal dma_stb, dma_cyc, dma_we, dma_ack, dma_stall : std_logic;
  signal dma_sel                                      : std_logic_vector(3 downto 0);
  signal dma_adr, dma_dat_rd, dma_dat_wr              : std_logic_vector(31 downto 0);
  -- WISHBONE from crossbar master port
  signal cnx_master_out                               : t_wishbone_master_out_array(c_NUM_WB_MASTERS-1 downto 0);
  signal cnx_master_in                                : t_wishbone_master_in_array(c_NUM_WB_MASTERS-1 downto 0);
  -- WISHBONE to crossbar slave port
  signal cnx_slave_out                                : t_wishbone_slave_out_array(c_NUM_WB_SLAVES-1 downto 0);
  signal cnx_slave_in                                 : t_wishbone_slave_in_array(c_NUM_WB_SLAVES-1 downto 0);
  -- WISHBONE addresses
  signal dma_ctrl_wb_adr, tdc_core_wb_adr, gn_wb_adr  : std_logic_vector(31 downto 0);
  -- Interrupts
  signal irq_to_gn4124                                : std_logic;  
  signal irq_acam_err_p, irq_tstamp_p, irq_time_p     : std_logic;  
  signal dma_irq                                      : std_logic_vector(1 downto 0); 
  signal irq_sources                                  : std_logic_vector(g_width-1 downto 0);
  -- Carrier CSR info
  signal gn4124_status                                : std_logic_vector(31 downto 0);
  signal mezz_pll_status                              : std_logic_vector(11 downto 0);
  -- Mezzanine 1-wire
  signal mezz_owr_pwren, mezz_owr_en, mezz_owr_i      : std_logic_vector(c_FMC_ONE_WIRE_NB - 1 downto 0);
  -- Carrier 1-wire
  signal carrier_owr_en, carrier_owr_i                : std_logic_vector(c_FMC_ONE_WIRE_NB - 1 downto 0);
  -- Mezzanine system I2C for EEPROM
  signal sys_scl_in, sys_scl_out, sys_scl_oe_n        : std_logic;
  signal sys_sda_in, sys_sda_out, sys_sda_oe_n        : std_logic;

  signal led_clk_20m_divider                 : unsigned(22 downto 0);
  signal led_clk_20m_aux                     : std_logic_vector(7 downto 0) :="01111111";
  signal led_clk_20m                         : std_logic;
  signal led_clk_125m_divider                 : unsigned(22 downto 0);
  signal led_clk_125m_aux                     : std_logic_vector(7 downto 0):="01111111";
  signal led_clk_125m                         : std_logic;
  signal led_clk_125m2_divider                 : unsigned(22 downto 0);
  signal led_clk_125m2_aux                     : std_logic_vector(7 downto 0);
  signal led_clk_125m2                         : std_logic;
  signal dma_eic_irq, fmc_eic_irq           : std_logic;


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin


---------------------------------------------------------------------------------------------------
--                                        TDC 125MHz clk                                         --
---------------------------------------------------------------------------------------------------

  irq_aux_p_o <= '0';

  svec_clk_ibuf : IBUFG
  port map
  (I => spec_clk_i,
   O => clk_20m_vcxo_buf);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  cmp_tdc_clks_rsts_mgment : clks_rsts_manager
  generic map
    (nb_of_reg                 => 68)
  port map
    (clk_20m_vcxo_i            => clk_20m_vcxo_buf,
     acam_refclk_p_i           => acam_refclk_p_i,
     acam_refclk_n_i           => acam_refclk_n_i,
     tdc_125m_clk_p_i          => tdc_clk_p_i,
     tdc_125m_clk_n_i          => tdc_clk_n_i,
     rst_n_i                   => rst_n_a_i,
     pll_sdo_i                 => pll_sdo_i,
     pll_status_i              => pll_status_i,
     send_dac_word_p_i         => send_dac_word_p,
     dac_word_i                => dac_word,
     acam_refclk_r_edge_p_o    => acam_refclk_r_edge_p,
     internal_rst_o            => general_rst,
     pll_cs_n_o                => pll_cs_o,
     pll_dac_sync_n_o          => pll_dac_sync_o,
     pll_sdi_o                 => pll_sdi_o,
     pll_sclk_o                => pll_sclk_o,
     tdc_125m_clk_o            => clk_125m,
     pll_status_o              => open);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  general_rst_n               <= not general_rst;



---------------------------------------------------------------------------------------------------
--                                     CSR WISHBONE CROSSBAR                                     --
---------------------------------------------------------------------------------------------------
--   0x00000 -> SDB
--   0x01000 -> DMA configuration
--   0x01100 -> Carrier 1-wire master
--   0x01200 -> Carrier CSR information
--   0x01300 -> Vector Interrupt Controller
--   0x01400 -> DMA Embedded Interrupt Controller
--   0x02000 -> TDC mezzanine SDB
--     0x03000 -> TDC Mezzanine configuration (including ACAM regs)
--     0x03100 -> TDC Mezzanine 1-wire master
--     0x03200 -> TDC Mezzanine Embedded Interrupt Controller
--     0x03300 -> TDC Mezzanine I2C master
  cmp_sdb_crossbar : xwb_sdb_crossbar
  generic map
    (g_num_masters => c_NUM_WB_SLAVES,
     g_num_slaves  => c_NUM_WB_MASTERS,
     g_registered  => true,
     g_wraparound  => true,
     g_layout      => c_INTERCONNECT_LAYOUT,
     g_sdb_addr    => c_SDB_ADDRESS)
  port map
    (clk_sys_i     => clk_125m,
     rst_n_i       => rst_n_a_i,
     slave_i       => cnx_slave_in,
     slave_o       => cnx_slave_out,
     master_i      => cnx_master_in,
     master_o      => cnx_master_out);



---------------------------------------------------------------------------------------------------
--                                           GNUM CORE                                           --
---------------------------------------------------------------------------------------------------
  gnum_interface_block: gn4124_core
  port map
    (rst_n_a_i       => rst_n_a_i,
	 status_o        => gn4124_status,
    -- P2L Direction Source Sync DDR related signals
     p2l_clk_p_i     => p2l_clk_p_i,
     p2l_clk_n_i     => p2l_clk_n_i,
     p2l_data_i      => p2l_data_i,
     p2l_dframe_i    => p2l_dframe_i,
     p2l_valid_i     => p2l_valid_i,
    -- P2L Control
     p2l_rdy_o       => p2l_rdy_o,
     p_wr_req_i      => p_wr_req_i,
     p_wr_rdy_o      => p_wr_rdy_o,
     rx_error_o      => rx_error_o,
    -- L2P Direction Source Sync DDR related signals
     l2p_clk_p_o     => l2p_clk_p_o,
     l2p_clk_n_o     => l2p_clk_n_o,
     l2p_data_o      => l2p_data_o ,
     l2p_dframe_o    => l2p_dframe_o,
     l2p_valid_o     => l2p_valid_o,
     l2p_edb_o       => l2p_edb_o,
    -- L2P Control
     l2p_rdy_i       => l2p_rdy_i,
     l_wr_rdy_i      => l_wr_rdy_i,
     p_rd_d_rdy_i    => p_rd_d_rdy_i,
     tx_error_i      => tx_error_i,
     vc_rdy_i        => vc_rdy_i,
    -- Interrupt interface
     dma_irq_o       => dma_irq,
     irq_p_i         => irq_to_gn4124,
     irq_p_o         => irq_p_o,
    -- CSR WISHBONE interface (master pipelined)
     csr_clk_i       => clk_125m,
     csr_adr_o       => gn_wb_adr,
     csr_dat_o       => cnx_slave_in(c_MASTER_GENNUM).dat,
     csr_sel_o       => cnx_slave_in(c_MASTER_GENNUM).sel,
     csr_stb_o       => cnx_slave_in(c_MASTER_GENNUM).stb,
     csr_we_o        => cnx_slave_in(c_MASTER_GENNUM).we,
     csr_cyc_o       => cnx_slave_in(c_MASTER_GENNUM).cyc,
     csr_dat_i       => cnx_slave_out(c_MASTER_GENNUM).dat,
     csr_ack_i       => cnx_slave_out(c_MASTER_GENNUM).ack,
     csr_stall_i     => cnx_slave_out(c_MASTER_GENNUM).stall,
    -- DMA WISHBONE interface (pipelined)
     dma_clk_i       => clk_125m,
     dma_adr_o       => dma_adr,
     dma_cyc_o       => dma_cyc,
     dma_dat_o       => dma_dat_wr,
     dma_sel_o       => dma_sel,
     dma_stb_o       => dma_stb,
     dma_we_o        => dma_we,
     dma_ack_i       => dma_ack,
     dma_dat_i       => dma_dat_rd,
     dma_stall_i     => dma_stall,
    -- DMA registers WISHBONE interface (slave classic)
     dma_reg_clk_i   => clk_125m,
     dma_reg_adr_i   => dma_ctrl_wb_adr,
     dma_reg_dat_i   => cnx_master_out(c_SLAVE_DMA).dat,
     dma_reg_sel_i   => cnx_master_out(c_SLAVE_DMA).sel,
     dma_reg_stb_i   => cnx_master_out(c_SLAVE_DMA).stb,
     dma_reg_we_i    => cnx_master_out(c_SLAVE_DMA).we,
     dma_reg_cyc_i   => cnx_master_out(c_SLAVE_DMA).cyc,
     dma_reg_dat_o   => cnx_master_in(c_SLAVE_DMA).dat,
     dma_reg_ack_o   => cnx_master_in(c_SLAVE_DMA).ack,
     dma_reg_stall_o => cnx_master_in(c_SLAVE_DMA).stall);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Convert 32-bit word address into byte address for crossbar
  cnx_slave_in(c_MASTER_GENNUM).adr <= gn_wb_adr(29 downto 0) & "00";

  -- Convert 32-bit byte address into word address for DMA controller
  dma_ctrl_wb_adr <= "00" & cnx_master_out(c_SLAVE_DMA).adr(31 downto 2);

  -- Unused wishbone signals
  cnx_master_in(c_SLAVE_DMA).err <= '0';
  cnx_master_in(c_SLAVE_DMA).rty <= '0';
  cnx_master_in(c_SLAVE_DMA).int <= '0';

---------------------------------------------------------------------------------------------------
--                                         GN4124 DMA EIC                                        --
  cmp_dma_eic : dma_eic
  port map
    (rst_n_i         => general_rst_n,
     clk_sys_i       => clk_125m,
     wb_adr_i        => cnx_master_out(c_SLAVE_DMA_EIC).adr(3 downto 2),  -- cnx_master_out.adr is byte address
     wb_dat_i        => cnx_master_out(c_SLAVE_DMA_EIC).dat,
     wb_dat_o        => cnx_master_in(c_SLAVE_DMA_EIC).dat,
     wb_cyc_i        => cnx_master_out(c_SLAVE_DMA_EIC).cyc,
     wb_sel_i        => cnx_master_out(c_SLAVE_DMA_EIC).sel,
     wb_stb_i        => cnx_master_out(c_SLAVE_DMA_EIC).stb,
     wb_we_i         => cnx_master_out(c_SLAVE_DMA_EIC).we,
     wb_ack_o        => cnx_master_in(c_SLAVE_DMA_EIC).ack,
     wb_stall_o      => cnx_master_in(c_SLAVE_DMA_EIC).stall,
     wb_int_o        => dma_eic_irq,
     irq_dma_done_i  => dma_irq(0),
     irq_dma_error_i => dma_irq(1));

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused wishbone signals
  cnx_master_in(c_SLAVE_DMA_EIC).err <= '0';
  cnx_master_in(c_SLAVE_DMA_EIC).rty <= '0';
  cnx_master_in(c_SLAVE_DMA_EIC).int <= '0';


---------------------------------------------------------------------------------------------------
--                                            TDC BOARD                                          --
---------------------------------------------------------------------------------------------------

  cmp_tdc : fmc_tdc_mezzanine
  generic map
    (g_span                  => g_span,
     g_width                 => g_width,
     values_for_simul        => FALSE)
  port map
    (-- clocks, resets, dac
     clk_125m_i             => clk_125m,
     rst_i                  => general_rst,
     acam_refclk_r_edge_p_i => acam_refclk_r_edge_p,
     send_dac_word_p_o      => send_dac_word_p,
     dac_word_o             => dac_word,
     -- ACAM
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
     -- Input channels to FPGA (not used)
     tdc_in_fpga_1_i        => tdc_in_fpga_1_i,
     tdc_in_fpga_2_i        => tdc_in_fpga_2_i,
     tdc_in_fpga_3_i        => tdc_in_fpga_3_i,
     tdc_in_fpga_4_i        => tdc_in_fpga_4_i,
     tdc_in_fpga_5_i        => tdc_in_fpga_5_i,
     -- LEDs and buttons on TDC and SPEC
     tdc_led_status_o       => tdc_led_status_o,
     tdc_led_trig1_o        => open,--tdc_led_trig1_o,
     tdc_led_trig2_o        => tdc_led_trig2_o,
     tdc_led_trig3_o        => tdc_led_trig3_o,
     tdc_led_trig4_o        => tdc_led_trig4_o,
     tdc_led_trig5_o        => open,--tdc_led_trig5_o,
     -- WISHBONE interface with the GNUM/VME_core
     wb_tdc_csr_adr_i       => cnx_master_out(c_SLAVE_TDC).adr,
     wb_tdc_csr_dat_i       => cnx_master_out(c_SLAVE_TDC).dat,
     wb_tdc_csr_stb_i       => cnx_master_out(c_SLAVE_TDC).stb,
     wb_tdc_csr_we_i        => cnx_master_out(c_SLAVE_TDC).we,
     wb_tdc_csr_cyc_i       => cnx_master_out(c_SLAVE_TDC).cyc,
     wb_tdc_csr_sel_i       => cnx_master_out(c_SLAVE_TDC).sel,
     wb_tdc_csr_dat_o       => cnx_master_in(c_SLAVE_TDC).dat,
     wb_tdc_csr_ack_o       => cnx_master_in(c_SLAVE_TDC).ack,
     wb_tdc_csr_stall_o     => cnx_master_in(c_SLAVE_TDC).stall,
     -- Interrupts
     wb_irq_o               => fmc_eic_irq,
     -- WISHBONE interface with the GNUM DMA/VME_core
     -- for the retreival of the timestamps
     wb_tdc_mem_adr_i       => dma_adr,
     wb_tdc_mem_dat_i       => dma_dat_wr,
     wb_tdc_mem_cyc_i       => dma_cyc,
     wb_tdc_mem_stb_i       => dma_stb,
     wb_tdc_mem_we_i        => dma_we,
     wb_tdc_mem_dat_o       => dma_dat_rd,
     wb_tdc_mem_ack_o       => dma_ack,
     wb_tdc_mem_stall_o     => dma_stall,
     -- Interrupt pulses, for debug
     irq_tstamp_p_o         => irq_tstamp_p,
     irq_time_p_o           => irq_time_p,
     irq_acam_err_p_o       => irq_acam_err_p,
     -- TDC board EEPROM I2C EEPROM interface
     sys_scl_b              => sys_scl_b,
     sys_sda_b              => sys_sda_b,
     -- 1-wire UniqueID&Thermometer interface
     one_wire_b             => mezz_one_wire_b);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Convert byte address into word address
  tdc_core_wb_adr <= "00" & cnx_master_out(c_SLAVE_TDC).adr(31 downto 2);

  -- Unused wishbone signals
  cnx_master_in(c_SLAVE_TDC).err   <= '0';
  cnx_master_in(c_SLAVE_TDC).rty   <= '0';
  cnx_master_in(c_SLAVE_TDC).int   <= '0';



---------------------------------------------------------------------------------------------------
--                                              VIC                                              --
---------------------------------------------------------------------------------------------------
  cmp_vic : xwb_vic
  generic map
    (g_interface_mode      => PIPELINED,
     g_address_granularity => BYTE,
     g_num_interrupts      => 2,
     g_init_vectors        => c_VIC_VECTOR_TABLE)
  port map 
    (clk_sys_i    => clk_125m,
     rst_n_i      => general_rst_n,
     slave_i      => cnx_master_out(c_SLAVE_VIC),
     slave_o      => cnx_master_in(c_SLAVE_VIC),
     irqs_i(0)    => fmc_eic_irq,
     irqs_i(1)    => dma_eic_irq,
     irq_master_o => irq_to_gn4124);


  tdc_led_trig1_o <= irq_tstamp_p;
  tdc_led_trig5_o <= irq_to_gn4124;




---------------------------------------------------------------------------------------------------
--                    Carrier 1-wire MASTER DS18B20 (thermometer + unique ID)                    --
---------------------------------------------------------------------------------------------------
  cmp_carrier_onewire : xwb_onewire_master
  generic map
    (g_interface_mode      => CLASSIC,
     g_address_granularity => BYTE,
     g_num_ports           => 1,
     g_ow_btp_normal       => "5.0",
     g_ow_btp_overdrive    => "1.0")
  port map
    (clk_sys_i   => clk_125m,
     rst_n_i     => general_rst_n,
     slave_i     => cnx_master_out(c_SLAVE_SPEC_ONEWIRE),
     slave_o     => cnx_master_in(c_SLAVE_SPEC_ONEWIRE),
     desc_o      => open,
     owr_pwren_o => open,
     owr_en_o    => carrier_owr_en,
     owr_i       => carrier_owr_i);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  carrier_one_wire_b <= '0' when carrier_owr_en(0) = '1' else 'Z';
  carrier_owr_i(0)   <= carrier_one_wire_b;



---------------------------------------------------------------------------------------------------
--                                    Carrier CSR information                                    --
---------------------------------------------------------------------------------------------------
-- Information on carrier type, mezzanine presence, pcb version

  cmp_carrier_csr : carrier_csr
  port map
    (rst_n_i                          => general_rst_n,
     wb_clk_i                         => clk_125m,
     wb_addr_i                        => cnx_master_out(c_SLAVE_SPEC_CSR).adr(3 downto 2),
     wb_data_i                        => cnx_master_out(c_SLAVE_SPEC_CSR).dat,
     wb_data_o                        => cnx_master_in(c_SLAVE_SPEC_CSR).dat,
     wb_cyc_i                         => cnx_master_out(c_SLAVE_SPEC_CSR).cyc,
     wb_sel_i                         => cnx_master_out(c_SLAVE_SPEC_CSR).sel,
     wb_stb_i                         => cnx_master_out(c_SLAVE_SPEC_CSR).stb,
     wb_we_i                          => cnx_master_out(c_SLAVE_SPEC_CSR).we,
     wb_ack_o                         => cnx_master_in(c_SLAVE_SPEC_CSR).ack,
     carrier_csr_carrier_pcb_rev_i    => pcb_ver_i,
     carrier_csr_carrier_reserved_i   => (others => '0'),
     carrier_csr_carrier_type_i       => c_CARRIER_TYPE,
     carrier_csr_stat_fmc_pres_i      => prsnt_m2c_n_i,
     carrier_csr_stat_p2l_pll_lck_i   => gn4124_status(0),
     carrier_csr_stat_sys_pll_lck_i   => '0',
     carrier_csr_stat_ddr3_cal_done_i => '0',
     carrier_csr_stat_reserved_i      => (others => '0'),
     carrier_csr_ctrl_led_green_o     => open,
     carrier_csr_ctrl_led_red_o       => open,
     carrier_csr_ctrl_dac_clr_n_o     => open,
     carrier_csr_ctrl_reserved_o      => open);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused wishbone signals
  cnx_master_in(c_SLAVE_SPEC_CSR).err   <= '0';
  cnx_master_in(c_SLAVE_SPEC_CSR).rty   <= '0';
  cnx_master_in(c_SLAVE_SPEC_CSR).stall <= '0';
  cnx_master_in(c_SLAVE_SPEC_CSR).int   <= '0';


   
end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------