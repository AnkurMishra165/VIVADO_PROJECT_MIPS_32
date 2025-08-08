`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2025 11:45:32 PM
// Design Name: 
// Module Name: TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input clk1,
    input clk2,
    input reset,
    output [31:0] debug_pc
);

MIPS32_PIPE uut (
    .clk1(clk1),
    .clk2(clk2),
    .reset(reset),
    .PC(debug_pc)
);

endmodule

