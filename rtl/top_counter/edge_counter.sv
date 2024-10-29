module counter(
    input   logic        clk,
    input   logic        rst,
    input   logic        enable,
    input   logic        inc,

    output  logic [31:0] counter
);
 logic en_prev;


  always_ff @(posedge clk) begin
    if (rst) begin
      counter <= '0;
      en_prev <= '0;
    end 
    else 

    if (enable==0)
    begin
      counter <= counter;
    end 
    else if (~en_prev && enable) 
    begin
      counter <= '0;
    end
    else if(inc && enable)
    begin
      counter <= counter + 1;
    end
    
    en_prev <= enable;

  end

endmodule
