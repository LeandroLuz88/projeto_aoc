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

.align 2
# Vetor de sprites do mapa
MapSprite:
	.word Grass	# 0
	.word Dirt	# 1
   
# Vetor de posicoes target dos inimigos 
# (Todos os valores são multiplicados por 16)
.align 2
PathSize: .word 11
.align 0
Path:
    .byte 176, 16   	 # (11, 1)
    .byte 176, 80   	 # (11, 5)
    .byte 128, 80   	 # (8, 5)
    .byte 128, 128  	 # (8, 8)
    .byte 192, 128 	 # (12, 8)
    .byte 192, 160  	# (12, 10)
    .byte 64, 160    	# (4, 10)
    .byte 64, 80     	# (4, 5)
    .byte 16, 80    	# (1, 5)
    .byte 16, 208	# (1, 13)
    .byte 224, 208	# (14, 13)

MapStart:	.word 3840	# Unidade de início do caminho relativa ao mapa (15 * 16 * 16)

MapStartX: .word 0
MapStartY: .word 16	# 1 * 16

    
.text
	
	
