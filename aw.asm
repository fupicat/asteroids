; Opções
    FPS             equ 20  ; 20 fps = 50ms por frame
    MAX_OBJS        equ 24  ; O número máximo de objetos que podem existir ao mesmo tempo.
    SPEED           equ 2   ; A velocidade da nave, e velocidade inicial dos obstáculos e poderes.
    TIRO_MAX_DELAY  equ 4   ; Quantos frames de delay entre tiros ao segurar a barra de espaço.
    UI_PANEL_Y      equ 180 ; A posição Y onde o painel da interface começa.
    SPAWN_DELAY     equ 10  ; Quantos frames esperar entre spawn de obstáculos e power ups.
    HIT_POINTS      equ 10  ; Quantas chances a nave tem de bater num obstáculo antes de perder.
    VIDA_CHANCE     equ 5   ; Chance de spawnar um power up de vida ao invés de um obstáculo. Ex: 5 = chance de 1 de 5.
    ESCD_SPAWN_SEC  equ 10  ; Quantos segundos entre cada escudo aparecer.
    ESCUDO_SECONDS  equ 6   ; Quantos segundos o escudo dura.
    ROUND_SECONDS   equ 24  ; Quantos segundos uma rodada dura.
    ROUNDS          equ 4   ; Quantas rodadas dura o jogo.
    SPEED_ACC       equ 1   ; Quantos pixels adicionar à velocidade dos obstáculos a cada rodada.
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
    UI_BARRA_MAX_POS equ UI_BARRA_WIDTH ; Adicione isso à posição da barra para obter o endereço de memória onde ela acaba.
    UI_BOTAO_POS     equ 320 * (UI_PANEL_Y + 5) + (160 - SPR_SIZE / 2)

    SPR_SIZE        equ 10

    INIT_NAVE_POS   equ 320 * (100 - SPR_SIZE / 2) + (160 - SPR_SIZE / 2)
    FRENTE_NAVE     equ 320 * (SPR_SIZE / 2) + SPR_SIZE ; Adicione isso à posição da nave para spawnar o tiro na frente dela.
    NAVE_MIN_Y      equ 320 * SPEED
    NAVE_MAX_Y      equ UI_PANEL_POS - 320 * (SPR_SIZE + SPEED)

    SPEED_TIRO      equ SPEED * 2
    LIFETIME_TIRO   equ (320 - 160 - SPR_SIZE / 2) / SPEED_TIRO
    BASE_LF_OBST    equ (320 - SPR_SIZE / 2)

    DELAY_LOW       equ (1000 / FPS) * 1000
    INV_FRAMES      equ ESCUDO_SECONDS * FPS

    ESCD_DELAY      equ ESCD_SPAWN_SEC * FPS

    LIFE_ERASE      equ UI_BARRA_WIDTH / HIT_POINTS
    ROUND_ERASE     equ UI_BARRA_WIDTH / ROUND_SECONDS
;
; Enums
    MENU_JOGAR  equ 0
    MENU_SAIR   equ 1

    DIR_CIMA    equ 0
    DIR_BAIXO   equ 1
    DIR_ESQ     equ 2
    DIR_DIR     equ 3

    OBJ_NULL    equ 0
    OBJ_TIRO    equ 1
    OBJ_OBST    equ 2
    OBJ_VIDA    equ 3
    OBJ_ESCD    equ 4
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

    str_lose    db "              _   __         //|        "
                db "             | | / /__  ____|/||        "
                db "             | |/ / _ \/ __/ -_)        "
                db "         ___ |___/\___/\__/\__/         "
                db "        / _ \___ _______/ /__ __ __     "
                db "       / ___/ -_) __/ _  / -_) // /     "
                db "      /_/   \__/_/  \_,_/\__/\_,_/      "
    len_str_lose equ $ - str_lose

    str_win     db "         ___                            "
                db "        / _ \___ ________ _             "
                db "       / ___/ _ `/ __/ _ `/             "
                db "      /_/   \_,_/_/__\_,_/_             "
                db "                  / /  _/_/___  ___     "
                db "                 / _ \/ -_) _ \(_-<     "
                db "                /_.__/\__/_//_/___/     "
                             
    len_str_win equ $ - str_win

    str_exit_prompt   db "       Aperte [ ENTER ] para sair       "
    len_str_exit_prompt equ $ - str_exit_prompt

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
    rng_seed      dw 0

    nave_pos      dw INIT_NAVE_POS
    nave_inv      dw 0
    
    tiro_timer    dw 0
    spawn_timer   dw SPAWN_DELAY
    escd_timer    dw ESCD_DELAY
    round_timer   dw FPS

    enable_escd   db 0

    rounds_left   dw ROUNDS
    obst_speed    dw SPEED
    obst_lifetime dw BASE_LF_OBST / SPEED - SPEED

    tempo_pos     dw UI_TEMPO_POS + UI_BARRA_MAX_POS - ROUND_ERASE
    vida_pos      dw UI_VIDA_POS + UI_BARRA_MAX_POS - LIFE_ERASE

    ; Array de objetos:
    ; MAX_OBJS objetos podem existir no plano do jogo ao mesmo tempo.
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
; Faz nada durante um frame do jogo.
idle_frame:
    push cx
    push dx

    xor cx, cx
    mov dx, DELAY_LOW
    call delay

    pop dx
    pop cx
    ret
;
; Decrementa um número de 16 bits na memória se ele já não for zero.
;
; Recebe:
; BX = Endereço na memória.
;
; Retorna:
; BX = 1 se o timer acabou de virar 0.
decrement_timer:
    cmp word ptr [bx], 0
    je decrement_timer_end

    dec word ptr [bx]
    jnz decrement_timer_end

    mov bx, 1 ; Se o timer acabou de virar 0, retorna 1.

    decrement_timer_end:
        ret
;
; Gera um número pseudo-aleatório usando o último número gerado.
; Referência: https://stackoverflow.com/questions/40698309/8086-random-number-generator-not-just-using-the-system-time
;
; Retorna:
; AX = Número aleatório.
; rng_seed = Número aleatório.
rand:
    push dx

    mov     ax, 25173          ; LCG Multiplier
    mul     word ptr [rng_seed]     ; DX:AX = LCG multiplier * seed
    add     ax, 13849          ; Add LCG increment value
    ; Modulo 65536, AX = (multiplier*seed+increment) mod 65536
    mov     word ptr [rng_seed], ax          ; Update seed = return value
    shr     ax, 5               ; Discard 5 bits

    pop dx
    ret
;
; Gera um número aleatório entre 0 e AX.
;
; Recebe:
; AX = Limite superior.
;
; Retorna:
; AX = Número aleatório.
rand_range:
    push bx
    push dx
            
    mov bx, ax
    
    call rand
    xor dx, dx
    div bx ; DX contem o resto.
    
    mov ax, dx

    pop dx
    pop bx
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
; Preenche a área do jogo até a barra de status com uma cor.
;
; Recebe:
; DL = Cor
slowly_fill_game_area:
    push di
    push bx
    push cx

    mov di, 0

    mov bx, UI_PANEL_Y / 4

    slowly_fill_game_area_loop:
        mov cx, 320 * 4

        slowly_fill_game_area_pixel:
            ; Transfere a cor para uma linha na tela.
            mov es:[di], dl
            inc di
            loop slowly_fill_game_area_pixel

        ; Espere um frame
        call idle_frame

        ; Decrementa a altura e verifica se acabou.
        dec bx
        jz slowly_fill_game_area_end

        jmp slowly_fill_game_area_loop

    slowly_fill_game_area_end:
        pop cx
        pop bx
        pop di
    ret
;
; Obtém o sprite correto da nave, dependendo se ela estiver com o escudo ou não.
;
; Retorna:
; SI = Endereço do sprite.
get_nave_sprite:
    mov si, offset spr_nave

    ; Vê se a nave está com o escudo ativado para selecionar o sprite certo.
    cmp nave_inv, 0
    je get_nave_sprite_end
    mov si, offset spr_nave_escd
    
    get_nave_sprite_end:
        ret
;
; Move um sprite em uma direção.
; Preenche a área que o sprite costumava ocupar por preto.
;
; Recebe:
; SI = Endereço do sprite no segmento de dados.
; AX = Direção para mover (0 = cima, 1 = baixo, 2 = esquerda, 3 = direita).
; BX = Quantos pixels mover.
; DI = Posição atual do sprite na tela.
;
; Retorna:
; DI = Nova posição do sprite na tela.
move_sprite:
    push ax
    push bx

    cmp bx, 0
    je move_sprite_end

    cmp ax, DIR_CIMA
    je move_sprite_up
    cmp ax, DIR_BAIXO
    je move_sprite_down
    cmp ax, DIR_ESQ
    je move_sprite_left
    cmp ax, DIR_DIR
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
; Obtém uma posição aleatória para um objeto nascer na extremidade direita da tela dentro da área de jogo.
;
; Retorna:
; DI = Posição de spawn.
get_random_spawn_pos:
    push ax
    push bx

    mov ax, UI_PANEL_Y - SPR_SIZE
    call rand_range

    mov bx, 320
    mul bx
    add ax, 320 - SPR_SIZE
    mov di, ax

    pop bx
    pop ax
    ret
;
; Detecta colisão entre um pixel e um sprite.
; Para isso, vai passando linha por linha de um sprite,
; vendo se o pixel está no intervalo de memória que aquela linha ocupa.
;
; Recebe:
; SI = Posição do pixel.
; DI = Posição do sprite.
;
; Retorna:
; AX = 1 se houve colisão, 0 se não houve.
point_collision:
    push bx
    push cx
    push di
    push si

    xor ax, ax

    xor bx, bx
    mov cx, SPR_SIZE
    point_collision_loop:
        ; Vê se o pixel está dentro desta linha do sprite.

        ; Primeiro vê se o pixel vem depois da sua extremidade esquerda.
        cmp si, di
        jae point_collision_continue
        ; Se não está, vai para a próxima linha.
        add di, SPR_SIZE - 1
        jmp point_collision_skip

        ; Depois, vê se o pixel vem antes da sua extremidade direita.
        point_collision_continue:
            add di, SPR_SIZE - 1
            cmp si, di
            ; Se estiver dentro da linha, houve colisão.
            jbe point_collision_detected

        ; Vamos para a próxima linha...
        point_collision_skip:
            inc bx
            add di, 320 - SPR_SIZE + 1
            loop point_collision_loop
    
    point_collision_end:
        pop si
        pop di
        pop cx
        pop bx
        ret
    
    point_collision_detected:
        mov ax, 1
        jmp point_collision_end
;
; Detecta colisão entre dois sprites.
; Para isso, esse procedimento só faz colisão de pixel pelos quatro cantos do sprite.
;
; Recebe:
; SI = Posição do sprite 1.
; DI = Posição do sprite 2.
;
; Retorna:
; AX = 1 se houve colisão, 0 se não houve.
sprite_collision:
    push dx
    push di

    mov dl, 15

    ; Testando canto superior esquerdo...
    call point_collision
    cmp ax, 1
    je sprite_collision_end

    ; Testando canto superior direito...
    add si, SPR_SIZE - 1
    call point_collision
    cmp ax, 1
    je sprite_collision_end

    ; Testando canto inferior esquerdo...
    add si, 320 * (SPR_SIZE - 1) - SPR_SIZE + 1
    call point_collision
    cmp ax, 1
    je sprite_collision_end

    ; Testando canto inferior direito...
    add si, SPR_SIZE - 1
    call point_collision

    sprite_collision_end:
        pop di
        pop dx
        ret
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
        cmp word ptr [bx], OBJ_NULL
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
        call spawn_vida
        jmp spawn_object_end
    
    spawn_object_escd:
        call spawn_escd
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
    push di
    push si

    call get_random_spawn_pos
    ; Desenhe o sprite do obstáculo.
    mov si, offset spr_obst
    call draw_sprite
    ; Move a posição para a memória
    mov word ptr [bx+2], di
    ; Move o tempo de vida do obstáculo.
    mov di, obst_lifetime
    mov word ptr [bx+4], di

    pop si
    pop di
    ret
;
; Cria um objeto de escudo.
;
; Recebe:
; BX = Posição do objeto na array de objetos.
spawn_escd:
    push di
    push si

    call get_random_spawn_pos
    ; Desenhe o sprite do escudo.
    mov si, offset spr_escd
    call draw_sprite
    ; Move a posição para a memória
    mov word ptr [bx+2], di
    ; Move o tempo de vida do obstáculo, que é o mesmo para o escudo.
    mov di, obst_lifetime
    mov word ptr [bx+4], di

    pop si
    pop di
    ret
;
; Cria um objeto de restaurador de vida.
;
; Recebe:
; BX = Posição do objeto na array de objetos.
spawn_vida:
    push di
    push si

    call get_random_spawn_pos
    ; Desenhe o sprite da vida.
    mov si, offset spr_vida
    call draw_sprite
    ; Move a posição para a memória
    mov word ptr [bx+2], di
    ; Move o tempo de vida do obstáculo, que é o mesmo para a vida.
    mov di, obst_lifetime
    mov word ptr [bx+4], di

    pop si
    pop di
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

    cmp word ptr [bx], OBJ_NULL
    je remove_object_end
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
; Move um objeto que seja um sprite, e atualiza sua posição na array de objetos.
;
; Recebe:
; BX = Posição do objeto na array de objetos.
; SI = Endereço do sprite no segmento de dados.
; AX = Direção para mover (0 = cima, 1 = baixo, 2 = esquerda, 3 = direita).
; CX = Quantos pixels mover.
;
; Retorna:
; DI = Nova posição do objeto na tela.
move_object_sprite:
    ; Primeiro, vamos obter a posição atual do objeto.
    mov di, word ptr [bx+2]
    push bx
    
    ; Move o objeto.
    mov bx, cx
    call move_sprite

    ; Atualiza a posição na array de objeto.
    pop bx
    mov word ptr [bx+2], di
    ret
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
        cmp word ptr [bx], OBJ_NULL
        jne process_objects_found
        process_objects_continue:
            ; Adiciona 6 para ir para o próximo objeto,
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
        call process_vida
        jmp process_objects_continue
    
    process_objects_escd:
        call process_escd
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
; Realiza as ações do asteroide.
;
; Recebe:
; BX = Posição da entrada do objeto na array de objetos.
process_obst:
    push ax
    push di
    push si
    push cx

    ; Move o obstáculo para a esquerda.
    mov si, offset spr_obst
    mov ax, DIR_ESQ
    mov cx, obst_speed
    call move_object_sprite

    push bx ; Salva sua posição na memória caso tenha que ser deletado.

    ; Vamos detectar se algum tiro atingiu esse obstáculo!
    ; Percorremos todos os objetos...
    mov bx, offset objects
    mov cx, MAX_OBJS
    process_obst_loop:
        cmp word ptr [bx], OBJ_TIRO
        ; Achamos um tiro!
        je process_obst_tiro
        process_obst_continue:
            add bx, 6
            loop process_obst_loop
    
    pop bx ; Recupera sua posição na memória.

    ; Agora vamos ver se ele está colidindo com a nave.
    mov si, nave_pos
    call sprite_collision
    cmp ax, 1
    je process_obst_hit

    process_obst_end:
        pop cx
        pop si
        pop di
        pop ax
        ret
    
    ; OMG achamos um tiro!! Vamos ver se ele atingiu o obstáculo.
    ; Aqui, BX é a posição em memória do tiro.
    process_obst_tiro:
        ; Obtém a posição do tiro da array de objetos
        mov si, word ptr [bx+2]
        ; Detecta colisão.
        call point_collision
        ; Se a colisão foi detectada...
        cmp ax, 1
        je process_obst_die
        ; Senão, continue procurando por tiros.
        jmp process_obst_continue
    
    ; O obstáculo foi atingido por um tiro!
    process_obst_die:
        ; Primeiro, remove o tiro.
        call remove_object
        ; Depois, remove o obstáculo.
        pop bx ; Recupera sua posição na memória.
        call remove_object
        jmp process_obst_end
    
    ; O obstáculo atingiu a nave!
    process_obst_hit:
        ; Causa dano na nave.
        call damage
        ; Remove o obstáculo.
        call remove_object
        ; Redesenha a nave.
        call get_nave_sprite
        mov di, nave_pos
        call draw_sprite
        jmp process_obst_end
;
; Realiza as ações do escudo.
;
; Recebe:
; BX = Posição da entrada do objeto na array de objetos.
process_escd:
    push ax
    push di
    push si
    push cx

    ; Move o escudo para a esquerda.
    mov si, offset spr_escd
    mov ax, DIR_ESQ
    mov cx, obst_speed
    call move_object_sprite

    ; Agora vamos ver se ele está colidindo com a nave.
    mov si, nave_pos
    call sprite_collision
    cmp ax, 1
    je process_escd_hit

    process_escd_end:
        pop cx
        pop si
        pop di
        pop ax
        ret
    
    ; O escudo atingiu a nave!
    process_escd_hit:
        ; Remove o escudo.
        call remove_object
        ; Ativa o modo invencível.
        call activate_shield
        jmp process_escd_end
;
; Realiza as ações do restaurador de vida.
;
; Recebe:
; BX = Posição da entrada do objeto na array de objetos.
process_vida:
    push ax
    push di
    push si
    push cx

    ; Move a vida para a esquerda.
    mov si, offset spr_vida
    mov ax, DIR_ESQ
    mov cx, obst_speed
    call move_object_sprite

    ; Agora vamos ver se ela está colidindo com a nave.
    mov si, nave_pos
    call sprite_collision
    cmp ax, 1
    je process_vida_hit

    process_vida_end:
        pop cx
        pop si
        pop di
        pop ax
        ret
    
    ; A vida atingiu a nave!
    process_vida_hit:
        ; Remove a vida.
        call remove_object
        ; Enche novamente a barra de vida.
        call restore_health
        ; Redesenha a nave.
        call get_nave_sprite
        mov di, nave_pos
        call draw_sprite
        jmp process_vida_end
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

    ; Inicializa as ações de sprite com o sprite da nave, sua posição e velocidade.
    call get_nave_sprite
    mov di, nave_pos
    mov bx, SPEED

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
        mov ax, DIR_BAIXO
        call move_sprite
        mov nave_pos, di
    
    process_input_fire:
        cmp input_fire, 1
        jne process_input_done
        ; Primeiro, vemos se o tiro não está em delay.
        cmp tiro_timer, 0
        jne process_input_done
        ; Atirar
        mov ax, OBJ_TIRO
        call spawn_object
        mov input_fire, 0
        mov tiro_timer, TIRO_MAX_DELAY

    process_input_done:
        pop di
        pop si
        pop bx
        pop ax
        ret

;
; Cria um obstáculo ou power-up baseado no status do jogo.
random_spawn:
    push ax
    push bx

    ; Por padrão, a gente spawna um obstáculo.
    mov bx, OBJ_OBST

    ; Caso a vida da nave estiver menos da metade, o restaurador de vida pode aparecer
    ; ao invés de um asteroide.
    cmp vida_pos, UI_VIDA_POS + (UI_BARRA_MAX_POS / 2)
    jae random_spawn_done
    ; Vamos rodar o RNG para ver se aparece o power-up da vida.
    mov ax, VIDA_CHANCE
    call rand_range
    cmp ax, 0 ; Se o RNG nos der 0, spawnamos a vida.
    jne random_spawn_done
    mov bx, OBJ_VIDA

    ; Spawnamos o que estiver no registrador BX por último.
    random_spawn_done:
        mov ax, bx
        call spawn_object

        pop bx
        pop ax
        ret
;
; Ativa o poder do escudo.
activate_shield:
    push si
    push di

    mov nave_inv, INV_FRAMES

    mov si, offset spr_nave_escd
    mov di, nave_pos
    call draw_sprite

    pop di
    pop si
    ret
;
; Preenche a vida da nave.
restore_health:
    push di
    push dx

    mov di, UI_VIDA_POS
    mov dl, 10
    mov dh, 2
    call draw_status_bar
    mov vida_pos, UI_VIDA_POS + UI_BARRA_MAX_POS - LIFE_ERASE

    pop dx
    pop di

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
; CX = Quantos pixels para decrementar.
;
; Retorna:
; DI = Nova posição preenchida da barra.
decrement_status_bar:
    push bx
    push dx

    mov bx, SPR_SIZE
    xor dl, dl
    call draw_rect

    sub di, cx

    pop dx
    pop bx
    ret
;
; Causa dano à nave. Se a nave não tiver mais vida, encerra o jogo.
damage:
    cmp nave_inv, 0 ; Se a nave estiver invencível, pule o dano completamente.
    jne damage_denied

    push di
    push cx
    mov cx, LIFE_ERASE

    mov di, vida_pos
    call decrement_status_bar

    ; Se a posição preenchida da barra for maior que sua posição inicial,
    ; significa que a barra ainda não acabou.
    cmp di, UI_VIDA_POS
    jae damage_done

    ; Se chegar nesse ponto, significa que a nave não tem mais vida.
    ; Perdeu o jogo.
    call you_lose

    damage_done:
        mov vida_pos, di ; Atualiza a posição da barra.

        pop cx
        pop di
    damage_denied:
        ret
;
; Mostra tela de fim de jogo.
you_lose:
    mov dl, 4
    call slowly_fill_game_area

    mov ax, @data
    mov es, ax              ; String tem que estar no ES.
    mov ah, 13h             ; Imprimir string.
    xor al, al              ; Só caracteres.
    xor bh, bh              ; Página de vídeo 0

    ; Você perdeu
    xor dl, dl              ; X = 0
    mov dh, 4               ; Y = 4
    mov bl, 15              ; Cor branco.
    mov cx, len_str_lose    ; Tamanho da string
    mov bp, offset str_lose ; String para escrever.
    int 10h

    ; Opções
    mov dh, 17
    mov cx, len_str_exit_prompt
    mov bp, offset str_exit_prompt
    int 10h

    you_lose_loop:
        ; Espere por uma tecla pressionada.
        mov ah, 0
        int 16h

        ; Se a tecla não for enter, volte.
        cmp ah, 1Ch
        jne you_lose_loop
    
    call end_program
;
; Desce um tick do timer de rodada.
round_tick:
    push di
    push cx

    mov di, tempo_pos
    mov cx, ROUND_ERASE
    call decrement_status_bar

    ; Se a posição preenchida da barra for maior que sua posição inicial,
    ; significa que ainda tem tempo.
    cmp di, UI_TEMPO_POS
    jae round_tick_done

    ; Se chegar nesse ponto, significa que o tempo acabou.
    ; Preenche o timer.
    push dx
    mov di, UI_TEMPO_POS
    mov dl, 11
    mov dh, 3
    call draw_status_bar
    pop dx
    mov tempo_pos, UI_TEMPO_POS + UI_BARRA_MAX_POS - ROUND_ERASE

    call next_round

    ; Saia da rotina mais cedo.
    pop cx
    pop di
    ret

    round_tick_done:
        mov tempo_pos, di ; Atualiza a posição da barra.

        pop cx
        pop di
        ret
;
; Passa para o próximo round.
next_round:
    push ax
    push bx
    push cx
    push dx

    ; Permite que o escudo comece a aparecer.
    mov enable_escd, 1

    ; Deleta todos os objetos na tela.
    mov bx, offset objects
    mov cx, MAX_OBJS

    next_round_delete_objs:
        call remove_object
        ; Adiciona 6 para ir para o próximo objeto,
        ; Já que cada entrada de objeto é de 3 words, AKA 6 bytes.
        add bx, 6
        loop next_round_delete_objs

    ; Altera a velocidade e tempo de vida padrão dos objetos.
    add obst_speed, SPEED_ACC
    mov bx, obst_speed
    xor dx, dx
    mov ax, BASE_LF_OBST
    div bx
    sub ax, obst_speed
    mov obst_lifetime, ax

    ; Decrementa a contagem de rodada.
    ; Se acabarem os rounds, o jogador venceu!
    dec rounds_left
    jnz next_round_continue

    call you_win

    next_round_continue:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
;
; Mostra tela de vitória.
you_win:
    mov dl, 14
    call slowly_fill_game_area

    mov ax, @data
    mov es, ax              ; String tem que estar no ES.
    mov ah, 13h             ; Imprimir string.
    xor al, al              ; Só caracteres.
    xor bh, bh              ; Página de vídeo 0

    ; Você perdeu
    xor dl, dl              ; X = 0
    mov dh, 4               ; Y = 4
    mov bl, 15              ; Cor branco.
    mov cx, len_str_win     ; Tamanho da string
    mov bp, offset str_win  ; String para escrever.
    int 10h

    ; Opções
    mov dh, 17
    mov cx, len_str_exit_prompt
    mov bp, offset str_exit_prompt
    int 10h

    you_win_loop:
        ; Espere por uma tecla pressionada.
        mov ah, 0
        int 16h

        ; Se a tecla não for enter, volte.
        cmp ah, 1Ch
        jne you_win_loop
    
    call end_program
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
    ; Inicializa o RNG.
    xor ah, ah    
    int 1AH ; Obtém o tempo do sistema. CX:DX = Número de ticks de clock desde a meia-noite.

    mov word ptr [rng_seed], dx

    ; Desenha os primeiros elementos da cena.
    call setup_scene

    ; Entrando no loop principal do jogo...
    main_loop:
        ; Primeiro, obtém os controles do jogador.
        call get_input

        ; Segundo, faz as ações de cada tecla pressionada.
        call process_input

        ; Terceiro, realiza as ações dos objetos.
        call process_objects

        ; Espera um frame para continuar.
        call idle_frame

        ; Decrementa todos os timers.
        ; Decrementa o timer de tiro.
        mov bx, offset tiro_timer
        call decrement_timer

        ; Decrementa o timer de spawn.
        mov bx, offset spawn_timer
        call decrement_timer

        ; Decrementa o timer de round.
        mov bx, offset round_timer
        call decrement_timer

        cmp bx, 1 ; Se o timer de round tiver terminado...
        jne main_loop_escudo

        call round_tick
        ; Reinicia o timer.
        mov round_timer, FPS

        main_loop_escudo:
            ; Se o escudo estiver desativado, pule essa parte.
            cmp enable_escd, 0
            je main_loop_invincibility

            ; Decrementa o timer de escudo.
            mov bx, offset escd_timer
            call decrement_timer

            cmp bx, 1 ; Se o timer de escudo tiver terminado...
            jne main_loop_invincibility
            ; Vamos spawnar um escudo.
            mov ax, OBJ_ESCD
            call spawn_object
            ; E reiniciar o timer.
            mov escd_timer, ESCD_DELAY

        main_loop_invincibility:
            ; Decrementa o timer de invencibilidade
            mov bx, offset nave_inv
            call decrement_timer

            cmp bx, 1 ; Se o timer de invencibilidade tiver terminado...
            jne main_loop_random_spawn
            ; Vamos redesenhar a nave com o sprite normal.
            mov si, offset spr_nave
            mov di, nave_pos
            call draw_sprite

        main_loop_random_spawn:
            ; Se o timer de spawn for 0, vamos criar um novo obstáculo.
            cmp spawn_timer, 0
            jne main_loop

            mov spawn_timer, SPAWN_DELAY
            call random_spawn

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
    mov bl, 10              ; Cor verde claro.
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
    call main_menu

    xor dl, dl
    call draw_bg_color

    call start_game
    
    call end_program

end start
