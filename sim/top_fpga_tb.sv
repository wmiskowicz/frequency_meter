`timescale 1 ns / 1 ps

module top_fpga_tb();

// Inputs
logic clk_in1;
logic btnC;
logic sw0;
wire  RsRx;

// Inouts
wire PS2Clk;
wire PS2Data;

// Outputs
logic RsTx;
logic [1:0] led;
logic [6:0] seg;
logic [3:0] an;
logic start_measurement;

// Instantiate the Unit Under Test (UUT)
top_fpga #(
  .COUNT_CYCLES(1000)
)uut (
  .clk_in1(clk_in1),
  .btnC(btnC),
  .btnU(start_measurement),
  .sw0(sw0),
  .RsRx(RsRx),
  .PS2Clk(PS2Clk),
  .PS2Data(PS2Data),
  .RsTx(RsTx),
  .led(led),
  .seg(seg),
  .an(an)
);

// Clock generation (100 MHz)
initial begin
  clk_in1 = 0;
  forever #5 clk_in1 = ~clk_in1;
end

// Pullups for PS2 lines (Standard for open-drain)
assign (weak1, weak0) PS2Clk = 1'b1;
assign (weak1, weak0) PS2Data = 1'b1;

// RsRx tie-off
assign RsRx = 1'b1;

initial begin
  // Initialize Inputs
  btnC = 1;      // Start in reset
  sw0 = 0;       // Start with random generator mode

  // Wait for global reset
  #1000;
  btnC = 0;      // Release reset

  // Wait for PLL/Locked signal (if simulated)
  #200;
  start_measurement = 1'b1;

  // Change switch mode halfway through
  #5000;
  sw0 = 0;

  // Final wait as requested
  #10000;

  $display("Simulation finished at %t", $time);
  $stop;
end

endmodule