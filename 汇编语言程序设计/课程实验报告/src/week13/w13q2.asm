data segment
    SUM dw 2 dup(0)
data ends

stack segment stack
    dw 256 dup(0)
stack ends

code segment
    assume cs:code,ds:data,ss:stack
start:
FINSUM macro X,Y,SUM
    mov dx,2
    if X gt Y ;;x+2y
        add SUM[0],X
        mov ax,Y
    else ;;2x+y
        add SUM[0],Y
        mov ax,X
    endif
    mul dx
    add SUM[0],ax
    adc SUM[1],dx
    endm

    mov ax,data
    mov ds,ax

    FINSUM 4,3,<SUM>

    mov ax,4c00h
    int 21h
code ends

end start