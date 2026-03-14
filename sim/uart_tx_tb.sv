`timescale 1ns / 1ps

module uart_tx_tb;

// Parameters
localparam CLK_FREQ  = 100_000_000;
localparam BAUD_RATE = 115200;
localparam CLK_PERIOD = 10; // 100 MHz
localparam BIT_TIME   = 1_000_000_000 / BAUD_RATE;

// Signals
logic clk = 0;
logic rst;
logic start_tx;
logic [7:0] tx_data; // Changed to 8-bit to match logic
logic tx;

// Instantiate UUT
uart_tx #(
  .CLK_FREQ(CLK_FREQ),
  .BAUD_RATE(BAUD_RATE)
) uut (
  .clk(clk),
  .rst(rst),
  .start_tx(start_tx),
  .tx_data(tx_data),
  .tx(tx)
);

// Clock Gen
always #(CLK_PERIOD/2) clk = ~clk;
logic [7:0] captured_data;
logic parity;

// Monitor Task: Captures the TX line and prints the result
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

// Stimulus
initial begin
  // Init
  rst = 1;
  start_tx = 0;
  tx_data = 8'h00;
  #(CLK_PERIOD * 10);
  rst = 0;
  #(CLK_PERIOD * 10);

  // Test Case 1: Send 0x55 (01010101)
  $display("[Monitor] Sending data 0x55");
  @(posedge clk);
  tx_data = 8'h55;
  start_tx = 1;
  @(posedge clk);
  start_tx = 0;

  monitor_tx();
  #(3*BIT_TIME)

  // Test Case 2: Send 0xA5
  $display("[Monitor] Sending data 0xA5");
  #(BIT_TIME); // Small gap between frames
  @(posedge clk);
  tx_data = 8'hA5;
  start_tx = 1;
  @(posedge clk);
  start_tx = 0;

  monitor_tx();

  #1000;
  $display("Simulation Finished");
  $finish;
end

endmodule