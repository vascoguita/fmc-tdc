`include "simdrv_defs.svh"
`include "if_wb_master.svh"
`include "if_wb_slave.svh"

interface IVHDWishboneMaster
  (
   input clk_i,
   input rst_n_i
   );

   parameter g_addr_width 	   = 32;
   parameter g_data_width 	   = 32;

   typedef virtual IWishboneMaster VIWishboneMaster;
   
   IWishboneMaster #(g_addr_width, g_data_width) TheMaster (clk_i, rst_n_i);

   t_wishbone_master_in in;
   t_wishbone_master_out out;

   modport master
     (
      input  in,
      output out
      );
   
   assign out.cyc = TheMaster.cyc;
   assign out.stb = TheMaster.stb;
   assign out.we = TheMaster.we;
   assign out.sel = TheMaster.sel;
   assign out.adr = TheMaster.adr;
   assign out.dat = TheMaster.dat_o;
   
   assign TheMaster.ack = in.ack;
   assign TheMaster.stall = in.stall;
   assign TheMaster.rty = in.rty;
   assign TheMaster.err = in.err;
   assign TheMaster.dat_i = in.dat;

   
   function CBusAccessor get_accessor();
      return TheMaster.get_accessor();
   endfunction // get_accessor

   initial begin
      CWishboneAccessor acc;
      
      @(posedge rst_n_i);
      @(posedge clk_i);

      TheMaster.settings.addr_gran = BYTE;
      TheMaster.settings.cyc_on_stall = 1;
      
      acc = TheMaster.get_accessor();
      acc.set_mode( PIPELINED );
      
   end
   
      
endinterface // IVHDWishboneMaster


interface IVHDWishboneSlave
  (
   input clk_i,
   input rst_n_i
   );

   parameter g_addr_width 	   = 32;
   parameter g_data_width 	   = 32;

   typedef virtual IWishboneSlave VIWishboneSlave;
   
   IWishboneSlave #(g_addr_width, g_data_width) TheSlave (clk_i, rst_n_i);
   
   t_wishbone_slave_in in;
   t_wishbone_slave_out out;

   modport slave
     (
      input  in,
      output out
      );
   
   assign TheSlave.cyc = in.cyc;
   assign TheSlave.stb = in.stb;
   assign TheSlave.we = in.we;
   assign TheSlave.sel = in.sel;
   assign TheSlave.adr = in.adr;
   assign TheSlave.dat_i = in.dat;
   
   assign out.ack = TheSlave.ack;
   assign out.stall = TheSlave.stall;
   assign out.rty = TheSlave.rty;
   assign out.err = TheSlave.err;
   assign out.dat = TheSlave.dat_o;

   function automatic CWishboneAccessor get_accessor();
      return TheSlave.get_accessor();
   endfunction // get_accessor
   
   initial begin
      
      @(posedge rst_n_i);
      @(posedge clk_i);

      TheSlave.settings.mode = PIPELINED;
      TheSlave.settings.stall_prob = 0.1;
      TheSlave.settings.gen_random_stalls = 1;
      TheSlave.settings.stall_min_duration = 1;
      TheSlave.settings.stall_max_duration = 5;
      
   end
   
      
endinterface // IVHDWishboneSlave

