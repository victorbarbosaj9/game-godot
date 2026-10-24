class_name SpeciesChip
extends PanelContainer
## Espécie já colocada no ecossistema: mostra população, K e a pressão pop/K.

signal remover(especie: Species)

var especie: Species
var _lbl_info: Label
var _barra: ProgressBar


func configurar(e: Species, removivel: bool = true) -> void:
	especie = e
	custom_minimum_size = Vector2(148, 0)
	mouse_filter = Control.MOUSE_FILTER_PASS
	add_theme_stylebox_override("panel", _estilo(e.cor))
	tooltip_text = e.descricao if removivel else "Espécie fixa: não pode ser removida. " + e.descricao

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(hbox)

	if e.icone != null:
		var ico := TextureRect.new()
		ico.texture = e.icone
		ico.custom_minimum_size = Vector2(32, 32)
		ico.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ico.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hbox.add_child(ico)
	else:
		var amostra := ColorRect.new()
		amostra.color = e.cor
		amostra.custom_minimum_size = Vector2(20, 20)
		amostra.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		amostra.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hbox.add_child(amostra)

	var coluna := VBoxContainer.new()
	coluna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coluna.add_theme_constant_override("separation", 1)
	coluna.mouse_filter = Control.MOUSE_FILTER_PASS
	hbox.add_child(coluna)

	var linha := HBoxContainer.new()
	linha.mouse_filter = Control.MOUSE_FILTER_PASS
	coluna.add_child(linha)

	var nome := Label.new()
	nome.text = e.nome
	nome.add_theme_font_size_override("font_size", 13)
	nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nome.clip_text = true
	nome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	linha.add_child(nome)

	if removivel:
		var botao := Button.new()
		botao.text = "x"
		botao.flat = true
		botao.tooltip_text = "Remover do ecossistema"
		botao.pressed.connect(func(): remover.emit(especie))
		linha.add_child(botao)

	_barra = ProgressBar.new()
	_barra.max_value = 150.0
	_barra.show_percentage = false
	_barra.custom_minimum_size = Vector2(0, 6)
	_barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coluna.add_child(_barra)

	_lbl_info = Label.new()
	_lbl_info.add_theme_font_size_override("font_size", 11)
	_lbl_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coluna.add_child(_lbl_info)


## Painel escuro com borda na cor da espécie (a mesma cor da linha no gráfico).
func _estilo(cor: Color) -> StyleBoxFlat:
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0, 0, 0, 0.4)
	st.border_color = cor
	st.set_border_width_all(2)
	st.border_width_left = 6
	st.set_corner_radius_all(4)
	st.content_margin_left = 6.0
	st.content_margin_right = 6.0
	st.content_margin_top = 4.0
	st.content_margin_bottom = 4.0
	return st


func atualizar(pop: float, k: float) -> void:
	if pop < 1.0:
		_lbl_info.text = "extinta"
		_barra.value = 0.0
		modulate = Color(1.0, 0.6, 0.6)
		return
	modulate = Color.WHITE
	var pressao := pop / k
	_lbl_info.text = "pop %d / K %d" % [int(pop), int(k)]
	_barra.value = minf(pressao * 100.0, 150.0)
	if pressao < 0.9:
		_barra.modulate = Color(0.5, 0.85, 0.5)
	elif pressao <= 1.05:
		_barra.modulate = Color(0.95, 0.8, 0.3)
	else:
		_barra.modulate = Color(0.95, 0.4, 0.35)
