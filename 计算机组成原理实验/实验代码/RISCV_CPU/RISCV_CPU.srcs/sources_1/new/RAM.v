`timescale 1ns / 1ps

module RAM(
    input clk,
    input we,
    input [2:0] mm,
    input [5:0] addr,
    output reg [31:0] rdata,
    input [31:0] raw_wdata
);
    parameter LB = 0, LH = 1, LW = 2, LBU = 3, LHU = 4;
    // 用寄存器堆模拟RAM
    reg [31:0] data[0:63];

    // 未处理读出的数据 / 实际写的数据
    wire [31:0] raw_data, wdata;

    assign raw_data = data[addr];

    always @(*) begin
        case(mm)
            LB:  rdata = {{24{raw_data[7]}}, raw_data[7:0]};
            LH:  rdata = {{16{raw_data[15]}}, raw_data[15:0]};
            LW:  rdata = raw_data;
            LBU: rdata = {24'b0, raw_data[7:0]};
            LHU: rdata = {16'b0, raw_data[15:0]};
            default: rdata = 32'h0;
        endcase
    end
    // mm = 5 => sb
    // mm = 6 -> sh
    // mm = 7 => sw
    assign wdata = ( 
        {24'b0, {8{mm[2] & ~mm[1] & mm[0]}}}  |
        {16'b0, {16{(&mm[2:1]) & ~mm[0]}}} |
        {32{(&mm[2:0])}}
    ) & raw_wdata;

    always @(posedge clk) begin
        if(we) begin
            data[addr] <= wdata;
        end
    end
    
    initial begin
        $monitor($time, ,
            "RAM->we => %b\t->mm => %b\t->addr => 0x%8h\t->raw_wdata => 0x%8h",
            we,
            mm,
            addr,
            raw_wdata
        );
    end
endmodule
