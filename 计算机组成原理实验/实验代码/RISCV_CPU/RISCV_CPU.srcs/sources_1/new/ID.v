`timescale 1ns / 1ps
/*
 * 指令译码器 ID：将 ins 根据RISC-V指令集规则
 * 分解成各个有用的字段，提供给 CU 模块。
 */
module ID(
    input [31:0] ins,       // 指令代码
    output [4:0] rs1,       // 原操作数寄存器1
    output [4:0] rs2,       // 原操作数寄存器2
    output [4:0] rd,        // 目的操作数寄存器
    output [6:0] opcode,    // 操作代码
    output [11:0] imm12,    // 12位立即数
    output [19:0] imm20,    // 20位立即数
    output [2:0] funct3,    // 3位 opcode 附加码
    output funct7           // 7位 opcode 附加码 (这里1位的原因稍后说明)
);
    assign opcode = ins[6:0];
    assign rs1 = ins[19:15];
    assign rs2 = ins[24:20];
    assign rd = ins[11:7];
    assign funct3 = ins[14:12];
    /* 
     * 虽然 funct7 为 7 位，但实际上我们要实现的
     * 37条指令里的 funct7 只有 funct7[6] 不同
     */
    assign funct7 = ins[30];

    /* 
     * 立即数的译码稍微复杂些，因为他的位置在 ins 里变动
     * 归纳得出五种不同的 imm 分布格式
     */ 
    wire fm1, fm2, fm3, fm4, fm5;
    
    // 格式1 所有I类指令和jalr opcode: 00x0011 和 1100111
    assign fm1 = (~ins[6] & ~ins[5] & ~ins[3] & ~ins[2] & ins[1] & ins[0]) | 
                   ((&ins[6:5]) & ~(|ins[4:3]) & (&ins[2:0]));
    // 格式2 所有B类指令 opcode: 1100011
    assign fm2 = (&ins[6:5]) & ~(|ins[4:2]) & (&ins[1:0]);
    // 格式3 所有S类指令 opcode:0100011
    assign fm3 = ~ins[6] & ins[5] & ~(|ins[4:2]) & (&ins[1:0]);
    // 格式4 jal opcode: 1101111
    assign fm4 = (&ins[6:5]) & ~ins[4] & (&ins[3:0]);
    // 格式5 所有U类指令 opcode: 0x10111
    assign fm5 = ~ins[6] & ins[4] & ~ins[3] & (&ins[2:0]);

    assign imm12 = ({12{fm1}} & ins[31:20]) |
                   ({12{fm2}} & {ins[31], ins[7], ins[30:25], ins[11:8]}) |
                   ({12{fm3}} & {ins[31:25], ins[11:7]});

    assign imm20 = ({20{fm5}} & ins[31:12]) |
                   ({20{fm4}} & {ins[31], ins[19:12], ins[20], ins[30:21]});
endmodule
