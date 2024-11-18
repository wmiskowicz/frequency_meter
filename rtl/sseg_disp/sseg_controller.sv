module sseg_controller #(
    parameter COMPONENT_ID = 8'hFF
)(
    input   logic        clk,     
    input   logic        rst,

    output  logic [6:0]  sseg,
    output  logic [3:0]  an,

    axi_if.slave axi
);

// Internal signals
wire [3:0]  bcd3, bcd2, bcd1, bcd0;
wire [31:0] data;


// Instances

axi_stream_slave #(
  .FRAME_SIZE(4),
  .ID_VALID(COMPONENT_ID)
)
u_axi_stream_slave (
  .clk  (clk),
  .rst_n(!rst),
  .rx_data(data),
  .axi  (axi)
);


bin2bcd u_bin2bcd (
    .bcd0(bcd0), 
    .bcd1(bcd1), 
    .bcd2(bcd2), 
    .bcd3(bcd3), 
    .bin (data) 
);



disp_hex_mux u_disp_hex_mux (
    .an   (an),
    .clk  (clk),
    .hex0 (bcd0),
    .hex1 (bcd1),
    .hex2 (bcd2),
    .hex3 (bcd3),
    .reset(rst),
    .sseg (sseg) 
);
    
endmodule