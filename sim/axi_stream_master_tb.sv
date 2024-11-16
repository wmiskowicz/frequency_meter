module axi_stream_master_tb;

  logic clk;
  logic rst_n;
  logic [31:0] data_in;
  logic send_packet;
  logic send_mean;

  localparam int CLK_PERIOD = 10ns;

  axi_if axi();

  axi_stream_master dut (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .send_packet(send_packet),
    .send_mean(send_mean),
    .axi(axi.master)
  );

  initial clk = 0;
  always begin
      #(CLK_PERIOD/2) clk = ~clk;
  end

  initial begin
    init_reset();

    send_data_packet(32'hAABBCCDD);
    send_data_packet(32'h12341234);
    send_data_packet(32'h55AA55AA);

    
    #100 $finish;
  end


  task wait_clock_cycles(input int num_cycles);
    for (int i = 0; i < num_cycles; i++) @(posedge clk);
  endtask

  task  init_reset();
    rst_n = 0;
    send_packet = 0;
    send_mean = 0;
    data_in = 32'hAABBCCDD;

    wait_clock_cycles(10);
    rst_n = 1;
    wait_clock_cycles(10);
  endtask

  task automatic send_data_packet(
    input logic  [31:0] data
  );
    data_in = data;
    send_packet = 1;
    axi.tready_in = 1;
    wait_clock_cycles(1);
    send_packet = 0;
    wait_clock_cycles(10);
  endtask 


  always @(posedge clk) begin
    if ($urandom_range(1, 10) <= 7) begin
      axi.tready_in <= 1; 
    end else begin
      axi.tready_in <= 0;
    end
  end




endmodule
