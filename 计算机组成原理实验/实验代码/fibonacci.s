.globl __start

.text

__start:
    ## 等待输入 N
    addi a0, zero, 5
    ecall

    ## 初始化变量
    addi s1, zero, 1    # f(1)
    addi s2, zero, 1    # f(2)
    addi s3, zero, 3    # 用于 N >= 3
    addi s4, zero, 2    # 用于控制迭代次数

    ## 算法核心
    # N == 1 或 2，则直接输出 1
    bge a0, s3, fibo    # N >= 3?
    blt a0, s1, error   # N < 1? 若小于1，则直接退出程序
    jal zero, output
    # 否则，进行迭代计算，s1和s2分别存储 f(n-2)/f(n-1)
fibo:
    add t0, zero, s1    # 保存 f(n-2)
    add s1, zero, s2    # f(n-2) = f(n-1)
    add s2, t0, s2      # f(n) = f(n-2) + f(n-1)
    addi a0, a0, -1     # N--
    bne a0, s4, fibo    # N != 2 continue
    ## 输出结果
output:
    addi a0, zero, 1
    add a1, zero, s2
    ecall
error:
    ## 程序结束
    addi a0, zero, 10
    ecall

