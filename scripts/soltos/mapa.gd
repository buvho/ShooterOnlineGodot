extends Node2D
class_name mapa
var dropid = 0
static var si : Node2D; 
static var dropSC = load("res://cenas/props/dropped_item.tscn")
func _ready():
	si = self
@rpc("any_peer","call_local","reliable")
func spawn_drop(droped_item_id : int,flip : bool,pos : Vector2):
	print(multiplayer.get_unique_id())
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
