---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for Mini NIC for WhiteRabbit
---------------------------------------------------------------------------------------
-- File           : minic_wb_slave.vhd
-- Author         : auto-generated by wbgen2 from mini_nic.wb
-- Created        : Thu Mar  7 14:45:52 2013
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE mini_nic.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wbgen2_pkg.all;

use work.minic_wbgen2_pkg.all;


entity minic_wb_slave is
  port (
    rst_n_i                                  : in     std_logic;
    clk_sys_i                                : in     std_logic;
    wb_adr_i                                 : in     std_logic_vector(4 downto 0);
    wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    wb_stall_o                               : out    std_logic;
    wb_int_o                                 : out    std_logic;
    tx_ts_read_ack_o                         : out    std_logic;
    irq_tx_i                                 : in     std_logic;
    irq_tx_ack_o                             : out    std_logic;
    irq_tx_mask_o                            : out    std_logic;
    irq_rx_i                                 : in     std_logic;
    irq_rx_ack_o                             : out    std_logic;
    irq_txts_i                               : in     std_logic;
    regs_i                                   : in     t_minic_in_registers;
    regs_o                                   : out    t_minic_out_registers
  );
end minic_wb_slave;

architecture syn of minic_wb_slave is

signal minic_mcr_tx_start_dly0                  : std_logic      ;
signal minic_mcr_tx_start_int                   : std_logic      ;
signal minic_mcr_rx_en_int                      : std_logic      ;
signal minic_mcr_rx_class_int                   : std_logic_vector(7 downto 0);
signal minic_mprot_lo_int                       : std_logic_vector(15 downto 0);
signal minic_mprot_hi_int                       : std_logic_vector(15 downto 0);
signal eic_idr_int                              : std_logic_vector(2 downto 0);
signal eic_idr_write_int                        : std_logic      ;
signal eic_ier_int                              : std_logic_vector(2 downto 0);
signal eic_ier_write_int                        : std_logic      ;
signal eic_imr_int                              : std_logic_vector(2 downto 0);
signal eic_isr_clear_int                        : std_logic_vector(2 downto 0);
signal eic_isr_status_int                       : std_logic_vector(2 downto 0);
signal eic_irq_ack_int                          : std_logic_vector(2 downto 0);
signal eic_isr_write_int                        : std_logic      ;
signal irq_inputs_vector_int                    : std_logic_vector(2 downto 0);
signal ack_sreg                                 : std_logic_vector(9 downto 0);
signal rddata_reg                               : std_logic_vector(31 downto 0);
signal wrdata_reg                               : std_logic_vector(31 downto 0);
signal bwsel_reg                                : std_logic_vector(3 downto 0);
signal rwaddr_reg                               : std_logic_vector(4 downto 0);
signal ack_in_progress                          : std_logic      ;
signal wr_int                                   : std_logic      ;
signal rd_int                                   : std_logic      ;
signal allones                                  : std_logic_vector(31 downto 0);
signal allzeros                                 : std_logic_vector(31 downto 0);

begin
-- Some internal signals assignments. For (foreseen) compatibility with other bus standards.
  wrdata_reg <= wb_dat_i;
  bwsel_reg <= wb_sel_i;
  rd_int <= wb_cyc_i and (wb_stb_i and (not wb_we_i));
  wr_int <= wb_cyc_i and (wb_stb_i and wb_we_i);
  allones <= (others => '1');
  allzeros <= (others => '0');
-- 
-- Main register bank access process.
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      ack_sreg <= "0000000000";
      ack_in_progress <= '0';
      rddata_reg <= "00000000000000000000000000000000";
      minic_mcr_tx_start_int <= '0';
      minic_mcr_rx_en_int <= '0';
      minic_mcr_rx_class_int <= "00000000";
      regs_o.tx_addr_load_o <= '0';
      regs_o.rx_addr_load_o <= '0';
      regs_o.rx_size_load_o <= '0';
      regs_o.rx_avail_load_o <= '0';
      tx_ts_read_ack_o <= '0';
      minic_mprot_lo_int <= "0000000000000000";
      minic_mprot_hi_int <= "0000000000000000";
      eic_idr_write_int <= '0';
      eic_ier_write_int <= '0';
      eic_isr_write_int <= '0';
    elsif rising_edge(clk_sys_i) then
-- advance the ACK generator shift register
      ack_sreg(8 downto 0) <= ack_sreg(9 downto 1);
      ack_sreg(9) <= '0';
      if (ack_in_progress = '1') then
        if (ack_sreg(0) = '1') then
          minic_mcr_tx_start_int <= '0';
          regs_o.tx_addr_load_o <= '0';
          regs_o.rx_addr_load_o <= '0';
          regs_o.rx_size_load_o <= '0';
          regs_o.rx_avail_load_o <= '0';
          tx_ts_read_ack_o <= '0';
          eic_idr_write_int <= '0';
          eic_ier_write_int <= '0';
          eic_isr_write_int <= '0';
          ack_in_progress <= '0';
        else
          regs_o.tx_addr_load_o <= '0';
          regs_o.rx_addr_load_o <= '0';
          regs_o.rx_size_load_o <= '0';
          regs_o.rx_avail_load_o <= '0';
        end if;
      else
        if ((wb_cyc_i = '1') and (wb_stb_i = '1')) then
          case rwaddr_reg(4 downto 0) is
          when "00000" => 
            if (wb_we_i = '1') then
              minic_mcr_tx_start_int <= wrdata_reg(0);
              minic_mcr_rx_en_int <= wrdata_reg(10);
              minic_mcr_rx_class_int <= wrdata_reg(23 downto 16);
            end if;
            rddata_reg(0) <= '0';
            rddata_reg(1) <= regs_i.mcr_tx_idle_i;
            rddata_reg(2) <= regs_i.mcr_tx_error_i;
            rddata_reg(8) <= regs_i.mcr_rx_ready_i;
            rddata_reg(9) <= regs_i.mcr_rx_full_i;
            rddata_reg(10) <= minic_mcr_rx_en_int;
            rddata_reg(11) <= regs_i.mcr_tx_ts_ready_i;
            rddata_reg(23 downto 16) <= minic_mcr_rx_class_int;
            rddata_reg(3) <= 'X';
            rddata_reg(4) <= 'X';
            rddata_reg(5) <= 'X';
            rddata_reg(6) <= 'X';
            rddata_reg(7) <= 'X';
            rddata_reg(12) <= 'X';
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(2) <= '1';
            ack_in_progress <= '1';
          when "00001" => 
            if (wb_we_i = '1') then
              regs_o.tx_addr_load_o <= '1';
            end if;
            rddata_reg(23 downto 0) <= regs_i.tx_addr_i;
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00010" => 
            if (wb_we_i = '1') then
              regs_o.rx_addr_load_o <= '1';
            end if;
            rddata_reg(23 downto 0) <= regs_i.rx_addr_i;
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00011" => 
            if (wb_we_i = '1') then
              regs_o.rx_size_load_o <= '1';
            end if;
            rddata_reg(23 downto 0) <= regs_i.rx_size_i;
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00100" => 
            if (wb_we_i = '1') then
              regs_o.rx_avail_load_o <= '1';
            end if;
            rddata_reg(23 downto 0) <= regs_i.rx_avail_i;
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00101" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(0) <= regs_i.tsr0_valid_i;
            rddata_reg(5 downto 1) <= regs_i.tsr0_pid_i;
            rddata_reg(21 downto 6) <= regs_i.tsr0_fid_i;
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00110" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(31 downto 0) <= regs_i.tsr1_tsval_i;
            tx_ts_read_ack_o <= '1';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "00111" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(23 downto 0) <= regs_i.dbgr_irq_cnt_i;
            rddata_reg(24) <= regs_i.dbgr_wb_irq_val_i;
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "01000" => 
            if (wb_we_i = '1') then
              minic_mprot_lo_int <= wrdata_reg(15 downto 0);
              minic_mprot_hi_int <= wrdata_reg(31 downto 16);
            end if;
            rddata_reg(15 downto 0) <= minic_mprot_lo_int;
            rddata_reg(31 downto 16) <= minic_mprot_hi_int;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "10000" => 
            if (wb_we_i = '1') then
              eic_idr_write_int <= '1';
            end if;
            rddata_reg(0) <= 'X';
            rddata_reg(1) <= 'X';
            rddata_reg(2) <= 'X';
            rddata_reg(3) <= 'X';
            rddata_reg(4) <= 'X';
            rddata_reg(5) <= 'X';
            rddata_reg(6) <= 'X';
            rddata_reg(7) <= 'X';
            rddata_reg(8) <= 'X';
            rddata_reg(9) <= 'X';
            rddata_reg(10) <= 'X';
            rddata_reg(11) <= 'X';
            rddata_reg(12) <= 'X';
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
            rddata_reg(16) <= 'X';
            rddata_reg(17) <= 'X';
            rddata_reg(18) <= 'X';
            rddata_reg(19) <= 'X';
            rddata_reg(20) <= 'X';
            rddata_reg(21) <= 'X';
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "10001" => 
            if (wb_we_i = '1') then
              eic_ier_write_int <= '1';
            end if;
            rddata_reg(0) <= 'X';
            rddata_reg(1) <= 'X';
            rddata_reg(2) <= 'X';
            rddata_reg(3) <= 'X';
            rddata_reg(4) <= 'X';
            rddata_reg(5) <= 'X';
            rddata_reg(6) <= 'X';
            rddata_reg(7) <= 'X';
            rddata_reg(8) <= 'X';
            rddata_reg(9) <= 'X';
            rddata_reg(10) <= 'X';
            rddata_reg(11) <= 'X';
            rddata_reg(12) <= 'X';
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
            rddata_reg(16) <= 'X';
            rddata_reg(17) <= 'X';
            rddata_reg(18) <= 'X';
            rddata_reg(19) <= 'X';
            rddata_reg(20) <= 'X';
            rddata_reg(21) <= 'X';
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "10010" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(2 downto 0) <= eic_imr_int(2 downto 0);
            rddata_reg(3) <= 'X';
            rddata_reg(4) <= 'X';
            rddata_reg(5) <= 'X';
            rddata_reg(6) <= 'X';
            rddata_reg(7) <= 'X';
            rddata_reg(8) <= 'X';
            rddata_reg(9) <= 'X';
            rddata_reg(10) <= 'X';
            rddata_reg(11) <= 'X';
            rddata_reg(12) <= 'X';
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
            rddata_reg(16) <= 'X';
            rddata_reg(17) <= 'X';
            rddata_reg(18) <= 'X';
            rddata_reg(19) <= 'X';
            rddata_reg(20) <= 'X';
            rddata_reg(21) <= 'X';
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "10011" => 
            if (wb_we_i = '1') then
              eic_isr_write_int <= '1';
            end if;
            rddata_reg(2 downto 0) <= eic_isr_status_int(2 downto 0);
            rddata_reg(3) <= 'X';
            rddata_reg(4) <= 'X';
            rddata_reg(5) <= 'X';
            rddata_reg(6) <= 'X';
            rddata_reg(7) <= 'X';
            rddata_reg(8) <= 'X';
            rddata_reg(9) <= 'X';
            rddata_reg(10) <= 'X';
            rddata_reg(11) <= 'X';
            rddata_reg(12) <= 'X';
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
            rddata_reg(16) <= 'X';
            rddata_reg(17) <= 'X';
            rddata_reg(18) <= 'X';
            rddata_reg(19) <= 'X';
            rddata_reg(20) <= 'X';
            rddata_reg(21) <= 'X';
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when others =>
-- prevent the slave from hanging the bus on invalid address
            ack_in_progress <= '1';
            ack_sreg(0) <= '1';
          end case;
        end if;
      end if;
    end if;
  end process;
  
  
-- Drive the data output bus
  wb_dat_o <= rddata_reg;
-- TX DMA start
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      minic_mcr_tx_start_dly0 <= '0';
      regs_o.mcr_tx_start_o <= '0';
    elsif rising_edge(clk_sys_i) then
      minic_mcr_tx_start_dly0 <= minic_mcr_tx_start_int;
      regs_o.mcr_tx_start_o <= minic_mcr_tx_start_int and (not minic_mcr_tx_start_dly0);
    end if;
  end process;
  
  
-- TX DMA idle
-- TX DMA error
-- RX DMA ready
-- RX DMA buffer full
-- RX DMA enable
  regs_o.mcr_rx_en_o <= minic_mcr_rx_en_int;
-- TX TS ready
-- RX Accepted Packet Classes
  regs_o.mcr_rx_class_o <= minic_mcr_rx_class_int;
-- TX DMA buffer address
  regs_o.tx_addr_o <= wrdata_reg(23 downto 0);
-- RX DMA buffer address
  regs_o.rx_addr_o <= wrdata_reg(23 downto 0);
-- RX available words
  regs_o.rx_size_o <= wrdata_reg(23 downto 0);
-- RX available words
  regs_o.rx_avail_o <= wrdata_reg(23 downto 0);
-- Timestamp valid
-- Port ID
-- Frame ID
-- Timestamp value
-- interrupt counter
-- status of wb_irq_o line
-- address range lo
  regs_o.mprot_lo_o <= minic_mprot_lo_int;
-- address range hi
  regs_o.mprot_hi_o <= minic_mprot_hi_int;
-- extra code for reg/fifo/mem: Interrupt disable register
  eic_idr_int(2 downto 0) <= wrdata_reg(2 downto 0);
-- extra code for reg/fifo/mem: Interrupt enable register
  eic_ier_int(2 downto 0) <= wrdata_reg(2 downto 0);
-- extra code for reg/fifo/mem: Interrupt status register
  eic_isr_clear_int(2 downto 0) <= wrdata_reg(2 downto 0);
-- extra code for reg/fifo/mem: IRQ_CONTROLLER
  eic_irq_controller_inst : wbgen2_eic
    generic map (
      g_num_interrupts     => 3,
      g_irq00_mode         => 3,
      g_irq01_mode         => 3,
      g_irq02_mode         => 3,
      g_irq03_mode         => 0,
      g_irq04_mode         => 0,
      g_irq05_mode         => 0,
      g_irq06_mode         => 0,
      g_irq07_mode         => 0,
      g_irq08_mode         => 0,
      g_irq09_mode         => 0,
      g_irq0a_mode         => 0,
      g_irq0b_mode         => 0,
      g_irq0c_mode         => 0,
      g_irq0d_mode         => 0,
      g_irq0e_mode         => 0,
      g_irq0f_mode         => 0,
      g_irq10_mode         => 0,
      g_irq11_mode         => 0,
      g_irq12_mode         => 0,
      g_irq13_mode         => 0,
      g_irq14_mode         => 0,
      g_irq15_mode         => 0,
      g_irq16_mode         => 0,
      g_irq17_mode         => 0,
      g_irq18_mode         => 0,
      g_irq19_mode         => 0,
      g_irq1a_mode         => 0,
      g_irq1b_mode         => 0,
      g_irq1c_mode         => 0,
      g_irq1d_mode         => 0,
      g_irq1e_mode         => 0,
      g_irq1f_mode         => 0
    )
    port map (
      clk_i                => clk_sys_i,
      rst_n_i              => rst_n_i,
      irq_i                => irq_inputs_vector_int,
      irq_ack_o            => eic_irq_ack_int,
      reg_imr_o            => eic_imr_int,
      reg_ier_i            => eic_ier_int,
      reg_ier_wr_stb_i     => eic_ier_write_int,
      reg_idr_i            => eic_idr_int,
      reg_idr_wr_stb_i     => eic_idr_write_int,
      reg_isr_o            => eic_isr_status_int,
      reg_isr_i            => eic_isr_clear_int,
      reg_isr_wr_stb_i     => eic_isr_write_int,
      wb_irq_o             => wb_int_o
    );
  
  irq_inputs_vector_int(0) <= irq_tx_i;
  irq_tx_ack_o <= eic_irq_ack_int(0);
  irq_tx_mask_o <= eic_imr_int(0);
  irq_inputs_vector_int(1) <= irq_rx_i;
  irq_rx_ack_o <= eic_irq_ack_int(1);
  irq_inputs_vector_int(2) <= irq_txts_i;
  rwaddr_reg <= wb_adr_i;
  wb_stall_o <= (not ack_sreg(0)) and (wb_stb_i and wb_cyc_i);
-- ACK signal generation. Just pass the LSB of ACK counter.
  wb_ack_o <= ack_sreg(0);
end syn;
