extends CanvasLayer
var cooldown = 3
var  vitima : Cara
# Called when the node enters the scene tree for the first time.
func _ready():
	while (cooldown > 0):
		$Panel/Control/Countdown.text = str(cooldown)
		await get_tree().create_timer(1).timeout
		cooldown -= 1
	vitima.respawn.rpc()
	queue_free()
