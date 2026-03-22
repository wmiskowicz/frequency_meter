module main_controller#(
  parameter int COUNT_CYCLES
)(
  input wire clk,
  input wire rst,
  input wire source_select,
  input wire start_measurment,

  inout PS2Clk,
  inout PS2Data,
  output logic enable_counting,
  
  axi_if.master sseg_axis,
  axi_if.master mem_axis,
  axi_if.master uart_tx_axis,
  axi_if.master uart_rx_axis
);

axi_if axim();

axi_stream_dmux u_axi_stream_dmux (
  .clk         (clk),
  .rst_n       (!rst),

  .m_axis      (axim),

  .mem_axis    (mem_axis),
  .sseg_axis   (sseg_axis),
  .uart_rx_axis(uart_rx_axis),
  .uart_tx_axis(uart_tx_axis)
);

pulse_counter_top #(
  .COUNT_CYCLES(COUNT_CYCLES)
)
u_pulse_counter_top (
  .clk          (clk),
  .rst          (rst),
  .source_select(source_select),
  .enable_counting(enable_counting),
  .start_measurment(start_measurment),

  .PS2Clk       (PS2Clk),
  .PS2Data      (PS2Data),
  .axi          (axim)
);


endmodule
