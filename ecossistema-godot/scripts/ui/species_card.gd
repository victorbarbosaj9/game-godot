class_name SpeciesCard
extends PanelContainer
## Cartão de uma espécie disponível.
## Mostra ícone, nome, custo base e um seletor de quantidade (×0.25 a ×1.5).
## Toque no cartão para colocar no ecossistema com a quantidade escolhida.
## Arraste para a área do ecossistema para o mesmo efeito.

signal escolhida(especie: Species, multiplicador: float)

const MULTIPLICADORES := [0.25, 0.5, 1.0, 1.5]
const ROTULOS       := ["×¼", "×½", "×1", "×1½"]

var especie: Species
var _idx: int = 2          # começa em 100%
var _lbl_custo: Label
var _btn_menos: Button
var _btn_mais: Button
var _lbl_mult: Label
var _btn_colocar: Button


func configurar(e: Species) -> void:
	especie = e
	mouse_filter = Control.MOUSE_FILTER_PASS
	tooltip_text = e.descricao
	add_theme_stylebox_override("panel", _estilo(e.cor))

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(vbox)

	# Linha superior: ícone + nome + custo
	var topo := HBoxContainer.new()
	topo.add_theme_constant_override("separation", 6)
	topo.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(topo)

	if e.icone != null:
		var ico := TextureRect.new()
		ico.texture = e.icone
		ico.custom_minimum_size = Vector2(28, 28)
		ico.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ico.mouse_filter = Control.MOUSE_FILTER_IGNORE
		topo.add_child(ico)
	else:
		var amostra := ColorRect.new()
		amostra.color = e.cor
		amostra.custom_minimum_size = Vector2(20, 20)
		amostra.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		amostra.mouse_filter = Control.MOUSE_FILTER_IGNORE
		topo.add_child(amostra)

	var nome := Label.new()
	nome.text = e.nome
	nome.add_theme_font_size_override("font_size", 14)
	nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nome.clip_text = true
	nome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	topo.add_child(nome)

	_lbl_custo = Label.new()
	_lbl_custo.add_theme_font_size_override("font_size", 13)
	_lbl_custo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	topo.add_child(_lbl_custo)

	# Linha inferior: seletor de quantidade + botão colocar
	var base := HBoxContainer.new()
	base.add_theme_constant_override("separation", 4)
	base.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(base)

	_btn_menos = Button.new()
	_btn_menos.text = "−"
	_btn_menos.flat = true
	_btn_menos.custom_minimum_size = Vector2(26, 0)
	_btn_menos.pressed.connect(_diminuir)
	base.add_child(_btn_menos)

	_lbl_mult = Label.new()
	_lbl_mult.add_theme_font_size_override("font_size", 13)
	_lbl_mult.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_mult.custom_minimum_size = Vector2(36, 0)
	_lbl_mult.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base.add_child(_lbl_mult)

	_btn_mais = Button.new()
	_btn_mais.text = "+"
	_btn_mais.flat = true
	_btn_mais.custom_minimum_size = Vector2(26, 0)
	_btn_mais.pressed.connect(_aumentar)
	base.add_child(_btn_mais)

	var espaco := Control.new()
	espaco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	base.add_child(espaco)

	_btn_colocar = Button.new()
	_btn_colocar.text = "Colocar"
	_btn_colocar.flat = false
	_btn_colocar.pressed.connect(func(): escolhida.emit(especie, multiplicador()))
	base.add_child(_btn_colocar)

	_atualizar_ui()


func multiplicador() -> float:
	return MULTIPLICADORES[_idx]


func custo_atual() -> int:
	return maxi(1, roundi(especie.custo * multiplicador()))


func desabilitar(valor: bool) -> void:
	_btn_colocar.disabled = valor
	_btn_menos.disabled = valor
	_btn_mais.disabled = valor
	modulate = Color(0.55, 0.55, 0.55) if valor else Color.WHITE


func _diminuir() -> void:
	if _idx > 0:
		_idx -= 1
		_atualizar_ui()
		escolhida.emit(especie, -1.0)   # -1 = só atualiza UI, não coloca


func _aumentar() -> void:
	if _idx < MULTIPLICADORES.size() - 1:
		_idx += 1
		_atualizar_ui()
		escolhida.emit(especie, -1.0)


func _atualizar_ui() -> void:
	if _lbl_mult == null:
		return
	_lbl_mult.text = ROTULOS[_idx]
	_lbl_custo.text = "custo %d" % custo_atual()
	_btn_menos.disabled = _idx == 0
	_btn_mais.disabled  = _idx == MULTIPLICADORES.size() - 1


func _get_drag_data(_pos: Vector2) -> Variant:
	if _btn_colocar.disabled or especie == null:
		return null
	var previa := TextureRect.new()
	if especie.icone:
		previa.texture = especie.icone
	previa.custom_minimum_size = Vector2(32, 32)
	set_drag_preview(previa)
	return {"especie": especie, "multiplicador": multiplicador()}


## Painel escuro com borda na cor da espécie.
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
