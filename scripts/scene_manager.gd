extends Node2D

@export var player_scene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.coin_count = 0
	if not GameManager.score_label:
		GameManager.score_label = $GameManager/ScoreLabel
	if not GameManager.total_coin_count:
		GameManager.total_coin_count = get_tree().get_nodes_in_group("Coins").size()
		
	if GameManager.multiplayer_mode_enabled:
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
					GameManager.player_scenes.append(current_player)
			index += 1

func _load_main_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	print("load main menu?")

func _load_multiplayer_menu():
	print("current scene: ", get_tree().get_current_scene())
	GameManager.game_scene.queue_free()  # Remove the game scene
	self.show()  # Show the multiplayer menu again
