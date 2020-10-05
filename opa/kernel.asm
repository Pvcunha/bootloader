org 0x7e00
jmp 0x0000:start

data:

    ball_init_x dw 156
    ball_init_y dw 96

	ball_x dw 0    ;pos x
    ball_y dw 0    ;pos y
    ball_size equ 4     ;tamanho da bola
    
    bar_left_init_x dw 0
    bar_right_init_x dw 306
    ball_left_init_y dw 20

    bar_left_x dw 10    ;pos x
    bar_left_y dw 80    ;pos y

    bar_right_x dw 300    ;pos x
    bar_right_y dw 80    ;pos y
    bar_sizex equ 4     ;tamanho da bola 
    bar_sizey_right dw 40
    bar_sizey_left dw 40
    score_right dw 0
    score_left dw 0
    win_left dw 0
    win_right dw 0
    msg_win_right db 'Right player won!', 0 ;Zero no final equivale a null
    msg_win_left db 'Left player won!', 0
    title db 'PONGUI', 0
    instruction db 'Press W to start', 0
    instruction_2 db 'MOVEMENT KEYS', 0
    ruless db 'Left player : W,S --- Right player : O,L$'
    
    aux db 0      ;vai checar o tempo

    bar_vel dw 5
    bs_x dw 2
    bs_y dw 2
    flag_x dw 1
    flag_y dw 1


set_video_mode:
    mov ah, 00h     ;transforma para modo video
    mov al, 13h     ;escolhe o modo video
    int 10h         ;executa a conf

    mov ah, 00h     ;transforma para modo video
    mov al, 13h     ;escolhe o modo video
    int 10h         ;executa a conf
    ret


clearscreen:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x07        ; tells BIOS to scroll down window
    mov al, 0x00        ; clear entire window
    mov bh, 0           ; white on black
    mov cx, 0x00        ; specifies top left of screen as (0,0)
    mov dh, 0x18        ; 18h = 24 rows of chars
    mov dl, 0x4f        ; 4fh = 79 cols of chars
    int 0x10            ; calls video interrupt

    popa
    mov sp, bp
    pop bp
    ret


%macro delay 2
	mov cx, %1
	mov dx, %2
	
	mov ah, 86h
	int 15h
%endmacro



%macro putc 1
    mov bl, %1
    mov ah, 0eh
    int 10h
%endmacro

ball_reset:                 ;seta a bola nas posições iniciais 
    mov ax, [ball_init_x] 
    mov bx, [ball_init_y]

    mov [ball_x], ax
    mov [ball_y], bx
    ret

update_game_left:

    mov ax, [score_left]
    add ax, 1
    mov [score_left], ax
    cmp ax,5
    jne end_left
    mov ax, 1
    mov [win_left], ax

    end_left:
    mov ax,[bar_sizey_right]
    sub ax, 8
    mov [bar_sizey_right],ax

    ret


update_game_right:
    
    mov ax, [score_right]
    add ax, 1
    mov [score_right], ax
    cmp ax,5
    jne end_right
    mov ax, 1
    mov [win_right], ax

    end_right:
    mov ax,[bar_sizey_left]
    sub ax, 8
    mov [bar_sizey_left],ax

    ret


draw_ball:
    mov cx, [ball_x]  ;determina pos inicial da coluna (x)
    mov dx, [ball_y] ;determina posinicial da linha (y)

    horizontal_loop:
        mov ah, 0Ch     ;coloca no modo de escrever pixel
        mov al, 15      ;determina a cor do pixel
        mov bh, 00h     ;determina o numero da pagina
        int 10h
        
        inc cx          ;incrementa coluna
        
        mov ax, cx      ; se cx - pos_x inicial > ball_size então uma linha foi completada 
        sub ax, [ball_x]
        cmp ax, ball_size
        jng horizontal_loop ; se a comparacao nao for maior ele continua o loop horizontal (jump if not greater)
        
        mov cx, [ball_x]
        inc dx              ; se dx - ball_y > ball_size the drawing is complete
        mov ax, dx
        sub ax, [ball_y]
        cmp ax, ball_size
        jng horizontal_loop     ;se nao for maior passamos para a prox coluna

    ret

draw_bar_left:
    mov cx, [bar_left_x]  ;determina pos inicial da coluna (x)
    mov dx, [bar_left_y] ;determina posinicial da linha (y)

    horizontal_loop1:
        mov ah, 0Ch     ;coloca no modo de escrever pixel
        mov al, 15      ;determina a cor do pixel
        mov bh, 00h     ;determina o numero da pagina
        int 10h
        
        inc cx          ;incrementa coluna
        
        mov ax, cx      ; se cx - pos_x inicial > ball_size então uma linha foi completada 
        sub ax, [bar_left_x]
        cmp ax, bar_sizex
        jng horizontal_loop1 ; se a comparacao nao for maior ele continua o loop horizontal (jump if not greater)
        
        mov cx, [bar_left_x]
        inc dx              ; se dx - ball_y > ball_size the drawing is complete
        mov ax, dx
        sub ax, [bar_left_y]
        cmp ax,[bar_sizey_left]
        jng horizontal_loop1     ;se nao for maior passamos para a prox coluna

    ret

draw_bar_right:
    mov cx, [bar_right_x]  ;determina pos inicial da coluna (x)
    mov dx, [bar_right_y] ;determina posinicial da linha (y)

    horizontal_loop2:
        mov ah, 0Ch     ;coloca no modo de escrever pixel
        mov al, 15      ;determina a cor do pixel
        mov bh, 00h     ;determina o numero da pagina
        int 10h
        
        inc cx          ;incrementa coluna
        
        mov ax, cx      ; se cx - pos_x inicial > ball_size então uma linha foi completada 
        sub ax, [bar_right_x]
        cmp ax, bar_sizex
        jng horizontal_loop2 ; se a comparacao nao for maior ele continua o loop horizontal (jump if not greater)
        
        mov cx, [bar_right_x]
        inc dx              ; se dx - ball_y > ball_size the drawing is complete
        mov ax, dx
        sub ax, [bar_right_y]
        cmp ax, [bar_sizey_right]
        jng horizontal_loop2     ;se nao for maior passamos para a prox coluna

    ret

move_bar:
    mov ah,01h
    int 16h
    jz  bar_right_check_movement ; zf = 1, jz-> jump if zero

    ;verificando qual key foi pressionada
    mov ah,00h
    int 16h
    cmp al,77h 
    je bar_left_move_up

    ;verificando qual key foi pressionada
    cmp al,73h 
    je bar_left_move_down
    jmp bar_right_check_movement

    bar_left_move_up:
        mov ax,[bar_vel]
        sub [bar_left_y],ax

        mov ax,3
        cmp [bar_left_y],ax
        jl fix_padle_left_top
        jmp bar_right_check_movement

        fix_padle_left_top:
            mov ax,3
            mov [bar_left_y],ax
            jmp bar_right_check_movement


    bar_left_move_down:
        mov ax,[bar_vel]
        add [bar_left_y],ax
        mov ax,200
        sub ax,3
        sub ax,[bar_sizey_left]
        cmp [bar_left_y],ax
        jg  fix_bar_left_bottom
        jmp bar_right_check_movement

        fix_bar_left_bottom:
            mov [bar_left_y],ax
            jmp exit_mov

    bar_right_check_movement:

        cmp al,6Fh 
        je bar_right_move_up

        ;verificando qual key foi pressionada
        cmp al,6Ch 
        je bar_right_move_down
        jmp exit_mov

        bar_right_move_up:
            mov ax,[bar_vel]
            sub [bar_right_y],ax

            mov ax,3
            cmp [bar_right_y],ax
            jl fix_padle_right_top
            jmp exit_mov

            fix_padle_right_top:
                mov ax,3
                mov [bar_right_y],ax
                jmp exit_mov

        bar_right_move_down:
            mov ax,[bar_vel]
            add [bar_right_y],ax
        
            mov ax,200
            sub ax,3
            sub ax,[bar_sizey_right]
            cmp [bar_right_y],ax
            jg fix_padle_right_bottom
            jmp exit_mov

            fix_padle_right_bottom:
                mov [bar_right_y],ax
                jmp exit_mov

    exit_mov:

        ret

collision:
    check_right_collision:
        mov ax, [ball_x]
        add ax, ball_size
        cmp ax, 310
        jng check_left_collision
        mov bx, 0
        mov [flag_x], bx  ; Se teve colisão a direita, a flag é 0
        call ball_reset
        call update_game_left

    check_left_collision:
        mov ax, [ball_x]
        sub ax, ball_size
        cmp ax, 0
        jnl check_up_collision
        mov bx, 1
        mov [flag_x], bx ; Se teve colisão a esquerda, a flag é 1
        call ball_reset
        call update_game_right

    check_up_collision:
        mov ax, [ball_y]
        cmp ax, 0
        jnl check_down_collision
        mov bx, 1
        mov [flag_y], bx

    check_down_collision:
        mov ax, [ball_y]
        add ax, ball_size
        cmp ax, 200
        jng moviment_end
        mov bx, 0
        mov [flag_y], bx ; Se teve colisão em baixo, a flag é 0

        
        
    moviment_end:
        ret

walk_x:
        mov bx, [flag_x]
        cmp bx, 1   ;se a flag_x = 1 eh pq eu estou me movendo para a direita
        jne move_left
        move_right:
            mov bx, [ball_x]
            add bx, [bs_x]
            mov [ball_x], bx
            jmp walk_x_end
        move_left:
            mov bx, [ball_x]
            sub bx, [bs_x]
            mov [ball_x], bx
        walk_x_end:
            ret

walk_y:
    mov bx, [flag_y]
    cmp bx, 1 ;se a flag_y = 1 eh pq eu estou me movendo para baixo
    jne move_up
    move_down:
        mov bx, [ball_y]
        add bx, [bs_y]
        mov [ball_y], bx
        jmp walk_y_end
    move_up:
        mov bx, [ball_y]
        sub bx, [bs_y]
        mov [ball_y], bx
    walk_y_end:
        ret

;    para checar se a bola esta batendo na barra, temos:
        ;(Bola_x + tam_bola > barra_x && Bola_x < (barra_x + tam_barra)
        ;&& bola_y + tam_bola > barra_y && bola_y < barra_y + barra_tam

    
        
check_pad_collision:

    check_pad_R_collision:
        mov ax, [ball_x]
        add ax, ball_size
        cmp ax, [bar_right_x]
        jng check_pad_L_collision

        mov ax, [bar_right_x]
        add ax, bar_sizex
        cmp [ball_x], ax
        jnl check_pad_L_collision

        mov ax, [ball_y]
        add ax, ball_size
        cmp ax, [bar_right_y]
        jng check_pad_L_collision

        mov ax, [bar_right_y]
        add ax, [bar_sizey_right]
        cmp [ball_y], ax
        jnl check_pad_L_collision

    negmov:
        mov bx, 0
        mov [flag_x], bx

    check_pad_L_collision: 
        mov ax, [ball_x]
        add ax, ball_size
        cmp ax, [bar_left_x]
        jng pad_end

        mov ax, [bar_left_x]
        add ax, bar_sizex
        cmp [ball_x], ax
        jnl pad_end

        mov ax, [ball_y]
        add ax, ball_size
        cmp ax, [bar_left_y]
        jng pad_end

        mov ax, [bar_left_y]
        add ax, [bar_sizey_left]
        cmp [ball_y], ax
        jnl pad_end

    negmovleft:
        mov bx, 1
        mov [flag_x],bx
        
    pad_end:
        ret    

display_win:
    mov al,[win_left]
    mov bl,[win_right]
    mov cl, 1
    cmp al,cl
    je display_win_left
    display_win_right:
        ;Printa a string
        mov  si, msg_win_right
        ;Move cursor pro meio da tela
        mov cl,0
        mov ah, 02h
        mov bh, 0
        mov dh, 10
        mov dl, 12
        int 10h 
        display_loop_right:
            lodsb
            cmp al,0 
            je end_display
            putc 15
            jmp display_loop_right


    display_win_left:
        cli
        mov  si, msg_win_left
        ;Move o cursor para o meio da tela
        mov cl,0
        mov ah, 02h
        mov bh, 0
        mov dh, 10
        mov dl, 12
        int 10h 

        display_loop_left:
            lodsb
            cmp al,0 
            je end_display
            putc 15
            jmp display_loop_left


    end_display:
        ret

reset_all:
    mov ax, 0
    mov [win_left], ax
    mov [win_right], ax
    mov [score_left], ax
    mov [score_right], ax
    mov ax, 40
    mov [bar_sizey_left], ax
    mov [bar_sizey_right], ax
    mov ax, 156
    mov bx, 96
    mov [ball_init_x], ax
    mov [ball_init_y], bx
    mov ax, 80
    mov [bar_right_y], ax
    mov [bar_left_y],ax 


    ret

menu:
        mov si, title
        mov cl,0
        mov ah, 02h
        mov bh, 0
        mov dh, 5
        mov dl, 17
        int 10h

        loop_title:
            lodsb
            cmp al,0
            je instruction_procedure
            putc 10
            jmp loop_title
        
        instruction_procedure:
            mov si, instruction
            mov cl,0
            mov ah, 02h
            mov bh, 0
            mov dh, 11
            mov dl, 12
            int 10h

            loop_instruction_start:
                lodsb
                cmp al, 0
                je instruction_msg
                putc 14
                jmp loop_instruction_start
        
        instruction_msg:
        mov si, instruction_2
            mov cl,0
            mov ah, 02h
            mov bh, 0
            mov dh, 15
            mov dl, 14
            int 10h

            loop_instruction_msg:
                lodsb
                cmp al, 0
                je rules
                putc 14
                jmp loop_instruction_msg

        rules:
            mov si, ruless
            mov cl,0
            mov ah, 02h
            mov bh, 0
            mov dh, 18
            mov dl, 0
            int 10h

            loop_rules:
                lodsb
                cmp al, '$'
                je wait_to_press
                putc 14
                jmp loop_rules

        wait_to_press:
            mov ah, 00h
            int 16h
            cmp al,'w'
            jne wait_to_press
            call outer_gameloop
                



start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    ;Código do projeto...
    call set_video_mode
    call menu
    outer_gameloop:

        call ball_reset
        inner_gameloop:
            call draw_ball

            call draw_bar_left

            call draw_bar_right
            
            call walk_x ;anda em x

            call walk_y ;anda em y
            
            call move_bar

            call collision

            call check_pad_collision
            ;delay 1, 100
            delay 0, 0x4000
            call clearscreen
            mov ax, [win_left]
            mov bx, [win_right]
            cmp ax,bx
            je inner_gameloop
            call display_win
            delay 50,000
            call clearscreen
            call reset_all
            call menu



jmp $