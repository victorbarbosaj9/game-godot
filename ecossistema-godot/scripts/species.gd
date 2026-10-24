class_name Species
extends Resource
## Define uma espécie do ecossistema.
## Crie arquivos .tres a partir deste Resource (ex.: capim.tres, coelho.tres).

enum Tipo { PRODUTOR, CONSUMIDOR }

@export var nome: String = ""
@export var icone: Texture2D
@export var tipo: Tipo = Tipo.PRODUTOR
@export_multiline var descricao: String = ""
## Cor usada no gráfico, nos cartões e como placeholder até existir sprite.
@export var cor: Color = Color.WHITE
## Custo para colocar a espécie no ecossistema (orçamento da fase).
@export var custo: int = 1

@export_group("População")
@export var populacao_inicial: float = 100.0
## Taxa de crescimento (r) do modelo logístico.
@export var taxa_crescimento: float = 0.3

@export_group("Alimentação")
## Espécies que esta espécie come (vazio para produtores).
@export var come: Array[Species] = []
## Quantos indivíduos desta espécie são consumidos por indivíduo predador, por turno.
@export var taxa_caca: float = 1.0
## Quanto cada indivíduo de presa contribui para a capacidade de suporte (K) do predador.
@export var eficiencia: float = 0.5

@export_group("Produtores")
## K máximo de um produtor com luz e água em 100%.
@export var k_base: float = 1000.0
