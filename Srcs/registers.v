`timescale 1ns / 1ps  
module Register_file(
    input clk,
    input reset,
    input RegWrite,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,
    input wire [31:0] Result,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    // This is the memory for our 32 registers.
    reg [31:0] Register[31:0];
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                Register[i] <= 32'b0;
            end
        end else if (RegWrite && (rd != 5'b0)) begin
            Register[rd] <= Result;
        end
    end

    assign rd1 = (rs1 == 5'b0) ? 32'b0 : Register[rs1];
    assign rd2 = (rs2 == 5'b0) ? 32'b0 : Register[rs2];

endmodule
