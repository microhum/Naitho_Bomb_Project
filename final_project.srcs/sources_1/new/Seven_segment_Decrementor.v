`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2019 03:50:21 PM
// Design Name: 
// Module Name: seven-segment-counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Seven_segment_Decrementer(
    input clock,
    input reset,
    input countdown_active,
    output reg [3:0] digit,
    output reg [6:0] segment,
    output reg dp,
    output reg times_up
);

    reg [26:0] ms_counter;
    reg [15:0] displayed_number;
    reg [3:0] LED_activation_set;
    reg [19:0] refresh_counter;
    reg countdown_was_active;

    wire ms_enable;
    wire [1:0] LED_activating_counter;
    
    always @(posedge clock or posedge reset)
    begin
        if (reset == 1)
            ms_counter <= 0;
        else if (countdown_active == 0)
            ms_counter <= 0;
        else begin
            if (ms_counter >= 99999)
            // Reset ms clock back to 0 if it overflowed
                 ms_counter <= 0;
            else
                ms_counter <= ms_counter + 1;
        end
    end

    assign ms_enable = (ms_counter == 99999)? 1 : 0;
    
    always @(posedge clock or posedge reset)
    begin
        if (reset == 1) begin
            displayed_number <= 0;
            countdown_was_active <= 0;
        end else begin
            countdown_was_active <= countdown_active;
            if (countdown_active == 0) begin
                displayed_number <= 0;
            end else begin
                // Start countdown from 40000 when entering mode 1
                if (!countdown_was_active && countdown_active) begin
                    displayed_number <= 40000;
                end else if (ms_enable == 1 && displayed_number > 0) begin
                    // Decrement only if above 0
                    displayed_number <= displayed_number - 1;
                end
            end
        end
    end
    
    always @(posedge clock or posedge reset)
    begin 
        if (reset == 1)
            refresh_counter <= 0;
            
        else 
            refresh_counter <= refresh_counter + 1;
    end 
    
    assign LED_activating_counter = refresh_counter[19:18];
    
    always @(*)

        case(LED_activating_counter)
        // Remember you can only drive one display at a time and there's 
        // no reason why there'd be a refresh period in which all displays
        // are off.
        
        // The position of each bit corresponds to which of the 4 displays is activated
        
        // Remember that for a 4-digit number in the form WXYZ
        // WXYZ / 1000 = W
        // (WXYZ % 1000) / 100 = X
        // ((WXYZ % 1000) % 100) / 10 = Y
        // WXYZ % 10 = Z
        2'b00: begin
            digit = 4'b0111;
            LED_activation_set = (displayed_number / 10) / 1000;
            dp = 1'b1;

              end
        2'b01: begin
            digit = 4'b1011;
            LED_activation_set = ((displayed_number / 10) % 1000) / 100;
            dp = 1'b0;

              end
        2'b10: begin
            digit = 4'b1101;
            LED_activation_set = (((displayed_number / 10) % 1000) % 100) / 10;
            dp = 1'b1;

                end
        2'b11: begin
            digit = 4'b1110;
            LED_activation_set = (displayed_number / 10) % 10;
            dp = 1'b1;
               end
        endcase

    
    always @(*)
    // Since this a common anode display, a "low" (0) signal illuminates a specific segment
    // For segment order, see: https://en.wikipedia.org/wiki/Seven-segment_display
        case(LED_activation_set)
        4'b0000: segment= 7'b0000001; // "0"     
        4'b0001: segment = 7'b1001111; // "1" 
        4'b0010: segment = 7'b0010010; // "2" 
        4'b0011: segment = 7'b0000110; // "3" 
        4'b0100: segment = 7'b1001100; // "4" 
        4'b0101: segment = 7'b0100100; // "5" 
        4'b0110: segment = 7'b0100000; // "6" 
        4'b0111: segment = 7'b0001111; // "7" 
        4'b1000: segment = 7'b0000000; // "8"     
        4'b1001: segment = 7'b0000100; // "9" 
        default: segment = 7'b0000001; // "0"
        endcase


    // Set times_up when countdown reaches 0
    always @(*) begin
        if (countdown_active && displayed_number == 0 && countdown_was_active) begin
            times_up = 1;
        end else begin
            times_up = 0;
        end
    end

 endmodule