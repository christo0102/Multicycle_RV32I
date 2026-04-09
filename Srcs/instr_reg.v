`timescale 1ns / 1ps  
module Instruction_Reg (
    input  wire        clk,
    input  wire        IRWrite,
    input  wire [31:0] pc_out,
    input  wire [31:0] Read_Data,
    output reg  [31:0] OldPC,
    output reg  [31:0] instruction
);
always @(posedge clk) begin
    if (IRWrite)
        instruction <= Read_Data;
        OldPC <= pc_out;
end
endmodule
