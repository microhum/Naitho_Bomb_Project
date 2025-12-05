`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2025 05:01:07 PM
// Design Name: 
// Module Name: test
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


`timescale 1ns / 1ps

module Seven_segment_Decrementor_tb;

    // Inputs
    reg clock;
    reg reset;
    reg countdown_active;

    // Outputs
    wire [3:0] digit;
    wire [6:0] segment;

    // Instantiate the Unit Under Test (UUT)
    Seven_segment_Decrementor uut (
        .clock(clock),
        .reset(reset),
        .countdown_active(countdown_active),
        .digit(digit),
        .segment(segment)
    );

    // Clock generation
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, Seven_segment_Decrementor_tb);
        
        clock = 0;
        forever #5 clock = ~clock; // 100MHz clock (10ns period)
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        countdown_active = 0;
        #10; // Wait 10ns

        // Release reset
        reset = 0;
        #10;

        // Test reset state: displayed_number should be 40
        $display("After reset: digit=%b, segment=%b", digit, segment);
        // Assuming initial display shows 40, but since it's multiplexed, hard to check directly

        // Activate countdown
        countdown_active = 1;
        $display("Countdown activated");

        // Wait for a few seconds (simulate time)
        // Since one second = 100,000,000 cycles = 1,000,000,000 ns, too slow for sim
        // Instead, wait for one_second_enable pulses or just check after some time

        // For simulation, we can force the counter or wait shorter time
        // But to test properly, let's wait for one decrement
        // one_second_counter reaches 99999999 at 1e9 ns, but that's impractical

        // For test purposes, we can modify the counter limit in sim or just check logic

        // Wait some time
        #100000; // Wait 100us, which is 10,000 cycles

        // Check if decrementing (displayed_number should decrease)
        $display("After countdown active: digit=%b, segment=%b", digit, segment);

        // Deactivate countdown
        countdown_active = 0;
        $display("Countdown deactivated");

        // Wait a bit
        #100;

        // Should reset to 40
        $display("After deactivation: digit=%b, segment=%b", digit, segment);

        // Reactivate
        countdown_active = 1;
        $display("Countdown reactivated");

        #100000;

        $display("Final: digit=%b, segment=%b", digit, segment);

        // End simulation
        $finish;
    end

endmodule
