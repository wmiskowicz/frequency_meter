`timescale 1ns / 1ps

module random_generator_tb();

// ---- Signal Declarations ----
logic clk;
logic rst;
logic start_measurment;
logic random;

// Measurement variables
int pulse_count;
int window_size = 1000; // Number of clock cycles per measurement period
real density;

// ---- DUT Instantiation ----
random_generator dut (
  .clk(clk),
  .rst(rst),
  .start_measurment(start_measurment),
  .random(random)
);

// ---- Clock Generation (100MHz) ----
initial begin
  clk = 0;
  forever #5 clk = ~clk;
end

// ---- Test Logic ----
initial begin
  rst = 1;
  start_measurment = 0;
  pulse_count = 0;

  #100;
  @(posedge clk);
  rst = 0;

  // Trigger the LFSR seed/measurement start
  #20;
  @(posedge clk);
  start_measurment = 1;
  #10;
  start_measurment = 0;

  $display("--- Starting Random Pulse Measurement ---");
  $display("Window Size: %0d clock cycles", window_size);
  $display("Time | Pulses | Density (%%)");

  repeat (5) begin
    rst = 1;
    start_measurment = 0;
    pulse_count = 0;

    #100;
    @(posedge clk);
    rst = 0;

    // Trigger the LFSR seed/measurement start
    #20;
    @(posedge clk);
    start_measurment = 1;
    #10;
    start_measurment = 0;
    repeat (5) begin
      pulse_count = 0;

      repeat (window_size) begin
        @(posedge clk);
        if (random) pulse_count++;
      end

      density = (real'(pulse_count) / window_size) * 100.0;
      $display("%t | %0d | %0.2f%%", $time, pulse_count, density);
    end
  end

  #100;
  $display("--- Simulation Finished ---");
  $stop;
end

endmodule
