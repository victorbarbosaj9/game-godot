class_name Ecosystem
extends Node
## Simulação por turnos com crescimento logístico e capacidade de suporte (K).
##
## Cada turno:
##   nova_pop = pop + r * pop * (1 - pop / K) - predacao
## - Produtores: K = k_base * luz * agua
## - Consumidores: K = soma(pop da presa * eficiencia)

signal turno_finalizado(turno: int, resumo: Dictionary)
signal especie_extinta(especie: Species)
signal especie_adicionada(especie: Species)
signal especie_removida(especie: Species)

const LIMIAR_EXTINCAO := 1.0

var especies: Array[Species] = []
var populacao: Dictionary = {}  # Species -> float
var historico: Dictionary = {}  # Species -> Array[float] (para o gráfico)
var historico_k: Dictionary = {}  # Species -> Array[float] (K a cada turno)
var turno_inicio: Dictionary = {}  # Species -> turno em que entrou
var turno: int = 0

## Fatores ambientais (0.0 a 1.0+). Eventos como seca reduzem estes valores.
var luz: float = 1.0
var agua: float = 1.0


func adicionar_especie(e: Species, multiplicador: float = 1.0) -> void:
	if e in especies:
		return
	especies.append(e)
	populacao[e] = maxf(e.populacao_inicial * multiplicador, 1.0)
	historico[e] = [e.populacao_inicial]
	turno_inicio[e] = turno
	historico_k[e] = [calcular_k(e)]
	_atualizar_k_atual()
	especie_adicionada.emit(e)


func remover_especie(e: Species) -> void:
	especies.erase(e)
	populacao.erase(e)
	historico.erase(e)
	historico_k.erase(e)
	turno_inicio.erase(e)
	_atualizar_k_atual()
	especie_removida.emit(e)


## Quando uma espécie entra ou sai, o K das outras muda: corrige o ponto do turno atual.
func _atualizar_k_atual() -> void:
	for outra in especies:
		if historico_k.has(outra) and not historico_k[outra].is_empty():
			historico_k[outra][historico_k[outra].size() - 1] = calcular_k(outra)


func calcular_k(e: Species) -> float:
	if e.tipo == Species.Tipo.PRODUTOR:
		return maxf(e.k_base * luz * agua, 1.0)
	var alimento := 0.0
	for presa in e.come:
		if populacao.has(presa):
			alimento += populacao[presa] * e.eficiencia
	return maxf(alimento, 1.0)


## Retorna pop/K: abaixo de 1 há folga, acima de 1 há superpopulação.
func pressao_ambiental(e: Species) -> float:
	return populacao[e] / calcular_k(e)


func simular_turno() -> void:
	turno += 1

	# 1) Predação, calculada com as populações do início do turno.
	var perdas := {}
	for e in especies:
		perdas[e] = 0.0
	for predador in especies:
		for presa in predador.come:
			if populacao.has(presa):
				perdas[presa] += populacao[predador] * predador.taxa_caca

	# 2) Crescimento logístico menos predação.
	var novas := {}
	var resumo := {}
	for e in especies:
		var p: float = populacao[e]
		var k := calcular_k(e)
		var crescimento: float = e.taxa_crescimento * p * (1.0 - p / k)
		var nova := p + crescimento - minf(perdas[e], p)
		if nova < LIMIAR_EXTINCAO:
			nova = 0.0
		novas[e] = nova
		resumo[e] = {
			"antes": p,
			"depois": nova,
			"k": k,
			"predacao": minf(perdas[e], p),
		}

	# 3) Aplica o resultado e registra extinções.
	for e in especies:
		var antes: float = populacao[e]
		populacao[e] = novas[e]
		historico[e].append(novas[e])
		historico_k[e].append(calcular_k(e))
		if antes > 0.0 and novas[e] == 0.0:
			especie_extinta.emit(e)

	turno_finalizado.emit(turno, resumo)


## Gera um texto educativo a partir do resumo do turno.
func gerar_feedback(resumo: Dictionary) -> String:
	var maior_alta: Species = null
	var maior_queda: Species = null
	var delta_alta := 0.0
	var delta_queda := 0.0

	for e in resumo:
		var d: float = resumo[e]["depois"] - resumo[e]["antes"]
		if d > delta_alta:
			delta_alta = d
			maior_alta = e
		if d < delta_queda:
			delta_queda = d
			maior_queda = e

	# Prioridade: superpopulação (conceito de capacidade de suporte).
	for e in resumo:
		if resumo[e]["antes"] > resumo[e]["k"] * 1.05:
			return "%s passou da capacidade de suporte (K = %d). Faltou recurso e a população diminuiu." % [e.nome, int(resumo[e]["k"])]

	if maior_queda != null and resumo[maior_queda]["predacao"] > 0.0 and delta_queda < -5.0:
		return "%s diminuiu por causa da predação." % maior_queda.nome
	if maior_alta != null and delta_alta > 5.0:
		return "%s está crescendo: ainda há folga em relação à capacidade de suporte." % maior_alta.nome
	return "O ecossistema está próximo do equilíbrio."

## Resumo do histórico para o gráfico e para a tela de resultado:
## população de cada espécie em fração do K (1.0 = 100%), turno a turno.
func snapshot() -> Dictionary:
	var series: Array = []
	for e in especies:
		var razoes: Array = []
		var extinta_em := -1
		for i in historico[e].size():
			var k: float = maxf(historico_k[e][i], 1.0)
			razoes.append(minf(historico[e][i] / k, 3.0))
			if extinta_em < 0 and historico[e][i] <= 0.0:
				extinta_em = turno_inicio[e] + i
		series.append({
			"nome": e.nome,
			"cor": e.cor,
			"inicio": turno_inicio[e],
			"razoes": razoes,
			"extinta_em": extinta_em,
		})
	return {"turnos": turno, "series": series}
