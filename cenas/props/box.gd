extends Node2D
@export var item_id = -1;

func _on_hurt_box__on_change_life(_valor):
	if item_id != -1 && multiplayer.get_unique_id() == 1:
		Game.si.spawn_drop(item_id,global_position)
	destroy.rpc()

@rpc("any_peer","reliable","call_local")
func destroy():
	queue_free()
