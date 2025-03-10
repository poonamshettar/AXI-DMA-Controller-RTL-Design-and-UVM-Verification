class monitor extends uvm_monitor;
  virtual dma_if vif;
  uvm_analysis_port#(transaction) send;
  transaction tr;
  `uvm_component_utils(monitor)
  
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr=transaction::type_id::create("tr");
    send=new("send",this);
    if(!uvm_config_db#(virtual dma_if)::get(this,"","vif",vif))
      `uvm_error("MONITOR","unable to access interface");
  endfunction
    
  
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      if(vif.dma_done) begin
        tr.src_addr=vif.src_addr;
        tr.dst_addr=vif.dst_addr;
        tr.transfer_size=vif.transfer_size;
        tr.dma_done=vif.dma_done;
//         tr.dma_start=1;
        send.write(tr);
      end
    end
  endtask
endclass