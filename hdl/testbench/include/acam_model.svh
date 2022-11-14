// SPDX-FileCopyrightText: 2022 CERN (home.cern)
//
// SPDX-License-Identifier: CERN-OHL-W-2.0+

`timescale 1ps/1ps

// ACAM TDC GPX model. Almost as crappy as the real thing, but at least doesn't produce the infamous 4ns errors :-) Thanks ACAM for making reliable chips!
//
// Limitations:
// - I-mode only (81 ps bin size)
// - Internal start retrigger only
// - Doesn't support StartOffset or external starts
// - 5 TTL Stop channels only.
// - Not configurable through the registers (settings are fixed, writes are ignored).

module tdc_gpx_model
  (
   input 	PuResN,
   input 	Alutrigger,
   input 	RefClk,

   input 	WRN,
   input 	RDN,
   input 	CSN,
   input 	OEN,

   input [3:0] 	Adr,

   input 	TStart,
   input [8:1] 	TStop,

   input 	StartDis,
   input [4:1] 	StopDis,

   output 	IrFlag,
   output 	ErrFlag,

   output reg 	EF1,
   output reg	EF2,
   
   output 	LF1,
   output 	LF2,

   inout [27:0] D

   /* sim-only */

   );

   parameter time g_imode_resolution  = 81ps;
   parameter int g_verbose 	      = 1;
   parameter time g_ref_clock_period = 32ns;
   parameter int g_ref_clocks_per_retrig = 16;
   parameter int g_queue_size = 16;
   parameter int g_prev_start_threshold = 100;
   
   const real c_empty_flag_delay       = 75ns;

   int 	      retrig_cnt = 0;
   int 	      start_nb_cnt = 0;
   reg 	      internal_start = 0;
   
   always@(posedge RefClk or negedge PuResN)
     if( !PuResN )
       begin
	  retrig_cnt <= 0;
	  internal_start <= 0;
       end else begin
	     if(retrig_cnt == g_ref_clocks_per_retrig-1)
	       begin
		  retrig_cnt <= 0;
		  internal_start <= 1;
	       end else begin
		  retrig_cnt <= retrig_cnt + 1;
		  internal_start <= 0;
	       end
       end // else: !if( !PuResN )

   always@(posedge RefClk or negedge PuResN)
     if( !PuResN )
       begin
	  start_nb_cnt <= 0;
       end else if (internal_start) begin
	  if(start_nb_cnt == 255)
	    start_nb_cnt <= 0;
	  else
	    start_nb_cnt <= start_nb_cnt + 1;
       end
   
   wire r_MasterAluTrig;
   wire r_StartDisStart;
     
   reg[27:0] RB[0:14];
   reg[27:0] DQ = 0;

   reg EF1_int 	= 1'b1;
   reg EF2_int 	= 1'b1;
   reg start_disabled_int;

   int imode_start_offset;
   
   typedef struct {
      int 	       start_nb;
      bit 	       slope;
      int 	       t;
   } acam_hit_t;
   
   typedef acam_hit_t acam_hit_queue_t[$];

   acam_hit_queue_t q_stop[5];

   typedef bit [27:0] acam_data_bus_t;
   typedef acam_data_bus_t acam_fifo_t[$];
   
   
   acam_fifo_t q_fifo[2];
   

   
   const int c_FALLING_EDGE_FLAG = 'h80000000;

   task automatic master_reset;
      int i;

      if(g_verbose) $display("Acam::MasterReset");

      for(i=0;i<5;i++)
	q_stop[i]='{};

      q_fifo[0] ='{};
      q_fifo[1] ='{};
      
      EF1                <= 1;
      EF2 <= 1;
      
      start_disabled_int <= 0;

      for(i=0;i<15;i++)
        RB[i]             = 0;
   endtask // master_reset

   initial master_reset();
   
   
   always@(negedge PuResN) begin
      master_reset();
      end

   int t 		      = 0;
   int t_last_start = 0;
   int t_last_start_d = 0;

   always@(negedge PuResN)
     begin
	t_last_start_d = 0;
	t_last_start = 0;
	t = 0;
     end

   always #(g_imode_resolution) t <= t + 1;
  
   always@(posedge internal_start) 
     if( PuResN ) begin
	t_last_start_d <= t_last_start;
	t_last_start <= t;
     end

   genvar gch;

   generate
      for (gch = 0 ;gch < 5; gch++)
	begin
   
	   always@(posedge TStop[gch+1] or negedge TStop[gch+1]) 
	     if(PuResN && !StopDis[(gch/2)+1]) begin
	     //if(PuResN) begin
		automatic acam_hit_t hit;
		
		if(g_verbose)
		  $display("Acam::stop[%d] %s @ %t ps", gch+1, TStop[gch+1] ? "RISING" : "FALLING", t * g_imode_resolution);

		hit.t = t;
		hit.slope = TStop[gch+1] ? 1 : 0;
		hit.start_nb = start_nb_cnt & 'hff;

		if( t - t_last_start < g_prev_start_threshold )
		  begin
		     hit.start_nb = (start_nb_cnt - 1) & 'hff;
		     hit.t += (g_ref_clock_period * g_ref_clocks_per_retrig ) / g_imode_resolution;
		  end

		q_stop[gch].push_back( hit );
	     end
	end
      endgenerate
   
   
   always@(negedge WRN) if (!CSN && RDN)
     begin
	RB[Adr] <= D;
	if(g_verbose)
	  $display("Acam::write reg %x val %x", Adr, D);
     end
   
   always@(negedge RDN) if (!CSN && WRN)
     begin
	automatic acam_data_bus_t d;
	
	if(g_verbose)
	  $display("Acam::read reg %x val %x", Adr, RB[Adr]);     
	if(Adr == 8) begin
	   if (q_fifo[0].size() )
	     DQ 	    <= q_fifo[0].pop_front();
	   else
	     $error("Acam::attempt to read from an empty IFIFO0");
	   
		    
	end else if(Adr == 9) begin
	   if (q_fifo[1].size() )
	     DQ 	    <= q_fifo[1].pop_front();
	   else
	     $error("Acam::attempt to read from an empty IFIFO1");
	end else
	  
	  DQ <= RB[Adr];
     end
   
   
   always@(negedge PuResN) begin
      int i;
      for (i=0;i<14;i++) RB[i] <= 0;
   end

   assign D  = (!CSN && !RDN)?DQ:28'bz;


   generate
      
      for(gch = 0; gch < 5; gch++)
	begin
          
	   always@(posedge RefClk)
	     begin
		automatic acam_hit_t t_stop;
		automatic bit [27:0] dout;
		

		if(q_stop[gch].size() > 0)
		  begin
		     automatic int fifo_id = gch < 4 ? 0 : 1;
		     
		     t_stop = q_stop[gch].pop_front();

		     if(q_fifo[fifo_id].size() == 0) begin
			#(c_empty_flag_delay);
		     end

		     dout[16:0] = t_stop.t;
		     dout[17] = t_stop.slope;
		     dout[25:18] = t_stop.start_nb;
		     dout[27:26] = gch & 'h3;

		     q_fifo[fifo_id].push_back(dout);
		       
		  end // if (q_stop[gch].num() > 0)
	     end // always@ (posedge RefClk)
	end
   endgenerate
   

   initial forever begin
      #1;
      if(q_fifo[0].size() > 0)
	EF1 = #(12ns) 0;
      else
	EF1 = 1;
   end

   initial forever begin
      #1;
      if(q_fifo[1].size() > 0)
	EF2 = #(12ns) 0;
      else
	EF2 = 1;
   end
   

   
   assign IrFlag = start_nb_cnt & 'h80 ? 1'b1 : 1'b0;
   assign ErrFlag = 0;
   
   
   
   
endmodule // acam_model


