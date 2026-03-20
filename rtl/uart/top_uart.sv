
module top_uart#(
  parameter BAUD_RATE = 9600,
  parameter CLK_FREQ = 100_000_000,
  parameter TX_ID,
  parameter RX_ID
)(
  input wire clk,
  input wire rst,
  input wire rx,

  output logic tx,
  axi_if.slave axis_tx,
  axi_if.slave axis_rx
);
  
wire [7:0] rx_data;
wire read_valid;

uart_rx #(
  .CLK_FREQ(CLK_FREQ),
  .BAUD_RATE(BAUD_RATE)
)u_uart_rx (
  .clk     (clk),
  .rst     (rst),
  .rx      (rx),

  .data_out(rx_data),
  .read_valid(read_valid)
);

fifo_generator_0 fifo_rx (
  .clk(clk),   
  .srst(rst),  
  .din(rx_data),   
  .wr_en(read_valid), 
  .rd_en(), 
  .dout(),
  .full(),
  .empty()
);


top_uart_tx #(
  .TX_ID    (TX_ID),
  .CLK_FREQ (CLK_FREQ),
  .BAUD_RATE(BAUD_RATE)
)
u_top_uart_tx (
  .axis(axis_tx),
  .clk(clk),
  .rst(rst),
  .tx (tx)
);



endmodule
