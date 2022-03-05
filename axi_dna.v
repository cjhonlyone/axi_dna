`timescale 1ns / 1ps

`define _FPGADNA0 8'h00
`define _FPGADNA1 8'h01
`define _FPGADNA2 8'h02
`define _FPGADNA3 8'h03

/*
 * AXI4-Lite RAM
 */
module axi_dna #
(
    parameter family = "7Series",
    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 16,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    // Extra pipeline register on output
    parameter PIPELINE_OUTPUT = 0
)
(
    input  wire                      s_axil_clk,
    input  wire                      s_axil_rstn,
    
    input  wire [ADDR_WIDTH-1:0]     s_axil_awaddr ,
    input  wire [2:0]                s_axil_awprot ,
    input  wire                      s_axil_awvalid,
    output wire                      s_axil_awready,
    input  wire [DATA_WIDTH-1:0]     s_axil_wdata  ,
    input  wire [STRB_WIDTH-1:0]     s_axil_wstrb  ,
    input  wire                      s_axil_wvalid ,
    output wire                      s_axil_wready ,
    output wire [1:0]                s_axil_bresp  ,
    output wire                      s_axil_bvalid ,
    input  wire                      s_axil_bready ,
    input  wire [ADDR_WIDTH-1:0]     s_axil_araddr ,
    input  wire [2:0]                s_axil_arprot ,
    input  wire                      s_axil_arvalid,
    output wire                      s_axil_arready,
    output wire [DATA_WIDTH-1:0]     s_axil_rdata  ,
    output wire [1:0]                s_axil_rresp  ,
    output wire                      s_axil_rvalid ,
    input  wire                      s_axil_rready 
);

    wire s_axil_rst = ~ s_axil_rstn;
    
    reg [31:0]                    rFPGADNA0       ;
    reg [31:0]                    rFPGADNA1       ;
    reg [31:0]                    rFPGADNA2       ;
    reg [31:0]                    rFPGADNA3       ;

parameter VALID_ADDR_WIDTH = ADDR_WIDTH - $clog2(STRB_WIDTH);
parameter WORD_WIDTH = STRB_WIDTH;
parameter WORD_SIZE = DATA_WIDTH/WORD_WIDTH;

reg mem_wr_en;
reg mem_rd_en;

reg s_axil_awready_reg = 1'b0, s_axil_awready_next;
reg s_axil_wready_reg = 1'b0, s_axil_wready_next;
reg s_axil_bvalid_reg = 1'b0, s_axil_bvalid_next;
reg s_axil_arready_reg = 1'b0, s_axil_arready_next;
reg [DATA_WIDTH-1:0] s_axil_rdata_reg = {DATA_WIDTH{1'b0}}, s_axil_rdata_next;
reg s_axil_rvalid_reg = 1'b0, s_axil_rvalid_next;
reg [DATA_WIDTH-1:0] s_axil_rdata_pipe_reg = {DATA_WIDTH{1'b0}};
reg s_axil_rvalid_pipe_reg = 1'b0;

// (* RAM_STYLE="BLOCK" *)
// reg [DATA_WIDTH-1:0] mem[(2**VALID_ADDR_WIDTH)-1:0];

wire [VALID_ADDR_WIDTH-1:0] s_axil_awaddr_valid = s_axil_awaddr >> (ADDR_WIDTH - VALID_ADDR_WIDTH);
wire [VALID_ADDR_WIDTH-1:0] s_axil_araddr_valid = s_axil_araddr >> (ADDR_WIDTH - VALID_ADDR_WIDTH);

assign s_axil_awready = s_axil_awready_reg;
assign s_axil_wready = s_axil_wready_reg;
assign s_axil_bresp = 2'b00;
assign s_axil_bvalid = s_axil_bvalid_reg;
assign s_axil_arready = s_axil_arready_reg;
assign s_axil_rdata = PIPELINE_OUTPUT ? s_axil_rdata_pipe_reg : s_axil_rdata_reg;
assign s_axil_rresp = 2'b00;
assign s_axil_rvalid = PIPELINE_OUTPUT ? s_axil_rvalid_pipe_reg : s_axil_rvalid_reg;

// integer i, j;

// initial begin
//     // two nested loops for smaller number of iterations per loop
//     // workaround for synthesizer complaints about large loop counts
//     for (i = 0; i < 2**VALID_ADDR_WIDTH; i = i + 2**(VALID_ADDR_WIDTH/2)) begin
//         for (j = i; j < i + 2**(VALID_ADDR_WIDTH/2); j = j + 1) begin
//             mem[j] = 0;
//         end
//     end
// end

always @* begin
    mem_wr_en = 1'b0;

    s_axil_awready_next = 1'b0;
    s_axil_wready_next = 1'b0;
    s_axil_bvalid_next = s_axil_bvalid_reg && !s_axil_bready;

    if (s_axil_awvalid && s_axil_wvalid && (!s_axil_bvalid || s_axil_bready) && (!s_axil_awready && !s_axil_wready)) begin
        s_axil_awready_next = 1'b1;
        s_axil_wready_next = 1'b1;
        s_axil_bvalid_next = 1'b1;

        mem_wr_en = 1'b1;
    end
end

always @(posedge s_axil_clk) begin
    if (s_axil_rst) begin
        s_axil_awready_reg <= 1'b0;
        s_axil_wready_reg <= 1'b0;
        s_axil_bvalid_reg <= 1'b0;
    end else begin
        s_axil_awready_reg <= s_axil_awready_next;
        s_axil_wready_reg <= s_axil_wready_next;
        s_axil_bvalid_reg <= s_axil_bvalid_next;
    end

    // for (i = 0; i < WORD_WIDTH; i = i + 1) begin
    //     if (mem_wr_en && s_axil_wstrb[i]) begin
    //         mem[s_axil_awaddr_valid][WORD_SIZE*i +: WORD_SIZE] <= s_axil_wdata[WORD_SIZE*i +: WORD_SIZE];
    //     end
    // end
    if (s_axil_rst) begin
    end
    if (mem_wr_en) begin
    end else begin
    end
end

always @* begin
    mem_rd_en = 1'b0;

    s_axil_arready_next = 1'b0;
    s_axil_rvalid_next = s_axil_rvalid_reg && !(s_axil_rready || (PIPELINE_OUTPUT && !s_axil_rvalid_pipe_reg));

    if (s_axil_arvalid && (!s_axil_rvalid || s_axil_rready || (PIPELINE_OUTPUT && !s_axil_rvalid_pipe_reg)) && (!s_axil_arready)) begin
        s_axil_arready_next = 1'b1;
        s_axil_rvalid_next = 1'b1;

        mem_rd_en = 1'b1;
    end
end

always @(posedge s_axil_clk) begin
    if (s_axil_rst) begin
        s_axil_arready_reg <= 1'b0;
        s_axil_rvalid_reg <= 1'b0;
        s_axil_rvalid_pipe_reg <= 1'b0;
    end else begin
        s_axil_arready_reg <= s_axil_arready_next;
        s_axil_rvalid_reg <= s_axil_rvalid_next;

        if (!s_axil_rvalid_pipe_reg || s_axil_rready) begin
            s_axil_rvalid_pipe_reg <= s_axil_rvalid_reg;
        end
    end
    if (mem_rd_en) begin
                 if (s_axil_araddr_valid[7:0] == `_FPGADNA0        ) begin s_axil_rdata_reg <= rFPGADNA0       ;
        end else if (s_axil_araddr_valid[7:0] == `_FPGADNA1        ) begin s_axil_rdata_reg <= rFPGADNA1       ;
        end else if (s_axil_araddr_valid[7:0] == `_FPGADNA2        ) begin s_axil_rdata_reg <= rFPGADNA2       ;
        end else if (s_axil_araddr_valid[7:0] == `_FPGADNA3        ) begin s_axil_rdata_reg <= rFPGADNA3       ;
        end else begin s_axil_rdata_reg   <= 32'd0;
        end
    end

    if (!s_axil_rvalid_pipe_reg || s_axil_rready) begin
        s_axil_rdata_pipe_reg <= s_axil_rdata_reg;
    end
end

    reg [95:0] dna_reg;
    reg [31:0] dna_cnt;
    wire        dna_dout;
    reg        dna_read;
    reg        dna_shift;

generate
    if (family == "7Series") begin
        DNA_PORT #(
          .SIM_DNA_VALUE(57'h010203040506070)  // Specifies a sample 57-bit DNA value for simulation
        )
        DNA_PORT_inst (
          .DOUT(dna_dout),   // 1-bit output: DNA output data.
          .CLK(s_axil_clk),     // 1-bit input: Clock input.
          .DIN(1'b0),     // 1-bit input: User data input pin.
          .READ(dna_read),   // 1-bit input: Active high load DNA, active low read input.
          .SHIFT(dna_shift)  // 1-bit input: Active high shift enable input.
        );

        always @ (posedge s_axil_clk) begin
            if (s_axil_rst) begin
                dna_read <= 1'b0;
                dna_shift <= 1'b0;
                dna_cnt <= 32'd0;
                dna_reg <= 57'h0;
                rFPGADNA0 <= 32'd0;
                rFPGADNA1 <= 32'd0;
                rFPGADNA2 <= 32'd0;
                rFPGADNA3 <= 32'd7;
            end else begin
                if (dna_cnt == (32'd57+2)) begin
                    dna_read<= 1'b0;
                    dna_shift <= 1'b0;
                    dna_cnt <= dna_cnt;
                    dna_reg <= dna_reg;
                    rFPGADNA0 <= dna_reg[31:0];
                    rFPGADNA1 <= dna_reg[63:32];
                    rFPGADNA2 <= dna_reg[95:64];
                    rFPGADNA3 <= 32'd7;
                end else begin
                    dna_read<= (dna_cnt == 32'd0) ? 1'b1 : 1'b0;
                    dna_shift <= 1'b1; 
                    dna_cnt <= dna_cnt + 1'b1;
                    dna_reg <= {dna_reg[55:0], dna_dout};
                    rFPGADNA0 <= 32'd0;
                    rFPGADNA1 <= 32'd0;
                    rFPGADNA2 <= 32'd0;
                    rFPGADNA3 <= 32'd7;
                end
            end
        end

    end else begin
        DNA_PORTE2 #(
          .SIM_DNA_VALUE(96'h000000000010203040506070)  // Specifies a sample 96-bit DNA value for simulation
        )
        DNA_PORTE2_inst (
          .DOUT(dna_dout),   // 1-bit output: DNA output data.
          .CLK(s_axil_clk),     // 1-bit input: Clock input.
          .DIN(1'b0),     // 1-bit input: User data input pin.
          .READ(dna_read),   // 1-bit input: Active high load DNA, active low read input.
          .SHIFT(dna_shift)  // 1-bit input: Active high shift enable input.
        );

        always @ (posedge s_axil_clk) begin
            if (s_axil_rst) begin
                dna_read <= 1'b0;
                dna_shift <= 1'b0;
                dna_cnt <= 32'd0;
                dna_reg <= 57'h0;
                rFPGADNA0 <= 32'd0;
                rFPGADNA1 <= 32'd0;
                rFPGADNA2 <= 32'd0;
                rFPGADNA3 <= 32'd2;
            end else begin
                if (dna_cnt == (32'd97+2)) begin
                    dna_read<= 1'b0;
                    dna_shift <= 1'b0;
                    dna_cnt <= dna_cnt;
                    dna_reg <= dna_reg;
                    rFPGADNA0 <= dna_reg[31:0];
                    rFPGADNA1 <= dna_reg[63:32];
                    rFPGADNA2 <= dna_reg[95:64];
                    rFPGADNA3 <= 32'd2;
                end else begin
                    dna_read<= 1'b1;
                    dna_shift <= 1'b1; 
                    dna_cnt <= dna_cnt + 1'b1;
                    dna_reg <= {dna_reg[94:0], dna_dout};
                    rFPGADNA0 <= 32'd0;
                    rFPGADNA1 <= 32'd0;
                    rFPGADNA2 <= 32'd0;
                    rFPGADNA3 <= 32'd2;
                end
            end
        end
    end

endgenerate

endmodule
