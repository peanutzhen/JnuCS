`timescale 1ns / 1ps
/*
 * 外设与RAM使用内存映射风格访问
 * addr=0x40时从switch外设读数据
 * addr=0x80时写数据至外设result
 * 其余均为访问RAM
 */
module IOMapping(
    // RAM
    input clk,
    input we,
    input [7:0] addr,
    input [31:0] wdata,
    input [2:0] mm,
    output [31:0] rdata,
    // IO
    input [5:0] switch,
    output reg [31:0] result
);
    wire [31:0] RAM_rdata, RAM_wdata;
    wire RAM_ce, RAM_we;
    assign RAM_ce = ~(|addr[7:6]);
    assign RAM_we = RAM_ce & we;
    RAM IOMapping_RAM(
        .clk(clk),
        .we(RAM_we),
        .mm(mm),
        .addr(addr[5:0]),
        .rdata(RAM_rdata),
        .raw_wdata(RAM_wdata)
    );

    assign rdata = addr[6] ? {26'h0, switch} : RAM_rdata;
    assign RAM_wdata = wdata;

    always @(posedge clk)
    begin
        if(we & addr[7])
            result <= wdata;
    end
endmodule
