module top_counter #(
  parameter int CYCLLES_COUNT_MAX = 100_000_000
)(
  input   logic        clk,
  input   logic        rst,
  input   logic        pulse_signal,
  input   logic        start_measurment,

  output  logic        enable,
  axi_if.master        axi
);

import component_id_pkg::*;

localparam SSEG_REFRESH_RATE = 10;

wire inc, send_packet;
wire send_cyclic_packet;
wire [15:0] counter;


axi_stream_master #(
  .FRAME_SIZE(4)
)
u_axi_master (
  .axi        (axi),
  .clk        (clk),
  .data_in    ({16'd0, counter}),
  .id         (send_cyclic_packet ? SSEG_ID : UART_TX_ID),
  .rst_n      (!rst),
  .send_packet(send_packet || send_cyclic_packet)
);

enable_toggle #(
  .COUNT_MAX(CYCLLES_COUNT_MAX)
)
u_enable_toggle (
  .clk   (clk),
  .enable(enable),
  .rst   (rst)
);



posedge_detector increment (
  .clk(clk),
  .out(inc),
  .rst(rst),
  .sig(pulse_signal)
);

counter #(
  .CYCLIC_SEND_CYCLES(CYCLLES_COUNT_MAX / SSEG_REFRESH_RATE)
)u_counter (
  .clk    (clk),
  .rst    (rst),
  .start_measurment(start_measurment),
  .enable (enable),
  .inc    (inc),
  .send_packet(send_packet),
  .send_cyclic_packet(send_cyclic_packet),
  .counter(counter)
);

endmodule
