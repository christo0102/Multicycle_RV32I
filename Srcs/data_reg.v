module Data_Reg (
    input  wire        clk,
    input  wire [31:0] load_data,
    output reg  [31:0] RData
);
always @(posedge clk) 
        RData <= load_data;
endmodule
