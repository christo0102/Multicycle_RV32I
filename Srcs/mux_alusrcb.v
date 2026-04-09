`timescale 1ns / 1ps    
module Mux_ALUSrcB( 
input  [31:0] B, 
input  [31:0] ImmExt, 
input  [1:0]  ALUSrcB, 
output reg [31:0] SrcB
); 
always @(*) begin 
case (ALUSrcB) 
2'b00: SrcB = B; 
2'b01: SrcB = ImmExt; 
2'b10: SrcB = 32'd4; 
2'b11: SrcB = 32'b0; 
default: SrcB = 32'b0; 
endcase 
end 
endmodule  
