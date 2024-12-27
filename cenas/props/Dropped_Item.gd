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
	$Sprite.offset = Vector2(0,-voumematar.height/2)
func use(cara : Cara):
	cara.equip_item(item_id)
	if not infinite:
		Game.si.remove_drop.rpc_id(1,name)
