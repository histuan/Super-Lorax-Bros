extends Control

@onready var botao := $Caixa/Start as Button

var iniciando := false


# Dá foco ao botão (Enter e Espaço funcionam) e liga o clique
func _ready() -> void:
	botao.pressed.connect(_on_start_pressed)
	botao.grab_focus()


# Começa uma partida nova e vai para a fase (uma vez só)
func _on_start_pressed() -> void:
	if iniciando:
		return
	iniciando = true
	Jogo.nova_partida()
	get_tree().change_scene_to_file("res://cenas/main.tscn")
