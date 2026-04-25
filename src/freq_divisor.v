module freq_divisor (
    input wire clk,
    output reg clk_out
);

    reg [24:0] counter; 

    always @(posedge clk) begin
        counter <= counter + 1'b1;
    end

    always @(posedge counter[24]) begin                
        clk_out <= ~clk_out;
    end


endmodule