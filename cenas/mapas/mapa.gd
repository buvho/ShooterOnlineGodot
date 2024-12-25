extends Node2D
class_name Mapa
var dropid = 0
var respawnable = true
static var drop_quant = 2
static var si : Node2D; 
static var dropSC = load("res://cenas/props/dropped_item.tscn")
static var maps = {0: "res://cenas/mapas/mapa0.tscn"}
@export var starter_gear = -1
func _ready():
	si = self
	if starter_gear != -1:
		for player : Cara in get_parent().get_node("spawn").get_children():
			player.equip_item(starter_gear)
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
	
static func pre_load_map():
	var id = randi() % maps.size()
	var shuffled : Array
	for i : Cara in si.get_parent().get_node("Spawner").get_children():
		shuffled.append(i.name)
		i.free()
	shuffled.shuffle()
	Mapa.si.load_map.rpc(id)
	si.load_players(shuffled)
@rpc("any_peer","reliable","call_local")
func load_map(id : int):
	$"../Camera".player = null
	for i in get_children():
		i.queue_free()
	add_child(load(maps[id]).instantiate())
	drop_quant = get_child(0).get_node("Spawns").get_child_count()
func load_players(player_list):
	var i = 0
	for id in player_list:
		$"../Spawner".add_player(int(id),i)
static func get_spawn(n):
	return Mapa.si.get_child(0).get_node("Spawns").get_child(n).global_position

static func create_countdown(text : String,player : Cara):
	var pepega = load("res://cenas/outros/cooldown.tscn").instantiate()
	pepega.vitima = player
	pepega.text = text
	player.add_child(pepega)
	return pepega
