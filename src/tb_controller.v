`timescale 1ns/1ps
`include "controller.v"

module controller_tb;

// ========================
// Sinais
// ========================
reg clk;
reg rst;
reg [7:0] speed;
reg driver_off;
reg lane_available;
reg request_lane_change_accepted;
reg has_car_right;
reg [7:0] max_speed_limit;

wire buzzer;
wire sets;
wire hazards;
wire brake;
wire request_lane_change;

// ========================
// DUT
// ========================
controller dut (
    .clk(clk),
    .rst(rst),
    .speed(speed),
    .driver_off(driver_off),
    .lane_available(lane_available),
    .request_lane_change_accepted(request_lane_change_accepted),
    .has_car_right(has_car_right),
    .max_speed_limit(max_speed_limit),
    .buzzer(buzzer),
    .sets(sets),
    .hazards(hazards),
    .brake(brake),
    .request_lane_change(request_lane_change)
);

// ========================
// CLOCK
// ========================
always #5 clk = ~clk;

// ========================
// DECODIFICADOR DE ESTADO
// ========================
function [200:0] state_name;
    input [3:0] s;
    begin
        case (s)
            4'b0000: state_name = "IDLE";
            4'b0001: state_name = "ALERTING";
            4'b0010: state_name = "CHECKING_LANE";
            4'b0011: state_name = "CHANGING_LANE";
            4'b0100: state_name = "REQUEST_LANE";
            4'b0101: state_name = "STOPPING";
            4'b0110: state_name = "CHECK_RIGHT";
            4'b0111: state_name = "STOPPED";
            default: state_name = "UNKNOWN";
        endcase
    end
endfunction

// ========================
// MONITOR PRINCIPAL
// ========================
initial begin
    $dumpfile("controller.vcd");
    $dumpvars(0, controller_tb);

    $display("===========================================================================");
    $display("TIME | STATE            | SPD | drv | lane | right | acc | brk | set | haz | buz");
    $display("===========================================================================");
end

always @(posedge clk) begin
    $display("%4t | %-15s | %3d |  %b  |  %b   |   %b   |  %b  |  %b  |  %b  |  %b  |  %b",
        $time,
        state_name(dut.state),
        speed,
        driver_off,
        lane_available,
        has_car_right,
        request_lane_change_accepted,
        brake,
        sets,
        hazards,
        buzzer
    );
end

// ========================
// MONITOR DE TRANSIÇÃO
// ========================
reg [3:0] prev_state;

always @(posedge clk) begin
    if (dut.state != prev_state) begin
        $display(">>> TRANSITION: %s -> %s at %0t",
            state_name(prev_state),
            state_name(dut.state),
            $time
        );
    end
    prev_state <= dut.state;
end

// ========================
// MONITOR DE EVENTOS
// ========================
always @(posedge clk) begin
    if (request_lane_change)
        $display(">>> EVENT: Pedido de mudança de faixa @%0t", $time);

    if (hazards)
        $display(">>> EVENT: Pisca-alerta ativo @%0t", $time);

    if (brake && speed > 0)
        $display(">>> EVENT: Freando... speed=%0d @%0t", speed, $time);
end

// ========================
// ASSERTIONS SIMPLES
// ========================
always @(posedge clk) begin
    if (dut.state == 4'b0111 && speed > 1) begin
        $display("!!! ERRO: STOPPED com speed > 0 @%0t", $time);
        $stop;
    end
end

// ========================
// ESTÍMULOS
// ========================
initial begin
    clk = 0;
    rst = 1;
    speed = 0;
    driver_off = 0;
    lane_available = 0;
    request_lane_change_accepted = 0;
    has_car_right = 0;
    max_speed_limit = 80;

    prev_state = 0;

    #10 rst = 0;

    // ------------------------
    // CENÁRIO 1: motorista dorme
    // ------------------------
    speed = 60;
    driver_off = 1;
    #50;

    // ------------------------
    // CENÁRIO 2: pode parar
    // ------------------------
    lane_available = 1;
    #40;

    speed = 30;
    #40;

    speed = 0;
    #40;

    driver_off = 0;
    #40;

    // ------------------------
    // CENÁRIO 3: mudança de faixa
    // ------------------------
    speed = 70;
    driver_off = 1;
    lane_available = 0;
    has_car_right = 1;
    #50;

    request_lane_change_accepted = 1;
    #40;

    has_car_right = 0;
    #40;

    speed = 20;
    #40;

    speed = 0;
    #40;

    $finish;
end

endmodule