; multi-segment executable file template.

data segment
    BCD1 db 4 dup(0)
    BCD2 db 4 dup(0)
    BCD3 db 4 dup(0)
    pt1 db "BCD1: $"
    pt2 db 0dh,0ah,"BCD2: $"
    pt3 db 0dh,0ah,"BCD3: $"
    TEN db 10 
    C1 db 0
    DIGIT9 db 0
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

    ;get BCD1
    lea dx,pt1
    mov ah,9
    int 21h
    ; prepare get bcd1
    ; dx:bx store bcd1
    mov dx,0
    mov bx,0
    mov cx,0 ; memorize numbers of digit
get1:
    mov ah,1
    int 21h
    ;judge return key
    cmp al,0dh
    je store1
    ;get number and byte to word
    sub al,30h
    cbw
    
    ;shift 4 bits
    mov si,0
shift:
    shl bx,1
    rcl dx,1
    inc si
    cmp si,4
    jl shift
    
    add bx,ax
    inc cx
    cmp cx,8     ;only get 8 digits, a double word
    jne get1
    je store1
store1:
    mov BCD1[0],dh
    mov BCD1[1],dl
    mov BCD1[2],bh
    mov BCD1[3],bl
    
    ;get BCD1
    lea dx,pt2
    mov ah,9
    int 21h
    ; prepare get bcd2
    ; dx:bx for tmp bcd2
    mov dx,0
    mov bx,0
    mov cx,0 ; memorize numbers of digit
get2:
    mov ah,1
    int 21h
    ;judge return key
    cmp al,0dh
    je store2
    ;get number and byte to word
    sub al,30h
    cbw
    ;shift 4 bits
    mov si,0
shift1:
    shl bx,1
    rcl dx,1
    inc si
    cmp si,4
    jl shift1
    
    add bx,ax
    inc cx
    cmp cx,8     ;only get 4 digits, a word
    jne get2
    je store2
store2:
    mov BCD2[0],dh
    mov BCD2[1],dl
    mov BCD2[2],bh
    mov BCD2[3],bl
    
    ;starting computing
    mov al,[3]
    mov ah,[7]  
    add al,ah
    daa
    mov BCD3[3],al
    
    mov al,[2]
    mov ah,[6]
    adc al,0
    add al,ah
    daa
    mov BCD3[2],al
    
    mov al,[1]
    mov ah,[5]
    adc al,0
    add al,ah
    daa
    mov BCD3[1],al
    
    mov al,[0]
    mov ah,[4]
    adc al,0
    add al,ah
    daa
    adc DIGIT9,0 ;keep 9th digit
    mov BCD3[0],al
    
    
    ;show output
    lea dx,pt3
    mov ah,9
    int 21h
    ;show 9th digit if it is 1
    cmp DIGIT9,0
    jne print_digit9
    je skip_digit9
print_digit9:
    add DIGIT9,30h
    mov dl,DIGIT9
    mov ah,2
    int 21h
skip_digit9:
    ;prepare pushing each digit of BCD3 in stack
    mov cl,0
    mov bx,000fh
    mov di,3     ;low 4 digits of BCD3
    mov C1,0
get3:
    mov al,BCD3[di]
    mov ah,BCD3[di-1]
    and ax,bx
    shr ax,cl
    add ax,30h

    push ax      ;keep digit in stack 
    
    ;shift 4 bits
    shl bx,4       ;mask for next digit
    
    add cl,4       ;for normalize to ascii
    
    inc C1         
    cmp C1,4       ;C1 control 4 times loop
    jl get3
                
    ;now push high 4 digits of BCD3 in stack
    mov cl,0       
    mov bx,000fh   ;re init mask
    sub di,2       ;high 4 digits
    mov C1,0       ;re init control loop var
    cmp di,1
    jge get3       ;if di<1, means end to get BCD3
    
;display BCD3
    mov cx,8
    cmp DIGIT9,0
    jne dirty_bx
    mov bx,0
    jmp display
dirty_bx:
    mov bx,1 
    ; when bx=1, means start print numbers
    ; bx used for skip 0 like: 00123 -> 123 
display:
    pop ax
    mov dl,al
    cmp bx,0
    je judge_skip
    jne print
judge_skip:
    cmp dl,30h   ;if dl=30h means '0', skip it.
    je skip
    mov bx,1     ;first no '0' digit, and do not skip 0 after it.
print:
    mov ah,2
    int 21h
skip:
    dec cx
    cmp cx,0
    jne display
          
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
