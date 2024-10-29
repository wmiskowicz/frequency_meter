module tb_enable_toggle;

    localparam int CLK_PERIOD = 10ns;

    logic clk;
    logic rst;
    logic enable;

    enable_toggle DUT (
        .clk(clk),
        .rst(rst),
        .enable(enable)
    );

    always begin
        #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test sequence
    initial begin
        clk = 0;
        rst = 1;
        #10; 
        rst = 0;
        #10;

        #2_000_000_000;
        $stop;
    end

    initial begin
        $monitor("Time: %0t | rst: %b | Enable: %b", $time, rst, enable);
    end

endmodule
