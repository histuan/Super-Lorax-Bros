extends Node2D
## Explosões aleatórias no fundo (só enfeite: não machucam nem colidem com nada).
## Fica dentro de uma camada Parallax2D. As explosões nascem só na parte da camada que está na tela.

@export var tipos: Array[SpriteFrames] = []      ## animações sorteadas (tocam uma vez e somem)
@export var faixa_y := Vector2(146, 158)         ## altura do pé da explosão (em pixels da imagem do fundo)
@export var intervalo := Vector2(1.2, 3.5)       ## segundos entre uma explosão e a próxima (mínimo, máximo)
@export var ligado := true

var _espera := 0.0


func _ready() -> void:
	_espera = randf_range(intervalo.x, intervalo.y)


func _process(delta: float) -> void:
	if not ligado or tipos.is_empty():
		return
	_espera -= delta
	if _espera <= 0.0:
		_espera = randf_range(intervalo.x, intervalo.y)
		_explodir()


# Cria uma explosão num ponto sorteado da parte visível e apaga quando a animação acaba
func _explodir() -> void:
	var e := AnimatedSprite2D.new()
	e.sprite_frames = tipos.pick_random()
	var tam := e.sprite_frames.get_frame_texture(&"default", 0).get_size()
	var tela := get_viewport().get_visible_rect().size
	var para_local := get_global_transform_with_canvas().affine_inverse()
	var esquerda := (para_local * Vector2.ZERO).x
	var direita := (para_local * Vector2(tela.x, 0.0)).x
	var x := randf_range(esquerda + 16.0, direita - 16.0)
	var y := randf_range(faixa_y.x, faixa_y.y)
	e.centered = false
	e.position = Vector2(roundf(x - tam.x / 2.0), roundf(y - tam.y + 2.0))
	add_child(e)
	e.animation_finished.connect(e.queue_free)
	e.play(&"default")
