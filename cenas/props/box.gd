extends Node2D
@export var item_id = -1;

func _on_hurt_box__on_change_life(_valor):
	if multiplayer.get_unique_id() == 1:
		destroy.rpc()
		if item_id != -1:
			Game.si.spawn_drop(item_id,global_position)

@rpc("any_peer","reliable","call_local")
func destroy():
	Game.si.play_audio(load("res://Resources/woodbreak.mp3"),0.9,1.1,global_position,-5)
	var particulas = load("res://cenas/outros/Box_particles.tscn").instantiate()
	Game.si.get_child(0).add_child(particulas)
	particulas.emitting = true
	particulas.global_position = global_position
	queue_free()
