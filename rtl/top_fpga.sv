 `timescale 1 ns / 1 ps

 module top_fpga (
     input   logic       clk_in1,
     input   logic       btnC,

     inout   logic       PS2Clk,
     inout   logic       PS2Data,
 
     output  logic [1:0] led,
     output  logic [1:0] sw,
     output  logic [6:0] seg,
     output  logic [3:0] an
 );
 
 (* KEEP = "TRUE" *)
 (* ASYNC_REG = "TRUE" *)


 /**
  * Local variables and signals
  */
  logic locked;
  wire rst, clk;
  wire [31:0] counter;
  wire enable;   

  assign rst = btnC;
  assign led[0] = locked; 
  assign led[1] = enable;


  clk_wiz_0 u_clk_wiz_0 (
    .clk_in1(clk_in1),
    .locked (locked),
    .reset  (rst),

    .clk    (clk)
  );


 top_counter u_top_counter (
   .PS2Clk (PS2Clk),
   .PS2Data(PS2Data),
   .clk    (clk),
   .counter(counter),
   .enable (enable),
   .rst    (rst)
 );


 sseg_controller u_sseg_controller (
     .clk    (clk),
     .counter(counter),
     .rst    (rst),
     .sseg   (seg),
     .an     (an)
 );

 
 
 
 endmodule
 