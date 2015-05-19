`include "simdrv_defs.svh"
`include "gn4124_bfm.svh"
`include "timestamp_fifo_regs.vh"

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
	 data <= ent.ts | (ent.channel << 26) | (1<<17);
	 
      end else if (addr == 9) begin
	 acam_fifo_entry ent;
	 ent=fifo2.pop_front();
	 data <= ent.ts | (ent.channel << 26) | (1<<17);

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


   reg clk_acam = 0;
   reg clk_62m5 = 0;

   always@(posedge clk_125m)
     clk_62m5 <= ~clk_62m5;

   always@(posedge clk_62m5)
     clk_acam <= ~clk_acam;
   
   wire [3:0] tdc_addr;

   wire [27:0] tdc_data;
   

    IGN4124PCIMaster I_Gennum ();

   
   wr_spec_tdc #(
              .g_with_wr_phy(0),	
              .g_simulation(1)
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
		     .err_flag_i(1'b0),
		     .int_flag_i(1'b0),
		     .rd_n_o(tdc_rd_n),
		     .data_bus_io(tdc_data),
		     .address_o(tdc_addr),

	              `GENNUM_WIRE_SPEC_PINS(I_Gennum)

		     
		     );

   fake_acam ACAM(
		 .addr(tdc_addr),
		 .data(tdc_data),
		 .wr(1'b0),
		 .rd(tdc_rd_n),
		 .ef1(tdc_ef1),
		 .ef2(tdc_ef2)
		 );
   

   
   
   


   reg force_irq = 0;
   
   initial begin

      CBusAccessor acc;
      const uint64_t tdc1_base = 'h40000;
      uint64_t d;
      acc = I_Gennum.get_accessor();
      
      
      #100us;

      $display("Accessor: %x", acc);
      
      $display("Un-reset FMCs...");
      
      acc.write('h02000c, 'h3); 

      #500us;
      
      acc.read('h040000, d); 
      $display("TDC SDB ID : %x", d);


      acc.write('h420a0, 1234);  // set UTC
      acc.write('h420fc, 1<<9); // load UTC

      acc.write('h43004, 'hf); // enable EIC irq

      acc.write('h42084, 'h1f0000); // enable all ACAM inputs
      acc.write('h420fc, (1<<0)); // start acquisition
      
      acc.write('h420fc, (1<<0)); // start acquisition
      acc.write('h42090, 2); // thr = 2 ts
      acc.write('h42094, 10); // thr = 10 ms
      
      
      
      #300us;
      fork
	 forever begin
	    acc.read('h45000 + `ADDR_TSF_CSR, d); 
	    
	    $display("TSF CSR %x", d);
	    
	    if(d&1)  begin
	       uint64_t t0,t1,t2,t3;
	       
	       acc.write('h45000 + `ADDR_TSF_CSR, 0);
	       acc.read('h45000 + `ADDR_TSF_LTS0, t0);
	       acc.read('h45000 + `ADDR_TSF_LTS1, t1);
	       acc.read('h45000 + `ADDR_TSF_LTS2, t2);
	       acc.read('h45000 + `ADDR_TSF_LTS3, t3);

	       $display("Last: %08x %08x %08x %08x",t0,t1,t2,t3);
	       
	    end
	    

	    acc.read('h45000 + `ADDR_TSF_FIFO_CSR, d);
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
	    $display("Pulse!");
	 
	    ACAM.pulse(0, 0);
	    ACAM.pulse(1, 0);
	    ACAM.pulse(2, 0);
	    #10us;
	 end
      join
      
      
     
      
     
   end
 
   

  
endmodule // main




