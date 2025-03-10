interface dma_if();
  logic dma_start;
  logic dma_done;
  logic dma_error;
  logic [31:0] src_addr;
  logic [31:0] dst_addr;
  logic [31:0] transfer_size;
  logic clk;
  logic rst_n;
endinterface : dma_if