module random_generator (
    input  wire        clk,          
    input  wire        rst,
    input  wire [11:0] xpos,        
    output reg         random    
);

  // LFSR with a simple feedback polynomial
  reg [7:0] lfsr;

  always_ff @(posedge clk) begin
    if (rst) begin
      lfsr <= 8'h1;
      random <= 1'b0;
    end else begin
      lfsr <= {lfsr[5:0], xpos[1], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3] ^ xpos[3] ^ xpos[7]};
      random <= lfsr[0] && xpos[0] ^ xpos[4];
    end
  end

endmodule
