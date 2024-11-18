module top_counter_tb;

    logic clk;
    logic rst;
    logic pulse_signal;

    axi_if axi();

    localparam int CLK_PERIOD = 10ns;
    assign axi.tready = 1'b1;

    top_counter #(
      .CYCLLES_COUNT_MAX(100)
    )dut (
        .clk(clk),
        .rst(rst),
        .pulse_signal(pulse_signal),
        .axi(axi)
    );

    sseg_controller #(
      .COMPONENT_ID(8'h7F)
     ) u_sseg_controller (
      .clk    (clk),
      .rst    (rst),
      .sseg   (),
      .an     (),
      .axi    (axi)
     );

    initial clk = 0;
    always 
    begin
      #(CLK_PERIOD/2) clk = ~clk;
    end

    task wait_clock_cycles(input int num_cycles);
        for (int i = 0; i < num_cycles; i++) @(posedge clk);
    endtask

    always @(posedge clk) begin
      if ($urandom_range(1, 10) <= 7) begin
        pulse_signal <= 1; 
      end else begin
        pulse_signal <= 0;
      end
    end

    initial begin
        rst = 1;
        wait_clock_cycles(2);
        rst = 0;
        wait_clock_cycles(10000);



        $finish;
    end


endmodule
