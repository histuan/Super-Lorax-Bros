extends Control

var saindo := false


# Garante o relógio parado enquanto a tela de vitória está aberta
func _ready() -> void:
	Jogo.parar_relogio()


# Espaço ou Enter voltam para o título (uma vez só, ignorando tecla segurada)
func _unhandled_input(evento: InputEvent) -> void:
	if saindo or evento.is_echo() or not evento.is_action_pressed("ui_accept"):
		return
	saindo = true
	get_tree().change_scene_to_file("res://cenas/telas/titulo.tscn")
