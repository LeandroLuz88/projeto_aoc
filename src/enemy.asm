.data

# Inimigo:
#	Reservado [0, 1]	(0)
#	EnemyX [0, 224]		(1)
#	EnemyY [0, 224]		(2)
#	Path [0, 255]		(3)
#	HP [0, 255]		(4)
#	Type [0, 3]		(5)
#	SlowTime [0, 255]	(6)
#	EXTRA
# Tamanho de um inimigo: 8 bytes
# Possiveis atributos adicionais:


MaxEnemies:	.word 10
AliveEnemies:	.word 0
EnemySize:	.word 8
Enemies: 	.space 80	# 8 bytes * 10 inimigos
EnemyCooldown:	.word 0		# Intervalo entre um salto e outro dos inimigos

# Estrutura de tipos de inimigos
#	| sprite | vida inicial | velocidade | recompensa |
.align 0
EnemyType:
	.byte 0, 30, 6, 5	# Zumbi comum
	.byte 1, 50, 3, 8

.align 2
EnemySpriteType:
	.word EnemySprite0
	.word EnemySprite1


.text

# Inicializa o vetor de inimigos
InitEnemies:
	li $t0, 0
	lw $t1, MaxEnemies
	la $t2, Enemies
	lw $t3, EnemySize
	
	IELoop:
	beq $t0, $t1, IELoopExit
		# Define a posição como não reservada
		sw $zero, 0($t2)
		addu $t2, $t2, $t3
	addi $t0, $t0, 1
	j IELoop
	IELoopExit:
	
	jr $ra
		

# Gera inimigo no inicio do caminho
#	- a0: tipo do inimigo
# 	- v0 = 1: inimigo alocado com sucesso
#	- v0 = 0: inimigo nao alocado por falta de espaco
SpawnEnemy:
	li $t0, 0
	lw $t1, AliveEnemies
	la $t2, Enemies
	lw $t5, MaxEnemies
	
	# Se o vetor de inimigo estiver lotado, encerra
	slt $t5, $t1, $t5
	bnez $t5, SEBranch1
	li $v0, 0	# Falha: inimigo nao spawnado
	jr $ra
	
	SEBranch1:
	
	sll $t3, $t1, 3
	add $t2, $t2, $t3
	addi $t1, $t1, 1
	sw $t1, AliveEnemies
	la $t3, EnemyType
	sll $t4, $a0, 2
	add $t3, $t3, $t4
		
	# Carrega os atributos do inimigo na posicao encontrada
	li $t4, 1
	sb $t4, 0($t2)		# Reservado = 1
	li $t4, 0
	sb $t4, 1($t2)		# X
	li $t4, 16
	sb $t4, 2($t2)		# Y
	li $t4, 0
	sb $t4, 3($t2) 		# Path
	lbu $t4, 1($t3)
	sb $t4, 4($t2)		# HP
	sb $a0, 5($t2)		# Type
	sb $zero, 6($t2)	# SlowTime

	li $v0, 1	# Sucesso: inimigo spawnado
	jr $ra
	

# Percorre o vetor de inimigos e atualiza suas posicoes atuais
# e, se necessario, suas posicoes alvo e renderiza o sprite no
# mapa
UpdateEnemies:
	# Verifica se esta no tempo do inimigo dar um passo
	lw $t0, EnemyCooldown
	beqz $t0, CooldownCheckBranch
	addi $t0, $t0, -1
	sw $t0, EnemyCooldown
	jr $ra
	CooldownCheckBranch:
	li $t0, 25	# Intervalo de cooldown
	sw $t0, EnemyCooldown

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal EraseAllEnemies

	move $s0, $zero
	lw $s1, AliveEnemies
	la $s2, Enemies
	la $s3, EnemyType
	
	# Loop para percorrer vetor de inimigos
	UELoop:
	beq $s0, $s1, UELoopExit
		
		# Se a posicao nao estiver reservada, pula
		lbu $t6, 0($s2)
		beqz $t6, UEBranch
		
		# (Se vida = 0, liberar)
		
		lbu $s4, 5($s2)		# Carrega o tipo
		sll $s4, $s4, 2		# tipo * 4 (tipo especifico)
		add $s4, $s4, $s3
		lbu $a2, 2($s4)		# Carrega velocidade

		lbu $t8, 3($s2)		# Carrega ponto do caminho
		sll $t8, $t8, 1		# ponto * 2
		la $t5, Path
		add $t8, $t8, $t5
		lbu $s5, 0($t8)		# TargetX
		lbu $s6, 1($t8)		# TargetY
			
		
		# 1) Avanca inimigo na direcao X
		lbu $a0, 1($s2)
		move $a1, $s5
		jal StepToward
		sb $v0, 1($s2)
		
		# 2) Avanca inimigo na direcao Y
		lbu $a0, 2($s2)
		move $a1, $s6
		jal StepToward
		sb $v0, 2($s2)
			
		# 3) Renderiza o inimigo
		lbu $a0, 1($s2)
		lbu $a1, 2($s2)
		jal GetUnitAddress
		move $a1, $v0
		
		lbu $t6, 0($s4)		# Carrega indice de sprite
		sll $t6, $t6, 2
		la $t7, EnemySpriteType
		add $t6, $t6, $t7
		lw $a0, 0($t6)
		li $a2, 16
		li $a3, 16
		
		jal DrawSprite
		
		# 4) Se chegou ao destino, muda o destino
		lbu $t8, 1($s2)		# X
		lbu $t9, 2($s2)		# Y
		
		bne $t8, $s5, UEBranch	# Pule se X != TargetX
		bne $t9, $s6, UEBranch	# Pule se Y != TergetY
		
		# Incrementa o path do inimigo
		lbu $t6, 3($s2)
		addi $t6, $t6, 1
		sb $t6, 3($s2)
		
		UEBranch:
		addi $s2, $s2, 8 	# Endereco atual no vetor + EnemySize
	addi $s0, $s0, 1
	j UELoop
	UELoopExit:
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	
# Apaga todos os sprites de inimigos do mapa
# substituindo-os pelo sprite de terra
EraseAllEnemies:
	# Push
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $s0, $zero
	lw $s1, AliveEnemies
	la $s2, Enemies
	
	# Percorre vetor de inimigos
	EAELoop:
	beq $s0, $s1, EAELoopExit
		# Se a posicao estiver vazia, pule
		lbu $t0, 0($s2)
		beqz $t0, EAEBranch0
		
		# Se indice de reservado for 2, mude para 0
		bne $t0, 2, EAEBranch3
		sb $zero, 0($s2)
		j EAELoopExit
		EAEBranch3:
		
		# identifica tiles
		lbu $s3, 1($s2)		# X
		lbu $s4, 2($s2)		# Y
		addi $a0, $s3, 15	# X da ponta superior direita
		addi $a1, $s4, 15	# Y da ponta inferior esquerda
		andi $s3, $s3, 0xFFF0	# trunca X para o maior multiplo de 16
		andi $s4, $s4, 0xFFF0	# trunca Y para o maior multiplo de 16
		andi $a0, $a0, 0xFFF0	# trunca X da ponta superior direita
		andi $a1, $a1, 0xFFF0	# trunca Y da ponta superior direita
		
		# 1) Caso o inimigo esteja ocupando 2 tiles no eixo
		# horizontal, pinte antes o da direita
		beq $s3, $a0, EAEBranch1
		
		move $a1, $s4
		
		jal GetUnitAddress
		
		la $a0, Dirt
		move $a1, $v0
		li $a2, 16
		li $a3, 16
		
		jal DrawSprite
		
		j EAEBranch2
		
		# 2) Caso o inimigo esteja ocupando 2 tiles no eixo
		# vertical, pinte antes o de baixo
		EAEBranch1:
		beq $s4, $a1, EAEBranch2
		
		move $a0, $s3
		
		jal GetUnitAddress
		
		la $a0, Dirt
		move $a1, $v0
		li $a2, 16
		li $a3, 16
		
		jal DrawSprite
		
		# 3) Pinta o tile da posicao do inimigo truncada
		EAEBranch2:
		
		move $a0, $s3
		move $a1, $s4
		
		jal GetUnitAddress
		
		la $a0, Dirt
		move $a1, $v0
		li $a2, 16
		li $a3, 16
		
		jal DrawSprite

		EAEBranch0:
		addi $s2, $s2, 8
	addi $s0, $s0, 1
	j EAELoop
	EAELoopExit:
	
	# Pop
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


# Apaga um inimigo especifico.
#	- a0: indice do inimigo
EraseEnemy:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $s2, Enemies
	sll $t0, $a0, 3
	add $s2, $s2, $t0
	
	# identifica tiles
	lbu $s3, 1($s2)		# X
	lbu $s4, 2($s2)		# Y
	addi $a0, $s3, 15	# X da ponta superior direita
	addi $a1, $s4, 15	# Y da ponta inferior esquerda
	andi $s3, $s3, 0xFFF0	# trunca X para o maior multiplo de 16
	andi $s4, $s4, 0xFFF0	# trunca Y para o maior multiplo de 16
	andi $a0, $a0, 0xFFF0	# trunca X da ponta superior direita
	andi $a1, $a1, 0xFFF0	# trunca Y da ponta superior direita
	
	# 1) Caso o inimigo esteja ocupando 2 tiles no eixo
	# horizontal, pinte antes o da direita
	beq $s3, $a0, EEBranch1
		
	move $a1, $s4
	
	jal GetUnitAddress
		
	la $a0, Dirt
	move $a1, $v0
	li $a2, 16
	li $a3, 16
	
	jal DrawSprite
	
	j EEBranch2
	
	# 2) Caso o inimigo esteja ocupando 2 tiles no eixo
	# vertical, pinte antes o de baixo
	EEBranch1:
	beq $s4, $a1, EEBranch2
	
	move $a0, $s3
		
	jal GetUnitAddress
		
	la $a0, Dirt
	move $a1, $v0
	li $a2, 16
	li $a3, 16
		
	jal DrawSprite
		
	# 3) Pinta o tile da posicao do inimigo truncada
	EEBranch2:
		
	move $a0, $s3
	move $a1, $s4
		
	jal GetUnitAddress
		
	la $a0, Dirt
	move $a1, $v0
	li $a2, 16
	li $a3, 16
		
	jal DrawSprite
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


# Mata um determinado inimigo e organiza o array de inimigos
#	- a0: indice do inimigo
KillEnemy:	
	lw $t1, AliveEnemies
	
	# Se o array estiver vazio, encerra
	bnez $t1, KEBranch0
	jr $ra
	KEBranch0:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, Enemies
	sll $t2, $a0, 3		# indice * 8
	add $t0, $t0, $t2
	sub $t3, $t1, $a0	# (inimigos vivos) - (indice)
	
	# Se o indice for do ultimo inimigo, nao reordena
	beq $t3, 1, KEBranch1
	
	# Se o indice for de um inimigo do meio do array
	# organiza o array para que nao haja espacos
	# vazios entre os espacos reservados
	KELoop:
	addi $t3, $t3, -1
	
	# Carrega o inimigo seguinte em duas words de 4 bytes
	lw $t4, 8($t0)
	lw $t2, 12($t0)
	
	# Armazena as duas words na posicao atual
	sw $t4, 0($t0)
	sw $t2, 4($t0)
	
	# Pula para a posicao seguinte
	addi $t0, $t0,  8
	addi $a0, $a0, 1
	
	bnez $t3, KELoop
	
	KEBranch1:
	
	sb $zero, 0($t0)	# Reservado = 0
	addi $t1, $t1, -1
	sw $t1, AliveEnemies	# Decrementa inimigos vivos
	jal EraseEnemy

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	
	
	
	
	
	
	
	
	
	
	