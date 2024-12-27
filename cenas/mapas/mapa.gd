extends Node2D
class_name Game
var dropid = 0
static var spawn_quant = 2
static var can_respawn = true
static var can_punch = true
var loaded_map
static var si : Node2D; 
static var dropSC = load("res://cenas/props/dropped_item.tscn")
static var maps = [preload("res://cenas/mapas/mapa1.tscn"),
	preload("res://cenas/mapas/mapa2.tscn"),
	preload("res://cenas/mapas/mapa3.tscn"),
	preload("res://cenas/mapas/mapa4.tscn"),
	preload("res://cenas/mapas/mapa5.tscn"),
	preload("res://cenas/mapas/mapa6.tscn"),
	preload("res://cenas/mapas/mapa7.tscn"),
	preload("res://cenas/mapas/mapa8.tscn")
]


func _ready():
	si = self
func _process(delta):
	print(loaded_map)
@rpc("any_peer","call_local","reliable")
func spawn_drop(droped_item_id : int,pos : Vector2,flip : bool = false):
	var drop = dropSC.instantiate()
	drop.global_position = pos
	drop.item_id = droped_item_id
	drop.get_node("Sprite").flip_h = flip
	drop.name = "drop" + str(dropid)
	dropid += 1
	call_deferred("add_child",drop)
@rpc("any_peer","call_local","reliable")
func remove_drop(path : String):
	get_node(path).queue_free()
	
func pre_load_map():
	var id = randi() % maps.size()
	NetWork.player_list = []
	load_map.rpc(id)
@rpc("any_peer","reliable","call_local")
func load_map(id : int):
	can_punch = false
	can_respawn = false
	for i in get_children():
		i.queue_free()
		await i.tree_exited
	loaded_map = maps[id].instantiate()
	add_child(loaded_map)
	spawn_quant = get_child(0).get_node("Spawns").get_child_count()
	if multiplayer.get_unique_id() == 1:
		load_players()
func load_players():
	var players : Array
	for p : Cara in si.get_parent().get_node("Spawner").get_children():
		players.append(p.name.to_int())
		p.queue_free()
		await p.tree_exited
	var spawm = range(spawn_quant-1)
	spawm.shuffle()
	var i : int = 0
	for name_id : int in players:
		$"../Spawner".add_player(name_id,spawm[i])
		si.load_countdown.rpc_id(name_id,"prepare-se",3,str(name_id))
		i += 1
@rpc("any_peer","reliable","call_local")
func load_countdown(text : String,time : int,nome : String):
	var player : Cara = get_player(nome)
	player.max_speed = 0
	player.jump_force = 0
	var pepega = create_countdown(text,time,player)
	pepega.acabou.connect(func(): player.move_reset(); can_punch = true)
@rpc("any_peer","reliable","call_remote")
func create_countdown(text : String,time : int,node = si.get_parent()):
	var pepega = load("res://cenas/outros/countdown.tscn").instantiate()
	pepega.text = text
	pepega.countdown = time
	node.add_child(pepega)
	return pepega
@rpc("any_peer","reliable","call_local")
func playergone(n):
	NetWork.player_list.erase(n.to_int())
	if NetWork.player_list.size() == 1:
		var count = create_countdown(get_player(str(NetWork.player_list[0])).nome + " Ganhou!",3)
		create_countdown.rpc(get_player(str(NetWork.player_list[0])).nome + " Ganhou!",3)
		count.tree_exited.connect(pre_load_map)
		NetWork.player_list = []
static func get_spawn(n):
	if Game.si.get_child(0).get_node("Spawns"):
		return Game.si.get_child(0).get_node("Spawns").get_child(n).global_position
	else:
		si.get_tree().create_timer(0.1).timeout.connect(get_spawn,n)
	
static func get_player(nome):
	return si.get_parent().get_node("Spawner/" + nome)
