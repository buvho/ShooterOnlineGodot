extends Area2D

func _on_body_entered(body):
	if body is Cara:
		body.global_position += Vector2(0,-300)
		body.mudar_vida(-100)
