`include "axi_mem_slave.v"
`include "dma_fsm.v"
module dma_axi_top #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64,
    parameter MEM_DEPTH  = 1024
)(
    input  wire                   clk,
    input  wire                   rst_n,

    // Control Interface
    input  wire                   dma_start,
    input  wire [ADDR_WIDTH-1:0]  src_addr,
    input  wire [ADDR_WIDTH-1:0]  dst_addr,
    input  wire [31:0]            transfer_size,
    output wire                   dma_done,
    output wire                   dma_error
);

    // AXI Interconnect Signals
    wire                        awvalid, awready;
    wire [ADDR_WIDTH-1:0]       awaddr;

    wire                        wvalid, wready;
    wire [DATA_WIDTH-1:0]       wdata;
    wire [(DATA_WIDTH/8)-1:0]   wstrb;
    wire                        wlast;

    wire                        bvalid, bready;
    wire [1:0]                  bresp;

    wire                        arvalid, arready;
    wire [ADDR_WIDTH-1:0]       araddr;

    wire                        rvalid, rready;
    wire [DATA_WIDTH-1:0]       rdata;
    wire                        rlast;

    // Instantiate DMA Controller
    dma_axi_fsm #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dma_inst (
        .clk(clk),
        .rst_n(rst_n),

        .dma_start(dma_start),
        .src_addr(src_addr),
        .dst_addr(dst_addr),
        .transfer_size(transfer_size),
        .dma_done(dma_done),
        .dma_error(dma_error),

        .m_axi_awvalid(awvalid),
        .m_axi_awready(awready),
        .m_axi_awaddr(awaddr),

        .m_axi_wvalid(wvalid),
        .m_axi_wready(wready),
        .m_axi_wdata(wdata),
        .m_axi_wstrb(wstrb),
        .m_axi_wlast(wlast),

        .m_axi_bvalid(bvalid),
        .m_axi_bresp(bresp),
        .m_axi_bready(bready),

        .m_axi_arvalid(arvalid),
        .m_axi_arready(arready),
        .m_axi_araddr(araddr),

        .m_axi_rvalid(rvalid),
        .m_axi_rready(rready),
        .m_axi_rdata(rdata),
        .m_axi_rlast(rlast)
    );

    // Instantiate AXI Memory Slave
    axi_memory_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH(MEM_DEPTH)
    ) mem_inst (
        .clk(clk),
        .rst_n(rst_n),

        .s_axi_awvalid(awvalid),
        .s_axi_awready(awready),
        .s_axi_awaddr(awaddr),

        .s_axi_wvalid(wvalid),
        .s_axi_wready(wready),
        .s_axi_wdata(wdata),
        .s_axi_wstrb(wstrb),
        .s_axi_wlast(wlast),

        .s_axi_bvalid(bvalid),
        .s_axi_bready(bready),
        .s_axi_bresp(bresp),

        .s_axi_arvalid(arvalid),
        .s_axi_arready(arready),
        .s_axi_araddr(araddr),

        .s_axi_rvalid(rvalid),
        .s_axi_rready(rready),
        .s_axi_rdata(rdata),
        .s_axi_rresp(),     // not connected for simplicity
        .s_axi_rlast(rlast)
    );

endmodule
