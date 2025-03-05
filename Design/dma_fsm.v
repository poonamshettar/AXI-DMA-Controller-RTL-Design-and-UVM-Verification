module dma_axi_fsm #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64,
    parameter BURST_LEN  = 16
)(
    input  wire                 clk,
    input  wire                 rst_n,

    // Control interface
    input  wire                 dma_start,
    input  wire [ADDR_WIDTH-1:0] src_addr,
    input  wire [ADDR_WIDTH-1:0] dst_addr,
    input  wire [31:0]          transfer_size, 

    // AXI Write Interface
    output reg                  m_axi_awvalid,
    input  wire                 m_axi_awready,
    output reg  [ADDR_WIDTH-1:0] m_axi_awaddr,

    output reg                  m_axi_wvalid,
    input  wire                 m_axi_wready,
    output reg  [DATA_WIDTH-1:0] m_axi_wdata,
    output reg  [(DATA_WIDTH/8)-1:0] m_axi_wstrb,
    output reg                  m_axi_wlast,

    input  wire                 m_axi_bvalid,
    input  wire [1:0]           m_axi_bresp,
    output reg                  m_axi_bready,

    // AXI Read Interface
    output reg                  m_axi_arvalid,
    input  wire                 m_axi_arready,
    output reg  [ADDR_WIDTH-1:0] m_axi_araddr,

    input  wire                 m_axi_rvalid,
    output reg                  m_axi_rready,
    input  wire [DATA_WIDTH-1:0] m_axi_rdata,
    input  wire                 m_axi_rlast,

    // Status
    output reg                  dma_done,
    output reg                  dma_error
);

    // FSM States
    localparam  IDLE           = 3'd0,
                ARBITRATE      = 3'd1,
                READ_SETUP     = 3'd2,
                READ_TRANSFER  = 3'd3,
                WRITE_SETUP    = 3'd4,
                WRITE_TRANSFER = 3'd5,
                COMPLETE       = 3'd6;

    reg [2:0] state, next_state;

    // Internal registers
    reg [31:0] bytes_remaining;
    reg [ADDR_WIDTH-1:0] current_src;
    reg [ADDR_WIDTH-1:0] current_dst;

    // FSM Sequential Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // FSM Combinational Logic
    always @(*) begin
        // Default assignments
        next_state = state;

        dma_done   = 0;
        dma_error  = 0;

        m_axi_awvalid = 0;
        m_axi_awaddr  = current_dst;

        m_axi_wvalid  = 0;
        m_axi_wdata   = m_axi_rdata;  // simple passthrough
        m_axi_wstrb   = {(DATA_WIDTH/8){1'b1}};
        m_axi_wlast   = 0;

        m_axi_bready  = 1;

        m_axi_arvalid = 0;
        m_axi_araddr  = current_src;

        m_axi_rready  = 1;

        case (state)
            IDLE: begin
                if (dma_start)
                    next_state = ARBITRATE;
            end

            ARBITRATE: begin
                next_state = READ_SETUP;
            end

            READ_SETUP: begin
                m_axi_arvalid = 1;
                if (m_axi_arready)
                    next_state = READ_TRANSFER;
            end

            READ_TRANSFER: begin
                if (m_axi_rvalid) begin
                    // Data is available to write
                    next_state = WRITE_SETUP;
                end
            end

            WRITE_SETUP: begin
                m_axi_awvalid = 1;
                if (m_axi_awready)
                    next_state = WRITE_TRANSFER;
            end

            WRITE_TRANSFER: begin
                m_axi_wvalid = 1;
                m_axi_wlast  = (bytes_remaining <= (DATA_WIDTH/8));
                if (m_axi_wready) begin
                    if (bytes_remaining <= (DATA_WIDTH/8))
                        next_state = COMPLETE;
                    else
                        next_state = READ_SETUP;
                end
            end

            COMPLETE: begin
                dma_done = 1;
                if (!dma_start)
                    next_state = IDLE;
            end

            default: begin
                dma_error = 1;
                next_state = IDLE;
            end
        endcase
    end

    // Address and Byte Tracking Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bytes_remaining <= 0;
            current_src     <= 0;
            current_dst     <= 0;
        end else if (state == IDLE && dma_start) begin
            bytes_remaining <= transfer_size;
            current_src     <= src_addr;
            current_dst     <= dst_addr;
        end else if (state == WRITE_TRANSFER && m_axi_wready) begin
            bytes_remaining <= bytes_remaining - (DATA_WIDTH / 8);
            current_src     <= current_src + 1;
            current_dst     <= current_dst + 1;
        end
    end

endmodule
