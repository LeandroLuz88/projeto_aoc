.data

# Posicao inicial do jogador em unidades do bitmap
PlayerX: .word 112
PlayerY: .word 112

# Onde o jogador esta desenhado na tela agora (comeca igual a PlayerX/Y)
DrawnUnitX: .word 112
DrawnUnitY: .word 112

# Destino do movimento do jogador (se estah parado, eh a posicao do jogador)
TargetUnitX: .word 112
TargetUnitY: .word 112

# Unidades andadas por frame (8 unidades = 1 tile)
PlayerSpeed: .word 6 # da pra deixar em 2 ou 3

# Indica de ha movimento ou nao, 0 == parado, 1 == movimentando
Moving: .word 0

.text

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
	
	addi $t1, $t1, -16	# destino: 1 tile acima
	
	la $t0, TargetUnitY
	sw $t1, 0($t0)
	j StartMove
MoveLeft:
	la $t0, PlayerX
	lw $t1, 0($t0)
	
	# Se for sair do mapa
	blez $t1, InputDone
	
	addi $t1, $t1, -16	# destino: 1 tile a esquerda
	
	la $t0, TargetUnitX
	sw $t1, 0($t0)
	j StartMove
MoveDown:
	la $t0, PlayerY
	lw $t1, 0($t0)
	
	# Se for sair do mapa
	li $t2, 224		# 14 * 16
	slt $t2, $t1, $t2
	beq $t2, $zero, InputDone
	
	addi $t1, $t1, 16	# destino: 1 tile abaixo
	
	la $t0, TargetUnitY
	sw $t1, 0($t0)
	j StartMove
MoveRight:
	la $t0, PlayerX
	lw $t1, 0($t0)
	
	# Se for sair do mapa
	li $t2, 224		# 14 * 16
	slt $t2, $t1, $t2
	beq $t2, $zero, InputDone
	
	addi $t1, $t1, 16	# destino: 1 tile a direita
	
	la $t0, TargetUnitX
	sw $t1, 0($t0)
	j StartMove
	
StartMove:
	la $t0, Moving
	li $t1, 1
	sw $t1, 0($t0)
	j InputDone


# Aproxima um valor do seu destino, sem passar dele
#	a0: Valor atual
#	a1: Destino
#	a2: Velocidade (quanto andar por chamada, > 0)
#	v0: Novo valor
StepToward:
	sub $t0, $a1, $a0	# t0 = distancia ate o destino (com sinal)
	bltz $t0, StepBack
	
	# Destino a frente (ou ja chegou)
	slt $t1, $a2, $t0	# 1 se velocidade < distancia
	beq $t1, $zero, StepArrive
	add $v0, $a0, $a2
	jr $ra
	
	StepBack:
	sub $t0, $zero, $t0	# t0 = |distancia|
	slt $t1, $a2, $t0
	beq $t1, $zero, StepArrive
	sub $v0, $a0, $a2
	jr $ra
	
	StepArrive:
	move $v0, $a1		# Se falta menos que um passo, para exatamente no destino
	jr $ra
	

# Atualiza o estado do jogador a cada frame
UpdatePlayer:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, Moving
	lw $t1, 0($t0)
	beq $t1, $zero, UpdateDone	# Parado: nada a fazer
	
	# Avanca PlayerSpeed unidades em direcao ao destino (eixo X)
	la $t0, PlayerX
	lw $a0, 0($t0)
	la $t0, TargetUnitX
	lw $a1, 0($t0)
	la $t0, PlayerSpeed
	lw $a2, 0($t0)
	jal StepToward
	la $t0, PlayerX
	sw $v0, 0($t0)
	
	# O mesmo no eixo Y
	la $t0, PlayerY
	lw $a0, 0($t0)
	la $t0, TargetUnitY
	lw $a1, 0($t0)
	la $t0, PlayerSpeed
	lw $a2, 0($t0)
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
RenderPlayer:
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