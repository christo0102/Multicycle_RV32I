`timescale 1ns / 1ps    
module PC( 
    input clk, 
    input reset,  
    input PCWrite,      
    input [31:0] pc_next, 
    output wire [31:0] pc_out
); 
    reg [31:0] pc_reg;
    always @(posedge clk) begin 
        if (reset) 
            pc_reg <= 32'h00000000;
        else if (PCWrite)
            pc_reg <= pc_next;
    end 
    assign pc_out = pc_reg;
endmodule
