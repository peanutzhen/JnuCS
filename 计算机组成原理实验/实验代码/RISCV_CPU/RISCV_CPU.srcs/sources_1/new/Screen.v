`timescale 1ns / 1ps

// 基于七段数码管显示数字的屏幕模块
module Screen(
    input clk,
    input [31:0] data,
    output [6:0] a2g_l,
    output [3:0] an_l,
    output [6:0] a2g_r,
    output [3:0] an_r
    );
    wire clk_3hz;
    // 分频器 100MHz -> 3Hz
    divclk Screen_divclk(
        .clk(clk),
        .new_clk(clk_3hz)
    );
    // 左边四个数码管
    digit Screen_left_digits(
        .data(data[31:16]),
        .clk(clk_3hz),
        .a2g(a2g_l),
        .an(an_l)
    );
    // 右边四个数码管
    digit Screen_right_digits(
        .data(data[15:0]),
        .clk(clk_3hz),
        .a2g(a2g_r),
        .an(an_r)
    );

    initial
        $monitor($time,, "Screen->data => 0x%8h", data);
endmodule
