`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/13 21:03:35
// Design Name: 
// Module Name: divclk
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


module divclk(
    input clk,
    output new_clk
    );
    reg[24:0] data=25'b0;
    always @(posedge clk)
        data<=data+1'b1;
    // 100MHz·ÖÆµÖÁ3Hz
    assign new_clk = data[18];
endmodule
