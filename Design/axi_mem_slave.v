module axi_memory_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64,
    parameter MEM_DEPTH  = 1024
)(
    input  wire                      clk,
    input  wire                      rst_n,

    // AXI Write Address Channel
    input  wire                      s_axi_awvalid,
    output reg                       s_axi_awready,
    input  wire [ADDR_WIDTH-1:0]     s_axi_awaddr,

    // AXI Write Data Channel
    input  wire                      s_axi_wvalid,
    output reg                       s_axi_wready,
    input  wire [DATA_WIDTH-1:0]     s_axi_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  wire                      s_axi_wlast,

    // AXI Write Response Channel
    output reg                       s_axi_bvalid,
    input  wire                      s_axi_bready,
    output reg [1:0]                 s_axi_bresp,

    // AXI Read Address Channel
    input  wire                      s_axi_arvalid,
    output reg                       s_axi_arready,
    input  wire [ADDR_WIDTH-1:0]     s_axi_araddr,

    // AXI Read Data Channel
    output reg                       s_axi_rvalid,
    input  wire                      s_axi_rready,
    output reg [DATA_WIDTH-1:0]      s_axi_rdata,
    output reg [1:0]                 s_axi_rresp,
    output reg                       s_axi_rlast
);

    // Local variables
    localparam STRB_WIDTH = DATA_WIDTH / 8;

    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    // Word-aligned address calculation (Assumes alignment to DATA_WIDTH)
    wire [ADDR_WIDTH-1:0] wr_word_addr;
    wire [ADDR_WIDTH-1:0] rd_word_addr;

    // assign wr_word_addr = s_axi_awaddr[ADDR_WIDTH-1:3];
    // assign rd_word_addr = s_axi_araddr[ADDR_WIDTH-1:3];
    assign wr_word_addr = s_axi_awaddr;
    assign rd_word_addr = s_axi_araddr;
    integer i;
    initial begin
        
        for(i = 0 ;i< MEM_DEPTH-1;i = i+1) begin
            mem[i] <= i;
        end
    end
    //=======================
    // Write Channel Handling
    //=======================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_awready <= 0;
            s_axi_wready  <= 0;
            s_axi_bvalid  <= 0;
            s_axi_bresp   <= 2'b00;
        end else begin
            if (!s_axi_awready && s_axi_awvalid)
                s_axi_awready <= 1;
            else
                s_axi_awready <= 0;

            if (!s_axi_wready && s_axi_wvalid)
                s_axi_wready <= 1;
            else
                s_axi_wready <= 0;

            // if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
            if (s_axi_wvalid && s_axi_wready) begin
                if (STRB_WIDTH >= 1 && s_axi_wstrb[0]) mem[wr_word_addr][7:0]   <= s_axi_wdata[7:0];
                if (STRB_WIDTH >= 2 && s_axi_wstrb[1]) mem[wr_word_addr][15:8]  <= s_axi_wdata[15:8];
                if (STRB_WIDTH >= 3 && s_axi_wstrb[2]) mem[wr_word_addr][23:16] <= s_axi_wdata[23:16];
                if (STRB_WIDTH >= 4 && s_axi_wstrb[3]) mem[wr_word_addr][31:24] <= s_axi_wdata[31:24];
                if (STRB_WIDTH >= 5 && s_axi_wstrb[4]) mem[wr_word_addr][39:32] <= s_axi_wdata[39:32];
                if (STRB_WIDTH >= 6 && s_axi_wstrb[5]) mem[wr_word_addr][47:40] <= s_axi_wdata[47:40];
                if (STRB_WIDTH >= 7 && s_axi_wstrb[6]) mem[wr_word_addr][55:48] <= s_axi_wdata[55:48];
                if (STRB_WIDTH >= 8 && s_axi_wstrb[7]) mem[wr_word_addr][63:56] <= s_axi_wdata[63:56];

                s_axi_bvalid <= 1;
                s_axi_bresp  <= 2'b00; // OKAY
            end

            if (s_axi_bvalid && s_axi_bready)
                s_axi_bvalid <= 0;
        end
    end

    //=======================
    // Read Channel Handling
    //=======================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_axi_arready <= 0;
            s_axi_rvalid  <= 0;
            s_axi_rdata   <= 0;
            s_axi_rresp   <= 2'b00;
            s_axi_rlast   <= 0;
        end else begin
            if (!s_axi_arready && s_axi_arvalid)
                s_axi_arready <= 1;
            else
                s_axi_arready <= 0;

            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rvalid <= 1;
                s_axi_rdata  <= mem[rd_word_addr];
                s_axi_rresp  <= 2'b00;
                s_axi_rlast  <= 1;
            end

            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 0;
                s_axi_rlast  <= 0;
            end
        end
    end

endmodule
