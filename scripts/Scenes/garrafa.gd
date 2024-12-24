extends Item
@rpc("any_peer", "call_local") func use():
	if item_ready:
		$AnimationPlayer.play("Garrafa")
		IPlayer.max_speed = 100
		IPlayer.velocity.x = clamp(IPlayer.velocity.x,-IPlayer.max_speed,IPlayer.max_speed)
		item_ready = false

func _on_animation_player_animation_finished(_anim_name):
		IPlayer.reset_ready = true
		item_ready = true
		IPlayer.mudar_vida(30)
