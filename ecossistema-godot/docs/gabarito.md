# Gabarito das fases (uso do professor/desenvolvedor)

Os resultados abaixo foram conferidos rodando o jogo no Godot 4.3 e com `tools/balanceamento.py`.

## Fase 1: Campo aberto (20 turnos, orçamento 6)
Colocar **Capim, Coelho e Raposa** (custo 6). Todas as espécies obrigatórias sobrevivem.

## Fase 2: Teia alimentar (20 turnos, orçamento 9)
Obrigatórias: Capim, Coelho, Raposa e Sapo. Sem **Gafanhoto**, o sapo não tem presas suficientes e é extinto
no 1º turno. Solução: as cinco espécies (custo 9).
Conceito: um predador só se sustenta se o K dele (função da quantidade de presas) for suficiente.

## Fase 3: Espécie invasora (25 turnos, orçamento 6)
O Caramujo já está no ecossistema e come capim. Obrigatórias: Capim e Coelho.
Só vence a combinação **Capim + Coelho + Gafanhoto + Sapo** (custo 6): o sapo controla a invasora e o gafanhoto
sustenta o sapo. Com apenas Capim e Coelho, o capim colapsa e o coelho vai junto.
Conceito: espécie invasora sem predador consome o recurso das nativas.

## Fase 4: Ação humana (30 turnos, orçamento 7, evento no turno 10)
No turno 10, luz e água caem pela metade e o K do capim cai para 25%. Obrigatórias: Capim, Coelho e Cobra.
A cobra come sapos **e** coelhos. Vencem **Capim + Coelho + Cobra** (custo 6) ou **Capim + Coelho + Gafanhoto + Cobra** (custo 7).
Armadilhas: a Raposa compete com a cobra pelos coelhos e derruba as duas; o Sapo precisa de gafanhotos e não cabe no orçamento junto com a cobra.
Sem o capim (a base da cadeia) nada se sustenta.
Conceito: quando o ambiente perde recursos, ele sustenta menos indivíduos; um predador com mais de um tipo de presa resiste melhor, e dois predadores disputando a mesma presa se prejudicam.
