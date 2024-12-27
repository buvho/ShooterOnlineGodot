extends Node2D
enum Orientation {BOTTOM,RIGHT,TOP,LEFT}
@export var orientation : Orientation

func _enter_tree():
	match orientation:
		1:
			rotation = deg_to_rad(-90)
		2:
			rotation = deg_to_rad(180)
		3:
			rotation = deg_to_rad(90)
