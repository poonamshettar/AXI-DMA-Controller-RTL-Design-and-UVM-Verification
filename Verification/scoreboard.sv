class scoreboard extends uvm_component;
  uvm_analysis_imp#(transaction,scoreboard) recv;
  transaction tr;
  `uvm_component_utils(scoreboard)
  
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv=new("recv",this);
  endfunction
  
  virtual function void write(transaction tr);
    if(tr.dma_done==1)
      begin
        `uvm_info("SCOREBOARD", $sformatf("Transfer complete: src=0x%0h dst=0x%0h size=%0d",
                                       tr.src_addr, tr.dst_addr, tr.transfer_size), UVM_LOW)
      end
  endfunction
endclass

  
  
    
    