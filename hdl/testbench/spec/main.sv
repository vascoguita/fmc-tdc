`timescale 1ns/1ps

`include "timestamp_fifo_regs.vh"
`include "tdc_eic_wb_regs.vh"
`include "tdc_core_csr_wb.vh"
`include "vic_wb.vh"
`include "dma_controller_wb.vh"

`include "regs/tdc_buffer_control_regs.vh"
`include "regs/spec_base_regs.vh"

`include "gn4124_bfm.svh"
`include "acam_model.svh"

// don't use the ACAM model, we're testing the readout here
`undef USE_ACAM_MODEL

import tdc_core_pkg::*;


// Base addresses of the cores (relative to the beginning of gn4124 BAR0)
`define BASE_SPEC_CSR  'h0000
`define BASE_GENNUM_DMA 'h00c0
`define BASE_VIC 'h0100
`define BASE_TDC_CORE 'h20000

// Offsets of TDC core subcomponents
`define OFFSET_TDC_CORE_CFG 'h2000
`define OFFSET_TDC_FIFO1 'h5000
`define OFFSET_TDC_EIC 'h3000
`define OFFSET_TDC_BUFFER_CONTROLLER 'h6000

// VIC IRQ line assignemnts
`define VIC_IRQ_GENNUM_DMA 2
`define VIC_IRQ_TDC_CORE 6

// base address of the Gennum BAR with system RAM
`define BASE_HOST_MEM 'h20000000

`define TDC_EIC_BUFFER0 (5)

// internal TDC timestamp structure
typedef struct {
   uint32_t tai;
   uint32_t coarse;
   uint32_t frac;
   uint32_t seq;
   int      slope;
   int 	    channel;
} fmc_tdc_timestamp_t;

typedef fmc_tdc_timestamp_t fmc_tdc_timestamp_queue_t[$];

// generates a stream of fake (random) timestamps. They are stored in an internal
// queue so that later they can be compared against the values read out over DMA.
class FakeTimestampGenerator;
   protected fmc_tdc_timestamp_queue_t m_queue;
   protected int m_seq, m_channel;
   protected int m_enabled;   

   function new(int channel);
      m_channel = channel;
      m_seq = 0;
      m_enabled = 0;
   endfunction // new
   
   function int is_enabled();
      return m_enabled;
   endfunction // is_enabled

   task automatic enable(int e);
      m_enabled = e;
   endtask // enable
   
   function automatic fmc_tdc_timestamp_queue_t get_queue();
      return m_queue;
   endfunction // get_queue

// produces a signle fake timestamp. Returns it and also stores in the local queue for further 
// verification
   function automatic t_tdc_timestamp generate_hw_timestamp(  int slope = 0);
      fmc_tdc_timestamp_t ts;
      t_tdc_timestamp ts_hw;
      
      ts.tai = $random % 10000;
      ts.coarse = $random % 125000000;
      ts.frac = $random % 4096;
      ts.seq = m_seq;
      ts.slope = slope;
      ts.channel = m_channel;

      ts_hw.tai = ts.tai;
      ts_hw.coarse = ts.coarse;
      ts_hw.frac = ts.frac;
      ts_hw.channel = ts.channel;
      ts_hw.slope = ts.slope;
      ts_hw.seq = ts.seq;
      
      m_seq++;
      return ts_hw;
   endfunction // generate_hw_timestamp
   
   
   
endclass // FakeTimestampGenerator

// Base interface class for a Device (with an assigned base address) connected to a particular bus.
class IBusDevice;

   CBusAccessor m_acc;
   uint64_t m_base;

   function new ( CBusAccessor acc, uint64_t base );
      m_acc =acc;
      m_base = base;
   endfunction // new
   
   virtual task write32( uint32_t addr, uint32_t val );
//      $display("write32 addr %x val %x", m_base + addr, val);
      m_acc.write(m_base +addr, val);
   endtask // write
   
   virtual task read32( uint32_t addr, output uint32_t val );
      automatic uint64_t val64;
      m_acc.read(m_base + addr, val64);
      val = val64;
   endtask // write

endclass // BusDevice


// Driver for the VIC.
class VICDriver extends IBusDevice;
   function new(CBusAccessor bus, uint64_t base);
      super.new(bus, base);
   endfunction // new

   task automatic init();
      int i;
      for(i=0;i<32;i++)
	write32(`BASE_VIC_IVT_RAM + i * 4, i);
      write32(`ADDR_VIC_CTL, `VIC_CTL_ENABLE);
   endtask // init
   
   task automatic enable_irqs(uint32_t mask);
      write32(`ADDR_VIC_IER, mask);
   endtask // enable_irqs

   task automatic disable_irqs(uint32_t mask);
      write32(`ADDR_VIC_IDR, mask);
   endtask // enable_irqs

   task automatic get_pending_irq(output uint32_t id);
      read32(`ADDR_VIC_VAR, id);
   endtask // get_pending_irqs

   task automatic clear_pending_irq(uint32_t mask);
      write32(`ADDR_VIC_EOIR, mask);
   endtask // get_pending_irqs
   
   
endclass // VICDriver

// abstract interface implementing an interrupt handler. Used by IrqLine module
// to redirect IRQ events to an appropriate handler function/class.
virtual class IrqHandler;
   pure virtual task irq(int id);
endclass // IrqHandler

// Trivial driver for the Gennum DMA
class GennumDMA extends IBusDevice;

   protected bit m_dma_pending;
   protected time m_t_start, m_t_end;
   protected uint32_t m_last_size;
   
   
   function new(CBusAccessor bus, uint64_t base);
      super.new(bus, base);
      m_dma_pending = 0;
   endfunction // new


   // executes a Local-to-Host DMA transfer.
  task automatic dma_to_host( uint32_t addr_card, uint32_t addr_host, uint32_t size);
    // DMA transfer
     $display("[Info] Start GN4124 DMA: card=0x%x host=0x%x size=%d", addr_card,addr_host,size);
     
     write32(`ADDR_DMA_CSTART, addr_card); // dma start addr (card address space)
     write32(`ADDR_DMA_HSTARTL, addr_host); // host addr
     write32(`ADDR_DMA_HSTARTH, 'h00000000);
     write32(`ADDR_DMA_LEN, size); // length
     write32(`ADDR_DMA_NEXTL, 'h00000000); // next (we don't use chained transfers for the moment)
     write32(`ADDR_DMA_NEXTH, 'h00000000);
     write32(`ADDR_DMA_ATTRIB, 'h00000000); // attrib: pcie -> host
     write32(`ADDR_DMA_CTRL, 'h00000001); // xfer start
     m_t_start = $time;
     m_last_size = size;
     m_dma_pending = 1;
  endtask // dma_to_host

   // IRQ handler for the DMA complete interrupt
   task automatic irq_dma_complete();
      // strange, we got an IRQ without a pending DMA xfer?
      if ( !m_dma_pending )
	$display("[Error] GN4124 DMA irq without a pending transfer");

      write32(`ADDR_DMA_STAT, (1<<2) ); // clear pending IRQ
      
      m_t_end = $time;

      $display("[Info] GN4124 DMA transfer complete, %d bytes took %.0f us",
	       m_last_size, real'(m_t_end - m_t_start) / real'(1us) );
      
      m_dma_pending = 0;
   endtask // on_dma_complete

   function bit is_dma_pending();
      return m_dma_pending;
   endfunction // is_dma_pending

endclass // GennumDMA

// Main SPEC TDC driver. Mostly a copy-paste (+ systemverilog translation) of the
// relevant fmc-tdc driver code.
class FmcTdcSPECDriver extends IBusDevice;
   protected GennumDMA m_gennum_dma;
   protected VICDriver m_vic;
   protected int m_using_dma;


// size of the DDR channel buffer
    protected const uint32_t TDC_CHANNEL_BUFFER_SIZE_BYTES = 'h100000;
    protected const int dma_buf_ddr_burst_size_default = 16;

    fmc_tdc_timestamp_queue_t m_queues[5];

// buffer descriptor, as in the driver   
   typedef struct 
		  {
		     uint32_t addr[2];
		     uint32_t active_buffer;
		     uint32_t size;
		     uint32_t host_mem_addr;
		     int total_timestamps;
		  } tdc_dma_buffer_t;

   protected tdc_dma_buffer_t m_buffers[5];

   // Gennum DMA IRQ handler - just forward to the Gennum driver
   task automatic irq_gennum_dma();
      $display("[Info] Handling GN4124 DMA IRQ");
      m_gennum_dma.irq_dma_complete();
   endtask // irq_gennum_dma

   // TDC Core IRQ handler
   task automatic irq_tdc_core();
      uint32_t isr;
      int i;

      $display("[Info] Handling TDC Buffer IRQ");
      
      read32(`OFFSET_TDC_EIC + `ADDR_TDC_EIC_EIC_ISR, isr);

      // check DMA interrupts, call handler for the buffer(s) for which IRQ(s)
      // is/are pending
      for(int i = 0; i < 5; i++)
	if( isr & ( 1<< (`TDC_EIC_EIC_ISR_TDC_DMA1_OFFSET + i) ) )
	  irq_dma_buffer(i);
   endtask // irq_tdc_core

   // IRQ handler for a single DMA buffer
   task automatic irq_dma_buffer(int channel);
      uint32_t count;
      int transfer_buffer;

      // tell the TDC to start putting samples in the other buffer so that
      // continuous acquisition can be possible
      buffer_switch(channel, transfer_buffer);
      // Once the buffer is switched, read how many samples we ahve in the previous
      // buffer
      buffer_get_count(channel , count );
      
      $display("DMA Buffer IRQ: %d, count %d", channel, count);

      if( m_gennum_dma.is_dma_pending() )
	begin
	   $error("[Error] Trying to trigger DMA transfer while previous transfer is still pending");
	   return;
	end

      // each timestamp is 16 bytes, trigger the gennum DMA xfer	
      m_gennum_dma.dma_to_host( m_buffers[channel].addr[transfer_buffer],
				m_buffers[channel].host_mem_addr, count * 16 );
      
      m_buffers[channel].host_mem_addr += count + 16;
      m_buffers[channel].total_timestamps += count;
   endtask // irq_dma_buffer

   function int get_ts_count(int channel);
      return m_buffers[channel].total_timestamps;
   endfunction // get_ts_count

   function VICDriver get_vic();
      return m_vic;
   endfunction // get_vic
   
   function new(CBusAccessor bus);
      super.new(bus, `BASE_TDC_CORE );

      // create the necessary sub-peripherals (VIC and GN4124)
      m_vic = new (bus, `BASE_VIC );
      m_gennum_dma = new (bus, `BASE_GENNUM_DMA);
      m_using_dma = 0;
   endfunction // new

   task automatic buffer_get_count(int channel, output uint32_t count);
      uint32_t base = `OFFSET_TDC_BUFFER_CONTROLLER + ('h40 * channel);
      read32( base + `ADDR_TDC_BUF_CUR_COUNT, count );
   endtask // buffer_get_count
   
   task automatic buffer_burst_disable(int channel);
      uint32_t tmp;
      uint32_t base = `OFFSET_TDC_BUFFER_CONTROLLER + ('h40 * channel);
      
      read32( base + `ADDR_TDC_BUF_CSR, tmp );
      tmp &= ~`TDC_BUF_CSR_ENABLE;
      write32(base + `ADDR_TDC_BUF_CSR, tmp );
   endtask // buffer_burst_disable
   
   task automatic buffer_burst_enable(int channel);
      uint32_t tmp;
      uint32_t base = `OFFSET_TDC_BUFFER_CONTROLLER + ('h40 * channel);

      read32( base + `ADDR_TDC_BUF_CSR, tmp );
      tmp |= `TDC_BUF_CSR_ENABLE;
      write32( base + `ADDR_TDC_BUF_CSR, tmp );
      
   endtask // buffer_burst_disable
   
   task automatic buffer_burst_size_set(int channel, int size);
      uint32_t tmp;
      uint32_t base = `OFFSET_TDC_BUFFER_CONTROLLER + ('h40 * channel);

      read32( base + `ADDR_TDC_BUF_CSR, tmp );
      tmp &= ~`TDC_BUF_CSR_BURST_SIZE;
      tmp |= size << `TDC_BUF_CSR_BURST_SIZE_OFFSET;
      write32( base + `ADDR_TDC_BUF_CSR, tmp );
   endtask // buffer_burst_size_set
   
   task automatic buffer_irq_timeout_set(int channel, int tmo);
      uint32_t tmp;
      uint32_t base = `OFFSET_TDC_BUFFER_CONTROLLER + ('h40 * channel);

      read32( base + `ADDR_TDC_BUF_CSR, tmp );
      tmp &= ~`TDC_BUF_CSR_IRQ_TIMEOUT;
      tmp |= tmo  << `TDC_BUF_CSR_IRQ_TIMEOUT_OFFSET;
      write32( base + `ADDR_TDC_BUF_CSR, tmp );
   endtask // buffer_burst_size_set
   
   task automatic buffer_switch(int channel, output int transfer_buffer);
      uint32_t csr;
      uint32_t base = `OFFSET_TDC_BUFFER_CONTROLLER + ('h40 * channel);
      uint32_t base_cur;

      read32( base + `ADDR_TDC_BUF_CSR, csr );
      csr |= `TDC_BUF_CSR_SWITCH_BUFFERS;
      write32( base + `ADDR_TDC_BUF_CSR, csr );

      /*
       * It waits until all pending DDR memory transactions from the active
       * buffer are committed to the memory.
       * This is almost instant (e.g. < 1us), but we never know with
       * the PCs going ever faster
       */
      forever begin
	 read32( base + `ADDR_TDC_BUF_CSR, csr );
	 if( csr & `TDC_BUF_CSR_DONE )
	   break;
      end
      
      /* clear CSR.DONE flag (write 1) */
      read32( base + `ADDR_TDC_BUF_CSR, csr );
      csr |= `TDC_BUF_CSR_DONE;
      write32( base + `ADDR_TDC_BUF_CSR, csr );

	/*
	 * we have two buffers in the hardware: the current one and the 'next'
	 * one. From the point of view of this interrupt handler, the current
	 * one is to be read out and switched to the 'next' buffer.,
	 */
      transfer_buffer = m_buffers[channel].active_buffer;
      base_cur = m_buffers[channel].addr [ m_buffers[channel].active_buffer ];

      m_buffers[channel].active_buffer = 1 - m_buffers[channel].active_buffer;

	/* update the pointer to the next buffer */
      write32( base + `ADDR_TDC_BUF_NEXT_BASE, base_cur);
      write32( base + `ADDR_TDC_BUF_NEXT_SIZE, m_buffers[channel].size | `TDC_BUF_NEXT_SIZE_VALID );

      
   endtask // buffer_switch
   
   task automatic configure_buffers();
      int channel;
      uint32_t rv, val;

      for(channel=0;channel<5;channel++)
	begin
	   uint32_t base = `OFFSET_TDC_BUFFER_CONTROLLER + ('h40 * channel);


	   m_buffers[channel].active_buffer = 0;
	   m_buffers[channel].host_mem_addr =  `BASE_HOST_MEM + channel * 'h1000000; // reserve a lot of host memory for each channel
	   m_buffers[channel].total_timestamps = 0;
	   m_buffers[channel].size = TDC_CHANNEL_BUFFER_SIZE_BYTES;
	   
	   buffer_burst_disable(channel);
	   
	/* Buffer 1 */
	   m_buffers[channel].addr[0] = TDC_CHANNEL_BUFFER_SIZE_BYTES * (2 * channel);
	   write32 ( base + `ADDR_TDC_BUF_CUR_BASE, m_buffers[channel].addr[0] );

	   val = (m_buffers[channel].size << `TDC_BUF_CUR_SIZE_SIZE_OFFSET);
	   val |= `TDC_BUF_CUR_SIZE_VALID;
	   
	   write32( base + `ADDR_TDC_BUF_CUR_SIZE, val );

	/* Buffer 2 */
	   m_buffers[channel].addr[1] = TDC_CHANNEL_BUFFER_SIZE_BYTES * (2 * channel + 1);
	   write32 ( base + `ADDR_TDC_BUF_NEXT_BASE, m_buffers[channel].addr[1] );

	   val = (m_buffers[channel].size << `TDC_BUF_NEXT_SIZE_SIZE_OFFSET);
	   val |= `TDC_BUF_NEXT_SIZE_VALID;
	   write32 ( base + `ADDR_TDC_BUF_NEXT_SIZE, val );

	   buffer_burst_size_set(channel, dma_buf_ddr_burst_size_default);
	   buffer_irq_timeout_set(channel, 3);
	   buffer_burst_enable(channel);

	   
	   $display("[Info] Config channel %d: base = %x buf[0] = 0x%08x, buf[1] = 0x%08x, %d timestamps per buffer",
		 channel, base, m_buffers[channel].addr[0],
		    m_buffers[channel].addr[1],
		    m_buffers[channel].size );


	   read32( base + `ADDR_TDC_BUF_CSR, val);
	end // for (channel=0;channel<5;channel++)
      

   endtask // configure_buffers
   
   
   // init
   task automatic init();
      uint32_t d;

      // we need at least these 2 IRQs to test DMA transfers:
      $display("[Info] Init VIC");

      m_vic.init();
      m_vic.enable_irqs( (1<<`VIC_IRQ_GENNUM_DMA) | (1<<`VIC_IRQ_TDC_CORE ) );
      
      $display("[Info] TDC core base addr: %x", m_base);

      read32('h0, d); 
      if( d != 'h5344422d )
	  begin
	    $error("[Error!] Can't read the SDB signature, reading: %x.", d);
	    $stop;
	   end

      if( d == 'h5344422d )
 	  begin
	    $display("[Info] Found the SDB signature: %x", d);
	  end


      // Configure the TDC
      $display("[Info] Setting up TDC core..");
      write32(`ADDR_TDC_CORE_CSR_UTC+`OFFSET_TDC_CORE_CFG, 1234);  // set UTC
      write32(`ADDR_TDC_CORE_CSR_CTRL+`OFFSET_TDC_CORE_CFG, 1<<9); // load UTC
      write32(`ADDR_TDC_CORE_CSR_IRQ_TSTAMP_THRESH+`OFFSET_TDC_CORE_CFG, 2); // FIFO threshold = 2 ts
      write32(`ADDR_TDC_CORE_CSR_IRQ_TIME_THRESH+`OFFSET_TDC_CORE_CFG, 2); // FIFO threshold = 2 ms
      write32('h20bc, ((-1)<<1)); // test?
      
   endtask // init

   task automatic start_acquisition( int use_dma );
      m_using_dma = use_dma;
      if( use_dma )
	begin
	   // allocate memory ranges for DDR acquisition buffers for each channel
	   configure_buffers();
	   // Configure the EIC for an interrupt on DMA buffer
	   write32(`OFFSET_TDC_EIC + `ADDR_TDC_EIC_EIC_IER, 'h1F << 5);
	   $display("[Info] Starting acquisition in DMA mode");
	end else begin
      	   write32(`OFFSET_TDC_EIC + `ADDR_TDC_EIC_EIC_IER, 'h1F); // enable FIFO irq
	   // fixme: FIFO mode not supported
	  
	end
      
      write32(`ADDR_TDC_CORE_CSR_ENABLE+`OFFSET_TDC_CORE_CFG, 'h1f0000); // enable all ACAM inputs
      write32(`ADDR_TDC_CORE_CSR_CTRL+`OFFSET_TDC_CORE_CFG, (1<<0)); // start acquisition
   endtask // start_acquisition
   
   // fixme: likely doesn't work
   task automatic readout_fifo();
      automatic uint32_t csr, t[4];

      for(int i = 0; i < 1; i++) //(int i = 0; i < 5; i++)
	begin
	   automatic uint32_t FIFObase = `OFFSET_TDC_FIFO1 + i * 'h100;
	   automatic fmc_tdc_timestamp_t ts, ts1, ts2;
	   
	   read32(FIFObase + `ADDR_TSF_FIFO_CSR, csr);
           //$display("!!!csr %x: %x", FIFObase + `ADDR_TSF_FIFO_CSR, csr);

	   
	   if( ! (csr & `TSF_FIFO_CSR_EMPTY ) ) begin
              //$display("!!!FIFO not empty!!! csr %x; empty: %x", csr, `TSF_FIFO_CSR_EMPTY);
	      read32(FIFObase + `ADDR_TSF_FIFO_R0, t[0]);
	      read32(FIFObase + `ADDR_TSF_FIFO_R1, t[1]);
	      read32(FIFObase + `ADDR_TSF_FIFO_R2, t[2]);
	      read32(FIFObase + `ADDR_TSF_FIFO_R3, t[3]);

              ts.tai = t[0];
	      ts.coarse = t[1];
	      ts.frac = t[2] & 'hfff;
	      ts.slope = t[3] & 'h8 ? 1: 0;
	      ts.seq = t[3] >> 4;
	      ts.channel = i;
	      
	      m_queues[i].push_back(ts);	
              //$display("!!!Pushed in FIFO!!!");
	   end
	end // for (int i = 0; i < 5; i++)
   endtask // update


   task automatic readout_dma();

   endtask // readout_dma
   
   
  function int poll();
    //$display("[Info] m_queues[0].size: %d", m_queues[0].size());
    return (m_queues[0].size() > 2);
  endfunction // poll

  function fmc_tdc_timestamp_t get();
    return m_queues[0].pop_front();
  endfunction // get


   
endclass // FmcTdcDriver

// Master IRQ dispatcher for the SPEC - TDC
class FmcTdcSPECIrqHandler extends IrqHandler;
   FmcTdcSPECDriver m_driver;
   
   function new ( FmcTdcSPECDriver drv );
      m_driver = drv;
   endfunction

   // this gets called by IrqLine when the gn_gpio(0) is asserted.
   task irq(int id);
      uint32_t irq_id;
      VICDriver vic = m_driver.get_vic();

      // read the pending IRQ ID from the VIC
      vic.get_pending_irq(irq_id);
      $display("[Info] VIC got irq %d", irq_id);

      // dispatch it to the right handler
      case(irq_id)
	`VIC_IRQ_GENNUM_DMA:
	  m_driver.irq_gennum_dma();
	`VIC_IRQ_TDC_CORE:
	  m_driver.irq_tdc_core();
	default:
	  $error("[Error] spurious VIC irq %d", irq_id);
      endcase // case (irq_id)

      // clear IRQ
     vic.clear_pending_irq(irq_id);
   endtask // irq
   
endclass // IrqHandler


// module that observes an interrupt line and if it's asserted
// calls a handler (IrqHandler object) set through set_handler() method.
module IRQLine (
		input irq_i
);

   IrqHandler m_handler;
   
   task set_handler(IrqHandler h);
      m_handler = h;
   endtask // set_handler

   initial forever
     begin
	if(!irq_i)
	  @(posedge irq_i);

	if(irq_i)
	  begin
	     while(irq_i && m_handler)
	       begin
		  m_handler.irq(0);
		  #5us; // give some grace...
	       end
	  end else
	    #100ns;
     end

endmodule // IRQLine



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

   reg         sim_ts_valid = 0;
   wire        sim_ts_ready;
          t_tdc_timestamp sim_ts;
   
   

`ifdef USE_ACAM_MODEL
   
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

`endif // !`ifdef USE_ACAM_MODEL
   

     
   // GN4124 model instantiation  
   IGN4124PCIMaster Host ();
     

   wire [1:0]  gn_gpio;
   

   // TDC core instantiation
   wr_spec_tdc 
     #(
       .g_simulation(1),
       .g_use_fake_timestamps_for_sim(1)
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
	      .fmc0_tdc_stop_dis_o(tdc_stop_dis[1] ),
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
	      .gn_gpio_b                 (gn_gpio),
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
	      .ddr_we_n_o                (ddr_we_n),

	      .sim_timestamp_valid_i(sim_ts_valid),
	      .sim_timestamp_ready_o(sim_ts_ready),
	      .sim_timestamp_i(sim_ts)
	      
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

`ifndef USE_ACAM_MODEL

   // loop that produces fake timestamps. We're not using ACAM here, instead
   // the sim_ts inputs (simulation only) of the SPEC top level are routed directly
   // to the acquisition core. This speeds up the simulation and also allows to check
   // the data integrity of acquisition alone without bothering with all the math associated
   // with conversion of the data coming from the ACAM chip.
   FakeTimestampGenerator fakeTsGen;

   initial 
     begin
	fakeTsGen = new( 0 );

	
	forever begin
	   while(!fakeTsGen.is_enabled())
	     repeat(100) @(posedge DUT.clk_sys_62m5);

	   sim_ts <= fakeTsGen.generate_hw_timestamp(0);
	   sim_ts_valid <= 1;
	   
	   @(posedge DUT.clk_sys_62m5);
	   while(!sim_ts_ready)
	     @(posedge DUT.clk_sys_62m5);
	   sim_ts_valid <= 0;
	   @(posedge DUT.clk_sys_62m5);

	   // wait for some idle time, don't bomb the design with too many timestamps ;-)
	   repeat(100) @(posedge DUT.clk_sys_62m5);

	end
     end // initial begin
   
   
`endif
   

   IRQLine
     irq_line_gennum_master
       (
	.irq_i(gn_gpio[0])
	);
   

   assign tdc_stop_dis[4] = tdc_stop_dis[1];
   assign tdc_stop_dis[3] = tdc_stop_dis[1];
   assign tdc_stop_dis[2] = tdc_stop_dis[1];
   

   // initial 
   initial begin
      CBusAccessor acc;
      FmcTdcSPECDriver drv;
      FmcTdcSPECIrqHandler irq_handler;
      int i;
      
      uint64_t d;
      acc = Host.get_accessor();
      drv = new (acc);
      irq_handler = new(drv);
      	
      $display("Waiting for the DDR3 controller to bootstrap...");
      #4us;
      
      // fixme: poll SPEC reigsters...
      $display("DDR3 calibration complete");

      // connect the Gennum IRQ line to FMC TDC Driver interrupt routing
      irq_line_gennum_master.set_handler( irq_handler );

      // init the board
      drv.init();

      // start acquisition
      drv.start_acquisition( 1 );

      
`ifndef USE_ACAM_MODEL
      fakeTsGen.enable(1); // generate a bunch of fake timestamps
`endif

      // let it run for a while
      #20us;
      

`ifndef USE_ACAM_MODEL
      fakeTsGen.enable(0);
`endif
      #50us; // fixme: check if all dma xfers are done instead of dumb wait
      

      // Read back. The verification of DDR timestamps against the ones in the queue of FakeTimestampGenerator is left to the reader ;-)
      
      $display("[Info] Channel 0 got %d timestamps", drv.get_ts_count(0) );
      $display("HOST MEM DUMP: ");

      for(i=0;i<drv.get_ts_count(0) * 4; i++)
	begin
	   uint64_t rv;
	   
	   Host.host_mem_read(i*8, rv);
	   $display("hostMem[0x%08x]=0x%016x", i*8, rv);
	end
      
/*

      
	
	$display("[Info] Start operation");
      
      fork
	 forever begin
	    drv.readout_fifo();
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
 */
    end
   
endmodule // main




