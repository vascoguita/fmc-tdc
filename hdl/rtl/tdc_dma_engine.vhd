library ieee;

use ieee.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;

use work.tdc_core_pkg.all;
use work.wishbone_pkg.all;
use work.genram_pkg.all;
use work.gencores_pkg.all;

entity tdc_dma_engine is
  generic (
    g_CLOCK_FREQ : integer := 62500000
    );
  port (
    clk_i : in std_logic;
    rst_n_i   : in std_logic;

    ts_i       : in  t_tdc_timestamp_array(4 downto 0);
    ts_valid_i : in  std_logic_vector(4 downto 0);
    ts_ready_o : out std_logic_vector(4 downto 0);

    slave_i : in  t_wishbone_slave_in;
    slave_o : out t_wishbone_slave_out;

    irq_o : out std_logic_vector(4 downto 0);

    dma_wb_o : out t_wishbone_master_out;
    dma_wb_i : in  t_wishbone_master_in
    );
end tdc_dma_engine;

architecture rtl of tdc_dma_engine is

  signal cr_cnx_master_out : t_wishbone_master_out_array(4 downto 0);
  signal cr_cnx_master_in  : t_wishbone_master_in_array(4 downto 0);

  signal dma_cnx_slave_out : t_wishbone_slave_out_array(4 downto 0);
  signal dma_cnx_slave_in  : t_wishbone_slave_in_array(4 downto 0);

  signal c_CR_CNX_BASE_ADDR : t_wishbone_address_array(4 downto 0) :=
    (0 => x"00000000",
     1 => x"00000040",
     2 => x"00000080",
     3 => x"000000c0",
     4 => x"00000100");

  signal c_CR_CNX_BASE_MASK : t_wishbone_address_array(4 downto 0) :=
    (0 => x"000001c0",
     1 => x"000001c0",
     2 => x"000001c0",
     3 => x"000001c0",
     4 => x"000001c0");


  constant c_TIMER_PERIOD_MS     : integer := 1;
  constant c_TIMER_DIVIDER_VALUE : integer := g_CLOCK_FREQ * c_TIMER_PERIOD_MS / 1000 - 1;

  signal irq_tick_div : unsigned(15 downto 0);
  signal irq_tick     : std_logic;
begin

  p_irq_tick : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        irq_tick     <= '0';
        irq_tick_div <= (others => '0');
      else
        if irq_tick_div = c_TIMER_DIVIDER_VALUE then
          irq_tick     <= '1';
          irq_tick_div <= (others => '0');
        else
          irq_tick     <= '0';
          irq_tick_div <= irq_tick_div + 1;
        end if;
      end if;
    end if;
  end process;

  U_CR_Crossbar : xwb_crossbar
    generic map (
      g_num_masters => 1,
      g_num_slaves  => 5,
      g_registered  => true,
      g_address     => c_CR_CNX_BASE_ADDR,
      g_mask        => c_CR_CNX_BASE_MASK)
    port map (
      clk_sys_i      => clk_i,
      rst_n_i    => rst_n_i,
      slave_i(0) => slave_i,
      slave_o(0) => slave_o,
      master_i   => cr_cnx_master_in,
      master_o   => cr_cnx_master_out);

  U_DMA_Crossbar : xwb_crossbar
    generic map (
      g_num_masters => 5,
      g_num_slaves  => 1,
      g_registered  => true,
      g_address     => (0 => x"00000000"),
      g_mask        => (0 => x"00000000"))
    port map (
      clk_sys_i       => clk_i,
      rst_n_i     => rst_n_i,
      slave_i     => dma_cnx_slave_in,
      slave_o     => dma_cnx_slave_out,
      master_i(0) => dma_wb_i,
      master_o(0) => dma_wb_o);

  gen_channels : for i in 0 to 4 generate

    U_DMA_Channel : entity work.tdc_dma_channel
      port map (
        clk_i      => clk_i,
        rst_n_i    => rst_n_i,
        ts_i       => ts_i(i),
        ts_valid_i => ts_valid_i(i),
        ts_ready_o => ts_ready_o(i),
        slave_i    => cr_cnx_master_out(i),
        slave_o    => cr_cnx_master_in(i),
        irq_o      => irq_o(i),
        irq_tick_i => irq_tick,
        dma_wb_o   => dma_cnx_slave_in(i),
        dma_wb_i   => dma_cnx_slave_out(i));

  end generate gen_channels;

end rtl;
