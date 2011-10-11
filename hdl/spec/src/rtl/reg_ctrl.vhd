----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : Register control block including RAM memory for storage (reg_ctrl)
--  author      : G. Penacoba
--  date        : Oct 2011
--  version     : Revision 1
--  description : contains the RAM block (64 x 32) and the wishbone classic slave interfaces.
--                Processes the TDC_control register.
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

----------------------------------------------------------------------------------------------------
--  entity declaration for reg_ctrl
----------------------------------------------------------------------------------------------------
entity reg_ctrl is
    generic(
        g_width             : integer :=32
    );
    port(
        -- wishbone classic slave signals to interface the registers with the internal application modules
        appli_clk_i         : in std_logic;
        appli_reset_i       : in std_logic;

        appli_adr_i         : in std_logic_vector(g_width-1 downto 0);
        appli_cyc_i         : in std_logic;
        appli_dat_i         : in std_logic_vector(g_width-1 downto 0);
        appli_stb_i         : in std_logic;
        appli_we_i          : in std_logic;

        appli_ack_o         : out std_logic;
        appli_dat_o         : out std_logic_vector(g_width-1 downto 0);

        -- wishbone classic slave signals to interface with the host through the gnum core and the gnum chip
        host_clk_i          : in std_logic;
        host_reset_i        : in std_logic;

        host_adr_i          : in std_logic_vector(g_width-1 downto 0);
        host_cyc_i          : in std_logic;
        host_dat_i          : in std_logic_vector(g_width-1 downto 0);
        host_stb_i          : in std_logic;
        host_we_i           : in std_logic;

        host_ack_o          : out std_logic;
        host_dat_o          : out std_logic_vector(g_width-1 downto 0);
        
        -- control signals for interface with other application internal modules
        activate_acq_o      : out std_logic;
        deactivate_acq_o    : out std_logic;
        load_utc_o          : out std_logic;
        load_tdc_config_o   : out std_logic;
        load_acam_config_o  : out std_logic;
        read_acam_config_o  : out std_logic;
        reset_acam_o        : out std_logic;
        read_acam_status_o  : out std_logic;
        read_ififo1_o       : out std_logic;
        read_ififo2_o       : out std_logic;
        read_start01_o      : out std_logic;
        
        -- configuration registers for the modules of the TDC core
        starting_utc_time_o : out std_logic_vector(31 downto 0);
        clk_freq_o          : out std_logic_vector(31 downto 0);
        ref_clk_freq_o      : out std_logic_vector(31 downto 0);
        start_phase_o       : out std_logic_vector(31 downto 0);
        one_hz_phase_o      : out std_logic_vector(31 downto 0);
        retrig_freq_o       : out std_logic_vector(31 downto 0)
    );
end reg_ctrl;

----------------------------------------------------------------------------------------------------
--  architecture declaration for reg_ctrl
----------------------------------------------------------------------------------------------------
architecture rtl of reg_ctrl is

component reg_mem_gen_v6_2
    port(
    clka    : in std_logic;
    addra   : in std_logic_vector(5 downto 0);
    dina    : in std_logic_vector(31 downto 0);
    ena     : in std_logic;
    wea     : in std_logic_vector(0 downto 0);
    douta   : out std_logic_vector(31 downto 0);

    clkb    : in std_logic;
    addrb   : in std_logic_vector(5 downto 0);
    dinb    : in std_logic_vector(31 downto 0);
    enb     : in std_logic;
    web     : in std_logic_vector(0 downto 0);
    doutb   : out std_logic_vector(31 downto 0)
    );
end component;

signal appli_ack        : std_logic;
signal appli_adr        : std_logic_vector(5 downto 0);
signal appli_clk        : std_logic;
signal appli_cyc        : std_logic;
signal appli_data_rd    : std_logic_vector(g_width-1 downto 0);
signal appli_data_wr    : std_logic_vector(g_width-1 downto 0);
signal appli_en         : std_logic;
signal appli_reset      : std_logic;
signal appli_stb        : std_logic;
signal appli_we         : std_logic_vector(0 downto 0);

signal host_ack         : std_logic;
signal host_adr         : std_logic_vector(5 downto 0);
signal host_clk         : std_logic;
signal host_cyc         : std_logic;
signal host_data_rd     : std_logic_vector(g_width-1 downto 0);
signal host_data_wr     : std_logic_vector(g_width-1 downto 0);
signal host_en          : std_logic;
signal host_reset       : std_logic;
signal host_stb         : std_logic;
signal host_we          : std_logic_vector(0 downto 0);

signal starting_utc_time        : std_logic_vector(31 downto 0);
signal clk_freq                 : std_logic_vector(31 downto 0);
signal ref_clk_freq             : std_logic_vector(31 downto 0);
signal start_phase              : std_logic_vector(31 downto 0);
signal one_hz_phase             : std_logic_vector(31 downto 0);
signal retrig_freq              : std_logic_vector(31 downto 0);

signal control_register         : std_logic_vector(31 downto 0);
signal clear_ctrl_reg           : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    -- Wishbone classic interface compatible slave for the application side
    application_interface: process
    begin
        if appli_reset ='1' then
            appli_ack           <= '0';
        else
            appli_ack           <= appli_stb and appli_cyc;
        end if;
        wait until appli_clk ='1';
    end process;

    -- Wishbone classic interface compatible slave for the side of the communication with the host
    host_side_interface: process
    begin
        if host_reset ='1' then
            host_ack           <= '0';
        else
            host_ack           <= host_stb and host_cyc;
        end if;
        wait until host_clk ='1';
    end process;
    
    -- config registers for TDC core
    config_reg: process
    begin
        if host_reset ='1' then
            starting_utc_time   <= (others =>'0');
            clk_freq            <= (others =>'0');
            ref_clk_freq        <= (others =>'0');
            start_phase         <= (others =>'0');
            one_hz_phase        <= (others =>'0');
            retrig_freq         <= (others =>'0');
        elsif host_cyc ='1' and host_stb ='1' and host_we(0) ='1' then
            if host_adr = x"20" then
                starting_utc_time   <= host_data_wr;
            end if;
            if host_adr = x"21" then
                clk_freq            <= host_data_wr;
            end if;
            if host_adr = x"22" then
                ref_clk_freq        <= host_data_wr;
            end if;
            if host_adr = x"23" then
                start_phase         <= host_data_wr;
            end if;
            if host_adr = x"24" then
                one_hz_phase        <= host_data_wr;
            end if;
            if host_adr = x"25" then
                retrig_freq         <= host_data_wr;
            end if;
        end if;
        wait until host_clk ='1';
    end process;
    
    -- control register for TDC core
    control_reg: process
    begin
        if host_reset ='1' then
            control_register        <= (others =>'0');
            clear_ctrl_reg          <= '0';
        elsif clear_ctrl_reg ='1' then
            control_register        <= (others =>'0');
            clear_ctrl_reg          <= '0';
        elsif host_cyc ='1' and host_stb ='1' and host_we(0) ='1' then
            if host_adr_i = x"00020040" then            -- address outside of the memory block
                control_register    <= host_data_wr;
                clear_ctrl_reg      <= '1';
            end if;
        end if;
        wait until host_clk ='1';
    end process;
            

    memory_block: reg_mem_gen_v6_2
    port map(
        clka        => appli_clk,
        addra       => appli_adr,
        dina        => appli_data_wr,
        ena         => appli_en,
        wea         => appli_we,
        douta       => appli_data_rd,
        
        clkb        => host_clk,
        addrb       => host_adr,
        dinb        => host_data_wr,
        enb         => host_en,
        web         => host_we,
        doutb       => host_data_rd
    );

    -- inputs from other blocks    
    appli_clk                   <= appli_clk_i;
    appli_reset                 <= appli_reset_i;

    appli_adr                   <= appli_adr_i(5 downto 0);
    appli_cyc                   <= appli_cyc_i;
    appli_data_wr               <= appli_dat_i;
    appli_en                    <= appli_cyc;
    appli_stb                   <= appli_stb_i;
    appli_we(0)                 <= appli_we_i;
    
    host_clk                    <= host_clk_i;
    host_reset                  <= host_reset_i;

    host_adr                    <= host_adr_i(5 downto 0);
    host_cyc                    <= host_cyc_i;
    host_data_wr                <= host_dat_i;
    host_en                     <= host_cyc;
    host_stb                    <= host_stb_i;
    host_we(0)                  <= host_we_i;
    
    -- outputs to other blocks
    appli_ack_o                 <= appli_ack;
    appli_dat_o                 <= appli_data_rd;
    
    host_ack_o                  <= host_ack;
    host_dat_o                  <= host_data_rd;

    activate_acq_o              <= control_register(0);
    deactivate_acq_o            <= control_register(1);
    load_utc_o                  <= control_register(2);
    load_tdc_config_o           <= control_register(3);
    load_acam_config_o          <= control_register(4);
    read_acam_config_o          <= control_register(5);
    reset_acam_o                <= control_register(6);
    read_acam_status_o          <= control_register(8);
    read_ififo1_o               <= control_register(9);
    read_ififo2_o               <= control_register(10);
    read_start01_o              <= control_register(11);

    starting_utc_time_o         <= starting_utc_time;
    clk_freq_o                  <= clk_freq;
    ref_clk_freq_o              <= ref_clk_freq;
    start_phase_o               <= start_phase;
    one_hz_phase_o              <= one_hz_phase;
    retrig_freq_o               <= retrig_freq;
        
end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------



