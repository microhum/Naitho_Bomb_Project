`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2025 10:06:54 PM
// Design Name: 
// Module Name: uart_tx
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

module uart_tx(
    input clk,
    input reset,
    input [7:0] data,
    input start_tx,
    output reg tx,
    output reg ready
);

    localparam CLK_FREQ = 100000000;
    localparam BAUD_RATE = 9600;
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    reg [13:0] bit_timer; // enough for 100MHz/9600 ≈ 10417
    reg [3:0] bit_index;
    reg [7:0] shift_reg;
    reg sending;

    initial begin
        tx = 1'b1; // idle high
        ready = 1'b1;
        sending = 1'b0;
        bit_timer = 0;
        bit_index = 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx <= 1'b1;
            ready <= 1'b1;
            sending <= 1'b0;
            bit_timer <= 0;
            bit_index <= 0;
        end else begin
            if (sending) begin
                ready <= 1'b0;
                if (bit_timer < BIT_PERIOD - 1) begin
                    bit_timer <= bit_timer + 1;
                end else begin
                    bit_timer <= 0;
                    case (bit_index)
                        0: tx <= 1'b0; // start bit
                        1: tx <= shift_reg[0];
                        2: tx <= shift_reg[1];
                        3: tx <= shift_reg[2];
                        4: tx <= shift_reg[3];
                        5: tx <= shift_reg[4];
                        6: tx <= shift_reg[5];
                        7: tx <= shift_reg[6];
                        8: tx <= shift_reg[7];
                        9: tx <= 1'b1; // stop bit
                        10: begin
                            sending <= 1'b0;
                            ready <= 1'b1;
                            bit_index <= 0;
                        end
                    endcase
                    bit_index <= bit_index + 1;
                end
            end else if (start_tx && ready) begin
                shift_reg <= data;
                sending <= 1'b1;
                bit_index <= 0;
                bit_timer <= 0;
                tx <= 1'b1; // keep high until start
            end
        end
    end

endmodule
