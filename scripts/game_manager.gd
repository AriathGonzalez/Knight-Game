extends Node

var players = {}
var player_scenes = []
var player_winner_username
var total_coin_count
var coin_count = 0
var multiplayer_mode_enabled = false
var respawn_point = Vector2(16, 25)
var score_label
var game_scene

func add_point():
	coin_count += 1
	score_label.text = "You collected " + str(coin_count) + " coins"
