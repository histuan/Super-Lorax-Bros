extends Area2D


# Mata o Lorax que cair no buraco, uma vez só
func _on_body_entered(corpo: Node2D) -> void:
	if corpo is Player:
		var jogador := corpo as Player
		if not jogador.is_dead:
			jogador.die()
