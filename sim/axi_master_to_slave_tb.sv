module axi_master_to_slave_tb;

import component_id_pkg::*;

logic clk;
logic rst_n;
logic [31:0] data_to_send;
logic [7:0] slave_id;
logic send_packet;
wire RsRx;
wire RsTx;

localparam int CLK_PERIOD = 10ns;

axi_if axi_m();
axi_if sseg_axis();
axi_if mem_axis();
axi_if uart_tx_axis();
axi_if uart_rx_axis();


axi_stream_master dut (
  .clk(clk),
  .rst_n(rst_n),
  .id(slave_id),
  .data_in(data_to_send),
  .send_packet(send_packet),
  .axi(axi_m)
);

axi_stream_dmux u_axi_stream_dmux (
  .clk         (clk),
  // Interface from Master
  .m_axis      (axi_m),
  .mem_axis    (mem_axis),
  .rst_n       (rst_n),
  // Interfaces to Slaves
  .sseg_axis   (sseg_axis),
  .uart_rx_axis(uart_rx_axis),
  .uart_tx_axis(uart_tx_axis)
);

// AXI slaves
sseg_controller #(
  .COMPONENT_ID(SSEG_ID)
)
u_sseg_controller (
  .clk    (clk),
  .rst    (!rst_n),
  .sseg   (),
  .an     (),
  .axi    (sseg_axis)
);

data_mem #(
  .COMPONENT_ID(MEMORY_ID)
)
u_data_mem (
  .clk(clk),
  .rst(!rst_n),
  .axi(mem_axis)
);


top_uart#(
  .BAUD_RATE(9600),
  .CLK_FREQ(100_000_000),
  .TX_ID(UART_TX_ID),
  .RX_ID(UART_RX_ID)
) u_top_uart(
  .clk(clk),
  .rst(!rst_n),
  .rx(RsRx),

  .tx(RsTx),
  .axis_tx(uart_tx_axis),
  .axis_rx(uart_rx_axis)
);

initial clk = 0;
always begin
  #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
  init_reset();

  send_data_packet(32'hAABBCCDD, SSEG_ID);
  send_data_packet(32'h12341234, UART_TX_ID);
  send_data_packet(32'h55AA55AA, SSEG_ID);


  #100 $finish;
end


task wait_clock_cycles(input int num_cycles);
  for (int i = 0; i < num_cycles; i++) @(posedge clk);
endtask

task  init_reset();
  rst_n = 0;
  send_packet = 0;
  data_to_send = 32'hAABBCCDD;

  wait_clock_cycles(10);
  rst_n = 1;
  wait_clock_cycles(10);
endtask

task automatic send_data_packet(
    input logic  [31:0] data,
    input logic  [7:0] id
  );
  data_to_send = data;
  slave_id = id;
  send_packet = 1;
  wait_clock_cycles(1);
  send_packet = 0;
  wait_clock_cycles(10);
endtask





endmodule
