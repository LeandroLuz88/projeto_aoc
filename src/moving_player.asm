# Configutaçõe do bitmap:
# 	- Unit W/H: 16
# 	- Display W/H: 256
# 128x128 unidades no display

.data

# Posição inicial do jogador em unidades do bitmap
PlayerX: .word 56
PlayerY: .word 56

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
		jal Render
		
		li $v0, 32
		li $a0, 30	# 30 ps de atraso a cada loop
		syscall
	j GameLoop
	
	j Exit

# Simplesmente preenche tood o fundo com o sprite 'Grass'
DrawBackground:
	li $t0, 0		# índice i
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
#	a0: Endereço da matriz de sprite
#	a1: Posição no bitmap
#	a2: Altura do sprite
#	a3: Largura do sprite
########################
# Informações:
#	- A altura e a largura são em número de unidades.
# 	- O valor 32 da operação "li $t4, 32" foi escolhido porque o bitmap foi
#	  configurado para Display Width de 256 e Unit Width 8. Portando 256/8=32.
#  	  Para cada configuração de bitmap, altere esse valor
DrawSprite:
	la $t0, Colors	# Endereço da lista de cores
	li $t1, 0	# Índice i
	li $t2, 0	# Índice j
	
	li $t4, 128	# 512/4 = 128
	sub $t4, $t4, $a3
	sll $t4, $t4, 2
	# $t4 é o número de bytes a serem pulados para ir da posição do último ponto de uma linha do sprite no bitmap para o 1° da próxima
	
	DrawSpriteLoop1:
		beq $t1, $a2, EndDrawSpriteLoop1
		
		DrawSpriteLoop2:
			beq $t2, $a3, EndDrawSpriteLoop2
			lbu $t3, 0($a0)		# Carrega o valor do pixel para $t3
			beq $t3, $zero, JumpDot	# Se o pixel for transparente, pula
			
			# Pintura do ponto
			sll $t3, $t3, 2		# Multiplica por 2^2=4
			add $t3, $t3, $t0	# Calcula o endereço da cor
			lw $t3, 0($t3)		# Carrega o valor da cor
			sw $t3, 0($a1)		# Pinta o ponto
			
			JumpDot:
			addi $a0, $a0, 1	# Incrementa índice da matriz de sprite
			addi $a1, $a1, 4	# Joga o ponto no bitmap para a posição ao seguinte somando 1*4=4
			addi $t2, $t2, 1	# i++
			
		j DrawSpriteLoop2
		EndDrawSpriteLoop2:
		
		add $a1, $a1, $t4 # Joga o ponto para a posição inicial da linha seguinte
		addi $t1, $t1, 1	# j++
		move $t2, $0		# i = 0
	j DrawSpriteLoop1
	EndDrawSpriteLoop1:
	
	jr $ra
	
# Função que retorna o endereço na memória do Tile
# 	a0: Posição x do tile
#	a1: Posição y do tile
#	v0: Endereço do tile
GetTileAdress:
	sll $a0, $a0, 5		# x * 8 * 4 = 2^5
	sll $a1, $a1, 12	# y * 128 * 8 * 4 = y * 2^12
	
	li $v0, 0x10040000
	add $v0, $v0, $a0
	add $v0, $v0, $a1
	
	jr $ra
	

# Função que retorna o endereço na memória de uma posição em unidades
# 	a0: Posição x em unidades
#	a1: Posição y em unidades
#	v0: Endereço da unidade
GetUnitAdress:
	sll $a0, $a0, 2		# x * 4 bytes = 2^2
	sll $a1, $a1, 9		# y * 128 * 4 = y * 2^9
	
	li $v0, 0x10040000
	add $v0, $v0, $a0
	add $v0, $v0, $a1
	
	jr $ra



InitGame:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal DrawBackground
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
ReadInput:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $t0, 0xffff0000	# Endereço de registro de controle
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
	
	addi $sp, $sp, -8
	sw $t1, 0($sp)
	sw $t0, 4($sp)
	
	la $t2, PlayerX
	lw $a0, 0($t2)
	move $a1, $t1
	jal GetUnitAdress
	
	la $a0, Grass
	move $a1, $v0
	li $a2, 8
	li $a3, 8
	jal DrawSprite
		
	lw $t1, 0($sp)
	lw $t0, 4($sp)
	addi $sp, $sp, 8
	
	addi $t1, $t1, -8	# Altera a posição do jogador
	
	sw $t1, 0($t0)
	j InputDone
MoveLeft:
	la $t0, PlayerX
	lw $t1, 0($t0)
	
	# Se for sair do mapa
	blez $t1, InputDone
	
	addi $sp, $sp, -8
	sw $t1, 0($sp)
	sw $t0, 4($sp)
	
	move $a0, $t1
	la $t2, PlayerY
	lw $a1, 0($t2)
	jal GetUnitAdress
	
	la, $a0, Grass
	move $a1, $v0
	li $a2, 8
	li $a3, 8
	jal DrawSprite
		
	lw $t1, 0($sp)
	lw $t0, 4($sp)
	addi $sp, $sp, 8
	
	addi $t1, $t1, -8	# Altera a posição do jogador
	
	sw $t1, 0($t0)
	j InputDone
MoveDown:
	la $t0, PlayerY
	lw $t1, 0($t0)
	
	# Se for sair do mapa
	li $t2, 120
	slt $t2, $t1, $t2
	beq $t2, $zero, InputDone
	
	addi $sp, $sp, -8
	sw $t1, 0($sp)
	sw $t0, 4($sp)
	
	la $t2, PlayerX
	lw $a0, 0($t2)
	move $a1, $t1
	jal GetUnitAdress
	
	la, $a0, Grass
	move $a1, $v0
	li $a2, 8
	li $a3, 8
	jal DrawSprite
		
	lw $t1, 0($sp)
	lw $t0, 4($sp)
	addi $sp, $sp, 8
	
	addi $t1, $t1, 8	# Altera a posição do jogador
	
	sw $t1, 0($t0)
	j InputDone
MoveRight:
	la $t0, PlayerX
	lw $t1, 0($t0)
	
	# Se for sair do mapa
	li $t2, 120
	slt $t2, $t1, $t2
	beq $t2, $zero, InputDone
	
	addi $sp, $sp, -8
	sw $t1, 0($sp)
	sw $t0, 4($sp)
	
	move $a0, $t1
	la $t2, PlayerY
	lw $a1, 0($t2)
	jal GetUnitAdress
	
	la $a0, Grass
	move $a1, $v0
	li $a2, 8
	li $a3, 8
	jal DrawSprite
		
	lw $t1, 0($sp)
	lw $t0, 4($sp)
	addi $sp, $sp, 8
	
	addi $t1, $t1, 8	# Altera a posição do jogador
	
	sw $t1, 0($t0)
	j InputDone


Render:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, PlayerX
	la $t1, PlayerY
	lw $a0, 0($t0)
	lw $a1, 0($t1)
	jal GetUnitAdress
	
	la $a0, Player
	move $a1, $v0
	li $a2, 8
	li $a3, 8
	jal DrawSprite
	
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra

Exit:
	li $v0, 10
	syscall
