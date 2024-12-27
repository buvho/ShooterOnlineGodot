extends Control

func _on_start_game_pressed():
	if multiplayer.get_unique_id() == 1:
		Game.si.pre_load_map()
		visible = false
