
module top_uart#(
  BAUD_RATE = 9600
)(
  input wire clk,
  input wire rst,
  input wire rx,

  output logic tx
);
  
wire [7:0] rx_data;
wire read_valid;

uart_rx u_uart_rx (
  .clk     (clk),
  .rst     (rst),
  .rx      (rx),

  .data_out(rx_data),
  .read_valid(read_valid)
);

fifo_generator_0 fifo_rx (
  .clk(clk),   
  .rst(rst),  
  .din(rx_data),   
  .wr_en(read_valid), 
  .rd_en(), 
  .dout(),
  .full(),
  .empty()
);

endmodule
