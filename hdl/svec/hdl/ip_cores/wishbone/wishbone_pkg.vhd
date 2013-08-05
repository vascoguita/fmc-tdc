library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.genram_pkg.all;

package wishbone_pkg is

  constant c_wishbone_address_width : integer := 32;
  constant c_wishbone_data_width    : integer := 32;

  subtype t_wishbone_address is
    std_logic_vector(c_wishbone_address_width-1 downto 0);
  subtype t_wishbone_data is
    std_logic_vector(c_wishbone_data_width-1 downto 0);
  subtype t_wishbone_byte_select is
    std_logic_vector((c_wishbone_address_width/8)-1 downto 0);
  subtype t_wishbone_cycle_type is
    std_logic_vector(2 downto 0);
  subtype t_wishbone_burst_type is
    std_logic_vector(1 downto 0);

  type t_wishbone_interface_mode is (CLASSIC, PIPELINED);
  type t_wishbone_address_granularity is (BYTE, WORD);

  type t_wishbone_master_out is record
    cyc : std_logic;
    stb : std_logic;
    adr : t_wishbone_address;
    sel : t_wishbone_byte_select;
    we  : std_logic;
    dat : t_wishbone_data;
  end record t_wishbone_master_out;

  subtype t_wishbone_slave_in is t_wishbone_master_out;

  type t_wishbone_slave_out is record
    ack   : std_logic;
    err   : std_logic;
    rty   : std_logic;
    stall : std_logic;
    int   : std_logic;
    dat   : t_wishbone_data;
  end record t_wishbone_slave_out;
  subtype t_wishbone_master_in is t_wishbone_slave_out;

  subtype t_wishbone_device_descriptor is std_logic_vector(255 downto 0);



  type t_wishbone_address_array is array(natural range <>) of t_wishbone_address;
  type t_wishbone_master_out_array is array (natural range <>) of t_wishbone_master_out;
  type t_wishbone_slave_out_array is array (natural range <>) of t_wishbone_slave_out;
  type t_wishbone_master_in_array is array (natural range <>) of t_wishbone_master_in;
  type t_wishbone_slave_in_array is array (natural range <>) of t_wishbone_slave_in;


  constant cc_dummy_address : std_logic_vector(c_wishbone_address_width-1 downto 0):=
    (others => 'X');
  constant cc_dummy_data : std_logic_vector(c_wishbone_address_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_sel : std_logic_vector(c_wishbone_data_width/8-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_slave_in : t_wishbone_slave_in :=
    ('0', 'X', cc_dummy_address, cc_dummy_sel, 'X', cc_dummy_data);
  constant cc_dummy_master_out : t_wishbone_master_out := cc_dummy_slave_in;
  
  -- Dangerous! Will stall a bus.
  constant cc_dummy_slave_out : t_wishbone_slave_out :=
    ('X', 'X', 'X', 'X', 'X', cc_dummy_data);
  constant cc_dummy_master_in : t_wishbone_master_in := cc_dummy_slave_out;

  -- A generally useful function.
  function f_ceil_log2(x : natural) return natural;
  function f_bits2string(s : std_logic_vector) return string;
  function f_string2bits(s : string) return std_logic_vector;
  function f_string2svl (s : string) return std_logic_vector;
  function f_slv2string (slv : std_logic_vector) return string;

------------------------------------------------------------------------------
-- SDB declaration
------------------------------------------------------------------------------
  
  constant c_sdb_device_length : natural := 512; -- bits
  subtype t_sdb_record is std_logic_vector(c_sdb_device_length-1 downto 0);
  type t_sdb_record_array is array(natural range <>) of t_sdb_record;
  
  type t_sdb_product is record
    vendor_id     : std_logic_vector(63 downto 0);
    device_id     : std_logic_vector(31 downto 0);
    version       : std_logic_vector(31 downto 0);
    date          : std_logic_vector(31 downto 0);
    name          : string(1 to 19);
  end record t_sdb_product;
  
  type t_sdb_component is record
    addr_first    : std_logic_vector(63 downto 0);
    addr_last     : std_logic_vector(63 downto 0);
    product       : t_sdb_product;
  end record t_sdb_component;
  
  constant c_sdb_endian_big    : std_logic := '0';
  constant c_sdb_endian_little : std_logic := '1';
  type t_sdb_device is record
    abi_class     : std_logic_vector(15 downto 0);
    abi_ver_major : std_logic_vector(7 downto 0);
    abi_ver_minor : std_logic_vector(7 downto 0);
    wbd_endian    : std_logic;                    -- 0 = big, 1 = little
    wbd_width     : std_logic_vector(3 downto 0); -- 3=64-bit, 2=32-bit, 1=16-bit, 0=8-bit
    sdb_component : t_sdb_component;
  end record t_sdb_device;
  
  type t_sdb_bridge is record
    sdb_child     : std_logic_vector(63 downto 0);
    sdb_component : t_sdb_component;
  end record t_sdb_bridge;

  type t_sdb_integration is record
    product : t_sdb_product;
  end record t_sdb_integration;

  type t_sdb_repo_url is record
    repo_url : string(1 to 63);
  end record t_sdb_repo_url;

  type t_sdb_synthesis is record
    syn_module_name  : string(1 to 16);
    syn_commit_id    : string(1 to 32);
    syn_tool_name    : string(1 to 8);
    syn_tool_version : std_logic_vector(31 downto 0);
    syn_date         : std_logic_vector(31 downto 0);
    syn_username     : string(1 to 15);
  end record t_sdb_synthesis;

  -- Used to configure a device at a certain address
  function f_sdb_embed_device(device : t_sdb_device; address : t_wishbone_address) return t_sdb_record;
  function f_sdb_embed_bridge(bridge : t_sdb_bridge; address : t_wishbone_address) return t_sdb_record;
  function f_sdb_embed_integration(integr : t_sdb_integration) return t_sdb_record;
  function f_sdb_embed_repo_url(url : t_sdb_repo_url) return t_sdb_record;
  function f_sdb_embed_synthesis(syn : t_sdb_synthesis) return t_sdb_record;

  function f_sdb_extract_device(sdb_record : t_sdb_record) return t_sdb_device;
  function f_sdb_extract_bridge(sdb_record : t_sdb_record) return t_sdb_bridge;
  function f_sdb_extract_integration(sdb_record : t_sdb_record) return t_sdb_integration;
  function f_sdb_extract_repo_url(sdb_record : t_sdb_record) return t_sdb_repo_url;
  function f_sdb_extract_synthesis(sdb_record : t_sdb_record) return t_sdb_synthesis;

  -- For internal use by the crossbar
  function f_sdb_embed_product(product : t_sdb_product) return std_logic_vector; -- (319 downto 8)
  function f_sdb_embed_component(sdb_component : t_sdb_component; address : t_wishbone_address) return std_logic_vector; -- (447 downto 8)
  function f_sdb_extract_product(sdb_record : std_logic_vector(319 downto 8))  return t_sdb_product;
  function f_sdb_extract_component(sdb_record : std_logic_vector(447 downto 8)) return t_sdb_component;

------------------------------------------------------------------------------
-- Components declaration
-------------------------------------------------------------------------------

  component wb_slave_adapter
    generic (
      g_master_use_struct  : boolean;
      g_master_mode        : t_wishbone_interface_mode;
      g_master_granularity : t_wishbone_address_granularity;
      g_slave_use_struct   : boolean;
      g_slave_mode         : t_wishbone_interface_mode;
      g_slave_granularity  : t_wishbone_address_granularity);
    port (
      clk_sys_i  : in  std_logic;
      rst_n_i    : in  std_logic;
      sl_adr_i   : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := cc_dummy_address;
      sl_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0)    := cc_dummy_data;
      sl_sel_i   : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0)  := cc_dummy_sel;
      sl_cyc_i   : in  std_logic                                             := '0';
      sl_stb_i   : in  std_logic                                             := '0';
      sl_we_i    : in  std_logic                                             := '0';
      sl_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
      sl_err_o   : out std_logic;
      sl_rty_o   : out std_logic;
      sl_ack_o   : out std_logic;
      sl_stall_o : out std_logic;
      sl_int_o   : out std_logic;
      slave_i    : in  t_wishbone_slave_in                                   := cc_dummy_slave_in;
      slave_o    : out t_wishbone_slave_out;
      ma_adr_o   : out std_logic_vector(c_wishbone_address_width-1 downto 0);
      ma_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
      ma_sel_o   : out std_logic_vector(c_wishbone_data_width/8-1 downto 0);
      ma_cyc_o   : out std_logic;
      ma_stb_o   : out std_logic;
      ma_we_o    : out std_logic;
      ma_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0)    := cc_dummy_data;
      ma_err_i   : in  std_logic                                             := '0';
      ma_rty_i   : in  std_logic                                             := '0';
      ma_ack_i   : in  std_logic                                             := '0';
      ma_stall_i : in  std_logic                                             := '0';
      ma_int_i   : in  std_logic                                             := '0';
      master_i   : in  t_wishbone_master_in                                  := cc_dummy_slave_out;
      master_o   : out t_wishbone_master_out);
  end component;

  component wb_async_bridge
    generic (
      g_simulation          : integer;
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD;
      g_cpu_address_width   : integer);
    port (
      rst_n_i     : in    std_logic;
      clk_sys_i   : in    std_logic;
      cpu_cs_n_i  : in    std_logic;
      cpu_wr_n_i  : in    std_logic;
      cpu_rd_n_i  : in    std_logic;
      cpu_bs_n_i  : in    std_logic_vector(3 downto 0);
      cpu_addr_i  : in    std_logic_vector(g_cpu_address_width-1 downto 0);
      cpu_data_b  : inout std_logic_vector(31 downto 0);
      cpu_nwait_o : out   std_logic;
      wb_adr_o    : out   std_logic_vector(c_wishbone_address_width - 1 downto 0);
      wb_dat_o    : out   std_logic_vector(31 downto 0);
      wb_stb_o    : out   std_logic;
      wb_we_o     : out   std_logic;
      wb_sel_o    : out   std_logic_vector(3 downto 0);
      wb_cyc_o    : out   std_logic;
      wb_dat_i    : in    std_logic_vector (c_wishbone_data_width-1 downto 0);
      wb_ack_i    : in    std_logic;
      wb_stall_i  : in    std_logic := '0');
  end component;

  component xwb_async_bridge
    generic (
      g_simulation          : integer;
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD;
      g_cpu_address_width   : integer);
    port (
      rst_n_i     : in    std_logic;
      clk_sys_i   : in    std_logic;
      cpu_cs_n_i  : in    std_logic;
      cpu_wr_n_i  : in    std_logic;
      cpu_rd_n_i  : in    std_logic;
      cpu_bs_n_i  : in    std_logic_vector(3 downto 0);
      cpu_addr_i  : in    std_logic_vector(g_cpu_address_width-1 downto 0);
      cpu_data_b  : inout std_logic_vector(31 downto 0);
      cpu_nwait_o : out   std_logic;
      master_o    : out   t_wishbone_master_out;
      master_i    : in    t_wishbone_master_in);
  end component;

  component xwb_bus_fanout
    generic (
      g_num_outputs          : natural;
      g_bits_per_slave       : integer;
      g_address_granularity  : t_wishbone_address_granularity := WORD;
      g_slave_interface_mode : t_wishbone_interface_mode      := CLASSIC);
    port (
      clk_sys_i : in  std_logic;
      rst_n_i   : in  std_logic;
      slave_i   : in  t_wishbone_slave_in;
      slave_o   : out t_wishbone_slave_out;
      master_i  : in  t_wishbone_master_in_array(0 to g_num_outputs-1);
      master_o  : out t_wishbone_master_out_array(0 to g_num_outputs-1));
  end component;

  component xwb_crossbar
    generic (
      g_num_masters : integer;
      g_num_slaves  : integer;
      g_registered  : boolean;
      g_address     : t_wishbone_address_array;
      g_mask        : t_wishbone_address_array);
    port (
      clk_sys_i     : in  std_logic;
      rst_n_i       : in  std_logic;
      slave_i       : in  t_wishbone_slave_in_array(g_num_masters-1 downto 0);
      slave_o       : out t_wishbone_slave_out_array(g_num_masters-1 downto 0);
      master_i      : in  t_wishbone_master_in_array(g_num_slaves-1 downto 0);
      master_o      : out t_wishbone_master_out_array(g_num_slaves-1 downto 0));
  end component;

  -- Use the f_xwb_bridge_*_sdb to bridge a crossbar to another
  function f_xwb_bridge_manual_sdb( -- take a manual bus size
      g_size        : t_wishbone_address;
      g_sdb_addr    : t_wishbone_address) return t_sdb_bridge;

  function f_xwb_bridge_layout_sdb( -- determine bus size from layout
      g_wraparound  : boolean := true;
      g_layout      : t_sdb_record_array;
      g_sdb_addr    : t_wishbone_address) return t_sdb_bridge;
  
  component xwb_sdb_crossbar
    generic (
      g_num_masters : integer;
      g_num_slaves  : integer;
      g_registered  : boolean := false;
      g_wraparound  : boolean := true;
      g_layout      : t_sdb_record_array;
      g_sdb_addr    : t_wishbone_address);
    port (
      clk_sys_i     : in  std_logic;
      rst_n_i       : in  std_logic;
      slave_i       : in  t_wishbone_slave_in_array(g_num_masters-1 downto 0);
      slave_o       : out t_wishbone_slave_out_array(g_num_masters-1 downto 0);
      master_i      : in  t_wishbone_master_in_array(g_num_slaves-1 downto 0);
      master_o      : out t_wishbone_master_out_array(g_num_slaves-1 downto 0));
  end component;

  component sdb_rom is
    generic(
      g_layout      : t_sdb_record_array;
      g_bus_end     : unsigned(63 downto 0));
    port(
      clk_sys_i     : in  std_logic;
      slave_i       : in  t_wishbone_slave_in;
      slave_o       : out t_wishbone_slave_out);
  end component;
  
  constant c_xwb_dma_sdb : t_sdb_device := (
    abi_class     => x"0000", -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7", -- 8/16/32-bit port granularity
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"000000000000001f",
    product => (
    vendor_id     => x"0000000000000651", -- GSI
    device_id     => x"cababa56",
    version       => x"00000001",
    date          => x"20120518",
    name          => "WB4-Streaming-DMA_0")));
  component xwb_dma is
    generic(
      -- Value 0 cannot stream
      -- Value 1 only slaves with async ACK can stream
      -- Value 2 only slaves with combined latency <= 2 can stream
      -- Value 3 only slaves with combined latency <= 6 can stream
      -- Value 4 only slaves with combined latency <= 14 can stream
      -- ....
      logRingLen : integer := 4
    );
    port(
      -- Common wishbone signals
      clk_i       : in  std_logic;
      rst_n_i     : in  std_logic;
      -- Slave control port
      slave_i     : in  t_wishbone_slave_in;
      slave_o     : out t_wishbone_slave_out;
      -- Master reader port
      r_master_i  : in  t_wishbone_master_in;
      r_master_o  : out t_wishbone_master_out;
      -- Master writer port
      w_master_i  : in  t_wishbone_master_in;
      w_master_o  : out t_wishbone_master_out;
      -- Pulsed high completion signal
      interrupt_o : out std_logic
    );
  end component;
  
  -- If you reset one clock domain, you must reset BOTH!
  -- Release of the reset lines may be arbitrarily out-of-phase
  component xwb_clock_crossing is
    generic(
      sync_depth : natural := 3;
      log2fifo   : natural := 4);
    port(
      -- Slave control port
      slave_clk_i    : in  std_logic;
      slave_rst_n_i  : in  std_logic;
      slave_i        : in  t_wishbone_slave_in;
      slave_o        : out t_wishbone_slave_out;
      -- Master reader port
      master_clk_i   : in  std_logic;
      master_rst_n_i : in  std_logic;
      master_i       : in  t_wishbone_master_in;
      master_o       : out t_wishbone_master_out);
  end component;
  
  subtype t_xwb_dpram_init is t_generic_ram_init;
  constant c_xwb_dpram_init_nothing : t_xwb_dpram_init := c_generic_ram_nothing;
  
  -- g_size is in words
  function f_xwb_dpram(g_size : natural) return t_sdb_device;
  component xwb_dpram
    generic (
      g_size                  : natural;
      g_init_file             : string                         := "";
      g_init_value            : t_xwb_dpram_init               := c_xwb_dpram_init_nothing;
      g_must_have_init_file   : boolean                        := true;
      g_slave1_interface_mode : t_wishbone_interface_mode      := CLASSIC;
      g_slave2_interface_mode : t_wishbone_interface_mode      := CLASSIC;
      g_slave1_granularity    : t_wishbone_address_granularity := WORD;
      g_slave2_granularity    : t_wishbone_address_granularity := WORD);
    port (
      clk_sys_i : in  std_logic;
      rst_n_i   : in  std_logic;
      slave1_i  : in  t_wishbone_slave_in;
      slave1_o  : out t_wishbone_slave_out;
      slave2_i  : in  t_wishbone_slave_in;
      slave2_o  : out t_wishbone_slave_out);
  end component;

  component wb_gpio_port
    generic (
      g_interface_mode         : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity    : t_wishbone_address_granularity := WORD;
      g_num_pins               : natural range 1 to 256;
      g_with_builtin_tristates : boolean                        := false);
    port (
      clk_sys_i  : in    std_logic;
      rst_n_i    : in    std_logic;
      wb_sel_i   : in    std_logic_vector(c_wishbone_data_width/8-1 downto 0);
      wb_cyc_i   : in    std_logic;
      wb_stb_i   : in    std_logic;
      wb_we_i    : in    std_logic;
      wb_adr_i   : in    std_logic_vector(7 downto 0);
      wb_dat_i   : in    std_logic_vector(c_wishbone_data_width-1 downto 0);
      wb_dat_o   : out   std_logic_vector(c_wishbone_data_width-1 downto 0);
      wb_ack_o   : out   std_logic;
      wb_stall_o : out   std_logic;
      gpio_b     : inout std_logic_vector(g_num_pins-1 downto 0);
      gpio_out_o : out   std_logic_vector(g_num_pins-1 downto 0);
      gpio_in_i  : in    std_logic_vector(g_num_pins-1 downto 0);
      gpio_oen_o : out   std_logic_vector(g_num_pins-1 downto 0));
  end component;

  component xwb_gpio_port
    generic (
      g_interface_mode         : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity    : t_wishbone_address_granularity := WORD;
      g_num_pins               : natural range 1 to 256;
      g_with_builtin_tristates : boolean);
    port (
      clk_sys_i  : in    std_logic;
      rst_n_i    : in    std_logic;
      slave_i    : in    t_wishbone_slave_in;
      slave_o    : out   t_wishbone_slave_out;
      desc_o     : out   t_wishbone_device_descriptor;
      gpio_b     : inout std_logic_vector(g_num_pins-1 downto 0);
      gpio_out_o : out   std_logic_vector(g_num_pins-1 downto 0);
      gpio_in_i  : in    std_logic_vector(g_num_pins-1 downto 0);
      gpio_oen_o : out   std_logic_vector(g_num_pins-1 downto 0));
  end component;

  component wb_i2c_master
    generic (
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD);
    port (
      clk_sys_i    : in  std_logic;
      rst_n_i      : in  std_logic;
      wb_adr_i     : in  std_logic_vector(4 downto 0);
      wb_dat_i     : in  std_logic_vector(31 downto 0);
      wb_dat_o     : out std_logic_vector(31 downto 0);
      wb_sel_i     : in  std_logic_vector(3 downto 0);
      wb_stb_i     : in  std_logic;
      wb_cyc_i     : in  std_logic;
      wb_we_i      : in  std_logic;
      wb_ack_o     : out std_logic;
      wb_int_o     : out std_logic;
      wb_stall_o   : out std_logic;
      scl_pad_i    : in  std_logic;
      scl_pad_o    : out std_logic;
      scl_padoen_o : out std_logic;
      sda_pad_i    : in  std_logic;
      sda_pad_o    : out std_logic;
      sda_padoen_o : out std_logic);
  end component;

  component xwb_i2c_master
    generic (
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD);
    port (
      clk_sys_i    : in  std_logic;
      rst_n_i      : in  std_logic;
      slave_i      : in  t_wishbone_slave_in;
      slave_o      : out t_wishbone_slave_out;
      desc_o       : out t_wishbone_device_descriptor;
      scl_pad_i    : in  std_logic;
      scl_pad_o    : out std_logic;
      scl_padoen_o : out std_logic;
      sda_pad_i    : in  std_logic;
      sda_pad_o    : out std_logic;
      sda_padoen_o : out std_logic);
  end component;

  component xwb_lm32
    generic (
      g_profile : string);
    port (
      clk_sys_i : in  std_logic;
      rst_n_i   : in  std_logic;
      irq_i     : in  std_logic_vector(31 downto 0);
      dwb_o     : out t_wishbone_master_out;
      dwb_i     : in  t_wishbone_master_in;
      iwb_o     : out t_wishbone_master_out;
      iwb_i     : in  t_wishbone_master_in);
  end component;

  component wb_onewire_master
    generic (
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD;
      g_num_ports           : integer;
      g_ow_btp_normal       : string                         := "1.0";
      g_ow_btp_overdrive    : string                         := "5.0");
    port (
      clk_sys_i   : in  std_logic;
      rst_n_i     : in  std_logic;
      wb_cyc_i    : in  std_logic;
      wb_sel_i    : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0);
      wb_stb_i    : in  std_logic;
      wb_we_i     : in  std_logic;
      wb_adr_i    : in  std_logic_vector(2 downto 0);
      wb_dat_i    : in  std_logic_vector(c_wishbone_data_width-1 downto 0);
      wb_dat_o    : out std_logic_vector(c_wishbone_data_width-1 downto 0);
      wb_ack_o    : out std_logic;
      wb_int_o    : out std_logic;
      wb_stall_o  : out std_logic;
      owr_pwren_o : out std_logic_vector(g_num_ports -1 downto 0);
      owr_en_o    : out std_logic_vector(g_num_ports -1 downto 0);
      owr_i       : in  std_logic_vector(g_num_ports -1 downto 0));
  end component;

  component xwb_onewire_master
    generic (
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD;
      g_num_ports           : integer;
      g_ow_btp_normal       : string                         := "5.0";
      g_ow_btp_overdrive    : string                         := "1.0");
    port (
      clk_sys_i   : in  std_logic;
      rst_n_i     : in  std_logic;
      slave_i     : in  t_wishbone_slave_in;
      slave_o     : out t_wishbone_slave_out;
      desc_o      : out t_wishbone_device_descriptor;
      owr_pwren_o : out std_logic_vector(g_num_ports -1 downto 0);
      owr_en_o    : out std_logic_vector(g_num_ports -1 downto 0);
      owr_i       : in  std_logic_vector(g_num_ports -1 downto 0));
  end component;

  component wb_spi
    generic (
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD);
    port (
      clk_sys_i  : in  std_logic;
      rst_n_i    : in  std_logic;
      wb_adr_i   : in  std_logic_vector(4 downto 0);
      wb_dat_i   : in  std_logic_vector(31 downto 0);
      wb_dat_o   : out std_logic_vector(31 downto 0);
      wb_sel_i   : in  std_logic_vector(3 downto 0);
      wb_stb_i   : in  std_logic;
      wb_cyc_i   : in  std_logic;
      wb_we_i    : in  std_logic;
      wb_ack_o   : out std_logic;
      wb_err_o   : out std_logic;
      wb_int_o   : out std_logic;
      wb_stall_o : out std_logic;
      pad_cs_o   : out std_logic_vector(7 downto 0);
      pad_sclk_o : out std_logic;
      pad_mosi_o : out std_logic;
      pad_miso_i : in  std_logic);
  end component;

  component xwb_spi
    generic (
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD);
    port (
      clk_sys_i  : in  std_logic;
      rst_n_i    : in  std_logic;
      slave_i    : in  t_wishbone_slave_in;
      slave_o    : out t_wishbone_slave_out;
      desc_o     : out t_wishbone_device_descriptor;
      pad_cs_o   : out std_logic_vector(7 downto 0);
      pad_sclk_o : out std_logic;
      pad_mosi_o : out std_logic;
      pad_miso_i : in  std_logic);
  end component;

  component wb_simple_uart
    generic (
      g_with_virtual_uart   : boolean                        := false;
      g_with_physical_uart  : boolean                        := true;
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD);
    port (
      clk_sys_i  : in  std_logic;
      rst_n_i    : in  std_logic;
      wb_adr_i   : in  std_logic_vector(4 downto 0);
      wb_dat_i   : in  std_logic_vector(31 downto 0);
      wb_dat_o   : out std_logic_vector(31 downto 0);
      wb_cyc_i   : in  std_logic;
      wb_sel_i   : in  std_logic_vector(3 downto 0);
      wb_stb_i   : in  std_logic;
      wb_we_i    : in  std_logic;
      wb_ack_o   : out std_logic;
      wb_stall_o : out std_logic;
      uart_rxd_i : in  std_logic := '1';
      uart_txd_o : out std_logic);
  end component;

  component xwb_simple_uart
    generic (
      g_with_virtual_uart   : boolean                        := false;
      g_with_physical_uart  : boolean                        := true;
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD);
    port (
      clk_sys_i  : in  std_logic;
      rst_n_i    : in  std_logic;
      slave_i    : in  t_wishbone_slave_in;
      slave_o    : out t_wishbone_slave_out;
      desc_o     : out t_wishbone_device_descriptor;
      uart_rxd_i : in  std_logic := '1';
      uart_txd_o : out std_logic);
  end component;

  component wb_tics
    generic (
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD;
      g_period              : integer);
    port (
      rst_n_i    : in  std_logic;
      clk_sys_i  : in  std_logic;
      wb_adr_i   : in  std_logic_vector(3 downto 0);
      wb_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0);
      wb_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
      wb_cyc_i   : in  std_logic;
      wb_sel_i   : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0);
      wb_stb_i   : in  std_logic;
      wb_we_i    : in  std_logic;
      wb_ack_o   : out std_logic;
      wb_stall_o : out std_logic);
  end component;

  component xwb_tics
    generic (
      g_interface_mode      : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity : t_wishbone_address_granularity := WORD;
      g_period              : integer);
    port (
      clk_sys_i : in  std_logic;
      rst_n_i   : in  std_logic;
      slave_i   : in  t_wishbone_slave_in;
      slave_o   : out t_wishbone_slave_out;
      desc_o    : out t_wishbone_device_descriptor);
  end component;

  component wb_vic
    generic (
      g_interface_mode      : t_wishbone_interface_mode;
      g_address_granularity : t_wishbone_address_granularity;
      g_num_interrupts      : natural);
    port (
      clk_sys_i    : in  std_logic;
      rst_n_i      : in  std_logic;
      wb_adr_i     : in  std_logic_vector(c_wishbone_address_width-1 downto 0);
      wb_dat_i     : in  std_logic_vector(c_wishbone_data_width-1 downto 0);
      wb_dat_o     : out std_logic_vector(c_wishbone_data_width-1 downto 0);
      wb_cyc_i     : in  std_logic;
      wb_sel_i     : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0);
      wb_stb_i     : in  std_logic;
      wb_we_i      : in  std_logic;
      wb_ack_o     : out std_logic;
      wb_stall_o   : out std_logic;
      irqs_i       : in  std_logic_vector(g_num_interrupts-1 downto 0);
      irq_master_o : out std_logic);
  end component;

  component xwb_vic
    generic (
      g_interface_mode      : t_wishbone_interface_mode;
      g_address_granularity : t_wishbone_address_granularity;
      g_num_interrupts      : natural);
    port (
      clk_sys_i    : in  std_logic;
      rst_n_i      : in  std_logic;
      slave_i      : in  t_wishbone_slave_in;
      slave_o      : out t_wishbone_slave_out;
      irqs_i       : in  std_logic_vector(g_num_interrupts-1 downto 0);
      irq_master_o : out std_logic);
  end component;

  constant c_wb_serial_lcd_sdb : t_sdb_device := (
    abi_class     => x"0000", -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7", -- 8/16/32-bit port granularity
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000ff",
    product => (
    vendor_id     => x"0000000000000651", -- GSI
    device_id     => x"b77a5045",
    version       => x"00000001",
    date          => x"20130222",
    name          => "SERIAL-LCD-DISPLAY ")));
  component wb_serial_lcd
    generic(
      g_cols : natural := 40;
      g_rows : natural := 24;
      g_hold : natural := 15; -- How many times to repeat a line  (for sharpness)
      g_wait : natural := 1); -- How many cycles per state change (for 20MHz timing)
    port(
      slave_clk_i  : in  std_logic;
      slave_rstn_i : in  std_logic;
      slave_i      : in  t_wishbone_slave_in;
      slave_o      : out t_wishbone_slave_out;
      di_clk_i     : in  std_logic;
      di_scp_o     : out std_logic;
      di_lp_o      : out std_logic;
      di_flm_o     : out std_logic;
      di_dat_o     : out std_logic);
  end component;

end wishbone_pkg;

package body wishbone_pkg is
  function f_ceil_log2(x : natural) return natural is
  begin
    if x <= 1
    then return 0;
    else return f_ceil_log2((x+1)/2) +1;
    end if;
  end f_ceil_log2;
  
  function f_sdb_embed_product(product : t_sdb_product)
    return std_logic_vector -- (319 downto 8)
  is
    variable result : std_logic_vector(319 downto 8);
  begin
    result(319 downto 256) := product.vendor_id;
    result(255 downto 224) := product.device_id;
    result(223 downto 192) := product.version;
    result(191 downto 160) := product.date;
    for i in 0 to 18 loop -- string to ascii
      result(159-i*8 downto 152-i*8) := 
        std_logic_vector(to_unsigned(character'pos(product.name(i+1)), 8));
    end loop;
    return result;
  end;
  
  function f_sdb_extract_product(sdb_record : std_logic_vector(319 downto 8))
    return t_sdb_product
  is
    variable result : t_sdb_product;
  begin
    result.vendor_id := sdb_record(319 downto 256);
    result.device_id := sdb_record(255 downto 224);
    result.version   := sdb_record(223 downto 192);
    result.date      := sdb_record(191 downto 160);
    for i in 0 to 18 loop -- ascii to string
      result.name(i+1) := character'val(to_integer(unsigned(sdb_record(159-i*8 downto 152-i*8))));
    end loop;
    return result;
  end;
  
  function f_sdb_embed_component(sdb_component : t_sdb_component; address : t_wishbone_address)
    return std_logic_vector -- (447 downto 8)
  is
    variable result : std_logic_vector(447 downto 8);
    
    constant first : unsigned(63 downto 0) := unsigned(sdb_component.addr_first);
    constant last  : unsigned(63 downto 0) := unsigned(sdb_component.addr_last);
    variable base  : unsigned(63 downto 0) := (others => '0');
  begin
    base(address'length-1 downto 0) := unsigned(address);
    
    result(447 downto 384) := std_logic_vector(base);
    result(383 downto 320) := std_logic_vector(base + last - first);
    result(319 downto   8) := f_sdb_embed_product(sdb_component.product);
    return result;
  end;
  
  function f_sdb_extract_component(sdb_record : std_logic_vector(447 downto 8))
    return t_sdb_component
  is
    variable result : t_sdb_component;
  begin
    result.addr_first := sdb_record(447 downto 384);
    result.addr_last  := sdb_record(383 downto 320);
    result.product    := f_sdb_extract_product(sdb_record(319 downto 8));
    return result;
  end;
  
  function f_sdb_embed_device(device : t_sdb_device; address : t_wishbone_address)
    return t_sdb_record
  is
    variable result : t_sdb_record;
  begin
    result(511 downto 496) := device.abi_class;
    result(495 downto 488) := device.abi_ver_major;
    result(487 downto 480) := device.abi_ver_minor;
    result(479 downto 453) := (others => '0');
    result(452)            := device.wbd_endian;
    result(451 downto 448) := device.wbd_width;
    result(447 downto   8) := f_sdb_embed_component(device.sdb_component, address);
    result(  7 downto   0) := x"01"; -- device
    return result;
  end;
  
  function f_sdb_extract_device(sdb_record : t_sdb_record)
    return t_sdb_device
  is
    variable result : t_sdb_device;
  begin
    result.abi_class     := sdb_record(511 downto 496);
    result.abi_ver_major := sdb_record(495 downto 488);
    result.abi_ver_minor := sdb_record(487 downto 480);
    result.wbd_endian    := sdb_record(452);
    result.wbd_width     := sdb_record(451 downto 448);
    result.sdb_component := f_sdb_extract_component(sdb_record(447 downto 8));
    
    assert sdb_record(7 downto 0) = x"01"
    report "Cannot extract t_sdb_device from record of type " & Integer'image(to_integer(unsigned(sdb_record(7 downto 0)))) & "."
    severity Failure;
    
    return result;
  end;

  function f_sdb_embed_integration(integr : t_sdb_integration)
    return t_sdb_record
  is
    variable result : t_sdb_record;
  begin
    result(511 downto 320) := (others => '0');
    result(319 downto 8)   := f_sdb_embed_product(integr.product);
    result(7 downto 0)     := x"80"; -- integration record
    return result;
  end f_sdb_embed_integration;

  function f_sdb_extract_integration(sdb_record : t_sdb_record)
    return t_sdb_integration
  is
    variable result : t_sdb_integration;
  begin
    result.product := f_sdb_extract_product(sdb_record(319 downto 8));

    assert sdb_record(7 downto 0) = x"80"
    report "Cannot extract t_sdb_integration from record of type " & Integer'image(to_integer(unsigned(sdb_record(7 downto 0)))) & "."
    severity Failure;

    return result;
  end f_sdb_extract_integration;

  function f_sdb_embed_repo_url(url : t_sdb_repo_url)
    return t_sdb_record
  is
    variable result : t_sdb_record;
  begin
    result(511 downto 8) := f_string2svl(url.repo_url);
    result(  7 downto 0) := x"81"; -- repo_url record
    return result;
  end;

  function f_sdb_extract_repo_url(sdb_record : t_sdb_record)
    return t_sdb_repo_url
  is
    variable result : t_sdb_repo_url;
  begin
    result.repo_url     := f_slv2string(sdb_record(511 downto 8));

    assert sdb_record(7 downto 0) = x"81"
    report "Cannot extract t_sdb_repo_url from record of type " & Integer'image(to_integer(unsigned(sdb_record(7 downto 0)))) & "."
    severity Failure;

    return result;
  end;

  function f_sdb_embed_synthesis(syn : t_sdb_synthesis)
    return t_sdb_record
  is
    variable result : t_sdb_record;
  begin
    result(511 downto 384) := f_string2svl(syn.syn_module_name);
    result(383 downto 256) := f_string2bits(syn.syn_commit_id);
    result(255 downto 192) := f_string2svl(syn.syn_tool_name);
    result(191 downto 160) := syn.syn_tool_version;
    result(159 downto 128) := syn.syn_date;
    result(127 downto   8) := f_string2svl(syn.syn_username);
    result(  7 downto   0) := x"82"; -- synthesis record
    return result;
  end;

  function f_sdb_extract_synthesis(sdb_record : t_sdb_record)
    return t_sdb_synthesis
  is
    variable result : t_sdb_synthesis;
  begin
    result.syn_module_name  := f_slv2string(sdb_record(511 downto 384));
    result.syn_commit_id    := f_bits2string(sdb_record(383 downto 256));
    result.syn_tool_name    := f_slv2string(sdb_record(255 downto 192));
    result.syn_tool_version := sdb_record(191 downto 160);
    result.syn_date         := sdb_record(159 downto 128);
    result.syn_username     := f_slv2string(sdb_record(127 downto   8));

    assert sdb_record(7 downto 0) = x"82"
    report "Cannot extract t_sdb_repo_url from record of type " & Integer'image(to_integer(unsigned(sdb_record(7 downto 0)))) & "."
    severity Failure;

    return result;
  end;

  function f_sdb_embed_bridge(bridge : t_sdb_bridge; address : t_wishbone_address)
    return t_sdb_record
  is
    variable result : t_sdb_record;
    
    constant first : unsigned(63 downto 0) := unsigned(bridge.sdb_component.addr_first);
    constant child : unsigned(63 downto 0) := unsigned(bridge.sdb_child);
    variable base  : unsigned(63 downto 0) := (others => '0');
  begin
    base(address'length-1 downto 0) := unsigned(address);
    
    result(511 downto 448) := std_logic_vector(base + child - first);
    result(447 downto   8) := f_sdb_embed_component(bridge.sdb_component, address);
    result(  7 downto   0) := x"02"; -- bridge
    return result;
  end;
  
  function f_sdb_extract_bridge(sdb_record : t_sdb_record) 
    return t_sdb_bridge
  is
    variable result : t_sdb_bridge;
  begin
    result.sdb_child     := sdb_record(511 downto 448);
    result.sdb_component := f_sdb_extract_component(sdb_record(447 downto 8));

    assert sdb_record(7 downto 0) = x"02"
    report "Cannot extract t_sdb_bridge from record of type " & Integer'image(to_integer(unsigned(sdb_record(7 downto 0)))) & "."
    severity Failure;
    
    return result;
  end;
  
  function f_xwb_bridge_manual_sdb(
    g_size       : t_wishbone_address;
    g_sdb_addr   : t_wishbone_address) return t_sdb_bridge
  is
    variable result : t_sdb_bridge;
  begin
    result.sdb_child := (others => '0');
    result.sdb_child(c_wishbone_address_width-1 downto 0) := g_sdb_addr;
    
    result.sdb_component.addr_first := (others => '0');
    result.sdb_component.addr_last  := (others => '0');
    result.sdb_component.addr_last(c_wishbone_address_width-1 downto 0) := g_size;
    
    result.sdb_component.product.vendor_id := x"0000000000000651"; -- GSI
    result.sdb_component.product.device_id := x"eef0b198";
    result.sdb_component.product.version   := x"00000001";
    result.sdb_component.product.date      := x"20120511";
    result.sdb_component.product.name      := "WB4-Bridge-GSI     ";
    
    return result;
  end f_xwb_bridge_manual_sdb;
  
  function f_xwb_bridge_layout_sdb(
    g_wraparound  : boolean := true;
    g_layout      : t_sdb_record_array;
    g_sdb_addr    : t_wishbone_address) return t_sdb_bridge
  is
    alias c_layout : t_sdb_record_array(g_layout'length-1 downto 0) is g_layout;

    -- How much space does the ROM need?
    constant c_used_entries : natural := c_layout'length + 1;
    constant c_rom_entries  : natural := 2**f_ceil_log2(c_used_entries); -- next power of 2
    constant c_sdb_bytes   : natural := c_sdb_device_length / 8;
    constant c_rom_bytes    : natural := c_rom_entries * c_sdb_bytes;
    
    variable result : unsigned(63 downto 0);
    variable sdb_component : t_sdb_component;
  begin
    if not g_wraparound then
      result := (others => '0');
      for i in 0 to c_wishbone_address_width-1 loop
        result(i) := '1';
      end loop;
    else
      -- The ROM will be an addressed slave as well
      result := (others => '0');
      result(c_wishbone_address_width-1 downto 0) := unsigned(g_sdb_addr);
      result := result + to_unsigned(c_rom_bytes, 64) - 1;
      
      for i in c_layout'range loop
        sdb_component := f_sdb_extract_component(c_layout(i)(447 downto 8));
        if unsigned(sdb_component.addr_last) > result then
          result := unsigned(sdb_component.addr_last);
        end if;
      end loop;
      -- round result up to a power of two -1
      for i in 62 downto 0 loop
        result(i) := result(i) or result(i+1);
      end loop;
    end if;
    
    return f_xwb_bridge_manual_sdb(std_logic_vector(result(c_wishbone_address_width-1 downto 0)), g_sdb_addr);
  end f_xwb_bridge_layout_sdb;
  
  function f_xwb_dpram(g_size : natural) return t_sdb_device
  is
    variable result : t_sdb_device;
  begin
    result.abi_class     := x"0001"; -- RAM device
    result.abi_ver_major := x"01";
    result.abi_ver_minor := x"00";
    result.wbd_width     := x"7"; -- 32/16/8-bit supported
    result.wbd_endian    := c_sdb_endian_big;
    
    result.sdb_component.addr_first := (others => '0');
    result.sdb_component.addr_last  := std_logic_vector(to_unsigned(g_size*4-1, 64));
    
    result.sdb_component.product.vendor_id := x"000000000000CE42"; -- CERN
    result.sdb_component.product.device_id := x"66cfeb52";
    result.sdb_component.product.version   := x"00000001";
    result.sdb_component.product.date      := x"20120305";
    result.sdb_component.product.name      := "WB4-BlockRAM       ";
    
    return result;
  end f_xwb_dpram;
  
  function f_bits2string(s : std_logic_vector) return string is
    --- extend length to full hex nibble
    variable result : string((s'length+7)/4 downto 1);
    variable s_norm : std_logic_vector(result'length*4-1 downto 0) := (others=>'0');
    variable cut : natural;
    variable nibble: std_logic_vector(3 downto 0);
  begin
    s_norm(s'length-1 downto 0) := s;
    for i in result'length-1 downto 0 loop
      nibble := s_norm(i*4+3 downto i*4);
      case nibble is
        when "0000" => result(i+1) := '0';
        when "0001" => result(i+1) := '1';
        when "0010" => result(i+1) := '2';
        when "0011" => result(i+1) := '3';
        when "0100" => result(i+1) := '4';
        when "0101" => result(i+1) := '5';
        when "0110" => result(i+1) := '6';
        when "0111" => result(i+1) := '7';
        when "1000" => result(i+1) := '8';
        when "1001" => result(i+1) := '9';
        when "1010" => result(i+1) := 'a';
        when "1011" => result(i+1) := 'b';
        when "1100" => result(i+1) := 'c';
        when "1101" => result(i+1) := 'd';
        when "1110" => result(i+1) := 'e';
        when "1111" => result(i+1) := 'f';
        when others => result(i+1) := 'X';
      end case;
    end loop;
    
    -- trim leading 0s
    strip : for i in result'length downto 1 loop
      cut := i;
      exit strip when result(i) /= '0';
    end loop;
    
    return "0x" & result(cut downto 1);
  end f_bits2string;

  -- Converts string (hex number, without leading 0x) to std_logic_vector
  function f_string2bits(s : string) return std_logic_vector is
    variable slv : std_logic_vector(s'length*4-1 downto 0);
    variable nibble : std_logic_vector(3 downto 0);
  begin
    for i in 0 to s'length-1 loop
      case s(i+1) is
        when '0' => nibble := X"0";
        when '1' => nibble := X"1";
        when '2' => nibble := X"2";
        when '3' => nibble := X"3";
        when '4' => nibble := X"4";
        when '5' => nibble := X"5";
        when '6' => nibble := X"6";
        when '7' => nibble := X"7";
        when '8' => nibble := X"8";
        when '9' => nibble := X"9";
        when 'a' => nibble := X"A";
        when 'A' => nibble := X"A";
        when 'b' => nibble := X"B";
        when 'B' => nibble := X"B";
        when 'c' => nibble := X"C";
        when 'C' => nibble := X"C";
        when 'd' => nibble := X"D";
        when 'D' => nibble := X"D";
        when 'e' => nibble := X"E";
        when 'E' => nibble := X"E";
        when 'f' => nibble := X"F";
        when 'F' => nibble := X"F";
        when others => nibble := "XXXX";
      end case;
      slv(((i+1)*4)-1 downto i*4) := nibble;
    end loop;
    return slv;
  end f_string2bits;

  -- Converts string to ascii (std_logic_vector)
  function f_string2svl (s : string) return std_logic_vector is
    variable slv : std_logic_vector((s'length * 8) - 1 downto 0);
  begin
    for i in 0 to s'length-1 loop
      slv(slv'high-i*8 downto (slv'high-7)-i*8) :=
        std_logic_vector(to_unsigned(character'pos(s(i+1)), 8));
    end loop;
    return slv;
  end f_string2svl;

  -- Converts ascii (std_logic_vector) to string
  function f_slv2string (slv : std_logic_vector) return string is
    variable s : string(1 to slv'length/8);
  begin
    for i in 0 to (slv'length/8)-1 loop
      s(i+1) := character'val(to_integer(unsigned(slv(slv'high-i*8 downto (slv'high-7)-i*8))));
    end loop;
    return s;
  end f_slv2string;

end wishbone_pkg;