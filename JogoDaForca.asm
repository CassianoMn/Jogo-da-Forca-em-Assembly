.data
    palavra: .space 20        # Espaço para a palavra secreta
    tentativas: .space 26     # Array para letras tentadas (a-z)
    display: .space 20        # Palavra com _ para letras não descobertas
    msg_entrada: .asciiz "\nDigite a palavra secreta: "
    msg_tent: .asciiz "\nDigite uma letra: "
    msg_ja_usada: .asciiz "\nEsta letra já foi tentada!"
    msg_ganhou: .asciiz "\nParabéns! Você ganhou!"
    msg_perdeu: .asciiz "\n\nGAME OVER! Você foi enforcado brutalmente!\nA palavra era: "
    msg_vidas: .asciiz "\nVidas restantes: "
    msg_acertou: .asciiz "\nVocê acertou uma letra!"
    msg_errou: .asciiz "\nLetra incorreta! O carrasco aperta mais a corda..."
    msg_letras_usadas: .asciiz "\nLetras já tentadas: "
    msg_entrada_invalida: .asciiz "\nPor favor, digite apenas letras!"
    msg_jogar_novamente: .asciiz "\nDeseja jogar novamente? (s/n): "
    msg_entrada_invalida_sn: .asciiz "\nPor favor, digite apenas 's' ou 'n'!"
    msg_limpa_tela: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"  # 20 linhas em branco
    new_line: .asciiz "\n"
    espaco: .asciiz " "
    
    # Arte ASCII da forca em diferentes estados
    forca_0: .asciiz "\n    +---+\n    |   |\n        |\n        |\n        |\n        |\n  =========\n"
    forca_1: .asciiz "\n    +---+\n    |   |\n    O   |\n        |\n        |\n        |\n  =========\n"
    forca_2: .asciiz "\n    +---+\n    |   |\n    O   |\n    |   |\n        |\n        |\n  =========\n"
    forca_3: .asciiz "\n    +---+\n    |   |\n    O   |\n   /|   |\n        |\n        |\n  =========\n"
    forca_4: .asciiz "\n    +---+\n    |   |\n    O   |\n   /|\\  |\n        |\n        |\n  =========\n"
    forca_5: .asciiz "\n    +---+\n    |   |\n    O   |\n   /|\\  |\n   /    |\n        |\n  =========\n"
    forca_6: .asciiz "\n    +---+\n    |   |\n    O   |\n   /|\\  |\n   / \\  |\n        |\n  =========\n"
    forca_morte: .asciiz "\n    +---+\n    |   |\n    X   |\n   /|\\  |\n   / \\  |\n        |\n  =========\n    MORTO!\n"
    
.text
.globl main
main:
    # Loop principal do programa
    j inicio_jogo

inicio_jogo:
    # Limpa a tela
    li $v0, 4
    la $a0, msg_limpa_tela
    syscall

    # Inicializa array de tentativas com zeros
    la $t0, tentativas
    li $t1, 26           # Tamanho do array
init_tentativas:
    sb $zero, ($t0)
    addi $t0, $t0, 1
    subi $t1, $t1, 1
    bnez $t1, init_tentativas
    
    # Solicita e armazena a palavra secreta
    li $v0, 4
    la $a0, msg_entrada
    syscall
    
    li $v0, 8
    la $a0, palavra
    li $a1, 20
    syscall
    
    # Converte palavra para minúsculas e remove o \n
    la $t0, palavra
convert_lower:
    lb $t1, ($t0)
    beq $t1, 10, set_null    # Se encontrar \n
    beq $t1, 0, init_start   # Se encontrar \0
    
    # Verifica se é letra maiúscula e converte para minúscula
    blt $t1, 65, next_char_conv   # Se < 'A', pula
    bgt $t1, 90, next_char_conv   # Se > 'Z', pula
    addi $t1, $t1, 32            # Converte para minúscula
    sb $t1, ($t0)
    
next_char_conv:
    addi $t0, $t0, 1
    j convert_lower
    
set_null:
    sb $zero, ($t0)          # Substitui \n por \0
    
init_start:
    # Inicializa o display com _
    la $t0, palavra
    la $t1, display
    
init_display:
    lb $t2, ($t0)
    beq $t2, 0, fim_init
    li $t3, 95              # Carrega _ (ASCII 95)
    sb $t3, ($t1)
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j init_display
    
fim_init:
    sb $zero, ($t1)
    
    # Loop principal do jogo
    li $s0, 6            # Número de vidas
    li $s1, 0            # Número de tentativas
    
game_loop:
    # Mostra estado do jogo
    jal mostrar_estado
    
    # Verifica se ganhou
    jal verificar_vitoria
    beq $v0, 1, ganhou
    
    # Solicita nova tentativa
    li $v0, 4
    la $a0, msg_tent
    syscall
    
    # Lê a letra
    li $v0, 12
    syscall
    move $s2, $v0
    
    # Pula linha após entrada
    li $v0, 4
    la $a0, new_line
    syscall
    
    # Valida entrada (apenas letras)
    move $a0, $s2
    jal validar_entrada
    beq $v0, 0, entrada_invalida
    
    # Converte para minúscula se necessário
    blt $s2, 65, game_loop   # Se < 'A', ignora
    bgt $s2, 122, game_loop  # Se > 'z', ignora
    blt $s2, 97, to_lower    # Se é maiúscula, converte
    j check_if_used
to_lower:
    addi $s2, $s2, 32
    
check_if_used:
    # Verifica se letra já foi usada
    la $t0, tentativas
    addi $t1, $s2, -97    # Índice no array (a=0, b=1, etc)
    add $t0, $t0, $t1
    lb $t2, ($t0)
    bnez $t2, letra_ja_usada
    
    # Marca letra como usada
    li $t2, 1
    sb $t2, ($t0)
    
    # Procura letra na palavra
    la $t0, palavra
    la $t1, display
    li $t2, 0            # Flag para indicar se achou a letra
    
check_letter:
    lb $t3, ($t0)
    beq $t3, 0, end_check
    bne $t3, $s2, next_char
    sb $s2, ($t1)        # Revela letra no display
    li $t2, 1            # Marca que achou
next_char:
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j check_letter
    
end_check:
    beq $t2, 1, acertou
    # Errou: perde uma vida
    li $v0, 4
    la $a0, msg_errou
    syscall
    subi $s0, $s0, 1
    beq $s0, 0, perdeu
    j game_loop
    
letra_ja_usada:
    li $v0, 4
    la $a0, msg_ja_usada
    syscall
    j game_loop
    
entrada_invalida:
    li $v0, 4
    la $a0, msg_entrada_invalida
    syscall
    j game_loop
    
acertou:
    li $v0, 4
    la $a0, msg_acertou
    syscall
    j game_loop
    
ganhou:
    li $v0, 4
    la $a0, msg_ganhou
    syscall
    j perguntar_jogar_novamente
    
perdeu:
    li $v0, 4
    la $a0, forca_morte  # Mostra o boneco morto
    syscall
    
    li $v0, 4
    la $a0, msg_perdeu
    syscall
    li $v0, 4
    la $a0, palavra
    syscall
    j perguntar_jogar_novamente
    
perguntar_jogar_novamente:
    li $v0, 4
    la $a0, msg_jogar_novamente
    syscall
    
    # Lê resposta (s/n)
    li $v0, 12
    syscall
    move $t0, $v0
    
    # Pula linha após entrada
    li $v0, 4
    la $a0, new_line
    syscall
    
    # Converte para minúscula se necessário
    blt $t0, 65, check_resposta   # Se < 'A', pula
    bgt $t0, 90, check_resposta   # Se > 'Z', pula
    addi $t0, $t0, 32            # Converte para minúscula
    
check_resposta:
    beq $t0, 115, inicio_jogo    # 's' em ASCII
    beq $t0, 110, fim_jogo       # 'n' em ASCII
    
    # Entrada inválida
    li $v0, 4
    la $a0, msg_entrada_invalida_sn
    syscall
    j perguntar_jogar_novamente
    
fim_jogo:
    li $v0, 10
    syscall

# Subrotinas auxiliares

# Mostra o estado atual do jogo
mostrar_estado:
    # Preserva registradores
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Pula linha
    li $v0, 4
    la $a0, new_line
    syscall
    
    # Mostra a forca baseada no número de vidas restantes
    # $s0 contém o número de vidas (6 inicial)
    li $t0, 6
    sub $t0, $t0, $s0    # t0 = 6 - vidas restantes (número de erros)
    
    # Seleciona a arte da forca apropriada
    la $t1, forca_0
    beq $t0, 0, mostrar_forca
    la $t1, forca_1
    beq $t0, 1, mostrar_forca
    la $t1, forca_2
    beq $t0, 2, mostrar_forca
    la $t1, forca_3
    beq $t0, 3, mostrar_forca
    la $t1, forca_4
    beq $t0, 4, mostrar_forca
    la $t1, forca_5
    beq $t0, 5, mostrar_forca
    la $t1, forca_6
	
mostrar_forca:
    li $v0, 4
    move $a0, $t1
    syscall
    
    # Mostra vidas restantes
    li $v0, 4
    la $a0, msg_vidas
    syscall
    
    li $v0, 1
    move $a0, $s0
    syscall
    
    # Resto do código de mostrar_estado mantido igual...
    # Mostra letras já tentadas
    li $v0, 4
    la $a0, msg_letras_usadas
    syscall
    
    # Percorre array de tentativas
    la $t0, tentativas
    li $t1, 0            # Contador
	
mostrar_tentativas:
    lb $t2, ($t0)
    beqz $t2, prox_tentativa
    
    # Mostra letra
    li $v0, 11
    addi $a0, $t1, 97    # Converte índice para ASCII
    syscall
    
    # Mostra espaço
    li $v0, 4
    la $a0, espaco
    syscall
    
prox_tentativa:
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    blt $t1, 26, mostrar_tentativas
    
    # Pula linha e mostra palavra atual
    li $v0, 4
    la $a0, new_line
    syscall
    
    la $a0, display
    li $v0, 4
    syscall
    
    # Restaura registradores e retorna
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Verifica se o jogador ganhou
verificar_vitoria:
    la $t0, palavra
    la $t1, display
    
check_win_loop:
    lb $t2, ($t0)
    lb $t3, ($t1)
    beq $t2, 0, win      # Se chegou ao fim sem diferenças, ganhou
    bne $t2, $t3, no_win
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j check_win_loop
    
win:
    li $v0, 1
    jr $ra
    
no_win:
    li $v0, 0
    jr $ra

# Valida se a entrada é uma letra
validar_entrada:
    # $a0 contém o caractere a ser validado
    blt $a0, 65, invalido     # Se < 'A', inválido
    bgt $a0, 122, invalido    # Se > 'z', inválido
    bgt $a0, 90, check_lower  # Se > 'Z', verifica se é minúscula
    j valido                  # Se está entre A-Z, válido
check_lower:
    blt $a0, 97, invalido     # Se está entre Z e a, inválido
valido:
    li $v0, 1
    jr $ra
invalido:
    li $v0, 0
    jr $ra
