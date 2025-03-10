class test extends uvm_test;
  `uvm_component_utils(test)
  
  function new(input string inst="test",uvm_component c);
    super.new(inst,c);
  endfunction
  
  env e;
  check_func dma;
  
  virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
    e      = env::type_id::create("env",this);
    dma      = check_func::type_id::create("check_func",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    dma.start(e.a.seqr);
    #50;
    phase.drop_objection(this);
  endtask
endclass