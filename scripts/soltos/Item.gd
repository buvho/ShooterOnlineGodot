extends Node2D
class_name Item
static var IdList = [
"res://cenas/armas/bastão.tscn", # 0
"res://cenas/armas/garrafa.tscn", 
"res://cenas/armas/grapling_hook.tscn",
"res://cenas/armas/pistol.tscn",
"res://cenas/armas/shotgun.tscn", # 4
"res://cenas/armas/Sniper.tscn"]
@export var use_hands : bool = true
@export var rotate_item : bool
@export var item_ready : bool = true
@export var id : int
@export var texture : Texture2D
@onready var IPlayer : Cara = get_parent().get_parent()
var playing_unique = false
var last_audio
var height : int
func try_use():
	if item_ready:
		use()
	else:
		fail_use()
func use():
	pass
func fail_use():
	pass
func get_texture():
	var test = $Sprite
	if texture:
		height = texture.get_height()
		return texture
	if test is Sprite2D:
		var re : Texture2D = test.texture
		height = re.get_height()
		return re
	elif test is AnimatedSprite2D:
		var re : Texture2D = test.sprite_frames.get_frame_texture("Use",0)
		height = re.get_height()
		return re

func _process(_delta):
	var hands = get_parent().get_node("Hands")
	hands.get_node("H1").global_position = get_node("Sprite/Hp1").global_position
	hands.get_node("H2").global_position = get_node("Sprite/Hp2").global_position

func play_audio(audio_file,pitchmin,pitchmax,unique = false):
		if unique == true && last_audio:
			last_audio.queue_free()
		var audio = AudioStreamPlayer2D.new()
		last_audio = audio
		audio.stream = audio_file
		audio.pitch_scale = randf_range(pitchmin,pitchmax)
		get_parent().add_child(audio)
		audio.play()
		await audio.finished
		last_audio = null
		audio.queue_free()
