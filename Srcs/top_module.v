`timescale 1ns / 1ps

module RISC_V_Multicycle (
    input wire clk,
    input wire reset
);

    wire [31:0] pc_out;
   
    wire [31:0] Address;
    wire [31:0] Read_Data;
    wire [31:0] instruction;
    wire [31:0] OldPC;
    wire [31:0] RData;
    wire [31:0] rd1;
    wire  [31:0] rd2;
    wire  [31:0] A; 
    wire  [31:0] B;
    wire [31:0] ImmExt;
    wire [31:0] SrcA; 
    wire [31:0] SrcB;
    wire [31:0] ALU_Result;
    wire [31:0] ALU_Output;
    wire [31:0] Result;
    wire [31:0] load_data;
    
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire funct7b5     = instruction[30];
    wire [1:0] ResultSrc;
    wire [1:0] ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [2:0] ImmSrc;
    wire [3:0] ALU_Ctrl;
    wire RegWrite;
    wire  MemWrite;
    wire PCWrite;
    wire  AdrSrc; 
    wire IRWrite; 
    wire zero;
    wire LessThan;
    wire en;

    Control_Unit CU (
        .clk(clk),
        .reset(reset),
        .en(en),
        .opcode(opcode),
        .funct3(funct3),
        .LessThan(LessThan),
        .funct7b5(funct7b5),
        .zero(zero),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUSrcB(ALUSrcB),
        .ALUSrcA(ALUSrcA),
        .ImmSrc(ImmSrc),
        .RegWrite(RegWrite),
        .ALU_Ctrl(ALU_Ctrl),
        .PCWrite(PCWrite),
        .AdrSrc(AdrSrc),
        .IRWrite(IRWrite)
    );

    PC pc_inst (
        .clk(clk),
        .reset(reset),
        .PCWrite(PCWrite),
        .pc_next(Result), 
        .pc_out(pc_out)
    );

    Mux_First addr_mux (
        .Result(Result),
        .pc_out(pc_out),
        .AdrSrc(AdrSrc),
        .Address(Address)
    );

    Unified_Memory memory (
        .clk(clk),
        .MemWrite(MemWrite),
        .AdrSrc(AdrSrc),
        .funct3(funct3),
        .Address(Address[9:0]),
        .Write_Data(B), 
        .Read_Data(Read_Data)
    );

    Instruction_Reg ir (
        .clk(clk),
        .IRWrite(IRWrite),
        .pc_out(pc_out),
        .Read_Data(Read_Data),
        .OldPC(OldPC),
        .instruction(instruction)
    );

    Data_Reg dr (
        .clk(clk),
        .load_data(Read_Data),
        .RData(RData)
    );

    Register_file rf (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rs3(instruction[11:7]),
        .Result(Result),
        .rd1(rd1),
        .rd2(rd2)
    );

    Src_Reg ab_regs (
        .clk(clk),
        .rd1(rd1),
        .rd2(rd2),
        .A(A),
        .B(B)
    );

    Extend ext (
        .instruction(instruction[31:7]), 
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );

    Mux_ALUSrcA mux_A (
        .pc_out(pc_out),
        .OldPC(OldPC),
        .A(A),
        .ALUSrcA(ALUSrcA),
        .SrcA(SrcA)
    );

    Mux_ALUSrcB mux_B (
        .B(B),
        .ImmExt(ImmExt),
        .ALUSrcB(ALUSrcB),
        .SrcB(SrcB)
    );

    ALU alu_inst (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALU_Ctrl(ALU_Ctrl),
        .ALU_Result(ALU_Result),
        .zero(zero),
        .LessThan(LessThan)
    );

    ALUResult_Reg alu_reg (
        .clk(clk),
        .reset(reset),
        .en(en),
        .ALU_Result(ALU_Result),
        .ALU_Output(ALU_Output)
    );

    Load_Unit load_unit (
        .Read_Data(RData),
        .Address(Address[1:0]),
        .funct3(funct3),
        .load_data(load_data)
    );

    Mux_Result res_mux (
        .ALU_Output(ALU_Output),
        .RData(load_data),
        .ALU_Result(ALU_Result),
        .ResultSrc(ResultSrc),
        .Result(Result)
    );

endmodule
