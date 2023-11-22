; Opções
    DELAY_LOW       equ 0C350H ; 3E80H = 16000 microssegundos, ~60 fps
    MAX_OBJS        equ 16 ; O número máximo de objetos que podem existir ao mesmo tempo.
    SPEED           equ 2 ; A velocidade da nave, obstáculos e poderes.
    TIRO_MAX_DELAY  equ 4
    UI_PANEL_Y      equ 180
;
; Defines
    CR              equ 13
    LF              equ 10

    MENU_SPRITES    equ 320 * (105) + SPR_SIZE * (320 / 2 / SPR_SIZE) - 7 * SPR_SIZE ; ehuahea colocar sprites do menu no meio da tela

    UI_BARRA_MAX     equ 10
    UI_PANEL_POS     equ 320 * (UI_PANEL_Y)
    UI_PANEL_HEIGHT  equ 200 - UI_PANEL_Y
    UI_TEMPO_POS     equ 320 * (UI_PANEL_Y + 5) + 5
    UI_VIDA_POS      equ 320 * (UI_PANEL_Y + 5) + 216
    UI_BARRA_HEIGHT  equ SPR_SIZE
    UI_BARRA_WIDTH   equ SPR_SIZE * UI_BARRA_MAX
    UI_BARRA_MAX_POS equ UI_BARRA_WIDTH - SPR_SIZE ; Adicione isso à posição da barra para obter o endereço de memória para começar a apagá-la.
    UI_BOTAO_POS     equ 320 * (UI_PANEL_Y + 5) + (160 - SPR_SIZE / 2)

    SPR_SIZE        equ 10

    INIT_NAVE_POS   equ 320 * (100 - SPR_SIZE / 2) + (160 - SPR_SIZE / 2)
    FRENTE_NAVE     equ 320 * (SPR_SIZE / 2) + SPR_SIZE ; Adicione isso à posição da nave para spawnar o tiro na frente dela.
    NAVE_MIN_Y      equ 320 * SPEED
    NAVE_MAX_Y      equ UI_PANEL_POS - 320 * (SPR_SIZE + SPEED)

    SPEED_TIRO      equ SPEED * 2
    LIFETIME_TIRO   equ (320 - 160 - SPR_SIZE / 2) / SPEED_TIRO
    LIFETIME_OBST   equ (320 - SPR_SIZE / 2) / SPEED - SPEED
;
; Enums
    OBJ_NULL    equ 0
    OBJ_TIRO    equ 1
    OBJ_OBST    equ 2
    OBJ_VIDA    equ 3
    OBJ_ESCD    equ 4
    MENU_JOGAR  equ 0
    MENU_SAIR   equ 1
;
model small
;
dataseg
    ; Textos
    str_logo    db "     ___       __               _    __", CR, LF
                db "    / _ | ___ / /____ _______  (_)__/ /", CR, LF
                db "   / __ |(_-</ __/ -_) __/ _ \/ / _  /", CR, LF
                db "  /_/ |_/___/\__/\__/_/  \___/_/\_,_/", CR, LF
                db "           _      __", CR, LF
                db "          | | /| / /__ ___ __", CR, LF
                db "          | |/ |/ / _ `/ // /", CR, LF
                db "          |__/|__/\_,_/\_, /", CR, LF
                db "                      /___/", CR, LF
    len_str_logo equ $ - str_logo

    str_jogar   db "               [ Jogar ]", CR, LF, CR, LF
                db "                 Sair   "
    len_str_jogar equ $ - str_jogar

    str_sair    db "                 Jogar  ", CR, LF, CR, LF
                db "               [ Sair  ]"
    len_str_sair equ $ - str_sair

    ; Sprites
    spr_nave        db 00, 00, 00, 04, 04, 12, 12, 12, 00, 00
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
    
    spr_obst        db 00, 00, 00, 08, 08, 08, 07, 07, 00, 00
                    db 00, 08, 08, 08, 08, 07, 08, 07, 07, 00
                    db 08, 08, 08, 08, 07, 07, 00, 08, 07, 07
                    db 08, 00, 07, 08, 07, 07, 00, 00, 07, 08
                    db 08, 00, 00, 08, 07, 08, 07, 07, 07, 07
                    db 08, 08, 08, 08, 07, 07, 07, 07, 07, 07
                    db 08, 08, 08, 08, 00, 08, 08, 07, 08, 07
                    db 00, 08, 08, 08, 00, 08, 08, 07, 07, 07
                    db 00, 08, 08, 08, 00, 00, 00, 08, 08, 00
                    db 00, 00, 08, 08, 08, 08, 08, 08, 00, 00
    
    spr_vida        db 00, 00, 15, 10, 10, 10, 10, 15, 00, 00
                    db 00, 15, 15, 10, 10, 10, 10, 15, 15, 00
                    db 15, 15, 10, 10, 10, 10, 10, 10, 15, 15
                    db 02, 10, 10, 10, 15, 15, 10, 10, 10, 02
                    db 02, 02, 10, 15, 15, 15, 15, 10, 02, 02
                    db 02, 02, 02, 02, 15, 15, 02, 02, 02, 02
                    db 00, 02, 02, 02, 02, 02, 02, 02, 02, 00
                    db 00, 00, 10, 10, 10, 10, 10, 10, 00, 00
                    db 00, 00, 15, 15, 15, 15, 15, 15, 00, 00
                    db 00, 00, 00, 15, 15, 15, 15, 00, 00, 00
    
    spr_escd        db 15, 15, 00, 00, 15, 15, 00, 00, 15, 15
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
    nave_pos   dw INIT_NAVE_POS
    
    tiro_delay db 0

    tempo_pos  dw UI_TEMPO_POS + UI_BARRA_MAX_POS

    ; Array de objetos:
    ; 16 objetos podem existir no plano do jogo ao mesmo tempo.
    ;
    ; Cada objeto é composto por:
    ; - Seu tipo (0 = vazio, 1 = tiro, 2 = obstaculo, 3 = vida, 4 = escudo)
    ; - Sua posição na tela (deslocamento na memória)
    ; - Seu tempo de vida, por quantos frames ele deve durar.
    objects    dw MAX_OBJS dup(0, 0, 0)

    ; Inputs
    input_up   db 0
    input_down db 0
    input_fire db 0

    menu_selection db 0
;
codeseg
;
; Troca para o modo CGA (320x200, 256 colors) e coloca a posição de memoria CGA no ES.
cga_mode:
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
; Converte posição de memória na tela para uma coordenada cartesiana.
; Coordenadas cartesianas têm origem no canto superior esquerdo da tela.
; X vai de 0 a 319
; Y vai de 0 a 199
;
; Recebe:
; DI = Posição do pixel na tela
;
; Retorna:
; BX = X
; AX = Y
screen_to_cartesian:
    push cx
    push dx

    mov ax, di

    ; Divide a posição na tela pela largura da tela.
    ; Resultado = Y
    ; Resto = X
    xor dx, dx
    mov cx, 320
    div cx
    mov bx, dx

    pop dx
    pop cx
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
; DI = Posição na memória CGA.
; DL = Cor
draw_pixel:
    mov es:[di], dl
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
;
; Recebe:
; SI = Endereço do sprite
; DI = Endereço para desenhar
draw_sprite:
    push cx
    push si
    push di
    push bx

    mov cx, SPR_SIZE      ; Coloca a largura do sprite no contador.
    mov bx, cx ; Salva a altura do sprite para saber quantas linhas desenhar.

    draw_sprite_loop:
        ; Transfere a imagem do sprite para a tela.
        rep movsb

        ; Decrementa a altura e verifica se acabou.
        dec bx
        jz draw_sprite_end

        ; Passa para a próxima linha.
        add di, 320
        sub di, SPR_SIZE
        mov cx, SPR_SIZE
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
; DI = Posição atual do sprite na memória de vídeo.
;
; Retorna:
; DI = Nova posição do sprite na memória de vídeo.
move_sprite:
    push ax
    push bx

    cmp bx, 0
    je move_sprite_end

    cmp ax, 0
    je move_sprite_up
    cmp ax, 1
    je move_sprite_down
    cmp ax, 2
    je move_sprite_left
    cmp ax, 3
    je move_sprite_right
    jmp move_sprite_end

    ; NOTA: Essa label fica aqui no meio da rotina para evitar pulos longos demais.
    move_sprite_end:
        pop bx
        pop ax
        ret

    move_sprite_up:
        ; Calcula nova posição
        mov ax, 320
        mul bx
        sub di, ax
        push di ; Salva nova posição

        call draw_sprite

        ; Desenha preto atrás do sprite.
        ; Largura = o tamanho do sprite.
        mov cx, SPR_SIZE
        ; Calcula posição do retângulo preto a se desenhar.
        ; Desce SPR_SIZE pixels a partir da posição nova do sprite.
        ; AKA, desce até o fim do sprite e cobre quantos pixels ele subiu.
        mov ax, 320
        push bx
        mov bx, SPR_SIZE
        mul bx
        add di, ax
        pop bx
        ; Desenha o retângulo
        xor dx, dx
        call draw_rect
        pop di ; Recupera nova posição

        jmp move_sprite_end
    
    move_sprite_down:
        ; Calcula nova posição
        mov ax, 320
        mul bx
        add di, ax
        push di ; Salva nova posição

        call draw_sprite

        ; Desenha preto atrás do sprite.
        ; Largura = o tamanho do sprite.
        mov cx, SPR_SIZE
        ; Calcula posição do retângulo preto a se desenhar.
        ; Sobe BX pixels a partir da posição nova do sprite.
        ; AKA, sobe quantos pixels o sprite desceu e cobre essa mesma quantidade de pixels.
        mov ax, 320
        mul bx
        sub di, ax
        ; Desenha o retângulo
        xor dx, dx
        call draw_rect
        pop di ; Recupera nova posição

        jmp move_sprite_end

    move_sprite_left:
        ; Calcula nova posição
        sub di, bx
        push di ; Salva nova posição

        call draw_sprite

        ; Desenha preto atrás do sprite
        ; Largura = a quantidade de pixels andados.
        mov cx, bx
        ; Altura = o tamanho do sprite.
        mov bx, SPR_SIZE
        ; Calcula posição do retângulo preto a se desenhar.
        ; Vai SPR_SIZE pixels pra direita a partir da posição nova do sprite.
        mov ax, SPR_SIZE
        add di, ax
        ; Desenha o retângulo
        xor dx, dx
        call draw_rect
        pop di ; Recupera nova posição

        jmp move_sprite_end
    
    move_sprite_right:
        ; Calcula nova posição
        add di, bx
        push di ; Salva nova posição

        call draw_sprite

        ; Desenha preto atrás do sprite
        ; Largura = a quantidade de pixels andados.
        mov cx, bx
        ; Calcula posição do retângulo preto a se desenhar.
        ; Vai BX pixels pra esquerda a partir da posição nova do sprite.
        sub di, bx
        ; Altura = o tamanho do sprite.
        mov bx, SPR_SIZE
        ; Desenha o retângulo
        xor dx, dx
        call draw_rect
        pop di ; Recupera nova posição.

        jmp move_sprite_end
;
; Cria um objeto em uma posição livre na array de objetos.
; Se não houver espaço, o objeto não será criado.
;
; Recebe:
; AX = Tipo do objeto.
spawn_object:
    push ax
    push bx
    push cx
    push di
    push dx

    mov bx, offset objects
    mov cx, MAX_OBJS

    spawn_object_loop:
        ; Vê se há espaço para criar o objeto.
        cmp word ptr [bx], 0
        je spawn_object_found
        ; Adiciona 6 para ir para o próximo objeto,
        ; Já que cada entrada de objeto é de 3 words, AKA 6 bytes.
        add bx, 6
        loop spawn_object_loop
    ; Oh no... não houve espaço para criar o objeto. ;(
    
    spawn_object_end:
        pop dx
        pop di
        pop cx
        pop bx
        pop ax
        ret
    
    spawn_object_found:
        ; Move o tipo do objeto para a array.
        mov word ptr [bx], ax
        ; Dependendo do tipo do objeto, faz algo diferente...
        cmp ax, OBJ_TIRO
        je spawn_object_tiro
        cmp ax, OBJ_OBST
        je spawn_object_obst
        cmp ax, OBJ_VIDA
        je spawn_object_vida
        cmp ax, OBJ_ESCD
        je spawn_object_escd
        ; Nenhum dos tipos?? Zere a posição.
        xor ax, ax
        jmp spawn_object_end
    
    spawn_object_tiro:
        call spawn_tiro
        jmp spawn_object_end
    
    spawn_object_obst:
        call spawn_obst
        jmp spawn_object_end
    
    spawn_object_vida:
        jmp spawn_object_end
    
    spawn_object_escd:
        jmp spawn_object_end

;
; Cria um objeto de tiro.
;
; Recebe:
; BX = Posição do objeto na array de objetos.
spawn_tiro:
    push ax
    push dx
    push di

    ; O tiro deve ser spawnado na frente da nave.
    mov di, nave_pos
    add di, FRENTE_NAVE
    ; Desenhe um único ponto branco nessa posição.
    mov dl, 15
    call draw_pixel
    ; Mova a posição para a memória
    mov word ptr [bx+2], di
    ; Move o tempo de vida do tiro.
    mov ax, LIFETIME_TIRO
    mov word ptr [bx+4], ax

    pop di
    pop dx
    pop ax
    ret
;
; Cria um objeto de obstáculo.
;
; Recebe:
; BX = Posição do objeto na array de objetos.
spawn_obst:
    push ax
    push dx
    push di
    push si

    ; O obstáculo deve ser spawnado em uma posição aleatória.
    mov di, 320 * 30 + 310 ; Temporário
    ; Desenhe o sprite do obstáculo.
    mov si, offset spr_obst
    call draw_sprite
    ; Mova a posição para a memória
    mov word ptr [bx+2], di
    ; Move o tempo de vida do obstáculo.
    mov ax, LIFETIME_OBST
    mov word ptr [bx+4], ax

    pop si
    pop di
    pop dx
    pop ax
    ret
;
; Remove um objeto, da memória e da tela.
;
; Recebe:
; BX = Posição do objeto na array de objetos.
remove_object:
    push ax
    push bx
    push cx
    push dx
    push di

    cmp word ptr [bx], OBJ_TIRO
    je remove_object_tiro
    cmp word ptr [bx], OBJ_OBST
    je remove_object_sprite
    cmp word ptr [bx], OBJ_VIDA
    je remove_object_sprite
    cmp word ptr [bx], OBJ_ESCD
    je remove_object_sprite

    remove_object_end:
        ; Deleta o objeto da memória.
        mov word ptr [bx], OBJ_NULL
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    
    remove_object_tiro:
        ; Desenha um único pixel preto na posição do tiro.
        mov di, word ptr [bx+2]
        mov dl, 0
        call draw_pixel
        jmp remove_object_end
    
    remove_object_sprite:
        push bx ; Salva posição do objeto na memória.
        ; Desenha um quadrado preto sobre qualquer sprite.
        mov di, word ptr [bx+2]
        mov dl, 0
        mov cx, SPR_SIZE
        mov bx, SPR_SIZE
        call draw_rect
        pop bx ; Recupera posição do objeto na memória.
        jmp remove_object_end
;
; Realiza as ações dos objetos no campo de jogo.
process_objects:
    push ax
    push bx
    push cx
    push dx

    ; Vamos passar por todos os objetos para agir.
    mov bx, offset objects
    mov cx, MAX_OBJS

    process_objects_loop:
        ; Há um objeto aqui?
        cmp word ptr [bx], 0
        jne process_objects_found
        process_objects_continue:
            ; Adiciona 6 para ir para o último objeto,
            ; Já que cada entrada de objeto é de 3 words, AKA 6 bytes.
            add bx, 6
            loop process_objects_loop
    
    process_objects_end:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    
    process_objects_found:
        ; Obtém o tipo do objeto.
        mov ax, word ptr [bx]

        ; Decrementa o valor de vida do objeto.
        dec word ptr [bx+4]
        ; Se o valor de vida agora for zero, remove o objeto.
        jz process_objects_remove

        cmp ax, OBJ_TIRO
        je process_objects_tiro
        cmp ax, OBJ_OBST
        je process_objects_obst
        cmp ax, OBJ_VIDA
        je process_objects_vida
        cmp ax, OBJ_ESCD
        je process_objects_escd
    
    process_objects_tiro:
        call process_tiro
        jmp process_objects_continue
    
    process_objects_obst:
        call process_obst
        jmp process_objects_continue

    process_objects_vida:
        jmp process_objects_continue
    
    process_objects_escd:
        jmp process_objects_continue
    
    process_objects_remove:
        call remove_object
        jmp process_objects_continue
;
; Realiza as ações de um tiro no campo de jogo.
;
; Recebe:
; BX = Posição da entrada do objeto na array de objetos.
process_tiro:
    push ax
    push bx
    push di
    push dx
    push cx

    ; Primeiro, vamos obter a posição atual do tiro.
    mov di, word ptr [bx+2]
    ; Cobre a posição atual com preto.
    mov dl, 0
    call draw_pixel

    ; Move o tiro.
    add di, SPEED_TIRO

    ; Desenha o tiro na nova posição.
    mov dl, 15
    call draw_pixel

    ; Atualiza a posição na array de objeto.
    mov word ptr [bx+2], di

    pop cx
    pop dx
    pop di
    pop bx
    pop ax
    ret
;
; Realiza as ações de um obstáculo no campo de jogo.
;
; Recebe:
; BX = Posição da entrada do objeto na array de objetos.
process_obst:
    push ax
    push bx
    push di
    push si
    push cx

    ; Primeiro, vamos obter a posição atual do obstáculo.
    mov di, word ptr [bx+2]
    push bx
    
    ; Move o obstáculo para a esquerda.
    mov si, offset spr_obst
    mov ax, 2
    mov bx, SPEED
    call move_sprite

    ; Atualiza a posição na array de objeto.
    pop bx
    mov word ptr [bx+2], di

    pop cx
    pop si
    pop di
    pop bx
    pop ax
    ret
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

    ; Se a tecla baixo estiver sendo pressionada...
    cmp al, 50h
    je input_down_pressed
    mov input_down, 0

    ; Se a tecla espaço estiver sendo pressionada...
    ; mov ah, 0
    ; int 16h
    cmp al, 39h
    je input_fire_pressed
    mov input_fire, 0

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

    input_fire_pressed:
        mov input_fire, 1
        jmp input_end
;
; Realiza as ações de cada tecla pressionada
process_input:
    push ax
    push bx
    push si
    push di

    mov si, offset spr_nave
    mov di, nave_pos
    mov bx, SPEED

    ; Decrementa o delay de tiro
    cmp tiro_delay, 0
    je process_input_up
    dec tiro_delay

    process_input_up:
        ; Se cima estiver pressionado...
        cmp input_up, 1
        jne process_input_down
        ; Primeiro, cheque se a nave não está no limite.
        cmp nave_pos, NAVE_MIN_Y
        jbe process_input_down ; JBE = JUMP IF BELOW OR EQUAL, comparação sem sinal.
        ; Mover para cima
        xor ax, ax
        call move_sprite
        mov nave_pos, di
    
    process_input_down:
        cmp input_down, 1
        jne process_input_fire
        ; Primeiro, cheque se a nave não está no limite.
        cmp nave_pos, NAVE_MAX_Y
        jae process_input_fire ; JAE = JUMP IF AFTER OR EQUAL, comparação sem sinal.
        ; Mover para baixo
        mov ax, 1
        call move_sprite
        mov nave_pos, di
    
    process_input_fire:
        cmp input_fire, 1
        jne process_input_done
        ; Primeiro, vemos se o tiro não está em delay.
        cmp tiro_delay, 0
        jne process_input_done
        ; Atirar
        mov ax, OBJ_TIRO
        call spawn_object
        mov input_fire, 0
        mov tiro_delay, TIRO_MAX_DELAY

    process_input_done:
        pop di
        pop si
        pop bx
        pop ax
        ret
;
; Desenha uma barra de status.
;
; Recebe:
; DI = Posição da barra.
; DL = Cor da barra.
; DH = Cor da sombra da barra.
draw_status_bar:
    push ax
    push bx
    push cx
    push dx
    push di

    mov ax, dx

    ; Fundo
    mov cx, UI_BARRA_WIDTH
    mov bx, UI_BARRA_HEIGHT
    xor dl, dl
    call draw_rect
    ; Cor
    sub cx, 2
    sub bx, 2
    add di, 320 + 1
    mov dl, al
    call draw_rect
    ; Brilho
    sub cx, 4
    mov bx, 1
    add di, 320 + 2
    mov dl, 15
    call draw_rect
    ; Sombra
    mov bx, 3
    add di, 320 * 3
    mov dl, ah
    call draw_rect

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
;
; Decrementa uma barra de status.
;
; Recebe:
; DI = Posição preenchida da barra.
;
; Retorna:
; DI = Nova posição preenchida da barra.
decrement_status_bar:
    ; Desenha um retângulo
    ; CX = Largura
    ; BX = Altura
    ; DI = Posição
    ; DL = Cor
    push bx
    push cx
    push dx

    mov cx, SPR_SIZE
    mov bx, cx
    xor dl, dl
    call draw_rect

    sub di, cx

    pop dx
    pop cx
    pop bx
    ret
;
; Desenha a cena inicial.
setup_scene:
    ; Desenha a nave
    mov di, nave_pos
    mov si, offset spr_nave
    call draw_sprite

    ; Desenha a interface.
    ; Painel
    mov di, UI_PANEL_POS
    mov dl, 15
    mov cx, 320
    setup_scene_panel_white_loop:
        call draw_pixel
        inc di
        loop setup_scene_panel_white_loop
    
    mov di, UI_PANEL_POS + 320
    mov dl, 8
    mov cx, 320 * (UI_PANEL_HEIGHT - 1)
    setup_scene_panel_loop:
        call draw_pixel
        inc di
        loop setup_scene_panel_loop
    
    ; Barra de tempo
    mov di, UI_TEMPO_POS
    mov dl, 11
    mov dh, 3
    call draw_status_bar

    ; Barra de vida
    mov di, UI_VIDA_POS
    mov dl, 10
    mov dh, 2
    call draw_status_bar

    ; Botão decorativo
    mov di, UI_BOTAO_POS
    ; Fundo
    mov cx, 10
    mov bx, 10
    xor dl, dl
    call draw_rect
    ; Cor
    sub cx, 2
    sub bx, 2
    add di, 320 + 1
    mov dl, 4
    call draw_rect
    ; Brilho 1
    sub cx, 2
    sub bx, 2
    mov dl, 12
    call draw_rect
    ; Sombra
    mov cx, 3
    mov bx, 3
    add di, 320 + 1
    mov dl, 15
    call draw_rect

    ret
;
start_game:
    ; Desenha os primeiros elementos da cena.
    call setup_scene

    mov ax, OBJ_OBST
    call spawn_object

    ; Entrando no loop principal do jogo...
    main_loop:
        ; Primeiro, obtém os controles do jogador.
        call get_input

        ; Segundo, faz as ações de cada tecla pressionada.
        call process_input

        ; Terceiro, realiza as ações dos objetos.
        call process_objects

        xor cx, cx
        mov dx, DELAY_LOW
        call delay
        jmp main_loop

    ret
;
main_menu:
    push ax
    push bx
    push cx
    push dx
    push es
    push bp

    ; Primeiro, vamos desenhar os sprites.
    mov di, MENU_SPRITES
    mov si, offset spr_nave
    call draw_sprite

    add di, SPR_SIZE * 4
    mov si, offset spr_obst
    call draw_sprite

    add di, SPR_SIZE * 4
    mov si, offset spr_vida
    call draw_sprite

    add di, SPR_SIZE * 4
    mov si, offset spr_escd
    call draw_sprite

    mov ax, @data
    mov es, ax              ; String tem que estar no ES.
    mov ah, 13h             ; Imprimir string.
    xor al, al              ; Só caracteres.
    xor bh, bh              ; Página de vídeo 0

    ; Logo
    xor dl, dl              ; X = 0
    mov dh, 2               ; Y = 2
    mov bl, 0CH             ; Cor vermelho claro.
    mov cx, len_str_logo    ; Tamanho da string
    mov bp, offset str_logo ; String para escrever.
    int 10h

    ; Opções
    mov dh, 17
    mov bl, 0FH
    mov cx, len_str_jogar
    mov bp, offset str_jogar
    int 10h

    main_menu_loop:
        ; Espere por uma tecla pressionada.
        mov ah, 0
        int 16h

        ; Se a tecla for enter
        cmp ah, 1Ch
        je main_menu_selected

        ; Se a tecla for cima
        cmp ah, 48h
        je main_menu_up

        ; Se a tecla for baixo
        cmp ah, 50h
        je main_menu_down

        jmp main_menu_loop
    
    main_menu_selected:
        cmp menu_selection, MENU_SAIR
        je main_menu_sair

        pop bp
        pop es
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    
    main_menu_sair:
        call end_program
    
    main_menu_up:
        mov menu_selection, MENU_JOGAR

        ; Desenha o texto.
        mov ah, 13h
        mov cx, len_str_jogar
        mov bp, offset str_jogar
        int 10h

        jmp main_menu_loop
    
    main_menu_down:
        mov menu_selection, MENU_SAIR

        ; Desenha o texto.
        mov ah, 13h
        mov cx, len_str_sair
        mov bp, offset str_sair
        int 10h

        jmp main_menu_loop
;
; Finaliza o programa. Retorna para o modo de texto do DOS e devolve o comando para o OS.
end_program:
    mov ah, 0
    mov al, 3
    int 10h

    mov   ah, 4Ch
    mov   al, 0
    int   21h
    ret
;
start:
    ; Configura o segmento de dados
    mov ax, @data
    mov ds, ax

    call cga_mode

    ; Ativa o menu. Comente para pular.
    ; call main_menu

    xor dl, dl
    call draw_bg_color

    call start_game
    
    call end_program

end start
