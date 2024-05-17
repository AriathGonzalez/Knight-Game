extends Control

@export var server_ip = "127.0.0.1"
@export var server_port = 8000
var peer

func _ready():
	# Manage connections of players
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	# TODO: If I want to host it 
	# if "--server" in OS.get_cmdline_args():
		

# Called on server and clients when someone connects
func peer_connected(id):
	print("Player %s connected." % id)

# Called on server and clients when someone disconnects
func peer_disconnected(id):
	print("Player %s disconnected." % id)
	GameManager.players.erase(id)
	
	# Remove from scene
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()
			
# Called only on client connection to server
# If you need to send info from clients to server, do it here
func connected_to_server():
	print("Connected to server.")
	send_player_info.rpc_id(1, $MarginContainer/VBoxContainer/LineEdit.text, multiplayer.get_unique_id())

# Called only on client when they fail to connect to server
func connection_failed():
	print("Error: Could not connect to server.")

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
	var game_scene = load("res://scenes/multiplayer_game.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	self.hide()
	
func _on_back_pressed():
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(server_ip, server_port)
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)	# Not needed, only if you want more optimization
	multiplayer.set_multiplayer_peer(peer)		# Establish client

func _on_host_pressed():
	# Establish that this instance is a server
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(server_port, 2)
	
	if error != OK:
		print("Cannot host: " + error)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)	# Not needed, only if you want more optimization
	
	# Set up multiplayer peer
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")
	send_player_info($MarginContainer/VBoxContainer/LineEdit.text, multiplayer.get_unique_id())

func _on_start_pressed():
	start_game.rpc()
