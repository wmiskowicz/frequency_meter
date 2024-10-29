module enable_toggle #(
    parameter COUNT_MAX = 100_000_000
)(
    input   logic    clk,     
    input   logic    rst,   

    output  logic    enable  
);

  int count;  

  always_ff @(posedge clk) 
  begin
      if (rst) 
      begin
          count <= 0;
          enable <= 0;
      end 
      else if (count == COUNT_MAX) 
      begin
          count <= 0;
          enable <= ~enable; 
      end 
      else 
      begin
          count <= count + 1;
      end
  end

endmodule
