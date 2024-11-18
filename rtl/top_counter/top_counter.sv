module top_counter #(
  parameter int CYCLLES_COUNT_MAX = 100_000_000
)(
  input   logic        clk,
  input   logic        rst,  
  input   logic        pulse_signal,

  output  logic        enable,
  axi_if.master        axi
);

  wire inc, send_packet;
  wire [15:0] counter;

  axi_stream_master #(
    .FRAME_SIZE(4)
  )u_axi_master (
    .axi        (axi),
    .clk        (clk),
    .data_in    (counter),
    .rst_n      (!rst),
    .send_packet(send_packet)
  );

  enable_toggle #(
    .COUNT_MAX(CYCLLES_COUNT_MAX)
  )
  u_enable_toggle (
    .clk   (clk),
    .enable(enable),
    .rst   (rst)
  );

  posedge_detector send_packet_enable (
    .clk(clk),
    .out(send_packet),
    .rst(rst),
    .sig(!enable)
 );

 posedge_detector increment (
    .clk(clk),
    .out(inc),
    .rst(rst),
    .sig(pulse_signal)
 );

 counter u_counter (
    .clk    (clk),
    .rst    (rst),
    .enable (enable),
    .inc    (inc),
    .counter(counter)
 );

endmodule
