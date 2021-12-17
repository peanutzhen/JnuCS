; multi-segment executable file template.

data segment
    prompt db "Size(Only odd num!) :$"
    num dw 0
    size db 0
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    ;get size       
    lea dx, prompt
    mov ah, 9
    int 21h

    mov ah, 1
    int 21h 
    
    mov size,al
    
    ;new line
    mov ah,2
    mov dl,0dH
    int 21h
    mov ah,2
    mov dl,0aH
    int 21h
    
    
    mov num,1  ;* nums
go:
    ;init
    mov al,size
    sub al,30h
    cbw
    
    ;space
    mov cx,ax
    sub cx,num
    sar cx,1 ; /2
    mov bx,cx ;store cx
    test cx,cx
    je prestar
    
space:
    mov ah,2
    mov dl,1Fh
    int 21h
    loop space
    
prestar:
    mov cx,num
star:
    mov ah,2
    mov dl,2Ah
    int 21h
    loop star
    
    mov cx,bx
    test cx,cx
    je ending
    
space2:
    mov ah,2
    mov dl,1Fh
    int 21h
    loop space2

    ;new line
    mov ah,2
    mov dl,0dH
    int 21h
    mov ah,2
    mov dl,0aH
    int 21h
    
    ;init
    mov al,size
    sub al,30h
    cbw
    
    add num,2
    cmp num,ax
    jg ending
    jng go
ending: 
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
