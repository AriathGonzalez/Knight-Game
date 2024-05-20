extends Control
	
func _on_quit_pressed():
	get_tree().quit()

func _on_singleplayer_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_multiplayer_pressed():
	get_tree().change_scene_to_file("res://scenes/multiplayer_menu.tscn")
