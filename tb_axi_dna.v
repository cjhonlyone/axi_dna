`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/04 23:47:41
// Design Name: 
// Module Name: tb_axi_dna
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_axi_dna;

    /*
    * AXI-lite slave interface
    */
    parameter AXIL_ADDR_WIDTH           = 32              ;
    parameter AXIL_DATA_WIDTH           = 32              ;
    parameter AXIL_STRB_WIDTH           = AXIL_DATA_WIDTH/8    ;

    reg                           s_axil_clk              ;
    reg                           s_axil_rst              ;

    initial                 
    begin
        s_axil_clk          <= 1'b0;
        #10000;
        forever
        begin    
            s_axil_clk      <= 1'b1;
            #5000;
            s_axil_clk      <= 1'b0;
            #5000;
        end
    end

    initial begin
        s_axil_rst <= 1'b1;
        repeat(100) begin
            @(posedge s_axil_clk)
                s_axil_rst <= 1'b1;
        end
        s_axil_rst <= 1'b0;
    end

    wire [AXIL_ADDR_WIDTH-1:0] s_axil_awaddr                             ;
    wire [2:0]                 s_axil_awprot                             ;
    wire                       s_axil_awvalid                            ;
    wire [AXIL_DATA_WIDTH-1:0] s_axil_wdata                              ;
    wire [AXIL_STRB_WIDTH-1:0] s_axil_wstrb                              ;
    wire                       s_axil_wvalid                             ;
    wire                       s_axil_bready                             ;
    wire [AXIL_ADDR_WIDTH-1:0] s_axil_araddr                             ;
    wire [2:0]                 s_axil_arprot                             ;
    wire                       s_axil_arvalid                            ;
    wire                       s_axil_rready                             ;

    wire                       s_axil_awready                            ;
    wire                       s_axil_wready                             ;
    wire [1:0]                 s_axil_bresp                              ;
    wire                       s_axil_bvalid                             ;
    wire                       s_axil_arready                            ;
    wire [AXIL_DATA_WIDTH-1:0] s_axil_rdata                              ;
    wire [1:0]                 s_axil_rresp                              ;
    wire                       s_axil_rvalid                             ;


    wire            s_axi_aclk = s_axil_clk;
    wire            s_axi_aresetn = ~s_axil_rst;

    reg             s_axi_cfg_wvalid;
    reg      [31:0] s_axi_cfg_waddr ;
    reg      [31:0] s_axi_cfg_wdata ;
    wire            s_axi_cfg_wready;

    reg             s_axi_cfg_rvalid;
    reg      [31:0] s_axi_cfg_raddr ;
    wire     [31:0] s_axi_cfg_rdata ;
    wire            s_axi_cfg_rdv   ;
    wire            s_axi_cfg_rready;
    
    axil_write inst_axil_write
    (
        .s_axi_aclk       (s_axi_aclk),
        .s_axi_aresetn    (s_axi_aresetn),
        .s_axi_awready    (s_axil_awready),
        .s_axi_wready     (s_axil_wready),
        .s_axi_bvalid     (s_axil_bvalid),
        .s_axi_bresp      (s_axil_bresp),
        .s_axi_awaddr     (s_axil_awaddr),
        .s_axi_awvalid    (s_axil_awvalid),
        .s_axi_wdata      (s_axil_wdata),
        .s_axi_wvalid     (s_axil_wvalid),
        .s_axi_bready     (s_axil_bready),

        .s_axi_cfg_wvalid (s_axi_cfg_wvalid),
        .s_axi_cfg_waddr  (s_axi_cfg_waddr),
        .s_axi_cfg_wdata  (s_axi_cfg_wdata),
        .s_axi_cfg_wready (s_axi_cfg_wready)
    );

    axil_read inst_axil_read
    (
        .s_axi_aclk       (s_axi_aclk),
        .s_axi_aresetn    (s_axi_aresetn),
        .s_axi_arready    (s_axil_arready),
        .s_axi_rvalid     (s_axil_rvalid),
        .s_axi_rdata      (s_axil_rdata),
        .s_axi_rresp      (s_axil_rresp),
        .s_axi_araddr     (s_axil_araddr),
        .s_axi_arvalid    (s_axil_arvalid),
        .s_axi_rready     (s_axil_rready),

        .s_axi_cfg_rvalid (s_axi_cfg_rvalid),
        .s_axi_cfg_raddr  (s_axi_cfg_raddr),
        .s_axi_cfg_rdata  (s_axi_cfg_rdata),
        .s_axi_cfg_rdv    (s_axi_cfg_rdv),
        .s_axi_cfg_rready (s_axi_cfg_rready)
    );


  // AXI-Lite Write task
  task axi_write;
    input [29:0] offset;
    input [31:0] data;
    reg   [31:0] addr;
    reg    [1:0] resp;
    begin
        while (s_axi_cfg_wready == 1'b0)
            @(posedge s_axi_aclk);
        s_axi_cfg_wvalid <= 1'b1;
        s_axi_cfg_waddr <= {offset, 2'b00};
        s_axi_cfg_wdata <= data;
        @(posedge s_axi_aclk);
        s_axi_cfg_wvalid <= 1'b0;
        while (s_axi_cfg_wready == 1'b0)
            @(posedge s_axi_aclk);
        @(posedge s_axi_aclk);
    end
  endtask // axi_write
  
  // AXI-Lite Read task
  task axi_read;
    input  [29:0] offset;
    output [31:0] data;
    reg    [31:0] addr;
    reg     [1:0] resp;
    begin
        while (s_axi_cfg_rready == 1'b0)
        @(posedge s_axi_aclk);
        s_axi_cfg_rvalid <= 1'b1;
        s_axi_cfg_raddr <= {offset, 2'b00};
        @(posedge s_axi_aclk);
        s_axi_cfg_rvalid <= 1'b0;
        while (s_axi_cfg_rdv == 1'b0) begin
//            data <= s_axi_cfg_rdata;
            @(posedge s_axi_aclk);
        end
        data = s_axi_cfg_rdata;
        @(posedge s_axi_aclk);
    end
  endtask // axi_read


	axi_dna #(
			.family("7Series"),
			.DATA_WIDTH(AXIL_DATA_WIDTH),
			.ADDR_WIDTH(AXIL_ADDR_WIDTH),
			.STRB_WIDTH(AXIL_STRB_WIDTH)
		) inst_axi_dna (
			.clk            (s_axi_aclk),
			.rst            (s_axil_rst),
			.s_axil_awaddr  (s_axil_awaddr),
			.s_axil_awprot  (s_axil_awprot),
			.s_axil_awvalid (s_axil_awvalid),
			.s_axil_awready (s_axil_awready),
			.s_axil_wdata   (s_axil_wdata),
			.s_axil_wstrb   (s_axil_wstrb),
			.s_axil_wvalid  (s_axil_wvalid),
			.s_axil_wready  (s_axil_wready),
			.s_axil_bresp   (s_axil_bresp),
			.s_axil_bvalid  (s_axil_bvalid),
			.s_axil_bready  (s_axil_bready),
			.s_axil_araddr  (s_axil_araddr),
			.s_axil_arprot  (s_axil_arprot),
			.s_axil_arvalid (s_axil_arvalid),
			.s_axil_arready (s_axil_arready),
			.s_axil_rdata   (s_axil_rdata),
			.s_axil_rresp   (s_axil_rresp),
			.s_axil_rvalid  (s_axil_rvalid),
			.s_axil_rready  (s_axil_rready)
		);
reg [31:0] axi_read_data;
initial begin
s_axi_cfg_wvalid <= 1'b0;
s_axi_cfg_waddr <= 32'd0;
s_axi_cfg_wdata <= 32'd0;

s_axi_cfg_rvalid <= 1'b0;
s_axi_cfg_raddr  <= 32'd0;

repeat(200) begin
    @(posedge s_axil_clk);
end
axi_read({32'd0  }, axi_read_data);
axi_read({32'd1  }, axi_read_data);

end
endmodule
