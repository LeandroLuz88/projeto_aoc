# Padrões de Mensagens de Commit (Uma Linha)

Formato recomendado (baseado no Conventional Commits):
`<tipo>: <descrição curta no imperativo>`

---

## Tipos de Commits Comuns

* **`feat:`** Adição de uma nova funcionalidade
  * `feat: implementa sistema de moedas ao derrotar monstros`

* **`fix:`** Correção de um bug ou erro
  * `fix: corrige colisao do tiro com os monstros`

* **`refactor:`** Mudança no código que não altera funcionalidade (refatoração)
  * `refactor: simplifica instrucoes de renderizacao do mapa`

* **`docs:`** Alterações na documentação (como o README.md)
  * `docs: atualiza instrucoes do Projeto X no README`

* **`style:`** Formatação, espaçamento ou ajustes de estilo sem alterar código
  * `style: remove comentarios nao utilizados`

* **`perf:`** Melhoria no desempenho do código
  * `perf: otimiza contagem de vida dos monstros`

* **`chore:`** Tarefas de manutenção ou build sem alterar código principal
  * `chore: atualiza .gitignore para ignorar executaveis MARS/SPIM`

---

# Guias de Padronização do Projeto (Branches e Commits)

Este documento define o fluxo de trabalho do Git, os padrões de nomeação de *branches* e as convenções para mensagens de *commit*.

---

## Fluxo de Trabalho e Padrão de Branches

### Estrutura das Branches

* **`main`**: Branch principal que contém o código estável e pronto para entrega.
* **`develop`**: Branch de desenvolvimento integrado. É criada a partir da `main` e serve como base para a criação e junção de todas as funcionalidades.
* **Branches de Tarefas (`<tipo>/<titulo>`)**: Puxadas a partir da `develop` para desenvolver uma funcionalidade específica, corrigir bugs ou refatorar a lógica.

### Fluxo de Desenvolvimento

1. Crie uma nova branch a partir da `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b <tipo>/<titulo-da-branch>

2. Desenvolva as alterações e faça os commits seguindo o padrão.

3. Abra um Pull Request (PR) da sua branch com destino à develop.

4. Após a validação e testes na develop, é feito o PR da develop para a main.
