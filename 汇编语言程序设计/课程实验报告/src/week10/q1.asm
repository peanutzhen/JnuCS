; multi-segment executable file template.

data segment
    prompt db "Output is $"
    output dw 0
    DIVIDER db 10
    pkey db "press any key...$"
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

init:
    mov ax,0
    mov dx,0
sum:
    inc ax ;ax++ 
    mov bx,0
    mov cx,ax
    inc cx
lp:
    add bx,ax ;computing...
    loop lp
handle:
    add dx,bx ;adding...
    cmp bx,200
    jg ending ;>200 end
    jng sum ;<=200 continue     
ending:
    lea bx,output
    mov [bx],dx  ;transport to memory
    lea dx,prompt
    mov ah,9
    int 21h
    
    ;preparing output
    mov ax,output
    mov cx,0
prepare:
    idiv DIVIDER ;³ı10
    mov dl,ah
    mov dh,0
    push dx
    inc cx ; count numbers of pushing
    test al,al
    jz display
    mov ah,0 ; clear ah
    jnz prepare
display:
    pop ax
    add ax,30h
    mov ah,2
    mov dl,al
    int 21h
    loop display
                   
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
