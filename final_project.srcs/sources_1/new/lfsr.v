module lfsr(
    input clock,
    input reset,
    input enable,
    output reg [7:0] random_out
);

    reg [7:0] lfsr_reg;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            lfsr_reg <= 8'b00000001; // initial seed
            random_out <= 8'b00000000;
        end else if (enable) begin
            lfsr_reg <= {lfsr_reg[6:0], lfsr_reg[7] ^ lfsr_reg[5] ^ lfsr_reg[4] ^ lfsr_reg[3]}; // taps for 8-bit
            random_out <= lfsr_reg;
        end
    end

endmodule
