module top_counter (
  input   logic        clk,
  input   logic        rst,
  
  inout  PS2Clk,
  inout  PS2Data,
  // input logic left,

  output  logic [31:0] counter,
  output  logic        enable
);


  wire left;
  wire inc;

  enable_toggle #(
    .COUNT_MAX(100_000_000)
  )
  u_enable_toggle (
    .clk   (clk),
    .enable(enable),
    .rst   (rst)
  );



 top_mouse u_top_mouse (
    .clk     (clk),
    .rst     (rst),
    .ps2_clk (PS2Clk),
    .ps2_data(PS2Data),
    .right   (),
    .left    (left)   
 );

 posedge_detector u_posedge_detector (
    .clk(clk),
    .out(inc),
    .rst(rst),
    .sig(left)
 );



 counter u_counter (
    .clk    (clk),
    .rst    (rst),
    .enable (enable),
    .inc    (inc),
    .counter(counter)
 );

endmodule
