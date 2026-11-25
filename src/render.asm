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

# Medidas da fonte de caracteres
.eqv CHAR_WIDTH		5
.eqv CHAR_HEIGHT	8


.data

# Fonte de caracteres, de A a Z e 0 a 9.
# Cada byte é uma linha e cada bit do byte 
# representa um ponto a ser pintado
Font:
    # Letras maiusculas (A-Z)
    .byte 14,17,17,31,17,17,17,17    # A
    .byte 30,17,17,30,17,17,30,0     # B
    .byte 14,17,16,16,16,17,14,0     # C
    .byte 30,17,17,17,17,17,30,0     # D
    .byte 31,16,16,30,16,16,31,0     # E
    .byte 31,16,16,30,16,16,16,0     # F
    .byte 14,17,16,23,17,17,15,0     # G
    .byte 17,17,17,31,17,17,17,17   # H
    .byte 31,4,4,4,4,4,31,0          # I
    .byte 7,2,2,2,18,18,12,0         # J
    .byte 17,18,20,24,20,18,17,17   # K
    .byte 16,16,16,16,16,16,31,0     # L
    .byte 17,27,21,21,17,17,17,17   # M
    .byte 17,25,21,19,17,17,17,17   # N
    .byte 14,17,17,17,17,17,14,0     # O
    .byte 30,17,17,30,16,16,16,16   # P
    .byte 14,17,17,17,21,18,13,1     # Q
    .byte 30,17,17,30,20,18,17,17   # R
    .byte 15,16,16,14,1,1,30,0       # S
    .byte 31,4,4,4,4,4,4,4           # T
    .byte 17,17,17,17,17,17,14,0     # U
    .byte 17,17,17,17,17,10,4,4      # V
    .byte 17,17,17,21,21,21,10,10   # W
    .byte 17,17,10,4,10,17,17,17    # X
    .byte 17,17,10,4,4,4,4,4         # Y
    .byte 31,1,2,4,8,16,31,0         # Z

    # Numeros (0-9)
    .byte 14,17,19,21,25,17,14,0     # 0
    .byte 4,12,4,4,4,4,14,0          # 1
    .byte 14,17,1,2,4,8,31,0         # 2
    .byte 30,1,1,14,1,1,30,0         # 3
    .byte 2,6,10,18,31,2,2,2         # 4
    .byte 31,16,16,30,1,1,30,0       # 5
    .byte 14,16,16,30,17,17,14,0     # 6
    .byte 31,1,2,4,8,8,8,8           # 7
    .byte 14,17,17,14,17,17,14,0     # 8
    .byte 14,17,17,15,1,1,14,0       # 9




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
	

# Desenha um caractere no bitmap
#	a0: posicao x em unidades do bitmap
#	a1: posicao y em unidades do bitmap
#	a2: codigo ascii. Apenas letras MAIUSCULAS ou numeros
#	a3: cor
DrawChar:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# 1) Checando se o char é uma letra, um numero ou invalido

	li $t0, 65
	slt $t0, $a2, $t0	# < 'A'
	bnez $t0, CharIsNumber
	
	li $t0, 90
	slt $t0, $t0, $a2	# > 'Z'
	bnez $t0, DCExit
	
	# Indice do array Font como letra
	addi $t0, $a2, -65
	
	j DCBranch
	
	CharIsNumber:
	li $t0, 48
	slt $t0, $a2, $t0	# < '0'
	bnez $t0, DCExit
	
	li $t0, 57
	slt $t0, $t0, $a2	# > '9'
	bnez $t0, DCExit
	
	# Indice do array Font como numero
	addi $t0, $a2, -22	# -48 + 26
	
	
	# 2) Desenha o char no bitmap se for valido
	
	DCBranch:

	# Ajusta o array Font para o indice
	sll $t0, $t0, 3		# CHAR_HEIGHT = 8 = 2^3
	la $t1, Font
	add $t0, $t1, $t0	# Posicao que armazena os bytes do caractere
	
	jal GetBitmapUnitAddress	# Os atributos ja estao nos registradores
	move $t1, $v0		# Posicao no bitmap
	
	move $t2, $zero
	DCRow:
	beq $t2, CHAR_HEIGHT, DCRowEnd
		li $t4, 16	# 2^(CHAR_WIDTH) = 2^5
		lbu $t5, 0($t0)	# Byte da linha
		move $t3, $zero
		DCCol:
		beq $t3, CHAR_WIDTH, DCColEnd
			#Verifica se determinado bit do byte da linha eh 1 (pinta) ou 0 (nao pinta)
			and $t6, $t4, $t5
			beqz $t6, DCColBranch
			
			sw $a3, 0($t1)	# Pinta
			
			DCColBranch:
			
			srl $t4, $t4, 1		# Proximo bit
			addi $t1, $t1, 4	# Proxima posicao
		addi $t3, $t3, 1	# Proxima coluna
		j DCCol
		DCColEnd:
		addi $t0, $t0, 1
		addi $t1, $t1, 2028		# 4 * (512 - CHAR_WIDTH) = 4 * (512 - 5)
	addi $t2, $t2, 1	# Proxima linha
	j DCRow
	DCRowEnd:
	
	DCExit:
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
