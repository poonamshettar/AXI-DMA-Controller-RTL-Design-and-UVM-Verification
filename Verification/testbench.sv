`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "transaction.sv"
`include "sequence.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "env.sv"
`include "test.sv"
`include "interface.sv"


module dma_tb_top;

  // Declare and instantiate the interface
  dma_if vif();

  // Clock generation
  initial begin
    vif.clk = 0;
    forever #10 vif.clk = ~vif.clk; // 100MHz clock
  end

  // Reset logic
  initial begin
    
     vif.rst_n=0;
    #20 vif.rst_n = 1;
  end

  // DUT instantiation and interface connection
  dma_axi_top #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(64),
    .MEM_DEPTH(1024)
  ) dut (
    .clk(vif.clk),
    .rst_n(vif.rst_n),
    .dma_start(vif.dma_start),
    .dma_done(vif.dma_done),
    .dma_error(vif.dma_error),
    .src_addr(vif.src_addr),
    .dst_addr(vif.dst_addr),
    .transfer_size(vif.transfer_size)
  );

  // Run the UVM test
  initial begin
    uvm_config_db#(virtual dma_if)::set(null,"*","vif",vif);
    run_test("test");
  end

endmodule