`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/27 14:37:43
// Design Name: 
// Module Name: RegFiles
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


module RegFiles(
    input clk,
    input we,
    input [4:0] raddr1,
    output [31:0] rdata1,
    input [4:0] raddr2,
    output [31:0] rdata2,
    input [4:0] waddr,
    input [31:0] wdata
    );
    // 此寄存器堆共有32个32位寄存器
    // 可同时读两个寄存器的值
    // 支持写操作，we控制读/写
    
    // 此处只定义31个寄存器，原因是0号寄存器恒为0
    // 可直接硬编码，缩减成本。
    reg[31:0] regs[1:31];
    
    // 定义读操作电路
    assign rdata1 = (raddr1 == 5'b00000) ? 32'b0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'b00000) ? 32'b0 : regs[raddr2];
    
    // 定义写操作电路，下降沿开始写
    always @(negedge clk)
        if(we)
            if(waddr != 5'b00000)
                regs[waddr] <= wdata;

endmodule
