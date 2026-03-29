module counter#(
  parameter CYCLIC_SEND_CYCLES = 10_000_000
)(
    input   logic        clk,
    input   logic        rst,
    input   logic        enable,
    input   logic        inc,
    input   logic        start_measurment,

    output  logic [15:0] counter,
    output  logic        send_packet,
    output  logic        send_cyclic_packet
);


 logic posedge_enable, negedge_enable, cyclic_send_edge;
 logic start_latch;
 logic send_reset_packet;
 logic cyclic_send_packet;

 assign send_packet = start_latch && (send_reset_packet || negedge_enable);
 assign send_cyclic_packet = start_latch && cyclic_send_edge;

  always @(posedge clk) begin
    if (rst) begin
      start_latch <= 1'b0;
    end
    else begin
      if (start_measurment)
        start_latch <= 1'b1;
    end
  end
  

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
  .COUNT_MAX(CYCLIC_SEND_CYCLES)
)
send_enable (
  .clk   (clk),
  .enable(cyclic_send_packet),
  .rst   (rst)
);

endmodule
