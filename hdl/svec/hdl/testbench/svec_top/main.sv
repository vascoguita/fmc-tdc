`include "vme64x_bfm.svh"
`include "svec_vme_buffers.svh"

module main;

   reg rst_n = 0;
   reg clk_125m = 0, clk_20m = 0, acam_refclk = 0;

   always #4ns clk_125m <= ~clk_125m;
   always #16ns acam_refclk <= ~acam_refclk;
   always #25ns clk_20m <= ~clk_20m;

   
   
   initial begin
      repeat(20) @(posedge clk_125m);
      rst_n = 1;
   end
   
   IVME64X VME(rst_n);

   `DECLARE_VME_BUFFERS(VME.slave);

   reg acam_ef =1;
   wire acam_rd;
   
   
   top_tdc #(
              .values_for_simul(1)
              ) DUT (
		     .clk_20m_vcxo_i(clk_20m),
                     .por_n_i (rst_n),
                     
                     .ft0_tdc_125m_clk_p_i(clk_125m),
                     .ft0_tdc_125m_clk_n_i(~clk_125m),
                     .ft0_acam_refclk_p_i(acam_refclk),
                     .ft0_acam_refclk_n_i(~acam_refclk),
                     .ft0_pll_status_i(1'b1),
                     .ft0_rd_n_o(acam_rd),
                     .ft0_ef1_i(acam_ef),
                     .ft0_ef2_i(1'b1),
                     
                     .ft1_tdc_125m_clk_p_i(clk_125m),
                     .ft1_tdc_125m_clk_n_i(~clk_125m),
                     .ft1_pll_status_i(1'b1),
		     
		     `WIRE_VME_PINS(8)
	         );

   initial begin
      #500us;
      forever begin
      acam_ef = 0;
      wait(!acam_rd);
      #10ns;
      acam_ef = 1;
      #50us;
         
      end
   end
   

   task automatic init_vme64x_core(ref CBusAccessor_VME64x acc);
      /* map func0 to 0x80000000, A32 */
      acc.write('h7ff63, 'h80, A32|CR_CSR|D08Byte3);
      acc.write('h7ff67, 0, CR_CSR|A32|D08Byte3);
      acc.write('h7ff6b, 0, CR_CSR|A32|D08Byte3);
      acc.write('h7ff6f, 36, CR_CSR|A32|D08Byte3);
      acc.write('h7ff33, 1, CR_CSR|A32|D08Byte3);
      acc.write('h7fffb, 'h10, CR_CSR|A32|D08Byte3); /* enable module (BIT_SET = 0x10) */

   endtask // init_vme64x_core
   
   initial begin
      CBusAccessor_VME64x acc = new(VME.master);
      CBusAccessor acc_casted = CBusAccessor'(acc);
      uint64_t d;

      #30us;

      init_vme64x_core(acc);
      acc_casted.set_default_xfer_size(A32|SINGLE|D32);
      
      acc.read('h80000000, d, D32|A32|SINGLE);
      $display("Master SDB 0 = %x. Un-resetting TDC cores.", d);

      acc.write('h80020008, 'hff , D32|A32|SINGLE);

      // wait for the PLLs to settle up
      #300us;


      acc.read('h80040000, d, D32|A32|SINGLE);
      $display("SDB core 0 = %x", d);
      acc.read('h80060000, d, D32|A32|SINGLE);
      $display("SDB core 1 = %x", d);

      acc.write('h800500fc, 1, D32|A32|SINGLE); // init acquisition
   
      forever begin
         acc.read('h800500a8, d, D32|A32|SINGLE); // init acquisition
         $display("wr-ptr %x", d);
         #10us;
         
      end
      
   end // initial begin
   

  
endmodule // main




