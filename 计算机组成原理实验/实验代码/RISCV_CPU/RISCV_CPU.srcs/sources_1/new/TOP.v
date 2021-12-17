`timescale 1ns / 1ps

module TOP(
    input clk,
    input rst,
    input [5:0] n,
    output [6:0] a2g_l,
    output [3:0] an_l,
    output [6:0] a2g_r,
    output [3:0] an_r
);
    // PC模块in/out 寄存器/线网
    reg [31:0] next_addr;
    wire [31:0] pc_addr;
    // ROM模块in/out 寄存器/线网
    wire [31:0] ins;
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [11:0] imm12;
    wire [19:0] imm20;
    wire [2:0] funct3;
    wire funct7;
    // CU模块in/out 寄存器/线网
    wire cond;
    wire reg_we, mem_we, use_imm, use_imm20, from_pc,
         from_mem, from_pc4;
    wire [1:0] pc_next_select;
    wire [2:0] mem_op;
    wire [3:0] alu_op;
    // RegStack模块in/out 寄存器/线网
    reg [31:0] reg_wdata;
    wire [31:0] reg_data1, reg_data2;
    // ALU模块in/out 寄存器/线网
    wire [31:0] a_in, b_in;
    wire [31:0] alu_f;
    // RAM模块out 寄存器/线网
    wire [31:0] mem_data;
    // Screen模块out 寄存器/线网
    wire [31:0] screen_data;

    // 下一次PC取值的四路选择器
    always @(*) begin
        case(pc_next_select)
            2'b00: next_addr = pc_addr + 32'h4;
            2'b01: next_addr = pc_addr + ({{20{imm12[11]}}, imm12[11:0]} << 1);
            2'b10: next_addr = pc_addr + ({{12{imm20[19]}}, imm20[19:0]} << 1);
            2'b11: next_addr = alu_f & -32'd2;
            default: next_addr = pc_addr + 32'h4;
        endcase
    end

    PC TOP_PC(
        .clk(clk),
        .rst(rst),
        .next(next_addr),
        .addr(pc_addr)
    );

    
    ROM TOP_ROM(
        .addr(pc_addr),
        .ins(ins)
    );

    ID TOP_ID(
        .ins(ins),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm12(imm12),
        .imm20(imm20),
        .funct3(funct3),
        .funct7(funct7)
    );

    
    CU TOP_CU(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .cond(cond),
        .reg_we(reg_we),
        .mem_we(mem_we),
        .mem_op(mem_op),
        .alu_op(alu_op),
        .use_imm(use_imm),
        .use_imm20(use_imm20),
        .from_pc(from_pc),
        .from_mem(from_mem),
        .from_pc4(from_pc4),
        .pc_next_select(pc_next_select)
    );

    // wdata 来源: PC+4 mem alu
    always @(*) begin
        if(from_pc4)
            reg_wdata = pc_addr + 4;
        else if(from_mem)
            reg_wdata = mem_data;
        else
            reg_wdata = alu_f;
    end
    
    RegStack TOP_RegStack(
        .clk(clk),
        .we(reg_we),
        .raddr1(rs1),
        .rdata1(reg_data1),
        .raddr2(rs2),
        .rdata2(reg_data2),
        .waddr(rd),
        .wdata(reg_wdata)
    );

    // a 端口数据来源: PC rs1
    // b 端口数据来源: rs2 imm12 imm20
    assign a_in = from_pc ? pc_addr : reg_data1;
    assign b_in = use_imm ? (use_imm20 ? {{12{imm20[19]}}, imm20[19:0]} : {{20{imm12[11]}}, imm12[11:0]}) : reg_data2;
    ALU TOP_ALU(
        .a(a_in),
        .b(b_in),
        .op(alu_op),
        .f(alu_f),
        .ZR(cond)
    );


    IOMapping TOP_IOMapping(
        .clk(clk),
        .we(mem_we),
        .mm(mem_op),
        .addr(alu_f[7:0]),
        .rdata(mem_data),
        .wdata(reg_data2),
        .switch(n),
        .result(screen_data)
    );

    Screen TOP_Screen(
        .clk(clk),
        .data(screen_data),
        .a2g_l(a2g_l),
        .an_l(an_l),
        .a2g_r(a2g_r),
        .an_r(an_r)
    );

    // 用来作分割线的
    always @(posedge clk)
        $display("                $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
endmodule
