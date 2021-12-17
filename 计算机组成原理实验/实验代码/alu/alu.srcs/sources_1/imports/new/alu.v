`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/13 18:45:01
// Design Name: 
// Module Name: alu
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


module alu(
    input [31:0] a,
    input [31:0] b,
    input [3:0] op,
    output reg [31:0] f,
    output c
    );
    
    always @(*)
    begin
        case(op)
            4'b0000: f = 32'b0;
            4'b0001: f = a + b;
            4'b0010: f = a - b;
            4'b0011: f = a & b;
            4'b0100: f = a | b;
            4'b0101: f = a ^ b;
            default: f = 32'b0;
        endcase
    end
    
    assign c = ~(|f);
endmodule
