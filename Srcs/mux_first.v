`timescale 1ns / 1ps  
module Mux_First( 
input  [31:0] Result, 
input  [31:0] pc_out, 
input         AdrSrc,
output [31:0] Address
);   
assign Address = (AdrSrc) ? Result : pc_out; 
endmodule



