 `timescale 1 ns / 1 ps

module top_fpga#(
  parameter COUNT_CYCLES = 100_000_000,
  parameter BAUD_RATE = 9600
) (
  input   logic       clk_in1,
  input   logic       btnC,
  input   logic       btnU,
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

import component_id_pkg::*;

// ---- Local parameters ----
localparam CLK_FREQ_HZ = 100_000_000;


/**
 * Local variables and signals
 */
logic locked;
wire rst, clk;
wire enable_counting;

axi_if sseg_axis();
axi_if mem_axis();
axi_if uart_tx_axis();
axi_if uart_rx_axis();

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

main_controller #(
  .COUNT_CYCLES(COUNT_CYCLES)
)u_main_controller (
  .clk  (clk),
  .rst  (rst),
  .source_select(sw0),
  .start_measurment(btnU),
  .enable_counting(enable_counting),

  .PS2Clk       (PS2Clk),
  .PS2Data      (PS2Data),
  .sseg_axis    (sseg_axis),
  .mem_axis     (mem_axis),
  .uart_tx_axis (uart_tx_axis),
  .uart_rx_axis (uart_rx_axis)
);



// AXI slaves
sseg_controller #(
  .COMPONENT_ID(SSEG_ID)
)
u_sseg_controller (
  .clk    (clk),
  .rst    (rst),
  .sseg   (seg),
  .an     (an),
  .axi    (sseg_axis)
);

data_mem #(
  .COMPONENT_ID(MEMORY_ID)
)
u_data_mem (
  .clk(clk),
  .rst(rst),
  .axi(mem_axis)
);


top_uart#(
  .BAUD_RATE(BAUD_RATE),
  .CLK_FREQ(CLK_FREQ_HZ),
  .TX_ID(UART_TX_ID),
  .RX_ID(UART_RX_ID)
) u_top_uart(
  .clk(clk),
  .rst(rst),
  .rx(RsRx),

  .tx(RsTx),
  .axis_tx(uart_tx_axis),
  .axis_rx(uart_rx_axis)
);

endmodule
