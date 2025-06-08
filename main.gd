extends Node2D

@export var initial_snake_length: int = 3
@export var tile_size: int = 32

var tile_offset: Vector2
var grid_width = 40
var grid_height = 30

var snake_body_segments: Array[Node2D] = []

var head: CharacterBody2D

var head_scene = preload("res://snake_head.tscn")
var body_scene = preload("res://snake_body.tscn")
var fruit_scene = preload("res://fruit.tscn")

func _ready():
	tile_offset = Vector2(tile_size / 2, tile_size / 2)
	# 1. Create the head
	head = head_scene.instantiate()
	head.position = Vector2(10, 8) * tile_size + tile_offset
	head.main = self
	add_child(head)
	
	# 2. Connect to the head's signals
	head.moved.connect(on_snake_head_moved)
	head.ate_fruit.connect(on_snake_ate_food)
	head.hit_self.connect(game_over)

	# 3. Create the initial body
	var behind_direction = -head.current_direction
	for i in range(initial_snake_length - 1):
		var grid_pos = (Vector2(10, 8) + (behind_direction * (i + 1)))
		var segment_pos = (grid_pos * tile_size) + tile_offset
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
	
	fruit.position = Vector2(x_pos, y_pos) * tile_size + tile_offset
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
	
func game_over():
	head.move_timer.stop()
	print("Game Over!")
	


func positions_are_equal(pos1: Vector2, pos2: Vector2) -> bool:
	if pos1.distance_to(pos2) < 0.1:
		return true
	else:
		return false


func is_position_occupied(check_pos: Vector2) -> bool:
	for segment in snake_body_segments:
		if positions_are_equal(segment.global_position, check_pos):
			return true 
	
	return false

func is_position_out_of_bounds(check_pos: Vector2) -> bool:
	var grid_pos = (check_pos / tile_size).round()
	if grid_pos.x < 0 or grid_pos.x > grid_width or \
	   grid_pos.y < 0 or grid_pos.y > grid_height:
		return true
	return false
