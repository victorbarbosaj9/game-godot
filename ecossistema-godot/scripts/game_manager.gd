extends Node
## Autoload (Projeto > Configurações do Projeto > Autoload, nome: GameManager).
## Guarda o estado que precisa sobreviver à troca de cenas e salva o progresso.

const FASES: Array[String] = ["fase1", "fase2", "fase3", "fase4"]
const ARQUIVO_PROGRESSO := "user://progresso.cfg"

## Se verdadeiro, a cena da fase mostra o tutorial por cima.
var modo_tutorial: bool = false

## Fases concluídas (ex.: "fase1"). Usado para liberar a próxima no seletor.
var fases_concluidas: Array[String] = []

## Fase escolhida no seletor (ex.: "fase1").
var fase_atual: String = "fase1"

## Resultado da última fase (lido pela tela de resultado).
var ultimo_resultado: Dictionary = {}

## Modo professor/demonstração: libera todas as fases sem salvar nada.
var liberar_todas: bool = false


func _ready() -> void:
	_carregar()


func concluir_fase(id: String) -> void:
	if id not in fases_concluidas:
		fases_concluidas.append(id)
		_salvar()


func fase_liberada(id: String) -> bool:
	if liberar_todas:
		return true
	var i := FASES.find(id)
	if i < 0:
		return false
	return i == 0 or FASES[i - 1] in fases_concluidas


func proxima_fase(id: String) -> String:
	var i := FASES.find(id)
	if i >= 0 and i + 1 < FASES.size():
		return FASES[i + 1]
	return ""


func resetar_progresso() -> void:
	fases_concluidas.clear()
	_salvar()


func _salvar() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progresso", "concluidas", fases_concluidas)
	cfg.save(ARQUIVO_PROGRESSO)


func _carregar() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(ARQUIVO_PROGRESSO) != OK:
		return
	for id in cfg.get_value("progresso", "concluidas", []):
		if id is String and id in FASES and id not in fases_concluidas:
			fases_concluidas.append(id)
