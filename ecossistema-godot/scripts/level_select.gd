extends Control
## Seletor de fases com bloqueio: cada fase só libera depois de concluir a anterior.
## O progresso é salvo pelo GameManager em user://progresso.cfg.

const CENA_MENU := "res://scenes/main_menu.tscn"
const CENA_FASE := "res://scenes/level.tscn"

var _lista: VBoxContainer
var _chk_liberar: CheckButton


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var imagem := TextureRect.new()
	imagem.texture = load("res://assets/backgrounds/menu.png")
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_SCALE
	imagem.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(imagem)
	var escurecer := ColorRect.new()
	escurecer.color = Color(0.04, 0.07, 0.06, 0.6)
	escurecer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(escurecer)

	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(520, 0)
	vbox.add_theme_constant_override("separation", 10)
	centro.add_child(vbox)

	var titulo := Label.new()
	titulo.text = "Escolha a fase"
	titulo.add_theme_font_size_override("font_size", 34)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(titulo)

	_lista = VBoxContainer.new()
	_lista.add_theme_constant_override("separation", 8)
	vbox.add_child(_lista)

	var extras := HBoxContainer.new()
	extras.add_theme_constant_override("separation", 12)
	vbox.add_child(extras)
	_chk_liberar = CheckButton.new()
	_chk_liberar.text = "Liberar todas (modo professor)"
	_chk_liberar.button_pressed = GameManager.liberar_todas
	_chk_liberar.toggled.connect(func(ligado: bool):
		GameManager.liberar_todas = ligado
		_montar_lista())
	_chk_liberar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	extras.add_child(_chk_liberar)
	var apagar := Button.new()
	apagar.text = "Apagar progresso"
	apagar.pressed.connect(func():
		GameManager.resetar_progresso()
		_montar_lista())
	extras.add_child(apagar)

	var voltar := Button.new()
	voltar.text = "Voltar ao menu"
	voltar.pressed.connect(func(): get_tree().change_scene_to_file(CENA_MENU))
	vbox.add_child(voltar)

	_montar_lista()


func _montar_lista() -> void:
	for filho in _lista.get_children():
		filho.queue_free()
	var numero := 1
	for id in GameManager.FASES:
		var nivel := load("res://data/levels/%s.tres" % id) as Level
		var liberada := GameManager.fase_liberada(id)
		var concluida := id in GameManager.fases_concluidas

		var botao := Button.new()
		botao.custom_minimum_size = Vector2(0, 62)
		botao.alignment = HORIZONTAL_ALIGNMENT_LEFT
		botao.disabled = not liberada
		var estado := "Concluída" if concluida else ("Disponível" if liberada else "Bloqueada: conclua a fase anterior")
		botao.text = "%s\n%s  |  %d turnos  |  orçamento %d" % [nivel.titulo, estado, nivel.objetivo_turnos, nivel.orcamento]
		if concluida:
			botao.modulate = Color(0.75, 1.0, 0.75)
		botao.pressed.connect(_jogar.bind(id))
		_lista.add_child(botao)
		numero += 1


func _jogar(id: String) -> void:
	GameManager.fase_atual = id
	GameManager.modo_tutorial = false
	get_tree().change_scene_to_file(CENA_FASE)
