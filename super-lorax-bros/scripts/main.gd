extends Node

@onready var jogador := $player as Player
@onready var meta := $Meta
@onready var hud := $Hud

var fase_concluida := false


# Liga o jogador ao Jogo e começa a contagem da fase
func _ready() -> void:
	Jogo.iniciar_fase()
	jogador.died.connect(_on_jogador_morreu)
	jogador.death_finished.connect(_on_morte_terminou)
	Jogo.tempo_esgotado.connect(_on_tempo_esgotado)
	meta.chegou.connect(_on_meta_chegou)


# Para o relógio e tira uma vida quando o Lorax morre
func _on_jogador_morreu() -> void:
	Jogo.parar_relogio()
	Jogo.perder_vida()


# Recomeça a fase depois da animação de morte
func _on_morte_terminou() -> void:
	if Jogo.vidas <= 0:
		# TEMPORARIO: a B6 troca isso pela tela de game over
		Jogo.nova_partida()
	get_tree().reload_current_scene()


# Mata o Lorax se o tempo acabar com ele vivo
func _on_tempo_esgotado() -> void:
	if not jogador.is_dead:
		jogador.die()


# Vitória: só vale com o Lorax vivo; para o relógio, espera a queda e vai para a tela de vitória
func _on_meta_chegou() -> void:
	if jogador.is_dead or fase_concluida:
		return
	fase_concluida = true
	Jogo.parar_relogio()
	jogador.vencer()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://cenas/telas/vitoria.tscn")


# Atalhos de teste, só em build de debug
func _unhandled_input(evento: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if evento is InputEventKey and evento.pressed and not evento.echo:
		if evento.keycode == KEY_F1:
			Jogo.tempo_restante = 5.0
		elif evento.keycode == KEY_F2 and not jogador.is_dead:
			jogador.die()
		elif evento.keycode == KEY_F3:
			jogador.global_position = Vector2(1470, 30)
			jogador.velocity = Vector2.ZERO
