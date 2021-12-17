`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/13 20:15:12
// Design Name: 
// Module Name: cumsum
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


module cumsum(
    input clk,
    input rst,
    input [4:0] n,
    output [31:0] result
    );
    // 利用ALU实现累加求和，即cumsum是ALu的控制器

    // 变量声明
    reg[31:0] regA, regB;   // 输入端寄存器
    wire[31:0] ans;         // 保存Alu运行结果

    // 实例化ALU模块
    alu myalu(
        .a(regA),
        .b(regB),
        .op(4'b0001),
        .f(ans),
        .c()
    );
    // 每个clk上升沿改变寄存器A/B
    // 导致ans立即发生改变
    always @(posedge clk)
    begin
        // 从 1 + 2 开始算起
        if(rst == 1'b1)
        begin
            regA <= 32'b1;
            regB <= 32'b10;
        end
        // 现在不断递增regB，直到regB == n
        else
        begin
            if(regB < n)
            begin
                regA <= ans;
                regB <= regB + 1'b1;
            end
        end
    end
        
    // 每当ans变化，result则会更新
    assign result = ans;
endmodule
