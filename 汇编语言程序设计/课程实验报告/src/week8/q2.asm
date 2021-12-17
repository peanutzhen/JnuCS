; multi-segment executable file template.

data segment
    ; add your data here!
    STRING db 81H;define 128 chars
           db 0   
           db 81H dup('#') ;# for the end of string
    
    NUM dw 4
        db 'NUM:'
        db 81H dup('$')
    
    BCHAR dw 6
          db 'BCHAR:'
          db 81H dup('$')   
    
    LCHAR dw 6
          db 'LCHAR:'
          db 81H dup('$')    
    
    OTHER dw 6
          db 'OTHER:'
          db 81H dup('$') 
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

    ; get string from I/O
    mov dx,offset STRING
    mov ah,0AH
    int 21h
    
    ;classification
    lea bx,STRING
    inc bx  ;jump to byte of length of string
    mov cl,[bx] ;get length of string
    mov ch,0   ;clear 0
    inc bx   ; first char
s:
    cmp byte ptr[bx],30H
    jb others
    jae next1
next1:
    cmp byte ptr[bx],39H
    jbe nums
    ja next2
next2:
    cmp byte ptr[bx],41H
    jb others
    jae next3
next3:
    cmp byte ptr[bx],5aH
    jbe bchars
    ja next4
next4:
    cmp byte ptr[bx],61h
    jb others
    jae next5
next5:
    cmp byte ptr[bx],7ah
    jbe lchars
    ja others
pres:
    inc bx
    ;complete? cx = 0 OK ,or not ok.
    dec cx
    test cx,cx
    je display
    jne s
    
others:
    mov di,bx ;store bx
    lea bx,OTHER
    jmp handler

nums:
    mov di,bx ;store bx
    lea bx,NUM
    jmp handler
    
bchars:
    mov di,bx ;store bx
    lea bx,BCHAR
    jmp handler
lchars:
    mov di,bx ;store bx
    lea bx,LCHAR
    jmp handler
    
handler:
    mov si,[bx]
    add si,2
    mov al,byte ptr [di] ;load char
    mov [bx+si],al ;write char
    inc word ptr[bx] ;length++
    mov bx,di ;return bx
    jmp pres

display:
    ;new line
    mov ah,2
    mov dl,0dH
    int 21h
    mov ah,2
    mov dl,0aH
    int 21h       
    ;display NUM
    mov dx,offset NUM
    mov ah,9
    int 21h
    ;new line
    mov ah,2
    mov dl,0dH
    int 21h
    mov ah,2
    mov dl,0aH
    int 21h 
    ;display BCHAR
    mov dx,offset BCHAR
    mov ah,9
    int 21h
    ;new line
    mov ah,2
    mov dl,0dH
    int 21h
    mov ah,2
    mov dl,0aH
    int 21h 
    ;display LCHAR
    mov dx,offset LCHAR
    mov ah,9
    int 21h 
    ;new line
    mov ah,2
    mov dl,0dH
    int 21h
    mov ah,2
    mov dl,0aH
    int 21h 
    ;display OTHER
    mov dx,offset OTHER
    mov ah,9
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
