extends Node2D

@export var initial_snake_length: int = 3
@export var tile_size: int = 64

var grid_width = 20
var grid_height = 15

var snake_body_segments: Array[Node2D] = []

var head_scene = preload("res://snake_head.tscn")
var body_scene = preload("res://snake_body.tscn")
var fruit_scene = preload("res://fruit.tscn")

func _ready():
	# 1. Create the head
	var head = head_scene.instantiate()
	head.position = Vector2(5, 5) * tile_size
	add_child(head)
	
	# 2. Connect to the head's signals
	head.moved.connect(on_snake_head_moved)
	head.ate_fruit.connect(on_snake_ate_food)

	# 3. Create the initial body
	var behind_direction = -head.current_direction
	for i in range(initial_snake_length - 1):
		var segment_pos = head.position + (behind_direction * tile_size * (i + 1))
		add_body_segment_at(segment_pos)
	
	spawn_fruit()
	head.move_timer.start()

func on_snake_head_moved(head_previous_position: Vector2):
	if snake_body_segments.is_empty():
		return
		
	# Classic "follow-the-leader" movement logic
	var target_position = head_previous_position
	for segment in snake_body_segments:
		var old_position = segment.global_position
		segment.global_position = target_position
		target_position = old_position
		
func spawn_fruit():
	print("Spawning a fruit.")
	
	var fruit = fruit_scene.instantiate()
	
	var x_pos = randi() % grid_width
	var y_pos = randi() % grid_height
	
	fruit.position = Vector2(x_pos, y_pos) * tile_size
	call_deferred("add_child", fruit)
	print("fruit spawned")
	
func grow_snake():
	print("Growing snake.")
	
	var new_segment = body_scene.instantiate()
	
	var current_tail = snake_body_segments.back()
	
	new_segment.global_position = current_tail.global_position
	
	call_deferred("add_child", new_segment)
	snake_body_segments.append(new_segment)
	
func on_snake_ate_food(fruit):
	print("Snake ate food!")
	fruit.queue_free()
	grow_snake()
	spawn_fruit()

func add_body_segment_at(position: Vector2):
	var segment = body_scene.instantiate()
	segment.position = position
	add_child(segment)
	snake_body_segments.append(segment)
