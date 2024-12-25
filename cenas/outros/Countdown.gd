extends CanvasLayer
var cooldown = 3
var  vitima : Cara
var text : String
signal acabou
# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/Control/Text.text = text
	while (cooldown > 0):
		$Panel/Control/Countdown.text = str(cooldown)
		await get_tree().create_timer(1).timeout
		cooldown -= 1
	var rand = randi() % Mapa.si.get_node("Spawns").get_child_count()
	acabou.emit()
	queue_free()
