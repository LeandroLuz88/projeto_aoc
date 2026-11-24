.data

.align 0
Map:	# 15x15 tiles
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

# Vetor de posicoes target dos inimigos 
# (Todos os valores são multiplicados por 16)
Path:
    .byte 0, 16	        # (0, 1)
    .byte 176, 16   	# (11, 1)
    .byte 176, 80   	# (11, 5)
    .byte 128, 80   	# (8, 5)
    .byte 128, 128  	# (8, 8)
    .byte 192, 128 	# (12, 8)
    .byte 192, 160  	# (12, 10)
    .byte 64, 160    	# (4, 10)
    .byte 64, 80     	# (4, 5)
    .byte 16, 80    	# (1, 5)
    .byte 16, 208	# (1, 13)
    .byte 224, 208	# (14, 13)
    .byte 225, 225	# Fim

.align 2
# Vetor de sprites do mapa
MapSprite:
	.word Grass		# 0
	.word Dirt		# 1
	.word Grass		# 2 (torre em construcao possui sprite de grama no fundo)
	.word TowerSimple	# 3
	.word TowerIce		# 4
	.word TowerRifle	# 5
	.word TowerCannon	# 6
    
.text
	
	
