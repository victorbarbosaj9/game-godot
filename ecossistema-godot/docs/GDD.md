# GDD: Ecossistema em Equilíbrio

Autor: João Victor Barbosa de Oliveira. Projeto de extensão do IF Sudeste, Curso de Godot.

## Resumo
Jogo de puzzle educativo para o ensino médio. O jogador monta um ecossistema, simula turnos e
precisa mantê-lo em equilíbrio, aprendendo cadeia alimentar e capacidade de suporte.

## Conceitos de Biologia
- Cadeia e teia alimentar (produtores, consumidores, predadores).
- Efeito dominó: remover ou adicionar uma espécie afeta as demais.
- Capacidade de suporte (K), fator limitante e equilíbrio dinâmico.

## Mecânica central
Para cada espécie, a cada turno:

    pop = pop + r * pop * (1 - pop / K) - predação

- Produtor: K = k_base (luz e água).
- Consumidor: K = soma(população da presa * eficiência).
- Predação = população do predador * taxa de caça (limitada à população da presa).
- População abaixo de 1 = extinção.

## Os 4 verbos (escopo do jogo)
1. Posicionar espécies. 2. Simular turnos. 3. Ler o gráfico (população em % de K). 4. Remover espécies.

## Regras da fase
- Orçamento de pontos; cada espécie tem um custo (remover devolve o custo).
- Vitória: todas as espécies obrigatórias vivas ao fim do objetivo (nº de turnos).
- Derrota: alguma espécie é extinta, ou faltam espécies obrigatórias no fim.
- O feedback explica o porquê do resultado (predação, superpopulação, folga).

## Fases
| Fase | Tema | Turnos | Orçamento | Estado |
|------|------|--------|-----------|--------|
| 1 | Capim, coelho e raposa | 20 | 6 | pronta |
| 2 | Teia alimentar (gafanhoto e sapo) | 20 | 9 | pronta |
| 3 | Espécie invasora (caramujo-africano fixo) | 25 | 6 | pronta |
| 4 | Ação humana (desmatamento e seca no turno 10; manter a cobra) | 30 | 7 | pronta |

Cada fase libera depois de concluir a anterior (progresso salvo em arquivo). Veja `docs/gabarito.md`.

## Fora do escopo (só se sobrar tempo)
Ajuste de taxas pelo jogador, eventos aleatórios, multiplayer, animações elaboradas, sons.

## Direção de arte
Pixel art, sprites 32x32 e fundos 480x270 em escala 2x (atualmente placeholders gerados por código, prontos para trocar por arte própria).
