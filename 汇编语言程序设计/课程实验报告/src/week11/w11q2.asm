; multi-segment executable file template.

data segment
    ; add your data here!
    str1 db 128
         db 0
         db 128 dup(24h)
    pt1 db "Enter str:",0dh,0ah,24h
    pt2 db 0dh,0ah,"Sorted str:",0dh,0ah,24h
    LEN dw 0
    END_DI dw 0
    END_SI dw 0
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

    ;get str1
    lea dx,pt1
    mov ah,9
    int 21h
    
    lea dx,str1[2]
    mov ah,0ah
    int 21h
    
    ;bubble sort
    
    ;init
    mov al,str1[3]
    cbw
    mov LEN,ax     ;len of str1
    
    mov ax,LEN
    add ax,3
    mov END_DI,ax  ;end of di:len+3
    mov di,4       ;start of str1 offset
   
L2:
    mov si,4       ;start of str1 offset
    ;compare str1[si] > str1[si]1
judge:
    mov al,str1[si]
    cmp al,str1[si]1
    jg swap
    jng next
swap:
    mov ah,str1[si]1
    mov str1[si],ah
    mov str1[si]1,al
next:  
    mov ax,END_DI
    sub ax,di
    add ax,4
    mov END_SI,ax
    inc si
    cmp si,END_SI
    jl judge
    
    inc di
    cmp di,END_DI
    jl L2
    
    ;show output
    lea dx,pt2
    mov ah,9
    int 21h
    
    lea dx,str1[4]
    mov ah,9
    int 21h
            
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
