extends Node2D

const SPEED = 60

var direction = 1

@onready var ray_cast_2d_right = $RayCast2DRight
@onready var ray_cast_2d_left = $RayCast2DLeft
@onready var animated_sprite_2d = $AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Enemy has hit wall on the right. Therefore, move to the left
	if ray_cast_2d_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true	# Flip sprite
	# Enemey has hit wall on the left. Therefore, move to the right
	if ray_cast_2d_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false
		
	position.x += direction * SPEED * delta
