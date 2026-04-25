`timescale 1ns/1ps
module test_tb ();

    reg clk;
    reg sw0;
    wire led0;

    

    test instance_blink(
        .clk(clk),
        .sw0(sw0),
        .led0(led0)
    );

    initial begin
        clk = 0;
        sw0 = 0;
    end

     // Clock
    always #5 clk = ~clk;

endmodule
