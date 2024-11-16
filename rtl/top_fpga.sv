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
  wire [15:0] counter;
  wire enable;  
  wire pulse_signal;

  axi_if axis();

  assign rst = btnC;
  assign led[0] = locked; 
  assign led[1] = enable;


  // PLL
  clk_wiz_0 u_clk_wiz_0 (
    .clk_in1(clk_in1),
    .locked (locked),
    .reset  (rst),

    .clk    (clk)
  );

  // Pulse source
  top_mouse u_top_mouse (
    .clk     (clk),
    .rst     (rst),
    .ps2_clk (PS2Clk),
    .ps2_data(PS2Data),
    .right   (),
    .left    (pulse_signal)   
 );

 // AXI master
 top_counter u_top_counter (
  .clk    (clk),
  .rst    (rst),
  .enable (enable),
  .pulse_signal(pulse_signal),
  .axi    (axis)
 );


 // AXI slave
 sseg_controller #(
  .COMPONENT_ID(8'h7F)
 ) u_sseg_controller (
  .clk    (clk),
  .rst    (rst),
  .sseg   (seg),
  .an     (an),
  .axi    (axis)
 );

 
 
 
 endmodule
 