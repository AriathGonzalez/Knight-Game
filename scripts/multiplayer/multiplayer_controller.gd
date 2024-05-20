extends CharacterBody2D
class_name MultiplayerPlayer

@onready var movement_animations: AnimatedSprite2D = $AnimatedSprite2D

@onready var movement_state_machine: Node = $movement_state_machine

@onready var player_move_component = $player_move_component

@onready var camera_2d = $Camera2D

var is_alive = true

func _ready() -> void:
	movement_state_machine.init(self, movement_animations, player_move_component)
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _unhandled_input(event: InputEvent) -> void:
	movement_state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	if not is_alive and is_on_floor():
		_set_alive()
					
	if multiplayer and $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		movement_state_machine.process_physics(delta)
		camera_2d.enabled = true
	else:
		camera_2d.enabled = false
		
func _process(delta: float) -> void:
	movement_state_machine.process_frame(delta)

func mark_dead():
	print("Player %s died." % self.name)
	is_alive = false
	$CollisionShape2D.set_deferred("disabled", true)
	$RespawnTimer.start()

func _respawn():
	print("Player %s respawned." % self.name)
	position = GameManager.respawn_point
	$CollisionShape2D.set_deferred("disabled", false)
	
func _set_alive():
	is_alive = true
	Engine.time_scale = 1	# Reset to default at respawn
