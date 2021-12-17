; multi-segment executable file template.

data segment
    STRING1 db 27    ;27: 25 for char ,1 for cret ,1 for $
            db 0   
            db 27 dup('$') ;# for the end of string
    STRING2 db 27
            db 0   
            db 27 dup('$') ;# for the end of string
    input_prom db "Enter 2 strings:$"
    output_prom db "Output:$"
    newline db 0dh,0ah,"$"
    
    offset1 db 26 dup(' ')  ;Used for right-format
    offset2 db 26 dup(' ')                
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

    ;print input prompt
    lea dx,input_prom
    mov ah,09h
    int 21h
    ;newline
    lea dx,newline
    mov ah,09h
    int 21h
    
    lea dx,STRING1
    mov ah,0Ah
    int 21h
    
    ;newline
    lea dx,newline
    mov ah,09h
    int 21h
    
    lea dx,STRING2
    mov ah,0ah
    int 21h 
    
    ;newline
    lea dx,newline
    mov ah,09h
    int 21h
    
    ;print output prompt
    lea dx,output_prom
    mov ah,09h
    int 21h
    
    ;newline
    lea dx,newline
    mov ah,09h
    int 21h
    
    ;下面采用ch，cl分别作为string1,2的补偿长度。即25h-串长
    ;handle string1
    mov al,STRING1+1
    cbw ;al -> ax
    mov si,25
    sub si,ax
    ;set offset
    mov offset1[si],'$'
    ;print offset
    lea dx,offset1
    mov ah,9
    int 21h
    ;print string1
    lea dx,STRING1+2
    mov ah,9
    int 21h
    ;newline
    lea dx,newline
    mov ah,9
    int 21h
    
    ;handle string2 
    mov al,STRING2+1
    cbw
    mov si,25
    sub si,ax
    ;set offset
    mov offset2[si],'$'
    ;print offset
    lea dx,offset2
    mov ah,9
    int 21h
    ;print string2
    lea dx,STRING2+2
    mov ah,9
    int 21h
    ;newline
    lea dx,newline
    mov ah,9
    int 21h
    
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
