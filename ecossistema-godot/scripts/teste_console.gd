extends Node
## Teste da simulação no console (anexe a um Node em uma cena vazia e rode).
## Valores testados: o sistema capim -> coelho -> raposa estabiliza em ~40 turnos.


func _criar(nome: String, tipo: Species.Tipo, pop: float, r: float,
		come: Array[Species] = [], taxa_caca := 0.0, eficiencia := 0.0, k_base := 1000.0) -> Species:
	var s := Species.new()
	s.nome = nome
	s.tipo = tipo
	s.populacao_inicial = pop
	s.taxa_crescimento = r
	s.come = come
	s.taxa_caca = taxa_caca
	s.eficiencia = eficiencia
	s.k_base = k_base
	return s


func _ready() -> void:
	var capim := _criar("Capim", Species.Tipo.PRODUTOR, 500, 0.5)
	var coelho := _criar("Coelho", Species.Tipo.CONSUMIDOR, 100, 0.6, [capim], 0.8, 0.5)
	var raposa := _criar("Raposa", Species.Tipo.CONSUMIDOR, 10, 0.3, [coelho], 2.0, 0.1)

	var eco := Ecosystem.new()
	add_child(eco)
	eco.especie_extinta.connect(func(e): print(">> %s foi extinta!" % e.nome))
	eco.turno_finalizado.connect(_on_turno)

	for e in [capim, coelho, raposa]:
		eco.adicionar_especie(e)

	for i in 40:
		eco.simular_turno()


func _on_turno(turno: int, resumo: Dictionary) -> void:
	if turno % 4 != 0:
		return
	var linha := "Turno %d: " % turno
	for e in resumo:
		linha += "%s=%d  " % [e.nome, int(resumo[e]["depois"])]
	print(linha)
