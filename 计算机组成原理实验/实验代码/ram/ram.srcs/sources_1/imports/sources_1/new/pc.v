`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/10 09:17:30
// Design Name: 
// Module Name: pc
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


module pc(
    input rst,
    input clk,
    output reg [31:0] addr
    );
    always @(posedge clk)
    begin
        if(rst == 1'b0)
            addr <= 32'b0;
        else
            addr <= addr + 1;
    end
endmodule
