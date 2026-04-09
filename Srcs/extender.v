`timescale 1ns / 1ps  
module Extend (
    input  [24:0] instruction,
    input  [2:0]  ImmSrc,
    output reg [31:0] ImmExt
);
    // specified by the Control Unit (ImmSrc).
    always @(*) begin
        case (ImmSrc)
            // I-Type (for addi, lw, jalr)
            3'b000: ImmExt = { {20{instruction[24]}}, instruction[24:13] };

            // S-Type (for sw, sh, sb)
            3'b001: ImmExt = { {20{instruction[24]}}, instruction[24:18], instruction[4:0] };

            // B-Type (for beq, bne, etc.)
            3'b010: ImmExt = { {20{instruction[24]}}, instruction[0], instruction[23:18], instruction[4:1], 1'b0 };

            // J-Type (for jal)
            3'b011: ImmExt = { {11{instruction[24]}}, instruction[24], instruction[12:5], instruction[13], instruction[23:14], 1'b0 };

            // U-Type (for lui, auipc)
            3'b100: ImmExt = { instruction[24:5], 12'b0 };

            // Default case to prevent latches and provide a known safe value
            default: ImmExt = 32'h00000000;
        endcase
    end
endmodule
