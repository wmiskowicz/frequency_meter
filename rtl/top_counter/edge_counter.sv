module counter(
    input   logic        clk,
    input   logic        rst,
    input   logic        enable,
    input   logic        inc,

    output  logic [15:0] counter,
    output  logic        send_packet
);


 logic posedge_enable;
 logic send_reset_packet;

 assign send_packet = send_reset_packet || cyclic_send_packet;


  always_ff @(posedge clk) begin
    if (rst) begin
      counter <= '0;
    end 
    else 

    if (enable==0)
    begin
      counter <= counter;
    end 
    else if (posedge_enable) 
    begin
      counter <= '0;
    end
    else if(inc && enable)
    begin
      counter <= counter + 1;
    end

    send_reset_packet <= posedge_enable;
  end

  posedge_detector increment (
    .clk(clk),
    .out(posedge_enable),
    .rst(rst),
    .sig(enable)
 );

 enable_toggle #(
  .COUNT_MAX(100)
)
send_enable (
  .clk   (clk),
  .enable(cyclic_send_packet),
  .rst   (rst)
);

endmodule
