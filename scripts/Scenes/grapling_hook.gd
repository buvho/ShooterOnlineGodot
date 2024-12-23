extends Item
static var hookSC = load("res://cenas/armas/hook.tscn")
var puchando
var hook : Node2D;

func use():
		item_ready = false;
		hook = hookSC.instantiate()
		mapa.si.add_child(hook)
		$Sprite.frame = 1
		hook.global_position = $Ponto.global_position
		hook.rotation = get_parent().rotation
		var forca = IPlayer.global_position.direction_to($Ponto.global_position) * 750 + Vector2(0,-100)
		hook.apply_impulse(forca)
		$Hope.visible = true
		hook.connect("foi", Callable(self, "_on_foi"))
func fail_use():
		IPlayer.gravity = 30
		item_ready = true
		puchando = false
		IPlayer.reset_ready = true
		hook.queue_free()
		$Hope.visible = false
		$Sprite.frame = 0
func _physics_process(_delta):
	if !item_ready:
		$Hope.set_point_position(0,$Ponto.position)
		$Hope.set_point_position(1,to_local(hook.global_position))
	if puchando:
		if IPlayer.global_position.distance_to(hook.global_position) < 35 && (IPlayer.is_on_ceiling() || IPlayer.is_on_floor() || IPlayer.is_on_wall()):
			IPlayer.velocity = Vector2.ZERO
			IPlayer.gravity = 0
		else:
			IPlayer.gravity = 30
			IPlayer.max_speed = 600
			IPlayer.accel = 20
			IPlayer.friction = 0
			var forca = clamp(IPlayer.global_position.distance_to(hook.global_position),50,100)
			IPlayer.velocity.y = clamp(IPlayer.velocity.y,-IPlayer.max_speed,IPlayer.max_speed)
			IPlayer.velocity += IPlayer.global_position.direction_to(hook.global_position) * forca

func _on_foi():
	puchando = true
