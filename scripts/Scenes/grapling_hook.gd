extends Item
static var hookSC = load("res://cenas/armas/hook.tscn")
var puchando
var lin : Vector2
var hook : Node2D;

func use():
		item_ready = false;
		hook = hookSC.instantiate()
		Mapa.si.add_child(hook)
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
			IPlayer.external_vel = 0
			IPlayer.gravity = 0
		else:
			IPlayer.gravity = 0
			IPlayer.accel = 50
			IPlayer.max_speed = 200
			IPlayer.friction = 0
			var forca = 40
			lin.x = IPlayer.external_vel + ($Ponto.global_position.direction_to(hook.global_position)).x * forca
			lin.y = IPlayer.velocity.y + ($Ponto.global_position.direction_to(hook.global_position)).y * forca
			lin = lin.limit_length(700)
			IPlayer.external_vel = lin.x
			IPlayer.velocity.y = lin.y
func _on_foi():
	puchando = true
