`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/09 20:11:50
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
    input chip_clk,     // P17 时钟脉冲100MHz
    input clk,          // S2 手动脉冲
    input rst,          // PC 复位端
    input [3:0] code,   // RAM_cntr 代码端
    input Q,            // 用于选择显示 ROM(=0)或RAM(=1)的数据
    //output [31:0] test, // 仿真测试输出端口(综合前请注释)
    output [6:0] a2g,   // 数码管a2g端
    output [3:0] an     // 选择数码管端
    );
    // rom 使用 IP core(Distributed LUT)
    // pc 应使用 clk
    // 七段数码管/RAM芯片 使用 chip_clk
    
    wire [31:0] pc_addr;
    // 实例化 PC
    pc my_pc(
        .rst(rst),
        .clk(clk),
        .addr(pc_addr)
    );
    
    wire [31:0] rom_data;
    // 实例化 ROM
    rom my_rom(
        .a(pc_addr[5:0]),
        .spo(rom_data)
    );
    
    wire [31:0] rdata;  // 保存读出数据
    // 实例化 RAM controller
    ram_cntr ins_ram_cntr(
        .clk(chip_clk),
        .code(code),
        .wdata(32'h123487ab),   // 直接写0x123487ab(实验要求)
        .rdata(rdata)
    );

    // 实例化分频器
    wire clk_3hz;
    divclk my_divclk(
        .clk(chip_clk),
        .new_clk(clk_3hz)
    );
    
    wire [15:0] disp_data;
    // Q = 0 显示 ROM 输出
    // Q = 1 显示 RAM 输出
    assign disp_data = Q ? 
                        {
                            rdata[31:28], 
                            rdata[23:20], 
                            rdata[15:12], 
                            rdata[7:4]
                        } : 
                        rom_data[15:0];
    // 实例化数码管
    digit my_digit(
        .data(disp_data),
        .clk(clk_3hz),
        .a2g(a2g),
        .an(an)
    );

    // 仅用于仿真查看ROM和RAM的数据
    // 综合前必须注释掉test端口和下面这行
    //assign test = {{rdata[31:28], rdata[23:20], rdata[15:12], rdata[7:4]}, rom_data[15:0]};
endmodule
