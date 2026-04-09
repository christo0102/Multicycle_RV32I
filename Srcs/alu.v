`timescale 1ns / 1ps         
module ALU #( 
parameter LEN = 32 
)( 
input  wire [LEN-1:0] SrcA, 
input  wire [LEN-1:0] SrcB, 
input  wire [3:0]    ALU_Ctrl, 
output reg  [LEN-1:0] ALU_Result, 
output wire zero ,
output wire LessThan
); 
localparam ADD  = 4'b0000; 
localparam SUB  = 4'b0001; 
localparam AND  = 4'b0010; 
localparam OR   = 4'b0011; 
localparam XOR  = 4'b0100; 
localparam SLL  = 4'b0101; 
localparam SRL  = 4'b0110; 
localparam SRA  = 4'b0111; 
localparam SLT  = 4'b1000; 
localparam SLTU = 4'b1001; 
localparam PASS = 4'b1010; 
localparam JALR = 4'b1011;

wire signed_less = ($signed(SrcA) < $signed(SrcB));
wire unsigned_less = (SrcA < SrcB);

assign LessThan = (ALU_Ctrl == SLT) ? signed_less : (ALU_Ctrl == SLTU) ? unsigned_less : 1'b0;
always @(*) begin 
case (ALU_Ctrl) 
ADD:   ALU_Result = SrcA + SrcB; 
SUB:   ALU_Result = SrcA - SrcB; 
AND:   ALU_Result = SrcA & SrcB; 
OR:    ALU_Result = SrcA | SrcB; 
XOR:   ALU_Result = SrcA ^ SrcB; 
SLL:   ALU_Result = SrcA << SrcB[4:0]; 
SRL:   ALU_Result = SrcA >> SrcB[4:0]; 
// logical right 
SRA:   ALU_Result = ($signed(SrcA)) >>> SrcB[4:0]; // arithmetic right 
SLT:   ALU_Result = ($signed(SrcA) < $signed(SrcB)) ? {{LEN-1{1'b0}}, 1'b1} : 'b0; 
SLTU:  ALU_Result = (SrcA < SrcB) ? {{LEN-1{1'b0}}, 1'b1} : 'b0; 
PASS:  ALU_Result = SrcB; 
JALR: ALU_Result = (SrcA + SrcB) & 32'hFFFFFFFE ; 
default: ALU_Result = {LEN{1'b0}}; 
endcase 
end 
assign zero = (ALU_Result == {LEN{1'b0}}); 
endmodule
