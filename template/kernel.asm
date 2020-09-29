org 0x7e00
jmp 0x0000:start



set_videomode:
    
    mov ax, 13h
    int 10h
    ret

set_initial_values:
    mov ax, 0A000h ; offset
    mov es, ax ; Guarda no es o valor do offset
    mov ax, 0 ; Coloca o pixel no canto superior esquerdo da tela
    mov di, ax ; faz o di apontar pro ax
    mov dl, 7; Cor do pixel
    mov [es:di], dl ; põe o pixel
    ret


putpixel: ; argumentos : x-pos, y-pos, cor
    
    push bp
    mov bp, sp

    mov ax, 0A000h ; offset
    mov es, ax ; Guarda no es o valor do offset
    
    mov ax, [bp+6] ; y-pos

    mov cx,320
    mul cx    
    add ax, [bp+8]
    mov di, ax ; faz o di apontar pro ax
    mov dl, [bp+4]
    ;mov di, ax ; faz o di apontar pro ax
    mov [es:di], dl ; põe o pixel


    mov sp, bp
    pop bp
    ret

%macro draw_pixel 3 ; (x,y,color)

pusha
push %1 ; x-pos
push %2 ; y-pos
push %3 ; color
call putpixel
add sp,6
popa

%endmacro



;draw_player: ; (x_begin,y_begin,color) -> dimension 3X9

;    push bp
;   mov bp, sp

;    mov bx, 
;    mov cx,0
;    loop_x:
;        add bx,cx 
;        draw_pixel bx, %2, %3
;        sub bx,cx
;        inc cx
;        cmp cx,3 ; 3 = x-dimension 
;        je loop_x
;    mov cx,0
;    mov ax, %2
;loop_y:
;    add ax,cx
;    draw_pixel %1, ax, %3
;    sub ax, cx
;    inc cx
;    cmp cx,9 ; 9 = y-dimension 
;    je loop_y

;    mov sp, bp
;    pop bp
;    ret


data:
	
	;Dados do projeto...



start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    ;Código do projeto...

    call set_videomode
    ;call set_initial_values
    mov bx,0
    mov ax,0
    mov dx, 7
    
    draw_pixel 10, 2, 7

    loopMain:
        draw_pixel bx, ax, dx
        inc ax
        inc bx
        jmp loopMain

   

jmp $