`timescale 1ns / 1ps

// 支持送数的程序计数器，上升沿触发，复位高电平有效
module PC(
    input clk,
    input rst,
    input [31:0] next,
    output reg [31:0] addr
);
    always @(posedge clk)
    begin
        if(rst)
            addr <= 32'b0;
        else
            addr <= next;
    end

    initial
        $monitor($time, , "PC->next => 0x%8h", next);
endmodule
