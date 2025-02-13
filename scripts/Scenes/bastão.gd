extends Item
@onready var bat_sound : AudioStream = preload("res://Resources/BatSwing.mp3")
@onready var bonk : AudioStream = preload("res://Resources/bonk.wav")
func use():
	$Sprite.play("Use")
	$AnimationPlayer.play("Bastao")
	play_audio(bat_sound,0.8,1.2,0,true)
	item_ready = false

func _on_area_2d_area_entered(area):
	if area is HurtBox:
		if area.get_parent() != IPlayer:
			area.change_life(-10)
			if area.get_parent() is Cara:
				area.knockback($Trow.global_position,500)
				play_audio(bonk,0.8,1.2,0,true)

func _on_sprite_animation_finished():
	item_ready = true
