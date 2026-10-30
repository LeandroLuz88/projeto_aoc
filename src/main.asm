.data

.text
.globl main

main:

	jal InitGame
	
	GameLoop:
		
		li $v0, 32
		li $a0, 30	# 30 ps de atraso a cada loop
		syscall
	j GameLoop
	
	j Exit



Exit:
	li $v0, 10
	syscall

.include "render.asm"