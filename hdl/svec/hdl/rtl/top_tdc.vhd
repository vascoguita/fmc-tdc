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
    (g_span            : integer :=32;                      -- address span in bus interfaces
     g_width           : integer :=32;                      -- data width in bus interfaces
     values_for_simul  : boolean :=FALSE);                  -- this generic is set to TRUE
                                                            -- when instantiated in a test-bench
  port
    (-- Carrier PoR
     por_n_i            : in    std_logic;
     -- Carrier 20MHz VCXO
     clk_20m_vcxo_i     : in    std_logic;
     -- VME interface
     VME_AS_n_i         : in    std_logic;
     VME_RST_n_i        : in    std_logic;
     VME_WRITE_n_i      : in    std_logic;
     VME_AM_i           : in    std_logic_vector(5 downto 0);
     VME_DS_n_i         : in    std_logic_vector(1 downto 0);
     VME_GA_i           : in    std_logic_vector(5 downto 0);
     VME_BERR_o         : inout std_logic;
     VME_DTACK_n_o      : inout std_logic;
     VME_RETRY_n_o      : out   std_logic;
     VME_RETRY_OE_o     : out   std_logic;
     VME_LWORD_n_b      : inout std_logic;
     VME_ADDR_b         : inout std_logic_vector(31 downto 1);
     VME_DATA_b         : inout std_logic_vector(31 downto 0);
     VME_BBSY_n_i       : in    std_logic;
     VME_IRQ_n_o        : out   std_logic_vector(6 downto 0);
     VME_IACK_n_i       : in    std_logic;
     VME_IACKIN_n_i     : in    std_logic;
     VME_IACKOUT_n_o    : out   std_logic;
     VME_DTACK_OE_o     : inout std_logic;
     VME_DATA_DIR_o     : inout std_logic;
     VME_DATA_OE_N_o    : inout std_logic;
     VME_ADDR_DIR_o     : inout std_logic;
     VME_ADDR_OE_N_o    : inout std_logic;
     -- TDC mezzanine PLL AD9516 and DAC AD5662 interface
     pll_sclk_o         : out   std_logic;
     pll_sdi_o          : out   std_logic;
     pll_cs_n_o         : out   std_logic;
     pll_dac_sync_n_o   : out   std_logic;
     pll_sdo_i          : in    std_logic; 
     pll_status_i       : in    std_logic; 
     tdc_125m_clk_p_i   : in    std_logic; 
     tdc_125m_clk_n_i   : in    std_logic;
     acam_refclk_p_i    : in    std_logic; 
     acam_refclk_n_i    : in    std_logic;
     -- TDC mezzanine ACAM timing interface
     start_from_fpga_o  : out   std_logic;
     err_flag_i         : in    std_logic;
     int_flag_i         : in    std_logic;
     --start_dis_o        : out   std_logic;
     --stop_dis_o         : out   std_logic;
     -- TDC mezzanine ACAM data interface
     data_bus_io        : inout std_logic_vector(27 downto 0);
     address_o          : out   std_logic_vector(3 downto 0);
     cs_n_o             : out   std_logic;
     oe_n_o             : out   std_logic;
     rd_n_o             : out   std_logic;
     wr_n_o             : out   std_logic;
     ef1_i              : in    std_logic;
     ef2_i              : in    std_logic;
     -- TDC mezzanine Input Logic
     enable_inputs_o    : out   std_logic;
     term_en_1_o        : out   std_logic;
     term_en_2_o        : out   std_logic;
     term_en_3_o        : out   std_logic;
     term_en_4_o        : out   std_logic;
     term_en_5_o        : out   std_logic;
     -- TDC mezzanine LEDs
     tdc_led_status_o   : out   std_logic;
     tdc_led_trig1_o    : out   std_logic;
     tdc_led_trig2_o    : out   std_logic;
     tdc_led_trig3_o    : out   std_logic;
     tdc_led_trig4_o    : out   std_logic;
     tdc_led_trig5_o    : out   std_logic;
     -- TDC mezzanine Input channels, also arriving to the FPGA (not used for the moment)
     tdc_in_fpga_1_i    : in    std_logic;
     tdc_in_fpga_2_i    : in    std_logic;
     tdc_in_fpga_3_i    : in    std_logic;
     tdc_in_fpga_4_i    : in    std_logic;
     tdc_in_fpga_5_i    : in    std_logic;
     -- TDC mezzanine I2C interface for EEPROM
     sys_scl_b          : inout std_logic;
     sys_sda_b          : inout std_logic;
     -- TDC mezzanine 1-wire interface for UniqueID & Thermometer
     mezz_one_wire_b    : inout std_logic;
     -- Carrier 1-wire interface for UniqueID & Thermometer
     carrier_one_wire_b : inout std_logic;
     -- Carrier other signals
     pcb_ver_i          : in    std_logic_vector(3 downto 0);
     prsnt_m2c_n_i      : in    std_logic;
     -- LEDs array
     fp_ledn_o           : out std_logic_vector(7 downto 0));

end top_tdc;

--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of top_tdc is

---------------------------------------------------------------------------------------------------
--                                           CONSTANTS                                           --
---------------------------------------------------------------------------------------------------
  ---> Constant regarding the Carrier type
  constant c_CARRIER_TYPE   : std_logic_vector(15 downto 0) := x"0002";

  ---> Constants regarding the SDB crossbar
  constant c_NUM_WB_SLAVES   : integer := 1;
  constant c_NUM_WB_MASTERS  : integer := 4;
  constant c_SLAVE_SVEC_1W   : integer := 0;  -- SVEC 1wire interface
  constant c_SLAVE_SVEC_INFO : integer := 1;  -- SVEC control and status registers
  constant c_SLAVE_IRQ       : integer := 2;  -- Interrupt controller
  constant c_SLAVE_TDC       : integer := 3;  -- TIMETAG core for time-tagging

  constant c_SDB_ADDRESS         : t_wishbone_address := x"00000000";
  constant c_FMC_TDC_SDB_BRIDGE  : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"0001FFFF", x"00040000");
                                                                       -- (   size    ,   sdb_addr )
  constant c_INTERCONNECT_LAYOUT : t_sdb_record_array(6 downto 0) :=
    (0 => f_sdb_embed_device     (c_ONEWIRE_SDB_DEVICE,  x"00010000"),
     1 => f_sdb_embed_device     (c_SPEC_CSR_SDB_DEVICE, x"00020000"),
     2 => f_sdb_embed_device     (c_INT_SDB_DEVICE,      x"00030000"),
     3 => f_sdb_embed_bridge     (c_FMC_TDC_SDB_BRIDGE,  x"00040000"),
     4 => f_sdb_embed_repo_url   (c_SDB_REPO_URL),
     5 => f_sdb_embed_synthesis  (c_SDB_SYNTHESIS),
     6 => f_sdb_embed_integration(c_SDB_INTEGRATION));

---------------------------------------------------------------------------------------------------
--                                            Signals                                            --
---------------------------------------------------------------------------------------------------
  -- Clocks and resets
  signal clk_125m, general_rst_n, general_rst, vme_rst_n     : std_logic;
  signal clk_20m_vcxo_buf, clk_20m_vcxo           : std_logic;
  signal acam_refclk_r_edge_p                     : std_logic;
  signal send_dac_word_p                          : std_logic;
  signal dac_word                                 : std_logic_vector(23 downto 0);
  -- VME interface
  signal VME_DATA_b_out                           : std_logic_vector(31 downto 0);
  signal VME_ADDR_b_out                           : std_logic_vector(31 downto 1);
  signal VME_LWORD_n_b_out, VME_DATA_DIR_int      : std_logic;
  signal VME_ADDR_DIR_int                         : std_logic;
  signal vme_master_out                           : t_wishbone_master_out;
  signal vme_master_in                            : t_wishbone_master_in;
  -- WISHBONE from crossbar master port
  signal cnx_master_out                           : t_wishbone_master_out_array(c_NUM_WB_MASTERS-1 downto 0);
  signal cnx_master_in                            : t_wishbone_master_in_array(c_NUM_WB_MASTERS-1 downto 0);
  -- WISHBONE to crossbar slave port
  signal cnx_slave_out                            : t_wishbone_slave_out_array(c_NUM_WB_SLAVES-1 downto 0);
  signal cnx_slave_in                             : t_wishbone_slave_in_array(c_NUM_WB_SLAVES-1 downto 0);
  -- Interrupts
  signal irq_to_vmecore                           : std_logic;  
  signal irq_acam_err_p, irq_tstamp_p, irq_time_p : std_logic;  
  -- Carrier CSR info
  signal mezz_pll_status                          : std_logic_vector(11 downto 0);
  -- Carrier 1-wire
  signal carrier_owr_en, carrier_owr_i            : std_logic_vector(c_FMC_ONE_WIRE_NB - 1 downto 0);
  -- SVEC LEDs
  signal led_divider                              : unsigned(22 downto 0);
  signal leds                                     : std_logic_vector(7 downto 0);
  -- IRQs
  signal irq_sources                              : std_logic_vector(31 downto 0);
  signal pllxilinx_62m5_clk_buf       : std_logic;
  signal pllout_clk_dmtd      : std_logic;
  signal pllxilinx_62m5_clk_fb : std_logic;
  signal pllout_clk_fb_dmtd   : std_logic;
  signal clk_62m5_pllxilinx          : std_logic;
  signal clk_dmtd         : std_logic;
  signal clk_125m_pllref  : std_logic;
  attribute buffer_type                    : string;  --" {bufgdll | ibufg | bufgp | ibuf | bufr | none}";
  attribute buffer_type of clk_125m_pllref : signal is "BUFG";


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin



---------------------------------------------------------------------------------------------------
--                                         SVEC LED test                                         --
---------------------------------------------------------------------------------------------------
  drive_leds : process (clk_62m5_pllxilinx)
  begin
    if rising_edge(clk_62m5_pllxilinx) then
      
      if(vme_rst_n = '0') then
        leds        <= "01111111";
        led_divider <= (others => '0');
      else
        led_divider <= led_divider+ 1;
        if(led_divider = 0) then
          leds      <= leds(6 downto 0) & leds(7);
        end if;
      end if;
    end if;
  end process;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  fp_ledn_o <= leds;



---------------------------------------------------------------------------------------------------
--                                     CLOCKS & RESETS MANAGER                                   --
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
  svec_clk_ibuf : IBUFG
  port map
    (I => clk_20m_vcxo_i,
     O => clk_20m_vcxo_buf);

  svec_clk_gbuf : BUFG
  port map
    (O => clk_20m_vcxo,
     I => clk_20m_vcxo_buf);

---------------------------------------------------------------------------------------------------
  cmp_sys_clk_pll : PLL_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",
      CLK_FEEDBACK       => "CLKFBOUT",
      COMPENSATION       => "INTERNAL",
      DIVCLK_DIVIDE      => 1,
      CLKFBOUT_MULT      => 8,
      CLKFBOUT_PHASE     => 0.000,
      CLKOUT0_DIVIDE     => 16,         -- 62.5 MHz
      CLKOUT0_PHASE      => 0.000,
      CLKOUT0_DUTY_CYCLE => 0.500,
      CLKOUT1_DIVIDE     => 16,         -- 125 MHz, not used
      CLKOUT1_PHASE      => 0.000,
      CLKOUT1_DUTY_CYCLE => 0.500,
      CLKOUT2_DIVIDE     => 16,
      CLKOUT2_PHASE      => 0.000,
      CLKOUT2_DUTY_CYCLE => 0.500,
      CLKIN_PERIOD       => 8.0,
      REF_JITTER         => 0.016)
    port map (
      CLKFBOUT => pllxilinx_62m5_clk_fb,
      CLKOUT0  => pllxilinx_62m5_clk_buf,
      CLKOUT1  => open,
      CLKOUT2  => open,
      CLKOUT3  => open,
      CLKOUT4  => open,
      CLKOUT5  => open,
      LOCKED   => open,
      RST      => '0',
      CLKFBIN  => pllxilinx_62m5_clk_fb,
      CLKIN    => clk_125m);

  cmp_clk_62m5_pllxilinx_buf : BUFG
    port map (
      O => clk_62m5_pllxilinx,
      I => pllxilinx_62m5_clk_buf);

---------------------------------------------------------------------------------------------------
  clks_rsts_mgment: clks_rsts_manager
  generic map
    (nb_of_reg              => 68)
  port map
    (clk_20m_vcxo_i         => clk_20m_vcxo,
     acam_refclk_p_i        => acam_refclk_p_i,
     acam_refclk_n_i        => acam_refclk_n_i,
     tdc_125m_clk_p_i       => tdc_125m_clk_p_i,
     tdc_125m_clk_n_i       => tdc_125m_clk_n_i,
     clk_62m5_pllxilinx_i   => clk_62m5_pllxilinx,
     rst_n_i                => VME_RST_n_i,
     por_n_i                => por_n_i,
     pll_sdo_i              => pll_sdo_i,
     pll_status_i           => pll_status_i,
     send_dac_word_p_i      => send_dac_word_p,
     dac_word_i             => dac_word,
     acam_refclk_r_edge_p_o => acam_refclk_r_edge_p,
     internal_rst_o         => general_rst,
     vme_rst_n_o            => vme_rst_n,
     pll_cs_n_o             => pll_cs_n_o,
     pll_dac_sync_n_o       => pll_dac_sync_n_o,
     pll_sdi_o              => pll_sdi_o,
     pll_sclk_o             => pll_sclk_o,
     tdc_125m_clk_o         => clk_125m,
     pll_status_o           => open);

    --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
    general_rst_n   <= not (general_rst);


  clks_crossing_125M_62M5: xwb_clock_crossing
   port map
     (slave_clk_i    => clk_62m5_pllxilinx, -- Slave control port: 
      slave_rst_n_i  => vme_rst_n,
      slave_i        => vme_master_out,
      slave_o        => vme_master_in,
      master_clk_i   => clk_125m,           -- Master reader port: 
      master_rst_n_i => general_rst_n,
      master_i       => cnx_slave_out(0),
      master_o       => cnx_slave_in(0));

  --cnx_slave_in(0)       <= vme_master_out;
  --vme_master_in         <= cnx_slave_out(0);
  --signal vme_master_out : t_wishbone_master_out;
  --signal vme_master_in  : t_wishbone_master_in;
  --signal cnx_slave_out  : t_wishbone_slave_out_array(c_NUM_WB_SLAVES-1 downto 0);
  --signal cnx_slave_in   : t_wishbone_slave_in_array(c_NUM_WB_SLAVES-1 downto 0);

  --signal cnx_master_out : t_wishbone_master_out_array(c_NUM_WB_MASTERS-1 downto 0);
  --signal cnx_master_in  : t_wishbone_master_in_array(c_NUM_WB_MASTERS-1 downto 0);

---------------------------------------------------------------------------------------------------
--                                     CSR WISHBONE CROSSBAR                                     --
---------------------------------------------------------------------------------------------------
-- CSR wishbone address decoder
--   0x1000 -> Interrupts controller
--   0x1800 -> SVEC UnidueID&Thermometer 1-wire
--   0x1C00 -> SVEC CSR information
--   0x2000 -> TDC board on FMC1

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
     rst_n_i       => general_rst_n,
     slave_i       => cnx_slave_in,
     slave_o       => cnx_slave_out,
     master_i      => cnx_master_in,
     master_o      => cnx_master_out);


---------------------------------------------------------------------------------------------------
--                                           VME CORE                                            --
---------------------------------------------------------------------------------------------------
  U_VME_Core : xvme64x_core
    port map (
      clk_i           => clk_62m5_pllxilinx,
      rst_n_i         => vme_rst_n, --------------
      VME_AS_n_i      => VME_AS_n_i,
      VME_RST_n_i     => vme_rst_n, --------------
      VME_WRITE_n_i   => VME_WRITE_n_i,
      VME_AM_i        => VME_AM_i,
      VME_DS_n_i      => VME_DS_n_i,
      VME_GA_i        => VME_GA_i,
      VME_BERR_o      => VME_BERR_o,
      VME_DTACK_n_o   => VME_DTACK_n_o,
      VME_RETRY_n_o   => VME_RETRY_n_o,
      VME_RETRY_OE_o  => VME_RETRY_OE_o,
      VME_LWORD_n_b_i => VME_LWORD_n_b,
      VME_LWORD_n_b_o => VME_LWORD_n_b_out,
      VME_ADDR_b_i    => VME_ADDR_b,
      VME_DATA_b_o    => VME_DATA_b_out,
      VME_ADDR_b_o    => VME_ADDR_b_out,
      VME_DATA_b_i    => VME_DATA_b,
      VME_IRQ_n_o     => VME_IRQ_n_o,
      VME_IACK_n_i    => VME_IACK_n_i,
      VME_IACKIN_n_i  => VME_IACKIN_n_i,
      VME_IACKOUT_n_o => VME_IACKOUT_n_o,
      VME_DTACK_OE_o  => VME_DTACK_OE_o,
      VME_DATA_DIR_o  => VME_DATA_DIR_int,
      VME_DATA_OE_N_o => VME_DATA_OE_N_o,
      VME_ADDR_DIR_o  => VME_ADDR_DIR_int,
      VME_ADDR_OE_N_o => VME_ADDR_OE_N_o,
      master_o        => vme_master_out,
      master_i        => vme_master_in,
      irq_i           => irq_to_vmecore);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  VME_DATA_b      <= VME_DATA_b_out    when VME_DATA_DIR_int = '1' else (others => 'Z');
  VME_ADDR_b      <= VME_ADDR_b_out    when VME_ADDR_DIR_int = '1' else (others => 'Z');
  VME_LWORD_n_b   <= VME_LWORD_n_b_out when VME_ADDR_DIR_int = '1' else 'Z';

  VME_ADDR_DIR_o  <= VME_ADDR_DIR_int;
  VME_DATA_DIR_o  <= VME_DATA_DIR_int;

  --cnx_slave_in(0) <= vme_master_out;
  --vme_master_in   <= cnx_slave_out(0);



---------------------------------------------------------------------------------------------------
--                                             TDC BOARD                                         --
---------------------------------------------------------------------------------------------------
  tdc_board: fmc_tdc_mezzanine
  generic map
    (g_span                  => g_span,
     g_width                 => g_width,
     values_for_simul        => FALSE)
  port map
    (-- clocks, resets, dac
     clk_125m_i              => clk_125m,
     rst_i                   => general_rst,
     acam_refclk_r_edge_p_i  => acam_refclk_r_edge_p,
     send_dac_word_p_o       => send_dac_word_p,
     dac_word_o              => dac_word,
     -- ACAM
     start_from_fpga_o       => start_from_fpga_o,
     err_flag_i              => err_flag_i,
     int_flag_i              => int_flag_i,
     start_dis_o             => open,--start_dis_o,
     stop_dis_o              => open,--stop_dis_o,
     data_bus_io             => data_bus_io,
     address_o               => address_o,
     cs_n_o                  => cs_n_o,
     oe_n_o                  => oe_n_o,
     rd_n_o                  => rd_n_o,
     wr_n_o                  => wr_n_o,
     ef1_i                   => ef1_i,
     ef2_i                   => ef2_i,
     -- Input channels enable
     enable_inputs_o         => enable_inputs_o,
     term_en_1_o             => term_en_1_o,
     term_en_2_o             => term_en_2_o,
     term_en_3_o             => term_en_3_o,
     term_en_4_o             => term_en_4_o,
     term_en_5_o             => term_en_5_o,
     -- Input channels to FPGA (not used)
     tdc_in_fpga_1_i         => tdc_in_fpga_1_i,
     tdc_in_fpga_2_i         => tdc_in_fpga_2_i,
     tdc_in_fpga_3_i         => tdc_in_fpga_3_i,
     tdc_in_fpga_4_i         => tdc_in_fpga_4_i,
     tdc_in_fpga_5_i         => tdc_in_fpga_5_i,
     -- LEDs and buttons on TDC and SPEC
     tdc_led_status_o        => tdc_led_status_o,
     tdc_led_trig1_o         => tdc_led_trig1_o,
     tdc_led_trig2_o         => tdc_led_trig2_o,
     tdc_led_trig3_o         => tdc_led_trig3_o,
     tdc_led_trig4_o         => tdc_led_trig4_o,
     tdc_led_trig5_o         => tdc_led_trig5_o,
     -- Interrupts
     irq_tstamp_p_o          => irq_tstamp_p,
     irq_time_p_o            => irq_time_p,
     irq_acam_err_p_o        => irq_acam_err_p,
     -- WISHBONE interface with the GNUM/VME_core
     wb_tdc_mezz_adr_i       => cnx_master_out(c_SLAVE_TDC).adr,
     wb_tdc_mezz_dat_i       => cnx_master_out(c_SLAVE_TDC).dat,
     wb_tdc_mezz_dat_o       => cnx_master_in (c_SLAVE_TDC).dat,
     wb_tdc_mezz_cyc_i       => cnx_master_out(c_SLAVE_TDC).cyc,
     wb_tdc_mezz_sel_i       => cnx_master_out(c_SLAVE_TDC).sel,
     wb_tdc_mezz_stb_i       => cnx_master_out(c_SLAVE_TDC).stb,
     wb_tdc_mezz_we_i        => cnx_master_out(c_SLAVE_TDC).we,
     wb_tdc_mezz_ack_o       => cnx_master_in (c_SLAVE_TDC).ack,
     wb_tdc_mezz_stall_o     => cnx_master_in (c_SLAVE_TDC).stall,
     -- TDC board EEPROM I2C EEPROM interface
     sys_scl_b               => sys_scl_b,
     sys_sda_b               => sys_sda_b,
     -- 1-wire UniqueID&Thermometer interface
     mezz_one_wire_b         => mezz_one_wire_b);


  --wb_tdc_mezz_adr <= "00" & cnx_master_out(c_SLAVE_TDC).adr(31 downto 2);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused WISHBONE signals
  cnx_master_in(c_SLAVE_TDC).err <= '0';
  cnx_master_in(c_SLAVE_TDC).rty <= '0';
  cnx_master_in(c_SLAVE_TDC).int <= '0';



---------------------------------------------------------------------------------------------------
--                                     INTERRUPTS CONTROLLER                                     --
---------------------------------------------------------------------------------------------------
-- IRQ sources
-- 0 -> unused
-- 1 -> unused
-- 2 -> number of timestamps reached threshold
-- 3 -> number of seconds passed reached threshold
-- 4 -> ACAM error
-- 5-31 -> unused
  cmp_irq_controller : irq_controller
  port map
    (clk_i       => clk_125m,
     rst_n_i     => general_rst_n,
     irq_src_p_i => irq_sources,
     irq_p_o     => irq_to_vmecore,
     wb_adr_i    => cnx_master_out(c_SLAVE_IRQ).adr(3 downto 2),
     wb_dat_i    => cnx_master_out(c_SLAVE_IRQ).dat,
     wb_dat_o    => cnx_master_in(c_SLAVE_IRQ).dat,
     wb_cyc_i    => cnx_master_out(c_SLAVE_IRQ).cyc,
     wb_sel_i    => cnx_master_out(c_SLAVE_IRQ).sel,
     wb_stb_i    => cnx_master_out(c_SLAVE_IRQ).stb,
     wb_we_i     => cnx_master_out(c_SLAVE_IRQ).we,
     wb_ack_o    => cnx_master_in(c_SLAVE_IRQ).ack);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  irq_sources(2)           <= irq_tstamp_p;
  irq_sources(3)           <= irq_time_p;
  irq_sources(4)           <= irq_acam_err_p;
  irq_sources(1 downto 0)  <= (others => '0');
  irq_sources(31 downto 5) <= (others => '0');
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused wishbone signals
  cnx_master_in(c_SLAVE_IRQ).err   <= '0';
  cnx_master_in(c_SLAVE_IRQ).rty   <= '0';
  cnx_master_in(c_SLAVE_IRQ).stall <= '0';
  cnx_master_in(c_SLAVE_IRQ).int   <= '0';



---------------------------------------------------------------------------------------------------
--                    Carrier 1-wire MASTER DS18B20 (thermometer + unique ID)                    --
---------------------------------------------------------------------------------------------------
  cmp_carrier_onewire : xwb_onewire_master
  generic map
    (g_interface_mode      => PIPELINED,
     g_address_granularity => BYTE,
     g_num_ports           => 1,
     g_ow_btp_normal       => "5.0",
     g_ow_btp_overdrive    => "1.0")
  port map
    (clk_sys_i   => clk_125m,
     rst_n_i     => general_rst_n,
     slave_i     => cnx_master_out(c_SLAVE_SVEC_1W),
     slave_o     => cnx_master_in(c_SLAVE_SVEC_1W),
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
     wb_addr_i                        => cnx_master_out(c_SLAVE_SVEC_INFO).adr(3 downto 2),
     wb_data_i                        => cnx_master_out(c_SLAVE_SVEC_INFO).dat,
     wb_data_o                        => cnx_master_in(c_SLAVE_SVEC_INFO).dat,
     wb_cyc_i                         => cnx_master_out(c_SLAVE_SVEC_INFO).cyc,
     wb_sel_i                         => cnx_master_out(c_SLAVE_SVEC_INFO).sel,
     wb_stb_i                         => cnx_master_out(c_SLAVE_SVEC_INFO).stb,
     wb_we_i                          => cnx_master_out(c_SLAVE_SVEC_INFO).we,
     wb_ack_o                         => cnx_master_in(c_SLAVE_SVEC_INFO).ack,
     carrier_csr_carrier_pcb_rev_i    => pcb_ver_i,
     carrier_csr_carrier_reserved_i   => mezz_pll_status,
     carrier_csr_carrier_type_i       => c_CARRIER_TYPE,
     carrier_csr_stat_fmc_pres_i      => prsnt_m2c_n_i,
     carrier_csr_stat_p2l_pll_lck_i   => '0',
     carrier_csr_stat_sys_pll_lck_i   => '0',
     carrier_csr_stat_ddr3_cal_done_i => '0',
     carrier_csr_stat_reserved_i      => x"0C0FFEE", -- for debugging
     carrier_csr_ctrl_led_green_o     => open,
     carrier_csr_ctrl_led_red_o       => open,
     carrier_csr_ctrl_dac_clr_n_o     => open,
     carrier_csr_ctrl_reserved_o      => open);


  mezz_pll_status <= "00000000000" & pll_status_i;
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused wishbone signals
  cnx_master_in(c_SLAVE_SVEC_INFO).err   <= '0';
  cnx_master_in(c_SLAVE_SVEC_INFO).rty   <= '0';
  cnx_master_in(c_SLAVE_SVEC_INFO).stall <= '0';
  cnx_master_in(c_SLAVE_SVEC_INFO).int   <= '0';

   
end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------