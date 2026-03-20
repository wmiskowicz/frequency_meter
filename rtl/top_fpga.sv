 `timescale 1 ns / 1 ps

module top_fpga#(
  parameter COUNT_CYCLES = 100_000_000
) (
  input   logic       clk_in1,
  input   logic       btnC,
  input   logic       sw0,
  input   wire        RsRx,

  inout   logic       PS2Clk,
  inout   logic       PS2Data,

  output  logic       RsTx,
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
wire enable_counting;

axi_if axis();

assign rst = btnC;
assign led[0] = locked;
assign led[1] = enable_counting;



// PLL
clk_wiz_0 u_clk_wiz_0 (
  .clk_in1(clk_in1),
  .locked (locked),
  .reset  (1'b0),
  .clk    (clk)
);

// main_fsm u_main_fsm (
//   .clk  (clk),
//   .rst  (rst),
//   .RsRx (RsRx),
//   .RsTx (RsTx),
//   .state()
// );



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


pulse_counter_top #(
  .COUNT_CYCLES(COUNT_CYCLES)
)
u_pulse_counter_top (
  .clk          (clk),
  .rst          (rst),
  .source_select(sw0),
  .enable_counting(enable_counting),

  .PS2Clk       (PS2Clk),
  .PS2Data      (PS2Data),
  .axi          (axis)
);

endmodule
