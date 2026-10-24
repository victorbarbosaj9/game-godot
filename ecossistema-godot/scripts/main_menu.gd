extends Control
## Menu principal.
##
## Árvore de nodes (veja scenes/main_menu.tscn):
## MainMenu (Control)  <- este script
## ├── Fundo (TextureRect) e Escurecer (ColorRect)
## ├── Centro/VBox: Titulo, Subtitulo, Jogar, Tutorial, Sobre, Sair
## └── Overlay (ColorRect, escurece o menu enquanto o "Sobre" está aberto)
##     └── PainelSobre (PanelContainer, com fundo opaco)
##         └── VBox: Texto, Fechar

const CENA_SELETOR := "res://scenes/level_select.tscn"
const CENA_FASE := "res://scenes/level.tscn"

@onready var botao_jogar: Button = $Centro/VBox/Jogar
@onready var botao_tutorial: Button = $Centro/VBox/Tutorial
@onready var botao_sobre: Button = $Centro/VBox/Sobre
@onready var botao_sair: Button = $Centro/VBox/Sair
@onready var overlay_sobre: Control = $Overlay
@onready var botao_fechar: Button = $Overlay/PainelSobre/VBox/Fechar


func _ready() -> void:
	botao_jogar.pressed.connect(_on_jogar)
	botao_tutorial.pressed.connect(_on_tutorial)
	botao_sobre.pressed.connect(func(): overlay_sobre.visible = true)
	botao_fechar.pressed.connect(func(): overlay_sobre.visible = false)
	botao_sair.pressed.connect(func(): get_tree().quit())
	botao_jogar.grab_focus()

	# Navegador (export web) não permite fechar a janela pelo jogo.
	if OS.has_feature("web"):
		botao_sair.hide()


func _on_jogar() -> void:
	GameManager.modo_tutorial = false
	get_tree().change_scene_to_file(CENA_SELETOR)


func _on_tutorial() -> void:
	GameManager.modo_tutorial = true
	GameManager.fase_atual = "fase1"
	get_tree().change_scene_to_file(CENA_FASE)
