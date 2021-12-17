`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/13 20:02:56
// Design Name: 
// Module Name: sim
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


module sim(

    );
    // Ê±ÖÓÐÅºÅ·ÂÕæ
    reg clk = 1'b0;
    always #10
        clk = ~clk;
        
    reg rst = 1'b1;
    reg[4:0] n = 5'b01010;
    reg Q = 1'b0;
    wire[15:0] result;
    
    top mytop(clk,rst,n,Q,result);
    
    initial
        #11 rst = 1'b0;
endmodule
