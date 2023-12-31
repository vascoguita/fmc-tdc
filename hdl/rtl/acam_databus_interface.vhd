-- SPDX-FileCopyrightText: 2022 CERN (home.cern)
--
-- SPDX-License-Identifier: CERN-OHL-W-2.0+

---------------------------------------------------------------------------------------------------
-- Title      : Acam databus interface
---------------------------------------------------------------------------------------------------
-- Description  The unit interfaces with the ACAM chip pins for the configuration of the registers
--              and the acquisition of the timestamps.
--              The ACAM proprietary interface is converted to a WISHBONE classic interface, with
--              which the unit communicates with the data_engine unit.
--              The WISHBONE master is implemented in the data_engine and the slave in this unit.
--
--              ___________               ____________              ___________
--             |           |___WRn_______|            |            |           |
--             |           |___RDn_______|            |___stb______|           |
--             |           |___CSn_______|            |___cyc______|           |
--             |   ACAM    |___OEn_______|  acam_     |___we_______|  data_    |
--             |           |___EF________|  databus_  |___ack______|  engine   |
--             |           |             |  interface |___adr______|           |
--             |           |___ADR_______|            |___datI_____|           |
--             |           |___DatabusIO_|            |___datO_____|           |
--             |___________|             |____________|            |___________|
--
--
----------------------------------------------/!\-------------------------------------------------|
-- In order for the core to be able  to keep retreiving timestamps from the ACAM at the ACAM's    |
-- maximun speed (31.25 M timestamps/ sec), it needs to complete one retreival per                |
-- 4 * clk_i cycles = 4 * 8 ns = 32 ns. To achieve that the core is allowing 16 ns from the moment|
-- it activates the rd_n_o signal until the ACAM ef signal is updated. ACAM's specification       |
-- defines that the maximum ef set time is 11.8 ns; this allows for >4 ns for the signals routing.|
-- To make sure this constraint is met, the Xilinx design map option "Pack IO Registers/Lathes    |
-- into IOBs" should be enabled.                                                                  |
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------


--=================================================================================================
--                                       Libraries & Packages
--=================================================================================================

-- Standard library
library IEEE;
use IEEE.std_logic_1164.all; -- std_logic definitions
use IEEE.NUMERIC_STD.all;    -- conversion functions
-- Specific library
library work;
use work.tdc_core_pkg.all;   -- definitions of types, constants, entities
use work.gencores_pkg.all;


--=================================================================================================
--                            Entity declaration for acam_databus_interface
--=================================================================================================
entity acam_databus_interface is
  port

  -- INPUTS
     -- Signals from the clk_rst_manager unit
    (clk_i       : in std_logic;                       -- 125 MHz clock
     rst_i       : in std_logic;                       -- global reset

     -- Signals from the ACAM chip
     ef1_i       : in std_logic;                       -- FIFO1 empty flag
     ef2_i       : in std_logic;                       -- FIFO2 empty flag

     data_bus_io : inout std_logic_vector(27 downto 0);

     -- Signals from the data_engine unit
     cyc_i       : in std_logic;                       -- WISHBONE cycle
     stb_i       : in std_logic;                       -- WISHBONE strobe
     we_i        : in std_logic;                       -- WISHBONE write enable
     adr_i       : in std_logic_vector(7 downto 0);    -- address of ACAM to write to/ read from (only 4 LSB are output)
     dat_i       : in std_logic_vector(31 downto 0);   -- data to load to ACAM (only 28 LSB are output)


  -- OUTPUTS
     -- signals internal to the chip: interface with other modules
     ef1_o       : out std_logic;                      -- ACAM FIFO1 empty flag (bouble registered with clk_i)
     ef2_o       : out std_logic;                      -- ACAM FIFO2 empty flag (bouble registered with clk_i)

     -- Signals to ACAM interface
     adr_o       : out std_logic_vector(3 downto 0);   -- ACAM address
     cs_n_o      : out std_logic;                      -- ACAM chip select, active low; it can always remain active
     oe_n_o      : out std_logic;                      -- ACAM output enble, active low
     rd_n_o      : out std_logic;                      -- ACAM read enable, active low
     wr_n_o      : out std_logic;                      -- ACAM write enable, active low

     -- Signals to the data_engine unit
     ack_o       : out std_logic;                      -- WISHBONE ack
     dat_o       : out std_logic_vector(31 downto 0)); -- ef1 & ef2 & 0 & 0 & 28 bits ACAM data_bus_io

end acam_databus_interface;


--=================================================================================================
--                                    architecture declaration
--=================================================================================================

architecture rtl of acam_databus_interface is

  type t_acam_interface is (IDLE, RD_START, RD_FETCH, RD_FETCH2, RD_FETCH3, RD_ACK, WR_START, WR_PUSH, WR_ACK);
  signal acam_data_st, nxt_acam_data_st : t_acam_interface;

  signal ef1_synch, ef2_synch           : std_logic;
  signal ack, rd, rd_extend             : std_logic;
  signal wr, wr_extend, wr_remove       : std_logic;
  signal rst_n                          : std_logic;

--=================================================================================================
--                                       architecture begin
--=================================================================================================
begin

---------------------------------------------------------------------------------------------------
--                                      Input Synchronizers                                      --
---------------------------------------------------------------------------------------------------

  rst_n <= not rst_i;

  cmp_sync_ef1: gc_sync_ffs
    port map (
      clk_i    => clk_i,
      rst_n_i  => rst_n,
      data_i   => ef1_i,
      synced_o => ef1_synch);

  cmp_sync_ef2: gc_sync_ffs
    port map (
      clk_i    => clk_i,
      rst_n_i  => rst_n,
      data_i   => ef2_i,
      synced_o => ef2_synch);

---------------------------------------------------------------------------------------------------
--                                             FSM                                               --
---------------------------------------------------------------------------------------------------
-- The following state machine implements the slave side of the WISHBONE interface
-- and converts the signals for the ACAM proprietary bus interface. The interface respects the
-- timings specified in page 7 of the ACAM datasheet.

  databus_access_seq_fsm: process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i ='1' then
        acam_data_st <= IDLE;
      else
        acam_data_st <= nxt_acam_data_st;
      end if;
    end if;
  end process;


--  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  databus_access_comb_fsm: process (acam_data_st, stb_i, cyc_i, we_i)
  begin
    case acam_data_st is
      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when IDLE     =>
                  -----------------------------------------------
                        ack                  <= '0';
                        rd_extend            <= '0';
                        wr_extend            <= '0';
                        wr_remove            <= '0';
                  -----------------------------------------------

                        if stb_i = '1' and cyc_i = '1' then
                          if we_i = '1' then
                            nxt_acam_data_st <= WR_START;
                          else
                            nxt_acam_data_st <= RD_START;
                          end if;

                        else
                          nxt_acam_data_st   <= IDLE;
                        end if;

      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when RD_START =>
                  -----------------------------------------------
                        ack                  <= '0';
                        rd_extend            <= '1';
                        wr_extend            <= '0';
                        wr_remove            <= '0';
                  -----------------------------------------------

                        nxt_acam_data_st     <= RD_FETCH;


      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when RD_FETCH =>
                  -----------------------------------------------
                        ack                  <= '0';
                        rd_extend            <= '1';
                        wr_extend            <= '0';
                        wr_remove            <= '0';
                  -----------------------------------------------

                        nxt_acam_data_st     <= RD_FETCH2;

      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when RD_FETCH2 =>
                  -----------------------------------------------
                        ack                  <= '0';
                        rd_extend            <= '1';
                        wr_extend            <= '0';
                        wr_remove            <= '0';
                  -----------------------------------------------

                        nxt_acam_data_st     <= RD_FETCH3;

      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when RD_FETCH3 =>
                  -----------------------------------------------
                        ack                  <= '0';
                        rd_extend            <= '1';
                        wr_extend            <= '0';
                        wr_remove            <= '0';
                  -----------------------------------------------

                        nxt_acam_data_st     <= RD_ACK;

      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when RD_ACK =>

                  -----------------------------------------------
                        ack                  <= '1';
                        rd_extend            <= '0';
                        wr_extend            <= '0';
                        wr_remove            <= '0';
                  -----------------------------------------------

                        nxt_acam_data_st     <= IDLE;


      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when WR_START =>
                  -----------------------------------------------
                        ack                  <= '0';
                        rd_extend            <= '0';
                        wr_extend            <= '1';
                        wr_remove            <= '0';
                  -----------------------------------------------

                        nxt_acam_data_st     <= WR_PUSH;

      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when WR_PUSH =>

                  -----------------------------------------------
                        ack                  <= '0';
                        rd_extend            <= '0';
                        wr_extend            <= '0';
                        wr_remove            <= '1';
                  -----------------------------------------------

                        nxt_acam_data_st     <= WR_ACK;

      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when WR_ACK =>

                  -----------------------------------------------
                        ack                  <= '1';
                        rd_extend            <= '0';
                        wr_extend            <= '0';
                        wr_remove            <= '0';
                  -----------------------------------------------

                        nxt_acam_data_st     <= IDLE;

      --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
      when others =>
                  -----------------------------------------------
                        ack                  <= '0';
                        rd_extend            <= '0';
                        wr_extend            <= '0';
                        wr_remove            <= '0';
                  -----------------------------------------------

                        nxt_acam_data_st     <= IDLE;
    end case;
  end process;

  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --
  ack_o  <= ack;

  -- to the 28 bits databus output we add the ef flags to arrive to a 32 bits word
  dat_o  <= ef1_synch & ef2_synch & "00" & data_bus_io;


---------------------------------------------------------------------------------------------------
--                                        Outputs to ACAM                                        --
---------------------------------------------------------------------------------------------------

output_registers: process (clk_i)
  begin
    if rising_edge (clk_i) then
      if rst_i ='1' then
        cs_n_o <= '1';
        rd_n_o <= '1';
        wr_n_o <= '1';
      else
        cs_n_o <= '0';
        rd_n_o <= not(rd);
        wr_n_o <= not(wr);
      end if;
    end if;
  end process;

  oe_n_o       <= '1';
  rd           <= ((stb_i and cyc_i and not(we_i)) or rd_extend) and (not(ack));
  wr           <= ((stb_i and cyc_i and we_i)      or wr_extend) and (not(wr_remove)) and (not(ack));
               -- the wr signal has to be removed to respect the ACAM specs
  data_bus_io  <= dat_i(27 downto 0) when we_i='1' else (others =>'Z');
  adr_o        <= adr_i(3 downto 0);


---------------------------------------------------------------------------------------------------
--                                     EF to the data_engine                                     --
---------------------------------------------------------------------------------------------------

  ef1_o        <= ef1_synch; -- ef1 after two synchronization registers
  ef2_o        <= ef2_synch; -- ef1 after two synchronization registers

end rtl;
--=================================================================================================
--                                        architecture end
--=================================================================================================
---------------------------------------------------------------------------------------------------
--                                      E N D   O F   F I L E
---------------------------------------------------------------------------------------------------
