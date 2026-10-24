class_name Tutorial
extends Control
## Tutorial guiado por passos. Fica por cima da fase e avança quando o jogador
## executa a ação pedida (ouvindo os sinais do Ecosystem).
##
## Árvore de nodes (monte no editor, cena tutorial.tscn):
## Tutorial (Control, tela cheia)  <- este script
## └── Painel (PanelContainer, ancorado embaixo)
##     └── Margem (MarginContainer)
##         └── VBox (VBoxContainer)
##             ├── Progresso (Label)
##             ├── Texto (Label, autowrap ligado)
##             ├── Continuar (Button)
##             └── Pular (Button)
##
## Uso na cena da fase:
##   var t := preload("res://scenes/ui/tutorial.tscn").instantiate()
##   add_child(t)
##   t.iniciar($Ecosystem)

signal tutorial_concluido

enum Condicao { CONTINUAR, ESPECIE_ADICIONADA, TURNO_SIMULADO, ESPECIE_REMOVIDA }

## Os 4 verbos do jogo: posicionar, remover, simular e ler o gráfico.
## Tudo o que não aparece aqui está FORA do escopo do projeto.
const PASSOS := [
	{
		"texto": "Bem-vindo! Seu objetivo é manter o ecossistema em equilíbrio. Vamos aprender os 4 comandos do jogo.",
		"condicao": Condicao.CONTINUAR,
	},
	{
		"texto": "1) POSICIONAR: arraste o Capim (produtor) para a área do ecossistema, ou apenas toque nele.",
		"condicao": Condicao.ESPECIE_ADICIONADA,
	},
	{
		"texto": "Agora coloque o Coelho. Ele come capim, então depende dele para viver.",
		"condicao": Condicao.ESPECIE_ADICIONADA,
	},
	{
		"texto": "2) SIMULAR: toque em Simular para passar um turno e ver o que acontece.",
		"condicao": Condicao.TURNO_SIMULADO,
	},
	{
		"texto": "3) LER O GRÁFICO: cada linha colorida é uma população em % do seu K. A linha tracejada em 100% é a capacidade de suporte: o máximo que o ambiente sustenta.",
		"condicao": Condicao.CONTINUAR,
	},
	{
		"texto": "Quando uma linha passa de 100%, falta recurso e a população cai. Simule mais um turno e observe.",
		"condicao": Condicao.TURNO_SIMULADO,
	},
	{
		"texto": "4) REMOVER: toque no x do Capim, na área do ecossistema, e simule. Veja o efeito dominó nos coelhos!",
		"condicao": Condicao.ESPECIE_REMOVIDA,
	},
	{
		"texto": "Pronto! Você já sabe jogar. Nas fases, mantenha todas as espécies vivas até o fim dos turnos do objetivo.",
		"condicao": Condicao.CONTINUAR,
	},
]

@onready var label_progresso: Label = $Painel/Margem/VBox/Progresso
@onready var label_texto: Label = $Painel/Margem/VBox/Texto
@onready var botao_continuar: Button = $Painel/Margem/VBox/Continuar
@onready var botao_pular: Button = $Painel/Margem/VBox/Pular

var passo_atual: int = -1
var ecossistema: Ecosystem


func _ready() -> void:
	# Deixa os cliques passarem para a fase por baixo (arrastar e soltar).
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	botao_continuar.pressed.connect(func(): _verificar(Condicao.CONTINUAR))
	botao_pular.pressed.connect(_concluir)


func iniciar(eco: Ecosystem) -> void:
	ecossistema = eco
	ecossistema.especie_adicionada.connect(func(_e): _verificar(Condicao.ESPECIE_ADICIONADA))
	ecossistema.especie_removida.connect(func(_e): _verificar(Condicao.ESPECIE_REMOVIDA))
	ecossistema.turno_finalizado.connect(func(_t, _r): _verificar(Condicao.TURNO_SIMULADO))
	_proximo_passo()


func _proximo_passo() -> void:
	passo_atual += 1
	if passo_atual >= PASSOS.size():
		_concluir()
		return
	var passo: Dictionary = PASSOS[passo_atual]
	label_progresso.text = "Passo %d de %d" % [passo_atual + 1, PASSOS.size()]
	label_texto.text = passo["texto"]
	botao_continuar.visible = passo["condicao"] == Condicao.CONTINUAR


func _verificar(condicao: Condicao) -> void:
	if passo_atual < 0 or passo_atual >= PASSOS.size():
		return
	if PASSOS[passo_atual]["condicao"] == condicao:
		_proximo_passo()


func _concluir() -> void:
	GameManager.modo_tutorial = false
	tutorial_concluido.emit()
	queue_free()
