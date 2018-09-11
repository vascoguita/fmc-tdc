--_________________________________________________________________________________________________
--                                                                                                |
--                                           |TDC core|                                           |
--                                                                                                |
--                                         CERN,BE/CO-HT                                          |
--________________________________________________________________________________________________|

---------------------------------------------------------------------------------------------------
--                                                                                                |
--                                        fmc_tdc_mezzanine                                       |
--                                                                                                |
---------------------------------------------------------------------------------------------------
-- File         fmc_tdc_mezzanine.vhd                                                             |
--                                                                                                |
-- Description  The unit combines                                                                 |
--                o the TDC core                                                                  |
--                o the wrabbit_sync unit that is managing the White Rabbit synchronization  and  |
--                  control signals                                                               |
--                o the I2C core for the communication with the TDC board EEPROM                  |
--                o the OneWire core for the communication with the TDC board UniqueID&Thermeter  |
--                o the Embedded Interrupt Controller core that concentrates several interrupt    |
--                  sources into one WISHBONE interrupt request line.                             |
--                                                                                                |
--              For the interconnection between the GN4124/VME core and the different cores (TDC, |
--              I2C, 1W, EIC, timestamps memory) the unit instantiates an SDB crossbar.           |
--                                                                                                |
--              Note that the TDC core uses word addressing, whereas the GN4124/VME cores use byte|
--              addressing                                                                        |
--                                   _______________________________                              |
--                                 |       FMC TDC mezzanine        |                             |
--                                 |                                |                             |
--                                 |     ________________           |                             |
--                                 | |--|  WRabbit_sync  |          |                             |
--                                 | |  |________________|          |                             |
--                                 | |   ________________    ___    |                             |
--                                 | |->|                |  |   |   |                             |
--                 ACAM chip <-->  |    |    TDC core    |  |   |   |   <-->                      |
--                                 | |--|________________|  | S |   |                             |
--                                 | |   ________________   |   |   |                             |
--                                 | |  |                |  |   |   |                             |
--               EEPROM chip <-->  | |  |    I2C core    |  |   |   |   <-->                      |
--                                 | |  |________________|  |   |   |                             |
--                                 | |   ________________   | D |   |          GN4124/VME core    |
--                                 | |  |                |  |   |   |                             |
--                   1W chip <-->  | |  |     1W core    |  |   |   |   <-->                      |
--                                 | |  |________________|  |   |   |                             |
--                                 | |   ________________   |   |   |                             |
--                                 | |  |                |  | B |   |                             |
--                                 | |->|       EIC      |  |   |   |   <-->                      |
--                                 |    |________________|  |___|   |                             |
--                                 |                                |                             |
--                                 |________________________________|                             |
--                                     ^                        ^                                 |
--                                     | 125 MHz            rst |                                 |
--                                   __|________________________|___                              |
--                                  |                               |                             |
--                   DAC chip <-->  |       clks_rsts_manager       |                             |
--                   PLL chip       |_______________________________|                             |
--                                                                                                |
--                         Figure 1: FMC TDC mezzanine architecture and                           |
--                          connection with the clks_rsts_manager unit                            |
--                                                                                                |
--                                                                                                |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
--              Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
-- Date         01/2014                                                                           |
-- Version      v2                                                                                |
-- Depends on                                                                                     |
--                                                                                                |
----------------                                                                                  |
-- Last changes                                                                                   |
--     07/2013  v1  EG  First version                                                             |
--     01/2014  v2  EG  Different output for the timestamp data                                   |
--     01/2014  v3  EG  Removed option for timestamps retrieval through DMA                       |
--     08/2014  v4  EG  Corrected missalignement between wrabbit_tai and wrabbit_tai_p (line 444) |
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
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tdc_core_pkg.all;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;
use work.TDC_OW_wbgen2_pkg.all;

--=================================================================================================
--                                Entity declaration for fmc_tdc_mezzanine
--=================================================================================================
entity fmc_tdc_mezzanine is
  generic
    (g_with_wrabbit_core           : boolean := false;
     g_span                        : integer := 32;
     g_width                       : integer := 32;
     g_simulation                  : boolean := false;
     g_use_dma_readout             : boolean := true;
     g_use_fake_timestamps_for_sim : boolean := false);
  port
    -- TDC core
    (

      -- System clock & reset (Wishbone)
      clk_sys_i   : in std_logic;       -- 62.5 MHz clock
      rst_sys_n_i : in std_logic;       -- reset for 62.5 MHz logic

      -- TDC 125 MHz reference & Reset (FMC)
      clk_tdc_i   : in std_logic;       -- 125 MHz clock
      rst_tdc_n_i : in std_logic;       -- reset for 125 MHz logic

      acam_refclk_r_edge_p_i    : in    std_logic;
      send_dac_word_p_o         : out   std_logic;
      dac_word_o                : out   std_logic_vector(23 downto 0);
      -- Interface with ACAM
      start_from_fpga_o         : out   std_logic;
      err_flag_i                : in    std_logic;
      int_flag_i                : in    std_logic;
      start_dis_o               : out   std_logic;
      stop_dis_o                : out   std_logic;
      data_bus_io               : inout std_logic_vector(27 downto 0);
      address_o                 : out   std_logic_vector(3 downto 0);
      cs_n_o                    : out   std_logic;
      oe_n_o                    : out   std_logic;
      rd_n_o                    : out   std_logic;
      wr_n_o                    : out   std_logic;
      ef1_i                     : in    std_logic;
      ef2_i                     : in    std_logic;
      -- Channels termination 
      enable_inputs_o           : out   std_logic;
      term_en_1_o               : out   std_logic;
      term_en_2_o               : out   std_logic;
      term_en_3_o               : out   std_logic;
      term_en_4_o               : out   std_logic;
      term_en_5_o               : out   std_logic;
      -- TDC board LEDs
      tdc_led_status_o          : out   std_logic;
      tdc_led_trig1_o           : out   std_logic;
      tdc_led_trig2_o           : out   std_logic;
      tdc_led_trig3_o           : out   std_logic;
      tdc_led_trig4_o           : out   std_logic;
      tdc_led_trig5_o           : out   std_logic;
      -- White Rabbit core
      wrabbit_link_up_i         : in    std_logic;
      wrabbit_time_valid_i      : in    std_logic;
      wrabbit_cycles_i          : in    std_logic_vector(27 downto 0);
      wrabbit_utc_i             : in    std_logic_vector(31 downto 0);
      wrabbit_clk_aux_lock_en_o : out   std_logic;
      wrabbit_clk_aux_locked_i  : in    std_logic;
      wrabbit_clk_dmtd_locked_i : in    std_logic;
      wrabbit_dac_value_i       : in    std_logic_vector(23 downto 0);
      wrabbit_dac_wr_p_i        : in    std_logic;

      -- WISHBONE interface with the GN4124/VME_core (clk_sys)
      -- for the core configuration | timestamps retrieval | core interrupts | 1Wire | I2C 

      slave_i : in  t_wishbone_slave_in;
      slave_o : out t_wishbone_slave_out;

      dma_wb_o : out t_wishbone_master_out;
      dma_wb_i : in  t_wishbone_master_in;

      wb_irq_o : out std_logic;

      -- I2C EEPROM interface
      i2c_scl_o              : out   std_logic;
      i2c_scl_oen_o          : out   std_logic;
      i2c_scl_i              : in    std_logic;
      i2c_sda_oen_o          : out   std_logic;
      i2c_sda_o              : out   std_logic;
      i2c_sda_i              : in    std_logic;
      -- 1-Wire interface
      onewire_b              : inout std_logic;
      direct_timestamp_o     : out   std_logic_vector(127 downto 0);
      direct_timestamp_stb_o : out   std_logic;

      sim_timestamp_i       : in  t_tdc_timestamp := c_dummy_timestamp;
      sim_timestamp_valid_i : in  std_logic       := '0';
      sim_timestamp_ready_o : out std_logic

      );
end fmc_tdc_mezzanine;


--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of fmc_tdc_mezzanine is

---------------------------------------------------------------------------------------------------
--                                         SDB CONSTANTS                                         --
---------------------------------------------------------------------------------------------------
  -- Note: All address in sdb and crossbar are BYTE addresses!

  -- Master ports on the wishbone crossbar
  constant c_WB_SLAVE_TDC_ONEWIRE     : integer := 0;  -- TDC mezzanine board UnidueID&Thermometer 1-wire
  constant c_WB_SLAVE_TDC_CORE_CONFIG : integer := 1;  -- TDC core configuration registers
  constant c_WB_SLAVE_TDC_EIC         : integer := 2;  -- TDC interrupts
  constant c_WB_SLAVE_TDC_I2C         : integer := 3;  -- TDC mezzanine board system EEPROM I2C
  constant c_WB_SLAVE_TDC_FIFO0       : integer := 4;  -- Access to TDC core FIFO for timestamps retrieval
  constant c_WB_SLAVE_TDC_DMA         : integer := 9;  -- Access to TDC core DMA controller

  -- Slave port on the wishbone crossbar
  constant c_NUM_WB_SLAVES : integer := 1;

  -- Wishbone master(s)
  constant c_WB_MASTER : integer := 0;

  -- sdb header address
  constant c_SDB_ADDRESS : t_wishbone_address := x"00000000";

  constant c_NUM_WB_MASTERS : integer := 10;

  -- WISHBONE crossbar layout
  constant c_INTERCONNECT_LAYOUT : t_sdb_record_array(c_NUM_WB_MASTERS-1 downto 0) :=
    (0 => f_sdb_embed_device(c_TDC_ONEWIRE_SDB_DEVICE, x"00001000"),
     1 => f_sdb_embed_device(c_TDC_CONFIG_SDB_DEVICE, x"00002000"),
     2 => f_sdb_embed_device(c_TDC_EIC_DEVICE, x"00003000"),
     3 => f_sdb_embed_device(c_I2C_SDB_DEVICE, x"00004000"),
     4 => f_sdb_embed_device(c_TDC_FIFO_SDB_DEVICE, x"00005000"),
     5 => f_sdb_embed_device(c_TDC_FIFO_SDB_DEVICE, x"00005100"),
     6 => f_sdb_embed_device(c_TDC_FIFO_SDB_DEVICE, x"00005200"),
     7 => f_sdb_embed_device(c_TDC_FIFO_SDB_DEVICE, x"00005300"),
     8 => f_sdb_embed_device(c_TDC_FIFO_SDB_DEVICE, x"00005400"),
     9 => f_sdb_embed_device(c_TDC_DMA_SDB_DEVICE, x"00006000")
     );

---------------------------------------------------------------------------------------------------
--                                            Signals                                            --
---------------------------------------------------------------------------------------------------
  -- resets
  signal general_rst_n, rst_ref_0_n : std_logic;
  -- Wishbone buse(s) from crossbar master port(s)
  signal cnx_master_out             : t_wishbone_master_out_array(c_NUM_WB_MASTERS-1 downto 0);
  signal cnx_master_in              : t_wishbone_master_in_array (c_NUM_WB_MASTERS-1 downto 0);

  -- WISHBONE addresses
  signal tdc_core_wb_adr           : std_logic_vector(31 downto 0);
  signal tdc_mem_wb_adr            : std_logic_vector(31 downto 0);
  -- 1-wire
  signal mezz_owr_en, mezz_owr_i   : std_logic_vector(0 downto 0);
  -- I2C
  signal sys_scl_in, sys_scl_out   : std_logic;
  signal sys_scl_oe_n, sys_sda_in  : std_logic;
  signal sys_sda_out, sys_sda_oe_n : std_logic;
  -- IRQ
  signal irq_tstamp                : std_logic;

  signal reg_to_wr, reg_from_wr : std_logic_vector(31 downto 0);
  signal wrabbit_utc_p          : std_logic;
  signal wrabbit_synched        : std_logic;

  signal irq_fifo, irq_dma : std_logic_vector(4 downto 0);

  signal timestamp                                       : t_tdc_timestamp_array(4 downto 0);
  signal timestamp_valid, timestamp_ready, timestamp_stb : std_logic_vector(4 downto 0);
  signal tdc_timestamp                                   : t_tdc_timestamp_array(4 downto 0);
  signal tdc_timestamp_valid, tdc_timestamp_ready        : std_logic_vector(4 downto 0);
  signal channel_enable                                  : std_logic_vector(4 downto 0);
  signal irq_threshold, irq_timeout                      : std_logic_vector(9 downto 0);
  signal tick_1ms                                        : std_logic;
  signal counter_1ms                                     : unsigned(17 downto 0);

  signal ts_offset  : t_tdc_timestamp_array(4 downto 0);
  signal reset_seq  : std_logic_vector(4 downto 0);
  signal raw_enable : std_logic_vector(4 downto 0);

  function f_wb_shift_address_word (w : t_wishbone_master_out) return t_wishbone_master_out is
    variable r : t_wishbone_master_out;
  begin
    r.adr := "00" & w.adr(31 downto 2);
    r.dat := w.dat;
    r.cyc := w.cyc;
    r.stb := w.stb;
    r.we  := w.we;
    r.sel := w.sel;
    return r;
  end f_wb_shift_address_word;

  signal regs_ow_out : t_TDC_OW_out_registers;
  signal regs_ow_in  : t_TDC_OW_in_registers;


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

  cmp_sdb_crossbar : xwb_sdb_crossbar
    generic map
    (g_num_masters => c_NUM_WB_SLAVES,
     g_num_slaves  => c_NUM_WB_MASTERS,
     g_registered  => true,
     g_wraparound  => true,
     g_layout      => c_INTERCONNECT_LAYOUT,
     g_sdb_addr    => c_SDB_ADDRESS)
    port map
    (clk_sys_i  => clk_sys_i,
     rst_n_i    => rst_sys_n_i,
     slave_i(0) => slave_i,
     slave_o(0) => slave_o,
     master_i   => cnx_master_in,
     master_o   => cnx_master_out);


---------------------------------------------------------------------------------------------------
--                                             TDC CORE                                          --
---------------------------------------------------------------------------------------------------
  cmp_tdc_core : entity work.fmc_tdc_core
    generic map
    (g_span              => g_span,
     g_width             => g_width,
     g_simulation        => g_simulation,
     g_with_dma_readout  => g_use_dma_readout,
     g_with_fifo_readout => true)
    port map
    (                                   -- clks, rst
      clk_tdc_i   => clk_tdc_i,
      rst_tdc_n_i => rst_tdc_n_i,
      clk_sys_i   => clk_sys_i,
      rst_sys_n_i => rst_sys_n_i,

      acam_refclk_r_edge_p_i => acam_refclk_r_edge_p_i,
      -- DAC configuration
      send_dac_word_p_o      => send_dac_word_p_o,
      dac_word_o             => dac_word_o,
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
      -- TDC board LEDs
      tdc_led_status_o       => tdc_led_status_o,
      tdc_led_trig1_o        => tdc_led_trig1_o,
      tdc_led_trig2_o        => tdc_led_trig2_o,
      tdc_led_trig3_o        => tdc_led_trig3_o,
      tdc_led_trig4_o        => tdc_led_trig4_o,
      tdc_led_trig5_o        => tdc_led_trig5_o,

      -- WR stuff
      wrabbit_tai_i        => wrabbit_utc_i,
      wrabbit_tai_p_i      => wrabbit_utc_p,
      wrabbit_synched_i    => wrabbit_synched,
      wrabbit_status_reg_i => reg_from_wr,
      wrabbit_ctrl_reg_o   => reg_to_wr,
      -- WISHBONE CSR for core configuration

      cfg_slave_i => f_wb_shift_address_word(cnx_master_out(c_WB_SLAVE_TDC_CORE_CONFIG)),
      cfg_slave_o => cnx_master_in(c_WB_SLAVE_TDC_CORE_CONFIG),

      timestamp_o       => tdc_timestamp,
      timestamp_valid_o => tdc_timestamp_valid,
      timestamp_ready_i => tdc_timestamp_ready,

      raw_enable_i => raw_enable,
      ts_offset_i  => ts_offset,
      reset_seq_i  => reset_seq,


      irq_threshold_o  => irq_threshold,
      irq_timeout_o    => irq_timeout,
      channel_enable_o => channel_enable
      );



  gen_use_fake_timestamps : if g_use_fake_timestamps_for_sim generate

    process(sim_timestamp_i, sim_timestamp_valid_i)
    begin

      timestamp_valid <= (others => '0');

      for i in 0 to 4 loop
        if unsigned(sim_timestamp_i.channel) = i then
          timestamp(i)       <= sim_timestamp_i;
          timestamp_valid(i) <= sim_timestamp_valid_i;
        end if;
      end loop;

    end process;
    timestamp_ready <= (others => '1');

  end generate gen_use_fake_timestamps;

  gen_use_real_timestamps : if not g_use_fake_timestamps_for_sim generate
    timestamp           <= tdc_timestamp;
    timestamp_valid     <= tdc_timestamp_valid;
    tdc_timestamp_ready <= timestamp_ready;
  end generate gen_use_real_timestamps;





  gen_fifos : for i in 0 to 4 generate

    U_TheFifo : entity work.timestamp_fifo
      generic map (
        g_channel => i)
      port map (
        clk_sys_i         => clk_sys_i,
        rst_sys_n_i       => rst_sys_n_i,
        slave_i           => cnx_master_out(c_WB_SLAVE_TDC_FIFO0 + i),
        slave_o           => cnx_master_in(c_WB_SLAVE_TDC_FIFO0 + i),
        irq_o             => irq_fifo(i),
        enable_i          => channel_enable(i),
        tick_i            => tick_1ms,
        irq_threshold_i   => irq_threshold,
        irq_timeout_i     => irq_timeout,
        timestamp_i       => timestamp,
        timestamp_valid_i => timestamp_stb,
        ts_offset_o       => ts_offset(i),
        reset_seq_o       => reset_seq(i),
        raw_enable_o      => raw_enable(i));

    timestamp_stb(i) <= timestamp_valid(i) and timestamp_ready(i);
  end generate gen_fifos;

  gen_with_dma_readout : if g_use_dma_readout generate
    U_DMA_Engine : entity work.tdc_dma_engine
      generic map (
        g_CLOCK_FREQ => 62500000)
      port map (
        clk_i      => clk_sys_i,
        rst_n_i    => rst_sys_n_i,
        enable_i   => channel_enable,
        raw_mode_i => raw_enable,
        ts_i       => timestamp,
        ts_valid_i => timestamp_valid,
        ts_ready_o => timestamp_ready,
        slave_i    => cnx_master_out(c_WB_SLAVE_TDC_DMA),
        slave_o    => cnx_master_in(c_WB_SLAVE_TDC_DMA),
        irq_o      => irq_dma,
        dma_wb_o   => dma_wb_o,
        dma_wb_i   => dma_wb_i);

  end generate gen_with_dma_readout;

  gen_without_dma : if not g_use_dma_readout generate
    irq_dma                                 <= (others => '0');
    cnx_master_in(c_WB_SLAVE_TDC_DMA).stall <= '0';
    cnx_master_in(c_WB_SLAVE_TDC_DMA).err   <= '0';
    cnx_master_in(c_WB_SLAVE_TDC_DMA).rty   <= '0';
    cnx_master_in(c_WB_SLAVE_TDC_DMA).ack   <= '1';
    timestamp_ready                         <= (others => '1');
  end generate gen_without_dma;


  p_gen_1ms_tick : process(clk_tdc_i)
  begin
    if rising_edge(clk_tdc_i) then
      if rst_tdc_n_i = '0' then
        tick_1ms    <= '0';
        counter_1ms <= (others => '0');
      else
        if counter_1ms = (125000000 / 1000) then
          tick_1ms    <= '1';
          counter_1ms <= (others => '0');
        else
          tick_1ms    <= '0';
          counter_1ms <= counter_1ms + 1;
        end if;
      end if;
    end if;
  end process;
---------------------------------------------------------------------------------------------------
--                                       WHITE RABBIT STUFF                                      --
--                           only synthesized if g_with_wrabbit_core is TRUE                     --
---------------------------------------------------------------------------------------------------
  cmp_wrabbit_synch : wrabbit_sync
    generic map
    (g_simulation        => g_simulation,
     g_with_wrabbit_core => g_with_wrabbit_core)
    port map
    (clk_sys_i                 => clk_sys_i,
     rst_n_sys_i               => rst_sys_n_i,
     clk_ref_i                 => clk_tdc_i,
     rst_n_ref_i               => rst_tdc_n_i,
     wrabbit_dac_value_i       => wrabbit_dac_value_i,
     wrabbit_dac_wr_p_i        => wrabbit_dac_wr_p_i,
     wrabbit_link_up_i         => wrabbit_link_up_i,
     wrabbit_time_valid_i      => wrabbit_time_valid_i,
     wrabbit_clk_aux_lock_en_o => wrabbit_clk_aux_lock_en_o,
     wrabbit_clk_aux_locked_i  => wrabbit_clk_aux_locked_i,
     wrabbit_clk_dmtd_locked_i => '1',           -- FIXME
     wrabbit_synched_o         => wrabbit_synched,
     wrabbit_reg_i             => reg_to_wr,     -- synced to 125MHz mezzanine
     wrabbit_reg_o             => reg_from_wr);  -- synced to 125MHz mezzanine

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  wrabbit_one_hz_pulse : process(clk_tdc_i)
  begin
    if rising_edge(clk_tdc_i) then
      if rst_tdc_n_i = '0' then
        wrabbit_utc_p <= '0';
      else
        if wrabbit_clk_aux_locked_i = '1' and g_with_wrabbit_core then
          if unsigned(wrabbit_cycles_i) = (unsigned(c_SYN_CLK_PERIOD)-3) then  -- so that the end of the pulse
                                        -- comes exactly upon the UTC change
            wrabbit_utc_p <= '1';
          else
            wrabbit_utc_p <= '0';
          end if;
        else
          wrabbit_utc_p <= '0';
        end if;
      end if;
    end if;
  end process;


---------------------------------------------------------------------------------------------------
--                        TDC Mezzanine Board UniqueID&Thermometer OneWire                       --
---------------------------------------------------------------------------------------------------

  U_Onewire : entity work.tdc_onewire_wb
    port map (
      rst_n_i   => rst_sys_n_i,
      clk_sys_i => clk_sys_i,
      slave_i   => cnx_master_out(c_WB_SLAVE_TDC_ONEWIRE),
      slave_o   => cnx_master_in(c_WB_SLAVE_TDC_ONEWIRE),
      regs_i    => regs_ow_in,
      regs_o    => regs_ow_out);

---------------------------------------------------------------------------------------------------
--                             WBGEN2 EMBEDDED INTERRUPTS CONTROLLER                             --
---------------------------------------------------------------------------------------------------
-- IRQ sources
-- 0 -> number of accumulated timestamps reached threshold
-- 1 -> number of seconds passed reached threshold and number of accumulated tstamps > 0
-- 2 -> ACAM error
  cmp_tdc_eic : entity work.tdc_eic
    port map
    (clk_sys_i       => clk_sys_i,
     rst_n_i         => rst_sys_n_i,
     wb_adr_i        => cnx_master_out(c_WB_SLAVE_TDC_EIC).adr(5 downto 2),
     wb_dat_i        => cnx_master_out(c_WB_SLAVE_TDC_EIC).dat,
     wb_dat_o        => cnx_master_in(c_WB_SLAVE_TDC_EIC).dat,
     wb_cyc_i        => cnx_master_out(c_WB_SLAVE_TDC_EIC).cyc,
     wb_sel_i        => cnx_master_out(c_WB_SLAVE_TDC_EIC).sel,
     wb_stb_i        => cnx_master_out(c_WB_SLAVE_TDC_EIC).stb,
     wb_we_i         => cnx_master_out(c_WB_SLAVE_TDC_EIC).we,
     wb_ack_o        => cnx_master_in(c_WB_SLAVE_TDC_EIC).ack,
     wb_stall_o      => cnx_master_in(c_WB_SLAVE_TDC_EIC).stall,
     wb_int_o        => wb_irq_o,
     irq_tdc_fifo1_i => irq_fifo(0),
     irq_tdc_fifo2_i => irq_fifo(1),
     irq_tdc_fifo3_i => irq_fifo(2),
     irq_tdc_fifo4_i => irq_fifo(3),
     irq_tdc_fifo5_i => irq_fifo(4),
     irq_tdc_dma1_i  => irq_dma(0),
     irq_tdc_dma2_i  => irq_dma(1),
     irq_tdc_dma3_i  => irq_dma(2),
     irq_tdc_dma4_i  => irq_dma(3),
     irq_tdc_dma5_i  => irq_dma(4)
     );

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Unused wishbone signals
  cnx_master_in(c_WB_SLAVE_TDC_EIC).err <= '0';
  cnx_master_in(c_WB_SLAVE_TDC_EIC).rty <= '0';


---------------------------------------------------------------------------------------------------
--                                TDC Mezzanine Board EEPROM I2C                                 --
---------------------------------------------------------------------------------------------------
  cmp_I2C_master : xwb_i2c_master
    generic map
    (g_interface_mode      => PIPELINED,
     g_address_granularity => BYTE)
    port map
    (clk_sys_i       => clk_sys_i,
     rst_n_i         => rst_sys_n_i,
     slave_i         => cnx_master_out(c_WB_SLAVE_TDC_I2C),
     slave_o         => cnx_master_in(c_WB_SLAVE_TDC_I2C),
     desc_o          => open,
     scl_pad_i(0)    => i2c_scl_i,
     scl_pad_o(0)    => sys_scl_out,
     scl_padoen_o(0) => sys_scl_oe_n,
     sda_pad_i(0)    => i2c_sda_i,
     sda_pad_o(0)    => sys_sda_out,
     sda_padoen_o(0) => sys_sda_oe_n);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  i2c_sda_oen_o <= sys_sda_oe_n;
  i2c_sda_o     <= sys_sda_out;
  i2c_scl_oen_o <= sys_scl_oe_n;
  i2c_scl_o     <= sys_scl_out;

  U_OnewireIF : gc_ds182x_interface
    generic map (
      g_CLOCK_FREQ_KHZ   => 62500,
      g_USE_INTERNAL_PPS => true)
    port map (
      clk_i              => clk_sys_i,
      rst_n_i            => rst_sys_n_i,
      pps_p_i            => '0',
      onewire_b          => onewire_b,
      id_o(63 downto 32) => regs_ow_in.tdc_ow_id_h_i,
      id_o(31 downto 0)  => regs_ow_in.tdc_ow_id_l_i,
      temper_o           => regs_ow_in.tdc_ow_temp_i,
      id_read_o          => regs_ow_in.tdc_ow_csr_valid_i);

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
