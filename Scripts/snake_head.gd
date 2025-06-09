extends CharacterBody2D

signal moved(previous_position: Vector2)
signal ate_fruit(fruit)
signal hit_self

# --- Properties ---
@export var head_color: Color = Color.LIME

var tile_size: int = 32
var move_speed: float = 0.2
var current_direction: Vector2 = Vector2.RIGHT
var can_change_direction: bool = true
var can_reverse: bool = true
var main: Node2D

@onready var move_timer: Timer = $MoveTimer
@onready var head_area: Area2D = $HeadArea

# --- Godot Functions ---

func _ready():
	get_node("FillSprite").modulate = head_color
	move_timer.wait_time = move_speed
	move_timer.timeout.connect(on_move_timer_timeout)
	move_timer.start()
	

func _unhandled_input(event: InputEvent):
	if not can_change_direction:
		return

	var new_direction = current_direction
	#This is our backstop in case there is only one snake length
	if can_reverse:
		if event.is_action_pressed("ui_up"):
			new_direction = Vector2.UP
		elif event.is_action_pressed("ui_down"):
			new_direction = Vector2.DOWN
		elif event.is_action_pressed("ui_left"):
			new_direction = Vector2.LEFT
		elif event.is_action_pressed("ui_right"):
			new_direction = Vector2.RIGHT
	else: #This will be our regular movement logic that doesn't allow reversing
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
	# First, calculate where we WANT to go, but don't move yet.
	var next_position = global_position + (current_direction * tile_size)

	# --- LOOK BEFORE YOU LEAP ---
	
	# 1. Ask the Main script if the next spot is occupied by our body.
	if main.is_position_occupied(next_position):
		emit_signal("hit_self")
		return # Stop here! Don't move.

	# 2. NEW: Ask the Main script if the next spot is a wall.
	if main.is_position_out_of_bounds(next_position):
		emit_signal("hit_self") # Hitting a wall is a game over, same as hitting self.
		return 					# Stop here! Don't move.

	# If we made it here, the path is clear. It is now safe to move.
	var previous_position = global_position
	global_position = next_position
	
	# Tells the Main script that we have successfully moved.
	moved.emit(previous_position)
	
	can_change_direction = true


func _on_head_area_area_entered(area):
	print("Head detector touched something! The object was: ", area)
	
	if area is Fruit:
		emit_signal("ate_fruit", area)
	elif area is SnakeBody:
		emit_signal("hit_self")
