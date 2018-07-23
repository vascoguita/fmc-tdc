import wishbone_pkg::*;
import tdc_core_pkg::*;


`include "simdrv_defs.svh"
`include "timestamp_fifo_regs.vh"
`include "if_wb_master.svh"
`include "vhd_wishbone_master.svh"
`include "acam_model.svh"

module main;

   reg rst_n = 0;
   reg clk_125m = 0, clk_20m = 0;

   always #4ns clk_125m <= ~clk_125m;
   always #25ns clk_20m <= ~clk_20m;
   
   initial begin
      repeat(20) @(posedge clk_125m);
      rst_n = 1;
   end


   reg clk_acam = 0; // 31.25 MHz
   reg clk_62m5 = 0;

   always@(posedge clk_125m)
     clk_62m5 <= ~clk_62m5;

   always@(posedge clk_62m5)
     clk_acam <= ~clk_acam;

   
   wire [3:0] tdc_addr;
   wire [27:0] tdc_data;
   reg [8:1]  tdc_stop = 0;
   wire        tdc_start, tdc_start_dis, tdc_stop_dis;
   wire        tdc_alutrigger = 0;
   wire        tdc_cs_n, tdc_oe_n, tdc_rd_n, tdc_wr_n;
   wire        tdc_err_flag, tdc_int_flag;
   wire        tdc_ef1, tdc_ef2;
   
   


   tdc_gpx_model ACAM
     (
      .PuResN(1'b1),
      .Alutrigger(tdc_alutrigger),
      .RefClk(clk_acam),

      .WRN(tdc_wr_n),
      .RDN(tdc_rd_n),
      .CSN(tdc_cs_n),
      .OEN(tdc_oe_n),

      .Adr(tdc_addr),

      .TStart(tdc_start),
      .TStop(tdc_stop),

      .StartDis(tdc_start_dis),
      .StopDis(tdc_stop_dis),

      .IrFlag(tdc_int_flag),
      .ErrFlag(tdc_err_flag),

      .EF1(tdc_ef1),
      .EF2(tdc_ef2),
   
      .LF1(),
      .LF2(),

      .D(tdc_data)
      );
   

   
   wr_spec_tdc #(
              .g_with_wr_phy(0),	
              .g_simulation(1),
	      .g_calib_soft_ip(0),
	      .g_sim_bypass_gennum(1)
              ) DUT (
		     .clk_125m_pllref_p_i(clk_125m),
		     .clk_125m_pllref_n_i(~clk_125m),
		     .clk_125m_gtp_p_i(clk_125m),
		     .clk_125m_gtp_n_i(~clk_125m),


		     .tdc_clk_125m_p_i(clk_125m),
		     .tdc_clk_125m_n_i(~clk_125m),

		     .acam_refclk_p_i(clk_acam),
		     .acam_refclk_n_i(~clk_acam),

		     .clk_20m_vcxo_i(clk_20m),
                     .pll_status_i(1'b1),

		     
		     .ef1_i(tdc_ef1),
		     .ef2_i(tdc_ef2),
		     .err_flag_i(tdc_err_flag),
		     .int_flag_i(tdc_int_flag),
		     .rd_n_o(tdc_rd_n),
		     .wr_n_o(tdc_wr_n),
		     .oe_n_o(tdc_oe_n),
		     .cs_n_o(tdc_cs_n),
		     .data_bus_io(tdc_data),
		     .address_o(tdc_addr),
		     .start_from_fpga_o(tdc_start),
//		     .start_dis_o(tdc_start_dis),
//		     .stop_dis_o(tdc_stop_dis),
		     
		     .sim_wb_i(Host.out),
		     .sim_wb_o(Host.in)
		     
		     );

  
      IVHDWishboneMaster Host
     (
      .clk_i   (DUT.clk_62m5_sys),
      .rst_n_i (DUT.rst_n_sys));

		     
   assign tdc_start_dis = 0;
   assign tdc_stop_dis = 0;
   
   
   


   reg force_irq = 0;
   
   initial begin

      CBusAccessor acc;
      const uint64_t tdc1_base = 'h40000;
      uint64_t d;
      acc = Host.get_accessor();
      
      
      #10us;

      $display("Accessor: %x", acc);
      
      $display("Un-reset FMCs...");
      
      acc.write('h02000c, 'h3); 

      #5us;
      
      acc.read('h040000, d); 
      $display("TDC SDB ID : %x", d);

      acc.read('h050000, d); 
      $display("TDC DMA R0 : %x", d);

      acc.write('h045000, 'hdeadbeef); 
      acc.read('h045000, d); 
      $display("TDC Buf CSR : %x", d);


      acc.write('h420a0, 1234);  // set UTC
      acc.write('h420fc, 1<<9); // load UTC

      acc.write('h43004, 'hf); // enable EIC irq

      acc.write('h42084, 'h1f0000); // enable all ACAM inputs
      acc.write('h420fc, (1<<0)); // start acquisition
      
      acc.write('h420fc, (1<<0)); // start acquisition
      acc.write('h42090, 2); // thr = 2 ts
      acc.write('h42094, 10); // thr = 10 ms
      
      $display("Start operation");
      
      
      fork
	 forever begin
	    acc.read('h45000 + `ADDR_TSF_CSR, d); 
	    
//	    $display("TSF CSR %x", d);
	    
	    if(d&1)  begin
	       uint64_t t0,t1,t2,t3;
	       
	       acc.write('h45000 + `ADDR_TSF_CSR, 0);
	       acc.read('h45000 + `ADDR_TSF_LTS0, t0);
	       acc.read('h45000 + `ADDR_TSF_LTS1, t1);
	       acc.read('h45000 + `ADDR_TSF_LTS2, t2);
	       acc.read('h45000 + `ADDR_TSF_LTS3, t3);

	       $display("Last: %08x %08x %08x %08x",t0,t1,t2,t3);
	       
	    end
	    

//	    acc.read('h45000 + `ADDR_TSF_FIFO_CSR, d);
//	    $display("FIFO CSR %x", d);
	    
/* -----\/----- EXCLUDED -----\/-----
	       if(!(d&`TSF_FIFO_CSR_EMPTY))  begin
		    uint64_t t0,t1,t2,t3;
	       
	       acc.read('hc15000 + `ADDR_TSF_FIFO_R0, t0);
	       acc.read('hc15000 + `ADDR_TSF_FIFO_R1, t1);
	       acc.read('hc15000 + `ADDR_TSF_FIFO_R2, t2);
	       acc.read('hc15000 + `ADDR_TSF_FIFO_R3, t3);

	       $display("Fifo: %08x %08x %08x %08x",t0,t1,t2,t3);
	       end
 -----/\----- EXCLUDED -----/\----- */
	    
	 end
	 
      
	 forever begin
	    #10us;
	    
	    $display("pulse @ %t", $time);
	    
	    tdc_stop[1] <= 1;
	    #110ns;
	    tdc_stop[1] <= 0;
	    #10us;
	 end
      join
      
      
     
      
     
   end
 
   

  
endmodule // main




