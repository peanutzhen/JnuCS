`timescale 1ns / 1ps

module ROM(
    input [31:0] addr,
    output reg [31:0] ins
);
    // 综合前请设置为斐波那契程序
    always @(*)
    begin
        case (addr[31:2])
            // R-type 测试程序
             /*
            30'h0: ins = 32'hffe00093; // addi x1, x0, -2
            30'h1: ins = 32'h00600113; // addi x2, x0, 6
            30'h2: ins = 32'h002081b3; // add x3, x1, x2
            30'h3: ins = 32'h40208233; // sub x4, x1, x2
            30'h4: ins = 32'h0020f2b3; // and x5, x1, x2
            30'h5: ins = 32'h0020e333; // or  x6, x1, x2
            30'h6: ins = 32'h0020c3b3; // xor x7, x1, x2
            30'h7: ins = 32'h00209433; // sll x8, x1, x2
            30'h8: ins = 32'h0020d4b3; // srl x9, x1, x2
            30'h9: ins = 32'h4020d533; // sra x10, x1, x2
            30'ha: ins = 32'h0020a5b3; // slt x11, x1, x2
            30'hb: ins = 32'h00112633; // slt x12, x2, x1
            30'hc: ins = 32'h001136b3; // sltu x13, x2, x1
            30'hd: ins = 32'h0020b733; // sltu x14, x1, x2
             */

            // I-type 测试程序
             /*
            30'h0: ins = 32'h123450b7; // lui x1, 0x12345
            30'h1: ins = 32'h7890e093; // ori x1, x1, 0x789
            30'h2: ins = 32'hffb00113; // addi x2, x0, -5
            30'h3: ins = 32'h00104193; // xori x3, x0, 1
            30'h4: ins = 32'h0090f213; // andi x4, x1, 9
            30'h5: ins = 32'h00109293; // slli x5, x1, 1
            30'h6: ins = 32'h0010d313; // srli x6, x1, 1
            30'h7: ins = 32'h40115393; // srai x7, x2, 1
            30'h8: ins = 32'h00312413; // slti x8, x2, 3
            30'h9: ins = 32'h0090a493; // slti x9, x1, 9
            30'ha: ins = 32'h00313b13; // sltiu x22, x2, 3
            30'hb: ins = 32'h0051b593; // sltiu x11, x3, 5
            30'hc: ins = 32'h00100503; // lb   x10, 1(x0)
            30'hd: ins = 32'h00201583; // lh   x11, 2(x0)
            30'he: ins = 32'h00402603; // lw   x12, 4(x0)
            30'hf: ins = 32'h00804683; // lbu  x13, 8(x0)
            30'h10: ins = 32'h01005703; // lhu  x14, 16(x0)
             */
            
            // S-type 测试程序
             /*
            30'h0: ins = 32'h124380b7; // lui x1, 0x12438
            30'h1: ins = 32'h7ab0e093; // ori x1, x1, 0x7ab
            30'h2: ins = 32'h00100023; // sb x1,0(x0)
            30'h3: ins = 32'h001010a3; // sh x1,1(x0)
            30'h4: ins = 32'h00102123; // sw x1,2(x0)
             */

             /* B-type 测试程序
            30'h0: ins = 32'h00100093; // addi x1, x0, 1
            30'h1: ins = 32'h7e100fe3; // beq x0, x1, 0xfff
            30'h2: ins = 32'h00000463; // beq x0, x0, 8
            30'h3: ins = 32'h00000033; // add x0, x0, x0
            30'h4: ins = 32'h7e001fe3; // bne x0, x0, 0xfff
            30'h5: ins = 32'h00101463; // bne x0, x1, 8
            30'h6: ins = 32'h00000033; // add x0, x0, x0
            30'h7: ins = 32'h7e00cfe3; // blt x1, x0, 0xfff
            30'h8: ins = 32'h7e00efe3; // bltu x1, x0, 0xfff
            30'h9: ins = 32'h7e105fe3; // bge x0, x1, 0xfff
            30'ha: ins = 32'h7e107fe3; // bgeu x0, x1, 0xfff
             */

            // U-type 测试程序
             /*
            30'h0: ins = 32'h123450b7; // lui x1, 0x12345
            30'h1: ins = 32'h10000117; // auipc x2, 0x10000
             */

            // J-type 测试程序
             /*
            30'h0: ins = 32'h0100006f; // jal x0, 0x10
            30'h1: ins = 32'h001000b3; // add x1, x0, x1
            30'h2: ins = 32'h001000b3; // add x1, x0, x1
            30'h3: ins = 32'h001000b3; // add x1, x0, x1
            30'h4: ins = 32'h01000067; // jalr x0, x0, 0x10
            30'h5: ins = 32'h001000b3; // add x1, x0, x1
            30'h6: ins = 32'h001000b3; // add x1, x0, x1
            30'h7: ins = 32'h001000b3; // add x1, x0, x1
             */

            // 计算斐波那契数程序: 由 Jupiter 汇编实验一得来
            // /*
            30'h0: ins = 32'h04002503; // lw a0, 0x40(x0) 外设switch读n
            30'h1: ins = 32'h00100493; // addi s1, zero, 1
            30'h2: ins = 32'h00100913; // addi s2, zero, 1
            30'h3: ins = 32'h00300993; // addi s3, zero, 3
            30'h4: ins = 32'h00200a13; // addi s4, zero, 2
            30'h5: ins = 32'h01355463; // bge a0, s3, fibo
            30'h6: ins = 32'h0180006f; // jal zero, output
            30'h7: ins = 32'h009002b3; // fibo: add t0, zero, s1
            30'h8: ins = 32'h012004b3; // add s1, zero, s2
            30'h9: ins = 32'h01228933; // add s2, t0, s2
            30'ha: ins = 32'hfff50513; // addi a0, a0, -1
            30'hb: ins = 32'hff4518e3; // bne a0, s4, fibo
            30'hc: ins = 32'h09202023; // output: sw s2, 0x80(x0) 输出至Screen
            // */
            default: ins = 32'h0;
        endcase
    end

    initial begin
        $monitor($time, , "ROM->addr => 0x%8h", addr);
        $monitor($time, , "ROM->ins  => 0x%8h", ins);
    end
endmodule
