class_name PopulationGraph
extends Control
## Gráfico da pressão ambiental: população de cada espécie em % da sua capacidade
## de suporte (K). A linha tracejada em 100% é o próprio K: acima dela falta recurso.
## Durante a fase, defina `ecossistema` e chame queue_redraw() a cada turno.
## Na tela de resultado, use definir_snapshot() com os dados guardados.

const MARGEM_ESQ := 46.0
const MARGEM_DIR := 12.0
const MARGEM_TOPO := 28.0
const MARGEM_BASE := 30.0

var ecossistema: Ecosystem
var _snap: Dictionary = {}


func definir_snapshot(dados: Dictionary) -> void:
	_snap = dados
	queue_redraw()


func _dados() -> Dictionary:
	if ecossistema != null:
		return ecossistema.snapshot()
	return _snap


func _draw() -> void:
	var fonte := ThemeDB.fallback_font
	var cor_texto := Color(1, 1, 1, 0.65)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.45))

	var dados := _dados()
	var series: Array = dados.get("series", [])
	if series.is_empty():
		draw_string(fonte, Vector2(16, size.y / 2.0), "O gráfico das populações aparece aqui.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, cor_texto)
		return

	var turnos: int = dados.get("turnos", 0)
	var area := Rect2(MARGEM_ESQ, MARGEM_TOPO, size.x - MARGEM_ESQ - MARGEM_DIR, size.y - MARGEM_TOPO - MARGEM_BASE)

	# Escala: sempre mostra de 0% a 120% de K (ou mais, se alguma espécie passar disso).
	var max_y := 1.2
	for s in series:
		for r in s["razoes"]:
			max_y = maxf(max_y, r * 1.05)
	var max_x := maxf(float(turnos), 1.0)

	var cor_eixo := Color(1, 1, 1, 0.35)
	draw_line(area.position, Vector2(area.position.x, area.end.y), cor_eixo, 1.0)
	draw_line(Vector2(area.position.x, area.end.y), area.end, cor_eixo, 1.0)
	draw_string(fonte, Vector2(6, area.end.y), "0%", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, cor_texto)
	draw_string(fonte, Vector2(6, area.position.y + 10), "%d%%" % int(max_y * 100.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, cor_texto)
	draw_string(fonte, Vector2(area.position.x, size.y - 10), "turno 0", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, cor_texto)
	draw_string(fonte, Vector2(area.end.x - 56, size.y - 10), "turno %d" % turnos, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, cor_texto)
	draw_string(fonte, Vector2(area.position.x, 16), "População em % de K (tracejada = 100%)", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, cor_texto)

	# Linha de K (100%)
	var y_k := area.end.y - (1.0 / max_y) * area.size.y
	draw_dashed_line(Vector2(area.position.x, y_k), Vector2(area.end.x, y_k), Color(1, 1, 1, 0.8), 1.5, 6.0)
	draw_string(fonte, Vector2(6, y_k + 4), "K", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1, 0.9))

	for s in series:
		var pontos := PackedVector2Array()
		var razoes: Array = s["razoes"]
		for i in razoes.size():
			var x := area.position.x + (float(int(s["inicio"]) + i) / max_x) * area.size.x
			var y := area.end.y - (float(razoes[i]) / max_y) * area.size.y
			pontos.append(Vector2(x, y))
		if pontos.size() >= 2:
			draw_polyline(pontos, s["cor"], 2.5)
		elif pontos.size() == 1:
			draw_circle(pontos[0], 4.0, s["cor"])
