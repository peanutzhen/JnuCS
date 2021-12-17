`timescale 1ns / 1ps

module divclk(
    input clk,
    output new_clk
    );
    reg[18:0] data=19'b0;
    always @(posedge clk)
        data<=data+1'b1;
    // 100MHz·ÖÆµÖÁ3Hz
    assign new_clk = data[18];
endmodule
