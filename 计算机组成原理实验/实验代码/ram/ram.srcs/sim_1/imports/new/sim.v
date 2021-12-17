`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/10 09:37:06
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
    reg chip_clk = 1'b0;
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg [3:0] code;
    // 模拟clk T = 160ns PC可以加6次1
    always
        #80 clk <= ~clk;
    // 保证set PC addr 0
    initial
        #105 rst <= ~rst;

    // 模拟芯片时钟脉冲
    always
        #5 chip_clk = ~chip_clk;

    // 模拟代码执行，先 s 再 l

    initial begin
        code = 4'b0101;     // sb4
        #10 code = 4'b0110; // sh8
        #10 code = 4'b0111; // sw0
        #10 code = 4'b0000; // lb0
        #10 code = 4'b0001; // lh0
        #10 code = 4'b0010; // lw0
        #10 code = 4'b0011; // lbu0
        #10 code = 4'b0100; // lhu0
        #10 code = 4'b1000; // lw4
        #10 code = 4'b1001; // lw8
    end

    wire [31:0] test;
    top my_top(
        .chip_clk(chip_clk),
        .clk(clk),
        .rst(rst),
        .code(code),
        .test(test)
    );
endmodule
