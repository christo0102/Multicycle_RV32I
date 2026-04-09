`timescale 1ns / 1ps  
module Load_Unit (
    input  wire [31:0] Read_Data,
    input  wire [1:0]  Address,
    input  wire [2:0]  funct3,
    output reg  [31:0] load_data
);

reg [7:0]  byte_data;
reg [15:0] half_data;

always @(*) begin
    byte_data = 8'b0;
    half_data = 16'b0;
    load_data = 32'b0;

    case (Address)
        2'b00: byte_data = Read_Data[7:0];
        2'b01: byte_data = Read_Data[15:8];
        2'b10: byte_data = Read_Data[23:16];
        2'b11: byte_data = Read_Data[31:24];
    endcase

    case (Address[1])
        1'b0: half_data = Read_Data[15:0];
        1'b1: half_data = Read_Data[31:16];
    endcase

    case (funct3)
        3'b000: load_data = {{24{byte_data[7]}}, byte_data}; 
        3'b001: load_data = {{16{half_data[15]}}, half_data};
        3'b010: load_data = Read_Data;
        3'b100: load_data = {24'b0, byte_data};
        3'b101: load_data = {16'b0, half_data};
        default: load_data = Read_Data;
    endcase
end

endmodule
