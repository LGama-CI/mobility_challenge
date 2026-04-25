module controller(
    input wire clk,
    input wire rst,
    input wire [7:0] speed,                     // Velocidade do carro
    input wire driver_off,                      // Motorista dormiu
    input wire lane_available,                  // Faixa disponível para parar
    input wire request_lane_change_accepted,    // Pedido de mudança de faixa aceito
    input wire has_car_right,                   // Carro à direita
    input wire max_speed_limit,                 // Velocidade máxima da via
    output reg buzzer,                          // Alarme 
    output reg sets,                            // Setas
    output reg hazards                          // Pisca aleta
    output reg brake,                          // Freio
    output reg request_lane_change             // Solicitação de mudança de faixa    
);
    localparam IDLE = 3'b000, ALERTING = 3'b001, CHANGING_LANE = 3'b010,
               REQUESTING_LANE_CHANGE = 3'b011, STOPPING = 3'b100, CHECKING_LANE_RIGHT = 3'b101;

    localparam ALERT_DURATION = 2'b11;

    reg [2:0] state;
    reg [2:0] next_state;
    reg [3:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = IDLE;
        buzzer = 0;
        sets = 0;
        hazards = 0;
        brake = 0;
        request_lane_change = 0;

        case (state)
            IDLE: begin
                if(motorista_indisponivel && velocidade > 0)
                    next_state = ALERTING;
            end
            ALERTING: begin
                buzzer = 1;
                if (counter >= ALERT_DURATION) begin
                    if (lane_available)
                        next_state = STOPPING;
                    else if (has_car_right)
                        next_state = REQUESTING_LANE_CHANGE;
                        request_lane_change = 1;
                    else
                        next_state = CHANGING_LANE;
                end else begin
                    next_state = ALERTING;
                end

            end
            REQUESTING_LANE_CHANGE: begin
                request_lane_change = 1;
                brake = 1;
                if (speed < max_speed_limit << 1) // Se a velocidade for menor que o dobro do limite
                    next_state = STOPPING;
                else if (request_lane_change_accepted) begin
                    next_state = CHANGING_LANE;
                    sets = 1;
                end else begin
                    next_state = REQUESTING_LANE_CHANGE;
                end

            end
            CHECKING_LANE_RIGHT: begin
            end
            STOPPING: begin
                brake = 1;
            end

        endcase
    end
endmodule