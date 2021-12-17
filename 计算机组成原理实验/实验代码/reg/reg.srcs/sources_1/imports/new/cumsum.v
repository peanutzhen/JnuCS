`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/13 19:16:28
// Design Name: 
// Module Name: fibo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cumsum(
    input clk,
    input rst,
    input [4:0] n,
    output [31:0] result
    );
    // 利用寄存器堆和ALU实现 累加求和
    // 即cumsum是RegFiles/ALu的控制器
    // 控制器采用有限状态机实现
    
    // 变量声明
    reg [4:0] read_addr[1:2];       // 读端口2个地址寄存器
    wire [31:0] data[1:2], ans;     // ALU的三端
    reg we;                         // 写使能端
    reg [4:0] write_addr;           // 写端口地址寄存器
    reg [31:0] write_data;          // 写端口数据寄存器
    reg [1:0] status;               // 状态表示
    
    reg [4:0] count;                // 用于何时停止计算
    // 实例化RegFiles模块
    RegFiles reg_inst1(
        .clk(clk),
        .we(we),
        .raddr1(read_addr[1]),
        .rdata1(data[1]),
        .raddr2(read_addr[2]),
        .rdata2(data[2]),
        .waddr(write_addr),
        .wdata(write_data)
    );
    // 实例化ALU模块
    ALU alu_inst1(
        .a(data[1]),
        .b(data[2]),
        .f(ans),
        .op(4'b0001)    // 0x1 使ALU进行加运算
    );
    // 有 限 状 态 机
    // S0/S1 分别完成regs[1]/regs[2]写1/2操作，并使data[1]/data[2]
    // 为他俩。S2将ALU计算结果写至regs[1]。S3递增regs[2]。
    // 跳转流程：S0 -> S1 -> S2 <--> S3
    // 上升沿切换状态（注意，控制器不要和寄存器堆写操作同时使用
    // 上升沿，否则出现竞争，使得状态切换后，参数没能来得及赋值
    // 完成，而寄存器已经开始写，就会得到错误结果！
    always @(posedge clk)
    begin
        // 初始化状态，用于重新计算/刷新
        if(rst == 1'b1)
        begin
            count <= 5'b00010;
            status <= 2'b00;
        end
        // 进入有限状态机
        else
        begin
            case(status)
                // 状态0：regs[1] <= 1
                2'b00:
                    begin
                        we <= 1'b1;
                        write_addr <= 5'b00001;
                        write_data <= 32'b1;
                        status <= 2'b01;
                    end
                // 状态1：regs[2] <= 2 且 初始化read_addr
                2'b01:
                    begin
                        we <= 1'b1;
                        write_addr <= 5'b00010;
                        write_data <= 32'b10;
                        read_addr[1] <= 5'b00001;
                        read_addr[2] <= 5'b00010;
                        status <= 2'b10;
                    end
                // 状态2：ALU计算 并 写答案至read_addr[1]寄存器
                2'b10:
                    begin
                        we <= 1'b1;
                        write_addr <= read_addr[1];
                        write_data <= ans;
                        count <= count + 1;
                        status <= 2'b11;
                    end
                // 状态3：递增read_addr[2]寄存器的值
                2'b11:
                    begin
                        if(count <= n) begin
                            we <= 1'b1;
                            write_addr <= read_addr[2];
                            write_data <= data[2] + 1;
                            status <= 2'b10;
                        end
                    end
                default: status <= 2'b00;
            endcase
        end
    end
    // 众所周知，ALU最后的read_addr[1]的寄存器即为答案
    assign result = data[1];
    //initial
        //$monitor($time,,"status=%d reg1=%x reg2=%x",status,data[1],data[2]);
endmodule
