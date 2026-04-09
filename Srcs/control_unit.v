`timescale 1ns / 1ps    
 module Control_Unit ( 
 input  wire       clk,
 input  wire       reset,
 input  wire [6:0] opcode, 
 input  wire [2:0] funct3, 
 input  wire       LessThan,
 input  wire       funct7b5, 
 input  wire       zero, 
 // Outputs to other processor components 
 output wire [1:0] ResultSrc, 
 output wire       MemWrite, 
 output wire [1:0] ALUSrcB, 
 output wire [1:0] ALUSrcA, 
 output wire [2:0] ImmSrc, 
 output wire       en,
 output wire       RegWrite, 
 output wire [3:0] ALU_Ctrl, 
 output wire       PCWrite,
 output wire       AdrSrc,
 output wire       IRWrite
 ); 
 // Internal wire to connect the two decoders 
 wire [1:0] ALUOp; 
 wire opcode5; 
 assign opcode5 = opcode[5]; 
 // Instantiate the Main Decoder 
 main_FSM main_FSM ( 
 .clk        (clk),
 .reset      (reset),
 .opcode     (opcode), 
 .funct3     (funct3),
 .zero       (zero),
 .en         (en),
 .AdrSrc     (AdrSrc),
 .IRWrite    (IRWrite),
 .LessThan   (LessThan),
 .PCWrite    (PCWrite), 
 .ResultSrc  (ResultSrc), 
 .MemWrite   (MemWrite), 
 .ALUSrcA     (ALUSrcA), 
 .ALUSrcB    (ALUSrcB), 
 .ImmSrc     (ImmSrc), 
 .RegWrite   (RegWrite), 
 .ALUOp      (ALUOp)      // Connects to the ALU_Decoder 
 ); 
 // Instantiate the ALU Decoder 
 ALU_Decoder alu_dec ( 
 .ALUOp      (ALUOp),     // Input comes from the main_decoder 
 .opcode5    (opcode5), 
 .funct3     (funct3), 
 .opcode     (opcode),
 .funct7b5   (funct7b5), 
 .ALU_Ctrl   (ALU_Ctrl) 
 ); 
 endmodule   
 //---------------------------------------------------------------- 
 // MAIN FSM
 //---------------------------------------------------------------- 
 module main_FSM ( 
 input  wire       clk,
 input  wire       reset,
 input  wire [6:0] opcode, 
 input  wire       LessThan,
 input  wire       zero,
 input  wire [2:0] funct3,
 output reg        PCWrite, 
 output reg  [1:0] ResultSrc, 
 output reg        AdrSrc,
 output reg        IRWrite,
 output reg        en,
 output reg        MemWrite, 
 output reg  [1:0] ALUSrcA, 
 output reg  [1:0] ALUSrcB, 
 output reg  [2:0] ImmSrc, 
 output reg        RegWrite, 
 output reg  [1:0] ALUOp 
 ); 
 
 wire take_branch;
 
assign take_branch =  (
    (funct3 == 3'b000 && zero)   | // BEQ: take if zero
    (funct3 == 3'b001 && ~zero)  | // BNE: take if not zero
    (funct3 == 3'b100 && LessThan) | // BLT: take if LessThan
    (funct3 == 3'b101 && ~LessThan) | // BGE: take if not LessThan
    (funct3 == 3'b110 && LessThan) | // BLTU: take if LessThan (unsigned)
    (funct3 == 3'b111 && ~LessThan)   // BGEU: take if not LessThan (unsigned)
);

    //====================================================
    // STATE ENCODING 
    //====================================================

    parameter S0_FETCH    = 4'd0,
              S1_DECODE   = 4'd1,
              S2_MEMADR   = 4'd2,
              S3_MEMREAD  = 4'd3,
              S4_MEMWB    = 4'd4,
              S5_MEMWRITE = 4'd5,
              S6_EXEC_R   = 4'd6,
              S7_ALUWB    = 4'd7,
              S8_EXEC_I   = 4'd8,
              S9_JAL      = 4'd9,
              S10_BEQ     = 4'd10,
              S11_JALR    = 4'd11,
              S12_LUI     = 4'd12,
              S13_AUIPC   = 4'd13;
              
    reg [3:0] state, nextstate;

    //====================================================
    // STATE REGISTER
    //====================================================

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0_FETCH;
        else
            state <= nextstate;
    end

    //====================================================
    // NEXT STATE LOGIC
    //====================================================
    // Combinatorial logic for signals that only depend on the instruction itself
    always @(*) begin
       case (opcode)
             7'b0110011: ImmSrc = 3'b000; // R-type (No immediate used)
             7'b0010011: ImmSrc = 3'b000; // I-type ALU
             7'b0000011: ImmSrc = 3'b000; // I-type Load (lw)
             7'b0100011: ImmSrc = 3'b001; // S-type (sw)
             7'b1100011: ImmSrc = 3'b010; // B-type (beq)
             7'b1101111: ImmSrc = 3'b011; // J-type (jal)
             7'b1100111: ImmSrc = 3'b000; // I-type (jalr uses I-type encoding)
             7'b0110111: ImmSrc = 3'b100; // U-type (lui)
             7'b0010111: ImmSrc = 3'b100; // U-type (auipc)
             default:    ImmSrc = 3'b000;
          endcase
        end 

    always @(*) begin
        case (state)

            S0_FETCH:
                nextstate = S1_DECODE;

            S1_DECODE: begin
                case (opcode)
                    7'b0000011: nextstate = S2_MEMADR;   // lw
                    7'b0100011: nextstate = S2_MEMADR;   // sw
                    7'b0110011: nextstate = S6_EXEC_R;   // R-type
                    7'b0010011: nextstate = S8_EXEC_I;   // I-type ALU
                    7'b1101111: nextstate = S9_JAL;      // jal
                    7'b1100011: nextstate = S10_BEQ;     // beq
                    7'b1100111: nextstate = S11_JALR;     //JALR
                    7'b0110111: nextstate = S12_LUI;     //LUI
                    7'b0010111: nextstate = S13_AUIPC;   //AUIPC
                    default:    nextstate = S0_FETCH;
                    
                endcase
            end

            S2_MEMADR: begin
                if (opcode == 7'b0000011)
                    nextstate = S3_MEMREAD;     // lw
                else
                    nextstate = S5_MEMWRITE;    // sw
            end

            S3_MEMREAD:
                nextstate = S4_MEMWB;

            S4_MEMWB:
                nextstate = S0_FETCH;

            S5_MEMWRITE:
                nextstate = S0_FETCH;

            S6_EXEC_R:
                nextstate = S7_ALUWB;

            S7_ALUWB:
                nextstate = S0_FETCH;

            S8_EXEC_I:
                nextstate = S7_ALUWB;

            S9_JAL:  
                nextstate = S7_ALUWB;

            S10_BEQ:
                nextstate = S0_FETCH;
            
            S11_JALR:
                nextstate = S7_ALUWB;
            
            S12_LUI:
                nextstate = S7_ALUWB;
                
            S13_AUIPC:
                nextstate = S0_FETCH;

            default:
                nextstate = S0_FETCH;

        endcase
    end

    //====================================================
    // OUTPUT LOGIC (MOORE)
    //====================================================

    always @(*) begin

        // Default values
        IRWrite   = 1'b0;
        PCWrite  = 1'b0;
        en       = 1'b0;
        RegWrite  = 1'b0;
        MemWrite  = 1'b0;
        AdrSrc    = 1'b0;
        ALUSrcA   = 2'b00;
        ALUSrcB   = 2'b00;
        ResultSrc = 2'b00;
        ALUOp     = 2'b00;

        case (state)

            S0_FETCH: begin
                AdrSrc   = 1'b0;
                en       = 1'b1;
                IRWrite  =  1'b1;
                ALUSrcA  = 2'b00;
                ALUSrcB  = 2'b10;
                ALUOp     =  2'b00;
                ResultSrc = 2'b10;
                PCWrite =  1'b1;
            end

            S1_DECODE: begin
                en       = 1'b1;
                ALUSrcA = 2'b01; //jalr
                ALUSrcB =(opcode == 7'b1100111)?2'b10: 2'b01;
                ALUOp   =  2'b00;
            end

            S2_MEMADR: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b01;
                ALUOp   = 2'b00;
                en       = 1'b1;
            end

            S3_MEMREAD: begin
                ResultSrc = 2'b00;
                AdrSrc    = 1'b1;
                en       = 1'b1;
            end

            S4_MEMWB: begin
                ResultSrc = 2'b01;
                RegWrite  = 1'b1;
                en       = 1'b1;
            end

            S5_MEMWRITE: begin
                ResultSrc = 2'b00;
                AdrSrc    = 1'b1;
                MemWrite  = 1'b1;
                en       = 1'b1;
            end

            S6_EXEC_R: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ALUOp   = 2'b10;
                en       = 1'b1;
            end

            S8_EXEC_I: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b01;
                ALUOp   = 2'b10;
                en       = 1'b1;
            end

            S7_ALUWB: begin
                ResultSrc = 2'b00;
                RegWrite  = 1'b1;
                en       = 1'b1;
            end

            S9_JAL: begin
                ALUOp     = 2'b00;
                ResultSrc = 2'b00;
                PCWrite   = 1'b1;
                en       = 1'b1;
                
            end

            S10_BEQ: begin
                ALUSrcA   = 2'b10;
                ALUSrcB   = 2'b00;
                ALUOp     = 2'b01;
                ResultSrc = 2'b00;
                en       = 1'b1;
                PCWrite   =  take_branch ? 1'b1 : 1'b0 ;
            end
            
            S11_JALR: begin
                ALUOp     = 2'b11;
                ALUSrcA   = 2'b10;
                ALUSrcB   = 2'b01;
                ResultSrc = 2'b10;
                PCWrite   = 1'b1;
                en       = 1'b0;
            end
            
            S12_LUI: begin
                ALUSrcA   = 2'b10;
                ALUSrcB   = 2'b01;
                ALUOp     = 2'b11;
                ResultSrc = 2'b00;
                en       = 1'b1;
            end
            
            S13_AUIPC: begin
                ALUSrcA   = 2'b01;
                ALUSrcB   = 2'b01;
                ALUOp     = 2'b00;
                ResultSrc = 2'b00;
                RegWrite  = 1'b1;
                en       = 1'b1;
            end     

        endcase
    end

endmodule



 
 
 
 
 
 
 
 //---------------------------------------------------------------- 
 // ALU DECODER 
 //---------------------------------------------------------------- 
 
 module ALU_Decoder ( 
 input  wire [1:0] ALUOp, 
 input  wire    opcode5,
 input  wire  [6:0] opcode,     
 input  wire [2:0] funct3, 
 input  wire       funct7b5, 
 output reg  [3:0] ALU_Ctrl 
 ); 
 // ALU operation encodings 
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
 always @(*) begin 
 case (ALUOp) 
 2'b00: ALU_Ctrl =  ADD; // For LW/SW /JALRaddress calculation 
 2'b11: ALU_Ctrl = (opcode ==7'b1100111)? JALR: PASS; // For LUI 
 2'b01: begin // For Branch instructions 
 case (funct3) 
 3'b000: ALU_Ctrl = SUB;  // BEQ 
 3'b001: ALU_Ctrl = SUB;  // BNE 
 3'b100: ALU_Ctrl = SLT;  // BLT 
 3'b101: ALU_Ctrl = SLT;  // BGE 
 3'b110: ALU_Ctrl = SLTU; // BLTU 
 3'b111: ALU_Ctrl = SLTU; // BGEU 
 default: ALU_Ctrl = ADD; // Should not happen 
 endcase 
 end 
 2'b10: begin // For R-Type and I-Type instructions 
 case (funct3) 
 3'b000: ALU_Ctrl = (funct7b5 & opcode5) ? SUB : ADD; 
 3'b001: ALU_Ctrl = SLL; 
 3'b010: ALU_Ctrl = SLT; 
 3'b011: ALU_Ctrl = SLTU; 
 3'b100: ALU_Ctrl = XOR; 
 3'b101: ALU_Ctrl = (funct7b5) ? SRA : SRL; 
 3'b110: ALU_Ctrl = OR; 
 3'b111: ALU_Ctrl = AND; 
 default: ALU_Ctrl = ADD; // Should not happen 
 endcase 
 end 
 default: ALU_Ctrl = ADD; // Default case for safety 
 endcase 
 end 
 endmodule
