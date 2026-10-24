# Configuracoes do bitmap:
# 	- Unit W/H: 16
# 	- Display W/H: 256
# 128x128 unidades no display

.data

# Posicao inicial do jogador em unidades do bitmap
PlayerX: .word 56
PlayerY: .word 56

# Onde o jogador esta desenhado na tela agora (comeca igual a PlayerX/Y)
DrawnUnitX: .word 56
DrawnUnitY: .word 56

# Destino do movimento do jogador (se estah parado, eh a posicao do jogador)
TargetUnitX: .word 56
TargetUnitY: .word 56

# Indica de ha movimento ou nao, 0 == parado, 1 == movimentando
Moving: .word 0


Player:
    .byte 0, 0, 9, 9, 9, 9, 0, 0
    .byte 0, 9, 9, 9, 9, 9, 9, 0
    .byte 0, 0, 5, 5, 5, 5, 0, 0
    .byte 0, 0, 0, 5, 5, 0, 0, 0
    .byte 0, 0, 8, 8, 8, 8, 0, 0
    .byte 0, 0, 8, 8, 8, 8, 0, 0
    .byte 0, 0, 2, 2, 2, 2, 0, 0
    .byte 0, 0, 2, 0, 0, 2, 0, 0
Grass:
    .byte 3, 3, 3, 3, 3, 3, 3, 3
    .byte 3, 3, 3, 3, 3, 3, 1, 3
    .byte 3, 3, 1, 3, 3, 3, 4, 3
    .byte 3, 3, 4, 3, 3, 3, 3, 3
    .byte 3, 3, 3, 3, 3, 3, 3, 3
    .byte 3, 3, 3, 3, 1, 3, 3, 3
    .byte 3, 3, 3, 3, 4, 3, 3, 3
    .byte 3, 3, 3, 3, 3, 3, 3, 3

.align 2
Colors:
    .word 0x000000
    .word 0x8FF43B
    .word 0x000000
    .word 0x3A9206
    .word 0x295C0B
    .word 0xFFA96F
    .word 0xDD8B53
    .word 0x032090
    .word 0xD02F17
    .word 0x2B1709

.text
.globl main

main:
	jal InitGame
	
	GameLoop:
	
		jal ReadInput
		jal UpdatePlayer
		jal Render
		
		li $v0, 32
		li $a0, 30	# 30 ps de atraso a cada loop
		syscall
	j GameLoop
	
	j Exit

# Simplesmente preenche todo o fundo com o sprite 'Grass'
DrawBackground:
	li $t0, 0		# indice i
	li $t1, 0		# indice j
	li $t2, 16 		# 16x16
	
	DBGLoop1:
	beq $t0, $t2, DBGLoop1Exit
		DBGLoop2:
		beq $t1, $t2, DBGLoop2Exit
			
			# Buscando endereço do tile
			move $a0, $t1
			move $a1, $t0
			
			# Push
			addi $sp, $sp, -4
			sw $ra, 0($sp)
			
			jal GetTileAdress
			
			# Pop
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			
			la $a0, Grass
			move $a1, $v0
			li $a2, 8
			li $a3, 8
		
			# Guardando dados na pilha
			addi $sp, $sp, -16
			sw $ra, 0($sp)
			sw $t0, 4($sp)
			sw $t1, 8($sp)
			sw $t2, 12($sp)
			
			jal DrawSprite
		
			# Descarregando a pilha
			lw $ra, 0($sp)
			lw $t0, 4($sp)
			lw $t1, 8($sp)
			lw $t2, 12($sp)
			addi $sp, $sp, 16
		addi $t1, $t1, 1	# j++
		j DBGLoop2
		DBGLoop2Exit:
	li $t1, 0		# j = 0
	addi $t0, $t0, 1	# i++
	j DBGLoop1
	DBGLoop1Exit:
	
	jr $ra


# Desenha um sprite
########################
# Argumentos:
#	a0: Endereco da matriz de sprite
#	a1: Posicao no bitmap
#	a2: Altura do sprite
#	a3: Largura do sprite
########################
# Informacoes:
#	- A altura e a largura sao em numero de unidades.
# 	- O valor 32 da operacao "li $t4, 32" foi escolhido porque o bitmap foi
#	  configurado para Display Width de 256 e Unit Width 8. Portando 256/8=32.
#  	- Para cada configuração de bitmap, altere esse valor
DrawSprite:
	la $t0, Colors	# Endereco da lista de cores
	li $t1, 0	# Indice i
	li $t2, 0	# Indice j
	
	li $t4, 128	# 512/4 = 128
	sub $t4, $t4, $a3
	sll $t4, $t4, 2
	# $t4 é o numero de bytes a serem pulados para ir da posicao do ultimo ponto de uma linha do sprite no bitmap para o 1o da proxima
	
	DrawSpriteLoop1:
		beq $t1, $a2, EndDrawSpriteLoop1
		
		DrawSpriteLoop2:
			beq $t2, $a3, EndDrawSpriteLoop2
			lbu $t3, 0($a0)		# Carrega o valor do pixel para $t3
			beq $t3, $zero, JumpDot	# Se o pixel for transparente, pula
			
			# Pintura do ponto
			sll $t3, $t3, 2		# Multiplica por 2^2=4
			add $t3, $t3, $t0	# Calcula o endereco da cor
			lw $t3, 0($t3)		# Carrega o valor da cor
			sw $t3, 0($a1)		# Pinta o ponto
			
			JumpDot:
			addi $a0, $a0, 1	# Incrementa indice da matriz de sprite
			addi $a1, $a1, 4	# Joga o ponto no bitmap para a posicao ao seguinte somando 1*4=4
			addi $t2, $t2, 1	# i++
			
		j DrawSpriteLoop2
		EndDrawSpriteLoop2:
		
		add $a1, $a1, $t4 # Joga o ponto para a posicao inicial da linha seguinte
		addi $t1, $t1, 1	# j++
		move $t2, $0		# i = 0
	j DrawSpriteLoop1
	EndDrawSpriteLoop1:
	
	jr $ra


# Funcao que retorna o endereço na memoria do Tile
# 	a0: Posicao x do tile
#	a1: Posicao y do tile
#	v0: Endereco do tile
GetTileAdress:
	sll $a0, $a0, 5		# x * 8 * 4 = 2^5
	sll $a1, $a1, 12	# y * 128 * 8 * 4 = y * 2^12
	
	li $v0, 0x10040000
	add $v0, $v0, $a0
	add $v0, $v0, $a1
	
	jr $ra
	

# Funcao que retorna o endereco na memoria de uma posicao em unidades
# 	a0: Posicao x em unidades
#	a1: Posicao y em unidades
#	v0: Endereco da unidade
GetUnitAdress:
	sll $a0, $a0, 2		# x * 4 bytes = 2^2
	sll $a1, $a1, 9		# y * 128 * 4 = y * 2^9
	
	li $v0, 0x10040000
	add $v0, $v0, $a0
	add $v0, $v0, $a1
	
	jr $ra


# Retorna a cor do fundo em uma posição
#	a0: Posição x em unidades
#	a1: Posição y em unidades
#	v0: Cor (0x00RRGGBB)
BackgroundColor:
	andi $t0, $a0, 7	# x mod 8
	andi $t1, $a1, 7	# y mod 8
	sll $t1, $t1, 3		# (y mod 8) * 8 = inicio da linha no sprite
	add $t0, $t0, $t1	# indice do ponto no sprite
	la $t1, Grass
	add $t0, $t0, $t1
	lbu $t0, 0($t0)		# indice da cor
	
	sll $t0, $t0, 2		# indice * 4
	la $t1, Colors
	add $t0, $t0, $t1
	lw $v0, 0($t0)		# cor
	
	jr $ra

# Desenha um sprite 8x8 ja misturado com o fundo: onde o sprite eh
# transparente, pinta a cor do fundo. Cada ponto recebe a cor final
# em uma unica escrita.
#	a0: Posicao x em unidades
#	a1: Posicao y em unidades
#	a2: Endereco da matriz do sprite
DrawSpriteOnBackground:
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	
	move $s0, $a0		# s0 = x do inicio da linha
	move $s1, $a1		# s1 = y da linha atual
	move $s2, $a2		# s2 = ponto atual do sprite
	addi $s5, $a1, 8	# s5 = y onde termina (exclusivo)
	
	DSOBRow:
	beq $s1, $s5, DSOBEnd
		move $a0, $s0
		move $a1, $s1
		jal GetUnitAdress
		move $s3, $v0		# s3 = endereco do ponto atual na tela
		move $s4, $s0		# s4 = x do ponto atual
		
		DSOBCol:
		addi $t0, $s0, 8
		beq $s4, $t0, DSOBColEnd
			lbu $t0, 0($s2)		# indice da cor no sprite
			beq $t0, $zero, DSOBBackground
			
			sll $t0, $t0, 2		# Ponto do sprite: busca a cor
			la $t1, Colors
			add $t0, $t0, $t1
			lw $v0, 0($t0)
			j DSOBPaint
			
			DSOBBackground:		# Ponto transparente: usa a cor do fundo
			move $a0, $s4
			move $a1, $s1
			jal BackgroundColor
			
			DSOBPaint:
			sw $v0, 0($s3)
			addi $s2, $s2, 1
			addi $s3, $s3, 4
			addi $s4, $s4, 1
		j DSOBCol
		DSOBColEnd:
		addi $s1, $s1, 1
	j DSOBRow
	DSOBEnd:
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	
	jr $ra

# Repinta o fundo nos pontos da posicao antiga de um sprite 8x8
# que nao ficam dentro da posição nova (a parte que ficou descoberta).
#	a0: x antigo   a1: y antigo   (em unidades)
#	a2: x novo     a3: y novo     (em unidades)
RestoreBackground:
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	
	move $s0, $a0		# s0 = x do inicio da linha (posicao antiga)
	move $s1, $a1		# s1 = y da linha atual
	move $s2, $a2		# s2 = x novo
	move $s3, $a3		# s3 = y novo
	addi $s6, $a1, 8	# s6 = y onde termina (exclusivo)
	
	RBRow:
	beq $s1, $s6, RBEnd
		move $a0, $s0
		move $a1, $s1
		jal GetUnitAdress
		move $s5, $v0		# s5 = endereço do ponto atual na tela
		move $s4, $s0		# s4 = x do ponto atual
		
		RBCol:
		addi $t0, $s0, 8
		beq $s4, $t0, RBColEnd

			# O ponto esta dentro da posicao nova? O sprite vai cobri-lo: pula.
			sub $t0, $s4, $s2
			sltiu $t0, $t0, 8	# 1 se 0 <= x - xNovo < 8
			sub $t1, $s1, $s3
			sltiu $t1, $t1, 8	# 1 se 0 <= y - yNovo < 8
			and $t0, $t0, $t1
			bne $t0, $zero, RBNext
			
			move $a0, $s4
			move $a1, $s1
			jal BackgroundColor
			sw $v0, 0($s5)
			
			RBNext:
			addi $s4, $s4, 1
			addi $s5, $s5, 4
		j RBCol
		RBColEnd:
		addi $s1, $s1, 1
	j RBRow
	RBEnd:
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	addi $sp, $sp, 32
	
	jr $ra


InitGame:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal DrawBackground

	# Desenha o jogador na posicao inicial
	la $t0, PlayerX
	lw $a0, 0($t0)
	la $t0, PlayerY
	lw $a1, 0($t0)
	la $a2, Player
	jal DrawSpriteOnBackground

	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
ReadInput:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# Se o jogador ja esta se movendo, ignora o teclado
	la $t0, Moving
	lw $t1, 0($t0)
	bne $t1, $zero, InputDone
	
	li $t0, 0xffff0000	# Endereco de registro de controle
	lw $t1, 0($t0)
	andi $t1, $t1, 1
	beq $t1, $zero, InputDone
	
	lw $t1, 4($t0)
	
	# w
	li $t0, 119
	beq $t1, $t0, MoveUp
	# a
	li $t0, 97
	beq $t1, $t0, MoveLeft
	# s
	li $t0, 115
	beq $t1, $t0, MoveDown
	# d
	li $t0, 100
	beq $t1, $t0, MoveRight
	# q
	li $t0, 113
	beq $t1, $t0, Exit
	
	InputDone:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
MoveUp:
	la $t0, PlayerY
	lw $t1, 0($t0)
	
	# Se for sair do mapa
	blez $t1, InputDone
	
	addi $t1, $t1, -8	# destino: 1 tile acima
	
	la $t0, TargetUnitY
	sw $t1, 0($t0)
	j StartMove
MoveLeft:
	la $t0, PlayerX
	lw $t1, 0($t0)
	
	# Se for sair do mapa
	blez $t1, InputDone
	
	addi $t1, $t1, -8	# destino: 1 tile a esquerda
	
	la $t0, TargetUnitX
	sw $t1, 0($t0)
	j StartMove
MoveDown:
	la $t0, PlayerY
	lw $t1, 0($t0)
	
	# Se for sair do mapa
	li $t2, 120
	slt $t2, $t1, $t2
	beq $t2, $zero, InputDone
	
	addi $t1, $t1, 8	# destino: 1 tile abaixo
	
	la $t0, TargetUnitY
	sw $t1, 0($t0)
	j StartMove
MoveRight:
	la $t0, PlayerX
	lw $t1, 0($t0)
	
	# Se for sair do mapa
	li $t2, 120
	slt $t2, $t1, $t2
	beq $t2, $zero, InputDone
	
	addi $t1, $t1, 8	# destino: 1 tile a direita
	
	la $t0, TargetUnitX
	sw $t1, 0($t0)
	j StartMove

StartMove:
	la $t0, Moving
	li $t1, 1
	sw $t1, 0($t0)
	j InputDone


# Aproxima um valor do destino em 1 unidade
#	a0: Valor atual
#	a1: Destino
#	v0: Novo valor (atual + 1, atual - 1 ou o próprio atual)
StepToward:
	slt $t0, $a0, $a1	# 1 se atual < destino
	slt $t1, $a1, $a0	# 1 se destino < atual
	add $v0, $a0, $t0
	sub $v0, $v0, $t1
	
	jr $ra


# Atualiza o estado do jogador a cada frame
UpdatePlayer:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, Moving
	lw $t1, 0($t0)
	beq $t1, $zero, UpdateDone	# Parado: nada a fazer
	
	# Avanca 1 unidade em direcao ao destino (eixo X)
	la $t0, PlayerX
	lw $a0, 0($t0)
	la $t0, TargetUnitX
	lw $a1, 0($t0)
	jal StepToward
	la $t0, PlayerX
	sw $v0, 0($t0)
	
	# Idem no eixo Y
	la $t0, PlayerY
	lw $a0, 0($t0)
	la $t0, TargetUnitY
	lw $a1, 0($t0)
	jal StepToward
	la $t0, PlayerY
	sw $v0, 0($t0)
	
	# Se ainda não chegou ao destino, continua em movimento
	la $t0, PlayerX
	lw $t1, 0($t0)
	la $t0, TargetUnitX
	lw $t2, 0($t0)
	bne $t1, $t2, UpdateDone
	
	la $t0, PlayerY
	lw $t1, 0($t0)
	la $t0, TargetUnitY
	lw $t2, 0($t0)
	bne $t1, $t2, UpdateDone
	
	# Chegou ao destino
	la $t0, Moving
	sw $zero, 0($t0)

	
	UpdateDone:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


# Redesenha o jogador so quando ele muda de lugar
Render:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# Se a posição atual e a mesma que esta na tela, nao ha o que fazer
	la $t0, PlayerX
	lw $t1, 0($t0)
	la $t0, DrawnUnitX
	lw $t2, 0($t0)
	bne $t1, $t2, RenderDraw
	
	la $t0, PlayerY
	lw $t1, 0($t0)
	la $t0, DrawnUnitY
	lw $t2, 0($t0)
	beq $t1, $t2, RenderDone
	
	RenderDraw:
	# 1) Repinta o fundo na parte da posicao antiga que ficou descoberta
	la $t0, DrawnUnitX
	lw $a0, 0($t0)
	la $t0, DrawnUnitY
	lw $a1, 0($t0)
	la $t0, PlayerX
	lw $a2, 0($t0)
	la $t0, PlayerY
	lw $a3, 0($t0)
	jal RestoreBackground
	
	# 2) Desenha o jogador na posicao nova, ja com o fundo por trás
	la $t0, PlayerX
	lw $a0, 0($t0)
	la $t0, PlayerY
	lw $a1, 0($t0)
	la $a2, Player
	jal DrawSpriteOnBackground
	
	# 3) Guarda onde o jogador ficou desenhado
	la $t0, PlayerX
	lw $t1, 0($t0)
	la $t0, DrawnUnitX
	sw $t1, 0($t0)
	
	la $t0, PlayerY
	lw $t1, 0($t0)
	la $t0, DrawnUnitY
	sw $t1, 0($t0)
	
	RenderDone:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


Exit:
	li $v0, 10
	syscall
