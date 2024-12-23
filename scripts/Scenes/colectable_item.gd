extends UseBox
@export 
var itemID : int
@export
var infinite : bool
var itemSC 
func _ready():
	itemSC = load(Item.IdList[itemID])
	var voumematar = itemSC.instantiate()
	$Sprite.texture = voumematar.get_texture()
	$Sprite.offset = Vector2(0,-voumematar.height)
@rpc("any_peer", "call_local") 
func use(_cara : Cara):
	_cara.equip_item(itemSC.instantiate())
	if not infinite:
		queue_free()
