extends Area2D

signal chegou

var ja_chegou := false


# Avisa uma vez só quando o Lorax vivo toca a porta
func _on_body_entered(corpo: Node2D) -> void:
	if ja_chegou or not corpo is Player:
		return
	if (corpo as Player).is_dead:
		return
	ja_chegou = true
	chegou.emit()
