; multi-segment executable file template.

data segment
    STRING1 db 128
            db 0
            db 128 dup('$')
    prompt1 db "Enter your string:",0dh,0ah,24h

    prompt2 db 0dh,0ah,"Index to delete:",0dh,0ah,24h
    
    prompt3 db 0dh,0ah,"Length to delete:",0dh,0ah,24h
    
    output db 0dh,0ah,"Output:",0dh,0ah,24h
    
    index db 3 dup('$')  ; 0 <= index <= 127
    
    len db 3 dup('$')    ; 1 <= len <= 127
    
    except db 0dh,0ah,"Error: Out of boundary!!",0dh,0ah,24h 
    
    TEN db 10d
       
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
    ;show prompt enter string
    lea dx,prompt1
    mov ah,9
    int 21h
    ;enter..
    lea dx,STRING1+2
    mov ah,0ah
    int 21h
    ;show index prompt
    lea dx,prompt2
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
    mov index,al  ;index store index num
    
    ;show length prompt
    lea dx,prompt3
    mov ah,9
    int 21h
    
    ;preparing get length
    mov si,0
    ;get index and store it in stack..
getlength:
    mov ah,1
    int 21h 
    
    cmp al,0dh         ; if return key, end input
    je trans2    
    
    mov len[si],al  ; storing
    inc si             ; next digit
    
    cmp si,3
    jge outOfBound    ; Out of Bound exception.
    
    jmp getlength      ; continue getting index

trans2:
    ;preparing get length
    mov si,0
    mov al,0

lp2:
    ;dl = digit value, al = value    
    mov dl,len[si]
    sub dl,30h
    add al,dl
    cmp len[si+1],'$'
    je store_length    ; it's time to store! Do not mul 10!
    imul TEN
    inc si
    jmp lp2      ;get next digit

store_length:
    mov len,al  ;length store length num

    ;It's time to deal with str1!    
handler:
    mov al,index
    cmp al,STRING1+3
    jge outOfBound ;exception
    cbw
    mov si,ax
    add si,4       ;delete beginning point
    
    mov al,len
    cbw
    mov di,ax      
    add di,si      ;delete ending point
    
    mov al,STRING1+3
    cbw
    mov cx,ax      
    sub cx,di
    add cx,4       ;replace counts = len(str1) - di + 4
    
lp3:
    mov al,STRING1[di] ;get char
    mov STRING1[si],al ;replace it
    inc si             
    inc di             ;next char
    cmp STRING1[di],'$' ; meeting end of str1
    je finish
    loop lp3
finish:    
    mov STRING1[si],'$' ; set end of str
    jmp display

outOfBound:
    lea dx,except
    mov ah,9
    int 21h
    jmp ending

display:
    lea dx,output
    mov ah,9
    int 21h
    ;show str1
    lea dx,STRING1+4
    mov ah,9
    int 21h
    jmp ending
        
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
