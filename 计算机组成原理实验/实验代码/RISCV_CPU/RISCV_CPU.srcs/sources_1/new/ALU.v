`timescale 1ns / 1ps

module ALU(
    input [31:0] a,
    input [31:0] b,
    input [3:0] op,
    output reg [31:0] f,
    output ZR               // ¡„±Í ∂Œª
);
    parameter ZERO = 4'h0, ADD = 4'h1, SUB = 4'h2,
              AND = 4'h3, OR = 4'h4, XOR = 4'h5,
              SLL = 4'h6, SRL = 4'h7, SRA = 4'h8,
              NE = 4'h9, LT = 4'hA, LTU = 4'hB,
              GE = 4'hC, GEU = 4'hD, SL12 = 4'hE,
              SL12ADD = 4'hF;

    always @(*)
    begin
        case(op)
            ZERO:   f = 32'b0;
            ADD:    f = a + b;
            SUB:    f = a - b;
            AND:    f = a & b;
            OR:     f = a | b;
            XOR:    f = a ^ b;
            SLL:    f = a << b[4:0];
            SRL:    f = a >> b[4:0];
            SRA:    f = $signed(a) >>> b[4:0];
            NE:     if(a != b) f = 32'h0; else f = 32'h1;
            LT:     if($signed(a) < $signed(b)) f = 32'h1; else f = 32'h0;
            LTU:    if(a < b) f = 32'h1; else f = 32'h0;
            GE:     if($signed(a) >= $signed(b)) f = 32'h1; else f = 32'h0;
            GEU:    if(a >= b) f = 32'h1; else f = 32'h0;
            SL12:    f = b << 12;
            SL12ADD: f = (b << 12) + a;
            default: f = 32'b0;
        endcase
    end
    
    assign ZR = ~(|f);

    initial begin
        $monitor($time,, "ALU->a => 0x%8h\t->b => 0x%8h\t->op => %4b", a, b, op);
        $monitor($time,, "ALU->f => 0x%8h", f);
    end
endmodule
