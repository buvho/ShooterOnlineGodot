extends Area2D
class_name HurtBox
signal _on_change_life(valor:int)
signal _on_Knockback(pos : Vector2, forca : int)

func change_life(valor):
	_on_change_life.emit(valor)
func knockback(pos,forca):
	_on_Knockback.emit(pos,forca)
