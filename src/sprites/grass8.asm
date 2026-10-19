.data
# Dimensoes: 8 x 8
SpriteWidth: .word 8
SpriteHeight: .word 8
Sprite:
    .byte 3, 3, 3, 3, 3, 3, 3, 3
    .byte 3, 3, 3, 3, 3, 3, 1, 3
    .byte 3, 3, 1, 3, 3, 3, 4, 3
    .byte 3, 3, 4, 3, 3, 3, 3, 3
    .byte 3, 3, 3, 3, 3, 3, 3, 3
    .byte 3, 3, 3, 3, 1, 3, 3, 3
    .byte 3, 3, 3, 3, 4, 3, 3, 3
    .byte 3, 3, 3, 3, 3, 3, 3, 3

.align 2
Colors:
    .word 0x000000
    .word 0x8FF43B
    .word 0x000000
    .word 0x3A9206
    .word 0x295C0B
    .word 0xFFA96F
    .word 0xDD8B53
    .word 0x032090
    .word 0xD02F17
    .word 0x2B1709

.text
