`timescale 1ns / 1ps    
module Mux_ALUSrcA( 
input  [31:0] pc_out, 
input  [31:0] OldPC, 
input  [31:0] A, 
input  [1:0]  ALUSrcA, 
output reg [31:0] SrcA
); 
always @(*) begin 
case (ALUSrcA) 
2'b00: SrcA = pc_out; 
2'b01: SrcA = OldPC; 
2'b10: SrcA = A; 
2'b11: SrcA = 32'b0; 
default: SrcA = 32'b0; 
endcase 
end 
endmodule
