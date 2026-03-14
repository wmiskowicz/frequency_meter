module main_fsm(
  input wire clk,
  input wire rst,
  input wire RsRx,

  output logic RsTx,
  output logic state
);


top_uart #(
  .BAUD_RATE(9600)
) u_top_uart (
  .clk(clk),
  .rst(rst),
  .rx(RsRx),
  .tx(RsTx)
);


endmodule
