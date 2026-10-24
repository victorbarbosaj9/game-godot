# Ecossistema em Equilíbrio

Jogo educativo de Biologia (Ecologia) feito em **Godot 4.3**.
Desenvolvido por **João Victor Barbosa de Oliveira**, para o projeto de extensão do **IF Sudeste**, Curso de Godot.
O jogador monta uma cadeia alimentar, simula turnos e descobre o que é **capacidade de suporte (K)**.

## Como abrir

1. Instale o [Godot 4.3 ou superior](https://godotengine.org/download) (versão padrão, não precisa do .NET).
2. Abra o Godot, clique em **Importar** e escolha o arquivo `project.godot` desta pasta.
3. Aperte **F5** para jogar. A cena inicial é o menu principal.

## Como jogar

- **Posicionar:** toque (ou arraste) uma espécie do painel da esquerda para o ecossistema. Cada espécie custa pontos do orçamento.
- **Simular:** use *Simular turno* ou *Simular 5 turnos*.
- **Cores:** a borda de cada cartão tem a mesma cor da linha da espécie no gráfico.
- **Ler o gráfico:** cada linha mostra a população de uma espécie em % da sua capacidade de suporte. A linha tracejada em 100% é o K. Acima dela, falta recurso e a população cai.
- **Remover:** toque no **x** da espécie, na área do ecossistema (o custo é devolvido).
- **Vencer:** manter as espécies obrigatórias vivas até o fim dos turnos do objetivo, sem que nenhuma espécie colocada por você seja extinta.

O botão **Tutorial** do menu ensina esses comandos passo a passo.
No fim de cada fase, a tela de resultado mostra o gráfico da partida e explica o que aconteceu com cada espécie.

## Fases

| Fase | Tema | Turnos | Orçamento |
|------|------|--------|-----------|
| 1 | Campo aberto: capim, coelho e raposa | 20 | 6 |
| 2 | Teia alimentar: gafanhoto e sapo entram na cadeia | 20 | 9 |
| 3 | Espécie invasora: o caramujo-africano já está no ecossistema | 25 | 6 |
| 4 | Ação humana: desmatamento e seca no turno 10; mantenha a cobra | 30 | 7 |

Cada fase só libera depois de concluir a anterior. O progresso é salvo em `user://progresso.cfg`
(no Godot: *Projeto > Abrir Pasta de Dados do Usuário*). No seletor há os botões **Liberar todas
(modo professor)** e **Apagar progresso**. As soluções estão em `docs/gabarito.md`.

## Estrutura de pastas

```
scripts/            lógica do jogo
  species.gd        Resource de espécie (população, r, K, quem come, custo, cor, ícone)
  ecosystem.gd      simulação por turnos (crescimento logístico + predação)
  level.gd          Resource de fase (espécies, orçamento, objetivo, evento, fundo)
  level_controller.gd  controla a cena da fase e monta a interface por código
  level_select.gd   seletor de fases com bloqueio
  game_manager.gd   autoload: estado global e progresso salvo
  main_menu.gd, result_screen.gd, tutorial.gd
  ui/               componentes de interface (cartão, chip, área, gráfico)
data/
  species/          capim, coelho, raposa, gafanhoto, sapo, cobra, caramujo (.tres)
  levels/           fase1 a fase4 (.tres)
scenes/             main_menu, level, level_select, result_screen, ui/tutorial
assets/             sprites (32x32) e fundos (480x270) em pixel art
tools/              gerar_arte.py (gera a arte placeholder) e balanceamento.py (testa balanceamento sem o Godot)
docs/               GDD, cronograma e gabarito
```

Regra de arquitetura: a lógica (`Ecosystem`) **não conhece a interface**. A interface chama
métodos dela e escuta seus sinais (`turno_finalizado`, `especie_extinta`, `especie_adicionada`, `especie_removida`).

## Como criar uma espécie nova

1. No Godot: clique direito em `data/species/` > *Novo Recurso* > `Species`.
2. Preencha no Inspetor: nome, tipo (produtor ou consumidor), ícone, cor, custo, população inicial,
   taxa de crescimento (r), quem ela come (`come`), taxa de caça e eficiência.
   Produtores usam `k_base`; consumidores têm K calculado pela quantidade de presas (`eficiencia`).
3. Teste os números antes de abrir o jogo com `tools/balanceamento.py` (precisa só do Python).

Dica de balanceamento: comece com poucas espécies e ajuste `taxa_caca` e `eficiencia`.
Predadores precisam de muitas presas para ter K suficiente; sistemas grandes oscilam bastante.

## Como criar uma fase nova

1. Duplique um arquivo de `data/levels/` e mude `id`, `titulo`, `orcamento`, `objetivo_turnos`, as listas de espécies e o `fundo`.
2. Adicione o `id` à lista `FASES` em `scripts/game_manager.gd` (a ordem define o desbloqueio).
3. Opcional: `especies_iniciais` (espécies fixas, como a invasora) e o grupo *Evento ambiental*
   (turno, multiplicadores de luz e água e texto).

## Pixel art

- O projeto roda em **960x540** com filtro de textura **Nearest**. Sprites 32x32 e fundos 480x270 (escala 2x) ficam nítidos.
- Os sprites e fundos atuais são **placeholders** gerados por `tools/gerar_arte.py`. Para usar arte própria,
  substitua os PNGs de `assets/sprites/` (um por espécie, mesmo nome) e `assets/backgrounds/`, mantendo os tamanhos.
- Cada `Species` tem o campo `icone` e cada `Level` tem o campo `fundo`: é só apontar para o novo arquivo.
- Se preferir a base 480x270, mude em *Projeto > Configurações > Display > Window* e reduza as fontes da interface.

## Créditos

- Desenvolvimento: João Victor Barbosa de Oliveira (projeto de extensão do IF Sudeste, Curso de Godot).

Preencha aqui os créditos de arte, fontes e sons de terceiros (nome do autor, link e licença).

- Engine: [Godot Engine](https://godotengine.org) (licença MIT).
- Sprites e fundos atuais: gerados por código no próprio projeto (`tools/gerar_arte.py`).
