data segment
    OPERAND db 23h,1,1,1,1,1
    RESULT db ?
data ends

stack segment stack
    dw 256 dup(0)
stack ends

code segment
    assume cs:code,ds:data,ss:stack
start:
BIN_SUB macro operand,count,result
    mov si,0
    mov al,operand[si]
    rept count
        inc si
        sub al,operand[si]
    endm
    mov result,al
endm

    mov ax,data
    mov ds,ax

    BIN_SUB <OPERAND>,6,<RESULT>
    mov ax,4c00h
    int 21h
code ends

end start