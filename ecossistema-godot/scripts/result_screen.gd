extends Control
## Tela de resultado: mensagem, gráfico da partida e explicação por espécie.
## Lê GameManager.ultimo_resultado (preenchido pela fase).

const CENA_MENU := "res://scenes/main_menu.tscn"
const CENA_SELETOR := "res://scenes/level_select.tscn"
const CENA_FASE := "res://scenes/level.tscn"


func _ready() -> void:
	var r: Dictionary = GameManager.ultimo_resultado
	var venceu: bool = r.get("venceu", false)
	var id: String = r.get("id", "")
	var proxima := GameManager.proxima_fase(id)

	set_anchors_preset(Control.PRESET_FULL_RECT)
	var fundo := ColorRect.new()
	fundo.color = Color(0.1, 0.14, 0.12)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	var margem := MarginContainer.new()
	margem.set_anchors_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "right", "top", "bottom"]:
		margem.add_theme_constant_override("margin_" + lado, 16)
	add_child(margem)

	var raiz := VBoxContainer.new()
	raiz.add_theme_constant_override("separation", 8)
	margem.add_child(raiz)

	var titulo := _texto("Equilíbrio alcançado!" if venceu else "Ecossistema em desequilíbrio", 30)
	titulo.modulate = Color(0.6, 0.9, 0.55) if venceu else Color(0.95, 0.5, 0.4)
	raiz.add_child(titulo)
	raiz.add_child(_texto("%s  |  %d turnos" % [r.get("fase", ""), r.get("turnos", 0)], 14))
	raiz.add_child(_texto(r.get("mensagem", "Nenhuma partida concluída ainda."), 15))

	# Meio: gráfico à esquerda, explicação à direita
	var meio := HBoxContainer.new()
	meio.size_flags_vertical = Control.SIZE_EXPAND_FILL
	meio.add_theme_constant_override("separation", 12)
	raiz.add_child(meio)

	var grafico := PopulationGraph.new()
	grafico.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grafico.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grafico.custom_minimum_size = Vector2(480, 220)
	meio.add_child(grafico)
	var dados: Dictionary = r.get("grafico", {})
	grafico.definir_snapshot(dados)

	var rolagem := ScrollContainer.new()
	rolagem.custom_minimum_size = Vector2(350, 0)
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	meio.add_child(rolagem)
	var coluna := VBoxContainer.new()
	coluna.custom_minimum_size = Vector2(334, 0)
	coluna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coluna.add_theme_constant_override("separation", 6)
	rolagem.add_child(coluna)

	coluna.add_child(_etiqueta("Como ler o gráfico", 15, true))
	coluna.add_child(_etiqueta("Cada linha é uma população em % da sua capacidade de suporte (K). A linha tracejada é 100%: acima dela falta recurso e a população cai nos turnos seguintes.", 13))

	coluna.add_child(_etiqueta("O que aconteceu com cada espécie", 15, true))
	for s in dados.get("series", []):
		coluna.add_child(_linha_especie(s))

	if r.get("dica", "") != "":
		coluna.add_child(_etiqueta("Conceito", 15, true))
		coluna.add_child(_etiqueta(r["dica"], 13))

	if venceu and id != "" and proxima == "":
		raiz.add_child(_texto("Parabéns! Você concluiu todas as fases.", 16))

	# Botões
	var botoes := HBoxContainer.new()
	botoes.alignment = BoxContainer.ALIGNMENT_CENTER
	botoes.add_theme_constant_override("separation", 12)
	raiz.add_child(botoes)

	var principal: Button = null
	if venceu and proxima != "":
		var seguinte := Button.new()
		seguinte.text = "Próxima fase"
		seguinte.pressed.connect(func(): _abrir_fase(proxima))
		botoes.add_child(seguinte)
		principal = seguinte

	var de_novo := Button.new()
	de_novo.text = "Jogar novamente"
	de_novo.pressed.connect(func(): _abrir_fase(id if id != "" else "fase1"))
	botoes.add_child(de_novo)
	if principal == null:
		principal = de_novo

	var fases := Button.new()
	fases.text = "Escolher fase"
	fases.pressed.connect(func(): get_tree().change_scene_to_file(CENA_SELETOR))
	botoes.add_child(fases)

	var menu := Button.new()
	menu.text = "Menu"
	menu.pressed.connect(func(): get_tree().change_scene_to_file(CENA_MENU))
	botoes.add_child(menu)
	principal.grab_focus()


func _abrir_fase(id: String) -> void:
	GameManager.fase_atual = id
	GameManager.modo_tutorial = false
	get_tree().change_scene_to_file(CENA_FASE)


## Uma linha da legenda: amostra de cor + resumo da espécie.
func _linha_especie(s: Dictionary) -> Control:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 8)
	var amostra := ColorRect.new()
	amostra.color = s["cor"]
	amostra.custom_minimum_size = Vector2(6, 0)
	linha.add_child(amostra)
	var texto := _etiqueta("%s: %s" % [s["nome"], _resumo_especie(s)], 13)
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(texto)
	return linha


func _resumo_especie(s: Dictionary) -> String:
	var razoes: Array = s["razoes"]
	if int(s["extinta_em"]) >= 0:
		return "foi extinta no turno %d." % int(s["extinta_em"])
	var pico := 0.0
	var turno_pico := 0
	for i in razoes.size():
		if razoes[i] > pico:
			pico = razoes[i]
			turno_pico = int(s["inicio"]) + i
	var final_: float = razoes[razoes.size() - 1]
	var texto := "pico de %d%% do K (turno %d) e terminou em %d%%." % [roundi(pico * 100.0), turno_pico, roundi(final_ * 100.0)]
	if pico > 1.05:
		texto += " Passou do K: faltou recurso e a população caiu depois."
	return texto


func _texto(t: String, tamanho: int) -> Label:
	var l := _etiqueta(t, tamanho)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


func _etiqueta(t: String, tamanho: int, destaque: bool = false) -> Label:
	var l := Label.new()
	l.text = t
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", tamanho)
	if destaque:
		l.modulate = Color(0.85, 0.95, 0.8)
	return l
