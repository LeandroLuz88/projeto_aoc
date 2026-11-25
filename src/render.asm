# Configurações de bitmap:
#	- Unit Width:		2
#	- Unit Height:		2
#	- Display Width:	1024
#	- Display Height:	512
#	- Base address:		0x100040000 (heap)

.eqv BITMAP_BASE	0x10040000	# Endereço base do bitmap
.eqv BITMAP_END		0x100C0000	# Endereço final do bitmap: BITMAP_BASE + [4 * (1024/2) * (512/2)]
.eqv MAP_BASE		0x10044220	# Endereço da unidade superior esquerda

.eqv Y_JUMP	2048	# Valor necessario para deslocar uma unidade para baixo
.eqv Y_SHIFT	11	# log_2 (Y_JUMP)

.eqv BACKGROUND_COLOR	0x333344
.eqv BOX_COLOR		0x57576c


.data

.text

# Pinta todo o bitmap de uma cor
PaintBackground:
	li $t0, BITMAP_BASE
	li $t1, BITMAP_END
	li $t2, BACKGROUND_COLOR	# Cor
	
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
	li $t3, MAP_BASE	# Endereço base do mapa (Endereço base + 251936960)
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
	
	li $v0, MAP_BASE	# Endereco base do mapa
	add $v0, $v0, $a0
	add $v0, $v0, $a1
	
	jr $ra
	
	
# Funcao que retorna o endereco na memoria de uma posicao em unidades
# 	a0: Posicao x em unidades
#	a1: Posicao y em unidades
#	v0: Endereco da unidade
GetUnitAddress:
	sll $a0, $a0, 2		# x * 4 bytes = 2^2
	sll $a1, $a1, Y_SHIFT
	
	li $v0, MAP_BASE	# Endereco base do mapa
	add $v0, $v0, $a0
	add $v0, $v0, $a1
	
	jr $ra
	

# Funcao que retorna o endereco na memoria de uma posicao em unidades
# 	a0: Posicao x em unidades
#	a1: Posicao y em unidades
#	v0: Endereco da unidade
GetBitmapUnitAddress:
	sll $a0, $a0, 2	
	sll $a1, $a1, Y_SHIFT	
	
	li $v0, BITMAP_BASE	# Endereco base do bitmap
	add $v0, $v0, $a0
	add $v0, $v0, $a1
	
	jr $ra
	
	
# Retorna a cor do fundo em uma posição
#	a0: Posição x em unidades
#	a1: Posição y em unidades
#	v0: Cor (0x00RRGGBB)
BackgroundColor:
	# busca tipo de sprite do fundo do tile
	srl $t2, $a0, 4		# floor(x/16) = x_tile
	srl $t3, $a1, 4		# floor(y/16) = y_tile
	sll $t4, $t3, 4		# y_tile * 16
	sub $t3, $t4, $t3	# (y_tile * 16) - y_tile = y_tile * 15
	add $t2, $t2, $t3
	la $t3, Map
	add $t2, $t2, $t3	# endereco do indice do sprite de fundo
	lbu $t2, 0($t2)		# indice do sprite (0 = Grass, 1 = Dirt)
	move $t5, $t2

	# busca endereco do sprite do fundo do tile do ponto
	sll $t2, $t2,  2
	la $t3, MapSprite
	add $t2, $t2, $t3	# endereco do endereco do sprite de fundo
	lw $t2, 0($t2)		# endereco do sprite de fundo
	
	andi $t0, $a0, 15	# x mod 16
	andi $t1, $a1, 15	# y mod 16
	sll $t1, $t1, 4		# (y mod 16) * 16 = inicio da linha no sprite
	add $t0, $t0, $t1	# indice do ponto no sprite
	add $t0, $t0, $t2
	lbu $t0, 0($t0)		# indice da cor

	# Mostra a grama em baixo da parte transparente de torres
    bne $t0, $zero, BackgroundHasColor
    ble $t5, 1, BackgroundHasColor  # grama ou terra
    la $t2, Grass
    add $t0, $t6, $t2
    lbu $t0, 0($t0)
	
BackgroundHasColor:
	sll $t0, $t0, 2		# indice * 4
	la $t1, Colors
	add $t0, $t0, $t1
	lw $v0, 0($t0)		# cor
	
	jr $ra

# Desenha um retangulo de uma determinada cor na interface
# 	a0: Posicao x em unidades do bitmap
#	a1: Posicao y em unidades do bitmap
#	a2: Largura
#	a3: Altura
#	t0: cor (RRGGBB)
DrawRectangle:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal GetBitmapUnitAddress	# os atributos ja estao nos registradores
	
	move $t1, $v0
	move $t2, $zero
	move $t3, $zero
	
	li $t4, Y_JUMP
	sll $t5, $a2, 2
	sub $t4, $t4, $t5	# salto para a linha seguinte
	
	DRecRow:
	beq $t3, $a3, DRecRowExit
		DRecCol:
		beq $t2, $a2, DRecColExit
			sw $t0, 0($t1)		# pinta
			addi $t1, $t1, 4	# desloca para a proxima coluna
		addi $t2, $t2, 1
		j DRecCol
		DRecColExit:
	add $t1, $t1, $t4	# desloca para a proxima linha
	move $t2, $zero
	addi $t3, $t3 1
	j DRecRow
	DRecRowExit:
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra

# Funcao que inicializa elementos como
# interface, mapa e jogador.
InitGame:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal PaintBackground
	jal DrawMap
	
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


# Inicializa elementos visuais do layout de jogo
InitGameLayout:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a0, 8
	li $a1, 8
	li $a2, 120
	li $a3, 112
	li $t0, BOX_COLOR
	jal DrawRectangle
	
	li $a0, 8
	li $a1, 136
	li $a2, 120
	li $a3, 112
	li $t0, BOX_COLOR
	jal DrawRectangle
	
	li $a0, 384
	li $a1, 8
	li $a2, 120
	li $a3, 112
	li $t0, BOX_COLOR
	jal DrawRectangle
	
	li $a0, 384
	li $a1, 136
	li $a2, 120
	li $a3, 112
	li $t0, BOX_COLOR
	jal DrawRectangle
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra