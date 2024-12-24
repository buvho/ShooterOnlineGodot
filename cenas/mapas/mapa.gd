extends Node2D
class_name Mapa
var dropid = 0
static var si : Node2D; 
static var dropSC = load("res://cenas/props/dropped_item.tscn")
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
	add_child(drop)
@rpc("any_peer","call_local","reliable")
func remove_drop(path : String):
	get_node(path).queue_free()
