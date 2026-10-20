extends Soldado

class_name Atirador

enum Estado { ANDANDO, AJOELHANDO, ATIRANDO, PAUSA, LEVANTANDO, MORTO }

const BALA := preload("res://cenas/inimigos/bala.tscn")

@export_group("Atirador")
@export var alcance_x := 144.0
@export var tolerancia_y := 16.0
@export var tiros := 3
@export var pausa := 1.5
@export var quadro_disparo := 2
@export var ponto_cano := Vector2(29, -2)
@export var hitbox_ajoelhado_tamanho := Vector2(14, 36)
@export var hitbox_ajoelhado_posicao := Vector2(0, 2)
@export_group("")

@onready var colisao := $CollisionShape2D as CollisionShape2D

var estado := Estado.ANDANDO
var tiros_dados := 0
var contador_pausa := 0.0
var hitbox_normal_tamanho: Vector2
var hitbox_normal_posicao: Vector2


# Guarda a hitbox normal (com forma própria) e liga os sinais do sprite
func _ready() -> void:
	super._ready()
	colisao.shape = colisao.shape.duplicate()
	hitbox_normal_tamanho = (colisao.shape as RectangleShape2D).size
	hitbox_normal_posicao = colisao.position
	animated_sprite_2d.frame_changed.connect(_on_frame_mudou)
	animated_sprite_2d.animation_looped.connect(_on_animacao_repetiu)


# Máquina de estados do atirador
func _comportamento(delta: float) -> void:
	var jogador := jogador_vivo()
	var alvo_no_alcance := jogador != null and _no_alcance(jogador)
	match estado:
		Estado.ANDANDO:
			if alvo_no_alcance:
				_virar_para(jogador)
				_ajoelhar()
			else:
				_andar(delta)
		Estado.ATIRANDO:
			if not alvo_no_alcance:
				_levantar()
		Estado.PAUSA:
			if not alvo_no_alcance:
				_levantar()
				return
			contador_pausa -= delta
			if contador_pausa <= 0.0:
				_virar_para(jogador)
				_comecar_tiros()


# Diz se o Lorax está perto o bastante e quase na mesma altura
func _no_alcance(jogador: Player) -> bool:
	var dx := jogador.global_position.x - global_position.x
	var dy := jogador.global_position.y - global_position.y
	return absf(dx) <= alcance_x and absf(dy) <= tolerancia_y


# Vira o soldado para o lado do Lorax
func _virar_para(jogador: Player) -> void:
	var dx := jogador.global_position.x - global_position.x
	if dx != 0.0:
		_definir_direcao(1 if dx > 0.0 else -1)


# Para e ajoelha; a hitbox fica mais baixa
func _ajoelhar() -> void:
	estado = Estado.AJOELHANDO
	_hitbox_ajoelhado(true)
	animated_sprite_2d.play(&"ajoelhar")


# Começa uma rodada de tiros
func _comecar_tiros() -> void:
	estado = Estado.ATIRANDO
	tiros_dados = 0
	animated_sprite_2d.play(&"atirar")


# Levanta e volta ao normal
func _levantar() -> void:
	estado = Estado.LEVANTANDO
	_hitbox_ajoelhado(false)
	animated_sprite_2d.play(&"levantar")


# Troca a hitbox entre ajoelhada e em pé (os pés ficam no mesmo lugar)
func _hitbox_ajoelhado(ajoelhado: bool) -> void:
	var forma := colisao.shape as RectangleShape2D
	forma.size = hitbox_ajoelhado_tamanho if ajoelhado else hitbox_normal_tamanho
	colisao.position = hitbox_ajoelhado_posicao if ajoelhado else hitbox_normal_posicao


# Cria a bala na boca do cano, na direção atual
func _atirar() -> void:
	var bala := BALA.instantiate()
	bala.direcao = direcao
	get_tree().current_scene.add_child(bala)
	bala.global_position = global_position + Vector2(ponto_cano.x * direcao, ponto_cano.y)


# Atira no quadro do clarão e conta o tiro
func _on_frame_mudou() -> void:
	if morto or estado != Estado.ATIRANDO:
		return
	if animated_sprite_2d.animation == &"atirar" and animated_sprite_2d.frame == quadro_disparo:
		_atirar()
		tiros_dados += 1


# Terminou o último tiro: fica ajoelhado parado no último quadro
func _on_animacao_repetiu() -> void:
	if morto or estado != Estado.ATIRANDO or tiros_dados < tiros:
		return
	estado = Estado.PAUSA
	contador_pausa = pausa
	animated_sprite_2d.stop()
	animated_sprite_2d.animation = &"ajoelhar"
	animated_sprite_2d.frame = animated_sprite_2d.sprite_frames.get_frame_count(&"ajoelhar") - 1


# Troca de estado no fim de "ajoelhar" e "levantar"
func _animacao_terminou(nome: StringName) -> void:
	if estado == Estado.AJOELHANDO and nome == &"ajoelhar":
		_comecar_tiros()
	elif estado == Estado.LEVANTANDO and nome == &"levantar":
		estado = Estado.ANDANDO
		animated_sprite_2d.play(&"walk")


# Morre em qualquer estado
func die() -> void:
	super.die()
	estado = Estado.MORTO
