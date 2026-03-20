module top_uart_tx#(
  parameter int TX_ID,
  parameter int CLK_FREQ,
  parameter int BAUD_RATE
)(
  input wire clk,
  input wire rst,
  axi_if.slave axis,

  output logic tx
);
// ----- Local parameters -----
localparam FRAME_SIZE = 4;


// ----- Local variables -----
axi_if axi();
wire start_tx;
wire tx_busy;
wire [7:0] tx_data;
wire select;

// ---- FIFO ----
wire fifo_empty;
wire fifo_full;

// ----- Signal assignments -----
assign start_tx = !fifo_empty && !tx_busy;

always_comb begin
  axis.tdata = axis.tdata;
  axis.tlast = axis.tlast;
  axis.tready = !fifo_full;
  axis.tvalid = axis.tvalid;
end


// ----- Module logic -----

axi_stream_slave #(
  .FRAME_SIZE(FRAME_SIZE),
  .ID_VALID  (TX_ID)
)
u_axi_stream_slave (
  .clk    (clk),
  .rst_n  (~rst),
  .axi    (axi),

  .rx_data(),
  .select (select),
  .data_valid ()
);

uart_tx #(
  .CLK_FREQ (CLK_FREQ),
  .BAUD_RATE(BAUD_RATE)
)
u_uart_tx (
  .clk     (clk),
  .rst     (rst),
  .start_tx(start_tx),
  .tx_data (tx_data),

  .tx      (tx),
  .busy    (tx_busy)
);


fifo_generator_0 fifo_tx (
  .clk(clk),   
  .srst(rst),  
  .din(axi.tdata),   
  .wr_en(select), 
  .rd_en(start_tx), 
  .dout(tx_data),
  .full(fifo_full),
  .empty(fifo_empty)
);


endmodule
