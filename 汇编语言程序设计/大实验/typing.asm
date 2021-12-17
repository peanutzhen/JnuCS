; 本程序为汇编语言课的课程设计
; 程序为一打字软件
; 设计思想：
; 开始程序->绘制开始界面->typing->perfomance
;                    ->exit  ->exit

; 分为:数据段data/栈段stack/主程序段main/子程序段function
; 作者：暨南大学--甄洛生  不得随意转载源代码，转载说明出处！

data segment
    assume ds:data
    ;标题 背景颜色设置值
    db 48,48,48,48,48,48,96,96,96,48,96,96,96,96,48,96,96,96,96,48,48,48,48,96
    db 48,48,48,48,48,48,96,96,96,48,48,96,96,48,48,96,96,96,48,96,96,96,48,48
    db 96,96,48,48,96,96,96,96,96,48,48,96,96,48,48,96,96,96,48,96,96,96,96,48
    db 96,96,48,48,96,96,96,96,96,96,48,48,48,48,96,96,96,96,48,96,96,96,96,48
    db 96,96,48,48,96,96,96,96,96,96,96,48,48,96,96,96,96,96,48,48,48,48,48,96
    db 96,96,48,48,96,96,96,96,96,96,96,48,48,96,96,96,96,96,48,48,96,96,96,96
    db 96,48,48,48,48,96,96,96,96,96,96,48,48,96,96,96,96,96,48,48,96,96,96,96
    db 96,48,48,48,48,96,96,96,96,96,96,48,48,96,96,96,96,96,48,96,96,96,96,96
    ; 主界面信息
    help1 db "Typ is a typing software.$"
    help2 db "<- -> control options.$"
    help3 db "Enter to confirm.$"
    help4 db "You can leave anytime by esc! Enjoy it.$"

    option1 db "Start now!"
    option2 db "   Exit   "

    declaim db "Ownership of typ is owned by zls.$"
    ; Esc界面
    esc_query db "Really want to exit?$"
    exit_str db "  Exit   "
    restart_str db " Restart " ; 9 chars
    ; 结束界面
    title_str db "Perfomance$"
    acc_str db "Accuracy: $"
    time_str db "Time: $"
    ; 练习文章,刚好100个字符。
    essay db "I was used to do things by my own, because I did not like to cooperate with other person. So stupid."
    ;page_str db "PAGE$"
    leave_prompt db "ESC to quit!$"
    ; 记录时长
    begin_time db 0,0,0
    end_time db 0,0,0
    gap db 0,0,0
    ; 用于各子过程返回值
    rtv db 0
    ; 错误次数
    missing db 0
    ; 页面信息(改为上卷样式，弃用)
    ;total_page db 0     ; 通过draw_text的最终bh给出
    ;current_page db 0   ; 通过handler函数的bh给出
data ends

stack segment stack
    assume ss:stack
    dw 0ffh dup(0)
stack ends

main segment
    assume cs:main
start:
    mov ax,data
    mov ds,ax

    ; 绘制开始界面！^ ^
    call far ptr start_interface
    ; 返回值ax将用于判断是退出1 还是 开始打字0
    cmp rtv,1
    je ending
entry:
    ; 清屏
    call far ptr clear
    ; 绘制文本
    call far ptr draw_text
    ; 错误率清零,相当重要的一步，否则重新开始后，missing可能不是0，导致很奇怪的bug
    mov byte ptr missing,0
    ; 记录进入时间
    lea dx,begin_time
    push dx
    call far ptr timer
    ; 开始打字练习
    call far ptr handler
    cmp rtv,0
    je normal_exit
    ; 若rtv为1，则Esc退出，给出提示，询问是重新一局还是退出
    call far ptr esc_prompt
    cmp rtv,0
    je ending
    jne entry
normal_exit:
    ; 记录退出时间
    lea dx,end_time
    push dx
    call far ptr timer
    ; 结束界面
    call far ptr ending_interface
    cmp rtv,0
    je entry
    jne ending
    ; 结束软件
ending:
    call far ptr clear
    mov ax,4c00h
    int 21h
main ends

function segment
    assume cs:function
save_context macro
    irp reg,<ax,bx,cx,dx,si,di,bp>
        push reg
    endm
endm

restore_context macro
    irp reg,<bp,di,si,dx,cx,bx,ax>
        pop reg
    endm
endm
; 绘制画布
draw_canvas macro color,start,end
    mov ah,6
    mov al,0
    mov bh,color
    mov cx,start
    mov dx,end
    int 10h
endm
; 绘制软件名字子程序，用于绘制主界面的子程序
draw_name:
    save_context
    mov si,0
    ; 设置起点终点
    mov cx,7
    mov dx,031ch
lp1:
    push cx
    push dx
    mov ah,2        ; BIOS 2号功能：置光标to dh,dl
    mov bh,0        ; bh 为显示页面
    int 10h

    mov cx,24
    lp2:
        push cx
        mov ah,2        ; BIOS 2号功能：置光标to dh,dl
        mov bh,0        ; bh 为显示页面
        int 10h

        mov ah,9
        mov al,20h
        mov bh,0
        mov bl,ds:[si]
        mov cx,1
        int 10h
        inc si
        inc dx
        pop cx
        loop lp2
    pop dx  ; 恢复当前行列值
    inc dh  ; 下一行
    mov dl,1ch
    pop cx  ; 恢复外循环计数器
    loop lp1
    restore_context
    ret
; 绘制软件信息宏，用于绘制主界面的子程序
draw_info macro
    save_context
    row=13
    irp i,<help1,help2,help3,help4>
        mov ah,2        ; 置光标
        mov bh,0
        mov dh,row
        mov dl,26
        int 10h

        lea dx,i ;打印信息
        mov ah,9
        int 21h
        row=row+1
    endm
    mov ah,2        ; 置光标
    mov bh,0
    mov dh,24
    mov dl,46
    int 10h

    lea dx,declaim ;打印信息
    mov ah,9
    int 21h
    restore_context
endm
; 绘制button,通过寄存器传参数
button:
    save_context
    lp_button:
        push cx
        mov ah,2
        int 10h

        mov ah,9
        mov al,[si]
        mov cx,1
        int 10h

        inc si              ; next character
        inc dl              ; next position
        pop cx
        loop lp_button
    mov ah,2
    mov bh,0
    mov dx,1950h              ; 隐藏光标
    int 10h
    restore_context
    ret

; 绘制整个按钮界面宏
draw_button macro r1,c1,r2,c2,len,page,selected,unselected,op1,op2
    save_context
    irp i,<c1,c2>
        mov ah,6
        mov al,0
        mov bh,01110000b
        mov ch,r1
        mov cl,i
        mov dh,r2
        mov dl,i+len-1
        int 10h
    endm
    ; 默认选中按钮1
    mov rtv,0
    mov bh,page
    mov bl,selected
    mov dh,r2-1
    mov dl,c1
    mov cx,len
    lea si,op1
    call near ptr button
    ; 部分参数不变，所以不必重新赋值。
    mov bl,unselected
    mov dl,c2
    lea si,op2
    call near ptr button
    restore_context
endm
control_option macro row,len,page,selected,unselected,c1,c2,op1,op2
    local lp,ret,left_arrow,right_arrow
    save_context
    ; 初始化列表
    mov dh,row
    mov cx,len
    mov bh,page
    lp:
        mov ah,0        ; BIOS 16号中断，0号功能：读取缓冲区输入
        int 16h

        cmp al,0dh
        je ret         ; end and return value
        cmp ax,4B00h
        je left_arrow
        cmp ax,4D00h
        je right_arrow
        jmp lp          ; 非法输入，直接忽略就完事了

        left_arrow:
            mov bl,selected
            mov dl,c1
            lea si,op1
            call near ptr button
            mov bl,unselected
            mov dl,c2
            lea si,op2
            call near ptr button
            mov rtv,0
            jmp lp
        right_arrow:
            mov bl,unselected
            mov dl,c1
            lea si,op1
            call near ptr button
            mov bl,selected
            mov dl,c2
            lea si,op2
            call near ptr button
            mov rtv,1
            jmp lp
    ret:
        restore_context
endm
; 清屏子程序
clear:
    save_context
    mov ax,3        ; 功能描述：设置显示器模式03H 80×2516色 文本
    int 10h
    restore_context
    retf
start_interface:
    save_context
    ; 绘制背景
    draw_canvas 70h,0,184fh
    draw_canvas 60h,0102h,174dh
    ; 软件名字子程序，不能用宏，否则代码在编译后很大
    call near ptr draw_name        ; 具体参见line 71
    ; 软件信息宏
    draw_info                      ; 绘制软件信息，操纵信息,具体参见line 108
    ; 绘制开始和退出按钮, 具体参见line 188
    ; r1,c1,r2,c2,len,page,selected,unselected
    draw_button 19,26,21,44,10,0,2ah,70h,option1,option2
    ; 循环检测按键，<- ->控制选中选项，Enter确定选择。参见line 219
    ; row,len,page,selected,unselected,c1,c2
    control_option 20,10,0,2ah,70h,26,44,option1,option2
    restore_context
    retf

timer:
    save_context
    mov bp,sp
    mov bx,[bp+18]
    mov ah,2ch          ; DOS 获取时间功能
    int 21h

    mov [bx],cl        ;mins
    mov [bx][1],dh     ;sec
    mov [bx][2],dl     ;百分秒 100ms
    restore_context
    retf 2

draw_border:
    save_context
    ; 边框颜色采用蓝绿色，相比灰色，更加好看了。
    ; 设置左右边界
    mov ah,6
    mov al,0
    mov bh,00110000b
    mov cx,0023h
    mov dx,1823h
    int 10h

    mov ah,6
    mov al,0
    mov bh,00110000b
    mov cx,002eh
    mov dx,182eh
    int 10h
    ; 设置每行的边界
    mov cx,0024h
    mov dx,002dh
    mov bh,00110000b
    db_lp:
        mov ah,6
        int 10h
        add ch,3
        add dh,3
        cmp ch,24
        jbe db_lp
    restore_context
    ret

draw_text:
    save_context
    ; 初始化列表
    mov bh,0            ; 在Page 0绘制
    mov si,0
    dt_lp:              ; 从坐标为[2,37]开始绘制文本
        mov dx,0124h
        dt_lp1:         ; 绘制一行
            push dx
            mov cx,10
            dt_lp2:     ; 绘制该行每个字符
                push cx
                mov ah,2    ; 光标置位
                int 10h
                mov ah,9
                mov al,essay[si]
                mov bl,00001111b
                mov cx,1
                int 10h
                inc si
                inc dl
                pop cx
                loop dt_lp2
            pop dx
            add dh,3                ; next 3 lines
            mov dl,24h              ; init col
            cmp si,80               ; draw 8 lines ok
            jnb dt_ret              ; 已经绘制完成
            jmp dt_lp1              ; unfinished, going on!
            ;cmp dh,25
            ;je next_page            ; 当前页面行已满，跳转到下一页绘制
            ;jne dt_lp1              ; 还没满，继续绘制
        ;next_page:
            ;inc bh
            ;jmp dt_lp
    dt_ret:
        ;mov total_page,bh           ; 存页数
        restore_context
        retf

handler_prompt macro
    save_context
    mov ah,2                    ; set pos
    mov bh,0                    ; page index
    mov dx,0                    ; x,y 坐标
    int 10h
    draw_canvas 8fh,0,000bh     ; set attr: text attr,start 坐标, end 坐标
    lea dx,leave_prompt         ; print
    mov ah,9
    int 21h
    restore_context
endm
handler:
    save_context
    ; 初始化列表
    mov bh,0                        ; page index
    mov si,0                        ; 当前打的字数
    h_lp:
        mov dx,0224h                ;首行，输入行
        ;mov ah,5
        ;mov al,bh
        ;int 10h                     ; 显示活动页，bh决定
        ;mov current_page,bh         ; 存当前页码
        call near ptr draw_border   ; 绘制边界
        handler_prompt
        h_lp1:
            push dx
            mov cx,10
            h_lp2:
                push cx
                mov ah,2            ; 光标置位
                int 10h

                mov ah,0            ; 读输入
                int 16h

                cmp ax,011bh        ; Esc
                je h_exit1

                cmp al,essay[si]    ; 判断输入是否正确
                je correct
                jne incorrect
                correct:
                    mov bl,00001010b
                    jmp show_char
                incorrect:
                    inc missing     ; 错误次数+1
                    mov bl,00001100b
                show_char:
                    mov ah,9
                    mov cx,1
                    int 10h         ; 输出字符
                    inc si
                    inc dl
                    pop cx
                loop h_lp2
            pop dx
            add dh,3
            mov dl,24h
            cmp si,100
            je h_exit0               ; 打完字啦，正常退出
            cmp dh,24                ; 还没打完，测试是否要上卷
            ja scroll
            jna h_lp1
    h_exit0:
        mov rtv,0              ; 设置正常结束退出码为0
        jmp h_ret
    h_exit1:
        mov rtv,1              ; 设置Esc退出码为1
        pop cx                 ; 由于提前跳转至此，必须弹出这两个小东西
        pop dx                 ; 本来是在输出字符的时候弹出，但现在跳过了
        jmp h_ret
    scroll:
        ; scroll up 3 lines
        mov ah,6
        mov al,3
        mov bh,0
        mov cx,0023h
        mov dx,182eh
        int 10h
        ; 重新绘制底部边框
        draw_canvas 30h,1623h,182eh
        draw_canvas 0,1624h,172dh
        ; 绘制紧接着的10个字符
        mov di,si
        mov dx,1624h
        mov cx,10
        h_lp3:
            push cx
            mov ah,2    ; 光标置位
            mov bh,0
            int 10h
            mov ah,9
            mov al,essay[di]
            mov bl,00001111b
            mov cx,1
            int 10h
            inc di
            inc dl
            pop cx
            loop h_lp3
        ; set 光标位置
        mov dx,1724h             ; last input line
        jmp h_lp1
    h_ret:
        restore_context
        retf

esc_prompt:
    save_context
    draw_canvas 40h,081ch,0e33h
    mov bh,0
    mov dx,091eh
    mov ah,2                ; 光标调整
    int 10h
    lea dx,esc_query        ; 显示提示字符
    mov ah,9
    int 21h
    ; 显示按钮
    ; r1,c1,r2,c2,len,page,selected,unselected
    draw_button 0bh,1eh,0dh,2ah,9,0,28h,70h,exit_str,restart_str
    ; row,len,page,selected,unselected,c1,c2
    control_option 0ch,9,0,28h,70h,1eh,2ah,exit_str,restart_str

    restore_context
    retf

print_bin macro bin_num
    local lp,print
    save_context
    mov bp,sp
    mov al,bin_num
    cbw
    mov bl,10
    ; compute
    lp:
        div bl
        mov dl,ah
        mov dh,0
        push dx
        mov ah,0
        cmp ax,0
        jne lp
    ; print out
    print:
        pop dx
        add dl,30h
        mov ah,2
        int 21h
        cmp bp,sp
        jne print
    restore_context
endm

compute_time_gap macro
    local get_ten_ms,get_sec,get_min
    ; 注意，运算时间，必须自定义借位。
    save_context
    mov cl,begin_time[0]
    mov dl,begin_time[1]
    mov al,begin_time[2]

    mov ch,end_time[0]
    mov dh,end_time[1]
    mov ah,end_time[2]
    cmp ah,al
    jae get_ten_ms                  ; 若够减，则直接得到百分秒
    ; 不够减，向秒借位
    add ah,100
    dec dh
    get_ten_ms:
        sub ah,al
        mov gap[2],ah

    cmp dh,dl
    jae get_sec                  ; 若够减，则直接得到秒
    ; 不够减，向分借位
    add dh,60
    dec ch
    get_sec:
        sub dh,dl
        mov gap[1],dh
    ; 分只会大于等于，不可能小于，因为结束时间大于等于开始时间，所以直接减就行
    sub ch,cl
    mov gap[0],ch
    restore_context
endm

ending_interface:              ; 结束界面
    save_context
    ; 绘制窗口背景
    draw_canvas 20h,091ch,1133h
    ; 显示窗口标题
    mov bh,0
    mov dx,0a23h
    mov ah,2                ; 光标调整
    int 10h
    lea dx,title_str
    mov ah,9
    int 21h
    ; 显示用时
    mov dx,0b1eh
    mov ah,2
    int 10h
    lea dx,time_str         ; 显示标签
    mov ah,9
    int 21h

    compute_time_gap        ; 计算用时
    print_bin gap[0]
    mov dl,'m'
    mov ah,2
    int 21h
    print_bin gap[1]
    mov dl,'s'
    mov ah,2
    int 21h
    print_bin gap[2]
    mov dl,'0'
    mov ah,2
    int 21h
    mov dl,'m'
    mov ah,2
    int 21h
    mov dl,'s'
    mov ah,2
    int 21h
    ; 显示精确度
    mov dx,0c1eh
    mov ah,2
    int 10h
    lea dx,acc_str          ; 显示标签
    mov ah,9
    int 21h
    mov ah,100
    sub ah,missing          ; 将错误率转换为精确率
    mov missing,ah
    print_bin missing
    mov dl,'%'
    mov ah,2
    int 21h
    ; 显示按钮
    ; r1,c1,r2,c2,len,page,selected,unselected
    draw_button 0eh,1eh,10h,2ah,9,0,1ah,70h,restart_str,exit_str
    ; row,len,page,selected,unselected,c1,c2
    control_option 0fh,9,0,1ah,70h,1eh,2ah,restart_str,exit_str
    restore_context
    retf
function ends

end start