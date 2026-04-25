module controller(
    input wire clk,
    input wire rst,
    input wire [7:0] speed,                     // Velocidade do carro
    input wire driver_off,                      // Motorista dormiu
    input wire lane_available,                  // Faixa disponível para parar
    input wire request_lane_change_accepted,    // Pedido de mudança de faixa aceito
    input wire has_car_right,                   // Carro à direita
    output reg buzzer,                          // Alarme 
    output reg sets,                            // Setas
    output reg hazards                          // Pisca aleta
);

    localparam IDLE = 3'b000, ALERTING = 3'b001, CHECKING_LANE = 3'b010, CHANGING_LANE = 3'b011,
               REQUESTING_LANE_CHANGE = 3'b100, STOPPING = 3'b101;

    reg [2:0] state;
    reg [2:0] next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
            end
            ALERTING: begin
            end
            CHECKING_LANE: begin
            end
            CHANGING_LANE: begin
            end
            REQUESTING_LANE_CHANGE: begin
            end
            STOPPING: begin
            end
            
        endcase
    end
endmodule