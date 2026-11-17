# Os comentarios sao opcionais e servem
# apenas para testar a geracao de inimigos

.data

.text
.globl main

main:
	jal InitGame
	jal InitEnemies
	#li $a0, 0
	#jal SpawnEnemy
	
	#li $s7, 100

	
	GameLoop:
		addi $s7, $s7, -1
	
		jal ReadInput
		jal UpdatePlayer
		jal RenderPlayer
		jal UpdateEnemies
		
		#bnez $s7, Testbranch
		#li $a0, 1
		#li $s7 100
		#jal SpawnEnemy
		#Testbranch:
		
		li $v0, 32
		li $a0, 16	# 30 ps de atraso a cada loop
		syscall
	j GameLoop
	
	j Exit



Exit:
	li $v0, 10
	syscall

.include "render.asm"
.include "sprites.asm"
.include "player.asm"
.include "enemy.asm"
.include "map.asm"
