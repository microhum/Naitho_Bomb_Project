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
    input random, // random button input
    output tx
);

    reg mode; // 0: password set, 1: countdown
    reg prev_mode; // previous mode for edge detection
    wire [6:0] decrementer_segment;
    wire [3:0] decrementer_digit;
    wire decrementer_dp;
    wire times_up;
    reg [7:0] password_state;
    reg [31:0] countdown_timer;
    reg countdown_active;
    reg [7:0] uart_data;    // data to send via UART (ASCII '0' or '1', '2', '3')
    reg uart_start;         // pulse to start UART transmission
    wire uart_ready;        // UART ready signal
    reg [1:0] mode_detector;
    reg prev_times_up;
    reg prev_password_match;
    reg random_mode;
    reg prev_random;
    wire [7:0] random_out;

    assign LED_segment = decrementer_segment;
    assign anode_activation = decrementer_digit;
    assign dp = decrementer_dp;

    initial begin
        mode = 0;
        prev_mode = 0;
        password_state = 8'b0000;
        countdown_timer = 0;
        countdown_active = 0;
        mode_detector = 2'b00;
        prev_times_up = 0;
        prev_password_match = 0;
        uart_start = 0;
        uart_data = 0;
        random_mode = 0;
        prev_random = 0;

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

    // LFSR for random password generation
    lfsr lfsr_inst (
        .clock(clock),
        .reset(reset),
        .enable(1'b1),
        .random_out(random_out)
    );

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            mode <= 0;
            prev_mode <= 0;
            password_state <= 8'b0000;
            countdown_timer <= 0;
            countdown_active <= 0;
            LED_input <= 8'b0000;
            LED_answer <= 8'b0000;
            random_mode <= 0;
            prev_random <= 0;
        end else begin
            // Detect random button press
            prev_random <= random;
            if (!prev_random && random) begin
                random_mode <= 1;
                password_state <= random_out;
                LED_input <= random_out;
            end

            if (mode == 0) begin
                if (!random_mode) begin
                    password_state <= password_input; // update password state
                    // Update LED to state
                    LED_input <= password_input;
                end
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
                        random_mode <= 0;
                        LED_answer <= 8'b0000; // clear answer display
                    end else if (times_up) begin
                        // Times up
                        countdown_active <= 0;
                        mode <= 0;
                        random_mode <= 0;
                        LED_answer <= 8'b0000; // clear answer display
                    end
                end
            prev_mode <= mode;
        end
    end

    // Send UART messages for events: 0 for ticking, 1 for password match, 2 for times up, 3 for reset
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            mode_detector <= 2'b00;
            prev_times_up <= 1'b0;
            prev_password_match <= 1'b0;
            uart_data <= 8'h33; // '3' for reset
            uart_start <= 1'b1;
        end else begin
            prev_times_up <= times_up;
            prev_password_match <= (password_answer == password_state) && (mode == 1);
            mode_detector[0] <= mode;
            mode_detector[1] <= mode_detector[0];

            uart_start <= 1'b0; // default

            // Send '2' on times up (rising edge)
            if (!prev_times_up && times_up) begin
                uart_data <= 8'h32; // '2'
                uart_start <= 1'b1;
            end
            // Send '1' on password match (rising edge)
            else if (!prev_password_match && (password_answer == password_state) && (mode == 1)) begin
                uart_data <= 8'h31; // '1'
                uart_start <= 1'b1;
            end
            // Send '0' on mode change to 1 (ticking starts)
            else if (mode_detector[1] != mode_detector[0] && mode_detector[0] == 1'b1) begin
                uart_data <= 8'h30; // '0'
                uart_start <= 1'b1;
            end
        end
    end

endmodule
