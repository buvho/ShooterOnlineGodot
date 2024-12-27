extends Area2D

func _on_area_entered(area):
	if area.get_parent() is Cara:
		area.get_parent().velocity.y = -800
		$"..".play()
