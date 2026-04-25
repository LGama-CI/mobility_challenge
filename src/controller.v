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
    output reg hazards,                         // Pisca aleta
    output reg brake,                           // Freio
    output reg request_lane_change              // Solicitação de mudança de faixa    
);
    localparam IDLE = 4'b0000, ALERTING = 4'b0001, CHECKING_LANE = 4'b0010, CHANGING_LANE = 4'b0011,
               REQUESTING_LANE_CHANGE = 4'b0100, STOPPING = 4'b0101, CHECKING_LANE_RIGHT = 4'b0110,
               STOPPED = 4'b0111;

    localparam ALERT_DURATION = 2'b11;

    reg [3:0] state;
    reg [3:0] next_state;
    reg [3:0] counter;

    wire min_speed_limit;
    assign min_speed_limit = max_speed_limit >> 1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = IDLE;
        buzzer = 1;
        sets = 0;
        hazards = 0;
        brake = 0;
        request_lane_change = 0;

        case (state)
            IDLE: begin
                buzzer = 0;
                if(driver_off && speed > 0)
                    next_state = ALERTING;
            end
            ALERTING: begin
                if (counter >= ALERT_DURATION) begin
                    next_state = CHECKING_LANE;
                end else begin
                    next_state = ALERTING;
                end
            end
            CHECKING_LANE: begin
                brake = 1;
                if (speed <= min_speed_limit || lane_available)
                    next_state = STOPPING;
                else if (has_car_right)begin
                    next_state = REQUESTING_LANE_CHANGE;
                    request_lane_change = 1;
                end else
                    next_state = CHANGING_LANE;
            end
            REQUESTING_LANE_CHANGE: begin
                request_lane_change = 1;
                brake = 1;
                if (speed <= min_speed_limit)
                    next_state = STOPPING;
                else if (request_lane_change_accepted) begin
                    next_state = CHECKING_LANE_RIGHT;
                    brake = 0;
                    sets = 1;
                end else begin
                    next_state = REQUESTING_LANE_CHANGE;
                end
            end
            CHECKING_LANE_RIGHT: begin
                if (speed <= min_speed_limit)
                    next_state = STOPPING;
                else if (!has_car_right)begin
                    next_state = CHANGING_LANE;
                    sets = 1;
                end else begin
                    next_state = CHECKING_LANE_RIGHT;
                end
            end
            CHANGING_LANE: begin
                sets = 1;
                next_state = CHECKING_LANE;
            end
            STOPPING: begin
                brake = 1;
                if (speed == 0)
                    next_state = STOPPED;
                else
                    next_state = STOPPING;
            end
            STOPPED: begin
                brake = 1;
                hazards = 1;
                if (!driver_off)
                    next_state = IDLE;
                else
                    next_state = STOPPED;
            end

        endcase
    end
endmodule