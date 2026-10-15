
from PIL import Image

# Arquivos de entrada e saída
ARQUIVO_ENTRADA = "sprite.png"
ARQUIVO_SAIDA = "sprite.asm"
ARQUIVO_PALETA = "palette.gpl"

def converter_imagem(entrada, saida, arquivo_paleta):
    imagem = Image.open(entrada).convert("RGBA")

    largura, altura = imagem.size

    # Índice 0 será reservado para pixels transparentes.
    paleta = [(0, 0, 0)]
    indices_cores = {}
    pixels = []

    # Leitura do arquivo de paleta
    with open(arquivo_paleta, "r", encoding="utf-8") as arquivo:    
        arquivo.readline()
        arquivo.readline()
        arquivo.readline()
        arquivo.readline()

        for linha in arquivo:
            if linha.strip() == "":
                break

            partes = linha.split()

            r = int(partes[0])
            g = int(partes[1])
            b = int(partes[2])

            cor = (r, g, b)

            if cor not in indices_cores:
                indice = len(paleta)
                indices_cores[cor] = indice
                paleta.append(cor)

    for y in range(altura):
        linha = []

        for x in range(largura):
            r, g, b, a = imagem.getpixel((x, y))

            # Transparência: não desenhar esse pixel.
            if a < 128:
                linha.append(0)
                continue

            cor = (r, g, b)

            if cor not in indices_cores:
                linha.append(0)
                print(f"Cor não encontrada na paleta: {cor}")
            else:
                linha.append(indices_cores[cor])

        pixels.append(linha)

    with open(saida, "w", encoding="utf-8") as arquivo:
        arquivo.write(".data\n")
        arquivo.write(f"# Dimensoes: {largura} x {altura}\n")

        arquivo.write(f"SpriteWidth: .word {largura}\n")
        arquivo.write(f"SpriteHeight: .word {altura}\n")

        arquivo.write("Sprite:\n")

        for linha in pixels:
            valores = ", ".join(map(str, linha))
            arquivo.write(f"    .byte {valores}\n")

        # Alinha o endereço seguinte a uma fronteira de 4 bytes.
        arquivo.write("\n.align 2\n")
        arquivo.write("Colors:\n")

        for r, g, b in paleta:
            cor = (r << 16) | (g << 8) | b
            arquivo.write(f"    .word 0x{cor:06X}\n")

        arquivo.write("\n.text\n")

    print(f"Imagem convertida: {largura} x {altura}")
    print(f"Cores opacas distintas: {len(paleta) - 1}")
    print(f"Arquivo gerado: {saida}")



converter_imagem(ARQUIVO_ENTRADA, ARQUIVO_SAIDA, ARQUIVO_PALETA)
