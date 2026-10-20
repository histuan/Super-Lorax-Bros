extends Enemy

class_name Soldado

@export_group("Soldado")
@export var tempo_entre_viradas := 0.25
@export var velocidade_animacao := 1.0
@export var deslocamento_morto := 3.0
@export var quadro_corpo_deitado := 3
@export_group("")

@onready var ray_parede := $RayParede as RayCast2D
@onready var ray_borda := $RayBorda as RayCast2D
@onready var notificador := $VisibleOnScreenNotifier2D as VisibleOnScreenNotifier2D

var direcao := -1
var ativo := false
var morto := false
var espera_virada := 0.0
var corpo_assentado := false


# Liga os sinais por código e começa virado para a esquerda
func _ready() -> void:
	notificador.screen_entered.connect(ativar)
	animated_sprite_2d.animation_finished.connect(_on_animacao_terminou)
	animated_sprite_2d.frame_changed.connect(_ajustar_corpo)
	animated_sprite_2d.speed_scale = velocidade_animacao
	_definir_direcao(-1)


# Gravidade, tempo de espera da virada e o comportamento próprio de cada soldado
func _process(delta: float) -> void:
	if morto or not ativo:
		return
	if not ray_cast_2d.is_colliding():
		position.y += vertical_speed * delta
	espera_virada = maxf(espera_virada - delta, 0.0)
	_comportamento(delta)


# Acorda o soldado (chamado quando ele entra na tela); depois disso ele patrulha mesmo fora da tela
func ativar() -> void:
	ativo = true


# Comportamento padrão: andar e virar; os filhos sobrescrevem
func _comportamento(delta: float) -> void:
	_andar(delta)


# Anda na direção atual; vira (uma vez só) na parede ou na borda do buraco
func _andar(delta: float) -> void:
	if horizontal_speed == 0.0:
		return
	if _perigo_adiante():
		if espera_virada <= 0.0:
			_definir_direcao(-direcao)
			espera_virada = tempo_entre_viradas
		return
	position.x += direcao * horizontal_speed * delta


# Diz se há parede ou buraco logo à frente
func _perigo_adiante() -> bool:
	ray_cast_2d.force_raycast_update()
	ray_parede.force_raycast_update()
	ray_borda.force_raycast_update()
	var sem_chao_adiante := not ray_borda.is_colliding() and ray_cast_2d.is_colliding()
	return ray_parede.is_colliding() or sem_chao_adiante


# Único lugar que muda a direção: vira o sprite e reposiciona os rays
func _definir_direcao(nova: int) -> void:
	direcao = nova
	animated_sprite_2d.flip_h = nova < 0
	ray_parede.target_position.x = 12.0 * nova
	ray_borda.position.x = 10.0 * nova


# Devolve o Lorax se ele existe e está vivo (senão null)
func jogador_vivo() -> Player:
	var jogador := get_tree().get_first_node_in_group("jogador") as Player
	if jogador == null or jogador.is_dead:
		return null
	return jogador


# Pisão: toca "dead", desliga a colisão e para tudo; aguenta ser chamado duas vezes
func die() -> void:
	if morto:
		return
	morto = true
	super.die()
	animated_sprite_2d.speed_scale = 1.0
	set_collision_layer_value(3, false)
	set_process(false)


# Quando o corpo já está deitado, desce alguns pixels para assentar no chão (uma vez só)
func _ajustar_corpo() -> void:
	if not morto or corpo_assentado:
		return
	if animated_sprite_2d.animation == &"dead" and animated_sprite_2d.frame >= quadro_corpo_deitado:
		corpo_assentado = true
		animated_sprite_2d.position.y += deslocamento_morto


# Some depois da animação de morte; nos outros casos avisa o filho
func _on_animacao_terminou() -> void:
	if morto:
		queue_free()
	else:
		_animacao_terminou(animated_sprite_2d.animation)


# Gancho para os filhos reagirem ao fim de uma animação sem loop
func _animacao_terminou(_nome: StringName) -> void:
	pass
