----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : TDC top level (top_tdc.vhd)
--  author      : G. Penacoba
--  date        : May 2011
--  version     : Revision 1
--  description : top level of tdc project
--  dependencies:
--  references  :
--  modified by :
--
----------------------------------------------------------------------------------------------------
--  last changes:
-- revamping, comments, renamings etc
-- new gnum core integrated
-- clks_rsts_mnger modified
----------------------------------------------------------------------------------------------------
--  to do:
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tdc_core_pkg.all;
use work.gn4124_core_pkg.all;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;

----------------------------------------------------------------------------------------------------
--  entity declaration for top_tdc
----------------------------------------------------------------------------------------------------
entity top_tdc is
  generic
    (g_span                  : integer :=32;                     -- address span in bus interfaces
     g_width                 : integer :=32;                     -- data width in bus interfaces
     values_for_simulation   : boolean :=FALSE);                   -- this generic is set to TRUE
                                                                  -- when instantiated in a test-bench
  port
    (-- interface with GNUM
     rst_n_a_i               : in  std_logic;
     -- P2L Direction
     p2l_clk_p_i             : in  std_logic;                    -- Receiver Source Synchronous Clock+
     p2l_clk_n_i             : in  std_logic;                    -- Receiver Source Synchronous Clock-
     p2l_data_i              : in  std_logic_vector(15 downto 0);-- Parallel receive data
     p2l_dframe_i            : in  std_logic;                    -- Receive Frame
     p2l_valid_i             : in  std_logic;                    -- Receive Data Valid
     p2l_rdy_o               : out std_logic;                    -- Rx Buffer Full Flag
     p_wr_req_i              : in  std_logic_vector(1 downto 0); -- PCIe Write Request
     p_wr_rdy_o              : out std_logic_vector(1 downto 0); -- PCIe Write Ready
     rx_error_o              : out std_logic;                    -- Receive Error
     vc_rdy_i                : in  std_logic_vector(1 downto 0); -- Virtual channel ready
     -- L2P Direction
     l2p_clk_p_o             : out std_logic;                    -- Transmitter Source Synchronous Clock+
     l2p_clk_n_o             : out std_logic;                    -- Transmitter Source Synchronous Clock-
     l2p_data_o              : out std_logic_vector(15 downto 0);-- Parallel transmit data
     l2p_dframe_o            : out std_logic;                    -- Transmit Data Frame
     l2p_valid_o             : out std_logic;                    -- Transmit Data Valid
     l2p_edb_o               : out std_logic;                    -- Packet termination and discard
     l2p_rdy_i               : in  std_logic;                    -- Tx Buffer Full Flag
     l_wr_rdy_i              : in  std_logic_vector(1 downto 0); -- Local-to-PCIe Write
     p_rd_d_rdy_i            : in  std_logic_vector(1 downto 0); -- PCIe-to-Local Read Response Data Ready
     tx_error_i              : in  std_logic;                    -- Transmit Error
     irq_p_o                 : out std_logic;                    -- Interrupt request pulse to GN4124 GPIO
     spare_o                 : out std_logic;

     -- interface signals with PLL circuit on TDC mezzanine
     acam_refclk_i           : in std_logic;                     -- 31.25 MHz clock that is also received by ACAM
     pll_ld_i                : in std_logic;                     -- PLL AD9516 interface signals
     pll_refmon_i            : in std_logic;                     --
     pll_sdo_i               : in std_logic;                     --
     pll_status_i            : in std_logic;                     --
     tdc_clk_p_i             : in std_logic;                     -- 125 MHz differential clock : system clock
     tdc_clk_n_i             : in std_logic;                     --

     pll_cs_o                : out std_logic;                     -- PLL AD9516 interface signals
     pll_dac_sync_o          : out std_logic;                     --
     pll_sdi_o               : out std_logic;                     --
     pll_sclk_o              : out std_logic;                     --
     -- interface signals with acam (timing) on TDC mezzanine
     err_flag_i              : in std_logic;                     -- error flag   signal coming from ACAM
     int_flag_i              : in std_logic;                     -- interrupt flag   signal coming from ACAM
     start_dis_o             : out std_logic;                    -- start disable   signal for ACAM
     start_from_fpga_o       : out std_logic;                    -- start   signal for ACAM
     stop_dis_o              : out std_logic;                    -- stop disable   signal for ACAM
     -- interface signals with acam (data) on TDC mezzanine
     data_bus_io             : inout std_logic_vector(27 downto 0);
     ef1_i                   : in std_logic;                     -- empty flag iFIFO1   signal from ACAM
     ef2_i                   : in std_logic;                     -- empty flag iFIFO2   signal from ACAM
     lf1_i                   : in std_logic;                     -- load flag iFIFO1   signal from ACAM
     lf2_i                   : in std_logic;                     -- load flag iFIFO2   signal from ACAM

     address_o               : out std_logic_vector(3 downto 0);
     cs_n_o                  : out std_logic;                    -- chip select for ACAM
     oe_n_o                  : out std_logic;                    -- output enable for ACAM
     rd_n_o                  : out std_logic;                    -- read   signal for ACAM
     wr_n_o                  : out std_logic;                    -- write   signal for ACAM

     -- other signals on the TDC mezzanine
     tdc_in_fpga_5_i         : in std_logic;                     -- input 5 for ACAM is also received by FPGA
                                                                 -- all 4 other stop inputs are miss-routed on PCB 
     mute_inputs_o           : out std_logic;                    -- controls all 5 inputs (actual function: ENABLE)
     tdc_led_status_o        : out std_logic;                    -- amber led on front pannel
     tdc_led_trig1_o         : out std_logic;                    -- amber leds on front pannel
     tdc_led_trig2_o         : out std_logic;                    --
     tdc_led_trig3_o         : out std_logic;                    --
     tdc_led_trig4_o         : out std_logic;                    --
     tdc_led_trig5_o         : out std_logic;                    --
     term_en_1_o             : out std_logic;                    -- enable of 50 Ohm termination inputs
     term_en_2_o             : out std_logic;                    --
     term_en_3_o             : out std_logic;                    --
     term_en_4_o             : out std_logic;                    --
     term_en_5_o             : out std_logic;                    --

    -- Carrier 1-wire interface (DS18B20 thermometer + unique ID)
     carrier_one_wire_b      : inout std_logic;

    -- Mezzanine system I2C EEPROM
     sys_scl_b               : inout std_logic;                  -- Mezzanine system I2C clock (EEPROM)
     sys_sda_b               : inout std_logic;                  -- Mezzanine system I2C data (EEPROM)

    -- Mezzanine 1-wire interface (DS18B20 thermometer + unique ID)
     mezz_one_wire_b         : inout std_logic;

     -- other signals on the SPEC carrier
     spec_aux0_i             : in std_logic;                     -- buttons on spec card
     spec_aux1_i             : in std_logic;                     --
     spec_aux2_o             : out std_logic;                    -- red leds on spec PCB
     spec_aux3_o             : out std_logic;                    --
     spec_aux4_o             : out std_logic;                    --
     spec_aux5_o             : out std_logic;                    --
     spec_led_green_o        : out std_logic;                    -- green led on spec front pannel
     spec_led_red_o          : out std_logic;                    -- red led on spec front pannel
     spec_clk_i              : in std_logic);                    -- 20 MHz clock from VCXO on spec card

end top_tdc;

----------------------------------------------------------------------------------------------------
--  architecture declaration for top_tdc
----------------------------------------------------------------------------------------------------
architecture rtl of top_tdc is



  signal clk, spec_clk : std_logic;

-- LEDs
  signal spec_led_blink_done, spec_led_period_done, tdc_led_blink_done      : std_logic;
  signal spec_led_period          : std_logic_vector(g_width-1 downto 0);
  signal visible_blink_length                                               : std_logic_vector(g_width-1 downto 0);
  signal spec_led_green, spec_led_red, tdc_led_status                       : std_logic;

  signal pulse_delay, window_delay, clk_period : std_logic_vector(g_width-1 downto 0);

  signal gnum_rst, gnum_rst_synch               : std_logic;



  signal acam_ef1, acam_ef2, acam_ef1_meta, acam_ef2_meta                 : std_logic;

  signal acam_errflag_f_edge_p, acam_errflag_r_edge_p, acam_intflag_f_edge_p, acam_refclk_r_edge_p  : std_logic;

  signal acam_tstamp1, acam_tstamp2          : std_logic_vector(g_width-1 downto 0);
  signal acam_tstamp1_ok_p, acam_tstamp2_ok_p    : std_logic;

  signal clk_i_cycles_offset, current_roll_over, retrig_nb_offset : std_logic_vector(g_width-1 downto 0);
  signal general_rst, general_rst_n            : std_logic;
  signal one_hz_p               : std_logic;

  signal acm_adr                  : std_logic_vector(7 downto 0);
  signal acm_cyc, acm_stb, acm_we, acm_ack                  : std_logic;
  signal acm_dat_r, acm_dat_w                : std_logic_vector(g_width-1 downto 0);

  signal dma_irq                  : std_logic_vector(1 downto 0); 
  signal irq_to_gn4124                    : std_logic;                    


  signal wbm_csr_sel                  : std_logic_vector(3 downto 0);
  signal wbm_csr_stb, wbm_csr_we                  : std_logic;


  signal wbm_csr_dat_wr, wbm_csr_dat_rd, dma_dat_rd, dma_dat_wr : std_logic_vector(31 downto 0);


  signal dma_stb, dma_cyc, dma_we, dma_ack, dma_stall : std_logic;
  signal dma_adr                  : std_logic_vector(31 downto 0);
  signal dma_sel                  : std_logic_vector(3 downto 0);


  signal mem_class_adr            : std_logic_vector(7 downto 0);
  signal mem_class_stb, mem_class_cyc, mem_class_we, mem_class_ack : std_logic;
  signal mem_class_data_wr, mem_class_data_rd        : std_logic_vector(4*g_width-1 downto 0);

  signal wb_csr_adr_decoded                  : std_logic_vector(g_span-1 downto 0);
  signal wb_csr_dat_wr_decoded              : std_logic_vector(g_width-1 downto 0);
  signal wb_csr_stb_decoded                  : std_logic;
  signal wb_csr_we_decoded                   : std_logic;


  signal activate_acq_p, deactivate_acq_p, load_acam_config, read_acam_config     : std_logic;
  signal read_acam_status, read_ififo1, read_ififo2, read_start01, reset_acam : std_logic;
  signal load_utc, clear_dacapo_counter                 : std_logic;

  signal starting_utc             : std_logic_vector(g_width-1 downto 0);
  signal acam_inputs_en, irq_tstamp_threshold, irq_time_threshold               : std_logic_vector(g_width-1 downto 0);
  signal acam_config              : config_vector;
  signal acam_config_rdbk         : config_vector;
  signal acam_status, acam_ififo1, acam_ififo2, acam_start01 : std_logic_vector(g_width-1 downto 0);

  signal local_utc, irq_code, wr_index, core_status          : std_logic_vector(g_width-1 downto 0);
  signal irq_sources       : std_logic_vector(g_width-1 downto 0);


  signal wb_csr_cyc_decoded, wb_all_csr_ack, wb_all_csr_stall : std_logic_vector(c_CSR_WB_SLAVES_NB-1 downto 0);
  signal wb_all_csr_dat_rd : std_logic_vector((32*c_CSR_WB_SLAVES_NB)-1 downto 0);

  signal wb_csr_sel_decoded : std_logic_vector (3 downto 0);

  signal wbm_csr_adr              : std_logic_vector (31 downto 0);
  signal wbm_csr_cyc, wbm_csr_ack_decoded, wbm_stall : std_logic;

  -- Mezzanine 1-wire
  signal mezz_owr_pwren : std_logic_vector(c_FMC_ONE_WIRE_NB - 1 downto 0);
  signal mezz_owr_en    : std_logic_vector(c_FMC_ONE_WIRE_NB - 1 downto 0);
  signal mezz_owr_i     : std_logic_vector(c_FMC_ONE_WIRE_NB - 1 downto 0);

  -- Carrier 1-wire
  signal carrier_owr_en    : std_logic_vector(c_FMC_ONE_WIRE_NB - 1 downto 0);
  signal carrier_owr_i     : std_logic_vector(c_FMC_ONE_WIRE_NB - 1 downto 0);

  -- Mezzanine system I2C for EEPROM
  signal sys_scl_in, sys_scl_out, sys_scl_oe_n  : std_logic;
  signal sys_sda_in, sys_sda_out, sys_sda_oe_n  : std_logic;

  signal tstamp_wr_p, irq_tstamp_p, irq_time_p               : std_logic;

-- <acam_status_i<31:0>> is never used.
-- <adr_i<7:4>> is never used.
-- <dat_i<31:28>> is never used.
-- <tstamp_wr_dat_i<127:0>> is never used.
-- <acam_tstamp1_i<30:30>> is never used.
-- <acam_tstamp1_i<28:28>> is never used.
-- <acam_tstamp2_i<31:31>> is never used.
-- <acam_tstamp2_i<29:29>> is never used.
-- <gnum_dma_adr_i<31:10>> is never used. 
-- <wbm_adr_i<31:18> never used
-- gnum_csr_adr_i<31:8> is never used

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin
 
---------------------------------------------------------------------------------------------------
--                                        WISHBONE CSR DECODER                                   --
---------------------------------------------------------------------------------------------------
-- CSR wishbone address decoder
--   0x00000 -> DMA configuration
--   0x20000 -> TDC core & ACAM
--   0x40000 -> Carrier 1-wire master   (Unidue ID & Thermometer)
--   0x60000 -> Mezzanine I2C master    (EEPROM)
--   0x80000 -> Mezzanine 1-wire master (Unidue ID & Thermometer)
--   0xA0000 -> Interrupt controller

  address_decoder:wb_addr_decoder
  generic map
    (g_WINDOW_SIZE  => c_BAR0_APERTURE,    -- note: c_BAR0_APERTURE    = 18
     g_WB_SLAVES_NB => c_CSR_WB_SLAVES_NB) -- note: c_CSR_WB_SLAVES_NB = 5
  port map
    (clk_i       => clk,
     rst_n_i     => rst_n_a_i,
     -- WISHBONE master interface
     wbm_adr_i   => wbm_csr_adr,
     wbm_dat_i   => wbm_csr_dat_wr,
     wbm_sel_i   => wbm_csr_sel,
     wbm_stb_i   => wbm_csr_stb,
     wbm_we_i    => wbm_csr_we,
     wbm_cyc_i   => wbm_csr_cyc,
     wbm_ack_o   => wbm_csr_ack_decoded,
     wbm_dat_o   => wbm_csr_dat_rd,
     wbm_stall_o => wbm_stall,
     -- WISHBONE slaves interface
     wb_dat_i    => wb_all_csr_dat_rd,
     wb_ack_i    => wb_all_csr_ack,
     wb_stall_i  => wb_all_csr_stall,
     wb_cyc_o    => wb_csr_cyc_decoded,
     wb_stb_o    => wb_csr_stb_decoded,
     wb_we_o     => wb_csr_we_decoded,
     wb_sel_o    => wb_csr_sel_decoded, -- Byte select???
     wb_adr_o    => wb_csr_adr_decoded,
     wb_dat_o    => wb_csr_dat_wr_decoded);


---------------------------------------------------------------------------------------------------
--                                     INTERRUPTS CONTROLLER                                     --
---------------------------------------------------------------------------------------------------
  cmp_irq_controller : irq_controller
    port map
      (clk_i       => clk,
       rst_n_i     => general_rst_n,
       irq_src_p_i => irq_sources,
       irq_p_o     => irq_to_gn4124,
       wb_adr_i    => wb_csr_adr_decoded(1 downto 0),
       wb_dat_i    => wb_csr_dat_wr_decoded,
       wb_dat_o    => wb_all_csr_dat_rd(c_CSR_WB_IRQ_CTRL * 32 + 31 downto c_CSR_WB_IRQ_CTRL * 32),
       wb_cyc_i    => wb_csr_cyc_decoded(c_CSR_WB_IRQ_CTRL),
       wb_sel_i    => wb_csr_sel_decoded,
       wb_stb_i    => wb_csr_stb_decoded,
       wb_we_i     => wb_csr_we_decoded,
       wb_ack_o    => wb_all_csr_ack(c_CSR_WB_IRQ_CTRL));

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- IRQ sources
  irq_sources(1 downto 0)  <= dma_irq;
  irq_sources(2)           <= irq_tstamp_p;
  irq_sources(3)           <= irq_time_p;
  irq_sources(31 downto 4) <= (others => '0');

  -- Classic slave supporting single pipelined accesses, stall isn't used
  wb_all_csr_stall(c_CSR_WB_IRQ_CTRL) <= '0';


---------------------------------------------------------------------------------------------------
--                    CARRIER 1-wire MASTER DS18B20 (thermometer + unique ID)                    --
---------------------------------------------------------------------------------------------------
-- Note: c_CSR_WB_CARRIER_ONE_WIRE = 2
  carrier_OneWire : wb_onewire_master
  generic map
    (g_num_ports        => 1,
     g_ow_btp_normal    => "5.0",
     g_ow_btp_overdrive => "1.0")
  port map
    (clk_sys_i   => clk,
     rst_n_i     => general_rst_n,
     wb_adr_i    => wb_csr_adr_decoded(2 downto 0),
     wb_dat_i    => wb_csr_dat_wr_decoded,
     wb_cyc_i    => wb_csr_cyc_decoded(c_CSR_WB_CARRIER_ONE_WIRE),
     wb_sel_i    => wb_csr_sel_decoded,
     wb_stb_i    => wb_csr_stb_decoded,
     wb_we_i     => wb_csr_we_decoded,

     wb_dat_o    => wb_all_csr_dat_rd(c_CSR_WB_CARRIER_ONE_WIRE * 32 + 31 downto 32 * c_CSR_WB_CARRIER_ONE_WIRE),
     wb_ack_o    => wb_all_csr_ack(c_CSR_WB_CARRIER_ONE_WIRE),
     wb_int_o    => open,
     owr_pwren_o => open,
     owr_en_o    => carrier_owr_en,
     owr_i       => carrier_owr_i);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  carrier_one_wire_b <= '0' when carrier_owr_en(0) = '1' else 'Z';
  carrier_owr_i(0)   <= carrier_one_wire_b;

  -- Classic slave supporting single pipelined accesses, stall isn't used
  wb_all_csr_stall(c_CSR_WB_CARRIER_ONE_WIRE) <= '0';


---------------------------------------------------------------------------------------------------
--                     Mezzanine System managment I2C Master, EEPROM access                      --
---------------------------------------------------------------------------------------------------
-- Note: c_CSR_WB_FMC_SYS_I2C = 3
  mezzanine_I2C_master_EEPROM : wb_i2c_master
  port map
    (clk_sys_i    => clk,
     rst_n_i      => general_rst_n,
     wb_adr_i     => wb_csr_adr_decoded(4 downto 0),
     wb_dat_i     => wb_csr_dat_wr_decoded,
     wb_we_i      => wb_csr_we_decoded,
     wb_stb_i     => wb_csr_stb_decoded,
     wb_sel_i     => wb_csr_sel_decoded,
     wb_cyc_i     => wb_csr_cyc_decoded(c_CSR_WB_FMC_SYS_I2C),
     wb_ack_o     => wb_all_csr_ack(c_CSR_WB_FMC_SYS_I2C),
     wb_int_o     => open,
     wb_dat_o     => wb_all_csr_dat_rd(c_CSR_WB_FMC_SYS_I2C * 32 + 31 downto 32 * c_CSR_WB_FMC_SYS_I2C),

     scl_pad_i    => sys_scl_in,
     scl_pad_o    => sys_scl_out,
     scl_padoen_o => sys_scl_oe_n,
     sda_pad_i    => sys_sda_in,
     sda_pad_o    => sys_sda_out,
     sda_padoen_o => sys_sda_oe_n);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Classic slave supporting single pipelined accesses, stall isn't used
  wb_all_csr_stall(c_CSR_WB_FMC_SYS_I2C) <= '0';

  -- Tri-state buffer for SDA and SCL
  sys_scl_b  <= sys_scl_out when sys_scl_oe_n = '0' else 'Z';
  sys_scl_in <= sys_scl_b;

  sys_sda_b  <= sys_sda_out when sys_sda_oe_n = '0' else 'Z';
  sys_sda_in <= sys_sda_b;

---------------------------------------------------------------------------------------------------
--                   Mezzanine 1-wire MASTER DS18B20 (thermometer + unique ID)                   --
---------------------------------------------------------------------------------------------------
--Note: c_CSR_WB_FMC_ONE_WIRE = 4
  cmp_fmc_onewire : wb_onewire_master
  generic map
    (g_num_ports        => 1,
     g_ow_btp_normal    => "5.0",
     g_ow_btp_overdrive => "1.0")
  port map
    (clk_sys_i   => clk,
     rst_n_i     => general_rst_n,
     wb_adr_i    => wb_csr_adr_decoded(2 downto 0),
     wb_dat_i    => wb_csr_dat_wr_decoded,
     wb_we_i     => wb_csr_we_decoded,
     wb_stb_i    => wb_csr_stb_decoded,
     wb_sel_i    => wb_csr_sel_decoded,
     wb_cyc_i    => wb_csr_cyc_decoded(c_CSR_WB_FMC_ONE_WIRE),
     wb_ack_o    => wb_all_csr_ack(c_CSR_WB_FMC_ONE_WIRE),
     wb_dat_o    => wb_all_csr_dat_rd(c_CSR_WB_FMC_ONE_WIRE * 32 + 31 downto 32 * c_CSR_WB_FMC_ONE_WIRE),
     wb_int_o    => open,
     owr_pwren_o => mezz_owr_pwren,
     owr_en_o    => mezz_owr_en,
     owr_i       => mezz_owr_i);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  mezz_one_wire_b <= '0' when mezz_owr_en(0) = '1' else 'Z';
  mezz_owr_i(0)   <= mezz_one_wire_b;

  -- Classic slave supporting single pipelined accesses, stall isn't used
  wb_all_csr_stall(c_CSR_WB_FMC_ONE_WIRE) <= '0';


---------------------------------------------------------------------------------------------------
--                                           GNUM CORE                                           --
---------------------------------------------------------------------------------------------------
-- Note: c_CSR_WB_DMA_CONFIG = 0
-- <dma_reg_adr_i<31:4>> is never used.
  gnum_interface_block: gn4124_core --cmp_gn4124_core
    port map
      (rst_n_a_i       => rst_n_a_i,
	   status_o        => open,
       p2l_clk_p_i     => p2l_clk_p_i,
       p2l_clk_n_i     => p2l_clk_n_i,
       p2l_data_i      => p2l_data_i,
       p2l_dframe_i    => p2l_dframe_i,
       p2l_valid_i     => p2l_valid_i,
       p2l_rdy_o       => p2l_rdy_o,
       p_wr_req_i      => p_wr_req_i,
       p_wr_rdy_o      => p_wr_rdy_o,
       rx_error_o      => rx_error_o,
       vc_rdy_i        => vc_rdy_i,
       l2p_clk_p_o     => l2p_clk_p_o,
       l2p_clk_n_o     => l2p_clk_n_o,
       l2p_data_o      => l2p_data_o ,
       l2p_dframe_o    => l2p_dframe_o,
       l2p_valid_o     => l2p_valid_o,
       l2p_edb_o       => l2p_edb_o,
       l2p_rdy_i       => l2p_rdy_i,
       l_wr_rdy_i      => l_wr_rdy_i,
       p_rd_d_rdy_i    => p_rd_d_rdy_i,
       tx_error_i      => tx_error_i,
       irq_p_o         => irq_p_o,
       dma_irq_o       => dma_irq,
       irq_p_i         => irq_to_gn4124,
       -----CSR all registers classic master-----
       csr_clk_i       => clk,
       csr_adr_o       => wbm_csr_adr,
       csr_cyc_o       => wbm_csr_cyc,
       csr_dat_o       => wbm_csr_dat_wr,
       csr_sel_o       => wbm_csr_sel,
       csr_stb_o       => wbm_csr_stb,
       csr_stall_i     => wbm_stall,          --<<--
       csr_we_o        => wbm_csr_we,
       csr_ack_i       => wbm_csr_ack_decoded,
       csr_dat_i       => wbm_csr_dat_rd,
       ------------DMA pipelined master----------
       dma_clk_i       => clk,
       dma_adr_o       => dma_adr,
       dma_cyc_o       => dma_cyc,
       dma_dat_o       => dma_dat_wr,
       dma_sel_o       => dma_sel,
       dma_stb_o       => dma_stb,
       dma_we_o        => dma_we,
       dma_ack_i       => dma_ack,
       dma_dat_i       => dma_dat_rd,
       dma_stall_i     => dma_stall,
       -------DMA registers classic slave--------
       dma_reg_clk_i   => clk,
       dma_reg_adr_i   => wb_csr_adr_decoded,
       dma_reg_dat_i   => wb_csr_dat_wr_decoded,
       dma_reg_sel_i   => wb_csr_sel_decoded,
       dma_reg_stb_i   => wb_csr_stb_decoded,
       dma_reg_we_i    => wb_csr_we_decoded,
       dma_reg_cyc_i   => wb_csr_cyc_decoded(c_CSR_WB_DMA_CONFIG),
       dma_reg_dat_o   => wb_all_csr_dat_rd(c_CSR_WB_DMA_CONFIG * 32 + 31 downto 32 * c_CSR_WB_DMA_CONFIG),
       dma_reg_ack_o   => wb_all_csr_ack(c_CSR_WB_DMA_CONFIG),
       dma_reg_stall_o => wb_all_csr_stall(c_CSR_WB_DMA_CONFIG));


---------------------------------------------------------------------------------------------------
--                                   TDC REGISTERS CONTROLLER                                    --
---------------------------------------------------------------------------------------------------
-- Note: c_CSR_WB_TDC_CORE = 1
  reg_control_block: reg_ctrl
    generic map
      (g_span                => g_span,
       g_width               => g_width)
    port map
      (clk_i                 => clk,
       rst_i                 => general_rst,
       gnum_csr_adr_i        => wb_csr_adr_decoded,
       gnum_csr_dat_i        => wb_csr_dat_wr_decoded,
       gnum_csr_stb_i        => wb_csr_stb_decoded,
       gnum_csr_we_i         => wb_csr_we_decoded,
       gnum_csr_cyc_i        => wb_csr_cyc_decoded(c_CSR_WB_TDC_CORE),
       gnum_csr_ack_o        => wb_all_csr_ack(c_CSR_WB_TDC_CORE),
       gnum_csr_dat_o        => wb_all_csr_dat_rd(c_CSR_WB_TDC_CORE * 32 + 31 downto 32 * c_CSR_WB_TDC_CORE),

       activate_acq_p_o      => activate_acq_p,
       deactivate_acq_p_o    => deactivate_acq_p,
       acam_wr_config_p_o    => load_acam_config,
       acam_rdbk_config_p_o  => read_acam_config,
       acam_rdbk_status_p_o  => read_acam_status,
       acam_rdbk_ififo1_p_o  => read_ififo1,
       acam_rdbk_ififo2_p_o  => read_ififo2,
       acam_rdbk_start01_p_o => read_start01,
       acam_rst_p_o          => reset_acam,
       load_utc_p_o          => load_utc,
       dacapo_c_rst_p_o      => clear_dacapo_counter,
       acam_config_rdbk_i    => acam_config_rdbk,
       acam_status_i         => acam_status,
       acam_ififo1_i         => acam_ififo1,
       acam_ififo2_i         => acam_ififo2,
       acam_start01_i        => acam_start01,
       local_utc_i           => local_utc,
       irq_code_i            => irq_code,
       core_status_i         => core_status,
       wr_index_i            => wr_index,
       acam_config_o         => acam_config,
       starting_utc_o        => starting_utc,
       acam_inputs_en_o      => acam_inputs_en,
       start_phase_o         => window_delay,
       irq_tstamp_threshold_o=> irq_tstamp_threshold,
       irq_time_threshold_o  => irq_time_threshold,
       one_hz_phase_o        => pulse_delay);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  wb_all_csr_stall(c_CSR_WB_TDC_CORE) <= '0';


---------------------------------------------------------------------------------------------------
--                                       ONE HZ GENERATOR                                        --
---------------------------------------------------------------------------------------------------
  one_second_block: one_hz_gen
    generic map
      (g_width                => g_width)
    port map
      (acam_refclk_r_edge_p_i => acam_refclk_r_edge_p,
       clk_i                  => clk,
       clk_period_i           => clk_period,
       load_utc_p_i           => load_utc,
       pulse_delay_i          => pulse_delay,
       rst_i                  => general_rst,
       starting_utc_i         => starting_utc,
       local_utc_o            => local_utc,
       one_hz_p_o             => one_hz_p);


---------------------------------------------------------------------------------------------------
--                                   ACAM TIMECONTROL INTERFACE                                  --
---------------------------------------------------------------------------------------------------
  acam_timing_block: acam_timecontrol_interface
    port map(
      err_flag_i              => err_flag_i,
      int_flag_i              => int_flag_i,
      start_dis_o             => start_dis_o,
      start_from_fpga_o       => start_from_fpga_o,
      stop_dis_o              => stop_dis_o,
      acam_refclk_r_edge_p_i  => acam_refclk_r_edge_p,
      clk_i                   => clk,
      activate_acq_p_i        => activate_acq_p,
      rst_i                   => general_rst,
      window_delay_i          => window_delay,
      acam_errflag_f_edge_p_o => acam_errflag_f_edge_p,
      acam_errflag_r_edge_p_o => acam_errflag_r_edge_p,
      acam_intflag_f_edge_p_o => acam_intflag_f_edge_p);


---------------------------------------------------------------------------------------------------
--                                     ACAM DATABUS INTERFACE                                    --
---------------------------------------------------------------------------------------------------
  acam_data_block: acam_databus_interface
    port map
      (ef1_i        => ef1_i,
       ef2_i        => ef2_i,
       lf1_i        => lf1_i,
       lf2_i        => lf2_i,
       data_bus_io  => data_bus_io,
       adr_o        => address_o,
       cs_n_o       => cs_n_o,
       oe_n_o       => oe_n_o,
       rd_n_o       => rd_n_o,
       wr_n_o       => wr_n_o,
       ef1_o        => acam_ef1,
       ef1_synch1_o => acam_ef1_meta,
       ef2_o        => acam_ef2,
       ef2_synch1_o => acam_ef2_meta,
       clk_i        => clk,
       rst_i        => general_rst,
       adr_i        => acm_adr,
       cyc_i        => acm_cyc,
       dat_i        => acm_dat_w,
       stb_i        => acm_stb,
       we_i         => acm_we,
       ack_o        => acm_ack,
       dat_o        => acm_dat_r);


---------------------------------------------------------------------------------------------------
--                                ACAM START RETRIGGER CONTROLLER                                --
---------------------------------------------------------------------------------------------------
  start_retrigger_block: start_retrig_ctrl
    generic map
      (g_width                => g_width)
    port map
      (acam_intflag_f_edge_p_i=> acam_intflag_f_edge_p,
       clk_i                  => clk,
       one_hz_p_i             => one_hz_p,
       rst_i                  => general_rst,
       clk_i_cycles_offset_o  => clk_i_cycles_offset,
       current_roll_over_o    => current_roll_over,
       retrig_nb_offset_o     => retrig_nb_offset);


---------------------------------------------------------------------------------------------------
--                                          DATA ENGINE                                          --
---------------------------------------------------------------------------------------------------
  data_engine_block: data_engine
    port map
      (acam_ack_i            => acm_ack,
       acam_dat_i            => acm_dat_r,
       acam_adr_o            => acm_adr,
       acam_cyc_o            => acm_cyc,
       acam_dat_o            => acm_dat_w,
       acam_stb_o            => acm_stb,
       acam_we_o             => acm_we,
       clk_i                 => clk,
       rst_i                 => general_rst,
       acam_ef1_i            => acam_ef1,
       acam_ef1_synch1_i     => acam_ef1_meta,
       acam_ef2_i            => acam_ef2,
       acam_ef2_synch1_i     => acam_ef2_meta,
       activate_acq_p_i      => activate_acq_p,
       deactivate_acq_p_i    => deactivate_acq_p,
       acam_wr_config_p_i    => load_acam_config,
       acam_rdbk_config_p_i  => read_acam_config,
       acam_rdbk_status_p_i  => read_acam_status,
       acam_rdbk_ififo1_p_i  => read_ififo1,
       acam_rdbk_ififo2_p_i  => read_ififo2,
       acam_rdbk_start01_p_i => read_start01,
       acam_rst_p_i          => reset_acam,
       acam_config_i         => acam_config,
       acam_config_rdbk_o    => acam_config_rdbk,
       acam_status_o         => acam_status,
       acam_ififo1_o         => acam_ififo1,
       acam_ififo2_o         => acam_ififo2,
       acam_start01_o        => acam_start01,
       acam_tstamp1_o        => acam_tstamp1,
       acam_tstamp1_ok_p_o   => acam_tstamp1_ok_p,
       acam_tstamp2_o        => acam_tstamp2,
       acam_tstamp2_ok_p_o   => acam_tstamp2_ok_p);


---------------------------------------------------------------------------------------------------
--                                       DATA FORMATTING                                         --
---------------------------------------------------------------------------------------------------
  data_formatting_block: data_formatting
    port map
      (clk_i                 => clk,
       rst_i                 => general_rst,
       tstamp_wr_wb_ack_i    => mem_class_ack,
       tstamp_wr_dat_i       => mem_class_data_rd,
       tstamp_wr_wb_adr_o    => mem_class_adr,
       tstamp_wr_wb_cyc_o    => mem_class_cyc,
       tstamp_wr_dat_o       => mem_class_data_wr,
       tstamp_wr_wb_stb_o    => mem_class_stb,
       tstamp_wr_wb_we_o     => mem_class_we,
       acam_tstamp1_i        => acam_tstamp1,
       acam_tstamp1_ok_p_i   => acam_tstamp1_ok_p,
       acam_tstamp2_i        => acam_tstamp2,
       acam_tstamp2_ok_p_i   => acam_tstamp2_ok_p,
       dacapo_c_rst_p_i      => clear_dacapo_counter,
       clk_i_cycles_offset_i => clk_i_cycles_offset,
       current_roll_over_i   => current_roll_over,
       retrig_nb_offset_i    => retrig_nb_offset,
       local_utc_i           => local_utc,
       tstamp_wr_p_o         => tstamp_wr_p,
       wr_index_o            => wr_index);


---------------------------------------------------------------------------------------------------
--                                     INTERRUPTS GENERATOR                                      --
---------------------------------------------------------------------------------------------------
  interrupts_generator: irq_generator
    generic map
      (g_width                => 32)
    port map
      (clk_i                  => clk,
       rst_i                  => general_rst,
       irq_tstamp_threshold_i => irq_tstamp_threshold,
       irq_time_threshold_i   => irq_time_threshold,
       activate_acq_p_i       => activate_acq_p,
       deactivate_acq_p_i     => deactivate_acq_p,
       tstamp_wr_p_i          => tstamp_wr_p,
       one_hz_p_i             => one_hz_p,
       irq_tstamp_p_o         => irq_tstamp_p,
       irq_time_p_o           => irq_time_p);


---------------------------------------------------------------------------------------------------
--                                        CIRCULAR BUFFER                                        --
---------------------------------------------------------------------------------------------------
  circular_buffer_block: circular_buffer
    port map
     (clk_i              => clk,
      tstamp_wr_rst_i    => general_rst,
      tstamp_wr_adr_i    => mem_class_adr,
      tstamp_wr_cyc_i    => mem_class_cyc,
      tstamp_wr_dat_i    => mem_class_data_wr,
      tstamp_wr_stb_i    => mem_class_stb,
      tstamp_wr_we_i     => mem_class_we,
      tstamp_wr_ack_p_o  => mem_class_ack,
      tstamp_wr_dat_o    => mem_class_data_rd,
      gnum_dma_rst_i     => general_rst,
      gnum_dma_adr_i     => dma_adr,
      gnum_dma_cyc_i     => dma_cyc,
      gnum_dma_dat_i     => dma_dat_wr,
      gnum_dma_stb_i     => dma_stb,
      gnum_dma_we_i      => dma_we,
      gnum_dma_ack_o     => dma_ack,
      gnum_dma_dat_o     => dma_dat_rd,
      gnum_dma_stall_o   => dma_stall);


---------------------------------------------------------------------------------------------------
--                                     CLOCKS & RESETS MANAGER                                   --
---------------------------------------------------------------------------------------------------
  clks_rsts_mgment: clks_rsts_manager
    generic map
      (nb_of_reg             => 68,
       values_for_simulation => values_for_simulation)
    port map
      (acam_refclk_i          => acam_refclk_i,
       pll_ld_i               => pll_ld_i,
       pll_refmon_i           => pll_refmon_i,
       pll_sdo_i              => pll_sdo_i,
       pll_status_i           => pll_status_i,
       gnum_rst_i             => gnum_rst,
       spec_clk_i             => spec_clk_i,
       tdc_clk_p_i            => tdc_clk_p_i,
       tdc_clk_n_i            => tdc_clk_n_i,
       acam_refclk_r_edge_p_o => acam_refclk_r_edge_p,
       internal_rst_o         => general_rst,
       pll_cs_o               => pll_cs_o,
       pll_dac_sync_o         => pll_dac_sync_o,
       pll_sdi_o              => pll_sdi_o,
       pll_sclk_o             => pll_sclk_o,
       spec_clk_o             => spec_clk,
       tdc_clk_o              => clk);


---------------------------------------------------------------------------------------------------
--                                          LEDs & more                                          --
---------------------------------------------------------------------------------------------------  

  spec_led_period_counter: free_counter
    port map
      (clk_i              => spec_clk,
       counter_en_i       => '1',
       rst_i              => gnum_rst,
       counter_top_i      => spec_led_period,
       counter_is_zero_o  => spec_led_period_done,
      counter_o           => open);
    
  spec_led_blink_counter: decr_counter
    port map
      (clk_i             => spec_clk,
       rst_i             => gnum_rst,
       counter_load_i    => spec_led_period_done,
       counter_top_i     => visible_blink_length,
       counter_is_zero_o => spec_led_blink_done,
       counter_o         => open);

  tdc_led_blink_counter: decr_counter
    port map
      (clk_i             => clk,
       rst_i             => general_rst,
       counter_load_i    => one_hz_p,
       counter_top_i     => visible_blink_length,
       counter_is_zero_o => tdc_led_blink_done,
       counter_o         => open);

  spec_led: process
    begin
      if gnum_rst ='1' then
        spec_led_red <= '0';
      elsif spec_led_period_done ='1' then
        spec_led_red <= '1';
      elsif spec_led_blink_done ='1' then
        spec_led_red <= '0';
      end if;
    wait until spec_clk ='1';
  end process;
    
  tdc_led: process
    begin
      if general_rst ='1' then
        tdc_led_status <= '0';
      elsif one_hz_p ='1' then
        tdc_led_status <= '1';
      elsif tdc_led_blink_done = '1' then
        tdc_led_status <= '0';
      end if;
    wait until clk ='1';
  end process;
    
  spec_led_period      <= c_SPEC_LED_PERIOD_SIM when values_for_simulation else c_SPEC_LED_PERIOD_SYN;
  visible_blink_length <= c_BLINK_LGTH_SIM when values_for_simulation else c_BLINK_LGTH_SYN;
  clk_period           <= c_SIM_CLK_PERIOD when values_for_simulation else c_SYN_CLK_PERIOD;

  spec_led_green       <= pll_ld_i;

  -- inputs
  sync_gnum_reset: process
    begin
      gnum_rst_synch <= not(rst_n_a_i);
      gnum_rst       <= gnum_rst_synch;
    wait until spec_clk ='1';
  end process;

  general_rst_n <= not general_rst;

  -- outputs
  process
    begin
      mute_inputs_o    <= acam_inputs_en(7);
      term_en_5_o      <= acam_inputs_en(4);
      term_en_4_o      <= acam_inputs_en(3);
      term_en_3_o      <= acam_inputs_en(2);
      term_en_2_o      <= acam_inputs_en(1);
      term_en_1_o      <= acam_inputs_en(0);
      spec_led_green_o <= spec_led_green;
      spec_led_red_o   <= spec_led_red;
      tdc_led_status_o <= tdc_led_status;
      tdc_led_trig5_o  <= acam_inputs_en(4) and acam_inputs_en(7);
      tdc_led_trig4_o  <= acam_inputs_en(3) and acam_inputs_en(7);
      tdc_led_trig3_o  <= acam_inputs_en(2) and acam_inputs_en(7);
      tdc_led_trig2_o  <= acam_inputs_en(1) and acam_inputs_en(7);
      tdc_led_trig1_o  <= acam_inputs_en(0) and acam_inputs_en(7);
    wait until clk ='1';
  end process;

  -- note: all spec_aux signals are active low
  button_with_spec_clk_i: process
    begin
      spec_aux3_o             <= spec_aux0_i;
      spec_aux2_o             <= spec_aux0_i;
    wait until spec_clk ='1';
  end process;

  button_with_tdc_clk_i: process
    begin
      spec_aux4_o             <= spec_aux1_i;
      spec_aux5_o             <= spec_aux1_i;
    wait until clk ='1';
  end process;
    
end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
