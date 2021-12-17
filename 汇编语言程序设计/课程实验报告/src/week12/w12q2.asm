; multi-segment executable file template.

data segment
    NUM db 30h
    TEN db 10
    prompt1 db "Output: $"
    pkey db 0dh,0ah,"press any key...$"
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

    ; add your code here
    lea dx,prompt1
    mov ah,9
    int 21h
    
    mov al,NUM
    mov ah,0
    push ax
    mov al,TEN
    cbw
    push ax
    call algorithm
    jmp ending
algorithm:    
    push bp
    mov bp,sp
    mov dx,0
    mov ax,[bp+6]
    cmp ax,80h    ;nega or posi?
    jge adjust
    jng lp3
adjust:
    xor al,0ffh
    inc al        ;absolute value
    mov bx,ax     ; temp ax
    mov dl,2dh    ;print -
    mov ah,2
    int 21h
    mov ax,bx
    mov dx,0
lp3:
    div word ptr [bp+4]
    push dx
    mov dx,0
    cmp ax,0
    jne lp3
    ;display  
display:
    pop ax
    add ax,30h
    mov dl,al
    mov ah,2
    int 21h 
    cmp sp,bp
    jne display 
    pop bp
    ret 4 
ending:        
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
