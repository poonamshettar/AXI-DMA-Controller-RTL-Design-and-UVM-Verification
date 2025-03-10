class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver);
  virtual dma_if vif;
  transaction tr;
  
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr=transaction::type_id::create("tr");
    if(!uvm_config_db#(virtual dma_if)::get(this,"","vif",vif))
      `uvm_error("DRIVER","unable to access interface");
  endfunction
  
  task run_phase(uvm_phase phase);
    `uvm_info("driver","driver_started",UVM_LOW)
    forever begin
      seq_item_port.get_next_item(tr);
      vif.src_addr<=tr.src_addr;
      vif.dst_addr<=tr.dst_addr;
      vif.transfer_size<=tr.transfer_size;
      @(posedge vif.clk);
      vif.dma_start<=1;
      @(posedge vif.clk);
      vif.dma_start<=0;
      
      wait(vif.dma_done || vif.dma_error);
      
//       `uvm_info("driver",$sformatf("%d",vif.dma_done),UVM_LOW);
      seq_item_port.item_done();
    end
  endtask
endclass
      
  
    
  