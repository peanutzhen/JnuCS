; multi-segment executable file template.

data segment
    STRING1 db 81H;define 128 chars
            db 0   
            db 81H dup('$')
    STRING2 db 81H;define 128 chars
            db 0   
            db 81H dup('$') 
    index db 3 dup('$')
    TEN db 10
    
    prompt1 db "String1: $" 
    prompt2 db "String2: $"
    prompt3 db "String1 plunged at: $" 
    
    outIndex db "Illegal index!(Out of index)"  
             db 0dh,0ah,24h   ;newline
    outCap db "Out of Capacity!" 
           db 0dh,0ah,24h
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

    ;get string1
    lea dx, prompt1
    mov ah, 9
    int 21h
    
    mov dx, offset STRING1
    mov ah, 0ah
    int 21h
    
    ;new line
    mov ah,2
    mov dl,0dH
    int 21h
    mov ah,2
    mov dl,0aH
    int 21h
    
    ;get string2
    lea dx, prompt2
    mov ah, 9
    int 21h
    
    mov dx, offset STRING2
    mov ah, 0ah
    int 21h
    
    ;new line
    mov ah,2
    mov dl,0dH
    int 21h
    mov ah,2
    mov dl,0aH
    int 21h
    
    ;show plunging index prompt
    lea dx,prompt3
    mov ah,9
    int 21h
    
    ;preparing get index
    mov si,0
    ;get index and store it in stack..
getindex:
    mov ah,1
    int 21h 
    
    cmp al,0dh        ; if return key, end input
    je trans1    
    
    mov index[si],al  ; storing
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
    mov dl,index[si]
    sub dl,30h
    add al,dl
    cmp index[si+1],'$'
    je store_index    ; it's time to store! Do not mul 10!
    imul TEN
    inc si
    jmp lp1      ;get next digit

store_index:
    mov index,al ;[index] = index num

    ;new line
    mov ah,2
    mov dl,0dH
    int 21h
    mov ah,2
    mov dl,0aH
    int 21h
       
   
    ;check it is legal or not
check:
    ;dx:index ax:len str
    mov al,index
    cbw
    mov dx,ax
    
    mov al,STRING1+1 ;length of string1
    cbw
    cmp ax,dx
    jl outOfIndex
    
    mov cx,ax        ;cx:len str1
    mov al,STRING2+1 ;length of string2
    cbw
    add ax,cx
    cmp ax,80h
    jg outOfBound     ;len(str1) + len(str2) > 127!!!!!
    
    jmp handler ;it is legal, hence jump to handler
    
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
    
    ;starting handling
handler:
    ;init
    add dx,2 ;actual index
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
    ;display string1 atfer plunging
    lea dx,STRING1+2
    mov ah,9
    int 21h
    
    ;new line
    mov ah,2
    mov dl,0dH
    int 21h
    mov ah,2
    mov dl,0aH
    int 21h
    
ending:            
    lea dx, pkey
    mov ah, 9
    int 21h        
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
      