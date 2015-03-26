`include "wrn_cpu_csr_regs.vh"

typedef class NodeCPUDbgQueue;
   

class NodeCPUControl;
   protected CBusAccessor bus;
   protected uint32_t base;

   protected uint32_t core_count ,app_id;

//   NodeCPUDbgQueue dbgq [$];
   NodeCPUDbgQueue dbgq [$];
   
   function new ( CBusAccessor bus_, input uint32_t base_);
      base = base_;
      bus = bus_;
   endfunction // new

   task writel ( uint32_t r, uint32_t v );
      bus.write ( base + r, v );
   endtask // _write

   task readl (  uint32_t r, ref uint32_t v );
      uint64_t tmp;
      bus.read (base + r, tmp );
      v= tmp;
   endtask // readl
   
   task init();
      int i;
      
      
      readl(`ADDR_WRN_CPU_CSR_APP_ID, app_id);
      readl(`ADDR_WRN_CPU_CSR_CORE_COUNT, core_count);

      core_count&='hf;

      for(i=0;i<core_count;i++)
	begin
	   NodeCPUDbgQueue q = new ( this, i );
	   
	   dbgq.push_back (q);
	end
      
      $display("App ID: %x", app_id);
      $display("Core count: %d", core_count);
      for(i=0;i<core_count;i++)
      begin
         uint32_t memsize;
         writel(`ADDR_WRN_CPU_CSR_CORE_SEL, i);
         readl(`ADDR_WRN_CPU_CSR_CORE_MEMSIZE, memsize);
         $display("Core %d: %d kB private memory", i, memsize/1024);
 
      end
      
      
      
      
   endtask // init

   task reset_core(int core, int reset);
      uint32_t rstr;
      readl(`ADDR_WRN_CPU_CSR_RESET, rstr);

      if(reset)
        rstr |= (1<<core);
      else
        rstr &= ~(1<<core);
      writel(`ADDR_WRN_CPU_CSR_RESET, rstr);
   endtask // enable_cpu


   task debug_int_enable(int core, int enable);
      uint32_t imsk;

      readl(`ADDR_WRN_CPU_CSR_DBG_IMSK, imsk);
      if(enable)
	imsk |= (1<<core);
      else
	imsk &= ~(1<<core);
      writel(`ADDR_WRN_CPU_CSR_DBG_IMSK, imsk);
   endtask // debug_int_enable


   
   task load_firmware(int core, string filename);
      integer f = $fopen(filename,"r");
      uint32_t q[$];
      int     n, i;
      
      reset_core(core, 1);

      writel(`ADDR_WRN_CPU_CSR_CORE_SEL, core);

      
      
      while(!$feof(f))
        begin
           int addr, data;
           string cmd;
           
           $fscanf(f,"%s %08x %08x", cmd,addr,data);
           if(cmd == "write")
             begin
                writel(`ADDR_WRN_CPU_CSR_UADDR, addr);
                writel(`ADDR_WRN_CPU_CSR_UDATA, data);
		q.push_back(data);
		n++;
		
             end
        end

      for(i=0;i<n;i++)
	begin
	   uint32_t rv;
           writel(`ADDR_WRN_CPU_CSR_UADDR, i);
           readl(`ADDR_WRN_CPU_CSR_UDATA, rv);
	   $display("readback: addr %x d %x", i, rv);
	   if(rv != q[i])
	     $display("verification error\n");
	   
	end
      
      
   endtask
        
      
 
   task update();
      int i;

      for(i=0;i<core_count;i++)
	dbgq[i].update();

   endtask // update
   
   
   
endclass 


class NodeCPUDbgQueue;
   protected NodeCPUControl cctl;
   protected int core_id;

   int 		 queue[$];
   
   function new ( NodeCPUControl cctl_, int core_id_);
      cctl = cctl_;
      core_id = core_id_;
   endfunction // new
   

   task update();
      uint32_t rval;
      
      forever begin
		 cctl.readl(`ADDR_WRN_CPU_CSR_DBG_POLL , rval);
	 if(! (rval & (1<<core_id)))
	   break;
	 cctl.writel(`ADDR_WRN_CPU_CSR_CORE_SEL, core_id);
	 cctl.readl(`ADDR_WRN_CPU_CSR_DBG_MSG, rval);
	 queue.push_back(rval);
	 $display("dbg rx '%c'", rval);
      end
	   
   endtask // update
   

   
   
endclass // NodeCPUDbgQueue
