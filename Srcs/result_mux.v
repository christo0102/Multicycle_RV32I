`timescale 1ns / 1ps    
module Mux_Result( 
input  [31:0] ALU_Output, 
input  [31:0] RData, 
input  [31:0] ALU_Result, 
input  [1:0]  ResultSrc, 
output reg [31:0] Result 
); 
always @(*) begin 
case (ResultSrc) 
2'b00: Result = ALU_Output; 
2'b01: Result = RData; 
2'b10: Result = ALU_Result; 
default: Result = 32'b0; 
endcase 
end 
endmodule
