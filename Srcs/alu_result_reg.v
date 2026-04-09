`timescale 1ns / 1ps   
module ALUResult_Reg (
    input  wire        clk,
    input  wire        reset,
    input  wire          en,
    input  wire [31:0] ALU_Result,
    output reg  [31:0] ALU_Output
);
always @(posedge clk or posedge reset) begin
    if (reset)
        ALU_Output <= 32'b0;
    else if(en)
        ALU_Output <= ALU_Result;
end
endmodule
