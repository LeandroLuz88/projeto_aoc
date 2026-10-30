# Configurações de bitmap:
#	- Unit Width:		2
#	- Unit Height:		2
#	- Display Width:	1024
#	- Display Height:	512
#	- Base address:		0x100040000 (heap)

# Endereço base do mapa: 0x10044040

# Variáveis:
#	- Map

# Funções:
#	- PaintBackground
#	- DrawMap

.data

.align 0
Map:
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
    .byte 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0
    .byte 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
    .byte 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
    .byte 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0
    .byte 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0
    .byte 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0
    .byte 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.text

# Pinta todo o bitmap de uma cor
PaintBackground:
	li $t0, 0x10040000	# Endereço base do bitmap
	addi $t1, $t0, 524288	# Endereço final
	li $t2, 0x333344	# Cor
	
	PaintBackgroundLoop:
		beq $t0, $t1, EndPaintBackgroundLoop
		sw $t2, 0($t0)
		addi $t0, $t0, 4
	j PaintBackgroundLoop
	EndPaintBackgroundLoop:
	
	jr $ra

# Desenha o mapa no bitmap com base na matriz "Map"
DrawMap:
	li $t0, 0		# índice i
	li $t1, 0		# indice j
	li $t2, 15 		# 15x15 tiles
	li $t3, 0x10044040	# Endereço base do mapa (Endereço base + 251936960)
	la $t4, Map		# Matriz de mapa
	
	# Argumentos da função DrawSprite constantes
	li $a2, 16
	li $a3, 16
	
	# Push
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	DrawMapLoop1:
	beq $t0, $t2, DrawMapLoop1Exit
		DrawMapLoop2:
		beq $t1, $t2, DrawMapLoop2Exit
			lbu $t5, 0($t4)
			
			# Decidir se é caminho de terra ou grama
			beq $t5, 1, DrawMapBeqElse
			la $a0, Grass
			j DrawMapBeqExit
			DrawMapBeqElse:
			la $a0, Dirt
			DrawMapBeqExit:
			
			move $a1, $t3
			
			# Push
			addi $sp, $sp, -20
			sw $t0, 0($sp)
			sw $t1, 4($sp)
			sw $t2, 8($sp)
			sw $t3, 12($sp)
			sw $t4, 16($sp)
		
			jal DrawSprite
		
			# Pop
			lw $t0, 0($sp)
			lw $t1, 4($sp)
			lw $t2, 8($sp)
			lw $t3, 12($sp)
			lw $t4, 16($sp)
			addi $sp, $sp, 20
			
			addi $t3, $t3, 64
			addi $t4, $t4, 1
			
		addi $t1, $t1, 1	# j++
		j DrawMapLoop2
		DrawMapLoop2Exit:
		addi $t3, $t3, 31808	# Salto para a linha seguinte de 4((512*16)-(15*16))
	li $t1, 0		# j = 0
	addi $t0, $t0, 1	# i++
	j DrawMapLoop1
	DrawMapLoop1Exit:
	
	# Pop
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# Funcao que retorna o endereço na memoria do Tile
# 	a0: Posicao x do tile
#	a1: Posicao y do tile
#	v0: Endereco do tile
GetTileAddress:
	sll $a0, $a0, 6		# x * 16 * 4 = 2^6
	sll $a1, $a1, 14	# y * 512 * 8 * 4 = y * 2^14
	
	li $v0, 0x10044040
	add $v0, $v0, $a0
	add $v0, $v0, $a1
	
	jr $ra
	

# Funcao que retorna o endereco na memoria de uma posicao em unidades
# 	a0: Posicao x em unidades
#	a1: Posicao y em unidades
#	v0: Endereco da unidade
GetUnitAddress:
	sll $a0, $a0, 2		# x * 4 bytes = 2^2
	sll $a1, $a1, 11	# y * 512 * 4 = y * 2^11
	
	li $v0, 0x10044040	# Endereco base do mapa
	add $v0, $v0, $a0
	add $v0, $v0, $a1
	
	jr $ra

# Funcao que inicializa elementos como
# interface, mapa e jogador.
InitGame:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal PaintBackground
	jal DrawMap

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

.include "sprites.asm"
