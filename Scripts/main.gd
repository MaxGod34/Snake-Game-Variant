#I have comments interspliced as I'm doing shit cuz I keep forgetting when I try to literally
#do the exact thing I just did lol

extends Node2D

@export var initial_snake_length: int = 1
@export var tile_size: int = 32

# Grid properties, including offset due to centering of the blocks
var tile_offset: Vector2
var grid_width = 40	# 1280 / 32 = 40
var grid_height = 30 # 960 / 32 = 30	so we have an area of 1200 blocks
var snake_body_segments: Array[Node2D] = []

# Boolean Flags
var is_game_over: bool = false
var upgrade_menu_is_pending: bool = false

var head: CharacterBody2D

var head_scene = preload("res://Scenes/snake_head.tscn")
var body_scene = preload("res://Scenes/snake_body.tscn")
var fruit_scene = preload("res://Scenes/fruit.tscn")
var pause_scene = preload("res://Scenes/pause_menu.tscn")

signal game_is_over(score)

func _ready():
	#difficulty modifiers
	if GameManager.current_difficulty == "hard":
		head_scene.instantiate().move_speed = 0.15
		initial_snake_length = 5
	else:
		head_scene.instantiate().move_speed = 0.25
		initial_snake_length = 1
	
	
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
	# 2.5. Connect our other signals
	$PauseMenu.resume_game.connect(toggle_pause)

	# 3. Create the initial body
	var behind_direction = -head.current_direction
	for i in range(initial_snake_length - 1):
		var grid_pos = (Vector2(10, 8) + (behind_direction * (i + 1)))
		var segment_pos = (grid_pos * tile_size) + tile_offset
		add_body_segment_at(segment_pos)
	
	spawn_fruit()
	head.move_timer.start()
	update_score_display()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_game_over:
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		get_tree().paused = false
		$PauseMenu.visible = false
	else:
		#update score when pause is pressed
		var current_score = snake_body_segments.size() + 1
		$PauseMenu.display_score(current_score)
		#actually pause the game
		get_tree().paused = true
		$PauseMenu.visible = true

func show_upgrade_menu():
	head.move_timer.stop() #this doesn't pause the game, it just stops the snake movement
	$UI/UpgradeMenu.update_all_displays()
	$UI/UpgradeMenu.visible = true

func _on_quit_to_menu():
	GameManager.go_to_scene("res://Scenes/main_menu.tscn")

func on_quit_to_menu_pressed():
	get_tree().paused = false
	GameManager.go_to_scene("res://Scenes/main_menu.tscn")

func on_snake_head_moved(head_previous_position: Vector2):
	if snake_body_segments.is_empty():
		return
		
	# Classic "follow-the-leader" movement logic
	var target_position = head_previous_position
	for segment in snake_body_segments:
		var old_position = segment.global_position
		segment.global_position = target_position
		target_position = old_position
	if upgrade_menu_is_pending:
		#menu is pending
		upgrade_menu_is_pending = false # Reset the flag
		show_upgrade_menu()				# Now we show the menu
		
func spawn_fruit():
	print("Spawning a fruit.")
	
	var fruit = fruit_scene.instantiate()
	var potential_position: Vector2
	var is_safe_position = false
	
	while not is_safe_position:
		var x_pos = randi() % grid_width
		var y_pos = randi() % grid_height
		var random_grid_pos = Vector2(x_pos, y_pos)
		
		potential_position = (random_grid_pos * tile_size) + tile_offset
		if not is_position_occupied(potential_position) and not positions_are_equal(potential_position, head.global_position):
			is_safe_position = true
			#this will break us out of the loop once it is set to true
	
	
	fruit.position = potential_position
	call_deferred("add_child", fruit)
	print("fruit spawned at a safe location")
	
func grow_snake():
	print("Growing snake.")
	
	for i in range(GameManager.fruit_reward):
		var new_segment_position: Vector2 
	# Check if the snake has a body yet.
		if snake_body_segments.is_empty() and i == 0:
		# If there is no body, place the new segment at the head's current position but one space back
		# The movement code on the next frame will automatically move it to the correct spot behind the head.
			new_segment_position = head.global_position - (head.current_direction * tile_size)
		else:
		# If there is already a body, use the old logic and place it at the tail's position.
			var current_tail = snake_body_segments.back()
			new_segment_position = current_tail.global_position
		
		var new_segment = create_colored_segment(new_segment_position)
		call_deferred("add_child", new_segment)
		snake_body_segments.append(new_segment)

	update_score_display()

func check_for_level_up():
	var leveled_up_this_frame = false # Flag to check for multi-leveling in one fruit grab
	var current_score = snake_body_segments.size() + 1
	
	while current_score >= GameManager.score_needed_for_next_level:
		print("Level Up! Score is: ", current_score)
		# Award level and skill point(s)
		GameManager.player_level += 1
		GameManager.skill_points += 1
		# Set the next level goal
		GameManager.score_needed_for_next_level += 5
		# Set a flag to know we should show the menu at a "later" time
		leveled_up_this_frame = true
	# After looping through this while loop, if we level up, set the flag that is waiting
	if leveled_up_this_frame:
		upgrade_menu_is_pending = true

func _on_upgrade_menu_resume_game_pressed():
	$UI/UpgradeMenu.visible = false
	head.move_timer.start()

func _on_upgrade_menu_upgrade_selected(upgrade_name):
	print("Player chose upgrade: ", upgrade_name)
	# Upgrades implemented: Speed and Fruit Reward
	# Speed Upgrade logic only
	if upgrade_name == "increase_speed":
		if GameManager.speed_upgrade_level < 10:
			GameManager.speed_upgrade_level += 1
			head.move_timer.wait_time *= 0.9
			print("New snake speed (wait time): ", head.move_timer.wait_time)
	# Fruit Reward Upgrade logic only
	elif upgrade_name == "increase_fruit_reward":
		if GameManager.fruit_reward < 10:
			GameManager.fruit_reward += 1
			print("New fruit reward (fruit reward): ", GameManager.fruit_reward)
			
	_on_upgrade_menu_resume_game_pressed()

func on_snake_ate_food(fruit):
	print("Snake ate food!")
	fruit.queue_free()
	grow_snake()
	spawn_fruit()
	check_for_level_up()
	
	if head.can_reverse:
		head.can_reverse = false

func add_body_segment_at(position: Vector2):
	var new_segment = create_colored_segment(position)
	add_child(new_segment)
	snake_body_segments.append(new_segment)
	
func game_over():
	is_game_over = true
	head.move_timer.stop()
	print("Game Over!")
	$UI/GameOverScreen.visible = true
	var final_score = snake_body_segments.size() + 1
	game_is_over.emit(final_score)


func update_score_display():
	var score = (snake_body_segments.size() + 1)
	$UI/ScoreLabel.text = "Score: " + str(score)

	
func create_colored_segment(position: Vector2) -> Node2D:
	var segment = body_scene.instantiate()
	segment.position = position
	#Change these values for the alternating snake pattern
	var color_a = Color("8A00C4") #Purple-neon
	var color_b = Color("BA8E23") #Dark Yellow
	if (snake_body_segments.size() + 2) % 5 == 0:
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
