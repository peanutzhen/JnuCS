`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/13 19:16:28
// Design Name: 
// Module Name: fibo
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


module fibo(
    input clk,
    input rst,
    input [4:0] n,
    output [31:0] result
    );
    // 利用ALU实现Fibonacci，即Fibo是ALu的控制器
    
    // 变量声明
    reg[31:0] regA, regB;
    wire[31:0] ans;
    reg[4:0] count;
    // 实例化ALU模块
    alu myalu(.a(regA),.b(regB),.op(4'b0001),.f(ans),.c());
    // 每个clk上升沿改变寄存器A/B
    // 导致ans立即发生改变
    always @(posedge clk)
    begin
        // 从fibonacci(3)开始计算
        if(rst == 1'b1)
        begin
            regA <= 32'b1;
            regB <= 32'b1;
            count <= 5'b00011;
        end
        // 开始迭代计算
        else
        begin
            if(count < n)
            begin
                regA <= regB;
                regB <= ans;
                count <= count + 1'b1;
            end
        end
    end
    
    // 每当ans变化，result则会更新
    assign result = ans;
endmodule
