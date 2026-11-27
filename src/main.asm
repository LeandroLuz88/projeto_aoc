.data

.text
.globl main

main:
	jal InitGame
	jal InitEnemies
	jal InitGameLayout
	
	GameLoop:
		jal ReadInput
		jal UpdatePlayer
		jal UpdateTowers
		jal RenderPlayer
		jal UpdateEnemies
		
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
.include "tower.asm"
.include "enemy.asm"
.include "map.asm"
.include "game.asm"
