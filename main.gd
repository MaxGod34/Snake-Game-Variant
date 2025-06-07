# FILE: main.gd (Reworked Version)

extends Node2D

@export var initial_snake_length: int = 3
@export var tile_size: int = 64

var snake_body_segments: Array[Node2D] = []

var head_scene = preload("res://snake_head.tscn")
var body_scene = preload("res://snake_body.tscn")
# var fruit_scene = preload("res://fruit.tscn") # We can add fruit back later

func _ready():
	# This function is now much simpler. It just builds the snake.
	
	# 1. Create the head
	var head = head_scene.instantiate()
	head.position = Vector2(10, 8) * tile_size
	add_child(head)
	
	# 2. Connect to the head's signals
	head.moved.connect(on_snake_head_moved)
	# head.ate_fruit.connect(on_snake_ate_food)

	# 3. Create the initial body
	var behind_direction = -head.current_direction
	for i in range(initial_snake_length - 1):
		var segment_pos = head.position + (behind_direction * tile_size * (i + 1))
		add_body_segment_at(segment_pos)
	
	# That's it! We no longer need to `await` or start the timer from here.

func on_snake_head_moved(head_previous_position: Vector2):
	if snake_body_segments.is_empty():
		return
		
	# Classic "follow-the-leader" movement logic
	var target_position = head_previous_position
	for segment in snake_body_segments:
		var old_position = segment.global_position
		segment.global_position = target_position
		target_position = old_position

func add_body_segment_at(position: Vector2):
	var segment = body_scene.instantiate()
	segment.position = position
	add_child(segment)
	snake_body_segments.append(segment)
