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
	else: #This will be the regular movement logic that doesn't allow reversing
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
		
	#----------Ability Activation----------#
	if event.is_action_pressed("activate_ability"):
		# Check if we can use the ability
		if GameManager.burrow_unlocked and GameManager.burrow_is_charged:
			print("Button Activated")
			GameManager.burrow_is_active = true
			# Visual feedback for the player
			get_node("FillSprite").modulate = Color.WHITE

# --- Signal Handlers ---

func on_move_timer_timeout():
	# Look at the next position
	var next_position = global_position + (current_direction * tile_size)

	# --- LOOK BEFORE YOU LEAP ---
	if main.is_position_occupied(next_position):
		emit_signal("hit_self")
		return

	# THE NEW BURROW LOGIC
	if main.is_position_out_of_bounds(next_position):
		# First, check if burrow is active
		if GameManager.burrow_is_active:
			# It is! Let's teleport.
			var grid_pos = (next_position / tile_size).round()
			
			# Horizontal Wrap
			if grid_pos.x < 0: grid_pos.x = main.grid_width - 1
			if grid_pos.x >= main.grid_width: grid_pos.x = 0
			
			# Vertical Wrap
			if grid_pos.y < 0: grid_pos.y = main.grid_height - 1
			if grid_pos.y >= main.grid_height: grid_pos.y = 0
			
			# Set the new position and consume the ability
			next_position = (grid_pos * tile_size) + main.tile_offset
			GameManager.burrow_is_active = false
			GameManager.burrow_is_charged = false
			# Return snake head to its normal color after it has teleported
			get_node("FillSprite").modulate = head_color
		else:
			# If burrow is not active, it's a normal game over.
			emit_signal("hit_self")
			return

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
