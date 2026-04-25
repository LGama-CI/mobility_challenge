module counter
#(parameter WIDTH = 3)
(
    input clk,rst,
    output reg [WIDTH-1:0] count
);

always@(posedge clk or negedge rst) begin
    if(!rst)
        count<=0;
    else
        count<=count+1;
    end
endmodule
