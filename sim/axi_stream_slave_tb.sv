module axi_stream_slave_tb;

  logic clk;
  logic rst_n;

  localparam int CLK_PERIOD = 10ns;
  localparam int PCK_SIZE = 4;
  localparam ID_VALID = 8'h7F;

  axi_if axi();
  
  axi_stream_slave #(.PCK_SIZE(PCK_SIZE)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .axi(axi.slave)
  );

  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  initial begin
    init_reset();
    send_data_packet(ID_VALID, '{8'hAA, 8'hBB, 8'hCC, 8'hDD});
    send_data_packet(ID_VALID, '{8'h45, 8'haa, 8'h12, 8'h34});
    send_data_packet(ID_VALID, '{8'h43, 8'h21, 8'h44, 8'h55});
    send_data_packet(8'h00, '{8'h11, 8'h22, 8'h33, 8'h44});
    #100 $finish;
  end

  task wait_clock_cycles(input int num_cycles);
    for (int i = 0; i < num_cycles; i++) @(posedge clk);
  endtask

  task init_reset();
    rst_n = 0;
    wait_clock_cycles(10);
    rst_n = 1;
    wait_clock_cycles(10);
  endtask

  task automatic send_data_packet(
    input logic [7:0] id,
    input logic [7:0] payload [PCK_SIZE]
  );
    axi.tvalid <= 1;
    axi.tdata <= id;
    wait_clock_cycles(1);

    for (int i = 0; i < PCK_SIZE; i++) begin
      axi.tdata <= payload[i];
      axi.tlast <= (i == PCK_SIZE-1);
      wait_clock_cycles(1);
    end

    axi.tvalid <= 0;
    axi.tlast  <= 0;
    wait_clock_cycles(10);
  endtask

endmodule
