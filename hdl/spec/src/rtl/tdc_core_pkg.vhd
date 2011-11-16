----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : Package for TDC core (tdc_core_pkg.vhd)
--  author      : G. Penacoba
--  date        : Jul 2011
--  version     : Revision 1
--  description : Package containing core wide constants and components
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
-- Package declaration
----------------------------------------------------------------------------------------------------
package tdc_core_pkg is

    component countdown_counter
    generic(
        width           : integer :=32
    );
    port(
        clk             : in std_logic;
        reset           : in std_logic;
        start           : in std_logic;
        start_value     : in std_logic_vector(width-1 downto 0);

        count_done      : out std_logic;
        current_value   : out std_logic_vector(width-1 downto 0)
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

    component incr_counter
    generic(
        width           : integer :=32
    );
    port(
        clk             : in std_logic;
        end_value       : in std_logic_vector(width-1 downto 0);
        incr            : in std_logic;
        reset           : in std_logic;

        count_done      : out std_logic;
        current_value   : out std_logic_vector(width-1 downto 0)
    );
    end component;

constant data_width                 : integer:=32;
constant tdc_led_period_sim         : std_logic_vector(data_width-1 downto 0):=x"0000F424";     -- 500 us at 125 MHz
constant tdc_led_period_syn         : std_logic_vector(data_width-1 downto 0):=x"03B9ACA0";     -- 500 ms at 125 MHz
constant spec_led_period_sim        : std_logic_vector(data_width-1 downto 0):=x"00004E20";     -- 1 ms at 20 MHz
constant spec_led_period_syn        : std_logic_vector(data_width-1 downto 0):=x"01312D00";     -- 1 s at 20 MHz
constant blink_length_syn           : std_logic_vector(data_width-1 downto 0):=x"00BEBC20";     -- 100 ms at 125 MHz
constant blink_length_sim           : std_logic_vector(data_width-1 downto 0):=x"000004E2";     -- 10 us at 125 MHz

subtype config_register             is std_logic_vector(data_width-1 downto 0);
type config_vector                  is array (10 downto 0) of config_register;


-- Addresses of ACAM registers to be written from the PCI-e host for configuration
constant c_acam_adr_reg0            : std_logic_vector(7 downto 0):= x"00";     -- corresponds to address 80000 of the gnum BAR 0
constant c_acam_adr_reg1            : std_logic_vector(7 downto 0):= x"01";     -- corresponds to address 80004 of the gnum BAR 0
constant c_acam_adr_reg2            : std_logic_vector(7 downto 0):= x"02";     -- corresponds to address 80008 of the gnum BAR 0
constant c_acam_adr_reg3            : std_logic_vector(7 downto 0):= x"03";     -- corresponds to address 8000C of the gnum BAR 0
constant c_acam_adr_reg4            : std_logic_vector(7 downto 0):= x"04";     -- corresponds to address 80010 of the gnum BAR 0
constant c_acam_adr_reg5            : std_logic_vector(7 downto 0):= x"05";     -- corresponds to address 80014 of the gnum BAR 0
constant c_acam_adr_reg6            : std_logic_vector(7 downto 0):= x"06";     -- corresponds to address 80018 of the gnum BAR 0
constant c_acam_adr_reg7            : std_logic_vector(7 downto 0):= x"07";     -- corresponds to address 8001C of the gnum BAR 0

constant c_acam_adr_reg11           : std_logic_vector(7 downto 0):= x"0B";     -- corresponds to address 8002C of the gnum BAR 0
constant c_acam_adr_reg12           : std_logic_vector(7 downto 0):= x"0C";     -- corresponds to address 80030 of the gnum BAR 0
constant c_acam_adr_reg14           : std_logic_vector(7 downto 0):= x"0E";     -- corresponds to address 80038 of the gnum BAR 0

-- Addresses of ACAM read-only register (used within the core to access ACAM timestamps)
constant c_acam_adr_reg8            : std_logic_vector(7 downto 0):= x"08";     -- not accessible for writing from PCI-e
constant c_acam_adr_reg9            : std_logic_vector(7 downto 0):= x"09";     -- not accessible for writing from PCI-e
constant c_acam_adr_reg10           : std_logic_vector(7 downto 0):= x"0A";     -- not accessible for writing from PCI-e

-- Addresses of ACAM registers readback
constant c_acam_adr_reg0_rdbk       : std_logic_vector(7 downto 0):= x"10";     -- corresponds to address 80040 of the gnum BAR 0
constant c_acam_adr_reg1_rdbk       : std_logic_vector(7 downto 0):= x"11";     -- corresponds to address 80044 of the gnum BAR 0
constant c_acam_adr_reg2_rdbk       : std_logic_vector(7 downto 0):= x"12";     -- corresponds to address 80048 of the gnum BAR 0
constant c_acam_adr_reg3_rdbk       : std_logic_vector(7 downto 0):= x"13";     -- corresponds to address 8004C of the gnum BAR 0
constant c_acam_adr_reg4_rdbk       : std_logic_vector(7 downto 0):= x"14";     -- corresponds to address 80050 of the gnum BAR 0
constant c_acam_adr_reg5_rdbk       : std_logic_vector(7 downto 0):= x"15";     -- corresponds to address 80054 of the gnum BAR 0
constant c_acam_adr_reg6_rdbk       : std_logic_vector(7 downto 0):= x"16";     -- corresponds to address 80058 of the gnum BAR 0
constant c_acam_adr_reg7_rdbk       : std_logic_vector(7 downto 0):= x"17";     -- corresponds to address 8005C of the gnum BAR 0

constant c_acam_adr_reg8_rdbk       : std_logic_vector(7 downto 0):= x"18";     -- corresponds to address 80060 of the gnum BAR 0
constant c_acam_adr_reg9_rdbk       : std_logic_vector(7 downto 0):= x"19";     -- corresponds to address 80064 of the gnum BAR 0
constant c_acam_adr_reg10_rdbk      : std_logic_vector(7 downto 0):= x"1A";     -- corresponds to address 80068 of the gnum BAR 0

constant c_acam_adr_reg11_rdbk      : std_logic_vector(7 downto 0):= x"1B";     -- corresponds to address 8006C of the gnum BAR 0
constant c_acam_adr_reg12_rdbk      : std_logic_vector(7 downto 0):= x"1C";     -- corresponds to address 80070 of the gnum BAR 0
constant c_acam_adr_reg14_rdbk      : std_logic_vector(7 downto 0):= x"1E";     -- corresponds to address 80078 of the gnum BAR 0

-- Addresses of TDC core configuration registers
constant c_starting_utc_adr         : std_logic_vector(7 downto 0):= x"20";     -- corresponds to address 80080 of the gnum BAR 0
constant c_in_en_ctrl_adr           : std_logic_vector(7 downto 0):= x"21";     -- corresponds to address 80084 of the gnum BAR 0
constant c_start_phase_adr          : std_logic_vector(7 downto 0):= x"22";     -- corresponds to address 80088 of the gnum BAR 0
constant c_one_hz_phase_adr         : std_logic_vector(7 downto 0):= x"23";     -- corresponds to address 8008C of the gnum BAR 0

--constant c_irq_config_adr           : std_logic_vector(7 downto 0):= x"24";

-- Addresses of TDC core status registers
constant c_local_utc_adr            : std_logic_vector(7 downto 0):= x"25";     -- corresponds to address 80094 of the gnum BAR 0
constant c_irq_code_adr             : std_logic_vector(7 downto 0):= x"26";     -- corresponds to address 80098 of the gnum BAR 0
constant c_wr_index_adr             : std_logic_vector(7 downto 0):= x"27";     -- corresponds to address 8009C of the gnum BAR 0
constant c_core_status_adr          : std_logic_vector(7 downto 0):= x"28";     -- corresponds to address 800A0 of the gnum BAR 0

-- Address of TDC core control register
constant c_control_register_adr     : std_logic_vector(7 downto 0):= x"3F";     -- corresponds to address 800FC of the gnum BAR 0

end tdc_core_pkg;

----------------------------------------------------------------------------------------------------
-- Package body
----------------------------------------------------------------------------------------------------
package body tdc_core_pkg is
end tdc_core_pkg;
