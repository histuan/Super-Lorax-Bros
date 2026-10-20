extends Area2D

const FRAMES_ACESA := preload("res://resources/sprite_frames/granada_acesa.tres")
const FRAMES_EXPLOSAO := preload("res://resources/sprite_frames/explosao_granada.tres")

# Quadro da explosão: 56x56 com o chão na linha 55 (27 px abaixo do centro); a origem da granada fica 4 px acima do chão
const LINHA_CHAO_QUADRO := 27.0
const ALTURA_ORIGEM_CHAO := 4.0

@export var tempo_pavio := 1.2
@export var tempo_de_vida := 8.0
@export var escala_explosao := 2.0
@export var raio_explosao := 28.0

@onready var sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var area_explosao := $AreaExplosao as Area2D
@onready var forma_explosao := $AreaExplosao/CollisionShape2D as CollisionShape2D
@onready var notificador := $VisibleOnScreenNotifier2D as VisibleOnScreenNotifier2D

var velocity := Vector2.ZERO
var pousou := false
var explodiu := false
var pavio := 0.0
var gravidade: float = ProjectSettings.get_setting("physics/2d/default_gravity")


# Liga os sinais por código
func _ready() -> void:
	forma_explosao.shape = forma_explosao.shape.duplicate()
	(forma_explosao.shape as CircleShape2D).radius = raio_explosao
	body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_animacao_terminou)
	notificador.screen_exited.connect(_on_saiu_da_tela)


# Voa em arco; depois de pousar, conta o pavio
func _physics_process(delta: float) -> void:
	if explodiu:
		return
	if pousou:
		pavio -= delta
		if pavio <= 0.0:
			explodir()
		return
	velocity.y += gravidade * delta
	position += velocity * delta
	tempo_de_vida -= delta
	if tempo_de_vida <= 0.0:
		queue_free()


# Lorax explode na hora; chão faz a granada pousar
func _on_body_entered(corpo: Node2D) -> void:
	if explodiu:
		return
	if corpo is Player:
		explodir(corpo as Player)
	elif not pousou:
		pousar()


# Para no chão, acende e começa a contar o pavio
func pousar() -> void:
	pousou = true
	velocity = Vector2.ZERO
	pavio = tempo_pavio
	sprite.sprite_frames = FRAMES_ACESA
	sprite.play(&"default")


# Explode uma vez só e fere o Lorax que estiver no raio (soldados não são atingidos)
func explodir(alvo: Player = null) -> void:
	if explodiu:
		return
	explodiu = true
	velocity = Vector2.ZERO
	sprite.sprite_frames = FRAMES_EXPLOSAO
	sprite.scale = Vector2.ONE * escala_explosao
	if pousou:
		sprite.position.y = ALTURA_ORIGEM_CHAO - LINHA_CHAO_QUADRO * escala_explosao
	sprite.play(&"default")
	if alvo != null:
		alvo.die()
	for corpo in area_explosao.get_overlapping_bodies():
		if corpo is Player:
			(corpo as Player).die()


# Some quando a explosão termina
func _on_animacao_terminou() -> void:
	if explodiu:
		queue_free()


# Granada que sai da tela ainda no ar é descartada; a acesa continua até explodir
func _on_saiu_da_tela() -> void:
	if not pousou and not explodiu:
		queue_free()
