class_name AreaEcossistema
extends PanelContainer
## Área onde as espécies são soltas. Guarda os chips das espécies colocadas.

signal soltou(dados: Variant)  # Species ou {"especie": Species, "multiplicador": float}

var chips: HFlowContainer


func _init() -> void:
	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(vbox)

	var titulo := Label.new()
	titulo.text = "Ecossistema (arraste ou toque nas espécies)"
	titulo.add_theme_font_size_override("font_size", 14)
	titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(titulo)

	chips = HFlowContainer.new()
	chips.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chips.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(chips)


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("especie")


func _drop_data(_pos: Vector2, data: Variant) -> void:
	soltou.emit(data)
