extends MultiplayerSynchronizer


func _on_synchronized():
	get_parent().sync()
	disconnect("synchronized",_on_synchronized)
