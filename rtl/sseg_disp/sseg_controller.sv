module sseg_controller (
    input   logic        clk,     
    input   logic        rst,   
    input   logic [31:0] counter,

    output  logic [6:0]  sseg,
    output  logic [3:0]  an
);

// Internal signals
wire [3:0] bcd3, bcd2, bcd1, bcd0;



// Instances

bin2bcd u_bin2bcd (
    .bcd0(bcd0), 
    .bcd1(bcd1), 
    .bcd2(bcd2), 
    .bcd3(bcd3), 
    .bin (counter) 
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