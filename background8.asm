    # Unidade: 2x2
# Display: 512x512

.data
# Dimensoes: 16 x 16
SpriteWidth: .word 16
SpriteHeight: .word 16

Grass:
    .byte 8, 8, 8, 8, 8, 8, 8, 8
    .byte 8, 8, 8, 8, 8, 8, 2, 8
    .byte 8, 8, 2, 8, 8, 8, 9, 8
    .byte 8, 8, 9, 8, 8, 8, 8, 8
    .byte 8, 8, 8, 8, 8, 8, 8, 8
    .byte 8, 8, 8, 8, 2, 8, 8, 8
    .byte 8, 8, 8, 8, 9, 8, 8, 8
    .byte 8, 8, 8, 8, 8, 8, 8, 8

.align 2
Colors:
    .word 0x000000
    .word 0x632800
    .word 0x8FF43B
    .word 0xD02F17
    .word 0x032090
    .word 0x000000
    .word 0x9C5221
    .word 0x676767
    .word 0x3A9206
    .word 0x295C0B

.text

Main:
	jal DrawBackground
	
	j Exit
	
DrawBackground:
	li $t0, 0		# índice i
	li $t1, 0		# indice j
	li $t2, 32 		# 32x32
	
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
	
	li $t4, 256
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
	sll $a0, $a0, 5		# x * 8 * 4 = x * 2^5
	sll $a1, $a1, 13	# y * 256 * 4 * 8 = y * 2^13
	
	li $v0, 0x10040000
	add $v0, $v0, $a0
	add $v0, $v0, $a1
	
	jr $ra
Exit:
	li $v0, 10
	syscall