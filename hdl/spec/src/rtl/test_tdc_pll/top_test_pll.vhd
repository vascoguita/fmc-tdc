----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : PLL test top level (top_tdc.vhd)
--  author      : G. Penacoba
--  date        : June 2011
--  version     : Revision 1
--  description : top level for preliminary testing of the PLL on the TDC card
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
--use work.tdc_core_pkg.all;
--use work.gn4124_core_pkg.all;

----------------------------------------------------------------------------------------------------
--  entity declaration for top_tdc
----------------------------------------------------------------------------------------------------
entity top_tdc is
    generic(
        g_width                 : integer :=32;
        values_for_simulation   : boolean :=FALSE
    );
    port(
        -- interface with GNUM on SPEC carrier
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

    component free_counter is
    generic(
        width           : integer :=32
    );
    port(
        clk             : in std_logic;
        enable          : in std_logic;
        reset           : in std_logic;
        start_value     : in std_logic_vector(width-1 downto 0);

        count_done      : out std_logic;
        current_value   : out std_logic_vector(width-1 downto 0)
    );
    end component;

constant tdc_led_period_sim     : std_logic_vector(g_width-1 downto 0):=x"0000F424"; -- 0.5 ms at 125 MHz (tdc board clock)
constant tdc_led_period_syn     : std_logic_vector(g_width-1 downto 0):=x"03B9ACA0"; -- 0.5 ms at 125 MHz (tdc board clock)
constant spec_led_period_sim    : std_logic_vector(g_width-1 downto 0):=x"00004E20"; -- 1 ms at 20 MHz (spec board clock)
constant spec_led_period_syn    : std_logic_vector(g_width-1 downto 0):=x"01312D00"; -- 1 s at 20 MHz (spec board clock)


signal tdc_led_period           : std_logic_vector(g_width-1 downto 0);
signal spec_led_period          : std_logic_vector(g_width-1 downto 0);
signal tdc_led_count_done       : std_logic;
signal spec_led_count_done      : std_logic;

-- will be registers of the core
signal pulse_delay              : std_logic_vector(g_width-1 downto 0):=x"00000000";
signal clock_period             : std_logic_vector(g_width-1 downto 0):=x"000030D4";

signal gnum_reset               : std_logic;
signal pll_cs                   : std_logic;

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
signal acam_start01             : std_logic_vector(16 downto 0);
signal acam_timestamp           : std_logic_vector(28 downto 0);
signal acam_timestamp_valid     : std_logic;
signal full_timestamp           : std_logic_vector(3*g_width-1 downto 0);
signal full_timestamp_valid     : std_logic;
signal one_hz_p                 : std_logic;
signal general_reset            : std_logic;
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

signal csr_clk                  : std_logic;
signal csr_adr                  : std_logic_vector(18 downto 0);
signal csr_dat_r                : std_logic_vector(31 downto 0);
signal csr_sel                  : std_logic_vector(3 downto 0);
signal csr_stb                  : std_logic;
signal csr_we                   : std_logic;
signal csr_cyc                  : std_logic_vector(0 downto 0);
signal csr_dat_w                : std_logic_vector(31 downto 0);
signal csr_ack                  : std_logic_vector(0 downto 0);

signal dma_clk                  : std_logic;
signal dma_adr                  : std_logic_vector(31 downto 0);
signal dma_dat_i                : std_logic_vector(31 downto 0);
signal dma_sel                  : std_logic_vector(3 downto 0);
signal dma_stb                  : std_logic;
signal dma_we                   : std_logic;
signal dma_cyc                  : std_logic;
signal dma_dat_o                : std_logic_vector(31 downto 0);
signal dma_ack                  : std_logic;
signal dma_stall                : std_logic;

signal acam_refclk              : std_logic;
signal clk                      : std_logic;
signal spec_clk                 : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin
    
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
    
    tdc_led_counter: free_counter
    port map(
        clk                 => clk,
        enable              => '1',
        reset               => general_reset,
        start_value         => tdc_led_period,
        
        count_done          => tdc_led_count_done,
        current_value       => open
    );
    
    tdc_led_period          <= tdc_led_period_sim when values_for_simulation
                                else tdc_led_period_syn;
        
    spec_led_red_counter: free_counter
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
    
    tdc_led: process
    begin
        if tdc_led_count_done ='1' then
            tdc_led_status      <= not(tdc_led_status);
        end if;
        wait until clk='1';
    end process;

    spec_led: process
    begin
        if spec_led_count_done ='1' then
            spec_led_red        <= not(spec_led_red);
        end if;
        wait until spec_clk ='1';
    end process;
    
    spec_led_green          <= pll_ld_i;

    -- inputs
    gnum_reset               <= not(rst_n_a_i);

    -- outputs
    pll_cs_o                <= pll_cs;

    tdc_led_status_o        <= tdc_led_status;
    spec_led_green_o        <= spec_led_green;
    spec_led_red_o          <= spec_led_red;

end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
