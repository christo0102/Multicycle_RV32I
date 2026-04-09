`timescale 1ns / 1ps

module Unified_Memory #(parameter DEPTH = 256)(
    input  wire        clk,
    input  wire        MemWrite,
    input  wire        AdrSrc,        // 0 = PC (instruction), 1 = ALUOut (data)
    input  wire [2:0]  funct3,        // needed for sb/sh/sw
    input  wire [9:0] Address,       // PC or ALUOut
    input  wire [31:0] Write_Data,
    output reg  [31:0] Read_Data
);

    reg [31:0] inst_memory [0:255];
    reg [31:0] data_memory [0:DEPTH-1];

    reg [31:0] mem_wdata;
    reg [3:0]  mem_be;

    wire [1:0] addr_lsb;
    wire [7:0] word_addr;

    assign addr_lsb  = Address[1:0];
    assign word_addr = Address[9:2];

    /* ---------------- READ ---------------- */
    always @(*) begin
        if (AdrSrc == 1'b0)
            Read_Data = inst_memory[word_addr];
        else
            Read_Data = data_memory[word_addr];
    end

    /* ---------------- STORE DECODE ---------------- */
    always @(*) begin
        mem_be    = 4'b0000;
        mem_wdata = data_memory[word_addr];

        case (funct3)
            3'b000: begin // SB
                case (addr_lsb)
                    2'b00: begin mem_be = 4'b0001; mem_wdata[7:0]   = Write_Data[7:0]; end
                    2'b01: begin mem_be = 4'b0010; mem_wdata[15:8]  = Write_Data[7:0]; end
                    2'b10: begin mem_be = 4'b0100; mem_wdata[23:16] = Write_Data[7:0]; end
                    2'b11: begin mem_be = 4'b1000; mem_wdata[31:24] = Write_Data[7:0]; end
                endcase
            end

            3'b001: begin // SH
                case (addr_lsb[1])
                    1'b0: begin mem_be = 4'b0011; mem_wdata[15:0]  = Write_Data[15:0]; end
                    1'b1: begin mem_be = 4'b1100; mem_wdata[31:16] = Write_Data[15:0]; end
                endcase
            end

            3'b010: begin // SW
                mem_be    = 4'b1111;
                mem_wdata = Write_Data;
            end
        endcase
    end

    /* ---------------- WRITE ---------------- */
    always @(posedge clk) begin
        if (MemWrite && AdrSrc) begin
            if (mem_be[0]) data_memory[word_addr][7:0]   <= mem_wdata[7:0];
            if (mem_be[1]) data_memory[word_addr][15:8]  <= mem_wdata[15:8];
            if (mem_be[2]) data_memory[word_addr][23:16] <= mem_wdata[23:16];
            if (mem_be[3]) data_memory[word_addr][31:24] <= mem_wdata[31:24];
        end
    end

endmodule
