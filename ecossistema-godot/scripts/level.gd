class_name Level
extends Resource
## Dados de uma fase. Crie novas fases duplicando um arquivo de data/levels/.

@export var id: String = "fase1"
@export var titulo: String = ""
@export_multiline var descricao: String = ""
@export var fundo: Texture2D
## Espécies que o jogador pode colocar no ecossistema.
@export var especies_disponiveis: Array[Species] = []
## Espécies que já começam no ecossistema e não podem ser removidas (ex.: invasora).
@export var especies_iniciais: Array[Species] = []
## Espécies que precisam estar vivas no fim do objetivo.
@export var especies_obrigatorias: Array[Species] = []
## Pontos para "comprar" espécies (cada espécie tem um custo).
@export var orcamento: int = 6
## Quantos turnos o ecossistema precisa durar em equilíbrio.
@export var objetivo_turnos: int = 20

@export_group("Evento ambiental")
## Turno em que o evento acontece (0 = sem evento).
@export var evento_turno: int = 0
## Multiplicadores aplicados à luz e à água (reduzem o K dos produtores).
@export var evento_luz: float = 1.0
@export var evento_agua: float = 1.0
@export_multiline var evento_texto: String = ""

@export_group("Texto educativo")
@export_multiline var dica: String = ""
