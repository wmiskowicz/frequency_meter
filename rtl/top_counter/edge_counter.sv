module counter(
    input   logic        clk,
    input   logic        rst,
    input   logic        enable,
    input   logic        inc,

    output  logic [15:0] counter,
    output  logic        send_packet
);


 logic posedge_enable, negedge_enable, cyclic_send_edge;
 logic send_reset_packet;
 logic cyclic_send_packet;

 assign send_packet = send_reset_packet || cyclic_send_edge || negedge_enable;


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

  posedge_detector posedge_send (
    .clk(clk),
    .out(posedge_enable),
    .rst(rst),
    .sig(enable)
 );

 posedge_detector negedge_send (
  .clk(clk),
  .out(negedge_enable),
  .rst(rst),
  .sig(!enable)
);

posedge_detector cyclic_send (
  .clk(clk),
  .out(cyclic_send_edge),
  .rst(rst),
  .sig(cyclic_send_packet)
);

 enable_toggle #(
  .COUNT_MAX(10_000_000) // normally 10_000_000, for simulation 10
)
send_enable (
  .clk   (clk),
  .enable(cyclic_send_packet),
  .rst   (rst)
);

endmodule
