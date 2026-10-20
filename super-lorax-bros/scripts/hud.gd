extends CanvasLayer

@onready var rotulo_vidas := $Raiz/Vidas/Numero as Label
@onready var rotulo_tempo := $Raiz/Tempo/Numero as Label


# Mostra o estado atual do Jogo e passa a acompanhar as mudanças
func _ready() -> void:
	_atualizar_vidas(Jogo.vidas)
	_atualizar_tempo(ceili(Jogo.tempo_restante))
	Jogo.vidas_mudou.connect(_atualizar_vidas)
	Jogo.tempo_mudou.connect(_atualizar_tempo)


# Escreve o número de vidas no canto esquerdo
func _atualizar_vidas(vidas: int) -> void:
	rotulo_vidas.text = "×%d" % vidas


# Escreve os segundos restantes no canto direito
func _atualizar_tempo(segundos: int) -> void:
	rotulo_tempo.text = "%d" % segundos
