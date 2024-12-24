extends Control



func _on_start_game_pressed():
	if multiplayer.get_unique_id() == 1:
		$"../../Mapa".queue_free()
		
