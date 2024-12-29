extends Area2D

func _on_area_entered(area):
	if area.get_parent() is Cara:
		area.get_parent().velocity.y = -800
		area.get_parent().reset_ready = true
		$"..".play()
		Game.si.play_audio(load("res://Resources/Spring.mp3"),0.8,1,global_position)
