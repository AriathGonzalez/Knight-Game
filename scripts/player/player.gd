extends CharacterBody2D
class_name Player

@onready
var movement_animations: AnimatedSprite2D = $AnimatedSprite2D

@onready
var movement_state_machine: Node = $movement_state_machine

@onready
var player_move_component = $player_move_component

func _ready() -> void:
	movement_state_machine.init(self, movement_animations, player_move_component)

func _unhandled_input(event: InputEvent) -> void:
	movement_state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	movement_state_machine.process_physics(delta)

func _process(delta: float) -> void:
	movement_state_machine.process_frame(delta)
