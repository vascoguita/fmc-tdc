library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gencores_pkg.all;
use work.tdc_core_pkg.all;
use work.wishbone_pkg.all;
use work.dr_wbgen2_pkg.all;

entity fmc_tdc_direct_readout is
  port
    (
      clk_sys_i   : in std_logic;
      rst_sys_n_i : in std_logic;

      timestamp_i       : in t_tdc_timestamp_array(4 downto 0);
      timestamp_valid_i : in std_logic_vector(4 downto 0);

      direct_slave_i : in  t_wishbone_slave_in;
      direct_slave_o : out t_wishbone_slave_out
      );

end entity;


architecture rtl of fmc_tdc_direct_readout is

  constant c_num_channels : integer := 5;

  type t_channel_state is record
    enable  : std_logic;
    timeout : unsigned(23 downto 0);
    ready   : std_logic;
  end record;

  --  Bit is set when timestamp for channel has to be written in fifo.
  signal fifo_wr : std_logic_vector(c_num_channels-1 downto 0);

  type t_channel_state_array is array(0 to c_num_channels-1) of t_channel_state;

  signal c : t_channel_state_array;

  signal regs_out : t_dr_out_registers;
  signal regs_in  : t_dr_in_registers;

  signal direct_slave_out: t_wishbone_slave_out;

  signal channel_select : integer := 0;

begin

  p_channel_select: process (timestamp_valid_i) is
  begin
    case timestamp_valid_i is
      when "00001" => channel_select <= 0;
      when "00010" => channel_select <= 1;
      when "00100" => channel_select <= 2;
      when "01000" => channel_select <= 3;
      when "10000" => channel_select <= 4;
      when others  => channel_select <= 0;
    end case;
  end process p_channel_select;

  regs_in.fifo_cycles_i  <= timestamp_i(channel_select).coarse;
  regs_in.fifo_edge_i    <= timestamp_i(channel_select).slope;
  regs_in.fifo_seconds_i <= timestamp_i(channel_select).tai;
  regs_in.fifo_channel_i <= std_logic_vector(to_unsigned(channel_select, 4));
  regs_in.fifo_bins_i    <= "000000" & timestamp_i(channel_select).frac;
  regs_in.fifo_wr_req_i  <= f_to_std_logic(fifo_wr(channel_select) = '1' and
                                           regs_out.fifo_wr_full_o = '0');

  U_WB_Slave : entity work.fmc_tdc_direct_readout_wb_slave
    port map (
      rst_n_i    => rst_sys_n_i,
      clk_sys_i  => clk_sys_i,
      wb_adr_i   => direct_slave_i.adr(4 downto 2),
      wb_dat_i   => direct_slave_i.dat,
      wb_dat_o   => direct_slave_out.dat,
      wb_cyc_i   => direct_slave_i.cyc,
      wb_sel_i   => direct_slave_i.sel,
      wb_stb_i   => direct_slave_i.stb,
      wb_we_i    => direct_slave_i.we,
      wb_ack_o   => direct_slave_out.ack,
      wb_stall_o => direct_slave_out.stall,
      regs_i     => regs_in,
      regs_o     => regs_out);

  direct_slave_out.err <= '0';
  direct_slave_out.rty <= '0';

  direct_slave_o <= direct_slave_out;


  gen_channels : for i in 0 to c_num_channels-1 generate

    c(i).enable <= regs_out.chan_enable_o(i);
    fifo_wr(i) <= f_to_std_logic(timestamp_i(i).slope = '1'and
                                 timestamp_valid_i(i) = '1'and
                                 c(i).ready = '1');

    p_dead_time : process (clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if rst_sys_n_i = '0' or c(i).enable = '0' then
          c(i).timeout <= (others => '0');
          c(i).ready <= '0';
        else
          if fifo_wr(i) = '1' then
            --  Ignore this channel for the dead time.
            c(i).timeout <= unsigned(regs_out.dead_time_o);
            c(i).ready <= '0';
          elsif c(i).timeout /= 0 then
            --  In dead time.
            c(i).ready <= '0';
            c(i).timeout <= c(i).timeout - 1;
          else
            -- Waiting for the next timestamp.
            c(i).ready <= '1';
            c(i).timeout <= (others => '0');
          end if;
        end if;
      end if;
    end process;
  end generate gen_channels;

end rtl;
