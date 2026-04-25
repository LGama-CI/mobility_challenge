module test (
    input wire clk, 
    input wire sw0, 
    output wire led0
);

    reg [24:0] counter; 
    reg led_state;

    always @(posedge clk) begin
        counter <= counter + 1'b1;
    end

    always @(posedge counter[24]) begin                
        led_state <= ~led_state;
    end

    assign led0 = sw0 ? led_state : 1'b0;

endmodule
