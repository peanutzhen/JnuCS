`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/27 16:22:33
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
    reg clk = 1'b0;
    reg rst = 1'b1;
    // 生成时钟脉冲，周期为20ns
    always
        #10 clk = ~clk;
    // 初始化reset
    initial
        #15 rst = 1'b0;
    
    reg[4:0] n = 5'b01010;      // 待计算问题的n
    reg Q = 1'b0;               // Fibo为0，CumSum为1
    wire[15:0] result;          // 计算结果
    
    // 注意：此处要将top中的test端口去掉注释！
    // 原因是实际写到板子上不需要这结果，但不分配给他输出
    // 又无法生成比特流。
    top mytop(clk,rst,n,Q,result);
    
     
endmodule
