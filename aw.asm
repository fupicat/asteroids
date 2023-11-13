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
    
    spr_nave_escd   db 00, 00, 00, 01, 01, 09, 09, 09, 00, 00
                    db 00, 00, 01, 01, 09, 09, 09, 09, 09, 00
                    db 00, 00, 01, 01, 09, 11, 15, 15, 15, 15
                    db 01, 09, 01, 01, 09, 11, 15, 15, 15, 15
                    db 01, 09, 01, 01, 09, 11, 11, 11, 11, 11
                    db 01, 09, 01, 01, 09, 09, 09, 09, 09, 00
                    db 01, 01, 01, 01, 09, 09, 09, 09, 09, 00
                    db 01, 01, 01, 01, 09, 01, 01, 01, 09, 00
                    db 00, 00, 01, 01, 09, 00, 01, 01, 09, 00
                    db 00, 00, 01, 01, 01, 00, 01, 01, 01, 00
    
    spr_obst    db 00, 00, 00, 08, 08, 08, 07, 07, 00, 00
                db 00, 08, 08, 08, 08, 07, 08, 07, 07, 00
                db 08, 08, 08, 08, 07, 07, 00, 08, 07, 07
                db 08, 00, 07, 08, 07, 07, 00, 00, 07, 08
                db 08, 00, 00, 08, 07, 08, 07, 07, 07, 07
                db 08, 08, 08, 08, 07, 07, 07, 07, 07, 07
                db 08, 08, 08, 08, 00, 08, 08, 07, 08, 07
                db 00, 08, 08, 08, 00, 08, 08, 07, 07, 07
                db 00, 08, 08, 08, 00, 00, 00, 08, 08, 00
                db 00, 00, 08, 08, 08, 08, 08, 08, 00, 00
    
    spr_vida    db 00, 00, 15, 10, 10, 10, 10, 15, 00, 00
                db 00, 15, 15, 10, 10, 10, 10, 15, 15, 00
                db 15, 15, 10, 10, 10, 10, 10, 10, 15, 15
                db 02, 10, 10, 10, 15, 15, 10, 10, 10, 02
                db 02, 02, 10, 15, 15, 15, 15, 10, 02, 02
                db 02, 02, 02, 02, 15, 15, 02, 02, 02, 02
                db 00, 02, 02, 02, 02, 02, 02, 02, 02, 00
                db 00, 00, 10, 10, 10, 10, 10, 10, 00, 00
                db 00, 00, 15, 15, 15, 15, 15, 15, 00, 00
                db 00, 00, 00, 15, 15, 15, 15, 00, 00, 00
    
    spr_escd    db 15, 15, 00, 00, 15, 15, 00, 00, 15, 15
                db 15, 01, 15, 15, 01, 01, 15, 15, 09, 15
                db 15, 01, 01, 15, 01, 09, 01, 09, 09, 15
                db 15, 01, 01, 15, 01, 01, 09, 09, 09, 15
                db 15, 01, 01, 01, 15, 09, 01, 09, 09, 15
                db 00, 15, 01, 01, 15, 01, 09, 09, 15, 00
                db 00, 15, 01, 01, 01, 15, 01, 09, 15, 00
                db 00, 00, 15, 01, 01, 15, 09, 15, 00, 00
                db 00, 00, 00, 15, 01, 09, 15, 00, 00, 00
                db 00, 00, 00, 00, 15, 15, 00, 00, 00, 00
    
    ; Jogo
    nave_pos   dw 320 * 30 + 30

    ; Inputs
    input_up   db 0
    input_down db 0
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
    push dx ; Salva o DX pois o MUL usa esse registrador.

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
; CX = Largura
; BX = Altura
; DI = Posição
; DL = Cor
draw_rect:
    push di
    push bx
    push cx ; Salva a largura

    draw_rect_loop:
        ; Transfere a cor para a tela.
        mov es:[di], dl
        inc di
        loop draw_rect_loop

        pop cx ; Recupera a largura

        ; Decrementa a altura e verifica se acabou.
        dec bx
        jz draw_rect_end

        ; Passa para a próxima linha.
        add di, 320
        sub di, cx
        push cx ; Salva a largura
        jmp draw_rect_loop

    draw_rect_end:
        pop bx
        pop di
    ret
;
; Desenha um sprite em uma posição
; SI = Endereço do sprite
; DI = Endereço para desenhar
draw_sprite:
    push cx
    push si
    push di
    push bx

    mov cx, spr_size      ; Coloca a largura do sprite no contador.
    mov bx, cx ; Salva a altura do sprite para saber quantas linhas desenhar.

    draw_sprite_loop:
        ; Transfere a imagem do sprite para a tela.
        rep movsb

        ; Decrementa a altura e verifica se acabou.
        dec bx
        jz draw_sprite_end

        ; Passa para a próxima linha.
        add di, 320
        sub di, spr_size
        mov cx, spr_size
        jmp draw_sprite_loop

    draw_sprite_end:
        pop bx
        pop di
        pop si
        pop cx
    ret
;
; Move um sprite em uma direção.
; Preenche a área que o sprite costumava ocupar por preto.
;
; Recebe:
; SI = Endereço do sprite no segmento de dados.
; AX = Direção para mover (0 = cima, 1 = baixo, 2 = esquerda, 3 = direita).
; BX = Quantos pixels mover.
; DX = Posição atual do sprite na memória de vídeo.
;
; Retorna:
; DX = Nova posição do sprite na memória de vídeo.
move_sprite:
    push ax
    push di
    push bx

    cmp bx, 0
    je move_sprite_end

    mov di, dx

    cmp ax, 0
    je move_sprite_up
    cmp ax, 1
    je move_sprite_down
    cmp ax, 2
    je move_sprite_left
    cmp ax, 3
    je move_sprite_right
    jmp move_sprite_end

    ; NOTE: Essas labels ficam aqui no meio da rotina para evitar pulos longos demais.
    move_sprite_finished:
        pop dx ; Traz de volta a nova posição do sprite para retorno.
    move_sprite_end:
        pop bx
        pop di
        pop ax
        ret

    move_sprite_up:
        ; Calcula nova posição
        mov ax, 320
        mul bx
        sub di, ax
        push di ; Salva a nova posição do sprite

        call draw_sprite

        ; Desenha preto atrás do sprite.
        ; Largura = o tamanho do sprite.
        mov cx, spr_size
        ; Calcula posição do retângulo preto a se desenhar.
        ; Desce spr_size pixels a partir da posição nova do sprite.
        ; AKA, desce até o fim do sprite e cobre quantos pixels ele subiu.
        mov ax, 320
        mul spr_size
        add di, ax
        ; Desenha o retângulo
        xor dx, dx
        call draw_rect

        jmp move_sprite_finished
    
    move_sprite_down:
        ; Calcula nova posição
        mov ax, 320
        mul bx
        add di, ax
        push di ; Salva a nova posição do sprite

        call draw_sprite

        ; Desenha preto atrás do sprite.
        ; Largura = o tamanho do sprite.
        mov cx, spr_size
        ; Calcula posição do retângulo preto a se desenhar.
        ; Sobe BX pixels a partir da posição nova do sprite.
        ; AKA, sobe quantos pixels o sprite desceu e cobre essa mesma quantidade de pixels.
        mov ax, 320
        mul bx
        sub di, ax
        ; Desenha o retângulo
        xor dx, dx
        call draw_rect

        jmp move_sprite_finished

    move_sprite_left:
        ; Calcula nova posição
        sub di, bx
        push di ; Salva a nova posição do sprite

        call draw_sprite

        ; Desenha preto atrás do sprite
        ; Largura = a quantidade de pixels andados.
        mov cx, bx
        ; Altura = o tamanho do sprite.
        mov bx, spr_size
        ; Calcula posição do retângulo preto a se desenhar.
        ; Vai spr_size pixels pra direita a partir da posição nova do sprite.
        mov ax, spr_size
        add di, ax
        ; Desenha o retângulo
        xor dx, dx
        call draw_rect

        jmp move_sprite_finished
    
    move_sprite_right:
        ; Calcula nova posição
        add di, bx
        push di ; Salva a nova posição do sprite

        call draw_sprite

        ; Desenha preto atrás do sprite
        ; Largura = a quantidade de pixels andados.
        mov cx, bx
        ; Calcula posição do retângulo preto a se desenhar.
        ; Vai BX pixels pra esquerda a partir da posição nova do sprite.
        sub di, bx
        ; Altura = o tamanho do sprite.
        mov bx, spr_size
        ; Desenha o retângulo
        xor dx, dx
        call draw_rect

        jmp move_sprite_finished
;
; Lê o status das teclas relevantes para o jogo e altera suas entradas na memória.
;
; Retorna:
; input_up = 1 se cima estiver pressionado, 0 se não.
; input_down = 1 se baixo estiver pressionado, 0 se não.
; input_fire = 1 se espaço estiver pressionado, 0 se não.
get_input:
    push ax
    push bx

    ; Há teclas para ler? Se não, pule essa etapa.
    mov ah, 1
    int 16h
    jz input_end

    ; Obtém o status do port 60H (teclado).
    in ax, 60H

    ; Se a tecla cima estiver sendo pressionada...
    cmp al, 48h
    je input_up_pressed
    mov input_up, 0

    cmp al, 50h
    je input_down_pressed
    mov input_down, 0

    input_end:
        pop bx
        pop ax
        ret

    input_up_pressed:
        mov input_up, 1
        jmp input_end
    
    input_down_pressed:
        mov input_down, 1
        jmp input_end
;
; Realiza as ações de cada tecla pressionada
process_input:
    push ax
    push bx
    push si

    mov si, offset spr_nave
    mov dx, nave_pos
    mov bx, 1

    process_input_up:
        cmp input_up, 1
        jne process_input_down
        ; Mover para cima
        xor ax, ax
        call move_sprite
        mov nave_pos, dx
    
    process_input_down:
        cmp input_down, 1
        jne process_input_done
        ; Mover para baixo
        mov ax, 1
        call move_sprite
        mov nave_pos, dx

    process_input_done:
        pop si
        pop bx
        pop ax
        ret
;
; Desenha a cena inicial.
setup_scene:
    mov di, nave_pos
    mov si, offset spr_nave
    call draw_sprite

    ret
;
start_game:
    call setup_scene

    main_loop:
        call get_input

        call process_input

        
        

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
