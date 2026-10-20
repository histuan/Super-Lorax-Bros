extends Area2D

@export var velocidade := 110.0
@export var tempo_de_vida := 8.0

@onready var sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var notificador := $VisibleOnScreenNotifier2D as VisibleOnScreenNotifier2D

var direcao := 1
var acertou := false


# Vira o sprite pela direção e liga os sinais
func _ready() -> void:
	sprite.flip_h = direcao < 0
	body_entered.connect(_on_body_entered)
	notificador.screen_exited.connect(queue_free)


# Voa reto; some depois de um tempo máximo (rede de segurança)
func _process(delta: float) -> void:
	position.x += direcao * velocidade * delta
	tempo_de_vida -= delta
	if tempo_de_vida <= 0.0:
		queue_free()


# Mata o Lorax; qualquer outro corpo (chão, bloco) só apaga a bala
func _on_body_entered(corpo: Node2D) -> void:
	if acertou:
		return
	acertou = true
	if corpo is Player:
		(corpo as Player).die()
	queue_free()
