-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

---------------------------------------------------------------------------------------
-- Title          : Address constants of the reg_ctrl unit
---------------------------------------------------------------------------------------
-- File           : reg_ctrl_pkg.vhd
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wbgen2_pkg.all;
use work.wishbone_pkg.all;

package reg_ctrl_pkg is


---------------------------------------------------------------------------------------------------
--                      Constants regarding addressing of the ACAM registers                     --
---------------------------------------------------------------------------------------------------
-- ACAM configuration regs
-- refer to https://ams.com/documents/20143/36005/TDC-GPX_DS000321_1-00.pdf/0b5268df-ea27-b5c6-87cd-e8605aa2c819

---------------------------------------------------------------------------------------------------
-- Addresses of ACAM configuration registers to be written by the PCIe host
                                                                     -- corresponds to host address: base+
  constant c_ACAM_REG0_ADR  : std_logic_vector(7 downto 0) := x"00"; -- [core base] + 0x00
  constant c_ACAM_REG1_ADR  : std_logic_vector(7 downto 0) := x"01"; -- [core base] + 0x04
  constant c_ACAM_REG2_ADR  : std_logic_vector(7 downto 0) := x"02"; -- [core base] + 0x08
  constant c_ACAM_REG3_ADR  : std_logic_vector(7 downto 0) := x"03"; -- [core base] + 0x0C
  constant c_ACAM_REG4_ADR  : std_logic_vector(7 downto 0) := x"04"; -- [core base] + 0x10
  constant c_ACAM_REG5_ADR  : std_logic_vector(7 downto 0) := x"05"; -- [core base] + 0x14
  constant c_ACAM_REG6_ADR  : std_logic_vector(7 downto 0) := x"06"; -- [core base] + 0x18
  constant c_ACAM_REG7_ADR  : std_logic_vector(7 downto 0) := x"07"; -- [core base] + 0x1C
  constant c_ACAM_REG11_ADR : std_logic_vector(7 downto 0) := x"0B"; -- [core base] + 0x2C
  constant c_ACAM_REG12_ADR : std_logic_vector(7 downto 0) := x"0C"; -- [core base] + 0x30
  constant c_ACAM_REG14_ADR : std_logic_vector(7 downto 0) := x"0E"; -- [core base] + 0x38


---------------------------------------------------------------------------------------------------
-- Addresses of ACAM read-only registers, to be written by the ACAM and used within the core to access ACAM timestamps
  constant c_ACAM_REG8_ADR  : std_logic_vector(7 downto 0) := x"08"; -- not accessible from the host
  constant c_ACAM_REG9_ADR  : std_logic_vector(7 downto 0) := x"09"; -- not accessible from the host
  constant c_ACAM_REG10_ADR : std_logic_vector(7 downto 0) := x"0A"; -- not accessible from the host


---------------------------------------------------------------------------------------------------
-- Addresses of ACAM configuration readback registers, to be written by the ACAM 
                                                                          -- corresponds to host address:
  constant c_ACAM_REG0_RDBK_ADR  : std_logic_vector(7 downto 0) := x"10"; -- [core base] + 0x40
  constant c_ACAM_REG1_RDBK_ADR  : std_logic_vector(7 downto 0) := x"11"; -- [core base] + 0x44
  constant c_ACAM_REG2_RDBK_ADR  : std_logic_vector(7 downto 0) := x"12"; -- [core base] + 0x48
  constant c_ACAM_REG3_RDBK_ADR  : std_logic_vector(7 downto 0) := x"13"; -- [core base] + 0x4C
  constant c_ACAM_REG4_RDBK_ADR  : std_logic_vector(7 downto 0) := x"14"; -- [core base] + 0x50
  constant c_ACAM_REG5_RDBK_ADR  : std_logic_vector(7 downto 0) := x"15"; -- [core base] + 0x54
  constant c_ACAM_REG6_RDBK_ADR  : std_logic_vector(7 downto 0) := x"16"; -- [core base] + 0x58
  constant c_ACAM_REG7_RDBK_ADR  : std_logic_vector(7 downto 0) := x"17"; -- [core base] + 0x5C
  constant c_ACAM_REG8_RDBK_ADR  : std_logic_vector(7 downto 0) := x"18"; -- [core base] + 0x60
  constant c_ACAM_REG9_RDBK_ADR  : std_logic_vector(7 downto 0) := x"19"; -- [core base] + 0x64
  constant c_ACAM_REG10_RDBK_ADR : std_logic_vector(7 downto 0) := x"1A"; -- [core base] + 0x68
  constant c_ACAM_REG11_RDBK_ADR : std_logic_vector(7 downto 0) := x"1B"; -- [core base] + 0x6C
  constant c_ACAM_REG12_RDBK_ADR : std_logic_vector(7 downto 0) := x"1C"; -- [core base] + 0x70
  constant c_ACAM_REG14_RDBK_ADR : std_logic_vector(7 downto 0) := x"1E"; -- [core base] + 0x78


---------------------------------------------------------------------------------------------------
--                    Constants regarding addressing of the TDC core registers                   --
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Addresses of TDC core Configuration registers to be written by the PCIe host
                                                                           -- corresponds to host address:
  constant c_STARTING_UTC_ADR     : std_logic_vector(7 downto 0) := x"20"; -- [core base] + 0x80
  constant c_ACAM_INPUTS_EN_ADR   : std_logic_vector(7 downto 0) := x"21"; -- [core base] + 0x84
  constant c_C000FFEE_BREAK_ADR   : std_logic_vector(7 downto 0) := x"23"; -- [core base] + 0x8C
  constant c_IRQ_TSTAMP_THRESH_ADR: std_logic_vector(7 downto 0) := x"24"; -- [core base] + 0x90
  constant c_IRQ_TIME_THRESH_ADR  : std_logic_vector(7 downto 0) := x"25"; -- [core base] + 0x94
  constant c_DAC_WORD_ADR         : std_logic_vector(7 downto 0) := x"26"; -- not used! [core base] + 0x98

---------------------------------------------------------------------------------------------------
-- Addresses of TDC core Status registers to be written by the different core units
  constant c_CURRENT_UTC_ADR      : std_logic_vector(7 downto 0) := x"28"; -- [core base] + 0xA0
  constant c_CORE_STATUS_ADR      : std_logic_vector(7 downto 0) := x"2B"; -- [core base] + 0xAC

---------------------------------------------------------------------------------------------------
-- Addresses of the White Rabbit control and status registers
  constant c_WRABBIT_STATUS_ADR   : std_logic_vector(7 downto 0) := x"2C"; -- [core base] + 0xB0
  constant c_WRABBIT_CTRL_ADR     : std_logic_vector(7 downto 0) := x"2D"; -- [core base] + 0xB4

---------------------------------------------------------------------------------------------------
-- Testing registers
  constant c_TEST0_ADR            : std_logic_vector(7 downto 0) := x"2E"; -- [core base] + 0xB8
  constant c_TEST1_ADR            : std_logic_vector(7 downto 0) := x"2F"; -- [core base] + 0xBC

---------------------------------------------------------------------------------------------------
-- Address of TDC core Control register
  constant c_CTRL_REG_ADR         : std_logic_vector(7 downto 0) := x"3F"; -- [core base] + 0xFC

---------------------------------------------------------------------------------------------------
-- Currently not used
-- constant c_START_PHASE_ADR      : std_logic_vector(7 downto 0) := x"22"; -- [core base] + 0x88
-- constant c_DEACT_CHAN_ADR       : std_logic_vector(7 downto 0) := x"27"; -- not used! [core base] + 0x9C
-- constant c_IRQ_CODE_ADR         : std_logic_vector(7 downto 0) := x"29"; -- not used! [core base] + 0xA4
-- constant c_WR_INDEX_ADR         : std_logic_vector(7 downto 0) := x"2A"; -- not used! [core base] + 0xA8
end package;