module top_counter_tb;

    logic clk;
    logic rst;
    logic left;
    logic [31:0] counter;
    logic enable;

    localparam int CLK_PERIOD = 10ns;

    top_counter uut (
        .clk(clk),
        .rst(rst),
        .left(left),
        .counter(counter),
        .enable(enable)
    );

    initial clk = 0;
    always 
    begin
      #(CLK_PERIOD/2) clk = ~clk;
    end

    task wait_clock_cycles(input int num_cycles);
        for (int i = 0; i < num_cycles; i++) @(posedge clk);
    endtask

    task automatic generate_inc();
      repeat (15) begin
        left = 1;
        wait_clock_cycles(4);
        left = 0;
        wait_clock_cycles(3);
        left = 1;
        wait_clock_cycles(6);
        left = 0;
        wait_clock_cycles(10);
      end
    endtask

    initial begin
        rst = 1;
        wait_clock_cycles(2);
        rst = 0;
        wait_clock_cycles(10);


        enable = 1;
        wait_clock_cycles(2);
        generate_inc();
        
        enable = 0;
        wait_clock_cycles(2);
        generate_inc();



        $stop;
    end


endmodule
