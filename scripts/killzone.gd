extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	print("You died")
	Engine.time_scale = 0.5	# Slow down game
	# Remove the collision of player on death
	body.get_node("CollisionShape2D").queue_free()
	timer.start()



func _on_timer_timeout():
	Engine.time_scale = 1	# Reset to default at respawn
	get_tree().reload_current_scene()

