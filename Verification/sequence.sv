class check_func extends uvm_sequence#(transaction);
  `uvm_object_utils(check_func)
  
  transaction tr;
  
  function new(string name="check_func");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(5)
      begin
        `uvm_info("seq","seq started",UVM_LOW);
        tr=transaction::type_id::create("tr");
        tr.valid_transfer.constraint_mode(1);
        start_item(tr);
        assert(tr.randomize);
        finish_item(tr);
        `uvm_info("seq","seq ended",UVM_LOW);
      end
  endtask
endclass
