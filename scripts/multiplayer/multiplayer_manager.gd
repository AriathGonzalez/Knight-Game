extends Control

@export var server_ip = "127.0.0.1"	# Change to local ip 
@export var server_port = 8000
var peer
		
func _ready():
	# Manage connections of players
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	# If I want a return to lobby for multiplayer 
	# Error: get_cached_object: ID 2 not found in cache of peer #.
	
	#call_deferred("_initialize_lobby")
	if "--server" in OS.get_cmdline_args():
		host_game()
		
# Called on server and clients when someone connects
func _on_player_connected(id):
	print("Player %s connected." % id)

# Called on server and clients when someone disconnects
func _on_player_disconnected(id):
	print("Player %s disconnected." % id)
	GameManager.players.erase(id)
	
	# Remove from scene
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()
			
# Called only on client connection to server
# If you need to send info from clients to server, do it here
func _on_connected_ok():
	print("Connected to server.")
	send_player_info.rpc_id(1, $MarginContainer/VBoxContainer/LineEdit.text, multiplayer.get_unique_id())

# Called only on client when they fail to connect to server
func _on_connected_fail():
	print("Error: Could not connect to server.")

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	GameManager.players.clear()
	GameManager.player_scenes = []
	
func _initialize_lobby():
	if multiplayer.has_multiplayer_peer():
		print("initialize lobby")
		return_to_lobby.rpc()
	
@rpc("any_peer", "call_local")
func return_to_lobby():
	var line_edit = $MarginContainer/VBoxContainer/LineEdit
	
	if line_edit:
		for player_id in GameManager.players:
			print("player_id: ", player_id)
			if multiplayer.get_unique_id() == player_id:
				line_edit.text = GameManager.players[player_id].username
	
@rpc("any_peer")
func send_player_info(username, id):
	# If new player, initialize their information
	if not GameManager.players.has(id):
		GameManager.players[id] = {
			"username": username,
			"id": id,
			"score": 0
		}
	
	if multiplayer.is_server():
		for player_id in GameManager.players:
			send_player_info.rpc(GameManager.players[player_id].username, player_id)
			
@rpc("any_peer", "call_local")
func start_game():
	get_tree().change_scene_to_file("res://scenes/multiplayer_game.tscn")
	
func host_game():
	# Establish that this instance is a server
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(server_port, 4)
	
	if error != OK:
		print("Cannot host: " + error)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)	# Not needed, only if you want more optimization
	
	# Set up multiplayer peer
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")
	GameManager.multiplayer_mode_enabled = true
	
func _on_back_pressed():
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(server_ip, server_port)
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)	# Not needed, only if you want more optimization
	multiplayer.set_multiplayer_peer(peer)		# Establish client
	GameManager.multiplayer_mode_enabled = true

func _on_host_pressed():
	host_game()
	send_player_info($MarginContainer/VBoxContainer/LineEdit.text, multiplayer.get_unique_id())

func _on_start_pressed():
	if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
		start_game.rpc()
