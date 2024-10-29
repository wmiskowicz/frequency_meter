module posedge_detector (
    input   logic   clk,
    input   logic   rst,
    input   logic   sig,

    output  logic   out
);  

  logic sig_prev;  


  always_ff @(posedge clk)
  begin
    if (rst) 
    begin
      sig_prev <= '0;
      out <= '0;
    end
    else
    begin
        sig_prev <= sig;
        out <= ~sig_prev && sig;
    end
  end

endmodule
