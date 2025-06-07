# FILE: snake_head.gd (Reworked Version)

extends CharacterBody2D

signal moved(previous_position: Vector2)
signal ate_fruit(fruit)

# --- Properties ---
var tile_size: int = 64
var move_speed: float = 0.25
var current_direction: Vector2 = Vector2.RIGHT
var can_change_direction: bool = true

@onready var move_timer: Timer = $MoveTimer
@onready var head_area: Area2D = $HeadArea

# --- Godot Functions ---

func _ready():
	# This script is now self-starting.
	# It configures AND starts its own timer.
	move_timer.wait_time = move_speed
	move_timer.timeout.connect(on_move_timer_timeout)
	move_timer.start() # <-- KEY CHANGE: The head starts itself.

func _unhandled_input(event: InputEvent):
	if not can_change_direction:
		return

	var new_direction = current_direction
	if event.is_action_pressed("ui_up") and current_direction != Vector2.DOWN:
		new_direction = Vector2.UP
	elif event.is_action_pressed("ui_down") and current_direction != Vector2.UP:
		new_direction = Vector2.DOWN
	elif event.is_action_pressed("ui_left") and current_direction != Vector2.RIGHT:
		new_direction = Vector2.LEFT
	elif event.is_action_pressed("ui_right") and current_direction != Vector2.LEFT:
		new_direction = Vector2.RIGHT
	
	if new_direction != current_direction:
		current_direction = new_direction
		can_change_direction = false

# --- Signal Handlers ---

func on_move_timer_timeout():
	var previous_position = global_position
	global_position += current_direction * tile_size
	moved.emit(previous_position)
	can_change_direction = true

# This function is connected to the child Area2D's `area_entered` signal
func _on_head_area_area_entered(area):
	if area is Fruit:
		ate_fruit.emit(area)
