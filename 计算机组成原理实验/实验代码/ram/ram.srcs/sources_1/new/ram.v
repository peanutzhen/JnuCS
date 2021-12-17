`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/11 11:28:32
// Design Name: 
// Module Name: ram
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


module ram(
    input clk,
    input we,
    input [5:0] addr,
    output [31:0] rdata,
    input [31:0] wdata
    );
    // ÓÃ¼Ä´æÆ÷¶ÑÄ£ÄâRAM
    reg [31:0] data[0:63];
    // read
    assign rdata = data[addr];
    // write
    always @(posedge clk) begin
        if(we) begin
            data[addr] <= wdata;
        end
    end
endmodule
