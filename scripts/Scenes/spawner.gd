extends Node2D
class_name NetWork
@export var player_scene: PackedScene
var game_stared = false
var port = 2012
var host
var peer
signal hide_ui

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

#chamado nos servers e clients
func peer_connected(_id):
	pass
#chamado nos servers e clients
func peer_disconnected(id):
	var player = get_node_or_null(str(id))
	if player:
		player.queue_free()
#chamado só em clients
func connected_to_server():
	get_game_status.rpc_id(1,multiplayer.get_unique_id())

#chamado só em clients
func connection_failed():
	$"../CanvasLayer/MenuInicial".visible = true

func _on_host_pressed():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error != OK:
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	$"../CanvasLayer/MenuDono".visible = true
	hide_ui.emit()
	add_player(1)
func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	if $"../CanvasLayer/MenuInicial/Panel/Container/Ip".text.is_empty():
		host = "localhost"
	else:
		host = $"../CanvasLayer/MenuInicial/Panel/Container/Ip".text
	var test = peer.create_client(host, port)
	if test == OK:
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.multiplayer_peer = peer

@rpc("any_peer","call_local","reliable")
func add_player(id,spawn = 0):
	var player : Cara = player_scene.instantiate()
	player.name = str(id);
	call_deferred("add_child", player)
	player.ready.connect(func(): get_tree().create_timer(0.01).timeout.connect(func (): player_pos.rpc_id(id,id,spawn)))
	return player
@rpc("any_peer","reliable","call_local")
func player_pos(id,spawn):
	get_node(str(id)).global_position = Mapa.get_spawn(spawn)
@rpc("any_peer","reliable")
func get_game_status(id):
	receive_game_status.rpc_id(id,game_stared)

@rpc("any_peer","reliable")
func receive_game_status(status):
	if status:
		multiplayer.multiplayer_peer.disconnect_peer(1)
		$"../CanvasLayer/MenuInicial".visible = true
		return
	hide_ui.emit()
	add_player.rpc_id(1,multiplayer.get_unique_id())


func _on_start_game_pressed():
	game_stared = true
