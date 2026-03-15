`timescale 1ns / 1ps

module top_uart_tx_tb;

// Parameters
localparam CLK_FREQ  = 100_000_000;
localparam BAUD_RATE = 115200;
localparam BIT_TIME   = 1_000_000_000 / BAUD_RATE;
localparam TX_ID     = 8'h01;
localparam FRAME_SIZE = 4;
localparam CLK_PER   = 10; // 100MHz
localparam UART_TRANSMISSION_TIME = BIT_TIME * 11;

// Signals
logic clk = 0;
logic rst;
logic tx;
logic [7:0] captured_data;
logic parity;

// Interface Instance
axi_if axi();

// DUT Instance
top_uart_tx #(
  .TX_ID(TX_ID),
  .CLK_FREQ(CLK_FREQ),
  .BAUD_RATE(BAUD_RATE)
) dut (
  .clk(clk),
  .rst(rst),
  .axis(axi.slave),
  .tx (tx)
);

// Clock Gen
always #(CLK_PER/2) clk = ~clk;


initial begin
  // Reset sequence
  rst = 1;
  axi.tdata  = 0;
  axi.tvalid = 0;
  axi.tlast  = 0;
  #(CLK_PER * 10);
  rst = 0;
  #(CLK_PER * 10);

  send_data_packet(TX_ID, '{8'hAA, 8'hBB, 8'hCC, 8'hDD});
  send_data_packet(TX_ID, '{8'h45, 8'haa, 8'h12, 8'h34});
  send_data_packet(TX_ID, '{8'h43, 8'h21, 8'h44, 8'h55});
  send_data_packet(TX_ID, '{8'h11, 8'h22, 8'h33, 8'h44});

  #(UART_TRANSMISSION_TIME * 16);
  #30us;
  $display("[TB] Test Complete");
  $finish;
end


// ---- Tasks ----
task wait_clock_cycles(input int num_cycles);
  for (int i = 0; i < num_cycles; i++) @(posedge clk);
endtask


always monitor_tx();

task monitor_tx();

  // Wait for Start Bit (falling edge)
  @(negedge tx);
  captured_data = 0;
  $display("[Monitor] Start bit detected at %t", $time);

  // Wait to reach middle of start bit
  #(BIT_TIME / 2);

  // Sample 8 data bits
  for (int i = 0; i < 8; i++) begin
    #(BIT_TIME);
    captured_data[i] = tx;
  end

  // Sample Parity bit
  #(BIT_TIME);
  parity = tx;

  // Sample Stop bit
  #(BIT_TIME);
  $display("[Monitor] Recieved data 0x%h", captured_data);

  if (parity !== (^captured_data))
    $display("[Monitor] ERROR: Parity mismatch!");
endtask


task automatic send_data_packet(
    input logic [7:0] id,
    input logic [7:0] payload [FRAME_SIZE]
  );
  axi.tvalid <= 1;
  axi.tdata <= id;
  wait_clock_cycles(1);

  for (int i = 0; i < FRAME_SIZE; i++) begin
    axi.tdata <= payload[i];
    axi.tlast <= (i == FRAME_SIZE-1);
    wait_clock_cycles(1);
  end

  axi.tvalid <= 0;
  axi.tlast  <= 0;
  wait_clock_cycles(10);
endtask


endmodule