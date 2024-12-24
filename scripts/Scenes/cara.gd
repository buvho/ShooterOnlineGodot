extends CharacterBody2D
class_name Cara
@export var vida = 100;
@export var gravity : int
@export var jump_force : int
@export var max_speed : float = 4000
@export var accel :float = 150
@export var friction : float = 100
#jogador
@export var item_id = -1
@export var skin_ID : int
@export var nome : String

var reset_ready = false
var item : Item
var interacted : UseBox
var areas_proximas: Array[UseBox]  = []
var can_jump = true
var cam_multiplier = 1

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		$Camera.enabled = true
		skin_ID = Menu.skin_ID
		nome = Menu.nome
		rpc("arrived",skin_ID,nome)
		await  get_tree().create_timer(0.05).timeout
		sync()
@rpc("any_peer", "call_local","reliable")
func arrived(fskin_ID,fnome):
	global_position = mapa.si.get_node("Spawn").global_position
	$Sprite.texture = load(Menu.skin_list[fskin_ID][0])
	$ItemPlace/Hands/H1.texture = load(Menu.skin_list[fskin_ID][1])
	$ItemPlace/Hands/H2.texture = load(Menu.skin_list[fskin_ID][1])
	$Nome.text = fnome
func sync():
	for player : Cara in get_parent().get_children():
		player.get_node("Sprite").texture = load(Menu.skin_list[player.skin_ID][0])
		player.get_node("ItemPlace/Hands/H1").texture = load(Menu.skin_list[player.skin_ID][1])
		player.get_node("ItemPlace/Hands/H2").texture = load(Menu.skin_list[player.skin_ID][1])
		player.get_node("Nome").text = player.nome
		player.get_node("HealthBar").value = player.vida
		if player.item_id != -1:
			var itemSC = load(Item.IdList[player.item_id])
			var itemdele = itemSC.instantiate()
			player.get_node("ItemPlace").add_child(itemdele)
			player.item = itemdele
			
func _physics_process(_delta):
	if is_multiplayer_authority() && visible == true:
		movement()
		try_interact()
		mouse()
func movement():
	var direction = 0
	if Input.is_action_pressed("down"):
		velocity.y += 30
	if Input.is_action_pressed("right"):
		direction = 1
	elif Input.is_action_pressed("left"):
		direction = -1
	if not is_on_floor():
		velocity.y += gravity
		if can_jump == true:
			get_tree().create_timer(0.1).timeout.connect(func():
				can_jump = false)
	else:
		can_jump = true
		if reset_ready:
			move_reset()
	if Input.is_action_pressed("up") && can_jump:
			can_jump = false
			velocity.y -= jump_force
	if not direction && friction != 0:
		if velocity.x > friction:
			velocity.x -= friction
		elif velocity.x < -friction:
			velocity.x += friction
		else:
			velocity.x = 0
	else:
		velocity.x += direction * accel
		velocity.x = clamp(velocity.x,-max_speed,max_speed)
	move_and_slide()
func try_interact():
	if not areas_proximas.is_empty() and Input.is_action_just_pressed("Interact"):
		interacted = areas_proximas.pop_front()
		interact.rpc(mapa.si.get_path_to(interacted))
	if item and Input.is_action_just_pressed("drop"):
		drop_item(item_id)
func mouse():
	var mousePos = get_local_mouse_position()
	$Camera.position =  get_local_mouse_position() * 0.05 * cam_multiplier
	if item != null:
		mousePos = mousePos.normalized() * 15 if mousePos.length() > 15 else mousePos
	else:
		mousePos = mousePos.normalized() * 10 if mousePos.length() > 10 else mousePos
	$ItemPlace.position = mousePos
	if mousePos.x > 0:
		$Sprite.flip_h = true
		$ItemPlace.scale = Vector2(1,1)
	else:
		$Sprite.flip_h = false
		if item != null:
			$ItemPlace.scale = Vector2(1,-1)
		else:
			$ItemPlace.scale = Vector2(-1,1)
	$ItemPlace.position = mousePos
	if Input.is_action_just_pressed("useitem"):
		use_item.rpc(item_id)
	if item != null && item.rotate_item:
		$ItemPlace.rotation = mousePos.angle()

func add_UseBox(useb : UseBox):
	areas_proximas.append(useb)
func remove_UseBox(useb : UseBox):
	areas_proximas.erase(useb)

@rpc("any_peer", "call_local","reliable") 
func equip_item(fitem : Item):
	if item_id == -1 or item.item_ready == true:
		if item_id != -1:
			drop_item(item_id)
		reset_ready = true
		$ItemPlace.add_child(fitem)
		item = fitem;
		item_id = fitem.id;
		$ItemPlace/Hands/H1.global_position = fitem.get_node("Sprite/Hp1").global_position
		$ItemPlace/Hands/H2.global_position = fitem.get_node("Sprite/Hp2").global_position
	else:
		areas_proximas.append(interacted)
@rpc("any_peer", "call_local","reliable") 
func use_item(id):
	if id == -1:
		$AnimationPlayer.play("Soco")
	else:
		item.try_use()
func drop_item(id):
	mapa.si.spawn_drop.rpc_id(1,item_id,!$Sprite.flip_h,$ItemPlace.global_position)
	remove_item.rpc()
@rpc("any_peer", "call_local","reliable") 
func remove_item():
	$ItemPlace/Hands/H2.position = Vector2(8,0)
	$ItemPlace/Hands/H1.position = Vector2(-8,0)
	$ItemPlace.rotation = 0
	if item:
		reset_ready = true
		item_id = -1
		item = null
		var i = $ItemPlace.get_child_count() - 1
		while i > 0:
			$ItemPlace.get_child(i).queue_free()
			i -= 1
func move_reset():
	max_speed = 450
	jump_force = 600
	accel = 200
	friction = 200
	reset_ready = false

@rpc("any_peer", "call_local","reliable") 
func interact(finteracted : String):
	var interacted_target = mapa.si.get_node(finteracted)
	interacted_target.use(self)
@rpc("call_local","any_peer","reliable")
func respawn():
	global_position = get_parent().spawn_point
	mudar_vida(100)
	velocity = Vector2.ZERO
	visible = true
	$CollisionShape2D.disabled = false
func knockback(vetor : Vector2,forca : int):
	velocity += vetor.direction_to(global_position) * forca
func mudar_vida(valor):
	if multiplayer.get_unique_id() == 1:
		mudar_vidaRPC.rpc(valor)
@rpc("call_local","any_peer","reliable")
func mudar_vidaRPC(valor):
	vida = clamp(valor + vida,0,100)
	$HealthBar.value = vida
	if vida == 0:
		visible = false
		$CollisionShape2D.call_deferred("set", "disabled", true)
		if is_multiplayer_authority():
			var pepega = load("res://cenas/outros/cooldown.tscn").instantiate()
			pepega.vitima = self
			add_child(pepega)

func _on_soco_em_alguem(body):
	if body is Cara && body != self:
		body.mudar_vida(-10)
		body.knockback(global_position + Vector2(0,3),500)
