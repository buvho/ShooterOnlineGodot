extends Item
class_name Gun
@export var dano = 25
@export var knockback = 1000
@export var audio_file : AudioStreamMP3
@export var pitchmin : float = 1
@export var pitchmax : float = 1
@export var linetime = 0.5
func use():
	item_ready = false
	$Sprite.play()
	play_audio(audio_file,pitchmin,pitchmax)
	for rayCast : RayCast2D in $Raycasts.get_children():
		var Alvo = rayCast.get_collider()
		criarLinha(rayCast)
		if Alvo is Cara:
			Alvo.mudar_vida(-dano)
			Alvo.knockback(rayCast.global_position,knockback)
	gun_use()
	
func gun_use():
	pass

func criarLinha(rayCast):
	var line = load("res://cenas/outros/linha.tscn").instantiate()
	line.posicao_inicial = rayCast.global_position
	if rayCast.get_collider() == null:
		line.posicao_final = to_global(rayCast.get_parent().position + rayCast.target_position)
		
	else:
		line.posicao_final = rayCast.get_collision_point()
	get_tree().root.get_node("World").add_child(line)

func anim_over():
	item_ready = true
