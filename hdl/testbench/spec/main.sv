`timescale 1ns/1ps

`include "timestamp_fifo_regs.vh"
`include "tdc_eic_wb_regs.vh"
`include "tdc_core_csr_wb.vh"
`include "vic_wb.vh"
`include "dma_controller_wb.vh"


`include "gn4124_bfm.svh"
`include "acam_model.svh"

`define DMA_BASE 'h00c0
`define VIC_BASE 'h0100

`define TDC_CORE_BASE 'h20000
`define TDC_CORE_CFG_BASE 'h2000
`define FIFO1_BASE 'h5000
`define FIFO1_BASE 'h5000
`define TDC_EIC_BASE 'h3000
`define TDC_DMA_BASE 'h6000

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
      //$display("[Info] writel %x: %x", addr+m_base, value);
   endtask

   // readl
   task automatic readl( uint32_t addr, ref uint32_t value );
      automatic uint64_t rv;
      m_acc.read(addr + m_base , rv);
      //$display("[Info] readl %x: %x", addr+m_base, rv);
      value = rv;
   endtask
   
   // init
   task automatic init();
      uint32_t d;

      $display("[Info] TDC core base addr: %x", m_base);

      readl('h0, d); 
      if( d != 'h5344422d )
	  begin
	    $error("[Error!] Can't read the SDB signature, reading: %x.", d);
	    $stop;
	   end

      if( d == 'h5344422d )
 	  begin
	    $display("[Info] Found the SDB signature: %x", d);
	  end

      // Configure the EIC for an interrupt on FIFO
      writel(`TDC_EIC_BASE + `ADDR_TDC_EIC_EIC_IER, 'h1F);

      // Configure the VIC
      writel(`VIC_BASE + `ADDR_VIC_IER, 'h7f);
      writel(`VIC_BASE + `ADDR_VIC_CTL, 'h1);

      // Configure the TDC
      $display("[Info] Setting up TDC core..");
      writel(`ADDR_TDC_CORE_CSR_UTC+`TDC_CORE_CFG_BASE, 1234);  // set UTC
      writel(`ADDR_TDC_CORE_CSR_CTRL+`TDC_CORE_CFG_BASE, 1<<9); // load UTC
      writel(`ADDR_TDC_CORE_CSR_ENABLE+`TDC_CORE_CFG_BASE, 'h1f0000); // enable all ACAM inputs
      writel(`ADDR_TDC_CORE_CSR_IRQ_TSTAMP_THRESH+`TDC_CORE_CFG_BASE, 2); // FIFO threshold = 2 ts
      writel(`ADDR_TDC_CORE_CSR_IRQ_TIME_THRESH+`TDC_CORE_CFG_BASE, 2); // FIFO threshold = 2 ms
      writel(`ADDR_TDC_CORE_CSR_CTRL+`TDC_CORE_CFG_BASE, (1<<0)); // start acquisition
      writel('h20bc, ((-1)<<1)); // test?
      
      $display("[Info] TDC acquisition started");
      
   endtask 
   
   // update	 
   task automatic update();
      automatic uint32_t csr, t[4];

    for(int i = 0; i < 1; i++) // only ch1 for now -- (int i = 0; i < 5; i++)
	  begin
	    automatic uint32_t FIFObase = `FIFO1_BASE + i * 'h100;
	    automatic fmc_tdc_timestamp_t ts, ts1, ts2;
	   
	    readl(FIFObase + `ADDR_TSF_FIFO_CSR, csr);
	   
	    if( ! (csr & `TSF_FIFO_CSR_EMPTY ) )
	      //$display("FIFO has values");
	      begin
		    readl(FIFObase + `ADDR_TSF_FIFO_R0, t[0]);
		    readl(FIFObase + `ADDR_TSF_FIFO_R1, t[1]);
		    readl(FIFObase + `ADDR_TSF_FIFO_R2, t[2]);
		    readl(FIFObase + `ADDR_TSF_FIFO_R3, t[3]);

            ts.tai = t[0];
		    ts.coarse = t[1];
		    ts.frac = t[2] & 'hfff;
	    	ts.slope = t[3] & 'h8 ? 1: 0;
	    	ts.seq = t[3] >> 4;
		    ts.channel = i;
		
		    m_queues[i].push_back(ts);	
	      end
	   end // for (int i = 0; i < 5; i++)
  endtask // update_fifo

  function int poll();
    $display("[Info] m_queues[0].size: %d", m_queues[0].size());
    return (m_queues[0].size() > 10);
  endfunction // poll

  function fmc_tdc_timestamp_t get();
    return m_queues[0].pop_front();
  endfunction // get

  // update DMA i/f		 
  task automatic update_dma();
	automatic uint32_t DMA_CH_base = `TDC_DMA_BASE + 'h100;
    automatic uint32_t dma_pos, dma_len;

    // read position?
    //readl(`DMA_CH_base + `POS, dma_pos); position in DDR /////
    $display("<%t> Start DMA, position in DDR: %.8x", $realtime, dma_pos);
    // read length?
    //readl(`DMA_CH_base + `POS, dma_len); position in DDR /////
    $display("<%t> Start DMA, position in DDR: %.8x", $realtime, dma_len);

    // DMA transfer
    writel(`DMA_BASE + `ADDR_DMA_CSTART, dma_pos); // dma start addr

    writel(`DMA_BASE + `ADDR_DMA_HSTARTL, 'h00001000); // host addr
    writel(`DMA_BASE + `ADDR_DMA_HSTARTH, 'h00000000);

    // length = 
    writel(`DMA_BASE + `ADDR_DMA_LEN, dma_len); // length

    writel(`DMA_BASE + `ADDR_DMA_NEXTL, 'h00000000); // next
    writel(`DMA_BASE + `ADDR_DMA_NEXTH, 'h00000000);

    writel(`DMA_BASE + `ADDR_DMA_ATTRIB, 'h00000000); // attrib: pcie -> host

    writel(`DMA_BASE + `ADDR_DMA_ATTRIB, 'h00000001); // xfer start

    //wait (DUT.inst_spec_base.irqs[2]);
    $display("<%t> END DMA", $realtime);
    writel(`DMA_BASE + `ADDR_DMA_STAT, 'h04); // clear DMA IRQ
    writel(`VIC_BASE + `ADDR_DMA_NEXTH, 'h0);
  endtask // update_dma

   
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

   wire ddr_cas_n, ddr_ck_p, ddr_ck_n, ddr_cke;
   wire [1:0] ddr_dm, ddr_dqs_p, ddr_dqs_n;
   wire ddr_odt, ddr_ras_n, ddr_reset_n, ddr_we_n;
   wire [15:0] ddr_dq;
   wire [13:0] ddr_a;
   wire [2:0]  ddr_ba;
   wire        ddr_rzq;

   
   // ACAM model instantiation  
   tdc_gpx_model 
     #( .g_verbose(0) )
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
   IGN4124PCIMaster Host ();

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
			//`GENNUM_WIRE_SPEC_BTRAIN_REF(Host)
      .gn_rst_n_i                (Host.rst_n),
      .gn_p2l_clk_n_i            (Host.p2l_clk_n),
      .gn_p2l_clk_p_i            (Host.p2l_clk_p),
      .gn_p2l_rdy_o              (Host.p2l_rdy),
      .gn_p2l_dframe_i           (Host.p2l_dframe),
      .gn_p2l_valid_i            (Host.p2l_valid),
      .gn_p2l_data_i             (Host.p2l_data),
      .gn_p_wr_req_i             (Host.p_wr_req),
      .gn_p_wr_rdy_o             (Host.p_wr_rdy),
      .gn_rx_error_o             (Host.rx_error),
      .gn_l2p_clk_n_o            (Host.l2p_clk_n),
      .gn_l2p_clk_p_o            (Host.l2p_clk_p),
      .gn_l2p_dframe_o           (Host.l2p_dframe),
      .gn_l2p_valid_o            (Host.l2p_valid),
      .gn_l2p_edb_o              (Host.l2p_edb),
      .gn_l2p_data_o             (Host.l2p_data),
      .gn_l2p_rdy_i              (Host.l2p_rdy),
      .gn_l_wr_rdy_i             (Host.l_wr_rdy),
      .gn_p_rd_d_rdy_i           (Host.p_rd_d_rdy),
      .gn_tx_error_i             (Host.tx_error),
      .gn_vc_rdy_i               (Host.vc_rdy),
      .gn_gpio_b                 (),
      .ddr_a_o                   (ddr_a),
      .ddr_ba_o                  (ddr_ba),
      .ddr_cas_n_o               (ddr_cas_n),
      .ddr_ck_n_o                (ddr_ck_n),
      .ddr_ck_p_o                (ddr_ck_p),
      .ddr_cke_o                 (ddr_cke),
      .ddr_dq_b                  (ddr_dq),
      .ddr_ldm_o                 (ddr_dm[0]),
      .ddr_ldqs_n_b              (ddr_dqs_n[0]),
      .ddr_ldqs_p_b              (ddr_dqs_p[0]),
      .ddr_odt_o                 (ddr_odt),
      .ddr_ras_n_o               (ddr_ras_n),
      .ddr_reset_n_o             (ddr_reset_n),
      .ddr_rzq_b                 (ddr_rzq),
      .ddr_udm_o                 (ddr_dm[1]),
      .ddr_udqs_n_b              (ddr_dqs_n[1]),
      .ddr_udqs_p_b              (ddr_dqs_p[1]),
      .ddr_we_n_o                (ddr_we_n)
      );

   // DDR3 model instantiation
   ddr3 #
     (
      .DEBUG(0),
      .check_strict_timing(0),
      .check_strict_mrbits(0)
      )
   cmp_ddr0
     (
      .rst_n   (ddr_reset_n),
      .ck      (ddr_ck_p),
      .ck_n    (ddr_ck_n),
      .cke     (ddr_cke),
      .cs_n    (1'b0),
      .ras_n   (ddr_ras_n),
      .cas_n   (ddr_cas_n),
      .we_n    (ddr_we_n),
      .dm_tdqs (ddr_dm),
      .ba      (ddr_ba),
      .addr    (ddr_a),
      .dq      (ddr_dq),
      .dqs     (ddr_dqs_p),
      .dqs_n   (ddr_dqs_n),
      .tdqs_n  (),
      .odt     (ddr_odt)
      );



   assign tdc_stop_dis[4] = tdc_stop_dis[1];
   assign tdc_stop_dis[3] = tdc_stop_dis[1];
   assign tdc_stop_dis[2] = tdc_stop_dis[1];
   

   // initial 
   initial begin
	 CBusAccessor acc;
	 FmcTdcDriver drv;
	 uint64_t d;
	 acc = Host.get_accessor();
	
	 #10us;
	
     // test read
     acc.read('h2208c, d); 

    // device instantiation
	drv = new (acc, `TDC_CORE_BASE, 0 );
	drv.init();
	
	$display("[Info] Start operation");
      
	fork
	  forever begin
	     drv.update();
         if(drv.poll()) begin
         fmc_tdc_timestamp_t ts1, ts2;
	     uint64_t timestmp1, timestmp2, diff;
           ts1 = drv.get();
           timestmp1 = ts1.tai*1e12 + ts1.coarse*8e3 + ts1.frac*81.03;
           $display("[Info] ts%d [%d:%d:%d src %d, slp: %d]: %d ps", ts1.seq, ts1.tai, ts1.coarse, ts1.frac, ts1.channel, ts1.slope, timestmp1);
           ts2 = drv.get();
           timestmp2 = ts2.tai*1e12 + ts2.coarse*8e3 + ts2.frac*81.03;
           $display("[Info] ts%d [%d:%d:%d src %d, slp: %d]:  %d ps", ts2.seq, ts2.tai, ts2.coarse, ts2.frac, ts2.channel, ts2.slope, timestmp2);
           if (timestmp1 > timestmp2) begin
             diff = timestmp1 - timestmp2;
             $display("[Info] Period: ts%d - ts%d:  %d",  ts1.seq, ts2.seq, diff); 
           end else begin 
             diff = timestmp2 - timestmp1;
             $display("[Info] Period: ts%d - ts%d:  %d",  ts2.seq, ts1.seq, diff);       
           end
	     end
	   end
	   	   
	  forever begin
         // generate pulses to TDC channel 1
	    #700ns;
	    tdc_stop[1] <= 1;
	    #300ns;
	    tdc_stop[1] <= 0;
	  end
	join
    end
   
endmodule // main




