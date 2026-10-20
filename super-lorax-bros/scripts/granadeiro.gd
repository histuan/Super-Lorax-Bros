extends Soldado

class_name Granadeiro

const GRANADA := preload("res://cenas/inimigos/granada.tscn")

@export_group("Granadeiro")
@export var alcance_x := 160.0
@export var alcance_y := 64.0
@export var intervalo := 2.5
@export var quadro_arremesso := 3
@export var ponto_arremesso := Vector2(16, -6)
@export var velocidade_y := -300.0
@export var vx_min := 40.0
@export var vx_max := 420.0
@export var antecipacao := 1.0
@export var fator_distancia := 1.3
@export_group("")

var contador_intervalo := 0.0
var arremessando := false
var alvo_posicao := Vector2.ZERO
var alvo_velocidade_x := 0.0


# Granadeiro não anda
func _init() -> void:
	horizontal_speed = 0.0


# Liga o sinal que marca o quadro do arremesso
func _ready() -> void:
	super._ready()
	animated_sprite_2d.frame_changed.connect(_on_frame_mudou)


# Com o Lorax no alcance e o intervalo cumprido, arremessa
func _comportamento(delta: float) -> void:
	contador_intervalo = maxf(contador_intervalo - delta, 0.0)
	if arremessando or contador_intervalo > 0.0:
		return
	var jogador := jogador_vivo()
	if jogador == null:
		return
	var dx := jogador.global_position.x - global_position.x
	var dy := jogador.global_position.y - global_position.y
	if absf(dx) <= alcance_x and absf(dy) <= alcance_y:
		_arremessar(dx, jogador)


# Guarda onde o Lorax estava, vira para ele e toca o arremesso; o intervalo conta do início
func _arremessar(dx: float, jogador: Player) -> void:
	alvo_posicao = jogador.global_position
	alvo_velocidade_x = jogador.velocity.x
	if dx != 0.0:
		_definir_direcao(1 if dx > 0.0 else -1)
	arremessando = true
	contador_intervalo = intervalo
	animated_sprite_2d.play(&"arremessar")


# Solta a granada no quadro certo da animação
func _on_frame_mudou() -> void:
	if morto or not arremessando:
		return
	if animated_sprite_2d.animation == &"arremessar" and animated_sprite_2d.frame == quadro_arremesso:
		_lancar()


# Cria a granada na mão, mirada onde o Lorax estava quando o arremesso começou
func _lancar() -> void:
	var origem := global_position + Vector2(ponto_arremesso.x * direcao, ponto_arremesso.y)
	var gravidade: float = ProjectSettings.get_setting("physics/2d/default_gravity")
	var dx := alvo_posicao.x - origem.x
	var dy := alvo_posicao.y - origem.y
	var tempo := tempo_de_voo(velocidade_y, dy, gravidade)
	# Parte da posição guardada no início: antecipacao projeta a velocidade daquele instante e fator_distancia passa um pouco do alvo
	var alvo_dx := (dx + alvo_velocidade_x * tempo * antecipacao) * fator_distancia
	var granada := GRANADA.instantiate()
	granada.velocity = Vector2(clampf(absf(alvo_dx) / tempo, vx_min, vx_max) * signf(alvo_dx), velocidade_y)
	get_tree().current_scene.add_child(granada)
	granada.global_position = origem


# Tempo até o arco descer ao desnível dy (se não alcança, usa o tempo do ponto mais alto)
static func tempo_de_voo(vy: float, dy: float, g: float) -> float:
	var discriminante := vy * vy + 2.0 * g * dy
	if discriminante < 0.0:
		return maxf(-vy / g, 0.05)
	return maxf((-vy + sqrt(discriminante)) / g, 0.05)


# Volta ao idle no fim do arremesso
func _animacao_terminou(nome: StringName) -> void:
	if nome == &"arremessar":
		arremessando = false
		animated_sprite_2d.play(&"idle")
