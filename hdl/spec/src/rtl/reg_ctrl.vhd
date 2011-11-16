----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : Register control block including RAM memory for storage (reg_ctrl)
--  author      : G. Penacoba
--  date        : Oct 2011
--  version     : Revision 1
--  description : Interfaces with the CSR wishbone bus of the GNUM core. Holds the configuration
--                and status registers for the ACAM and other modules of the TDC core.
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

----------------------------------------------------------------------------------------------------
--  entity declaration for reg_ctrl
----------------------------------------------------------------------------------------------------
entity reg_ctrl is
    generic(
        g_span                      : integer :=32;
        g_width                     : integer :=32
    );
    port(
        -- wishbone classic slave signals to interface with the host through the gnum core and the gnum chip
        clk                         : in std_logic;
        reg_reset_i                 : in std_logic;

        reg_adr_i                   : in std_logic_vector(g_span-1 downto 0);
        reg_cyc_i                   : in std_logic;
        reg_dat_i                   : in std_logic_vector(g_width-1 downto 0);
        reg_stb_i                   : in std_logic;
        reg_we_i                    : in std_logic;

        reg_ack_o                   : out std_logic;
        reg_dat_o                   : out std_logic_vector(g_width-1 downto 0);

        -- control signals for interface with other internal modules
        activate_acq_o              : out std_logic;
        deactivate_acq_o            : out std_logic;
        load_acam_config_o          : out std_logic;
        read_acam_config_o          : out std_logic;
        read_acam_status_o          : out std_logic;
        read_ififo1_o               : out std_logic;
        read_ififo2_o               : out std_logic;
        read_start01_o              : out std_logic;
        reset_acam_o                : out std_logic;
        load_utc_o                  : out std_logic;
        clear_dacapo_counter_o      : out std_logic;
        
        -- configuration registers from and for the ACAM and the modules of the TDC core
        acam_config_rdbk_i          : in config_vector;
        acam_status_i               : in std_logic_vector(g_width-1 downto 0);
        acam_ififo1_i               : in std_logic_vector(g_width-1 downto 0);
        acam_ififo2_i               : in std_logic_vector(g_width-1 downto 0);
        acam_start01_i              : in std_logic_vector(g_width-1 downto 0);
        local_utc_i                 : in std_logic_vector(g_width-1 downto 0);
        irq_code_i                  : in std_logic_vector(g_width-1 downto 0);
        wr_index_i                  : in std_logic_vector(g_width-1 downto 0);
        core_status_i               : in std_logic_vector(g_width-1 downto 0);

        acam_config_o               : out config_vector;
        starting_utc_o              : out std_logic_vector(g_width-1 downto 0);
        in_en_ctrl_o                : out std_logic_vector(g_width-1 downto 0);
        start_phase_o               : out std_logic_vector(g_width-1 downto 0);
        one_hz_phase_o              : out std_logic_vector(g_width-1 downto 0)
    );
end reg_ctrl;

----------------------------------------------------------------------------------------------------
--  architecture declaration for reg_ctrl
----------------------------------------------------------------------------------------------------
architecture rtl of reg_ctrl is

signal reg_ack                      : std_logic;
signal reg_adr                      : std_logic_vector(7 downto 0);
signal reg_cyc                      : std_logic;
signal reg_data_rd                  : std_logic_vector(g_width-1 downto 0);
signal reg_data_wr                  : std_logic_vector(g_width-1 downto 0);
signal reg_en                       : std_logic;
signal reg_reset                    : std_logic;
signal reg_stb                      : std_logic;
signal reg_we                       : std_logic;

signal acam_config_rdbk             : config_vector;
signal acam_status                  : std_logic_vector(g_width-1 downto 0);
signal acam_ififo1                  : std_logic_vector(g_width-1 downto 0);
signal acam_ififo2                  : std_logic_vector(g_width-1 downto 0);
signal acam_start01                 : std_logic_vector(g_width-1 downto 0);
signal core_status                  : std_logic_vector(g_width-1 downto 0);
signal irq_code                     : std_logic_vector(g_width-1 downto 0);
signal local_utc                    : std_logic_vector(g_width-1 downto 0);
signal wr_index                     : std_logic_vector(g_width-1 downto 0);

signal acam_config                  : config_vector;
signal starting_utc                 : std_logic_vector(g_width-1 downto 0);
signal in_en_ctrl                   : std_logic_vector(g_width-1 downto 0);
signal start_phase                  : std_logic_vector(g_width-1 downto 0);
signal one_hz_phase                 : std_logic_vector(g_width-1 downto 0);

signal control_register             : std_logic_vector(g_width-1 downto 0);
signal clear_ctrl_reg               : std_logic;

----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin

    -- Wishbone classic interface compatible slave for the side of the communication with the host
    csr_interface: process
    begin
        if reg_reset ='1' then
            reg_ack                 <= '0';
        else
            reg_ack                 <= reg_stb and reg_cyc;
        end if;
        wait until clk ='1';
    end process;
    
    -- config registers for ACAM
    acam_config_reg: process
    begin
        if reg_reset ='1' then
            acam_config(0)          <= (others =>'0');
            acam_config(1)          <= (others =>'0');
            acam_config(2)          <= (others =>'0');
            acam_config(3)          <= (others =>'0');
            acam_config(4)          <= (others =>'0');
            acam_config(5)          <= (others =>'0');
            acam_config(6)          <= (others =>'0');
            acam_config(7)          <= (others =>'0');
            acam_config(8)          <= (others =>'0');
            acam_config(9)          <= (others =>'0');
            acam_config(10)         <= (others =>'0');
        elsif reg_cyc ='1'      and reg_stb ='1'    and reg_we ='1' then

            if reg_adr = c_acam_adr_reg0 then
                acam_config(0)      <= reg_data_wr;
            end if;

            if reg_adr = c_acam_adr_reg1 then
                acam_config(1)      <= reg_data_wr;
            end if;

            if reg_adr = c_acam_adr_reg2 then
                acam_config(2)      <= reg_data_wr;
            end if;

            if reg_adr = c_acam_adr_reg3 then
                acam_config(3)      <= reg_data_wr;
            end if;

            if reg_adr = c_acam_adr_reg4 then
                acam_config(4)      <= reg_data_wr;
            end if;

            if reg_adr = c_acam_adr_reg5 then
                acam_config(5)      <= reg_data_wr;
            end if;

            if reg_adr = c_acam_adr_reg6 then
                acam_config(6)      <= reg_data_wr;
            end if;

            if reg_adr = c_acam_adr_reg7 then
                acam_config(7)      <= reg_data_wr;
            end if;

            if reg_adr = c_acam_adr_reg11 then
                acam_config(8)      <= reg_data_wr;
            end if;

            if reg_adr = c_acam_adr_reg12 then
                acam_config(9)      <= reg_data_wr;
            end if;

            if reg_adr = c_acam_adr_reg14 then
                acam_config(10)     <= reg_data_wr;
            end if;
        end if;
        wait until clk ='1';
    end process;

   -- config registers for TDC core
    core_config_reg: process
    begin
        if reg_reset ='1' then
            starting_utc            <= (others =>'0');
            in_en_ctrl              <= (others =>'0');
            start_phase             <= (others =>'0');
            one_hz_phase            <= (others =>'0');
        elsif reg_cyc ='1'      and reg_stb ='1'    and reg_we ='1' then

            if reg_adr = c_starting_utc_adr then
                starting_utc        <= reg_data_wr;
            end if;

            if reg_adr = c_in_en_ctrl_adr then
                in_en_ctrl          <= reg_data_wr;
            end if;

            if reg_adr = c_start_phase_adr then
                start_phase         <= reg_data_wr;
            end if;

            if reg_adr = c_one_hz_phase_adr then
                one_hz_phase        <= reg_data_wr;
            end if;

        end if;
        wait until clk ='1';
    end process;
    
    -- control register for TDC core:
    -- written from the PCIe host to control the data_engine state machine.
    -- the contents are cleared after one clock cycle.
    -- only one bit should be written at a time.
    
    control_reg: process
    begin
        if reg_reset ='1' then
            control_register        <= (others =>'0');
            clear_ctrl_reg          <= '0';

        elsif clear_ctrl_reg ='1' then
            control_register        <= (others =>'0');
            clear_ctrl_reg          <= '0';

        elsif reg_cyc ='1' and reg_stb ='1' and reg_we ='1' then
            if reg_adr = c_control_register_adr then
                control_register    <= reg_data_wr;
                clear_ctrl_reg      <= '1';

            end if;
        end if;
        wait until clk ='1';
    end process;
    
    -- All control and status registers read back
    with reg_adr select
        reg_data_rd         <=  acam_config(0)          when c_acam_adr_reg0,
                                acam_config(1)          when c_acam_adr_reg1,
                                acam_config(2)          when c_acam_adr_reg2,
                                acam_config(3)          when c_acam_adr_reg3,
                                acam_config(4)          when c_acam_adr_reg4,
                                acam_config(5)          when c_acam_adr_reg5,
                                acam_config(6)          when c_acam_adr_reg6,
                                acam_config(7)          when c_acam_adr_reg7,

                                acam_config(8)          when c_acam_adr_reg11,
                                acam_config(9)          when c_acam_adr_reg12,
                                acam_config(10)         when c_acam_adr_reg14,
                                
                                acam_config_rdbk(0)     when c_acam_adr_reg0_rdbk,
                                acam_config_rdbk(1)     when c_acam_adr_reg1_rdbk,
                                acam_config_rdbk(2)     when c_acam_adr_reg2_rdbk,
                                acam_config_rdbk(3)     when c_acam_adr_reg3_rdbk,
                                acam_config_rdbk(4)     when c_acam_adr_reg4_rdbk,
                                acam_config_rdbk(5)     when c_acam_adr_reg5_rdbk,
                                acam_config_rdbk(6)     when c_acam_adr_reg6_rdbk,
                                acam_config_rdbk(7)     when c_acam_adr_reg7_rdbk,

                                acam_ififo1             when c_acam_adr_reg8_rdbk,
                                acam_ififo2             when c_acam_adr_reg9_rdbk,
                                acam_start01            when c_acam_adr_reg10_rdbk,

                                acam_config_rdbk(8)     when c_acam_adr_reg11_rdbk,
                                acam_config_rdbk(9)     when c_acam_adr_reg12_rdbk,
                                acam_config_rdbk(10)    when c_acam_adr_reg14_rdbk,
                                
                                starting_utc            when c_starting_utc_adr,
                                in_en_ctrl              when c_in_en_ctrl_adr,
                                start_phase             when c_start_phase_adr,
                                one_hz_phase            when c_one_hz_phase_adr,

--                              RESERVED                when x"24",

                                local_utc               when c_local_utc_adr,
                                irq_code                when c_irq_code_adr,
                                wr_index                when c_wr_index_adr,
                                core_status             when c_core_status_adr,
                                x"FFFFFFFF"             when others;

    -- inputs
    reg_reset                   <= reg_reset_i;

    reg_adr                     <= reg_adr_i(7 downto 0);
    reg_cyc                     <= reg_cyc_i;
    reg_data_wr                 <= reg_dat_i;
    reg_en                      <= reg_cyc;
    reg_stb                     <= reg_stb_i;
    reg_we                      <= reg_we_i;
    
    acam_config_rdbk            <= acam_config_rdbk_i;
    acam_status                 <= acam_status_i;
    acam_ififo1                 <= acam_ififo1_i;
    acam_ififo2                 <= acam_ififo2_i;
    acam_start01                <= acam_start01_i;

    local_utc                   <= local_utc_i;
    irq_code                    <= irq_code_i;
    wr_index                    <= wr_index_i;
    core_status                 <= core_status_i;
    
    -- outputs
    reg_ack_o                   <= reg_ack;
    reg_dat_o                   <= reg_data_rd;

    acam_config_o               <= acam_config;
    activate_acq_o              <= control_register(0);
    deactivate_acq_o            <= control_register(1);
    load_acam_config_o          <= control_register(2);
    read_acam_config_o          <= control_register(3);
    read_acam_status_o          <= control_register(4);
    read_ififo1_o               <= control_register(5);
    read_ififo2_o               <= control_register(6);
    read_start01_o              <= control_register(7);
    reset_acam_o                <= control_register(8);
    load_utc_o                  <= control_register(9);
    clear_dacapo_counter_o      <= control_register(10);

    starting_utc_o              <= starting_utc;
    in_en_ctrl_o                <= in_en_ctrl;
    start_phase_o               <= start_phase;
    one_hz_phase_o              <= one_hz_phase;
        
end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
