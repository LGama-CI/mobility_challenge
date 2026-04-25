`include "counter.v"
`include "freq_divisor.v"
module controller(
    input wire clk,
    input wire rst,
    input wire [7:0] speed,
    input wire driver_off,
    input wire lane_available,
    input wire request_lane_change_accepted,
    input wire has_car_right,
    //input wire [7:0] max_speed_limit,
    output reg buzzer,
    output reg sets,
    output reg hazards,
    output reg brake,
    output reg request_lane_change
);

    localparam IDLE = 4'b0000, ALERTING = 4'b0001, CHECKING_LANE = 4'b0010, CHANGING_LANE = 4'b0011,
               REQUESTING_LANE_CHANGE = 4'b0100, STOPPING = 4'b0101, CHECKING_LANE_RIGHT = 4'b0110,
               STOPPED = 4'b0111;

    localparam ALERT_DURATION = 3'b011, max_speed_limit = 4'b1111;

    reg [3:0] state;
    reg [3:0] next_state;
    wire [2:0] count;

    wire [7:0] min_speed_limit;
    assign min_speed_limit = max_speed_limit >> 1;

    wire clk_div;
    freq_divisor freq_div(
        .clk(clk),
        .clk_out(clk_div)
    );
    counter alert_counter(
        .clk(clk_div),
        .rst(rst),
        .count(count)
    );

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;
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
                if (count >= ALERT_DURATION)
                    next_state = CHECKING_LANE;
            end

            CHECKING_LANE: begin
                brake = 1;
                if (speed <= min_speed_limit || lane_available)
                    next_state = STOPPING;
                else if (has_car_right) begin
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
                end
            end

            CHECKING_LANE_RIGHT: begin
                if (speed <= min_speed_limit)
                    next_state = STOPPING;
                else if (!has_car_right) begin
                    next_state = CHANGING_LANE;
                    sets = 1;
                end
            end

            CHANGING_LANE: begin
                sets = 1;
                next_state = CHECKING_LANE;
            end

            STOPPING: begin
                brake = 1;
                if (speed <= 1)
                    next_state = STOPPED;
            end

            STOPPED: begin
                brake = 1;
                hazards = 1;
                if (!driver_off)
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule