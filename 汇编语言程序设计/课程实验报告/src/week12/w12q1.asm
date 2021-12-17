; multi-segment executable file template.

data segment
    ; add your data here!
    BCD db 6 dup('$')
    TEN dw 10
    
    NUM dw 0
    P dw 0
    prompt1 db "Enter decimal:$"
    prompt2 db 0dh,0ah,"P:$"
    prompt3 db 0dh,0ah,"output:$"
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
    
    lea dx,prompt1
    mov ah,9
    int 21h
    
    mov si,0
getnum:
    mov ah,1
    int 21h

    cmp al,0dh        ; if return key, end input
    je trans

    mov BCD[si],al    ; storing
    inc si            ; next digit

    cmp si,5
    je trans

    jmp getnum      ; continue getting num

trans:
    ;preparing get num
    mov si,0
    mov ax,0
    mov dx,0
lp1:
    ;dl = digit value, al = value    
    mov dl,BCD[si]
    sub dl,30h
    add ax,dx
    cmp index[si+1],'$'
    je store_num    ; it's time to store! Do not mul 10!
    imul TEN
    inc si
    jmp lp1      ;get next digit

store_num:
    mov NUM,ax  
    
    ;now get P
    mov si,0
clear_BCD:
    mov BCD[si],24h
    inc si
    cmp si,5
    jne clear_BCD
    
    lea dx,prompt2
    mov ah,9
    int 21h
    
    mov si,0
getP:
    mov ah,1
    int 21h

    cmp al,0dh        ; if return key, end input
    je trans1

    mov BCD[si],al  ; storing
    inc si            ; next digit

    cmp si,2
    je trans1

    jmp getP      ; continue getting P

trans1:
    ;preparing get P
    mov si,0
    mov ax,0
    mov bl,10
lp2:    
    mov dl,BCD[si]
    sub dl,30h
    add al,dl
    cmp index[si+1],'$'
    je store_p    ; it's time to store! Do not mul 10!
    imul bl
    inc si
    jmp lp2      ;get next digit

store_p:
    cbw
    mov P,ax
    
    lea dx,prompt3
    mov ah,9
    int 21h
    ;now NUM,P have been loaded in mem
    ;it's time to transact!!
    push NUM
    push P
    call algorithm
    jmp ending
algorithm:    
    push bp
    mov bp,sp
    mov dx,0
    mov ax,[bp+6]
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
    
    call adjust
    mov dl,al
    mov ah,2
    int 21h
    cmp sp,bp
    jne display 
    pop bp
    ret 4 
adjust:
    cmp ax,3Ah
    jge s1
    ret 
s1:
    add ax,7
    ret     
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
