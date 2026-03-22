module random_generator (
  input  wire   clk,
  input  wire   rst,
  input  wire   start_measurment,
  output reg    random
);


// ---- Local parameters ----
localparam WIDTH = 16;

// ---- Local variables ----
logic [31:0] counter;
logic start_measurment_latch;
wire  [WIDTH-1:0] dataout;

assign random = ^dataout;


lfsr #(
  .WIDTH(WIDTH)
)
u_lfsr (
  .datain (start_measurment_latch ? counter[15:0] : 16'd0),
  .dataout(dataout)
);

always_ff @(posedge clk) begin
  if (rst) begin
    counter <= 32'hACE1;
  end
  else begin
    counter <= counter + dataout + 32'd1;
  end
end

always_ff @(posedge clk) begin
  if (rst) begin
    start_measurment_latch <= 1'b0;
  end
  else if (start_measurment) begin
    start_measurment_latch <= 1'b1;
  end
end


endmodule
