----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : TDC top level (top_tdc.vhd)
--  author      : G. Penacoba
--  date        : May 2011
--  version     : Revision 1
--  description : top level for preliminary testing of the acam chip on the TDC card
--  dependencies:
--  references  :
--  modified by :
--
----------------------------------------------------------------------------------------------------
--  last changes:
----------------------------------------------------------------------------------------------------
--  to do:
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tdc_core_pkg.all;
use work.gn4124_core_pkg.all;

----------------------------------------------------------------------------------------------------
--  entity declaration for top_tdc
----------------------------------------------------------------------------------------------------
entity top_tdc is
    generic(
        g_width                 : integer :=32;
        values_for_simulation   : boolean :=FALSE
    );
    port(
        -- interface with GNUM
        rst_n_a_i      : in  std_logic;
        -- P2L Direction
        p2l_clk_p_i : in  std_logic;                      -- Receiver Source Synchronous Clock+
        p2l_clk_n_i : in  std_logic;                      -- Receiver Source Synchronous Clock-
        p2l_data_i  : in  std_logic_vector(15 downto 0);  -- Parallel receive data
        p2l_dframe_i: in  std_logic;                      -- Receive Frame
        p2l_valid_i : in  std_logic;                      -- Receive Data Valid
        p2l_rdy_o   : out std_logic;                      -- Rx Buffer Full Flag
        p_wr_req_i  : in  std_logic_vector(1 downto 0);   -- PCIe Write Request
        p_wr_rdy_o  : out std_logic_vector(1 downto 0);   -- PCIe Write Ready
        rx_error_o  : out std_logic;                      -- Receive Error
        vc_rdy_i    : in  std_logic_vector(1 downto 0);   -- Virtual channel ready
        -- L2P Direction
        l2p_clk_p_o : out std_logic;                      -- Transmitter Source Synchronous Clock+
        l2p_clk_n_o : out std_logic;                      -- Transmitter Source Synchronous Clock-
        l2p_data_o  : out std_logic_vector(15 downto 0);  -- Parallel transmit data
        l2p_dframe_o: out std_logic;                      -- Transmit Data Frame
        l2p_valid_o : out std_logic;                      -- Transmit Data Valid
        l2p_edb_o   : out std_logic;                      -- Packet termination and discard
        l2p_rdy_i   : in  std_logic;                      -- Tx Buffer Full Flag
        l_wr_rdy_i  : in  std_logic_vector(1 downto 0);   -- Local-to-PCIe Write
        p_rd_d_rdy_i: in  std_logic_vector(1 downto 0);   -- PCIe-to-Local Read Response Data Ready
        tx_error_i  : in  std_logic;                      -- Transmit Error
        irq_p_o     : out std_logic;                      -- Interrupt request pulse to GN4124 GPIO
        
        -- interface signals with PLL circuit on TDC mezzanine
        acam_refclk_i           : in std_logic;
        pll_ld_i                : in std_logic;
        pll_refmon_i            : in std_logic;
        pll_sdo_i               : in std_logic;
        pll_status_i            : in std_logic;
        tdc_clk_p_i             : in std_logic;
        tdc_clk_n_i             : in std_logic;
        
        pll_cs_o                : out std_logic;
        pll_dac_sync_o          : out std_logic;
        pll_sdi_o               : out std_logic;
        pll_sclk_o              : out std_logic;

        -- interface signals with acam (timing) on TDC mezzanine
        err_flag_i              : in std_logic;
        int_flag_i              : in std_logic;

        start_dis_o             : out std_logic;
        start_from_fpga_o       : out std_logic;
        stop_dis_o              : out std_logic;

        -- interface signals with acam (data) on TDC mezzanine
        data_bus_io             : inout std_logic_vector(27 downto 0);
        ef1_i                   : in std_logic;
        ef2_i                   : in std_logic;
        lf1_i                   : in std_logic;
        lf2_i                   : in std_logic;

        address_o               : out std_logic_vector(3 downto 0);
        cs_n_o                  : out std_logic;
        oe_n_o                  : out std_logic;
        rd_n_o                  : out std_logic;
        wr_n_o                  : out std_logic;
        
        -- other signals on the TDC mezzanine
        mute_inputs_o           : out std_logic;
        tdc_led_status_o        : out std_logic;
        tdc_led_trig1_o         : out std_logic;
        tdc_led_trig2_o         : out std_logic;
        tdc_led_trig3_o         : out std_logic;
        tdc_led_trig4_o         : out std_logic;
        tdc_led_trig5_o         : out std_logic;
        term_en_1_o             : out std_logic;
        term_en_2_o             : out std_logic;
        term_en_3_o             : out std_logic;
        term_en_4_o             : out std_logic;
        term_en_5_o             : out std_logic;
        
        -- other signals on the SPEC carrier
        spec_aux0_i             : in std_logic;
        spec_aux1_i             : in std_logic;
        spec_aux2_o             : out std_logic;
        spec_aux3_o             : out std_logic;
        spec_aux4_o             : out std_logic;
        spec_aux5_o             : out std_logic;
        spec_led_green_o        : out std_logic;
        spec_led_red_o          : out std_logic;
        spec_clk_i              : in std_logic
    );
end top_tdc;

----------------------------------------------------------------------------------------------------
--  architecture declaration for top_tdc
----------------------------------------------------------------------------------------------------
architecture rtl of top_tdc is

    component one_hz_gen
    generic(
        g_width                 : integer :=32
    );
    port(
        acam_refclk_i           : in std_logic;
        clk_i                   : in std_logic;
        clock_period_i          : in std_logic_vector(g_width-1 downto 0);
        pulse_delay_i           : in std_logic_vector(g_width-1 downto 0);
        reset_i                 : in std_logic;

        one_hz_p_o              : out std_logic
    );
    end component;

--    component start_nb_offset_gen is
--    generic(
--        g_width                 : integer :=32
--    );
--    port(
--        acam_intflag_p_i        : in std_logic;
--        clk_i                   : in std_logic;
--        one_hz_p_i              : in std_logic;
--        reset_i                 : in std_logic;
--
--        start_nb_offset_o       : out std_logic_vector(g_width-1 downto 0)
--    );
--    end component;
--
--    component data_formatting
--    generic(
--        g_width                 : integer :=32
--    );
--    port(
--        acam_start01_i          : in std_logic_vector(16 downto 0);
--        acam_timestamp_i        : in std_logic_vector(28 downto 0);
--        acam_timestamp_valid_i  : in std_logic;
--        clk_i                   : in std_logic;
--        reset_i                 : in std_logic;
--        start_nb_offset_i       : in std_logic_vector(g_width-1 downto 0);
--        utc_current_time_i      : in std_logic_vector(g_width-1 downto 0);
--
--        full_timestamp_o        : out std_logic_vector(3*g_width-1 downto 0);
--        full_timestamp_valid_o  : out std_logic
--    );
--    end component;

    component acam_timecontrol_interface
    generic(
        g_width                 : integer :=32
    );
    port(
        err_flag_i              : in std_logic;
        int_flag_i              : in std_logic;

        start_dis_o             : out std_logic;
        stop_dis_o              : out std_logic;

        clk_i                   : in std_logic;
        one_hz_p_i              : in std_logic;
        reset_i                 : in std_logic;
        
        acam_errflag_p_o        : out std_logic;
        acam_intflag_p_o        : out std_logic
    );
    end component;

    component acam_databus_interface
    generic(
        g_width                 : integer :=32
    );
    port(
        ef1_i                   : in std_logic;
        ef2_i                   : in std_logic;
        lf1_i                   : in std_logic;
        lf2_i                   : in std_logic;

        data_bus_io             : inout std_logic_vector(27 downto 0);
        address_o               : out std_logic_vector(3 downto 0);
        cs_n_o                  : out std_logic;
        oe_n_o                  : out std_logic;
        rd_n_o                  : out std_logic;
        wr_n_o                  : out std_logic;

        clk_i                   : in std_logic;
        reset_i                 : in std_logic;

        adr_i                   : in std_logic_vector(19 downto 0);
        cyc_i                   : in std_logic;
        dat_i                   : in std_logic_vector(31 downto 0);
        stb_i                   : in std_logic;
        we_i                    : in std_logic;

        ack_o                   : out std_logic;
        dat_o                   : out std_logic_vector(31 downto 0)
    );
    end component;

    component clk_rst_managr
    port(
        acam_refclk_i           : in std_logic;
        pll_ld_i                : in std_logic;
        pll_refmon_i            : in std_logic;
        pll_sdo_i               : in std_logic;
        pll_status_i            : in std_logic;
        gnum_reset_i            : in std_logic;
        spec_clk_i              : in std_logic;
        tdc_clk_p_i             : in std_logic;
        tdc_clk_n_i             : in std_logic;
        
        acam_refclk_o           : out std_logic;
        general_reset_o         : out std_logic;
        pll_cs_o                : out std_logic;
        pll_dac_sync_o          : out std_logic;
        pll_sdi_o               : out std_logic;
        pll_sclk_o              : out std_logic;
        spec_clk_o              : out std_logic;
        tdc_clk_o               : out std_logic
    );
    end component;

    component gn4124_core
    generic(
    g_BAR0_APERTURE     : integer := 20;     -- BAR0 aperture, defined in GN4124 PCI_BAR_CONFIG register (0x80C)
                                             -- => number of bits to address periph on the board
    g_CSR_WB_SLAVES_NB  : integer := 1;      -- Number of CSR wishbone slaves
    g_DMA_WB_SLAVES_NB  : integer := 1;      -- Number of DMA wishbone slaves
    g_DMA_WB_ADDR_WIDTH : integer := 26      -- DMA wishbone address bus width
    );
    port
    (
      ---------------------------------------------------------
      -- Control and status
      --
      -- Asynchronous reset from GN4124
      rst_n_a_i      : in  std_logic;
      -- P2L clock PLL locked
      p2l_pll_locked : out std_logic;
      -- Debug ouputs
      debug_o        : out std_logic_vector(7 downto 0);

      ---------------------------------------------------------
      -- P2L Direction
      --
      -- Source Sync DDR related signals
      p2l_clk_p_i  : in  std_logic;                      -- Receiver Source Synchronous Clock+
      p2l_clk_n_i  : in  std_logic;                      -- Receiver Source Synchronous Clock-
      p2l_data_i   : in  std_logic_vector(15 downto 0);  -- Parallel receive data
      p2l_dframe_i : in  std_logic;                      -- Receive Frame
      p2l_valid_i  : in  std_logic;                      -- Receive Data Valid
      -- P2L Control
      p2l_rdy_o    : out std_logic;                      -- Rx Buffer Full Flag
      p_wr_req_i   : in  std_logic_vector(1 downto 0);   -- PCIe Write Request
      p_wr_rdy_o   : out std_logic_vector(1 downto 0);   -- PCIe Write Ready
      rx_error_o   : out std_logic;                      -- Receive Error
      vc_rdy_i     : in  std_logic_vector(1 downto 0);   -- Virtual channel ready

      ---------------------------------------------------------
      -- L2P Direction
      --
      -- Source Sync DDR related signals
      l2p_clk_p_o  : out std_logic;                      -- Transmitter Source Synchronous Clock+
      l2p_clk_n_o  : out std_logic;                      -- Transmitter Source Synchronous Clock-
      l2p_data_o   : out std_logic_vector(15 downto 0);  -- Parallel transmit data
      l2p_dframe_o : out std_logic;                      -- Transmit Data Frame
      l2p_valid_o  : out std_logic;                      -- Transmit Data Valid
      l2p_edb_o    : out std_logic;                      -- Packet termination and discard
      -- L2P Control
      l2p_rdy_i    : in  std_logic;                      -- Tx Buffer Full Flag
      l_wr_rdy_i   : in  std_logic_vector(1 downto 0);   -- Local-to-PCIe Write
      p_rd_d_rdy_i : in  std_logic_vector(1 downto 0);   -- PCIe-to-Local Read Response Data Ready
      tx_error_i   : in  std_logic;                      -- Transmit Error

      ---------------------------------------------------------
      -- Interrupt interface
      dma_irq_o : out std_logic_vector(1 downto 0);  -- Interrupts sources to IRQ manager
      irq_p_i   : in  std_logic;                     -- Interrupt request pulse from IRQ manager
      irq_p_o   : out std_logic;                     -- Interrupt request pulse to GN4124 GPIO

      ---------------------------------------------------------
      -- Target interface (CSR wishbone master)
      wb_clk_i : in  std_logic;
      wb_adr_o : out std_logic_vector(g_BAR0_APERTURE-log2_ceil(g_CSR_WB_SLAVES_NB+1)-1 downto 0);
      wb_dat_o : out std_logic_vector(31 downto 0);                         -- Data out
      wb_sel_o : out std_logic_vector(3 downto 0);                          -- Byte select
      wb_stb_o : out std_logic;
      wb_we_o  : out std_logic;
      wb_cyc_o : out std_logic_vector(g_CSR_WB_SLAVES_NB-1 downto 0);
      wb_dat_i : in  std_logic_vector((32*g_CSR_WB_SLAVES_NB)-1 downto 0);  -- Data in
      wb_ack_i : in  std_logic_vector(g_CSR_WB_SLAVES_NB-1 downto 0);

      ---------------------------------------------------------
      -- DMA interface (Pipelined wishbone master)
      dma_clk_i   : in  std_logic;
      dma_adr_o   : out std_logic_vector(31 downto 0);
      dma_dat_o   : out std_logic_vector(31 downto 0);                         -- Data out
      dma_sel_o   : out std_logic_vector(3 downto 0);                          -- Byte select
      dma_stb_o   : out std_logic;
      dma_we_o    : out std_logic;
      dma_cyc_o   : out std_logic;                                             --_vector(g_DMA_WB_SLAVES_NB-1 downto 0);
      dma_dat_i   : in  std_logic_vector((32*g_DMA_WB_SLAVES_NB)-1 downto 0);  -- Data in
      dma_ack_i   : in  std_logic;                                             --_vector(g_DMA_WB_SLAVES_NB-1 downto 0);
      dma_stall_i : in  std_logic--_vector(g_DMA_WB_SLAVES_NB-1 downto 0)        -- for pipelined Wishbone
      );
    end component;

--used to generate the one_hz_p pulse
constant sim_clock_period       : std_logic_vector(g_width-1 downto 0):=x"0001E848"; -- 1 ms at 125 MHz (tdc board clock)
constant syn_clock_period       : std_logic_vector(g_width-1 downto 0):=x"07735940"; -- 1 s at 125 MHz (tdc board clock)
-- used for regular blinking of the red led
constant spec_led_period_sim    : std_logic_vector(g_width-1 downto 0):=x"00004E20"; -- 1 ms at 20 MHz (spec board clock)
constant spec_led_period_syn    : std_logic_vector(g_width-1 downto 0):=x"01312D00"; -- 1 s at 20 MHz (spec board clock)

signal spec_led_period          : std_logic_vector(g_width-1 downto 0);
signal tdc_led_count_done       : std_logic;
signal spec_led_count_done      : std_logic;

-- will be registers of the core
signal pulse_delay              : std_logic_vector(g_width-1 downto 0);
signal clock_period             : std_logic_vector(g_width-1 downto 0);

signal gnum_reset               : std_logic;
signal pll_cs                   : std_logic;
signal spec_clk                 : std_logic;

signal tdc_led_status           : std_logic:='0';
signal tdc_led_trig1            : std_logic:='0';
signal tdc_led_trig2            : std_logic:='0';
signal tdc_led_trig3            : std_logic:='0';
signal tdc_led_trig4            : std_logic:='0';
signal tdc_led_trig5            : std_logic:='0';
signal spec_led_green           : std_logic:='0';
signal spec_led_red             : std_logic:='0';

signal acam_errflag_p           : std_logic;
signal acam_intflag_p           : std_logic;
signal acam_refclk              : std_logic;
signal acam_start01             : std_logic_vector(16 downto 0);
signal acam_timestamp           : std_logic_vector(28 downto 0);
signal acam_timestamp_valid     : std_logic;
signal clk                      : std_logic;
signal full_timestamp           : std_logic_vector(3*g_width-1 downto 0);
signal full_timestamp_valid     : std_logic;
signal general_reset            : std_logic;
signal one_hz_p                 : std_logic;
signal start_nb_offset          : std_logic_vector(g_width-1 downto 0);
signal start_timer_reg          : std_logic_vector(7 downto 0);
signal utc_current_time         : std_logic_vector(g_width-1 downto 0);

signal acm_adr                  : std_logic_vector(19 downto 0);
signal acm_cyc                  : std_logic;
signal acm_stb                  : std_logic;
signal acm_we                   : std_logic;
signal acm_ack                  : std_logic;
signal acm_dat_r                : std_logic_vector(g_width-1 downto 0);
signal acm_dat_w                : std_logic_vector(g_width-1 downto 0);

signal dma_irq                  : std_logic_vector(1 downto 0); 
signal irq_p                    : std_logic;                    

signal csr_adr                  : std_logic_vector(18 downto 0);
signal csr_dat_r                : std_logic_vector(31 downto 0);
signal csr_sel                  : std_logic_vector(3 downto 0);
signal csr_stb                  : std_logic;
signal csr_we                   : std_logic;
signal csr_cyc                  : std_logic_vector(0 downto 0);
signal csr_dat_w                : std_logic_vector(31 downto 0);
signal csr_ack                  : std_logic_vector(0 downto 0);

signal dma_adr                  : std_logic_vector(31 downto 0);
signal dma_dat_i                : std_logic_vector(31 downto 0);
signal dma_sel                  : std_logic_vector(3 downto 0);
signal dma_stb                  : std_logic;
signal dma_we                   : std_logic;
signal dma_cyc                  : std_logic;
signal dma_dat_o                : std_logic_vector(31 downto 0);
signal dma_ack                  : std_logic;
signal dma_stall                : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin
    
    one_second_block: one_hz_gen
    generic map(
        g_width             => g_width
    )
    port map(
        acam_refclk_i       => acam_refclk,
        clk_i               => clk,
        clock_period_i      => clock_period,
        pulse_delay_i       => pulse_delay,
        reset_i             => general_reset,
        
        one_hz_p_o          => one_hz_p
    );
    
--    start_nb_block: start_nb_offset_gen
--    generic map(
--        g_width             => g_width
--    )
--    port map(
--        acam_intflag_p_i    => acam_intflag_p,
--        clk_i               => clk,
--        one_hz_p_i          => one_hz_p,
--        reset_i             => general_reset,
--        
--        start_nb_offset_o   => start_nb_offset
--    );
    
--    data_formatting_block: data_formatting
--    generic map(
--        g_width             => g_width
--    )
--    port map(
--        acam_start01_i          => acam_start01,
--        acam_timestamp_i        => acam_timestamp,
--        acam_timestamp_valid_i  => acam_timestamp_valid,
--        clk_i                   => clk_i,
--        reset_i                 => general_reset,
--        start_nb_offset_i       => start_nb_offset,
--        utc_current_time_i      => utc_current_time,
--        
--        full_timestamp_o        => full_timestamp,
--        full_timestamp_valid_o  => full_timestamp_valid
--    );
    
    acam_timing_block: acam_timecontrol_interface
    generic map(
        g_width                 => g_width
    )
    port map(
        -- signals external to the chip: interface with acam
        err_flag_i              => err_flag_i,
        int_flag_i              => int_flag_i,
        
        -- this is the config for acam test, in normal application connect the outputs
        start_dis_o             => open,
        stop_dis_o              => open,
--        start_dis_o             => start_dis_o,
 --       stop_dis_o              => stop_dis_o,
        
        -- signals internal to the chip: interface with other modules
        clk_i                   => clk,
        one_hz_p_i              => one_hz_p,
        reset_i                 => general_reset,
            
        acam_errflag_p_o        => acam_errflag_p,
        acam_intflag_p_o        => acam_intflag_p
    );
    
    acam_data_block: acam_databus_interface
    generic map(
        g_width                 => g_width
    )
    port map(
        -- signals external to the chip: interface with acam
        ef1_i                   => ef1_i,
        ef2_i                   => ef2_i,
        lf1_i                   => lf1_i,
        lf2_i                   => lf2_i,
        
        data_bus_io             => data_bus_io,
        address_o               => address_o,
        cs_n_o                  => cs_n_o,
        oe_n_o                  => oe_n_o,
        rd_n_o                  => rd_n_o,
        wr_n_o                  => wr_n_o,
        
        -- signals internal to the chip: interface with other modules
        clk_i                   => clk,
        reset_i                 => general_reset,
        
        adr_i                   => acm_adr,
        cyc_i                   => acm_cyc,
        dat_i                   => acm_dat_w,
        stb_i                   => acm_stb,
        we_i                    => acm_we,
        
        ack_o                   => acm_ack,
        dat_o                   => acm_dat_r
    );
    
    gnum_interface_block: gn4124_core
    generic map(
        g_CSR_WB_SLAVES_NB      => 1
    )
    port map(
        rst_n_a_i               => rst_n_a_i,
        p2l_pll_locked          => open,
        debug_o                 => open,
        
        p2l_clk_p_i             => p2l_clk_p_i,
        p2l_clk_n_i             => p2l_clk_n_i,
        p2l_data_i              => p2l_data_i,
        p2l_dframe_i            => p2l_dframe_i,
        p2l_valid_i             => p2l_valid_i,
        p2l_rdy_o               => p2l_rdy_o,
        p_wr_req_i              => p_wr_req_i,
        p_wr_rdy_o              => p_wr_rdy_o,
        rx_error_o              => rx_error_o,
        vc_rdy_i                => vc_rdy_i,
        l2p_clk_p_o             => l2p_clk_p_o,
        l2p_clk_n_o             => l2p_clk_n_o,
        l2p_data_o              => l2p_data_o ,
        l2p_dframe_o            => l2p_dframe_o,
        l2p_valid_o             => l2p_valid_o,
        l2p_edb_o               => l2p_edb_o,
        l2p_rdy_i               => l2p_rdy_i,
        l_wr_rdy_i              => l_wr_rdy_i,
        p_rd_d_rdy_i            => p_rd_d_rdy_i,
        tx_error_i              => tx_error_i,
        irq_p_o                 => irq_p_o,
        
        dma_irq_o               => dma_irq,
        irq_p_i                 => irq_p,

        wb_clk_i                => clk,
        wb_adr_o                => csr_adr,
        wb_dat_o                => csr_dat_w,
        wb_sel_o                => csr_sel,
        wb_stb_o                => csr_stb,
        wb_we_o                 => csr_we,
        wb_cyc_o                => csr_cyc,
        wb_dat_i                => csr_dat_r,
        wb_ack_i                => csr_ack,

        dma_clk_i               => clk,
        dma_adr_o               => dma_adr,
        dma_dat_o               => dma_dat_i,
        dma_sel_o               => dma_sel,
        dma_stb_o               => dma_stb,
        dma_we_o                => dma_we,
        dma_cyc_o               => dma_cyc,
        dma_dat_i               => dma_dat_O,
        dma_ack_i               => dma_ack,
        dma_stall_i             => dma_stall
    );

    clocks_and_resets_management_block: clk_rst_managr
    port map(
        acam_refclk_i       => acam_refclk_i,
        pll_ld_i            => pll_ld_i,
        pll_refmon_i        => pll_refmon_i,
        pll_sdo_i           => pll_sdo_i,
        pll_status_i        => pll_status_i,
        gnum_reset_i        => gnum_reset,
        spec_clk_i          => spec_clk_i,
        tdc_clk_p_i         => tdc_clk_p_i,
        tdc_clk_n_i         => tdc_clk_n_i,
        
        acam_refclk_o       => acam_refclk,
        general_reset_o     => general_reset,
        pll_cs_o            => pll_cs,
        pll_dac_sync_o      => pll_dac_sync_o,
        pll_sdi_o           => pll_sdi_o,
        pll_sclk_o          => pll_sclk_o,
        spec_clk_o          => spec_clk,
        tdc_clk_o           => clk
    );
    
    spec_led_counter: free_counter
    port map(
        clk                 => spec_clk,
        enable              => '1',
        reset               => gnum_reset,
        start_value         => spec_led_period,
        
        count_done          => spec_led_count_done,
        current_value       => open
    );
    
    spec_led_period         <= spec_led_period_sim when values_for_simulation
                                else spec_led_period_syn;
    
    spec_led: process
    begin
        if spec_led_count_done ='1' then
            spec_led_red        <= not(spec_led_red);
        end if;
        wait until spec_clk ='1';
    end process;
    
    spec_led_green          <= pll_ld_i;

    tdc_led_counter: countdown_counter
    port map(
        clk                 => clk,
        reset               => general_reset,
        start               => one_hz_p,
        start_value         => visible_blink_length,
        
        count_done          => tdc_led_count_done,
        current_value       => open
    );

    tdc_led_status      <= not(tdc_led_count_done);
        
    -- inputs
    gnum_reset              <= not(rst_n_a_i);

    -- internal signals
    acm_adr(19)             <= '0';
    acm_adr(18 downto 0)    <= csr_adr;
    acm_cyc                 <= csr_cyc(0);
    acm_stb                 <= csr_stb;
    acm_we                  <= csr_we;
    acm_dat_w               <= csr_dat_w;
    csr_ack(0)              <= acm_ack;
    csr_dat_r               <= acm_dat_r;
    
    -- outputs
    pll_cs_o                <= pll_cs;

    tdc_led_status_o        <= tdc_led_status;
    tdc_led_trig1_o         <= tdc_led_trig1;
    tdc_led_trig2_o         <= tdc_led_trig2;
    tdc_led_trig3_o         <= tdc_led_trig3;
    tdc_led_trig4_o         <= tdc_led_trig4;
    tdc_led_trig5_o         <= tdc_led_trig5;
    spec_led_green_o        <= spec_led_green;
    spec_led_red_o          <= spec_led_red;
    
    -- this is the config for acam test...
    clock_period            <= sim_clock_period when values_for_simulation
                                else syn_clock_period;

    pulse_delay             <= x"00000000";

    start_dis_o             <= '0';
    stop_dis_o              <= '0';
    start_from_fpga_o       <= one_hz_p when spec_aux1_i ='0' else not(spec_aux0_i);
    spec_aux2_o             <= spec_aux0_i;
    spec_aux3_o             <= spec_aux1_i;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
