import wishbone_pkg::*;
import tdc_core_pkg::*;


`include "simdrv_defs.svh"
`include "timestamp_fifo_regs.vh"
`include "if_wb_master.svh"
`include "vhd_wishbone_master.svh"
`include "acam_model.svh"
`include "softpll_regs_ng.vh"
`include "gn4124_bfm.svh"

typedef struct {
   uint32_t tai;
   uint32_t coarse;
   uint32_t frac;
   uint32_t seq;
   int      slope;
   int 	    channel;
} fmc_tdc_timestamp_t;

typedef fmc_tdc_timestamp_t fmc_tdc_timestamp_queue_t[$];

class FmcTdcDriver;
   CBusAccessor m_acc;
   uint64_t     m_base;

   fmc_tdc_timestamp_queue_t m_queues[5];
   
   // new
   function new(CBusAccessor acc, uint64_t base, bit use_dma);
      m_acc = acc;
      m_base = base;
   endfunction

   // writel
   task automatic writel(uint32_t addr, uint32_t value);
      m_acc.write(addr + m_base ,value);
   endtask

   // readl
   task automatic readl( uint32_t addr, ref uint32_t value );
      automatic uint64_t rv;
      m_acc.read(addr + m_base , rv);
      $display("[Info] readl %x: %x", addr+m_base, rv);
      value = rv;
   endtask
   
   // init
   task automatic init();
      uint32_t d;

      $display("[Info] TDC core base addr: %x", m_base);

      readl('h0, d); 
      if( d != 'h5344422d )
	  begin
	   $error("[Error!] Can't read the SDB signature.");
	   $stop;
	   end

      readl('h1000, d); 
      readl('h1004, d); 
      readl('h1008, d);
      readl('h100C, d);  

      writel('h20a0, 1234);  // set UTC
      
      $display("[Info] Setting up TDC core..");
      writel('h20a0, 1234);  // set UTC
      writel('h20fc, 1<<9); // load UTC
      writel('h3004, 'h1f); // enable EIC irqs for all FIFO channels
      writel('h2084, 'h1f0000); // enable all ACAM inputs
      writel('h2090, 2); // FIFO threshold = 2 ts
      writel('h2094, 2); // FIFO threshold = 2 ms
      writel('h20fc, (1<<0)); // start acquisition
      writel('h20bc, ((-1)<<1));
      
      $display("[Info] TDC acquisition started");
      
   endtask 
   
   // update	 
   task automatic update();
      automatic uint32_t csr, t[4];

      for(int i = 0; i < 5; i++)
	  begin
	   automatic uint32_t base = 'h5000 + i * 'h100;
	   automatic fmc_tdc_timestamp_t ts;
	   
	   readl(base + `ADDR_TSF_FIFO_CSR, csr);

	   $display("csr %x", csr);
	   
	   if( ! (csr & `TSF_FIFO_CSR_EMPTY ) )
	    begin
		  readl(base + `ADDR_TSF_FIFO_R0, t[0]);
		  readl(base + `ADDR_TSF_FIFO_R1, t[1]);
		  readl(base + `ADDR_TSF_FIFO_R2, t[2]);
		  readl(base + `ADDR_TSF_FIFO_R3, t[3]);

		  ts.tai     = t[0];
		  ts.coarse  = t[1];
		  ts.frac    = t[2] & 'hfff;
		  ts.slope   = t[3] & 'h8 ? 1: 0;
		  ts.seq     = t[3] >> 4;
		  ts.channel = i;
          m_queues[i].push_back(ts);
	     end
	   
	end // for (int i = 0; i < 5; i++)
   endtask 
   
endclass // FmcTdcDriver


//////////////// main ////////////////
module main;

   // clk, rst
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

   // wires, regs
   wire        tdc_start, tdc_start_dis;
   wire        tdc_cs_n, tdc_oe_n, tdc_rd_n, tdc_wr_n;
   wire        tdc_err_flag, tdc_int_flag;
   wire        tdc_ef1, tdc_ef2;
   wire [3:0]  tdc_addr;
   wire [27:0] tdc_data;
   wire [4:1]  tdc_stop_dis;
   reg  [8:1]  tdc_stop = 0;

   
   // ACAM model instantiation  
   tdc_gpx_model 
     #( .g_verbose(1) )
   ACAM
     (
      .PuResN(1'b1),
      .Alutrigger(1'b0),
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

   // GN4124 model instantiation  
   IGN4124PCIMaster Host
     (
    
      );

   // TDC core instantiation
   wr_spec_tdc 
     #(
       .g_simulation(1)
       ) DUT (
		     .clk_125m_pllref_p_i(clk_125m),
		     .clk_125m_pllref_n_i(~clk_125m),
		     .clk_125m_gtp_p_i(clk_125m),
		     .clk_125m_gtp_n_i(~clk_125m),


		     .fmc0_tdc_clk_125m_p_i(clk_125m),
		     .fmc0_tdc_clk_125m_n_i(~clk_125m),

		     .fmc0_tdc_acam_refclk_p_i(clk_acam),
		     .fmc0_tdc_acam_refclk_n_i(~clk_acam),

		     .clk_20m_vcxo_i(clk_20m),

             .fmc0_tdc_pll_status_i(1'b1),
		     
		     .fmc0_tdc_ef1_i(tdc_ef1),
		     .fmc0_tdc_ef2_i(tdc_ef2),
		     .fmc0_tdc_err_flag_i(tdc_err_flag),
		     .fmc0_tdc_int_flag_i(tdc_int_flag),
		     .fmc0_tdc_rd_n_o(tdc_rd_n),
		     .fmc0_tdc_wr_n_o(tdc_wr_n),
		     .fmc0_tdc_oe_n_o(tdc_oe_n),
		     .fmc0_tdc_cs_n_o(tdc_cs_n),
		     .fmc0_tdc_data_bus_io(tdc_data),
		     .fmc0_tdc_address_o(tdc_addr),
		     .fmc0_tdc_start_from_fpga_o(tdc_start),
		     .fmc0_tdc_start_dis_o(tdc_start_dis),
		     .fmc0_tdc_stop_dis_o(tdc_stop_dis[1]),
			`GENNUM_WIRE_SPEC_BTRAIN_REF(Host)
		     );

   assign tdc_stop_dis[4] = tdc_stop_dis[1];
   assign tdc_stop_dis[3] = tdc_stop_dis[1];
   assign tdc_stop_dis[2] = tdc_stop_dis[1];
   

   // initial 
   initial begin
	 CBusAccessor acc;
	 FmcTdcDriver drv;
	 const uint64_t tdc1_base = 'h20000;
	 uint64_t d;
	 acc = Host.get_accessor();
	
	 #10us;
	
    // reset
	//$display("Un-reset FMCs...");
	//acc.write('h02000c, 'h3); 

     // test read
     acc.read('h2208c, d); 

    // device instantiation
	drv = new (acc, 'h20000, 0 );
	drv.init();
	
	$display("[Info] Start operation");
      
	fork
	  forever begin
	    drv.update();
	    #10us;
	  end
	   	   
	  forever begin
	    #700ns;
	    tdc_stop[1] <= 1;
	    #300ns;
	    tdc_stop[1] <= 0;
	  end
	join
    end
   
endmodule // main




