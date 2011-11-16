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
        g_span                  : integer :=32;                     -- address span in bus interfaces
        g_width                 : integer :=32;                     -- data width in bus interfaces
        values_for_simulation   : boolean :=FALSE                   -- this generic is set to TRUE
    );                                                              -- when instantiated in a test-bench
    port(
        -- interface with GNUM
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
        err_flag_i              : in std_logic;                     -- error flag signal coming from ACAM
        int_flag_i              : in std_logic;                     -- interrupt flag signal coming from ACAM

        start_dis_o             : out std_logic;                    -- start disable signal for ACAM
        start_from_fpga_o       : out std_logic;                    -- start signal for ACAM
        stop_dis_o              : out std_logic;                    -- stop disable signal for ACAM

        -- interface signals with acam (data) on TDC mezzanine
        data_bus_io             : inout std_logic_vector(27 downto 0);
        ef1_i                   : in std_logic;                     -- empty flag iFIFO1 signal from ACAM
        ef2_i                   : in std_logic;                     -- empty flag iFIFO2 signal from ACAM
        lf1_i                   : in std_logic;                     -- load flag iFIFO1 signal from ACAM
        lf2_i                   : in std_logic;                     -- load flag iFIFO2 signal from ACAM

        address_o               : out std_logic_vector(3 downto 0);
        cs_n_o                  : out std_logic;                    -- chip select for ACAM
        oe_n_o                  : out std_logic;                    -- output enable for ACAM
        rd_n_o                  : out std_logic;                    -- read signal for ACAM
        wr_n_o                  : out std_logic;                    -- write signal for ACAM
        
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
        
        -- other signals on the SPEC carrier
        spec_aux0_i             : in std_logic;                     -- buttons on spec card
        spec_aux1_i             : in std_logic;                     --
        spec_aux2_o             : out std_logic;                    -- red leds on spec PCB
        spec_aux3_o             : out std_logic;                    --
        spec_aux4_o             : out std_logic;                    --
        spec_aux5_o             : out std_logic;                    --
        spec_led_green_o        : out std_logic;                    -- green led on spec front pannel
        spec_led_red_o          : out std_logic;                    -- red led on spec front pannel
        spec_clk_i              : in std_logic                      -- 20 MHz clock from VCXO on spec card
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
        acam_refclk_edge_p_i    : in std_logic;
        clk                     : in std_logic;
        clock_period_i          : in std_logic_vector(g_width-1 downto 0);
        load_utc_i              : in std_logic;
        pulse_delay_i           : in std_logic_vector(g_width-1 downto 0);
        reset_i                 : in std_logic;
        starting_utc_i          : in std_logic_vector(g_width-1 downto 0);

        local_utc_o             : out std_logic_vector(g_width-1 downto 0);
        one_hz_p_o              : out std_logic
    );
    end component;

    component acam_timecontrol_interface
    generic(
        g_width                 : integer :=32
    );
    port(
        -- signals external to the chip: interface with acam
        err_flag_i              : in std_logic;
        int_flag_i              : in std_logic;

        start_dis_o             : out std_logic;
        start_from_fpga_o       : out std_logic;
        stop_dis_o              : out std_logic;

        -- signals internal to the chip: interface with other modules
        acam_refclk_edge_p_i    : in std_logic;
        clk                     : in std_logic;
        start_trig_i            : in std_logic;
        reset_i                 : in std_logic;
        window_delay_i          : in std_logic_vector(g_width-1 downto 0);
        
        acam_rise_errflag_p_o   : out std_logic;
        acam_fall_errflag_p_o   : out std_logic;
        acam_rise_intflag_p_o   : out std_logic;
        acam_fall_intflag_p_o   : out std_logic
    );
    end component;

    component acam_databus_interface
    generic(
        g_span                  : integer :=32;
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

        acam_ef1_o              : out std_logic;
        acam_ef1_meta_o         : out std_logic;
        acam_ef2_o              : out std_logic;
        acam_ef2_meta_o         : out std_logic;
        acam_lf1_o              : out std_logic;
        acam_lf2_o              : out std_logic;

        clk                     : in std_logic;
        reset_i                 : in std_logic;

        adr_i                   : in std_logic_vector(g_span-1 downto 0);
        cyc_i                   : in std_logic;
        dat_i                   : in std_logic_vector(g_width-1 downto 0);
        stb_i                   : in std_logic;
        we_i                    : in std_logic;

        ack_o                   : out std_logic;
        dat_o                   : out std_logic_vector(g_width-1 downto 0)
    );
    end component;

    component start_retrigger_control is
    generic(
        g_width                 : integer :=32
    );
    port(
        acam_rise_intflag_p_i   : in std_logic;
        acam_fall_intflag_p_i   : in std_logic;
        clk                     : in std_logic;
        one_hz_p_i              : in std_logic;
        reset_i                 : in std_logic;
        retrig_period_i         : in std_logic_vector(g_width-1 downto 0);
        
        clk_cycles_offset_o     : out std_logic_vector(g_width-1 downto 0);
        current_roll_over_o     : out std_logic_vector(g_width-1 downto 0);
        retrig_nb_offset_o      : out std_logic_vector(g_width-1 downto 0)
    );
    end component;

    component data_engine
    generic(
        g_span                  : integer :=32;
        g_width                 : integer :=32
    );
    port(
        -- wishbone master signals internal to the chip: interface with other modules
        ack_i                   : in std_logic;
        dat_i                   : in std_logic_vector(g_width-1 downto 0);

        adr_o                   : out std_logic_vector(g_span-1 downto 0);
        cyc_o                   : out std_logic;
        dat_o                   : out std_logic_vector(g_width-1 downto 0);
        stb_o                   : out std_logic;
        we_o                    : out std_logic;
        
        -- signals internal to the chip: interface with other modules
        clk                     : in std_logic;
        reset_i                 : in std_logic;
        acam_ef1_i              : in std_logic;
        acam_ef1_meta_i         : in std_logic;
        acam_ef2_i              : in std_logic;
        acam_ef2_meta_i         : in std_logic;

        activate_acq_i          : in std_logic;
        deactivate_acq_i        : in std_logic;
        load_acam_config_i      : in std_logic;
        read_acam_config_i      : in std_logic;
        read_acam_status_i      : in std_logic;
        read_ififo1_i           : in std_logic;
        read_ififo2_i           : in std_logic;
        read_start01_i          : in std_logic;
        reset_acam_i            : in std_logic;
        acam_config_i           : in config_vector;
        
        acam_config_rdbk_o      : out config_vector;
        acam_status_o           : out std_logic_vector(g_width-1 downto 0);
        acam_ififo1_o           : out std_logic_vector(g_width-1 downto 0);
        acam_ififo2_o           : out std_logic_vector(g_width-1 downto 0);
        acam_start01_o          : out std_logic_vector(g_width-1 downto 0);
        acam_timestamp1_o       : out std_logic_vector(g_width-1 downto 0);
        acam_timestamp1_valid_o : out std_logic;
        acam_timestamp2_o       : out std_logic_vector(g_width-1 downto 0);
        acam_timestamp2_valid_o : out std_logic
    );
    end component;

    component data_formatting
    generic(
        g_retrig_period_shift   : integer :=8;
        g_span                  : integer :=32;
        g_width                 : integer :=32
    );
    port(
        -- wishbone master signals internal to the chip: interface with the circular buffer
        ack_i                   : in std_logic;
        dat_i                   : in std_logic_vector(4*g_width-1 downto 0);

        adr_o                   : out std_logic_vector(g_span-1 downto 0);
        cyc_o                   : out std_logic;
        dat_o                   : out std_logic_vector(4*g_width-1 downto 0);
        stb_o                   : out std_logic;
        we_o                    : out std_logic;
        
        -- signals internal to the chip: interface with other modules
        acam_timestamp1_i       : in std_logic_vector(g_width-1 downto 0);
        acam_timestamp1_valid_i : in std_logic;
        acam_timestamp2_i       : in std_logic_vector(g_width-1 downto 0);
        acam_timestamp2_valid_i : in std_logic;
        clk                     : in std_logic;
        clear_dacapo_counter_i  : in std_logic;
        reset_i                 : in std_logic;
        clk_cycles_offset_i     : in std_logic_vector(g_width-1 downto 0);
        current_roll_over_i     : in std_logic_vector(g_width-1 downto 0);
        local_utc_i             : in std_logic_vector(g_width-1 downto 0);
        retrig_nb_offset_i      : in std_logic_vector(g_width-1 downto 0);

        wr_index_o              : out std_logic_vector(g_width-1 downto 0)
    );
    end component;

    component circular_buffer
    generic(
        g_span                  : integer :=32;
        g_width                 : integer :=32
    );
    port(
        -- wishbone classic slave signals to interface RAM with the modules providing the timestamps
        clk                     : in std_logic;
        class_reset_i           : in std_logic;

        class_adr_i             : in std_logic_vector(g_span-1 downto 0);
        class_cyc_i             : in std_logic;
        class_dat_i             : in std_logic_vector(4*g_width-1 downto 0);
        class_stb_i             : in std_logic;
        class_we_i              : in std_logic;

        class_ack_o             : out std_logic;
        class_dat_o             : out std_logic_vector(4*g_width-1 downto 0);

        -- wishbone pipelined slave signals to interface RAM with gnum core for DMA access from PCI-e
        pipe_reset_i            : in std_logic;

        pipe_adr_i              : in std_logic_vector(g_span-1 downto 0);
        pipe_cyc_i              : in std_logic;
        pipe_dat_i              : in std_logic_vector(g_width-1 downto 0);
        pipe_stb_i              : in std_logic;
        pipe_we_i               : in std_logic;

        pipe_ack_o              : out std_logic;
        pipe_dat_o              : out std_logic_vector(g_width-1 downto 0);
        pipe_stall_o            : out std_logic
    );
    end component;

    component reg_ctrl
    generic(
        g_span                  : integer :=32;
        g_width                 : integer :=32
    );
    port(
        -- wishbone classic slave signals to interface with the host through the gnum core and the gnum chip
        clk                     : in std_logic;
        reg_reset_i             : in std_logic;

        reg_adr_i               : in std_logic_vector(g_span-1 downto 0);
        reg_cyc_i               : in std_logic;
        reg_dat_i               : in std_logic_vector(g_width-1 downto 0);
        reg_stb_i               : in std_logic;
        reg_we_i                : in std_logic;

        reg_ack_o               : out std_logic;
        reg_dat_o               : out std_logic_vector(g_width-1 downto 0);

        -- control signals for interface with other internal modules
        activate_acq_o          : out std_logic;
        deactivate_acq_o        : out std_logic;
        load_acam_config_o      : out std_logic;
        read_acam_config_o      : out std_logic;
        read_acam_status_o      : out std_logic;
        read_ififo1_o           : out std_logic;
        read_ififo2_o           : out std_logic;
        read_start01_o          : out std_logic;
        reset_acam_o            : out std_logic;
        load_utc_o              : out std_logic;
        clear_dacapo_counter_o  : out std_logic;
        
        -- configuration registers from and for the ACAM and the modules of the TDC core
        acam_config_rdbk_i      : in config_vector;
        acam_status_i           : in std_logic_vector(g_width-1 downto 0);
        acam_ififo1_i           : in std_logic_vector(g_width-1 downto 0);
        acam_ififo2_i           : in std_logic_vector(g_width-1 downto 0);
        acam_start01_i          : in std_logic_vector(g_width-1 downto 0);
        local_utc_i             : in std_logic_vector(g_width-1 downto 0);
        irq_code_i              : in std_logic_vector(g_width-1 downto 0);
        core_status_i           : in std_logic_vector(g_width-1 downto 0);
        wr_index_i              : in std_logic_vector(g_width-1 downto 0);

        acam_config_o           : out config_vector;
        starting_utc_o          : out std_logic_vector(g_width-1 downto 0);
        in_en_ctrl_o            : out std_logic_vector(g_width-1 downto 0);
        start_phase_o           : out std_logic_vector(g_width-1 downto 0);
        one_hz_phase_o          : out std_logic_vector(g_width-1 downto 0)
    );
    end component;

    component clk_rst_managr
    generic(
        nb_of_reg               : integer:=68;
        values_for_simulation   : boolean:=FALSE
    );
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
        
        acam_refclk_edge_p_o    : out std_logic;
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
    g_BAR0_APERTURE             : integer := 20;     -- BAR0 aperture, defined in GN4124 PCI_BAR_CONFIG register (0x80C)
                                             -- => number of bits to address periph on the board
    g_CSR_WB_SLAVES_NB          : integer := 1;      -- Number of CSR wishbone slaves
    g_DMA_WB_SLAVES_NB          : integer := 1;      -- Number of DMA wishbone slaves
    g_DMA_WB_ADDR_WIDTH         : integer := 26      -- DMA wishbone address bus width
    );
    port
    (
      ---------------------------------------------------------
      -- Control and status
      --
      -- Asynchronous reset from GN4124
      rst_n_a_i                 : in  std_logic;
      -- P2L clock PLL locked
      p2l_pll_locked            : out std_logic;
      -- Debug ouputs
      debug_o                   : out std_logic_vector(7 downto 0);

      ---------------------------------------------------------
      -- P2L Direction
      --
      -- Source Sync DDR related signals
      p2l_clk_p_i               : in  std_logic;                      -- Receiver Source Synchronous Clock+
      p2l_clk_n_i               : in  std_logic;                      -- Receiver Source Synchronous Clock-
      p2l_data_i                : in  std_logic_vector(15 downto 0);  -- Parallel receive data
      p2l_dframe_i              : in  std_logic;                      -- Receive Frame
      p2l_valid_i               : in  std_logic;                      -- Receive Data Valid
      -- P2L Control
      p2l_rdy_o                 : out std_logic;                      -- Rx Buffer Full Flag
      p_wr_req_i                : in  std_logic_vector(1 downto 0);   -- PCIe Write Request
      p_wr_rdy_o                : out std_logic_vector(1 downto 0);   -- PCIe Write Ready
      rx_error_o                : out std_logic;                      -- Receive Error
      vc_rdy_i                  : in  std_logic_vector(1 downto 0);   -- Virtual channel ready

      ---------------------------------------------------------
      -- L2P Direction
      --
      -- Source Sync DDR related signals
      l2p_clk_p_o               : out std_logic;                      -- Transmitter Source Synchronous Clock+
      l2p_clk_n_o               : out std_logic;                      -- Transmitter Source Synchronous Clock-
      l2p_data_o                : out std_logic_vector(15 downto 0);  -- Parallel transmit data
      l2p_dframe_o              : out std_logic;                      -- Transmit Data Frame
      l2p_valid_o               : out std_logic;                      -- Transmit Data Valid
      l2p_edb_o                 : out std_logic;                      -- Packet termination and discard
      -- L2P Control
      l2p_rdy_i                 : in  std_logic;                      -- Tx Buffer Full Flag
      l_wr_rdy_i                : in  std_logic_vector(1 downto 0);   -- Local-to-PCIe Write
      p_rd_d_rdy_i              : in  std_logic_vector(1 downto 0);   -- PCIe-to-Local Read Response Data Ready
      tx_error_i                : in  std_logic;                      -- Transmit Error

      ---------------------------------------------------------
      -- Interrupt interface
      dma_irq_o                 : out std_logic_vector(1 downto 0);  -- Interrupts sources to IRQ manager
      irq_p_i                   : in  std_logic;                     -- Interrupt request pulse from IRQ manager
      irq_p_o                   : out std_logic;                     -- Interrupt request pulse to GN4124 GPIO

      ---------------------------------------------------------
      -- Target interface (CSR wishbone master)
      wb_clk_i                  : in  std_logic;
      wb_adr_o                  : out std_logic_vector(g_BAR0_APERTURE-log2_ceil(g_CSR_WB_SLAVES_NB+1)-1 downto 0);
      wb_dat_o                  : out std_logic_vector(31 downto 0);                         -- Data out
      wb_sel_o                  : out std_logic_vector(3 downto 0);                          -- Byte select
      wb_stb_o                  : out std_logic;
      wb_we_o                   : out std_logic;
      wb_cyc_o                  : out std_logic_vector(g_CSR_WB_SLAVES_NB-1 downto 0);
      wb_dat_i                  : in  std_logic_vector((32*g_CSR_WB_SLAVES_NB)-1 downto 0);  -- Data in
      wb_ack_i                  : in  std_logic_vector(g_CSR_WB_SLAVES_NB-1 downto 0);

      ---------------------------------------------------------
      -- DMA interface (Pipelined wishbone master)
      dma_clk_i                 : in  std_logic;
      dma_adr_o                 : out std_logic_vector(31 downto 0);
      dma_dat_o                 : out std_logic_vector(31 downto 0);                         -- Data out
      dma_sel_o                 : out std_logic_vector(3 downto 0);                          -- Byte select
      dma_stb_o                 : out std_logic;
      dma_we_o                  : out std_logic;
      dma_cyc_o                 : out std_logic;                                             --_vector(g_DMA_WB_SLAVES_NB-1 downto 0);
      dma_dat_i                 : in  std_logic_vector((32*g_DMA_WB_SLAVES_NB)-1 downto 0);  -- Data in
      dma_ack_i                 : in  std_logic;                                             --_vector(g_DMA_WB_SLAVES_NB-1 downto 0);
      dma_stall_i               : in  std_logic--_vector(g_DMA_WB_SLAVES_NB-1 downto 0)        -- for pipelined Wishbone
      );
    end component;

--used to generate the one_hz_p pulse
--constant sim_clock_period       : std_logic_vector(g_width-1 downto 0):=x"0000F424"; -- 500 us at 125 MHz (tdc board clock)
constant c_sim_clock_period     : std_logic_vector(g_width-1 downto 0):=x"0001E848"; -- 1 ms at 125 MHz (tdc board clock)
constant c_syn_clock_period     : std_logic_vector(g_width-1 downto 0):=x"07735940"; -- 1 s at 125 MHz (tdc board clock)

constant c_retrig_period        : std_logic_vector(g_width-1 downto 0):= x"00000040";
constant c_retrig_period_shift  : integer:=6;

constant c_dma_userspace_baseadr: std_logic_vector(31 downto 0):= x"00000000";
constant c_csr_userspace_baseadr: std_logic_vector(18 downto 0):= "010" & x"0000";

signal spec_led_blink_done      : std_logic;
signal spec_led_period_done     : std_logic;
signal spec_led_period          : std_logic_vector(g_width-1 downto 0);
signal tdc_led_blink_done       : std_logic;
signal visible_blink_length     : std_logic_vector(g_width-1 downto 0);

signal pulse_delay              : std_logic_vector(g_width-1 downto 0);
signal window_delay             : std_logic_vector(g_width-1 downto 0);
signal clock_period             : std_logic_vector(g_width-1 downto 0);

signal gnum_reset               : std_logic;
signal gnum_reset_r             : std_logic;

signal spec_led_green           : std_logic;
signal spec_led_red             : std_logic;
signal tdc_led_status           : std_logic;
signal tdc_led_trig1            : std_logic;
signal tdc_led_trig2            : std_logic;
signal tdc_led_trig3            : std_logic;
signal tdc_led_trig4            : std_logic;
signal tdc_led_trig5            : std_logic;

signal acam_ef1                 : std_logic;
signal acam_ef1_meta            : std_logic;
signal acam_ef2                 : std_logic;
signal acam_ef2_meta            : std_logic;
signal acam_lf1                 : std_logic;
signal acam_lf2                 : std_logic;
signal acam_fall_errflag_p      : std_logic;
signal acam_rise_errflag_p      : std_logic;
signal acam_fall_intflag_p      : std_logic;
signal acam_rise_intflag_p      : std_logic;
signal acam_refclk_edge_p       : std_logic;
signal acam_timestamp1          : std_logic_vector(g_width-1 downto 0);
signal acam_timestamp1_valid    : std_logic;
signal acam_timestamp2          : std_logic_vector(g_width-1 downto 0);
signal acam_timestamp2_valid    : std_logic;
signal clk_cycles_offset        : std_logic_vector(g_width-1 downto 0);
signal current_roll_over        : std_logic_vector(g_width-1 downto 0);
signal general_reset            : std_logic;
signal one_hz_p                 : std_logic;
signal retrig_nb_offset         : std_logic_vector(g_width-1 downto 0);

signal acm_adr                  : std_logic_vector(g_span-1 downto 0);
signal acm_cyc                  : std_logic;
signal acm_stb                  : std_logic;
signal acm_we                   : std_logic;
signal acm_ack                  : std_logic;
signal acm_dat_r                : std_logic_vector(g_width-1 downto 0);
signal acm_dat_w                : std_logic_vector(g_width-1 downto 0);

signal dma_irq                  : std_logic_vector(1 downto 0); 
signal irq_p                    : std_logic;                    

signal csr_adr                  : std_logic_vector(18 downto 0);
signal csr_cyc                  : std_logic_vector(0 downto 0);
signal csr_dat_r                : std_logic_vector(31 downto 0);
signal csr_sel                  : std_logic_vector(3 downto 0);
signal csr_stb                  : std_logic;
signal csr_we                   : std_logic;
signal csr_ack                  : std_logic_vector(0 downto 0);
signal csr_dat_w                : std_logic_vector(31 downto 0);

signal dma_adr                  : std_logic_vector(31 downto 0);
signal dma_cyc                  : std_logic;
signal dma_dat_w                : std_logic_vector(31 downto 0);
signal dma_sel                  : std_logic_vector(3 downto 0);
signal dma_stb                  : std_logic;
signal dma_we                   : std_logic;
signal dma_ack                  : std_logic;
signal dma_dat_r                : std_logic_vector(31 downto 0);
signal dma_stall                : std_logic;

signal mem_class_adr            : std_logic_vector(g_span-1 downto 0);
signal mem_class_cyc            : std_logic;
signal mem_class_data_wr        : std_logic_vector(4*g_width-1 downto 0);
signal mem_class_stb            : std_logic;
signal mem_class_we             : std_logic;
signal mem_class_ack            : std_logic;
signal mem_class_data_rd        : std_logic_vector(4*g_width-1 downto 0);
        
signal mem_pipe_adr             : std_logic_vector(g_span-1 downto 0);
signal mem_pipe_cyc             : std_logic;
signal mem_pipe_data_wr         : std_logic_vector(g_width-1 downto 0);
signal mem_pipe_stb             : std_logic;
signal mem_pipe_we              : std_logic;
signal mem_pipe_ack             : std_logic;
signal mem_pipe_data_rd         : std_logic_vector(g_width-1 downto 0);
signal mem_pipe_stall           : std_logic;

signal reg_adr                  : std_logic_vector(g_span-1 downto 0);
signal reg_cyc                  : std_logic;
signal reg_data_wr              : std_logic_vector(g_width-1 downto 0);
signal reg_stb                  : std_logic;
signal reg_we                   : std_logic;
signal reg_ack                  : std_logic;
signal reg_data_rd              : std_logic_vector(g_width-1 downto 0);

signal activate_acq             : std_logic;
signal deactivate_acq           : std_logic;
signal load_acam_config         : std_logic;
signal read_acam_config         : std_logic;
signal read_acam_status         : std_logic;
signal read_ififo1              : std_logic;
signal read_ififo2              : std_logic;
signal read_start01             : std_logic;
signal reset_acam               : std_logic;
signal load_utc                 : std_logic;
signal clear_dacapo_counter     : std_logic;
signal starting_utc             : std_logic_vector(g_width-1 downto 0);
signal in_en_ctrl               : std_logic_vector(g_width-1 downto 0);
signal start_phase              : std_logic_vector(g_width-1 downto 0);
signal one_hz_phase             : std_logic_vector(g_width-1 downto 0);

signal acam_config              : config_vector;
signal acam_config_rdbk         : config_vector;
signal acam_status              : std_logic_vector(g_width-1 downto 0);
signal acam_ififo1              : std_logic_vector(g_width-1 downto 0);
signal acam_ififo2              : std_logic_vector(g_width-1 downto 0);
signal acam_start01             : std_logic_vector(g_width-1 downto 0);

signal local_utc                : std_logic_vector(g_width-1 downto 0);
signal irq_code                 : std_logic_vector(g_width-1 downto 0);
signal wr_index                 : std_logic_vector(g_width-1 downto 0);
signal core_status              : std_logic_vector(g_width-1 downto 0);

signal clk                      : std_logic;
signal spec_clk                 : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin
    
    one_second_block: one_hz_gen
    generic map(
        g_width                 => g_width
    )
    port map(
        acam_refclk_edge_p_i    => acam_refclk_edge_p,
        clk                     => clk,
        clock_period_i          => clock_period,
        load_utc_i              => load_utc,
        pulse_delay_i           => pulse_delay,
        reset_i                 => general_reset,
        starting_utc_i          => starting_utc,
        
        local_utc_o             => local_utc,
        one_hz_p_o              => one_hz_p
    );
    
    acam_timing_block: acam_timecontrol_interface
    generic map(
        g_width                 => g_width
    )
    port map(
        -- signals external to the chip: interface with acam
        err_flag_i              => err_flag_i,
        int_flag_i              => int_flag_i,
        
        -- At the end the disable signals are not used in the current application
        start_dis_o             => start_dis_o,
        start_from_fpga_o       => start_from_fpga_o,
        stop_dis_o              => stop_dis_o,
        
        -- signals internal to the chip: interface with other modules
        acam_refclk_edge_p_i    => acam_refclk_edge_p,
        clk                     => clk,
        start_trig_i            => activate_acq,
        reset_i                 => general_reset,
        window_delay_i          => window_delay,
            
        acam_fall_errflag_p_o   => acam_fall_errflag_p,
        acam_rise_errflag_p_o   => acam_rise_errflag_p,
        acam_fall_intflag_p_o   => acam_fall_intflag_p,
        acam_rise_intflag_p_o   => acam_rise_intflag_p
    );
    
    acam_data_block: acam_databus_interface
    generic map(
        g_span                  => g_span,
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
        
        acam_ef1_o              => acam_ef1,
        acam_ef1_meta_o         => acam_ef1_meta,
        acam_ef2_o              => acam_ef2,
        acam_ef2_meta_o         => acam_ef2_meta,
        acam_lf1_o              => acam_lf1,
        acam_lf2_o              => acam_lf2,

        -- signals internal to the chip: interface with other modules
        clk                     => clk,
        reset_i                 => general_reset,
        
        adr_i                   => acm_adr,
        cyc_i                   => acm_cyc,
        dat_i                   => acm_dat_w,
        stb_i                   => acm_stb,
        we_i                    => acm_we,
        
        ack_o                   => acm_ack,
        dat_o                   => acm_dat_r
    );

    start_retrigger_block: start_retrigger_control
    generic map(
        g_width                 => g_width
    )
    port map(
        acam_fall_intflag_p_i   => acam_fall_intflag_p,
        acam_rise_intflag_p_i   => acam_rise_intflag_p,
        clk                     => clk,
        one_hz_p_i              => one_hz_p,
        reset_i                 => general_reset,
        retrig_period_i         => c_retrig_period,
        
        clk_cycles_offset_o     => clk_cycles_offset,
        current_roll_over_o     => current_roll_over,
        retrig_nb_offset_o      => retrig_nb_offset
    );
    
    data_engine_block: data_engine
    generic map(
        g_span                  => g_span,
        g_width                 => g_width
    )
    port map(
        -- wishbone master signals internal to the chip: interface with the ACAM core
        ack_i                   => acm_ack,
        dat_i                   => acm_dat_r,

        adr_o                   => acm_adr,
        cyc_o                   => acm_cyc,
        dat_o                   => acm_dat_w,
        stb_o                   => acm_stb,
        we_o                    => acm_we,
        
        -- signals internal to the chip: interface with other modules
        clk                     => clk,
        reset_i                 => general_reset,
        acam_ef1_i              => acam_ef1,
        acam_ef1_meta_i         => acam_ef1_meta,
        acam_ef2_i              => acam_ef2,
        acam_ef2_meta_i         => acam_ef2_meta,

        activate_acq_i          => activate_acq,
        deactivate_acq_i        => deactivate_acq,
        load_acam_config_i      => load_acam_config,
        read_acam_config_i      => read_acam_config,
        read_acam_status_i      => read_acam_status,
        read_ififo1_i           => read_ififo1,
        read_ififo2_i           => read_ififo2,
        read_start01_i          => read_start01,
        reset_acam_i            => reset_acam,
        acam_config_i           => acam_config,
        
        acam_config_rdbk_o      => acam_config_rdbk,
        acam_status_o           => acam_status,
        acam_ififo1_o           => acam_ififo1,
        acam_ififo2_o           => acam_ififo2,
        acam_start01_o          => acam_start01,
        acam_timestamp1_o       => acam_timestamp1,
        acam_timestamp1_valid_o => acam_timestamp1_valid,
        acam_timestamp2_o       => acam_timestamp2,
        acam_timestamp2_valid_o => acam_timestamp2_valid
    );
    
    data_formatting_block: data_formatting
    generic map(
        g_retrig_period_shift   => c_retrig_period_shift,
        g_span                  => g_span,
        g_width                 => g_width
    )
    port map(
        -- wishbone master signals internal to the chip: interface with the circular buffer
        ack_i                   => mem_class_ack,
        dat_i                   => mem_class_data_rd,

        adr_o                   => mem_class_adr,
        cyc_o                   => mem_class_cyc,
        dat_o                   => mem_class_data_wr,
        stb_o                   => mem_class_stb,
        we_o                    => mem_class_we,

        -- signals internal to the chip: interface with other modules
        acam_timestamp1_i       => acam_timestamp1,
        acam_timestamp1_valid_i => acam_timestamp1_valid,
        acam_timestamp2_i       => acam_timestamp2,
        acam_timestamp2_valid_i => acam_timestamp2_valid,
        clk                     => clk,
        clear_dacapo_counter_i  => clear_dacapo_counter,
        reset_i                 => general_reset,
        clk_cycles_offset_i     => clk_cycles_offset,
        current_roll_over_i     => current_roll_over,
        retrig_nb_offset_i      => retrig_nb_offset,
        local_utc_i             => local_utc,
        
        wr_index_o              => wr_index
    );
    
    circular_buffer_block: circular_buffer
    generic map(
        g_span                  => g_span,
        g_width                 => g_width
    )
    port map(
        -- wishbone classic slave signals to interface RAM with the internal modules providing the timestamps
        clk                     => clk,
        class_reset_i           => general_reset,
        
        class_adr_i             => mem_class_adr,
        class_cyc_i             => mem_class_cyc,
        class_dat_i             => mem_class_data_wr,
        class_stb_i             => mem_class_stb,
        class_we_i              => mem_class_we,
        
        class_ack_o             => mem_class_ack,
        class_dat_o             => mem_class_data_rd,
        
        -- wishbone pipelined slave signals to interface RAM with gnum core for DMA access from PCI-e
        pipe_reset_i            => general_reset,
        
        pipe_adr_i              => mem_pipe_adr,
        pipe_cyc_i              => mem_pipe_cyc,
        pipe_dat_i              => mem_pipe_data_wr,
        pipe_stb_i              => mem_pipe_stb,
        pipe_we_i               => mem_pipe_we,
        
        pipe_ack_o              => mem_pipe_ack,
        pipe_dat_o              => mem_pipe_data_rd,
        pipe_stall_o            => mem_pipe_stall
    );
    
    reg_control_block: reg_ctrl
    generic map(
        g_span                  => g_span,
        g_width                 => g_width
    )
    port map(
        -- wishbone classic slave signals to interface with the host through the gnum core and the gnum chip
        clk                     => clk,
        reg_reset_i             => general_reset,
        
        reg_adr_i               => reg_adr,
        reg_cyc_i               => reg_cyc,
        reg_dat_i               => reg_data_wr,
        reg_stb_i               => reg_stb,
        reg_we_i                => reg_we,
        
        reg_ack_o               => reg_ack,
        reg_dat_o               => reg_data_rd,
    
        -- control signals for interface with other application internal modules
        activate_acq_o          => activate_acq,
        deactivate_acq_o        => deactivate_acq,
        load_acam_config_o      => load_acam_config,
        read_acam_config_o      => read_acam_config,
        read_acam_status_o      => read_acam_status,
        read_ififo1_o           => read_ififo1,
        read_ififo2_o           => read_ififo2,
        read_start01_o          => read_start01,
        reset_acam_o            => reset_acam,
        load_utc_o              => load_utc,
        clear_dacapo_counter_o  => clear_dacapo_counter,
        
        -- configuration and status registers for the ACAM and the modules of the TDC core
        acam_config_rdbk_i      => acam_config_rdbk,
        acam_status_i           => acam_status,
        acam_ififo1_i           => acam_ififo1,
        acam_ififo2_i           => acam_ififo2,
        acam_start01_i          => acam_start01,
        local_utc_i             => local_utc,
        irq_code_i              => irq_code,
        core_status_i           => core_status,
        wr_index_i              => wr_index,

        acam_config_o           => acam_config,
        starting_utc_o          => starting_utc,
        in_en_ctrl_o            => in_en_ctrl,
        start_phase_o           => window_delay,
        one_hz_phase_o          => pulse_delay
    );
    
    clks_rsts_mgment: clk_rst_managr
    generic map(
        nb_of_reg               => 68,
        values_for_simulation   => values_for_simulation
    )
    port map(
        acam_refclk_i           => acam_refclk_i,
        pll_ld_i                => pll_ld_i,
        pll_refmon_i            => pll_refmon_i,
        pll_sdo_i               => pll_sdo_i,
        pll_status_i            => pll_status_i,
        gnum_reset_i            => gnum_reset,
        spec_clk_i              => spec_clk_i,
        tdc_clk_p_i             => tdc_clk_p_i,
        tdc_clk_n_i             => tdc_clk_n_i,
        
        acam_refclk_edge_p_o    => acam_refclk_edge_p,
        general_reset_o         => general_reset,
        pll_cs_o                => pll_cs_o,
        pll_dac_sync_o          => pll_dac_sync_o,
        pll_sdi_o               => pll_sdi_o,
        pll_sclk_o              => pll_sclk_o,
        spec_clk_o              => spec_clk,
        tdc_clk_o               => clk
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
        wb_cyc_o                => csr_cyc,
        wb_dat_o                => csr_dat_w,
        wb_sel_o                => csr_sel,
        wb_stb_o                => csr_stb,
        wb_we_o                 => csr_we,
        wb_ack_i                => csr_ack,
        wb_dat_i                => csr_dat_r,

        dma_clk_i               => clk,
        dma_adr_o               => dma_adr,
        dma_cyc_o               => dma_cyc,
        dma_dat_o               => dma_dat_w,
        dma_sel_o               => dma_sel,
        dma_stb_o               => dma_stb,
        dma_we_o                => dma_we,
        dma_ack_i               => dma_ack,
        dma_dat_i               => dma_dat_r,
        dma_stall_i             => dma_stall
    );

    spec_led_period_counter: free_counter
    port map(
        clk                     => spec_clk,
        enable                  => '1',
        reset                   => gnum_reset,
        start_value             => spec_led_period,
        
        count_done              => spec_led_period_done,
        current_value           => open
    );
    
    spec_led_blink_counter: countdown_counter
    port map(
        clk                     => spec_clk,
        reset                   => gnum_reset,
        start                   => spec_led_period_done,
        start_value             => visible_blink_length,
        
        count_done              => spec_led_blink_done,
        current_value           => open
    );

    tdc_led_blink_counter: countdown_counter
    port map(
        clk                     => clk,
        reset                   => general_reset,
        start                   => one_hz_p,
        start_value             => visible_blink_length,
        
        count_done              => tdc_led_blink_done,
        current_value           => open
    );

    -- connection of the DMA master port from the GNUM core to the circular buffer slave
    ------------------------------------------------------------------------------------
    -- address decoding: memory used has 1024 bytes depth
    -- (the DMA port of the GNUM core manages address for 8-bit words)
    mem_pipe_cyc                <= '1' when dma_cyc='1' and dma_adr(31 downto 10)= c_dma_userspace_baseadr(31 downto 10) 
                                    else '0';
--    mem_pipe_cyc                <= '1' when dma_cyc='1' and dma_adr(31 downto 10)=x"00000" & "00" else '0';

    mem_pipe_adr                <= dma_adr;

    mem_pipe_stb                <= dma_stb;
    mem_pipe_we                 <= dma_we;
    mem_pipe_data_wr            <= dma_dat_w;
    dma_ack                     <= mem_pipe_ack;
    dma_dat_r                   <= mem_pipe_data_rd;
    dma_stall                   <= mem_pipe_stall;
    
    --  CSR master connected to the register control slave
    ------------------------------------------------------
    -- address decoding: first 512 kB for GNUM core, second 512 kB for TDC application (of which only 256 bytes are reserved)
    -- (the CSR port of the GNUM core already treats addresses for 32-bit words)
    reg_cyc                     <= '1' when csr_cyc(0)='1' and csr_adr(18 downto 8)= c_csr_userspace_baseadr(18 downto 8) 
                                    else '0';
--    reg_cyc                     <= '1' when csr_cyc(0)='1' and csr_adr(18 downto 8)="010" & x"00" else '0';

    reg_adr(31 downto 19)       <= (others=>'0');
    reg_adr(18 downto 0)        <= csr_adr;

    reg_stb                     <= csr_stb;
    reg_we                      <= csr_we;
    reg_data_wr                 <= csr_dat_w;
    csr_ack(0)                  <= reg_ack;
    csr_dat_r                   <= reg_data_rd;
    
    spec_led: process
    begin
        if gnum_reset ='1' then
            spec_led_red        <= '0';
        elsif spec_led_period_done ='1' then
            spec_led_red        <= '1';
        elsif spec_led_blink_done ='1' then
            spec_led_red        <= '0';
        end if;
        wait until spec_clk ='1';
    end process;
    
    tdc_led: process
    begin
        if general_reset ='1' then
            tdc_led_status      <= '0';
        elsif one_hz_p ='1' then
            tdc_led_status      <= '1';
        elsif tdc_led_blink_done = '1' then
            tdc_led_status      <= '0';
        end if;
        wait until clk ='1';
    end process;
    
    spec_led_period             <= spec_led_period_sim when values_for_simulation
                                    else spec_led_period_syn;
    
    visible_blink_length        <= blink_length_sim when values_for_simulation
                                    else blink_length_syn;
    
    clock_period                <= c_sim_clock_period when values_for_simulation
                                    else c_syn_clock_period;

    -- internal signals
    irq_p                       <= dma_irq(0) or dma_irq(1);
    spec_led_green              <= pll_ld_i;

    -- inputs
    sync_gnum_reset: process
    begin
        gnum_reset_r                <= not(rst_n_a_i);
        gnum_reset                  <= gnum_reset_r;
        wait until spec_clk ='1';
    end process;

    -- outputs
    process
    begin
        mute_inputs_o           <= in_en_ctrl(7);
        term_en_5_o             <= in_en_ctrl(4);
        term_en_4_o             <= in_en_ctrl(3);
        term_en_3_o             <= in_en_ctrl(2);
        term_en_2_o             <= in_en_ctrl(1);
        term_en_1_o             <= in_en_ctrl(0);
    
        spec_led_green_o        <= spec_led_green;
        spec_led_red_o          <= spec_led_red;
        tdc_led_status_o        <= tdc_led_status;
        
        tdc_led_trig5_o         <= in_en_ctrl(4) and in_en_ctrl(7);
        tdc_led_trig4_o         <= in_en_ctrl(3) and in_en_ctrl(7);
        tdc_led_trig3_o         <= in_en_ctrl(2) and in_en_ctrl(7);
        tdc_led_trig2_o         <= in_en_ctrl(1) and in_en_ctrl(7);
        tdc_led_trig1_o         <= in_en_ctrl(0) and in_en_ctrl(7);
    wait until clk ='1';
    end process;

    -- note: all spec_aux signals are active low

    button_with_spec_clk: process
    begin
        spec_aux3_o             <= spec_aux0_i;
        spec_aux2_o             <= spec_aux0_i;
        wait until spec_clk ='1';
    end process;
    
    button_with_tdc_clk: process
    begin
        spec_aux4_o             <= spec_aux1_i;
        spec_aux5_o             <= spec_aux1_i;
        wait until clk ='1';
    end process;
    
end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
