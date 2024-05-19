extends Area2D


@onready var game_manager = %GameManager
@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	GameManager.add_point()
			
	if GameManager.multiplayer_mode_enabled and multiplayer.get_unique_id() == str(body.name).to_int():
		var player_id = multiplayer.get_unique_id()
		_increment_player_coin_count.rpc(player_id)
		_decrement_total_coin_count.rpc()
		play_coin_sound.rpc()
	elif not GameManager.multiplayer_mode_enabled:
		animation_player.play("pickup")
		
	if GameManager.multiplayer_mode_enabled and GameManager.total_coin_count <= 0:
		get_winner()
		update_label_for_all.rpc()
	elif not GameManager.multiplayer_mode_enabled and GameManager.coin_count >= GameManager.total_coin_count:
		body.update_label()
		$"../../EndTimer".start()

@rpc("any_peer", "call_local")
func _decrement_total_coin_count():
	GameManager.total_coin_count -= 1

@rpc("any_peer", "call_local")
func _increment_player_coin_count(player_id):
	GameManager.players[player_id].score += 1
	
func get_winner():
	var max_score = 0
	var player_winner_username
	
	for player_id in GameManager.players:
		var score = GameManager.players[player_id].score 
		if score > max_score:
			max_score = score
			player_winner_username = GameManager.players[player_id].username
	set_winner_for_all.rpc(player_winner_username)
	print("Winner: ", GameManager.player_winner_username)

@rpc("any_peer", "call_local")
func set_winner_for_all(player_winner_username):
	GameManager.player_winner_username = player_winner_username

@rpc("any_peer", "call_local")		
func update_label_for_all():
	for player in GameManager.player_scenes:
		var node_path = get_tree().get_current_scene().get_path_to(player)
		if node_path:
			var label = player.get_node("EndLabel")
			label.text = GameManager.player_winner_username + " Won!"
	$"../../EndTimer".start()

@rpc("any_peer", "call_local")
func play_coin_sound():
	animation_player.play("pickup")

