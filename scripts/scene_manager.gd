extends Node2D

@export var player_scene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	
	for i in GameManager.players:
		var current_player = player_scene.instantiate()
		current_player.name = str(GameManager.players[i].id)
		add_child(current_player)
		
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
				var label = current_player.get_node("Username")
				label.text = GameManager.players[i].username
		index += 1
	pass
