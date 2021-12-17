; multi-segment executable file template.

data segment
    STRING1 db 81H;define 128 chars
            db 0   
            db 81H dup('$')
    STRING2 db 81H;define 128 chars
            db 0   
            db 81H dup('$') 
    index db 4 dup('$')
    TEN db 10
    
    prompt1 db "String1: $" 
    prompt2 db 0dh,0ah,"String2: $"
    prompt3 db 0dh,0ah,"String1 plunged at: $" 
    
    outIndex db 0dh,0ah,"Illegal index!(Out of index)$"  

    outCap db 0dh,0ah,"Out of Capacity!$" 

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

    ;get string1
    lea dx,prompt1
    push dx
    lea dx,STRING1
    push dx
    call getstring
    
    
    ;get string2
    lea dx,prompt2
    push dx
    lea dx,STRING2
    push dx
    call getstring
    
    ;get index
    lea dx,prompt3
    push dx
    lea dx,index
    push dx
    call get_index  
    
    ;checking exception
    lea dx,STRING1
    push dx
    lea dx,STRING2
    push dx
    lea dx,index
    push dx
    
    call check
    call algorithm
    jmp ending
    
    ;exception list
outOfIndex:
    lea dx,outIndex
    mov ah,9
    int 21h
    jmp ending
outOfBound:
    lea dx,outCap
    mov ah,9
    int 21h
    jmp ending
           
ending:            
    lea dx, pkey
    mov ah, 9
    int 21h        
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h
    
getstring:
    push bp
    mov bp,sp
    mov dx,[bp+6]
    mov ah, 9
    int 21h
    
    mov dx, [bp+4]
    mov ah, 0ah
    int 21h
    
    pop bp
    ret 4
get_index:
    push bp 
    mov bp,sp
    ;show plunging index prompt
    mov dx,[bp+6]
    mov ah,9
    int 21h
    
    ;preparing get index
    mov si,0
    mov bx,[bp+4]
    ;get index and store it in stack..
getindex:
    mov ah,1
    int 21h 
    
    cmp al,0dh        ; if return key, end input
    je trans1    
    
    mov [bx][si],al   ; storing
    inc si            ; next digit
    
    cmp si,3
    jge outOfBound    ; Out of Bound exception.
    
    jmp getindex      ; continue getting index

trans1:
    ;preparing get index
    mov si,0
    mov al,0

lp1:
    ;dl = digit value, al = value    
    mov dl,[bx][si]
    sub dl,30h
    add al,dl
    cmp [bx][si+1],'$'
    je store_index    ; it's time to store! Do not mul 10!
    imul TEN
    inc si
    jmp lp1      ;get next digit

store_index:
    mov index,al ;[index] = index num
    pop bp
    ret 4
   
check:
    ;check it is legal or not
    ;dx:index ax:len str
    push bp
    mov bp,sp
    
    mov si,[bp+4]
    mov al,[si]
    cbw
    mov dx,ax
    
    mov si,[bp+8]
    mov al,[si]+1 ;length of string1
    cbw
    cmp ax,dx
    jl outOfIndex
    
    mov cx,ax        ;cx:len str1
    mov si,[bp+6]
    mov al,[si]+1 ;length of string2
    cbw
    add ax,cx
    cmp ax,80h
    jg outOfBound     ;len(str1) + len(str2) > 127!!!!!
    
    pop bp
    ret 6
    ;starting handling
algorithm:
    ;init
    mov dl,index
    mov dh,0
    inc dx ;actual index
    mov al,STRING1+1 ;length of string1
    cbw
    inc ax ;first add 2(str start), and then sub 1(index)
    mov si,ax  ; end of str1
    mov di,2   ; start of str2
    
    mov al,STRING2+1 ;length of string2
    cbw
    mov bx,ax  ;bx: len str2
    ;right-shift string1 from index
shift:
    mov al,STRING1[si]
    mov STRING1[bx][si],al
    dec si
    cmp si,dx
    jge shift
    ;copy string2 to index of string1
prepare:
    ;init
    mov al,STRING2+1 ;length of string2
    cbw              ;ax: len str2
    mov si,dx        ;init index
    mov cx,ax
copy:
    ;copying
    mov al,STRING2[di]
    mov STRING1[si],al
    inc si
    inc di
    loop copy
    
    ;new line
    mov ah,2
    mov dl,0dH
    int 21h
    mov ah,2
    mov dl,0aH
    int 21h
    ;display string1 atfer plunging
    lea dx,STRING1+2
    mov ah,9
    int 21h 
    ret       
ends

end start ; set entry point and stop the assembler.
      