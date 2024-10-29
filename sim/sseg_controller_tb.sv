module sseg_controller_tb;

    logic clk;
    logic rst;
    logic [31:0] counter;
    logic [6:0]  sseg;

    localparam int CLK_PERIOD = 10ns;

    sseg_controller DUT (
        .clk(clk),
        .rst(rst),
        .counter(counter),
        .sseg(sseg)
    );

    initial clk = 0;
    always begin
        #(CLK_PERIOD/2) clk = ~clk;
    end

    task wait_clock_cycles(input int num_cycles);
        for (int i = 0; i < num_cycles; i++) @(posedge clk);
    endtask

    initial begin
        rst = 1;
        counter = 0;
        wait_clock_cycles(2);
        rst = 0;
        wait_clock_cycles(2);

        repeat (1000) begin
            wait_clock_cycles(1);
            counter = counter + 32'd1;
        end

        wait_clock_cycles(50);
        $stop;
    end

    initial begin
        $monitor("Time: %0t | Counter: %h | sseg: %b", $time, counter, sseg);
    end

endmodule
