`timescale 1ns / 1ps  
module Src_Reg (
    input  wire        clk,
    input  wire [31:0] rd1,
    input  wire [31:0] rd2,
    output reg  [31:0] A,
    output reg  [31:0] B
);
always @(posedge clk) begin
        A <= rd1;
        B <= rd2;
end
endmodule
