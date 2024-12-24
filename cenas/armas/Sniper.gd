extends Gun

func _input(event):
	if event is InputEventMouseMotion:
		update_lazer()
func _ready():
	$Lazer/Line2D.points[0] = $Lazer/RayCast.position
	IPlayer.max_speed /= 2
	IPlayer.reset_ready = false
	IPlayer.cam_multiplier = 5
	update_lazer()
func gun_use():
	IPlayer.knockback($Lazer.global_position,500)
func update_lazer():
	if $Lazer/RayCast.get_collider():
		$Lazer/Line2D.points[1] = $Lazer.to_local($Lazer/RayCast.get_collision_point())
	else:
		$Lazer/Line2D.points[1] = $Lazer/RayCast.target_position
func _exit_tree():
	IPlayer.cam_multiplier = 1
