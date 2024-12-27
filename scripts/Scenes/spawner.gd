extends Node2D
class_name NetWork
@export var player_scene: PackedScene
var game_stared = false
var port = 2012
var host
var peer
signal hide_ui
var spawn_pos
static var player_list = []
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
		if player.visible == true:
			player_list.erase(id)
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
	add_player(1,randi() % Game.spawn_quant)
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
func add_player(id : int,spawn = 0):
		player_list.append(id)
		var player : Cara = player_scene.instantiate()
		if id != 1:
			att_pos.rpc_id(id,Game.get_spawn(spawn))
		player.name = str(id);
		add_child(player)
		if id == 1:
			while !player.is_inside_tree():
				await get_tree().create_timer(0.1).timeout
			player.global_position = Game.get_spawn(spawn)
		return player
@rpc("any_peer","reliable","call_local")
func att_pos(spawn):
	spawn_pos = spawn
	$"../MultiplayerSpawner".spawned.connect(player_pos) 
func player_pos(node):
	node.global_position = spawn_pos
	$"../MultiplayerSpawner".spawned.disconnect(player_pos) 

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
	add_player.rpc_id(1,multiplayer.get_unique_id(),randi() % Game.spawn_quant)


func _on_start_game_pressed():
	game_stared = true
