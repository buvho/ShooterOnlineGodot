extends CharacterBody2D
class_name Cara
#atributos
@export var vida = 100;
@export var gravity : int
@export var jump_force : int
@export var max_speed : float = 900
@export var accel :float = 150
@export var friction : float = 100
@export var item_id = -1
@export var skin_ID : int
@export var nome : String

#movimentação
var jump_buffer = 0;
var direction = 0
var can_jump = true
var external_vel = 0
#itens
var reset_ready = false
var item : Item
var interacted : UseBox
var areas_proximas: Array[UseBox]  = []

#multiplicadores
var cam_multiplier = 1

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		skin_ID = Menu.skin_ID
		nome = Menu.nome
		rpc("arrived",skin_ID,nome)
		await  get_tree().create_timer(0.05).timeout
		sync()
@rpc("any_peer", "call_local","reliable")
func arrived(fskin_ID,fnome):
	global_position = Mapa.si.get_node("Spawns").get_child(0).global_position
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
	#definir direções
	direction = 0
	if Input.is_action_pressed("down"):
		velocity.y += 30
	if Input.is_action_pressed("right"):
		direction = 1
	elif Input.is_action_pressed("left"):
		direction = -1
	if jump_buffer > 0:
		jump_buffer -= 1
	if not is_on_floor():
		velocity.y += gravity
		if can_jump == true:
			get_tree().create_timer(0.1).timeout.connect(func():
				can_jump = false)
	else:
		can_jump = true
		if reset_ready:
			move_reset()
	if Input.is_action_just_pressed("up"):
			jump_buffer = 15
	if can_jump && (jump_buffer > 0):
		jump_buffer = 0
		can_jump = false
		velocity.y -= jump_force
	if Input.is_action_just_released("up") && velocity.y < -100:
		velocity.y /= 1.8

	#logica de fricção/movimento (velocidade x)
	if !direction && friction != 0:
		if velocity.x > friction:
			velocity.x -= friction
		elif velocity.x < -friction:
			velocity.x += friction
		else:
			velocity.x = 0
		if external_vel:
			velocity.x = external_vel
			reset_ready = true
	if reset_ready == true && is_on_wall():
		external_vel = 0
	else:
		var vel = direction * accel
		if (external_vel * vel) < 0:
			if (abs(external_vel) > vel/10):
				external_vel += vel/10
				velocity.x = clamp(velocity.x + vel/10, -max_speed,max_speed) + external_vel
			else:
				friction = 200
				external_vel = 0
				velocity.x = vel - external_vel 
		else:
			velocity.x = clamp(velocity.x + vel,-max_speed,max_speed) + external_vel
	move_and_slide()
func move_reset():
	max_speed = 300
	jump_force = 500
	accel = 150
	friction = 150
	external_vel = lerpf(external_vel,0.0,0.1)
	velocity.x = clamp(velocity.x,-max_speed,max_speed)
	reset_ready = false
func try_interact():
	if not areas_proximas.is_empty() and Input.is_action_just_pressed("Interact"):
		interacted = areas_proximas.pop_front()
		interact.rpc(Mapa.si.get_path_to(interacted))
	if item and Input.is_action_just_pressed("drop"):
		drop_item()
func mouse():
	var mousePos = get_local_mouse_position()
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
			drop_item()
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
func drop_item():
	Mapa.si.spawn_drop.rpc_id(1,item_id,$ItemPlace.global_position,!$Sprite.flip_h)
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

@rpc("any_peer", "call_local","reliable") 
func interact(finteracted : String):
	var interacted_target = Mapa.si.get_node(finteracted)
	interacted_target.use(self)
@rpc("call_local","any_peer","reliable")
func respawn(spawn):
	global_position = Mapa.get_spawn(spawn)
	mudar_vida(100)
	external_vel = 0
	velocity = Vector2.ZERO
	visible = true
	$Hitbox/CollisionShape2D.disabled = false

func knockback(vetor : Vector2,forca : int):
	var vector = vetor.direction_to(global_position) * forca
	external_vel += vector.x
	velocity.y += vector.y
func mudar_vida(valor):
	if multiplayer.get_unique_id() == 1:
		mudar_vidaRPC.rpc(valor)
@rpc("call_local","any_peer","reliable")
func mudar_vidaRPC(valor):
	vida = clamp(valor + vida,0,100)
	$HealthBar.value = vida
	if vida == 0:
		visible = false
		$Hitbox/CollisionShape2D.disabled = true
		move_reset()
		if is_multiplayer_authority():
			var countdown = Mapa.create_countdown("Morreu",self)
			countdown.Acabou.connect(func(): respawn.rpc(randi() % Mapa.drop_quant))
func _on_soco_em_alguem(body):
	if body is HurtBox && body != $ItemPlace/Hands/Area2D:
		body.change_life(-10)
		body.knockback(global_position + Vector2(0,3),500)
