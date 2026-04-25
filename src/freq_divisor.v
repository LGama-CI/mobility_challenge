module freq_divisor (
    input wire clk,
    input wire rst,
    output wire clk_out
);

    reg [24:0] counter; 

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 25'h0;
        end else begin
            counter <= counter + 1'b1;
        end
    end

    assign clk_out = counter[24]; 

endmodule