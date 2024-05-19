extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	# Singleplayer
	if not GameManager.multiplayer_mode_enabled:
		Engine.time_scale = 0.5	# Slow down game
		# Remove the collision of player on death
		body.get_node("CollisionShape2D").queue_free()
		timer.start()
	else:
		_multiplayer_dead(body)

func _multiplayer_dead(body):
	if multiplayer.get_unique_id() ==  str(body.name).to_int() and body.is_alive:
		Engine.time_scale = 0.5
		body.mark_dead()
		
func _on_timer_timeout():
	Engine.time_scale = 1	# Reset to default at respawn
	get_tree().reload_current_scene()
	

