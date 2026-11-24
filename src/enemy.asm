# Struct Enemy:
# Estrutura de uma posicao no array "Enemies".
# Cada elemento possui ENEMY_SIZE bytes e
# cada byte representa um atributo variavel
# de um inimigo.
.eqv ENEMY_SIZE		8	# Tamanho de cada inimigo no array "Enemies". Recomendado ser multiplo de 4.
.eqv E_RESERVED	0
.eqv E_X	1
.eqv E_Y	2
.eqv E_PATH	3
.eqv E_HP	4
.eqv E_TYPE	5
.eqv E_SLOWTIME	6

.eqv MAX_ENEMIES	10
.eqv ENEMY_BYTES	80	# ENEMY_SIZE * MAX_ENEMIES

# Struct EnemyType:
# Armazena atributos constantes de cada tipo
# de inimigo.
.eqv ENEMY_TYPE_SIZE	4	# Tamanho de cada posicao no array "EnemyType"
.eqv ET_SPRITE	0	# indice do array EnemySpriteType
.eqv ET_INIT_HP	1	# vida inicial
.eqv ET_VEL	2	# numero de unidades que ele anda a cada salto
.eqv ET_COINS	3	# recompensa por matar o inimigo




.data

Enemies: 	.space ENEMY_BYTES	# Array de inimigos
AliveEnemies:	.word 0			# Inimigos vivos
EnemyCooldown:	.word 0			# Intervalo entre um salto e outro dos inimigos

# Array de tipos de inimigos
.align 0
EnemyType:
	.byte 0, 30, 6, 5	# Zumbi comum
	.byte 1, 50, 3, 8	# Zumbi com armadura

# Array de sprites de inimigos
.align 2
EnemySpriteType:
	.word EnemySprite0
	.word EnemySprite1




.text

# Funcoes que utilizam registradores do tipo s:
#	- UpdateEnemies
#	- EraseAllEnemies
#	- EraseEnemy

# Inicializa o vetor de inimigos
InitEnemies:
	li $t0, 0
	la $t1, Enemies
	
	IELoop:
	beq $t0, MAX_ENEMIES, IELoopExit
		# Define a posição como não reservada
		sb $zero, E_RESERVED($t1)
		addu $t1, $t1, ENEMY_SIZE
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
	
	# Se o vetor de inimigo estiver lotado, encerra
	li $t3, MAX_ENEMIES
	slt $t3, $t1, $t3
	bnez $t3, SEBranch1
	li $v0, 0	# Falha: inimigo nao spawnado
	jr $ra
	
	SEBranch1:
	
	mul $t3, $t1, ENEMY_SIZE
	add $t2, $t2, $t3
	addi $t1, $t1, 1
	sw $t1, AliveEnemies
	la $t3, EnemyType
	mul $t4, $a0, ENEMY_TYPE_SIZE
	add $t3, $t3, $t4
	
	# Carrega os atributos do inimigo na posicao encontrada
	li $t4, 1
	sb $t4, E_RESERVED($t2)		# Reservado = 1
	lbu $t4, Path
	sb $t4, E_X($t2)
	lbu $t4, Path+1
	sb $t4, E_Y($t2)
	li $t4, 0
	sb $t4, E_PATH($t2)
	lbu $t4, ET_INIT_HP($t3)
	sb $t4, E_HP($t2)
	sb $a0, E_TYPE($t2)
	sb $zero, E_SLOWTIME($t2)

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
	li $t0, 15	# Intervalo de cooldown
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
		
		lbu $t8, E_PATH($s2)		# Carrega ponto do caminho
		sll $t8, $t8, 1		# ponto * 2
		la $t5, Path
		add $t8, $t8, $t5
		lbu $s5, 0($t8)		# TargetX
		lbu $s6, 1($t8)		# TargetY
		
		# Verifica se chegou ao fim do caminho
		li $t1, 225
		bne $s5, $t1, UEBranch1
		
		move $a0, $s0
		
		addi $sp, $sp, -28
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		sw $s4, 16($sp)
		sw $s5, 20($sp)
		sw $s6, 24($sp)
		
		jal KillEnemy
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 28
		
		lw $s1, AliveEnemies
		j UELoop
		
		UEBranch1:
		
		lbu $s4, E_TYPE($s2)		# Carrega o tipo
		mul $s4, $s4, ENEMY_TYPE_SIZE	# tipo especifico
		add $s4, $s4, $s3
		lbu $a2, ET_VEL($s4)		# Carrega velocidade
		
		# 1) Avanca inimigo na direcao X
		lbu $a0, E_X($s2)
		move $a1, $s5
		jal StepToward
		sb $v0, E_X($s2)
		
		# 2) Avanca inimigo na direcao Y
		lbu $a0, E_Y($s2)
		move $a1, $s6
		jal StepToward
		sb $v0, E_Y($s2)
			
		# 3) Renderiza o inimigo
		lbu $a0, E_X($s2)
		lbu $a1, E_Y($s2)
		jal GetUnitAddress
		move $a1, $v0
		
		lbu $t6, ET_SPRITE($s4)		# Carrega indice de sprite
		sll $t6, $t6, 2
		la $t7, EnemySpriteType
		add $t6, $t6, $t7
		lw $a0, 0($t6)
		li $a2, 16
		li $a3, 16
		
		jal DrawSprite
		
		# 4) Se chegou ao destino, muda o destino
		lbu $t8, E_X($s2)
		lbu $t9, E_Y($s2)
		
		bne $t8, $s5, UEBranch	# Pule se X != TargetX
		bne $t9, $s6, UEBranch	# Pule se Y != TergetY
		
		# Incrementa o path do inimigo
		lbu $t6, E_PATH($s2)
		addi $t6, $t6, 1
		sb $t6, E_PATH($s2)
		
		UEBranch:
		addi $s2, $s2, ENEMY_SIZE	# Endereco atual no vetor + EnemySize
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
		lbu $t0, E_RESERVED($s2)
		beqz $t0, EAEBranch0
		
		# identifica tiles
		lbu $s3, E_X($s2)		# X
		lbu $s4, E_Y($s2)		# Y
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
		addi $s2, $s2, ENEMY_SIZE
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
	mul $t0, $a0, ENEMY_SIZE
	add $s2, $s2, $t0
	
	# identifica tiles
	lbu $s3, E_X($s2)
	lbu $s4, E_Y($s2)
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
# OBS: Essa funcao necessita que ENEMY_SIZE seja 8
KillEnemy:	
	lw $t1, AliveEnemies
	
	# Se o array estiver vazio, encerra
	bnez $t1, KEBranch0
	jr $ra
	KEBranch0:
	
	# Apaga o sprite
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $t1, 4($sp)
	sw $a0, 8($sp)
	jal EraseEnemy
	lw $ra, 0($sp)
	lw $t1, 4($sp)
	lw $a0, 8($sp)
	addi $sp, $sp, 12
	
	la $t0, Enemies
	mul $t2, $a0, ENEMY_SIZE
	add $t0, $t0, $t2
	sub $t3, $t1, $a0
	addi $t3, $t3, -1	# (inimigos vivos) - (indice) - 1
	
	# Se o indice for do ultimo inimigo, nao reordena
	beqz $t3, KEBranch1
	
	# Se o indice for de um inimigo do meio do array
	# organiza o array para que nao haja espacos
	# vazios entre os espacos reservados
	KELoop:
		addi $t3, $t3, -1
	
		# As seguintes operacoes necessitam que ENEMY_SIZE seja 8
	
		# Carrega o inimigo seguinte em duas words de 4 bytes
		lw $t4, 8($t0)
		lw $t2, 12($t0)
		
		# Armazena as duas words na posicao atual
		sw $t4, 0($t0)
		sw $t2, 4($t0)
	
		# Pula para a posicao seguinte
		addi $t0, $t0, 8
		addi $a0, $a0, 1	
	bnez $t3, KELoop
	
	KEBranch1:
	
	addi $t1, $t1, -1
	sw $t1, AliveEnemies	# Decrementa inimigos vivos
	
	sb $zero, E_RESERVED($t0)	# Reservado = 0
	
	
	jr $ra