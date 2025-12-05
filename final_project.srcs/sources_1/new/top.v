module top(
    input clock,
    input reset,
    input [3:0] password_answer, // password answer
    input [3:0] password_input, // password input
    output reg [3:0] LED_answer, // display for password answer
    output reg [3:0] LED_input, // display for password input
    output [3:0] anode_activation,
    output [6:0] LED_segment,
    input start
);

    reg mode; // 0: password set, 1: countdown
    wire [6:0] decrementer_segment;
    wire [3:0] decrementer_digit;
    reg [3:0] password_state;
    reg [31:0] countdown_timer;
    reg countdown_active;

    assign LED_segment = decrementer_segment;
    assign anode_activation = decrementer_digit; 

    initial begin
        mode = 0;
        password_state = 4'b0000;
        countdown_timer = 0;
        countdown_active = 0;
       
    end

    Seven_segment_Decrementer uut (
        .clock(clock),
        .reset(reset),
        .countdown_active(countdown_active),
        .digit(decrementer_digit),
        .segment(decrementer_segment)
    );

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            mode <= 0;
            password_state <= 4'b0000;
            countdown_timer <= 0;
            countdown_active <= 0;
            LED_input <= 4'b0000;
            LED_answer <= 4'b0000;
        end else begin
            if (mode == 0) begin
                password_state <= password_input; // update password state
                // Update LED to state
                LED_input <= password_input; 
                if (start) begin
                    mode <= 1; // toggle to countdown mode
                    countdown_timer <= 100_000_000; // example: 1 second at 100MHz
                    countdown_active <= 1;
                    LED_input <= 4'b0000; // clear input display
                end
            end 
            else if (mode == 1) begin
                    LED_answer <= password_answer;
                    if (password_answer == password_state) begin
                        // Password correct
                        countdown_active <= 0;
                        mode <= 0;
                        // Display "DONE" on 7-segment
                        LED_answer <= 4'b0000; // clear answer display
                    end

                end 
            end
        end
   

    // Removed password_leds assignment

endmodule