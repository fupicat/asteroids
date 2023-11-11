; Defines
DELAY_HIGH equ 0000H
DELAY_LOW  equ 3E80H ; 3E80H = 16000 microssegundos, ~60 fps

model small
;
dataseg
    ; Sprites
    spr_size    dw 10

    spr_nave    db 00, 00, 00, 04, 04, 12, 12, 12, 00, 00
                db 00, 00, 04, 04, 12, 12, 12, 12, 12, 00
                db 00, 00, 04, 04, 12, 11, 15, 15, 15, 15
                db 04, 12, 04, 04, 12, 11, 15, 15, 15, 15
                db 04, 12, 04, 04, 12, 11, 11, 11, 11, 11
                db 04, 12, 04, 04, 12, 12, 12, 12, 12, 00
                db 04, 04, 04, 04, 12, 12, 12, 12, 12, 00
                db 04, 04, 04, 04, 12, 04, 04, 04, 12, 00
                db 00, 00, 04, 04, 12, 00, 04, 04, 12, 00
                db 00, 00, 04, 04, 04, 00, 04, 04, 04, 00
    
    ; Utils
    rect_height dw 0
    rect_width  dw 0
;
codeseg
;
; Troca para o modo VGA (320x200, 256 colors) e coloca a posição de memoria VGA no ES.
vga_mode:
    mov ah, 0
    mov al, 13h
    int 10h
    mov ax, 0A000h
    mov es, ax
    ret
;
; Converte uma coordenada cartesiana para uma posição de memória na tela.
; Coordenadas cartesianas têm origem no canto superior esquerdo da tela.
; X vai de 0 a 319
; Y vai de 0 a 199
;
; Recebe:
; BX = X
; AX = Y
;
; Retorna:
; AX = Posição do pixel na tela
cartesian_to_screen:
    push bx
    push cx
    push dx ; Salva o DX pois o MUL usar esse registrador.

    mov cx, 320
    mul cx
    add ax, bx

    pop dx
    pop cx
    pop bx
    ret
;
; Pausa o programa por um número de microssegundos.
; CXDX = Microssegundos
delay:
    push ax

    mov ah, 86H
    int 15H

    pop ax
    ret
;
; Desenha um único pixel.
;
; Recebe:
; BX = X
; AX = Y
; DL = Cor
draw_pixel:
    push ax

    call cartesian_to_screen
    mov di, ax
    mov es:[di], dl

    pop ax
    ret
;
; Recebe uma cor e pinta o fundo inteiro com ela:
; DL = Cor
draw_bg_color:
    push cx
    push di

    mov cx, 64000
    xor di, di
    
    draw_bg_color_loop:
        mov es:[di], dl
        inc di
        loop draw_bg_color_loop
    
    pop di
    pop cx
    ret
;
; Desenha um retângulo
; BX = X
; AX = Y
; DL = Cor
; RECT_HEIGHT = Altura
; RECT_WIDTH = Largura
draw_rect:
    push ax
    push bx
    push cx
    push dx

    mov cx, [rect_width]

    draw_rect_loop:
        call draw_pixel
        inc bx
        loop draw_rect_loop
        mov cx, [rect_height]
        dec cx
        jz draw_rect_end
        mov [rect_height], cx
        inc ax
        mov cx, [rect_width]
        sub bx, cx
        call draw_pixel
        inc bx
        loop draw_rect_loop
    
    draw_rect_end:
        pop dx
        pop cx
        pop bx
        pop ax
    ret
;
; Desenha um sprite em uma posição
; BX = X
; AX = Y
; SI = Endereço do sprite
draw_sprite:
    push ax
    push cx
    push si

    call cartesian_to_screen
    mov di, ax            ; Coloca a posição para desenhar no registrador de destino.
    mov cx, spr_size      ; Coloca a largura do sprite no contador.
    mov [rect_height], cx ; Salva a altura do sprite para saber quantas linhas desenhar.

    draw_sprite_loop:
        ; Transfere a imagem do sprite para a tela.
        movsb
        loop draw_sprite_loop

        ; Incrementa a fonte e o destino para prepará-los para a próxima linha.
        inc si
        inc di

        ; Decrementa a altura e verifica se acabou.
        mov cx, [rect_height]
        dec cx
        jz draw_sprite_end
        mov [rect_height], cx

        ; Passa para a próxima linha.
        add di, 320
        sub di, [spr_size]
        mov cx, spr_size
        loop draw_sprite_loop

    draw_sprite_end:
        pop si
        pop cx
        pop ax
    ret
;
start_game:
    mov bx, 30
    mov ax, 30
    mov si, offset spr_nave

    main_loop:
        call draw_sprite
        add ax, 10

        mov cx, DELAY_HIGH
        mov dx, DELAY_LOW
        call delay
        jmp main_loop

    ret
;
start:
    ; Configura o segmento de dados
    mov ax, @data
    mov ds, ax

    call vga_mode

    call start_game

    ; Por enquanto isso não faz nada porque o loop do jogo executa pra sempre, só copiei de um template.
    input_loop:
        mov ah, 0        ; 0 - keyboard BIOS function to get keyboard scancode
        int 16h          ; keyboard interrupt
        jz input_loop    ; if 0 (no button pressed) jump to input_loop
        
        mov ah, 0  ; Restore
        mov al, 3  ; textmode
        int 10h    ; for DOS

        mov   ah, 4Ch
        mov   al, 0
        int   21h

end start
