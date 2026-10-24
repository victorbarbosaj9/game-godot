extends Control
## Controla a fase jogável. Monta a interface por código (sem depender de nodes
## criados à mão) e liga tudo ao Ecosystem por sinais.

const CENA_MENU := "res://scenes/main_menu.tscn"
const CENA_SELETOR := "res://scenes/level_select.tscn"
const CENA_RESULTADO := "res://scenes/result_screen.tscn"
const CENA_TUTORIAL := "res://scenes/ui/tutorial.tscn"

var nivel: Level
var eco: Ecosystem
var orcamento_restante: int = 0
var encerrado: bool = false

var _extintas: Array[Species] = []
var _aviso: String = ""
var _chips: Dictionary = {}    # Species -> SpeciesChip
var _custos_pagos: Dictionary = {}  # Species -> int (custo pago, para devolver ao remover)
var _cartoes: Dictionary = {}  # Species -> SpeciesCard

var _lbl_titulo: Label
var _lbl_turno: Label
var _lbl_orcamento: Label
var _lbl_objetivo: Label
var _lbl_feedback: Label
var _grafico: PopulationGraph
var _area: AreaEcossistema
var _cartoes_box: VBoxContainer
var _btn_simular: Button
var _btn_simular5: Button


func _ready() -> void:
	nivel = load("res://data/levels/%s.tres" % GameManager.fase_atual) as Level
	eco = Ecosystem.new()
	add_child(eco)
	eco.turno_finalizado.connect(_on_turno)
	eco.especie_extinta.connect(_on_extinta)
	orcamento_restante = nivel.orcamento

	_montar_ui()
	for e in nivel.especies_iniciais:
		_adicionar_chip(e, false, 1.0)
	_atualizar_chips()
	_atualizar_hud()
	_feedback("Escolha uma espécie no painel da esquerda e coloque no ecossistema.")
	if GameManager.modo_tutorial:
		_iniciar_tutorial()


# ---------- Interface ----------

func _novo_label(texto: String, tamanho: int) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tamanho)
	return l


func _montar_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	if nivel.fundo != null:
		var imagem := TextureRect.new()
		imagem.texture = nivel.fundo
		imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		imagem.stretch_mode = TextureRect.STRETCH_SCALE
		imagem.set_anchors_preset(Control.PRESET_FULL_RECT)
		imagem.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(imagem)
	var escurecer := ColorRect.new()
	escurecer.color = Color(0.04, 0.07, 0.06, 0.66)
	escurecer.set_anchors_preset(Control.PRESET_FULL_RECT)
	escurecer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(escurecer)

	var margem := MarginContainer.new()
	margem.set_anchors_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "right", "top", "bottom"]:
		margem.add_theme_constant_override("margin_" + lado, 12)
	add_child(margem)

	var raiz := VBoxContainer.new()
	raiz.add_theme_constant_override("separation", 8)
	margem.add_child(raiz)

	var topo := HBoxContainer.new()
	topo.add_theme_constant_override("separation", 24)
	raiz.add_child(topo)
	_lbl_titulo = _novo_label("", 22)
	_lbl_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topo.add_child(_lbl_titulo)
	_lbl_turno = _novo_label("", 18)
	topo.add_child(_lbl_turno)
	_lbl_orcamento = _novo_label("", 18)
	topo.add_child(_lbl_orcamento)

	_lbl_objetivo = _novo_label("", 14)
	_lbl_objetivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	raiz.add_child(_lbl_objetivo)

	var meio := HBoxContainer.new()
	meio.size_flags_vertical = Control.SIZE_EXPAND_FILL
	meio.add_theme_constant_override("separation", 12)
	raiz.add_child(meio)

	# Coluna esquerda: espécies disponíveis
	var esq := VBoxContainer.new()
	esq.custom_minimum_size = Vector2(190, 0)
	meio.add_child(esq)
	esq.add_child(_novo_label("Espécies", 16))
	_cartoes_box = VBoxContainer.new()
	_cartoes_box.add_theme_constant_override("separation", 4)
	esq.add_child(_cartoes_box)
	for e in nivel.especies_disponiveis:
		var c := SpeciesCard.new()
		_cartoes_box.add_child(c)
		c.configurar(e)
		c.escolhida.connect(_on_cartao_escolhido)
		_cartoes[e] = c

	# Coluna central: área do ecossistema e gráfico
	var centro := VBoxContainer.new()
	centro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	centro.add_theme_constant_override("separation", 8)
	meio.add_child(centro)
	_area = AreaEcossistema.new()
	_area.custom_minimum_size = Vector2(0, 140)
	centro.add_child(_area)
	_area.soltou.connect(_on_area_soltou)
	_grafico = PopulationGraph.new()
	_grafico.ecossistema = eco
	_grafico.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_grafico.custom_minimum_size = Vector2(0, 140)
	centro.add_child(_grafico)

	# Coluna direita: feedback educativo (o tutorial aparece por cima, embaixo)
	var dir := VBoxContainer.new()
	dir.custom_minimum_size = Vector2(250, 0)
	meio.add_child(dir)
	dir.add_child(_novo_label("O que aconteceu", 16))
	var painel_fb := PanelContainer.new()
	painel_fb.custom_minimum_size = Vector2(0, 110)
	dir.add_child(painel_fb)
	_lbl_feedback = _novo_label("", 14)
	_lbl_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	painel_fb.add_child(_lbl_feedback)

	# Barra inferior
	var base := HBoxContainer.new()
	base.add_theme_constant_override("separation", 8)
	raiz.add_child(base)
	_btn_simular = Button.new()
	_btn_simular.text = "Simular turno"
	_btn_simular.pressed.connect(_simular.bind(1))
	base.add_child(_btn_simular)
	_btn_simular5 = Button.new()
	_btn_simular5.text = "Simular 5 turnos"
	_btn_simular5.pressed.connect(_simular.bind(5))
	base.add_child(_btn_simular5)
	var reiniciar := Button.new()
	reiniciar.text = "Reiniciar"
	reiniciar.pressed.connect(func(): get_tree().reload_current_scene())
	base.add_child(reiniciar)
	var espaco := Control.new()
	espaco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	base.add_child(espaco)
	var fases := Button.new()
	fases.text = "Fases"
	fases.pressed.connect(func(): get_tree().change_scene_to_file(CENA_SELETOR))
	base.add_child(fases)
	var menu := Button.new()
	menu.text = "Menu"
	menu.pressed.connect(func(): get_tree().change_scene_to_file(CENA_MENU))
	base.add_child(menu)


func _atualizar_hud() -> void:
	_lbl_titulo.text = nivel.titulo
	if GameManager.modo_tutorial:
		_lbl_turno.text = "Turno: %d" % eco.turno
		_lbl_objetivo.text = "Modo tutorial: aqui nada vale ponto. Siga os passos no canto da tela."
	else:
		_lbl_turno.text = "Turno: %d / %d" % [eco.turno, nivel.objetivo_turnos]
		var nomes: Array[String] = []
		for e in nivel.especies_obrigatorias:
			nomes.append(e.nome)
		_lbl_objetivo.text = "Objetivo: mantenha %s vivas por %d turnos. %s" % [", ".join(nomes), nivel.objetivo_turnos, nivel.descricao]
	_lbl_orcamento.text = "Orçamento: %d" % orcamento_restante
	for e in _cartoes:
		var c: SpeciesCard = _cartoes[e]
		c.desabilitar(encerrado or (e in eco.especies) or c.custo_atual() > orcamento_restante)


func _feedback(texto: String) -> void:
	_lbl_feedback.text = texto


# ---------- Ações do jogador ----------

func _adicionar_chip(e: Species, removivel: bool, mult: float = 1.0) -> void:
	var chip := SpeciesChip.new()
	_area.chips.add_child(chip)
	chip.configurar(e, removivel)
	chip.remover.connect(_remover)
	_chips[e] = chip
	eco.adicionar_especie(e, mult)
	chip.atualizar(eco.populacao[e], eco.calcular_k(e))


func _on_cartao_escolhido(e: Species, mult: float) -> void:
	# mult == -1.0 significa que o jogador só mudou a quantidade no seletor
	if mult < 0.0:
		_atualizar_hud()
		return
	_tentar_adicionar(e, mult)


func _on_area_soltou(dados: Variant) -> void:
	if dados is Dictionary:
		_tentar_adicionar(dados["especie"], dados.get("multiplicador", 1.0))
	elif dados is Species:
		_tentar_adicionar(dados, 1.0)


func _tentar_adicionar(e: Species, mult: float = 1.0) -> void:
	if encerrado or e in eco.especies:
		return
	var custo := maxi(1, roundi(e.custo * mult))
	if custo > orcamento_restante:
		_feedback("Orçamento insuficiente para %s (custo %d, restam %d)." % [e.nome, custo, orcamento_restante])
		return
	orcamento_restante -= custo
	_custos_pagos[e] = custo
	_adicionar_chip(e, true)
	_atualizar_chips()
	_grafico.queue_redraw()
	_atualizar_hud()
	var pop_inicial := roundi(e.populacao_inicial * mult)
	_feedback("%s entrou com ~%d indivíduos. %s" % [e.nome, pop_inicial, e.descricao])


func _remover(e: Species) -> void:
	if encerrado or not (e in eco.especies) or e in nivel.especies_iniciais:
		return
	eco.remover_especie(e)
	orcamento_restante += _custos_pagos.get(e, e.custo)
	_custos_pagos.erase(e)
	if _chips.has(e):
		_chips[e].queue_free()
		_chips.erase(e)
	_atualizar_chips()
	_grafico.queue_redraw()
	_atualizar_hud()
	_feedback("%s saiu do ecossistema. Simule para ver o efeito nas outras espécies." % e.nome)


func _simular(quantos: int) -> void:
	if encerrado:
		return
	if eco.especies.is_empty():
		_feedback("Coloque ao menos uma espécie antes de simular.")
		return
	for i in quantos:
		if nivel.evento_turno > 0 and eco.turno + 1 == nivel.evento_turno:
			eco.luz *= nivel.evento_luz
			eco.agua *= nivel.evento_agua
			_aviso = nivel.evento_texto
		eco.simular_turno()
		if encerrado:
			break


func _atualizar_chips() -> void:
	for e in _chips:
		_chips[e].atualizar(eco.populacao.get(e, 0.0), eco.calcular_k(e))


# ---------- Simulação ----------

func _on_extinta(e: Species) -> void:
	if e in nivel.especies_iniciais:
		_aviso = "A espécie %s foi eliminada do ecossistema!" % e.nome
	else:
		_extintas.append(e)


func _on_turno(_turno: int, resumo: Dictionary) -> void:
	_atualizar_chips()
	_grafico.queue_redraw()
	var texto := eco.gerar_feedback(resumo)
	if _aviso != "":
		texto = _aviso + "\n" + texto
		_aviso = ""
	_feedback(texto)
	_atualizar_hud()
	if GameManager.modo_tutorial or encerrado:
		return

	if not _extintas.is_empty():
		_encerrar(false, "A espécie %s foi extinta. Sem alimento, ou com predação demais, a população chegou a zero." % _extintas[0].nome)
	elif eco.turno >= nivel.objetivo_turnos:
		var faltando: Array[String] = []
		for e in nivel.especies_obrigatorias:
			if not (e in eco.especies) or eco.populacao[e] < 1.0:
				faltando.append(e.nome)
		if faltando.is_empty():
			_encerrar(true, "O ecossistema se manteve por %d turnos. As espécies obrigatórias sobreviveram dentro da capacidade de suporte do ambiente." % eco.turno)
		else:
			_encerrar(false, "Faltaram espécies no ecossistema: %s." % ", ".join(faltando))


func _encerrar(venceu: bool, mensagem: String) -> void:
	encerrado = true
	_btn_simular.disabled = true
	_btn_simular5.disabled = true
	GameManager.ultimo_resultado = {
		"venceu": venceu,
		"mensagem": mensagem,
		"turnos": eco.turno,
		"dica": nivel.dica,
		"fase": nivel.titulo,
		"id": nivel.id,
		"grafico": eco.snapshot(),
	}
	if venceu:
		GameManager.concluir_fase(nivel.id)
	_feedback(mensagem)
	_atualizar_hud()
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file(CENA_RESULTADO)


# ---------- Tutorial ----------

func _iniciar_tutorial() -> void:
	var t: Tutorial = (load(CENA_TUTORIAL) as PackedScene).instantiate()
	add_child(t)
	t.iniciar(eco)
	t.tutorial_concluido.connect(func(): get_tree().reload_current_scene.call_deferred())
