library ieee;

use ieee.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;

use work.tdc_core_pkg.all;
use work.wishbone_pkg.all;
use work.genram_pkg.all;
use work.tdc_buf_wbgen2_pkg.all;

entity tdc_dma_channel is
  port (

    clk_i : in std_logic;
    rst_n_i   : in std_logic;

    enable_i : in std_logic;
    
    ts_i       : in  t_tdc_timestamp;
    ts_valid_i : in  std_logic;
    ts_ready_o : out std_logic;

    slave_i : in  t_wishbone_slave_in;
    slave_o : out t_wishbone_slave_out;

    irq_tick_i : in  std_logic;
    irq_o      : out std_logic;

    dma_wb_o : out t_wishbone_master_out;
    dma_wb_i : in  t_wishbone_master_in
    );
end tdc_dma_channel;

architecture rtl of tdc_dma_channel is

  signal cur_base  : unsigned(31 downto 0);
  signal cur_size  : unsigned(31 downto 0);
  signal cur_valid : std_logic;
  signal cur_pos   : unsigned(31 downto 0);


  signal next_base  : unsigned(31 downto 0);
  signal next_size  : unsigned(31 downto 0);
  signal next_valid : std_logic;

  signal addr        : unsigned(31 downto 0);
  signal count       : unsigned(31 downto 0);
  signal burst_count : unsigned(8 downto 0);

  signal irq_timer : unsigned(15 downto 0);

  signal regs_out : t_TDC_BUF_out_registers;
  signal regs_in  : t_TDC_BUF_in_registers;

  type t_STATE is (IDLE, SWITCH_BUFFERS, WAIT_NEXT_TS, SER0, SER1, SER2, SER3);
  type t_DMA_STATE is (WAIT_BURST, EXECUTE_BURST, WAIT_ACKS);

  signal fifo_in : std_logic_vector(33 downto 0);

  alias fifo_in_data is fifo_in(31 downto 0);
  alias fifo_in_is_addr is fifo_in(32);
  alias fifo_in_last_in_buffer is fifo_in(33);

  signal fifo_out : std_logic_vector(33 downto 0);

  alias fifo_out_data is fifo_out(31 downto 0);
  alias fifo_out_is_addr is fifo_out(32);
  alias fifo_out_last_in_buffer is fifo_out(33);

  signal fifo_rd, fifo_wr, fifo_full, fifo_empty, fifo_clear, fifo_valid : std_logic;
  signal fifo_count                                                      : std_logic_vector(7 downto 0);

  signal state     : t_STATE;
  signal dma_state : t_DMA_STATE;

  signal ts : t_tdc_timestamp;

  signal buffer_switch_latched : std_logic;

  signal dma_addr : unsigned(31 downto 0);

  signal burst_add      : std_logic;
  signal burst_sub      : std_logic;
  signal bursts_in_fifo : unsigned(3 downto 0);

  signal ack_count : unsigned(5 downto 0);

  signal dma_wb_out : t_wishbone_master_out;

  signal irq_req  : std_logic;
  signal overflow : std_logic;

begin

  U_WB_Regs : tdc_buffer_control_wb
    port map (
      rst_n_i   => rst_n_i,
      clk_sys_i => clk_i,
      slave_i   => slave_i,
      slave_o   => slave_o,
--      int_o     => int_o,
      regs_i    => regs_in,
      regs_o    => regs_out);

  p_irq_timer : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' or enable_i = '0' then
        irq_timer <= (others => '0');
        irq_o     <= '0';
      else
        irq_o <= '0';
        if irq_req = '0' then
          irq_timer <= (others => '0');
        elsif irq_timer = unsigned(regs_out.tdc_buf_csr_irq_timeout_o) then
          irq_o <= '1';
        elsif irq_req = '1' and irq_tick_i = '1' then
          irq_timer <= irq_timer + 1;
        end if;
      end if;
    end if;
  end process;

  p_write_fsm : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        state                 <= IDLE;
        fifo_wr               <= '0';
        fifo_clear            <= '1';
        buffer_switch_latched <= '0';
        cur_valid             <= '0';
        next_valid            <= '0';
        addr                  <= (others => '0');
        count                 <= (others => '0');
        burst_add             <= '0';
        ts_ready_o            <= '0';
        irq_req               <= '0';
      else
        fifo_wr                <= '0';
        fifo_clear             <= '0';
        fifo_in_last_in_buffer <= '0';
        fifo_in_is_addr        <= '0';
        burst_add              <= '0';
        ts_ready_o             <= '0';

        if(regs_out.tdc_buf_csr_switch_buffers_o = '1') then
          buffer_switch_latched <= '1';
        end if;

        if(regs_out.tdc_buf_cur_base_load_o = '1') then
          cur_base <= resize(unsigned(regs_out.tdc_buf_cur_base_o), cur_base'length);
          addr     <= resize(unsigned(regs_out.tdc_buf_cur_base_o), cur_base'length);
        end if;

        if(regs_out.tdc_buf_cur_size_size_load_o = '1') then
          cur_size <= resize(unsigned(regs_out.tdc_buf_cur_size_size_o), cur_size'length);
        end if;

        if(regs_out.tdc_buf_cur_size_valid_load_o = '1') then
          cur_valid <= regs_out.tdc_buf_cur_size_valid_o;
        end if;

        if(regs_out.tdc_buf_next_base_load_o = '1') then
          next_base <= resize(unsigned(regs_out.tdc_buf_next_base_o), next_base'length);
        end if;

        if(regs_out.tdc_buf_next_size_size_load_o = '1') then
          next_size <= resize(unsigned(regs_out.tdc_buf_next_size_size_o), next_size'length);
        end if;

        if(regs_out.tdc_buf_next_size_valid_load_o = '1') then
          next_valid <= regs_out.tdc_buf_next_size_valid_o;
        end if;



        case state is
          when SWITCH_BUFFERS =>
            count                  <= (others => '0');
            cur_base               <= next_base;
            cur_valid              <= next_valid;
            cur_size               <= next_size;
            addr                   <= next_base;
            next_valid             <= '0';
            buffer_switch_latched  <= '0';
            cur_pos                <= count;
            fifo_in_last_in_buffer <= '1';
            fifo_wr                <= '1';

            if(next_valid = '1') then
              irq_req <= '0';
            end if;

            state <= IDLE;

          when IDLE =>

            if(buffer_switch_latched = '1') then
              state <= SWITCH_BUFFERS;
            end if;


            
            if enable_i = '1' and regs_out.tdc_buf_csr_enable_o = '1' and ts_valid_i = '1' then

              if cur_valid = '1' then

                if count < cur_size then
                  ts              <= ts_i;
                  state           <= SER0;
                  fifo_in_is_addr <= '1';
                  fifo_in_data    <= std_logic_vector(addr);
                  fifo_wr         <= '1';
                  burst_count     <= (others => '0');
                  irq_req         <= '1';
                  ts_ready_o      <= '1';
                else
                  buffer_switch_latched <= '1';
                end if;
                overflow <= '0';
              else
                ts_ready_o <= '1';
                overflow   <= '1';
              end if;



            end if;

          when WAIT_NEXT_TS =>
            fifo_in_is_addr <= '0';
            if enable_i = '0' or regs_out.tdc_buf_csr_enable_o = '0' or burst_count = unsigned(regs_out.tdc_buf_csr_burst_size_o) or buffer_switch_latched = '1' then
              burst_add <= '1';
              state     <= IDLE;
            elsif ts_valid_i = '1' then
              state      <= SER0;
              ts         <= ts_i;
              ts_ready_o <= '1';
            end if;

          
--word 0 TAI
--word 1 coarse
--word 2 frac
--word 3
--  bit 31-4 sequence Id (mask: 0xFFFFFFF0)(it becomes smaller, is it possible?)
--  bit    3 slope (mask: 0x8)
--  bit  2-0 chan  (mask: 0x7)

          when SER0 =>
            fifo_in_data    <= ts.tai;
            fifo_in_is_addr <= '0';
            fifo_wr         <= '1';
            state           <= SER1;
          when SER1 =>
            fifo_in_data    <= ts.coarse;
            fifo_in_is_addr <= '0';
            fifo_wr         <= '1';
            state           <= SER2;
          when SER2 =>
            fifo_in_data    <= x"00000" & ts.frac;
            fifo_in_is_addr <= '0';
            fifo_wr         <= '1';
            state           <= SER3;
          when SER3 =>
            fifo_in_data    <= ts.seq(27 downto 0) & ts.slope & ts.channel(2 downto 0);
            fifo_in_is_addr <= '0';
            fifo_wr         <= '1';
            state           <= WAIT_NEXT_TS;
            count           <= count + 1;
            addr            <= addr + 16;
            burst_count     <= burst_count + 1;
        end case;
      end if;
    end if;
  end process;

  p_burst_counter : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        bursts_in_fifo <= (others => '0');
      else
        if burst_add = '1' and burst_sub = '0' then
          bursts_in_fifo <= bursts_in_fifo + 1;
        elsif burst_add = '0' and burst_sub = '1' then
          bursts_in_fifo <= bursts_in_fifo - 1;
        end if;
      end if;
    end if;
  end process;



  U_FIFO : generic_sync_fifo
    generic map (
      g_data_width => 34,
      g_size       => 256,
      g_show_ahead => true)
    port map (
      rst_n_i => rst_n_i,
      clk_i   => clk_i,
      d_i     => fifo_in,
      we_i    => fifo_wr,
      q_o     => fifo_out,
      rd_i    => fifo_rd,
      empty_o => fifo_empty,
      full_o  => fifo_full,
      count_o => fifo_count);

  ------------------------------------------------------------------------------
  -- Wishbone master (to DDR)
  ------------------------------------------------------------------------------
  p_wb_master : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        dma_wb_out.cyc          <= '0';
        fifo_valid              <= '0';
        burst_sub               <= '0';
        dma_state               <= WAIT_BURST;
        regs_in.tdc_buf_csr_done_i <= '0';
      else

        burst_sub <= '0';

        if regs_out.tdc_buf_csr_done_o = '1' and regs_out.tdc_buf_csr_done_load_o = '1' then
          regs_in.tdc_buf_csr_done_i <= '0';
        elsif fifo_empty = '0' and fifo_out_last_in_buffer = '1' then
          regs_in.tdc_buf_csr_done_i <= '1';
        end if;

        case dma_state is
          when WAIT_BURST =>
            if bursts_in_fifo /= 0 and fifo_empty = '0' and fifo_out_is_addr = '1' and fifo_out_last_in_buffer = '0' then
              dma_wb_out.cyc <= '1';
              dma_addr       <= unsigned(fifo_out_data);
              dma_state      <= EXECUTE_BURST;
              burst_sub      <= '1';
            end if;

          when EXECUTE_BURST =>
            if fifo_rd = '1' then
              dma_addr <= dma_addr + 4;
            end if;

            if fifo_empty = '1' then
              dma_state <= WAIT_ACKS;
            elsif fifo_out_is_addr = '1' and fifo_out_last_in_buffer = '0' then
              dma_state <= WAIT_ACKS;
            end if;

          when WAIT_ACKS =>
            if ack_count = 0 then
              dma_wb_out.cyc <= '0';
              dma_state      <= WAIT_BURST;
            end if;
        end case;
      end if;
    end if;
  end process;

  p_fifo_control : process(dma_wb_i, bursts_in_fifo, fifo_empty, dma_state, fifo_out_is_addr, fifo_out_last_in_buffer)
  begin
    fifo_rd <= '0';

    if (fifo_out_last_in_buffer = '1' and fifo_empty = '0') then
      fifo_rd <= '1';
    else

      case dma_state is
        when WAIT_BURST =>
          if bursts_in_fifo /= 0 and fifo_empty = '0' and fifo_out_is_addr = '1' then
            fifo_rd <= '1';
          end if;

        when EXECUTE_BURST =>
          if fifo_empty = '0' and dma_wb_i.stall = '0' and fifo_out_is_addr = '0' then
            fifo_rd <= '1';
          end if;

        when WAIT_ACKS =>
          fifo_rd <= '0';

      end case;
    end if;

  end process;


  p_count_acks : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if dma_wb_out.cyc = '0' then
        ack_count <= (others => '0');
      elsif(dma_wb_out.cyc = '1' and dma_wb_out.stb = '1' and dma_wb_i.stall = '0' and dma_wb_i.ack = '0') then
        ack_count <= ack_count + 1;
      elsif((dma_wb_out.stb = '0' or dma_wb_i.stall = '1') and dma_wb_i.ack = '1') then
        ack_count <= ack_count - 1;
      end if;
    end if;
  end process;


  dma_wb_out.adr <= std_logic_vector(dma_addr);
  dma_wb_out.dat <= fifo_out_data;
  dma_wb_out.stb <= not fifo_empty and not fifo_out_is_addr when (dma_state = EXECUTE_BURST) else '0';
  dma_wb_out.we  <= '1';
  dma_wb_out.sel <= (others => '1');

  dma_wb_o <= dma_wb_out;

  regs_in.tdc_buf_cur_base_i       <= std_logic_vector(resize(cur_base, 32));
  regs_in.tdc_buf_cur_size_size_i  <= std_logic_vector(resize(cur_size, 30));
  regs_in.tdc_buf_cur_size_valid_i <= cur_valid;

  regs_in.tdc_buf_next_base_i       <= std_logic_vector(resize(next_base, 32));
  regs_in.tdc_buf_next_size_size_i  <= std_logic_vector(resize(next_size, 30));
  regs_in.tdc_buf_next_size_valid_i <= next_valid;

  regs_in.tdc_buf_cur_count_i <= std_logic_vector(resize(cur_pos, 32));
end rtl;
