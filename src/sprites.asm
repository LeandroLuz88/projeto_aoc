.data

.align 0
Grass:
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 11, 12, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 12, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 12, 11, 11, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 12, 11, 11, 11, 11, 11, 11, 11, 11, 11, 12, 11, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 12, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 11, 11, 12, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 12, 11, 11, 11
    .byte 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11

Dirt:
    .byte 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13
    .byte 13, 13, 13, 10, 13, 13, 14, 13, 13, 10, 13, 13, 13, 10, 13, 13
    .byte 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13
    .byte 13, 13, 14, 13, 13, 10, 13, 13, 13, 13, 13, 10, 13, 13, 13, 13
    .byte 13, 13, 13, 13, 13, 13, 13, 13, 10, 13, 13, 13, 13, 13, 13, 13
    .byte 13, 10, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 13, 13
    .byte 13, 13, 13, 13, 13, 13, 10, 13, 13, 13, 13, 13, 13, 13, 13, 13
    .byte 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 10, 13, 13, 13, 13, 13
    .byte 13, 13, 10, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 10, 13, 13
    .byte 13, 13, 13, 13, 13, 10, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13
    .byte 13, 13, 13, 13, 13, 13, 13, 14, 13, 10, 13, 13, 13, 13, 13, 13
    .byte 13, 13, 13, 10, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13
    .byte 13, 14, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13
    .byte 13, 13, 13, 13, 13, 13, 10, 13, 13, 13, 13, 13, 13, 10, 13, 13
    .byte 13, 10, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 13, 13, 13, 13
    .byte 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13
   
.align 2
Colors:
    .word 0x000000
    .word 0x000000
    .word 0xFFA96F
    .word 0xEB9D68
    .word 0x2B1709
    .word 0xEEEEEE
    .word 0xDCDCDC
    .word 0x484848
    .word 0x032090
    .word 0x031A70
    .word 0x753B16
    .word 0x3A9206
    .word 0x40A107
    .word 0x82431C
    .word 0x786969

.text

# Desenha um sprite
#------------------------
# Argumentos:
#	a0: Endereço da matriz de sprite
#	a1: Posição no bitmap
#	a2: Altura do sprite
#	a3: Largura do sprite
#------------------------
# Informações:
#	- A altura e a largura são em número de unidades.
# 	- O valor 512 da operação "li $t4, 32" foi escolhido porque o bitmap foi
#	  configurado para Display Width de 1024 e Unit Width 2. Portando 1024/2=512.
#  	  Para cada configuração de bitmap, altere esse valor
DrawSprite:
	la $t0, Colors	# Endereço da lista de cores
	li $t1, 0	# Índice i
	li $t2, 0	# Índice j
	
	li $t4, 512
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
