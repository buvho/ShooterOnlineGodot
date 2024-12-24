extends RigidBody2D
@export 
var item_id : int
@export
var infinite : bool
var itemSC 
func _ready():
	itemSC = load(Item.IdList[item_id])
	var voumematar = itemSC.instantiate()
	$Sprite.texture = voumematar.get_texture()
	$Sprite.offset = Vector2(0,-voumematar.height)
@rpc("any_peer", "call_local") 
func use(cara : Cara):
	cara.equip_item(itemSC.instantiate())
	if not infinite && multiplayer.get_unique_id() == 1:
		mapa.si.remove_drop.rpc_id(1,name)
