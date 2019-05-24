library ieee;

use ieee.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;

use work.tdc_core_pkg.all;
use work.gencores_pkg.all;
use work.genram_pkg.all;

entity timestamp_convert_filter is
  port (
    clk_tdc_i   : in std_logic;
    rst_tdc_n_i : in std_logic;
    clk_sys_i   : in std_logic;
    rst_sys_n_i : in std_logic;

    enable_i     : in std_logic_vector(4 downto 0);
    reset_seq_i  : in std_logic_vector(4 downto 0);
    raw_enable_i : in std_logic_vector(4 downto 0);

    -- raw timestamp input, clk_tdc_i domain
    ts_i       : in t_acam_timestamp;
    ts_valid_i : in std_logic;

    -- converted and filtered timestamp output, clk_sys_i domain
    ts_offset_i : in     t_tdc_timestamp_array(4 downto 0);
    ts_o        : out    t_tdc_timestamp_array(4 downto 0);
    ts_valid_o  : buffer std_logic_vector(4 downto 0);
    ts_ready_i  : in     std_logic_vector(4 downto 0);

    direct_timestamp_o : out std_logic_vector(127 downto 0);
    direct_timestamp_valid_o : out std_logic
    );


end timestamp_convert_filter;

architecture rtl of timestamp_convert_filter is

  constant c_MIN_PULSE_WIDTH_TICKS : integer := 12;  -- 12 * 8 ns = 96 ns

  constant c_FINE_SF    : unsigned(17 downto 0) := to_unsigned(84934, 18);
  constant c_FINE_SHIFT : integer               := 11;

  type t_channel_state is record
    expected_edge      : std_logic;
    last_ts            : t_tdc_timestamp;
    last_valid         : std_logic;
    seq                : unsigned(31 downto 0);
    s1_delta_coarse    : unsigned(31 downto 0);
    s1_delta_tai       : unsigned(31 downto 0);
    s2_delta_coarse    : unsigned(31 downto 0);
    s2_delta_tai       : unsigned(31 downto 0);
    s1_valid, s2_valid : std_logic;
  end record;

  type t_channel_state_array is array(integer range<>) of t_channel_state;

  signal channels : t_channel_state_array(0 to 4);

  signal s1_frac_scaled                  : unsigned(31 downto 0);
  signal s1_tai, s2_tai, s3_tai          : unsigned(31 downto 0);
  signal s1_valid, s2_valid, s3_valid    : std_logic;
  signal s1_coarse, s2_coarse, s3_coarse : unsigned(31 downto 0);
  signal s2_frac, s3_frac                : unsigned(11 downto 0);

  signal coarse_adj                         : std_logic_vector(31 downto 0);
  signal s1_channel, s2_channel, s3_channel : std_logic_vector(2 downto 0);
  signal s1_edge, s2_edge, s3_edge          : std_logic;

  signal s3_ts : t_tdc_timestamp;

  signal ts_valid_sys : std_logic;

  signal fifo_we, fifo_rd, fifo_empty, fifo_full, fifo_rd_d : std_logic;
  signal fifo_d, fifo_q : std_logic_vector(127 downto 0);
  
  signal ts_fifo_out : t_acam_timestamp;

  signal ts_valid_preoffset, ts_ready_preoffset, ts_valid_postoffset : std_logic_vector(4 downto 0);
  signal ts_preoffset, ts_postoffset                                 : t_tdc_timestamp_array(4 downto 0);
  signal s1_meta, s2_meta, s3_meta                                      : std_logic_vector(31 downto 0);

  function f_pack_acam_timestamp (ts : t_acam_timestamp) return std_logic_vector is
    variable rv : std_logic_vector(127 downto 0);
  begin
    rv(31 downto 0)   := ts.tai;
    rv(63 downto 32)  := ts.coarse;
    rv(80 downto 64)  := ts.n_bins;
    rv(83 downto 81)  := ts.channel;
    rv(84)            := ts.slope;
    rv(116 downto 85) := ts.meta;
    return rv;
  end f_pack_acam_timestamp;

  function f_unpack_acam_timestamp ( p : std_logic_vector ) return t_acam_timestamp is
    variable ts : t_acam_timestamp;
  begin
    ts.tai := p(31 downto 0);
    ts.coarse := p(63 downto 32);
    ts.n_bins := p(80 downto 64);
    ts.channel := p(83 downto 81);
    ts.slope := p(84);
    ts.meta := p(116 downto 85);
    return ts;
  end f_unpack_acam_timestamp;

  
    begin

  fifo_d <= f_pack_acam_timestamp(ts_i);
  fifo_we <= ts_valid_i;

  U_Sync_FIFO: generic_async_fifo
    generic map (
      g_data_width             => 128,
      g_size                   => 16,
      g_show_ahead             => false)
    port map (
      rst_n_i           => rst_sys_n_i,
      clk_wr_i          => clk_tdc_i,
      d_i               => fifo_d,
      we_i              => fifo_we,
      clk_rd_i          => clk_sys_i,
      q_o               => fifo_q,
      rd_i              => fifo_rd,
      rd_empty_o        => fifo_empty);
  
  ts_fifo_out <= f_unpack_acam_timestamp(fifo_q);
  fifo_rd <= not fifo_empty;

  process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_sys_n_i = '0' then
        s1_valid <= '0';
        s2_valid <= '0';
        s3_valid <= '0';
        fifo_rd_d <= '0';
      else

        fifo_rd_d <= fifo_rd;

        -- 64/125 = 4096/8000: reduce fraction to avoid 64-bit division 
        -- frac = hwts->bins * 81 * 64 / 125;

        -- stage 1: scale frac
        s1_frac_scaled <= resize ((unsigned(ts_fifo_out.n_bins) * c_FINE_SF) srl c_FINE_SHIFT, 32);
        s1_coarse      <= unsigned(ts_fifo_out.coarse);
        s1_tai         <= unsigned(ts_fifo_out.tai);
        s1_edge        <= ts_fifo_out.slope;
        s1_channel     <= ts_fifo_out.channel;
        s1_meta        <= x"0000" & "000" & ts_fifo_out.n_bins(12 downto 0);
        s1_valid       <= fifo_rd_d;

        -- stage 2: adjust coarse
        s2_frac    <= s1_frac_scaled(11 downto 0);
        s2_coarse  <= unsigned(s1_coarse) + s1_frac_scaled(31 downto 12);
        s2_tai     <= s1_tai;
        s2_edge    <= s1_edge;
        s2_channel <= s1_channel;
        s2_meta     <= s1_meta;
        s2_valid   <= s1_valid;

        -- stage 3: roll-over coarse
        if s2_coarse(31) = '1' then
          s3_coarse <= s2_coarse + to_unsigned(125000000, 32);
          s3_tai    <= s2_tai - 1;
        elsif (s2_coarse >= 125000000) then
          s3_coarse <= s2_coarse - to_unsigned(125000000, 32);
          s3_tai    <= s2_tai + 1;
        else
          s3_coarse <= s2_coarse;
          s3_tai    <= s2_tai;
        end if;

        s3_meta     <= s2_meta;
        s3_frac    <= s2_frac;
        s3_edge    <= s2_edge;
        s3_channel <= s2_channel;
        s3_valid   <= s2_valid;
      end if;
    end if;
  end process;

  s3_ts.frac    <= std_logic_vector(s3_frac);
  s3_ts.coarse  <= std_logic_vector(s3_coarse);
  s3_ts.tai     <= std_logic_vector(s3_tai);
  s3_ts.slope   <= s3_edge;
  s3_ts.channel <= s3_channel;
  s3_ts.meta     <= s3_meta;


  p_direct_output : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_sys_n_i = '0' then
        direct_timestamp_valid_o <= '0';
      else
        direct_timestamp_o(31 downto 0)      <= s3_ts.tai;
        direct_timestamp_o(63 downto 32)     <= s3_ts.coarse;
        direct_timestamp_o(95 downto 64)     <= x"00000" & s3_ts.frac;
        direct_timestamp_o(96 + 2 downto 96) <= s3_ts.channel;
        direct_timestamp_o(96 + 3)           <= s3_ts.slope;
        direct_timestamp_o(127 downto 100)   <= (others => '0');
        direct_timestamp_valid_o             <= s3_valid;
      end if;
    end if;
  end process;
  
  gen_channels : for i in 0 to 4 generate

    p_fsm : process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if rst_sys_n_i = '0' or enable_i(i) = '0' then
          ts_valid_preoffset(i)     <= '0';
          channels(i).expected_edge <= '1';
          channels(i).s1_valid      <= '0';
          channels(i).s2_valid      <= '0';
          channels(i).last_valid    <= '0';
          channels(i).seq           <= (others => '0');
        else
          channels(i).s1_valid <= '0';

          if(reset_seq_i(i) = '1') then
            channels(i).seq <= (others => '0');
          end if;

          if s3_valid = '1' and unsigned(s3_channel) = i then

            if (s3_ts.slope = '1') then  -- rising edge
              channels(i).last_ts    <= s3_ts;
              channels(i).last_valid <= '1';
              channels(i).s1_valid   <= '0';
            else
              channels(i).last_valid <= '0';
              channels(i).s1_valid   <= '1';
            end if;

            channels(i).s1_delta_coarse <= unsigned(s3_ts.coarse) - unsigned(channels(i).last_ts.coarse);
            channels(i).s1_delta_tai    <= unsigned(s3_ts.tai) - unsigned(channels(i).last_ts.tai);
          end if;


          if channels(i).s1_delta_coarse(31) = '1' then
            channels(i).s2_delta_coarse <= channels(i).s1_delta_coarse + to_unsigned(125000000, 32);
            channels(i).s2_delta_tai    <= channels(i).s1_delta_tai - 1;
          else
            channels(i).s2_delta_coarse <= channels(i).s1_delta_coarse;
            channels(i).s2_delta_tai    <= channels(i).s1_delta_tai;
          end if;

          channels(i).s2_valid <= channels(i).s1_valid;

          if channels(i).s2_valid = '1' then
            if channels(i).s2_delta_tai = 0 and channels(i).s2_delta_coarse >= 12 then

              ts_preoffset(i).tai     <= channels(i).last_ts.tai;
              ts_preoffset(i).coarse  <= channels(i).last_ts.coarse;
              ts_preoffset(i).frac    <= channels(i).last_ts.frac;
              ts_preoffset(i).channel <= channels(i).last_ts.channel;
              ts_preoffset(i).slope   <= channels(i).last_ts.slope;
              ts_preoffset(i).meta <= channels(i).last_ts.meta;

              ts_valid_preoffset(i) <= '1';

              if(reset_seq_i(i) = '1') then
                channels(i).seq     <= (others => '0');
                ts_preoffset(i).seq <= (others => '0');
              else
                channels(i).seq     <= channels(i).seq + 1;
                ts_preoffset(i).seq <= std_logic_vector(channels(i).seq);
              end if;
            else
              ts_valid_preoffset(i) <= '0';
            end if;
          else
            ts_valid_preoffset(i) <= '0';
          end if;

        end if;
      end if;
    end process;

    U_Offset_Adder : entity work.tdc_ts_addsub
      port map (
        clk_i    => clk_sys_i,
        rst_n_i  => rst_sys_n_i,
        valid_i  => ts_valid_preoffset(i),
        enable_i => '1',
        a_i      => ts_preoffset(i),
        b_i      => ts_offset_i(i),
        valid_o  => ts_valid_postoffset(i),
        q_o      => ts_postoffset(i));

    p_output : process(clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if rst_sys_n_i = '0' or enable_i(i) = '0' then
          ts_valid_o(i) <= '0';
        else

          if ts_ready_i(i) = '1' then
            ts_valid_o(i) <= '0';
          end if;

          if raw_enable_i(i) = '1' then

            --if ts_valid_sys = '1' and unsigned(ts_latched.channel) = i then
            --  ts_valid_o(i) <= '1';
            --  ts_o(i).raw   <= ts_latched.raw;
            --end if;

          else

            if ts_valid_postoffset(i) = '1' then
              ts_valid_o(i) <= '1';
              ts_o(i)       <= ts_postoffset(i);
            end if;

          end if;


        end if;
      end if;
    end process;

  end generate gen_channels;


end rtl;




