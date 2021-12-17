data segment
    SCALE db 0ffh
    DIVD db 2
    RESULT db ?
    ILLEGAL db "Illegal sign value!",0dh,0ah,24h
data ends

stack segment stack
    dw 256 dup(0)
stack ends

code segment
    assume cs:code,ds:data,ss:stack
start:
    SIGN_DIV macro sign,scale,divd,result
        mov al,scale    ;;init ax with scale
        IF sign eq 0
            mov ah,0
            div divd   ;;unsigned div
        ENDIF
        IF sign eq 1
            cbw
            idiv divd  ;;signed div
        ENDIF
        IF sign gt 1
            mov dx,250 ;; illegal sign
        ENDIF
        mov result,al ;;store
    endm

    ; init ds,es
    mov ax,data
    mov ds,ax
    mov es,ax

    ;main proc
    SIGN_DIV 0,<SCALE>,<DIVD>,<RESULT>
    cmp dx,250
    je except
    jne ending

except:
    lea dx,ILLEGAL
    mov ah,9
    int 21h
ending:
    mov ax,4c00h
    int 21h
code ends

end start