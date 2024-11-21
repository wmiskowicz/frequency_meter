 `timescale 1 ns / 1 ps

 module top_fpga (
     input   logic       clk_in1,
     input   logic       btnC,
     input   logic       sw0,

     inout   logic       PS2Clk,
     inout   logic       PS2Data,
 
     output  logic [1:0] led,
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
  wire enable;  
  wire mouse_signal, random;
  wire pulse_signal;
  wire [11:0] xpos;

  axi_if axis();

  assign rst = btnC;
  assign led[0] = locked; 
  assign led[1] = enable;

  assign pulse_signal = sw0 ? mouse_signal : random;


  // PLL
  clk_wiz_0 u_clk_wiz_0 (
    .clk_in1(clk_in1),
    .locked (locked),
    .reset  (rst),
    .clk    (clk)
  );

  // Pulse sources
  top_mouse u_top_mouse (
    .clk     (clk),
    .rst     (rst),
    .ps2_clk (PS2Clk),
    .ps2_data(PS2Data),
    .xpos    (xpos),
    .right   (),
    .left    (mouse_signal)   
 );

 random_generator u_random_bit_generator (
   .clk       (clk),
   .rst       (rst),
   .xpos      (xpos),
   .random    (random)
 );

 // AXI master
 top_counter #(
  .CYCLLES_COUNT_MAX(100_000_000)
 )
 u_top_counter (
  .clk    (clk),
  .rst    (rst),
  .enable  (enable),
  .pulse_signal(pulse_signal),
  .axi    (axis)
 );


 // AXI slaves
 sseg_controller #(
  .COMPONENT_ID(8'h7F)
 ) 
 u_sseg_controller (
  .clk    (clk),
  .rst    (rst),
  .sseg   (seg),
  .an     (an),
  .axi    (axis)
 );

 data_mem #(
   .COMPONENT_ID(8'h7A)
 )
 u_data_mem (
   .clk(clk),
   .rst(rst),
   .axi(axis)
 );
 
 endmodule
 