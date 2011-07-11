----------------------------------------------------------------------------------------------------
--  CERN-BE-CO-HT
----------------------------------------------------------------------------------------------------
--
--  unit name   : data polling engine (data_polling)
--  author      : G. Penacoba
--  date        : June 2011
--  version     : Revision 1
--  description : engine polling data continuouly from the acam interface provided the FIFO is not 
--                empty. acts as a wishbone master.
--  dependencies:
--  references  :
--  modified by :
--
----------------------------------------------------------------------------------------------------
--  last changes:
----------------------------------------------------------------------------------------------------
--  to do: empty FIFO signals from Acam are missing (maybe putting them in the data?)
--          other Acam configuration registers maybe...
----------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

----------------------------------------------------------------------------------------------------
--  entity declaration for data_polling
----------------------------------------------------------------------------------------------------
entity data_polling is
    generic(
        g_width             : integer :=32
    );
    port(
        -- wishbone master signals internal to the chip: interface with other modules
        ack_i                   : in std_logic;
        dat_i                   : in std_logic_vector(31 downto 0);

        cyc_o                   : out std_logic;
        dat_o                   : out std_logic_vector(31 downto 0);
        stb_o                   : out std_logic;
        we_o                    : out std_logic;
        
        -- signals internal to the chip: interface with other modules
        clk_i                   : in std_logic;
        one_hz_p_i              : in std_logic;
        reset_i                 : in std_logic;
        start_timer_reg_i       : in std_logic_vector(7 downto 0);
        
        acam_start01_o          : out std_logic_vector(16 downto 0);
        acam_timestamp_o        : out std_logic_vector(28 downto 0);
        acam_timestamp_valid_o  : out std_logic
    );
end acam_databus_interface;

----------------------------------------------------------------------------------------------------
--  architecture declaration for data_polling
----------------------------------------------------------------------------------------------------
architecture rtl of data_polling is


----------------------------------------------------------------------------------------------------
--  architecture begins
----------------------------------------------------------------------------------------------------
begin


end rtl;
----------------------------------------------------------------------------------------------------
--  architecture ends
----------------------------------------------------------------------------------------------------
