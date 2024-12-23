extends Area2D
class_name UseBox

func _on_body_entered(body):
	if body is Cara:
		body.add_UseBox(self)
func _on_body_exited(body):
	if body is Cara:
		body.remove_UseBox(self)
func use(_cara : Cara):
	print("usado")
