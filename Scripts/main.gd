#I have comments interspliced as I'm doing shit cuz I keep forgetting when I try to literally
#do the exact thing I just did lol

extends Node2D

@export var initial_snake_length: int = 1
@export var tile_size: int = 32

var tile_offset: Vector2
var grid_width = 40	# 1280 / 32 = 40
var grid_height = 30 # 960 / 32 = 30	so we have an area of 1200 blocks

var snake_body_segments: Array[Node2D] = []

var head: CharacterBody2D

var head_scene = preload("res://Scenes/snake_head.tscn")
var body_scene = preload("res://Scenes/snake_body.tscn")
var fruit_scene = preload("res://Scenes/fruit.tscn")

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
	update_score_display()

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
	var new_segment_position: Vector2 # Holds the chosen position

	# Check if the snake has a body yet.
	if snake_body_segments.is_empty():
		# If there is no body, place the new segment at the head's current position but one space back
		# The movement code on the next frame will automatically move it to the correct spot behind the head.
		new_segment_position = head.global_position - (head.current_direction * tile_size)
	else:
		# If there is already a body, use the old logic and place it at the tail's position.
		var current_tail = snake_body_segments.back()
		new_segment_position = current_tail.global_position

	# Now, set the position and add the new segment
	new_segment.global_position = new_segment_position
	
	# We also need to give it the correct alternating color
	var color_a: Color = Color("00ffff") # Cyan
	var color_b: Color = Color("ffff00") # Yellow
	if snake_body_segments.size() % 2 == 0:
		new_segment.get_node("FillSprite").modulate = color_a
	else:
		new_segment.get_node("FillSprite").modulate = color_b
	
	call_deferred("add_child", new_segment)
	snake_body_segments.append(new_segment)
	update_score_display()
	
func on_snake_ate_food(fruit):
	print("Snake ate food!")
	fruit.queue_free()
	grow_snake()
	spawn_fruit()
	
	if head.can_reverse:
		head.can_reverse = false

func add_body_segment_at(position: Vector2):
	var new_segment = create_colored_segment(position)
	add_child(new_segment)
	snake_body_segments.append(new_segment)
	
func game_over():
	head.move_timer.stop()
	print("Game Over!")
	$UI/GameOverScreen.visible = true

func update_score_display():
	var score = (snake_body_segments.size() + 1)
	$UI/ScoreLabel.text = "Score: " + str(score) 

	
func create_colored_segment(position: Vector2) -> Node2D:
	var segment = body_scene.instantiate()
	segment.position = position
	#Change these values for the alternating snake pattern
	var color_a = Color("8A00C4") #Purple-neon
	var color_b = Color("BA8E23") #Dark Yellow
	if snake_body_segments.size() % 5 == 0 and snake_body_segments.size() != 1:
		segment.get_node("FillSprite").modulate = color_b
	else:
		segment.get_node("FillSprite").modulate = color_a
	return segment

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
