extends Node

const VIDAS_INICIAIS := 2
const TEMPO_LIMITE := 150.0

signal vidas_mudou(vidas: int)
signal tempo_mudou(segundos: int)
signal tempo_esgotado
signal sem_vidas

var vidas: int = VIDAS_INICIAIS
var tempo_restante: float = TEMPO_LIMITE
var rodando := false


# Começa o jogo já com as vidas cheias
func _ready() -> void:
	nova_partida()


# Desconta o tempo da fase e avisa quando o número inteiro mostrado muda
func _process(delta: float) -> void:
	if not rodando:
		return
	var antes := ceili(tempo_restante)
	tempo_restante = maxf(tempo_restante - delta, 0.0)
	var depois := ceili(tempo_restante)
	if depois != antes:
		tempo_mudou.emit(depois)
	if tempo_restante <= 0.0:
		rodando = false
		tempo_esgotado.emit()


# Zera a partida: vidas cheias
func nova_partida() -> void:
	vidas = VIDAS_INICIAIS
	vidas_mudou.emit(vidas)


# Prepara uma tentativa: relógio cheio e rodando, sem mexer nas vidas
func iniciar_fase() -> void:
	tempo_restante = TEMPO_LIMITE
	rodando = true
	tempo_mudou.emit(ceili(tempo_restante))


# Tira uma vida e avisa o fim das vidas uma vez só
func perder_vida() -> void:
	if vidas <= 0:
		return
	vidas -= 1
	vidas_mudou.emit(vidas)
	if vidas <= 0:
		sem_vidas.emit()


# Para o relógio (pode ser chamada várias vezes)
func parar_relogio() -> void:
	rodando = false
