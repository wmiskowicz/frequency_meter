`timescale 1ns / 1ps

module uart_rx_tb;

// Parameters
localparam CLK_FREQ = 100_000_000;
localparam BAUD_RATE = 115200; // Faster baud for shorter simulation
localparam PERIOD = 10; // 100MHz clock
localparam BIT_TIME = 1_000_000_000 / BAUD_RATE; // Time per bit in ns

// Signals
logic clk = 0;
logic sample;
logic rst;
logic rx;
logic [7:0] data_out;
logic [7:0] data_send;
logic read_valid;

assign sample = uut.uart_ctr == uut.CTR_SAMPLE_VAL;

// Instantiate UUT
uart_rx #(
  .CLK_FREQ(CLK_FREQ),
  .BAUD_RATE(BAUD_RATE)
) uut (
  .clk(clk),
  .rst(rst),
  .rx(rx),
  .data_out(data_out),
  .read_valid(read_valid)
);

// Clock Generation
always #(PERIOD/2) clk = ~clk;

// Task to send one UART byte
task send_byte(input [7:0] data);
  integer i;
  logic parity;
  parity = ^data; // Simple XOR for even parity

  $display("[TX] Sending Byte: 0x%h at %t", data, $time);

  // Start Bit (Logical 0)
  rx = 0;
  #(BIT_TIME);

  // Data Bits (LSB first)
  for (i = 0; i < 8; i = i + 1) begin
    rx = data[i];
    #(BIT_TIME);
  end

  // Parity Bit
  rx = parity;
  #(BIT_TIME);

  // Stop Bit (Logical 1)
  rx = 1;
  #(BIT_TIME);

  $display("[TX] Finished Sending Byte at %t", $time);
endtask

// Stimulus
initial begin
  // Initialize
  rst = 1;
  rx = 1; // Idle state for UART is High
  #50;
  rst = 0;
  #500;

  // Test Case 1: Send 0xA5
  data_send = 8'hA5;
  send_byte(data_send);

  // Wait for valid signal
  wait(read_valid);
  $display("[RX] Received Data: 0x%h", data_out);
  #100;

  // Test Case 2: Send 0x3C
  data_send = 8'h3C;
  send_byte(data_send);

  wait(read_valid);
  $display("[RX] Received Data: 0x%h", data_out);

  #500;
  $display("Simulation Finished");
  $finish;
end

endmodule
