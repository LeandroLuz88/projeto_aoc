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