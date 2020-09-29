org 0x7e00
jmp 0x0000:start

data:
	ball_x equ 10    ;pos x
    ball_y equ 10    ;pos y
    ball_size equ 4     ;tamanho da bola


set_video_mode:
    mov ah, 00h     ;transforma para modo video
    mov al, 13h     ;escolhe o modo video
    int 10h         ;executa a conf

    mov ah, 00h     ;transforma para modo video
    mov al, 13h     ;escolhe o modo video
    int 10h         ;executa a conf
    ret


draw_ball:
    mov cx, ball_x  ;determina pos inicial da coluna (x)
    mov dx, ball_y  ;determina posinicial da linha (y)

    horizontal_loop:
        mov ah, 0Ch     ;coloca no modo de escrever pixel
        mov al, 15      ;determina a cor do pixel
        mov bh, 00h     ;determina o numero da pagina
        int 10h
        
        inc cx          ;incrementa coluna
        
        mov ax, cx      ; se cx - pos_x inicial > ball_size então uma linha foi completada 
        sub ax, ball_x
        cmp ax, ball_size
        jng horizontal_loop ; se a comparacao nao for maior ele continua o loop horizontal (jump if not greater)
        
        mov cx, ball_x
        inc dx              ; se dx - ball_y > ball_size the drawing is complete
        mov ax, dx
        sub ax, ball_y
        cmp ax, ball_size
        jng horizontal_loop     ;se nao for maior passamos para a prox coluna

    ret



start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    ;Código do projeto...
    call set_video_mode
    call draw_ball



jmp $