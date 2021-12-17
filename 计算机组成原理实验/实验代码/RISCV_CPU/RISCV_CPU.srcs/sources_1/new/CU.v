`timescale 1ns / 1ps

/*
 *  根据译码结果生成各个部件的控制信号
 */
module CU(
    input [6:0] opcode,             // RISCV指令的opcode字段
    input [2:0] funct3,             // RISCV指令的funct3字段
    input funct7,                   // RISCV指令的funct7[6]比特
    input cond,                     // ALU的零标志位ZR
    output reg_we,                  // 寄存器堆写使能
    output mem_we,                  // IOMapping写使能
    output [2:0] mem_op,            // RAM操作码
    output [3:0] alu_op,            // ALU操作码
    output use_imm,                 // ALU的a端口使用立即数
    output use_imm20,               // ALU的立即数使用20位
    output from_pc,                 // ALU的a端口使用PC值
    output from_mem,                // 寄存器写数据来自内存
    output from_pc4,                // 寄存器写数据来自PC+4
    output [1:0] pc_next_select     // 下一PC值选择
);
    // 6种指令类型线网
    wire R_type, I_type, U_type, B_type, S_type, J_type;
    // funct3 信号线网
    wire f3_0, f3_1, f3_2, f3_3, f3_4, f3_5, f3_6, f3_7;
    // 37条指令信号线网
    wire _add, _sub, _and, _or, _xor, _sll, _srl, _sra,
        _slt, _sltu, _addi, _andi, _ori, _xori, _slti,
        _sltiu, _slli, _srli, _srai, _lw, _lb, _lbu,
        _lh, _lhu, _sw, _sb, _sh, _lui, _auipc, _jal,
        _jalr, _beq, _bne, _blt, _bltu, _bge, _bgeu;
    
    assign R_type = ~opcode[6] & (&opcode[5:4]) & ~(|opcode[3:2]) & (&opcode[1:0]);
    assign I_type = ~(|opcode[6:5]) & ~(|opcode[3:2]) & (&opcode[1:0]);
    assign U_type = ~opcode[6] & opcode[4] & ~opcode[3] & (&opcode[2:0]);
    assign B_type = (&opcode[6:5]) & ~(|opcode[4:2]) & (&opcode[1:0]);
    assign S_type = ~opcode[6] & opcode[5] & ~(|opcode[4:2]) & (&opcode[1:0]);
    assign J_type = (&opcode[6:5]) & ~opcode[4] & (&opcode[2:0]);
    
    assign f3_0 = ~(|funct3[2:0]);
    assign f3_1 = ~(|funct3[2:1]) & funct3[0];
    assign f3_2 = ~funct3[2] & funct3[1] & ~funct3[0];
    assign f3_3 = ~funct3[2] & (&funct3[1:0]);
    assign f3_4 = funct3[2] & ~(|funct3[1:0]);
    assign f3_5 = funct3[2] & ~funct3[1] & funct3[0];
    assign f3_6 = (&funct3[2:1]) & ~funct3[0];
    assign f3_7 = (&funct3[2:0]);

    assign _add = R_type & f3_0 & ~funct7;
    assign _sub = R_type & f3_0 &  funct7;
    assign _and = R_type & f3_7 & ~funct7;
    assign _or  = R_type & f3_6 & ~funct7;
    assign _xor = R_type & f3_4 & ~funct7;
    assign _sll = R_type & f3_1 & ~funct7;
    assign _srl = R_type & f3_5 & ~funct7;
    assign _sra = R_type & f3_5 &  funct7;
    assign _slt = R_type & f3_2 & ~funct7;
    assign _sltu = R_type & f3_3 & ~funct7;

    assign _addi = I_type & f3_0 & opcode[4];
    assign _andi = I_type & f3_7;
    assign _ori  = I_type & f3_6;
    assign _xori = I_type & f3_4 & opcode[4];
    assign _slti = I_type & f3_2 & opcode[4];
    assign _sltiu = I_type & f3_3;
    assign _slli = I_type & f3_1 & ~funct7 & opcode[4];
    assign _srli = I_type & f3_5 & ~funct7 & opcode[4];
    assign _srai = I_type & f3_5 & funct7 & opcode[4];

    assign _lw   = I_type & f3_2 & ~opcode[4];
    assign _lb   = I_type & f3_0 & ~opcode[4];
    assign _lbu  = I_type & f3_4 & ~opcode[4];
    assign _lh   = I_type & f3_1 & ~opcode[4];
    assign _lhu  = I_type & f3_5 & ~opcode[4];

    assign _sb = S_type & f3_0;
    assign _sh = S_type & f3_1;
    assign _sw = S_type & f3_2;

    assign _lui   = U_type &  opcode[5];
    assign _auipc = U_type & ~opcode[5];

    assign _jal  = J_type &  opcode[3];
    assign _jalr = J_type & ~opcode[3] & f3_0;

    assign _beq = B_type & f3_0;
    assign _bne = B_type & f3_1;
    assign _blt = B_type & f3_4;
    assign _bge = B_type & f3_5;
    assign _bltu = B_type & f3_6;
    assign _bgeu = B_type & f3_7;

    // R/I/U/J 类指令需要写寄存器堆
    assign reg_we = R_type | I_type | U_type | J_type;
    
    // S 类指令需要写(RAM+外设)
    assign mem_we = S_type;

    // 对应 mem_op 如下:
    // lb->0 lh->1 lw->2 lbu->3 lhu->4 sb->5 sh->6 sw->7
    assign mem_op[2] = _lhu | _sb  | _sh | _sw;
    assign mem_op[1] = _lw  | _lbu | _sh | _sw;
    assign mem_op[0] = _lh  | _lbu | _sb | _sw;
    
    // 根据ALU操作码的设计决定，我的设计就是这样
    assign alu_op[3] = _sra | _srai | _bne | _slt | _slti |
                        _bge | _sltu | _sltiu | _bgeu | _blt |
                        _bltu | _lui | _auipc;
    assign alu_op[2] = _or | _ori | _xor | _xori | _beq | _sll |
                        _slli | _srl | _srli | _blt | _bltu |
                        _lui | _auipc;
    assign alu_op[1] = _sub | _and | _andi | _sll | _slli |
                        _srl | _srli | _slt | _slti | _bge |
                        _sltu | _sltiu | _bgeu | _lui | _auipc;
    assign alu_op[0] = _add | _addi | _lb | _lh | _lw | _lbu |
                        _lhu | _sb | _sh | _sw | _jalr | _and |
                        _andi | _xor | _xori | _beq | _srl | 
                        _srli | _bne | _sltu | _sltiu | _bgeu |
                        _bltu | _auipc;
    
    assign use_imm = I_type | S_type | U_type | _jalr;

    assign use_imm20 = U_type;

    assign from_pc = _auipc;

    assign from_mem = _lb | _lh | _lw | _lbu | _lhu;
    
    assign from_pc4 = J_type;

    assign pc_next_select[1] = J_type;
    assign pc_next_select[0] = _jalr | (cond & B_type);

    initial begin
        $monitor($time,, "CU->cond => %b", cond);
        $monitor($time,, "CU->pc_next_select => %2b", pc_next_select);
    end
endmodule
