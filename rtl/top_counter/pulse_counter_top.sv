module pulse_counter_top#(
  parameter COUNT_CYCLES = 100_000_000
)(
  input wire clk,
  input wire rst,
  input wire source_select,
  input wire start_measurment,

  output logic enable_counting,
  inout PS2Clk,
  inout PS2Data,

  axi_if.master axi
);

wire mouse_signal, random;
wire pulse_signal;

assign pulse_signal = source_select ? mouse_signal : random;

// Pulse sources
top_mouse u_top_mouse (
  .clk     (clk),
  .rst     (rst),
  .ps2_clk (PS2Clk),
  .ps2_data(PS2Data),
  .xpos    (),
  .right   (),
  .left    (mouse_signal)
);

random_generator u_random_bit_generator (
  .clk              (clk),
  .rst              (rst),
  .start_measurment (start_measurment),
  .random           (random)
);

// AXI master
top_counter #(
  .CYCLLES_COUNT_MAX(COUNT_CYCLES)
)
u_top_counter (
  .clk    (clk),
  .rst    (rst),
  .start_measurment (start_measurment),
  .enable  (enable_counting),
  .pulse_signal(pulse_signal),
  .axi    (axi)
);


endmodule
