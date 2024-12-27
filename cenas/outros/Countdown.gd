extends CanvasLayer
var countdown = 3
var text : String
signal acabou
# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/Control/Text.text = text
	while (countdown > 0):
		$Panel/Control/Countdown.text = str(countdown)
		await get_tree().create_timer(1).timeout
		countdown -= 1
	acabou.emit()
	queue_free()
