`include "simdrv_defs.svh"
`include "vme64x_bfm.svh"
`include "svec_vme_buffers.svh"
`include "../../rtl/timestamp_fifo_regs.vh"

module fake_acam(
		 input [3:0] addr,
		 output reg [27:0] data,
		 input 	      wr,
		 input 	      rd,
		 output       reg ef1,
		 output       reg ef2
		 );

   typedef struct {
      int 	  channel;
      time 	  ts;
   } acam_fifo_entry;

   acam_fifo_entry fifo1[$], fifo2[$];

   task pulse(int channel, time ts);
      
     acam_fifo_entry ent;

      ent.channel = channel % 4;
      ent.ts = ts;
      
      if (channel >= 0 && channel <= 3) 
	 fifo1.push_back(ent);
      else
	fifo2.push_back(ent);

      #100ns;
      if(fifo1.size())
	ef1 = 0;
      if(fifo2.size())
	ef2 = 0;
      
      endtask // pulse

   initial begin
      ef1 = 1;
      ef2 = 1;
      data = 28'bz;
      
   end
   
   
   always@(negedge rd) begin
      if (addr == 8) begin
	 acam_fifo_entry ent;
	 ent=fifo1.pop_front();
	 data <= ent.ts | (ent.channel << 26);
	 
      end else if (addr == 9) begin
	 acam_fifo_entry ent;
	 ent=fifo2.pop_front();
	 data <= ent.ts | (ent.channel << 26);

      end else
	data <= 28'bz;

      #10ns;

      	ef1 <= (fifo1.size() ? 0 : 1);
      	ef2 <= (fifo2.size() ? 0 : 1);
      
	
   end
   
   
   
endmodule
   

module main;

   reg rst_n = 0;
   reg clk_125m = 0, clk_20m = 0;

   always #4ns clk_125m <= ~clk_125m;
   always #25ns clk_20m <= ~clk_20m;
   
   initial begin
      repeat(20) @(posedge clk_125m);
      rst_n = 1;
   end

   IVME64X VME(rst_n);

   `DECLARE_VME_BUFFERS(VME.slave);

   reg clk_acam = 0;
   reg clk_62m5 = 0;
   

   always@(posedge clk_125m)
     clk_62m5 <= ~clk_62m5;

   always@(posedge clk_62m5)
     clk_acam <= ~clk_acam;
   
   wire [3:0] tdc_addr;

   wire [27:0] tdc_data;
   
   
   wr_svec_tdc #(
              .g_with_wr_phy(0),	
              .g_simulation(1)
              ) DUT (
		     .clk_125m_pllref_p_i(clk_125m),
		     .clk_125m_pllref_n_i(~clk_125m),
		     .clk_125m_gtp_p_i(clk_125m),
		     .clk_125m_gtp_n_i(~clk_125m),


		     .tdc1_125m_clk_p_i(clk_125m),
		     .tdc1_125m_clk_n_i(~clk_125m),

		     .tdc1_acam_refclk_p_i(clk_acam),
		     .tdc1_acam_refclk_n_i(~clk_acam),

		     .clk_20m_vcxo_i(clk_20m),
                     .tdc1_pll_status_i(1'b1),
		     .por_n_i(rst_n),

		     .tdc1_ef1_i(tdc_ef1),
		     .tdc1_ef2_i(tdc_ef2),
		     .tdc1_err_flag_i(1'b0),
		     .tdc1_int_flag_i(1'b0),
		     .tdc1_rd_n_o(tdc_rd_n),
		     .tdc1_data_bus_io(tdc_data),
		     .tdc1_address_o(tdc_addr),
		     
		     `WIRE_VME_PINS(8)
		     );

   fake_acam ACAM(
		 .addr(tdc_addr),
		 .data(tdc_data),
		 .wr(1'b0),
		 .rd(tdc_rd_n),
		 .ef1(tdc_ef1),
		 .ef2(tdc_ef2)
		 );
   

   
   
   

  task automatic config_vme_function(ref CBusAccessor_VME64x acc, input int func, uint64_t base, int am);
      uint64_t addr = 'h7ff63 + func * 'h10;
      uint64_t val = (base) | (am << 2);

      $display("Func%d ADER=0x%x", func, val);

     if(am == 0)
       val = 1;
      
      acc.write(addr + 0, (val >> 24) & 'hff, CR_CSR|A32|D08Byte3);
      acc.write(addr + 4, (val >> 16) & 'hff, CR_CSR|A32|D08Byte3);
      acc.write(addr + 8, (val >> 8)  & 'hff, CR_CSR|A32|D08Byte3);
      acc.write(addr + 12, (val >> 0) & 'hff, CR_CSR|A32|D08Byte3);
 
      
   endtask // config_vme_function
   
   
   task automatic init_vme64x_core(ref CBusAccessor_VME64x acc);
      uint64_t rv;


      /* map func0 to 0x80000000, A32 */
//      config_vme_function(acc, 0, 'h80000000, 'h09);
      /* map func1 to 0xc00000, A24 */
      config_vme_function(acc, 1, 'hc00000, 'h39);
      config_vme_function(acc, 0, 0, 0);

      acc.write('h7ff33, 1, CR_CSR|A32|D08Byte3);
      acc.write('h7fffb, 'h10, CR_CSR|A32|D08Byte3); /* enable module (BIT_SET = 0x10) */

      acc.set_default_modifiers(A24 | D32 | SINGLE);
   endtask // init_vme64x_core
   

   reg force_irq = 0;
   
   initial begin
      CBusAccessor_VME64x acc = new(VME.master);
      CBusAccessor acc_casted = CBusAccessor'(acc);

      uint64_t d;
      const uint64_t tdc1_base = 'h30000;
      
      #100us;

      init_vme64x_core(acc);
      acc_casted.set_default_xfer_size(A24|SINGLE|D32);
 
      #15us;


      $display("Un-reset FMCs...");
      
      acc.write('hc0100c, 'h3); 

      #500us;
      
      acc.read('hc10000, d); 
      $display("TDC SDB ID : %x", d);


      acc.write('hc120a0, 1234);  // set UTC
      acc.write('hc120fc, 1<<9); // load UTC

      acc.write('hc13004, 'hf); // enable EIC irq

      acc.write('hc12084, 'h1f); // enable all ACAM inputs
      acc.write('hc120fc, (1<<0)); // start acquisition
      
      acc.write('hc120fc, (1<<0)); // start acquisition
      acc.write('hc12090, 2); // thr = 2 ts
      acc.write('hc12094, 10); // thr = 10 ms
      
      
      
      #300us;
      fork
	 forever begin
	    acc.read('hc15000 + `ADDR_TSF_LTSCTL, d); 
	    if(d&1)  begin
	       uint64_t t0,t1,t2,t3;
	       
	       acc.write('hc15000 + `ADDR_TSF_LTSCTL, 0);
	       acc.read('hc15000 + `ADDR_TSF_LTS0, t0);
	       acc.read('hc15000 + `ADDR_TSF_LTS1, t1);
	       acc.read('hc15000 + `ADDR_TSF_LTS2, t2);
	       acc.read('hc15000 + `ADDR_TSF_LTS3, t3);

	       $display("Last: %08x %08x %08x %08x",t0,t1,t2,t3);
	       
	    end
	    
	      

	 end
	 
      
	 forever begin
	    $display("Pulse!");
	 
	    ACAM.pulse(0, 0);
	    ACAM.pulse(1, 0);
	    ACAM.pulse(2, 0);
	    #10us;
	 end
      join
      
      
     
      
     
   end
 
   

  
endmodule // main




