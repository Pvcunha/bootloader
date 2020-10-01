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

    bar_left_x dw 0    ;pos x
    bar_left_y dw 80    ;pos y

    bar_right_x dw 306    ;pos x
    bar_right_y dw 80    ;pos y
    bar_sizex equ 4     ;tamanho da bola 
    bar_sizey equ 40

    pad_size_x equ 3 ; tamanho do pad em x
    pad_size_y equ 9 ; tamanho do pad em y
    
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


ball_reset:                 ;seta a bola nas posições iniciais 
    mov ax, [ball_init_x] 
    mov bx, [ball_init_y]

    mov [ball_x], ax
    mov [ball_y], bx
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
        cmp ax, bar_sizey
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
        cmp ax, bar_sizey
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
        sub ax,bar_sizey
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
            sub ax,bar_sizey
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

    check_left_collision:
        mov ax, [ball_x]
        sub ax, ball_size
        cmp ax, 0
        jnl check_up_collision
        mov bx, 1
        mov [flag_x], bx ; Se teve colisão a esquerda, a flag é 1
        call ball_reset

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

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    ;Código do projeto...
    call set_video_mode

    call ball_reset
    check_time:
        call draw_ball

        call draw_bar_left

        call draw_bar_right
        
        call walk_x ;anda em x

        call walk_y ;anda em y

        call move_bar
        

        call collision

        ;delay 1, 100
        delay 0, 0x4000
        call clearscreen
        jmp check_time


jmp $