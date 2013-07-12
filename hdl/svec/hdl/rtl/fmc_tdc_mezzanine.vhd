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
-- Description  Combines the TDC core with I2C and OneWire interface for the EEPROM and the       |
--              UniqueID&Thermetec chips on the TDC mezzanine board.                              |
--                                                                                                |
-- Authors      Gonzalo Penacoba  (Gonzalo.Penacoba@cern.ch)                                      |
--              Evangelia Gousiou (Evangelia.Gousiou@cern.ch)                                     |
-- Date         07/2013                                                                           |
-- Version      v1                                                                                |
-- Depends on                                                                                     |
--                                                                                                |
----------------                                                                                  |
-- Last changes                                                                                   |
--     07/2013  v1  EG  First version                                                             |
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


--=================================================================================================
--                                Entity declaration for fmc_tdc_mezzanine
--=================================================================================================
entity fmc_tdc_mezzanine is
  generic
    (g_span              : integer := 32;
     g_width             : integer := 32;
     values_for_simul    : boolean := FALSE);
  port
    (-- TDC core
     clk_125m_i          : in    std_logic;
     rst_i               : in    std_logic;
     acam_refclk_r_edge_p_i: in  std_logic;
     send_dac_word_p_o   : out   std_logic;
     dac_word_o          : out   std_logic_vector(23 downto 0);
     start_from_fpga_o   : out   std_logic;
     err_flag_i          : in    std_logic;
     int_flag_i          : in    std_logic;
     start_dis_o         : out   std_logic;
     stop_dis_o          : out   std_logic;
     data_bus_io         : inout std_logic_vector(27 downto 0);
     address_o           : out   std_logic_vector(3 downto 0);
     cs_n_o              : out   std_logic;
     oe_n_o              : out   std_logic;
     rd_n_o              : out   std_logic;
     wr_n_o              : out   std_logic;
     ef1_i               : in    std_logic;
     ef2_i               : in    std_logic;
     tdc_in_fpga_1_i     : in    std_logic;
     tdc_in_fpga_2_i     : in    std_logic;
     tdc_in_fpga_3_i     : in    std_logic;
     tdc_in_fpga_4_i     : in    std_logic;
     tdc_in_fpga_5_i     : in    std_logic;
     enable_inputs_o     : out   std_logic;
     term_en_1_o         : out   std_logic;
     term_en_2_o         : out   std_logic;
     term_en_3_o         : out   std_logic;
     term_en_4_o         : out   std_logic;
     term_en_5_o         : out   std_logic;
     tdc_led_status_o    : out   std_logic;
     tdc_led_trig1_o     : out   std_logic;
     tdc_led_trig2_o     : out   std_logic;
     tdc_led_trig3_o     : out   std_logic;
     tdc_led_trig4_o     : out   std_logic;
     tdc_led_trig5_o     : out   std_logic;
     irq_tstamp_p_o      : out   std_logic;
     irq_time_p_o        : out   std_logic;
     irq_acam_err_p_o    : out   std_logic;
     -- WISHBONE interface with the CNUM/VME_core
     wb_tdc_mezz_adr_i   : in    std_logic_vector(31 downto 0);
     wb_tdc_mezz_dat_i   : in    std_logic_vector(31 downto 0);
     wb_tdc_mezz_dat_o   : out   std_logic_vector(31 downto 0);
     wb_tdc_mezz_cyc_i   : in    std_logic;
     wb_tdc_mezz_sel_i   : in    std_logic_vector(3 downto 0);
     wb_tdc_mezz_stb_i   : in    std_logic;
     wb_tdc_mezz_we_i    : in    std_logic;
     wb_tdc_mezz_ack_o   : out   std_logic;
     wb_tdc_mezz_stall_o : out   std_logic;
     -- I2C EEPROM interface
     sys_scl_b           : inout std_logic;
     sys_sda_b           : inout std_logic;
     -- 1-wire UniqueID&Thermometer interface
     mezz_one_wire_b     : inout std_logic);
end fmc_tdc_mezzanine;


--=================================================================================================
--                                    architecture declaration
--=================================================================================================
architecture rtl of fmc_tdc_mezzanine is

---------------------------------------------------------------------------------------------------
--                                           CONSTANTS                                           --
---------------------------------------------------------------------------------------------------
  -- Note: All address in sdb and crossbar are BYTE addresses!
  -- Master ports on the wishbone crossbar
  constant c_NUM_WB_MASTERS           : integer := 5;
  constant c_WB_SLAVE_TDC_CORE_CONFIG : integer := 0;  -- TDC core configuration registers
  constant c_WB_SLAVE_TDC_ONEWIRE     : integer := 1;  -- TDC mezzanine board UnidueID&Thermometer 1-wire
  constant c_WB_SLAVE_TSTAMP_MEM      : integer := 2;  -- Access to TDC core timestamps memory
  constant c_WB_SLAVE_TDC_SYS_I2C     : integer := 3;  -- TDC mezzanine board system EEPROM I2C
  constant c_WB_SLAVE_DUMMY           : integer := 4;  -- Dummy for debugging


  -- Slave port on the wishbone crossbar
  constant c_NUM_WB_SLAVES            : integer := 1;
  -- Wishbone master(s)
  constant c_WB_MASTER                : integer := 0;
  -- sdb header address
  constant c_SDB_ADDRESS              : t_wishbone_address := x"00000000";
  -- WISHBONE crossbar layout
  constant c_INTERCONNECT_LAYOUT : t_sdb_record_array(4 downto 0) :=
    (0 => f_sdb_embed_device(c_TDC_CONFIG_SDB_DEVICE, x"00001000"),
     1 => f_sdb_embed_device(c_ONEWIRE_SDB_DEVICE,    x"00001100"),
     2 => f_sdb_embed_device(c_TDC_MEM_SDB_DEVICE,    x"00001200"),
     3 => f_sdb_embed_device(c_I2C_SDB_DEVICE,        x"00001300"),
     4 => f_sdb_embed_device(c_TDC_CONFIG_SDB_DEVICE, x"00001400"));

---------------------------------------------------------------------------------------------------
--                                            Signals                                            --
---------------------------------------------------------------------------------------------------
  -- resets
  signal general_rst_n               : std_logic;
  -- Wishbone buse(s) from crossbar master port(s)
  signal cnx_master_out              : t_wishbone_master_out_array(c_NUM_WB_MASTERS-1 downto 0);
  signal cnx_master_in               : t_wishbone_master_in_array (c_NUM_WB_MASTERS-1 downto 0);
  -- Wishbone buse(s) to crossbar slave port(s)
  signal cnx_slave_out               : t_wishbone_slave_out_array(c_NUM_WB_SLAVES-1 downto 0);
  signal cnx_slave_in                : t_wishbone_slave_in_array (c_NUM_WB_SLAVES-1 downto 0);
  -- WISHBONE addresses
  signal tdc_core_wb_adr             : std_logic_vector(31 downto 0);
  signal tdc_mem_wb_adr, dummy_core_wb_adr              : std_logic_vector(31 downto 0);
  -- 1-wire
  signal mezz_owr_en, mezz_owr_i     : std_logic_vector(0 downto 0);
  -- I2C
  signal sys_scl_in, sys_scl_out     : std_logic;
  signal sys_scl_oe_n, sys_sda_in    : std_logic;
  signal sys_sda_out, sys_sda_oe_n   : std_logic;
  -- dummy
  signal dummy_reg_1                 : std_logic_vector(31 downto 0) := x"F000000D";


--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

  general_rst_n <= not(rst_i);
---------------------------------------------------------------------------------------------------
--                                     CSR WISHBONE CROSSBAR                                     --
---------------------------------------------------------------------------------------------------
-- CSR wishbone address decoder
--   0x04000 -> TDC memory for timestamps retrieval
--   0x05000 -> TDC core configuration
--   0x05800 -> TDC mezzanine board system EEPROM I2C
--   0x05C00 -> TDC mezzanine board UnidueID&Thermometer 1-wire

  cmp_sdb_crossbar : xwb_sdb_crossbar
  generic map
    (g_num_masters => c_NUM_WB_SLAVES,
     g_num_slaves  => c_NUM_WB_MASTERS,
     g_registered  => true,
     g_wraparound  => true,
     g_layout      => c_INTERCONNECT_LAYOUT,
     g_sdb_addr    => c_SDB_ADDRESS)
  port map
    (clk_sys_i     => clk_125m_i,
     rst_n_i       => general_rst_n,
     slave_i       => cnx_slave_in,
     slave_o       => cnx_slave_out,
     master_i      => cnx_master_in,
     master_o      => cnx_master_out);
  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Connect crossbar slave port to entity port
  cnx_slave_in(c_WB_MASTER).adr <= wb_tdc_mezz_adr_i;
  cnx_slave_in(c_WB_MASTER).dat <= wb_tdc_mezz_dat_i;
  cnx_slave_in(c_WB_MASTER).sel <= wb_tdc_mezz_sel_i;
  cnx_slave_in(c_WB_MASTER).stb <= wb_tdc_mezz_stb_i;
  cnx_slave_in(c_WB_MASTER).we  <= wb_tdc_mezz_we_i;
  cnx_slave_in(c_WB_MASTER).cyc <= wb_tdc_mezz_cyc_i;

  wb_tdc_mezz_dat_o   <= cnx_slave_out(c_WB_MASTER).dat;
  wb_tdc_mezz_ack_o   <= cnx_slave_out(c_WB_MASTER).ack;
  wb_tdc_mezz_stall_o <= cnx_slave_out(c_WB_MASTER).stall;

---------------------------------------------------------------------------------------------------
--                                             TDC CORE                                          --
---------------------------------------------------------------------------------------------------
  tdc_core: fmc_tdc_core
  generic map
    (g_span                  => g_span,
     g_width                 => g_width,
     values_for_simul        => FALSE)
  port map
    (-- clocks, resets, dac
     clk_125m_i              => clk_125m_i,
     rst_i                   => rst_i,
     acam_refclk_r_edge_p_i  => acam_refclk_r_edge_p_i,
     send_dac_word_p_o       => send_dac_word_p_o,
     dac_word_o              => dac_word_o,
     -- ACAM
     start_from_fpga_o       => start_from_fpga_o,
     err_flag_i              => err_flag_i,
     int_flag_i              => int_flag_i,
     start_dis_o             => start_dis_o,
     stop_dis_o              => stop_dis_o,
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
     irq_tstamp_p_o          => irq_tstamp_p_o,
     irq_time_p_o            => irq_time_p_o,
     irq_acam_err_p_o        => irq_acam_err_p_o,
     -- WISHBONE CSR for TDC core and ACAM configuration
     tdc_config_wb_adr_i     => tdc_core_wb_adr,
     tdc_config_wb_dat_i     => cnx_master_out(c_WB_SLAVE_TDC_CORE_CONFIG).dat,
     tdc_config_wb_stb_i     => cnx_master_out(c_WB_SLAVE_TDC_CORE_CONFIG).stb,
     tdc_config_wb_we_i      => cnx_master_out(c_WB_SLAVE_TDC_CORE_CONFIG).we,
     tdc_config_wb_cyc_i     => cnx_master_out(c_WB_SLAVE_TDC_CORE_CONFIG).cyc,
     tdc_config_wb_dat_o     => cnx_master_in(c_WB_SLAVE_TDC_CORE_CONFIG).dat,
     tdc_config_wb_ack_o     => cnx_master_in(c_WB_SLAVE_TDC_CORE_CONFIG).ack,
     -- WISHBONE DMA for timestamps transfer
     tdc_mem_wb_adr_i        => tdc_mem_wb_adr,
     tdc_mem_wb_dat_i        => cnx_master_out(c_WB_SLAVE_TSTAMP_MEM).dat,
     tdc_mem_wb_stb_i        => cnx_master_out(c_WB_SLAVE_TSTAMP_MEM).stb,
     tdc_mem_wb_we_i         => cnx_master_out(c_WB_SLAVE_TSTAMP_MEM).we,
     tdc_mem_wb_cyc_i        => cnx_master_out(c_WB_SLAVE_TSTAMP_MEM).cyc,
     tdc_mem_wb_ack_o        => cnx_master_in(c_WB_SLAVE_TSTAMP_MEM).ack,
     tdc_mem_wb_dat_o        => cnx_master_in(c_WB_SLAVE_TSTAMP_MEM).dat,
     tdc_mem_wb_stall_o      => cnx_master_in(c_WB_SLAVE_TSTAMP_MEM).stall);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Convert byte address into word address
  tdc_core_wb_adr <= "00" & cnx_master_out(c_WB_SLAVE_TDC_CORE_CONFIG).adr(31 downto 2);
  tdc_mem_wb_adr  <= "00" & cnx_master_out(c_WB_SLAVE_TSTAMP_MEM).adr(31 downto 2);

  -- Unused wishbone signals
  cnx_master_in(c_WB_SLAVE_TDC_CORE_CONFIG).err   <= '0';
  cnx_master_in(c_WB_SLAVE_TDC_CORE_CONFIG).rty   <= '0';
  cnx_master_in(c_WB_SLAVE_TDC_CORE_CONFIG).stall <= '0';
  cnx_master_in(c_WB_SLAVE_TDC_CORE_CONFIG).int   <= '0';
  cnx_master_in(c_WB_SLAVE_TSTAMP_MEM).err        <= '0';
  cnx_master_in(c_WB_SLAVE_TSTAMP_MEM).rty        <= '0';
  cnx_master_in(c_WB_SLAVE_TSTAMP_MEM).stall      <= '0';
  cnx_master_in(c_WB_SLAVE_TSTAMP_MEM).int        <= '0';



---------------------------------------------------------------------------------------------------
--                                TDC Mezzanine Board EEPROM I2C                                 --
---------------------------------------------------------------------------------------------------
  mezzanine_I2C_master_EEPROM : xwb_i2c_master
  generic map
    (g_interface_mode      => PIPELINED,
     g_address_granularity => BYTE)
  port map
    (clk_sys_i    => clk_125m_i,
     rst_n_i      => general_rst_n,
     slave_i      => cnx_master_out(c_WB_SLAVE_TDC_SYS_I2C),
     slave_o      => cnx_master_in(c_WB_SLAVE_TDC_SYS_I2C),
     desc_o       => open,
     scl_pad_i    => sys_scl_in,
     scl_pad_o    => sys_scl_out,
     scl_padoen_o => sys_scl_oe_n,
     sda_pad_i    => sys_sda_in,
     sda_pad_o    => sys_sda_out,
     sda_padoen_o => sys_sda_oe_n);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  -- Tri-state buffer for SDA and SCL
  sys_scl_b  <= sys_scl_out when sys_scl_oe_n = '0' else 'Z';
  sys_scl_in <= sys_scl_b;
  sys_sda_b  <= sys_sda_out when sys_sda_oe_n = '0' else 'Z';
  sys_sda_in <= sys_sda_b;


---------------------------------------------------------------------------------------------------
--                        TDC Mezzanine Board UniqueID&Thermometer OneWite                       --
---------------------------------------------------------------------------------------------------
  cmp_fmc_onewire : xwb_onewire_master
  generic map
    (g_interface_mode      => PIPELINED,
     g_address_granularity => BYTE,
     g_num_ports           => 1,
     g_ow_btp_normal       => "5.0",
     g_ow_btp_overdrive    => "1.0")
  port map
    (clk_sys_i   => clk_125m_i,
     rst_n_i     => general_rst_n,
     slave_i     => cnx_master_out(c_WB_SLAVE_TDC_ONEWIRE),
     slave_o     => cnx_master_in(c_WB_SLAVE_TDC_ONEWIRE),
     desc_o      => open,
     owr_pwren_o => open,
     owr_en_o    => mezz_owr_en,
     owr_i       => mezz_owr_i);

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  mezz_one_wire_b <= '0' when mezz_owr_en(0) = '1' else 'Z';
  mezz_owr_i(0)   <= mezz_one_wire_b;


---------------------------------------------------------------------------------------------------
--                                             Dummy 0                                           --
---------------------------------------------------------------------------------------------------
--Note: c_WB_SLAVE_DUMMY = 0
--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  dummy0_ack_generator: process (clk_125m_i)
  begin
    if rising_edge (clk_125m_i) then
      if general_rst_n = '0' then
        cnx_master_in(c_WB_SLAVE_DUMMY).ack <= '0';
      else
        cnx_master_in(c_WB_SLAVE_DUMMY).ack <= cnx_master_out(c_WB_SLAVE_DUMMY).stb and cnx_master_out(c_WB_SLAVE_DUMMY).cyc;
      end if;
    end if;
  end process;

--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  dummy0: process (clk_125m_i)
  begin
    if rising_edge (clk_125m_i) then
      if general_rst_n = '0' then
        dummy_reg_1 <= x"F000000D";

      elsif cnx_master_out(c_WB_SLAVE_DUMMY).cyc = '1' and cnx_master_out(c_WB_SLAVE_DUMMY).stb = '1' and cnx_master_out(c_WB_SLAVE_DUMMY).we = '1' then

        if dummy_core_wb_adr(7 downto 0) = x"00" then
          dummy_reg_1 <= cnx_master_out(c_WB_SLAVE_DUMMY).dat;
        end if;

      elsif cnx_master_out(c_WB_SLAVE_DUMMY).cyc = '1' and cnx_master_out(c_WB_SLAVE_DUMMY).stb = '1' and cnx_master_out(c_WB_SLAVE_DUMMY).we = '0' then

        if dummy_core_wb_adr(7 downto 0)  = x"00" then
          cnx_master_in(c_WB_SLAVE_DUMMY).dat <= dummy_reg_1;
        elsif dummy_core_wb_adr(7 downto 0)  = x"01" then
          cnx_master_in(c_WB_SLAVE_DUMMY).dat <= wb_tdc_mezz_adr_i;
        else
          cnx_master_in(c_WB_SLAVE_DUMMY).dat <= dummy_core_wb_adr;
        end if;

      end if;
    end if;
  end process;

  dummy_core_wb_adr                     <= cnx_master_out(c_WB_SLAVE_DUMMY).adr;
  cnx_master_in(c_WB_SLAVE_DUMMY).err   <= '0';
  cnx_master_in(c_WB_SLAVE_DUMMY).rty   <= '0';
  cnx_master_in(c_WB_SLAVE_DUMMY).stall <= '0';
  cnx_master_in(c_WB_SLAVE_DUMMY).int   <= '0';
    
end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------