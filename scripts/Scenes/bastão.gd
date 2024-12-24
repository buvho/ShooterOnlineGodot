extends Item
@onready var bat_sound : AudioStream = load("res://Resources/BatSwing.mp3")
@onready var bonk : AudioStream = load("res://Resources/bonk.wav")
func use():
	$Sprite.play("Use")
	$AnimationPlayer.play("Bastao")
	play_audio(bat_sound,0.8,1.2,true)
	item_ready = false

func _on_area_2d_body_entered(body):
	if body is Cara:
		if body != IPlayer:
			body.mudar_vida(-20)
			play_audio(bonk,0.8,1.2,true)
			body.knockback($Trow.global_position,1000)
			body.max_speed = 5000
			body.friction = 0
			body.accel = 5
			get_tree().create_timer(0.1).timeout.connect(resetar.bind(body))
func resetar(body):
	body.reset_ready = true

func _on_sprite_animation_finished():
	item_ready = true
