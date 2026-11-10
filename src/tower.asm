# Sistema de torres
# Posicoes de torre sao guardadas em tiles (0..14)
# Tempos sao contados em frames do GameLoop

# Tipos de torre, identifica qual eh
.eqv TOWER_SIMPLE  0
.eqv TOWER_ICE     1
.eqv TOWER_RIFLE   2
.eqv TOWER_CANNON  3

# Limites e estados
.eqv MAX_TOWERS      32
.eqv MAX_LEVEL       3
.eqv BUILD_FRAMES    120 # contador de frames pra construcao
.eqv TILE_TOWER      2 # indica a presenca de uma torre no mapa de tile

.eqv STATE_EMPTY     0
.eqv STATE_BUILDING  1
.eqv STATE_ACTIVE    2

# Struct Tower: 8 words = 32 bytes
# Guarda so o que e proprio de cada torre e muda com o tempo
# Alcance, dano, cadencia e efeito ficam em TowerStats, buscados por tipo e nivel
.eqv TOWER_SIZE      32
.eqv T_STATE          0
.eqv T_TILEX          4 # coordenada X
.eqv T_TILEY          8 # coordenada Y
.eqv T_TYPE          12
.eqv T_LEVEL         16
.eqv T_COOLDOWN      20 # cooldown do tiro
.eqv T_TIMER         24 # tempo pra construcao
.eqv T_TARGET        28 # em quem ta mirando agora, se 0 nao tem alvo

# Linha de TowerStats: 4 words = 16 bytes
# Informacoes fundamentais dos tipos e level de cada torre
.eqv STAT_SIZE       16
.eqv STAT_RANGE       0
.eqv STAT_DAMAGE      4
.eqv STAT_COOLDOWN    8
.eqv STAT_EFFECT     12

.data

# Uma linha por tipo e nivel, na ordem: simples 1-3, gelo 1-3, rifle 1-3, canhao 1-3
# Endereco da linha = TowerStats + (tipo * MAX_LEVEL + nivel - 1) * STAT_SIZE
# VALORES PROVISORIOS: o balanceamento e so mexer nesta tabela.
#       alcance (tiles), dano, cadencia (frames), efeito
TowerStats:
    # simples
    .word 3,  10,  40, 0
    .word 3,  15,  32, 0
    .word 4,  22,  26, 0
    # gelo (efeito = duracao da lentidao, em frames)
    .word 2,   3,  50, 60
    .word 2,   5,  40, 90
    .word 3,   8,  32, 120
    # rifle (cobre o mapa inteiro)
    .word 99, 25, 120, 0
    .word 99, 38,  96, 0
    .word 99, 50,  76, 0
    # canhao (efeito = raio da explosao, em tiles)
    .word 2,  15, 100, 1
    .word 2,  22,  80, 1
    .word 3,  30,  64, 2

# MAX_TOWERS * TOWER_SIZE = 32 * 32
Towers: .space 1024

# O sistema de hordas deve deixar 1 entre hordas e 0 durante uma horda.
BuildingEnabled: .word 1

# Ultima posicao do jogador para a qual as torres vizinhas foram redesenhadas
LastRedrawX: .word 112
LastRedrawY: .word 112



.text

# a0: tile X
# a1: tile Y
# v0: endereco do byte correspondente em Map
MapTileAddress:
    mul $t0, $a1, 15       # y * numero de colunas
    add $t0, $t0, $a0      # y * 15 + x
    la $t1, Map
    add $v0, $t1, $t0
    jr $ra


# v0: endereco de um slot vazio em Towers, 0 se todos estiverem ocupados
FindFreeTowerSlot:
    la $t0, Towers
    li $t1, 0
FindFreeTowerSlotLoop:
    beq $t1, MAX_TOWERS, FindFreeTowerSlotNone
    lw $t2, T_STATE($t0)
    beq $t2, STATE_EMPTY, FindFreeTowerSlotFound
    addi $t0, $t0, TOWER_SIZE
    addi $t1, $t1, 1
    j FindFreeTowerSlotLoop
FindFreeTowerSlotFound:
    move $v0, $t0
    jr $ra
FindFreeTowerSlotNone:
    move $v0, $zero
    jr $ra


# a0: tile X
# a1: tile Y
# v0: endereco da torre nesse tile, 0 se nao houver
FindTowerAt:
    la $t0, Towers
    li $t1, 0
FindTowerAtLoop:
    beq $t1, MAX_TOWERS, FindTowerAtNone
    lw $t2, T_STATE($t0)
    beq $t2, STATE_EMPTY, FindTowerAtNext
    lw $t3, T_TILEX($t0)
    bne $t3, $a0, FindTowerAtNext
    lw $t3, T_TILEY($t0)
    bne $t3, $a1, FindTowerAtNext
    move $v0, $t0
    jr $ra
FindTowerAtNext:
    addi $t0, $t0, TOWER_SIZE
    addi $t1, $t1, 1
    j FindTowerAtLoop
FindTowerAtNone:
    move $v0, $zero
    jr $ra


# Linha de TowerStats que vale para o tipo e o nivel atuais da torre
# a0: endereco da torre
# v0: endereco da linha (STAT_RANGE, STAT_DAMAGE, STAT_COOLDOWN, STAT_EFFECT)
GetTowerStats:
    lw $t0, T_TYPE($a0)
    mul $t0, $t0, MAX_LEVEL     # primeira linha do tipo
    lw $t1, T_LEVEL($a0)
    add $t0, $t0, $t1
    addi $t0, $t0, -1           # nivel comeca em 1
    mul $t0, $t0, STAT_SIZE
    la $t1, TowerStats
    add $v0, $t1, $t0
    jr $ra


# a0: tipo da torre 
# v0: 1 se iniciou a construcao, 0 se nao iniciou
TryBuildTower:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)

    move $s0, $a0

    la $t0, BuildingEnabled
    lw $t0, 0($t0)
    beq $t0, $zero, TryBuildTowerFail

    # PlayerX/Y sao em unidades. Dividir por 16 converte em tile
    la $t0, PlayerX
    lw $t0, 0($t0)
    srl $s1, $t0, 4       # s1 = tile X do jogador
    la $t0, PlayerY
    lw $t0, 0($t0)
    srl $s2, $t0, 4       # s2 = tile Y do jogador

    # O tile deve ser grama: Map[tile] == 0
    move $a0, $s1
    move $a1, $s2
    jal MapTileAddress
    move $s4, $v0
    lbu $t0, 0($s4)
    bne $t0, $zero, TryBuildTowerFail

    jal FindFreeTowerSlot
    beq $v0, $zero, TryBuildTowerFail
    move $s3, $v0

    # Parte de economia quando tiver
    # Se nao tem dinheiro, vai pro TryBuildTowerFail
    # Se tiver vai descontar aqui

    # O tile agora esta ocupado por uma torre
    li $t0, TILE_TOWER
    sb $t0, 0($s4)

    # Inicializa a torre em construcao
    li $t0, STATE_BUILDING
    sw $t0, T_STATE($s3)
    sw $s1, T_TILEX($s3)
    sw $s2, T_TILEY($s3)
    sw $s0, T_TYPE($s3)
    li $t0, 1
    sw $t0, T_LEVEL($s3)
    li $t0, BUILD_FRAMES
    sw $t0, T_TIMER($s3)
    sw $zero, T_COOLDOWN($s3)
    sw $zero, T_TARGET($s3)

    li $v0, 1
    j TryBuildTowerEnd

TryBuildTowerFail:
    move $v0, $zero

TryBuildTowerEnd:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra
