extends Camera2D
var player : Cara
func enable(p : Cara):
	player = p
	global_position = p.global_position
func _physics_process(_delta):
	if player:
		var player_pos = player.global_position
		global_position += global_position.direction_to(player_pos) * global_position.distance_to(player_pos) / 5
		position += get_local_mouse_position() * 0.01 * player.cam_multiplier
