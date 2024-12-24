extends RigidBody2D
@onready var Upos = position
signal foi
func _physics_process(_delta):
	pass
	rotation = (position - Upos).angle()
	Upos = position
func _on_body_entered(body):
	if body is TileMapLayer:
		call_deferred("set_freeze", true)
		call_deferred("set_process_mode", PROCESS_MODE_DISABLED)
		foi.emit()
func set_freeze(value):
	freeze = value
