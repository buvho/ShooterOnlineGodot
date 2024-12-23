extends Node2D
class_name NetWork
@export var player_scene: PackedScene
static var spawn_point;
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
	spawn_point = $"../Mapa/Spawn".global_position

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
	$"../Control".visible = true

func _on_host_pressed():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error != OK:
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	$"../StartGame".visible = true
	emit_signal("hide_ui")
	add_player(1)
func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	if $"../Control/Panel/Container/Ip".text.is_empty():
		host = "localhost"
	else:
		host = $"../Control/Panel/Container/Ip".text
	var test = peer.create_client(host, port)
	if test == OK:
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.multiplayer_peer = peer

@rpc("any_peer","call_local")
func add_player(id):
	var player = player_scene.instantiate()
	player.name = str(id);
	player.global_position = spawn_point
	call_deferred("add_child", player)

@rpc("any_peer")
func get_game_status(id):
	receive_game_status.rpc_id(id,game_stared)

@rpc("any_peer")
func receive_game_status(status):
	if status:
		multiplayer.multiplayer_peer.disconnect_peer(1)
		$"../Control".visible = true
		return
	emit_signal("hide_ui")
	add_player.rpc_id(1,multiplayer.get_unique_id())


func _on_start_game_pressed():
	game_stared = true
