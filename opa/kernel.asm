org 0x7e00
jmp 0x0000:start

data:
	ball_x dw 10    ;pos x
    ball_y dw 10    ;pos y
    ball_size equ 4     ;tamanho da bola
    pad_size_x equ 3 ; tamanho do pad em x
    pad_size_y equ 9 ; tamanho do pad em y
    aux db 0      ;vai checar o tempo

    bs_x dw 5
    bs_y dw 5
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

move_ball:


collision:
    check_right_collision:
        mov ax, [ball_x]
        add ax, ball_size
        cmp ax, 310
        jng check_left_collision
        mov bx, 0
        mov [flag_x], bx  ; Se teve colisão a direita, a flag é 0
    
    check_left_collision:
        mov ax, [ball_x]
        sub ax, ball_size
        cmp ax, 0
        jnl check_up_collision
        mov bx, 1
        mov [flag_x], bx ; Se teve colisão a esquerda, a flag é 1

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

    check_time:
        call draw_ball
        
        call walk_x ;anda em x

        call walk_y ;anda em y

        call collision

        delay 1, 100
        ;delay 0, 0x4000
        call clearscreen
        jmp check_time


jmp $