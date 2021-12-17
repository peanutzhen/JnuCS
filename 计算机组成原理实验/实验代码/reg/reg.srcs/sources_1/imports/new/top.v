`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/13 19:35:17
// Design Name: 
// Module Name: top
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
    input clk,
    input rst,
    input [4:0] n,          // 2 < n < 32
    input Q,                // Q = 0 为 Fibo; Q = 1 为累加求和
    //output [15:0] test,   // 仿真检验结果用，实际用数码管显示结果
    output [6:0] a2g,       // 用于显示第an个数码管的a2g值
    output [3:0] an
    );
    // 保存模块运行结果
    // 注意：Q用于选择显示哪个问题的结果
    // 实际上top会将两个问题都进行求解
    wire[31:0] fibo;
    wire[31:0] sum;
    wire[15:0] result;
    // 实例化fibo控制器模块
    fibo my_fib(
        .clk(clk),
        .rst(rst),
        .n(n),
        .result(fibo)
    );
    // 实例化cumsum控制器模块
    cumsum my_cumsum(
        .clk(clk),
        .rst(rst),
        .n(n),
        .result(sum)
    );
    
    // 根据Q保存结果至result
    assign result = Q ? sum[15:0] : fibo[15:0];
    // 仿真用，写比特流请注释掉以及上面的test端口
    //assign test = Q ? sum[15:0] : fibo[15:0];

    // 降低时钟频率至合适，否则烧坏数码管
    wire clk_digit;
    divclk my_divclk(
        .clk(clk),
        .new_clk(clk_digit)
    );
    // 实例化七段数码管控制器模块，显示result（16进制）
    digit my_digit(
        .data(result),
        .clk(clk_digit),
        .a2g(a2g),
        .an(an)
    );
endmodule
