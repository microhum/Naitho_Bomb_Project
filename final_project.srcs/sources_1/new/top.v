module top(
    input clock,
    input reset,
    input [7:0] password_answer, // password answer
    input [7:0] password_input, // password input
    output reg [7:0] LED_answer, // display for password answer
    output reg [7:0] LED_input, // display for password input
    output [3:0] anode_activation,
    output [6:0] LED_segment,
    output dp,
    input start,
    output tx
);

    reg mode; // 0: password set, 1: countdown
    wire [6:0] decrementer_segment;
    wire [3:0] decrementer_digit;
    wire decrementer_dp;
    wire times_up;
    reg [7:0] password_state;
    reg [31:0] countdown_timer;
    reg countdown_active;
    reg [1:0] mode_detector; // for detecting mode changes [prev_mode, mode]
    reg [7:0] uart_data;    // data to send via UART (ASCII '0' or '1')
    reg uart_start;         // pulse to start UART transmission
    wire uart_ready;        // UART ready signal

    assign LED_segment = decrementer_segment;
    assign anode_activation = decrementer_digit;
    assign dp = decrementer_dp;

    initial begin
        mode = 0;
        password_state = 8'b0000;
        countdown_timer = 0;
        countdown_active = 0;

    end

    Seven_segment_Decrementer uut (
        .clock(clock),
        .reset(reset),
        .countdown_active(countdown_active),
        .digit(decrementer_digit),
        .segment(decrementer_segment),
        .dp(decrementer_dp),
        .times_up(times_up)
    );

    // UART transmitter instance for sending mode changes
    uart_tx uart_inst (
        .clk(clock),
        .reset(reset),
        .data(uart_data),
        .start_tx(uart_start),
        .tx(tx),
        .ready(uart_ready)
    );

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            mode <= 0;
            password_state <= 8'b0000;
            countdown_timer <= 0;
            countdown_active <= 0;
            LED_input <= 8'b0000;
            LED_answer <= 8'b0000;
        end else begin
            if (mode == 0) begin
                password_state <= password_input; // update password state
                // Update LED to state
                LED_input <= password_input; 
                if (start) begin
                    mode <= 1; // toggle to countdown mode
                    countdown_timer <= 100_000_000; // example: 1 second at 100MHz
                    countdown_active <= 1;
                    LED_input <= 8'b0000; // clear input display
                end
            end 
            else if (mode == 1) begin
                    LED_answer <= password_answer;
                    if (password_answer == password_state) begin
                        // Password correct
                        countdown_active <= 0;
                        mode <= 0;
                        LED_answer <= 8'b0000; // clear answer display
                    end else if (times_up) begin
                        // Times up
                        countdown_active <= 0;
                        mode <= 0;
                        LED_answer <= 8'b0000; // clear answer display
                    end
                end
        end
    end

    // Detect mode changes and send via UART
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            mode_detector <= 2'b00;
            uart_start <= 1'b0;
        end else begin
            mode_detector[0] <= mode;
            mode_detector[1] <= mode_detector[0];
            if (mode_detector[1] != mode_detector[0]) begin
                uart_data <= mode_detector[0] ? 8'h31 : 8'h30; // Send ASCII '1' or '0'
                uart_start <= 1'b1;
            end else begin
                uart_start <= 1'b0;
            end
        end
    end

    // Removed password_leds assignment

endmodule
