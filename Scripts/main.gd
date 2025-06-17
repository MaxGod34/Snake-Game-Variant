extends Node2D

@export var initial_snake_length: int = 1
@export var tile_size: int = 32


# Grid properties, including offset due to centering of the blocks
var tile_offset: Vector2
var grid_width: int
var grid_height: int


# Boolean Flags
var is_game_over: bool = false
var upgrade_menu_is_pending: bool = false
var garden_complete_is_pending: bool = false

var snake_body_segments: Array[Node2D] = []
var head: CharacterBody2D
var trail_pieces: Array = []

var spawned_obstacles: Array = []
var next_fruit_position: Vector2
var ghost_fruit_instance = null


var time_since_last_fruit: float = 0.0



var head_scene = preload("res://Scenes/snake_head.tscn")
var body_scene = preload("res://Scenes/snake_body.tscn")
var fruit_scene = preload("res://Scenes/fruit.tscn")
var rock_scene = preload("res://Scenes/rock.tscn")
var pause_scene = preload("res://Scenes/pause_menu.tscn")

#-------SIGNALS--------#

signal game_is_over(score)

func _ready():
	 # --- GAME SETUP ---
	var difficulty = GameManager.chosen_difficulty
	var p_class = GameManager.chosen_class
	var diff_data = GameManager.difficulty_data[difficulty]
	var class_data = GameManager.class_data[p_class]
	GameManager.has_died_this_garden = false
	GameManager.garden_weaver_used_this_garden = false
	
	initial_snake_length = class_data["start_length"]
	var start_speed = class_data["start_speed"] * diff_data["speed_multiplier"]
	
	spawned_obstacles.clear()
	# Bounds and Tile Offset cuz center origin omfg i'll kms
	update_boundary_visuals()
	tile_offset = Vector2(tile_size / 2, tile_size / 2)
	
	# --- CREATE HEAD ---
	head = head_scene.instantiate()
	head.move_speed = start_speed #  Apply the calculated speed to the real head instance.
	head.main = self
	add_child(head)
	
	#--POSITION HEAD AND BODY--#
	var start_grid_pos = Vector2(grid_width / 2, grid_height / 2)
	head.position = (start_grid_pos * tile_size) + tile_offset
	
	var behind_direction = -head.current_direction
	for i in range(initial_snake_length - 1):
		var grid_pos = (start_grid_pos + (behind_direction * (i + 1)))
		var segment_pos = (grid_pos * tile_size) + tile_offset
		add_body_segment_at(segment_pos)
	
	trail_pieces.clear()
	# --- CONNECT SIGNALS ---
	head.moved.connect(on_snake_head_moved)
	head.ate_fruit.connect(on_snake_ate_food)
	head.hit_self.connect(game_over)
	#-------MENUS AND TRANSITION SIGNALS------#
	$UI/UpgradeMenu.main_game = self
	$PauseMenu.resume_game.connect(toggle_pause)
	$UI/GameOverScreen.restart_pressed.connect(_on_restart_pressed)
	$UI/GameOverScreen.quit_to_menu_pressed.connect(_on_quit_to_menu_pressed)
	$UI/UpgradeMenu.upgrade_selected.connect(_on_upgrade_menu_upgrade_selected)
	$UI/UpgradeMenu.resume_game_pressed.connect(_on_upgrade_menu_resume_game_pressed)
	SceneTransition.transition_finished.connect(_on_transition_finished)
	# --- FINAL SETUP ---#
	#-----SET OBSTACLSE-----#
	var obstacle_count = GameManager.garden_data[GameManager.current_garden]["obstacle_count"]
	for i in range(obstacle_count):
		spawn_rock()
	#------SPAWN FRUITS----#
	for i in range(GameManager.max_fruits_on_screen):
		update_fruit_prediction()
		spawn_fruit()
	
	update_fruit_prediction()
	
	time_since_last_fruit = 0.0
	GameManager.fruits_eaten_this_run = 0

	
	# --- FINAL SETUP & START ---
	update_score_display()
	update_hud()
	apply_persistent_upgrades() # Removed head_timer.start() here
	
func _process(delta):
	# First, check for a "hard pause". If the tree is paused, do nothing at all.
	if get_tree().paused:
		return

	# 1. The snake's movement timer is NOT stopped (i.e., we are actively playing).
	# 2. The upgrade menu is currently visible on screen.
	if not head.move_timer.is_stopped() or $UI/UpgradeMenu.visible:
		# If either of those is true, the clock runs.
		GameManager.run_time += delta
		time_since_last_fruit += delta # Also increment our new timer
		
		# --- Run Timer Display ---
		var minutes = int(GameManager.run_time / 60)
		var seconds = int(GameManager.run_time) % 60
		var tenths = int(fmod(GameManager.run_time, 1.0) * 10)
		var time_string = ""
		if minutes > 0:
			time_string = "%d:%02d.%d" % [minutes, seconds, tenths]
		else:
			time_string = "%02d.%d" % [seconds, tenths]
		$UI/HUDContainer/StatsVbox/RunTimerLabel.text = "Run Time: " + time_string
		
		# --- NEW: Time Since Last Fruit Display ---
		$UI/HUDContainer/StatsVbox/TimeSinceLastFruitLabel.text = "Time Since Fruit: %.1f" % time_since_last_fruit

		# --- NEW: Fruits Per Minute (FPM) Display ---
		var fpm = 0.0
		if GameManager.run_time > 0: # Avoid division by zero at the start
			fpm = (GameManager.fruits_eaten_this_run / GameManager.run_time) * 60.0
		$UI/HUDContainer/StatsVbox/FPMLabel.text = "FPM: %.1f" % fpm

	# The trail logic is separate. It should ONLY run when the snake is actively moving.
	if not head.move_timer.is_stopped():
		# Handle the trail fading logic
		for i in range(trail_pieces.size() - 1, -1, -1):
			var piece = trail_pieces[i]
			piece.time_left -= delta
			piece.node.color.a = piece.time_left / 5.0 
			if piece.time_left <= 0:
				piece.node.queue_free()
				trail_pieces.remove_at(i)
	
	if GameManager.fruit_foresight_unlocked and is_instance_valid(ghost_fruit_instance):
		if positions_are_equal(head.global_position, ghost_fruit_instance.position):
			print("Snake occupied ghost spot! Finding new spot!")
			update_fruit_prediction()
			
	if not head.move_timer.is_stopped():
		var gardener_level = GameManager.patient_gardener_level
		if gardener_level > 0:
			# Loop through all fruits on screen
			for fruit in get_tree().get_nodes_in_group("fruits"):
				# We now check if the fruit has a "ripen" method. Both Fruit and GoldenFruit do.
				if fruit.has_method("ripen") and not fruit.is_ripe and fruit.time_left_to_ripen > 0:
					fruit.time_left_to_ripen -= delta
					if fruit.time_left_to_ripen <= 0:
						fruit.ripen()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_game_over:
		toggle_pause()
	if event.is_action_pressed("show_hud"):
		var tween = create_tween()
		tween.tween_property($UI/HUDContainer, "modulate:a", 1.0, 0.2)
	elif event.is_action_released("show_hud"):
		var tween = create_tween()
		tween.tween_property($UI/HUDContainer, "modulate:a", 0.1, 1.0)

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

func apply_persistent_upgrades():
	# Re-apply speed upgrades
	for i in range(GameManager.slither_sauce_level):
		if head.move_timer.wait_time > 0.05:
			var speed_mod = GameManager.class_data[GameManager.chosen_class]["speed_upgrade_mod"]
			head.move_timer.wait_time *= speed_mod

func show_upgrade_menu():
	head.move_timer.stop()
	
	$UI/UpgradeMenu.set_initial_state_and_update()

	$UI/UpgradeMenu.update_all_displays()

	$UI/UpgradeMenu.visible = true


func show_garden_complete_screen():
	head.move_timer.stop()
	var garden_id = GameManager.current_garden
	var garden_name = GameManager.garden_data[garden_id]["name"]
	var score = snake_body_segments.size() + 1
	var is_final_garden = (garden_id == 5)
	var is_final_win = (is_final_garden and score >= 666)
	
	$UI/GardenCompleteScreen.setup(garden_name, score, is_final_garden, is_final_win)
	$UI/GardenCompleteScreen.visible = true


func show_ghost_fruit():
	# Remove any old ghost
	if is_instance_valid(ghost_fruit_instance):
		ghost_fruit_instance.queue_free()
	
	# Check if we have the upgrade
	if GameManager.fruit_foresight_unlocked:
		ghost_fruit_instance = preload("res://Scenes/ghost_fruit.tscn").instantiate()
		# Find a safe spot for the GHOST and place it there.
		ghost_fruit_instance.position = next_fruit_position
		call_deferred("add_child", ghost_fruit_instance)

func update_hud():
	# Update Level
	$UI/HUDContainer/BottomGrid/LevelLabel.text = "Level: " + str(GameManager.player_level)

	# Update Progress Bar
	var current_score = snake_body_segments.size() + 1
	var xp_bar = $UI/HUDContainer/BottomGrid/XPProgressBar
	
	# Set range for the bar
	xp_bar.max_value = GameManager.score_needed_for_next_level
	# The bar starts at the previous goal!
	xp_bar.min_value = GameManager.score_at_level_start
	
	# Set the Bar's current fill value
	xp_bar.value = current_score
	# Update values for selected class, difficulty, and which garden currently on
	$UI/HUDContainer/BottomGrid/GardenGoalLabel.text = "Garden Goal: " + str(GameManager.garden_data[GameManager.current_garden]["score_goal"])
	$UI/HUDContainer/BottomGrid/HUDSPLabel.text = "SP: " + str(GameManager.skill_points)
	$UI/HUDContainer/BottomGrid/GardenCurrentNumberLabel.text = "Garden %s/5" % GameManager.current_garden
	$UI/HUDContainer/BottomGrid/GardenCurrentNameLabel.text = "\"" + GameManager.garden_data[GameManager.current_garden]["name"] + "\""
	#---------Stats Vbox-------#
	$UI/HUDContainer/StatsVbox/LivesLabel.text = "Lives: " + str(GameManager.extra_lives)
	$UI/HUDContainer/StatsVbox/FriutRewardLabel.text = "Growth: " + str(GameManager.fruit_reward)
	$UI/HUDContainer/StatsVbox/MaxFruitsLabel.text = "# of fruits: " + str(GameManager.max_fruits_on_screen)
	
		#------------ABILITY LABELS----------#
	var burrow_label = $UI/HUDContainer/StatsVbox/AbilitySlot1
	if GameManager.burrow_level > 0:
		burrow_label.visible = true
		burrow_label.text = "Burrow Charges (space): " + str(GameManager.burrow_charges)
	else:
		burrow_label.visible = false
	var phase_label = $UI/HUDContainer/StatsVbox/AbilitySlot2
	if GameManager.phase_shift_level > 0:
		phase_label.visible = true
		phase_label.text = "Phase Charges (e): " + str(GameManager.phase_shift_charges)
	else:
		phase_label.visible = false
	var meditate_label = $UI/HUDContainer/StatsVbox/AbilitySlot3
	if GameManager.meditative_state_level > 0:
		meditate_label.visible = true
		meditate_label.text = "Meditate Charges (r): " + str(GameManager.meditative_state_charges)
	else:
		meditate_label.visible = false
	var banana_bounty_label = $UI/HUDContainer/StatsVbox/AbilitySlot4
	if GameManager.banana_bounty_level > 0:
		banana_bounty_label.visible = true
		banana_bounty_label.text = "Banana Bounty (f): " + str(GameManager.banana_bounty_charges)
	else:
		banana_bounty_label.visible = false
	var tenderizer_label = $UI/HUDContainer/StatsVbox/AbilitySlot5
	if GameManager.tenderizer_level > 0:
		tenderizer_label.visible = true
		tenderizer_label.text = "Tender Charges: " + str(GameManager.tenderizer_charges)
	else:
		tenderizer_label.visible = false

	
	

func update_fruit_prediction():
	next_fruit_position = calculate_safe_spawn_position()
	show_ghost_fruit()

func _on_quit_to_menu_pressed():
	get_tree().paused = false
	SceneTransition.transition_to("res://Scenes/main_menu.tscn")

func on_snake_head_moved(head_previous_position: Vector2):
	if snake_body_segments.is_empty():
		# If there's no body, we can't get a tail position, so we just move the trail
		# from the head's old spot for this one special case.
		if GameManager.sovereign_trail_level > 0:
			spawn_trail_piece(head_previous_position)
		return
		
	var tail_previous_position = snake_body_segments.back().global_position	
	
	# Classic "follow-the-leader" movement logic
	var target_position = head_previous_position
	for segment in snake_body_segments:
		var old_position = segment.global_position
		segment.global_position = target_position
		target_position = old_position
	
	#----------SOVEREIGN TRAIL SHIT----------#
	if GameManager.sovereign_trail_level > 0:
		spawn_trail_piece(tail_previous_position)

	update_tail_visuals()
	
	if upgrade_menu_is_pending:
		#menu is pending
		upgrade_menu_is_pending = false # Reset the flag
		show_upgrade_menu()				# Now we show the menu
		
func spawn_fruit():
	var fruit = null
	var current_gs_level = GameManager.golden_seeds_level
	
	if current_gs_level > 0 and randf() < GameManager.golden_seeds_data[current_gs_level]["chance"]:
		fruit = preload("res://Scenes/golden_fruit.tscn").instantiate()
	else:
		fruit = fruit_scene.instantiate()
	
	# Add to group so we can check against it
	fruit.add_to_group("fruits") 
	# Find a safe spot NOW and place it there.
	fruit.position = next_fruit_position
	call_deferred("add_child", fruit)
	print("Fruit spawned at a guaranteed safe location.")

func destroy_obstacle(obstacle_node):
	# This function safely removes a rock from the game.
	
	# 1. Remove it from our tracking array so fruit can spawn here.
	spawned_obstacles.erase(obstacle_node)
	
	# 2. Add a cool effect, like making it shrink away.
	var tween = create_tween()
	tween.tween_property(obstacle_node, "scale", Vector2.ZERO, 0.2)
	# After the animation is done, delete the node for good.
	tween.tween_callback(obstacle_node.queue_free)


func spawn_rock():
	var rock = rock_scene.instantiate()
	var potential_position: Vector2
	var is_safe_position: bool = false
	
	while not is_safe_position:
		var x_pos = randi() % grid_width
		var y_pos = randi() % grid_height
		var random_grid_pos = Vector2(x_pos, y_pos)
		potential_position = (random_grid_pos * tile_size) + tile_offset
		
		# SAFETY CHECK
		var is_on_snake = is_position_occupied(potential_position) or positions_are_equal(potential_position, head.global_position)
		var is_on_another_rock = false
		for placed_rock in spawned_obstacles:
			if positions_are_equal(potential_position, placed_rock.position):
				is_on_another_rock = true
				break
		if not is_on_snake and not is_on_another_rock:
			is_safe_position = true
	
	var gray_value = randf_range(0.4, 0.7) # A random decimal between 0.4 (darker) and 0.7 (lighter)
	var random_gray_color = Color(gray_value, gray_value, gray_value)
	rock.get_node("FillSprite").modulate = random_gray_color
	
	
	rock.position = potential_position
	spawned_obstacles.append(rock)
	add_child(rock)

func spawn_trail_piece(position: Vector2):
	var trail_piece = ColorRect.new()
	trail_piece.color = Color("LIGHT_CYAN", 0.3)
	trail_piece.size = Vector2(tile_size, tile_size)
	# We subtract the offset because a ColorRect's origin is its top-left.
	trail_piece.position = position - tile_offset
	
	$TrailContainer.add_child(trail_piece)
	trail_pieces.append({"node": trail_piece, "time_left": 5.0})

func grow_snake(segments_to_add: int):
	print("Growing snake by %s segments." % segments_to_add)
	
	# Loop for the specified number of times
	for i in range(segments_to_add):
		var new_segment_position: Vector2
		
		# This logic for finding the position is still perfect.
		if snake_body_segments.is_empty() and i == 0:
			new_segment_position = head.global_position - (head.current_direction * tile_size)
		else:
			var current_tail = snake_body_segments.back()
			new_segment_position = current_tail.global_position
			
		var new_segment = create_colored_segment(new_segment_position)
		call_deferred("add_child", new_segment)
		snake_body_segments.append(new_segment)

	# We only update the score display once at the very end.
	update_score_display()

func update_progression():
	
	var current_score = snake_body_segments.size() + 1
	# Level Up Check
	var leveled_up_this_frame = false # Flag to check for multi-leveling in one fruit grab
	
	while current_score >= GameManager.score_needed_for_next_level:
		print("Level Up! Score is: ", current_score)
		# Award level and skill point(s)
		level_up()
		# Set a flag to know we should show the menu at a "later" time
		leveled_up_this_frame = true
	# After looping through this while loop, if we level up, set the flag that is waiting
	if leveled_up_this_frame:
		upgrade_menu_is_pending = true
	
	# Garden Completion Check
	var current_garden_id = GameManager.current_garden
	var current_goal = GameManager.garden_data[current_garden_id]["score_goal"]
	if current_score >= current_goal:
		#Beat the garden
		print("Garden ", current_garden_id, " complete! Pending screen.")
		#Show garden function coming soon
		garden_complete_is_pending = true

func level_up():
	print("Level up!")
	#Before we calculate the next goal, we need to save the current one
	GameManager.score_at_level_start = GameManager.score_needed_for_next_level
	
	GameManager.player_level += 1
	
	#SP SCALE
	if GameManager.chosen_class != "the_alchemist":
		if GameManager.player_level >= 10:
			GameManager.skill_points += 3
			GameManager.total_sp_this_run += 3
		elif GameManager.player_level >= 5:
			GameManager.skill_points += 2
			GameManager.total_sp_this_run += 2
		else:
			GameManager.skill_points += 1
			GameManager.total_sp_this_run += 1
	#EXP/SCORE SCALE
	if GameManager.player_level >= 10:
		GameManager.score_needed_for_next_level += 15
	elif GameManager.player_level >= 5:
		GameManager.score_needed_for_next_level += 10
	else:
		GameManager.score_needed_for_next_level += 5
	#RECHARGE BURROW IF UNLOCKED
	if GameManager.burrow_level > 0:
		GameManager.burrow_charges = GameManager.burrow_level
	if GameManager.phase_shift_level > 0:
		GameManager.phase_shift_charges = GameManager.phase_shift_level
	if GameManager.meditative_state_level > 0:
		GameManager.meditative_state_charges = GameManager.meditative_state_level
	if GameManager.banana_bounty_level > 0:
		GameManager.banana_bounty_charges = GameManager.banana_bounty_level
	if GameManager.tenderizer_level > 0:
		GameManager.tenderizer_charges = GameManager.tenderizer_level

func _on_upgrade_menu_resume_game_pressed():
	$UI/UpgradeMenu.visible = false
	if garden_complete_is_pending:
		# if yes, show garden screen instead of resuming
		garden_complete_is_pending = false
		show_garden_complete_screen()
	else:
		# Resume Game if no
		head.move_timer.start()
		update_hud()
	

func _on_upgrade_menu_upgrade_selected(upgrade_name):
	print("Player chose upgrade: ", upgrade_name)
	# Upgrades implemented: Speed and Fruit Reward
	#-------------Glutton----------------#
		#---ESP---#
	if upgrade_name == "elephant_sized_portions":
		GameManager.es_portions_level += 1
		GameManager.fruit_reward += 1 * GameManager.class_data[GameManager.chosen_class]["reward_upgrade_mod"]
		print("ESP bought! New Fruit Reward: ", GameManager.fruit_reward)
		#---More Mice---#
	elif upgrade_name == "more_mice":
			if GameManager.more_mice_level < 6: # Your max level
				GameManager.max_fruits_on_screen += 1
				GameManager.more_mice_level += 1
				
				# Instead of just spawning one fruit, we now check how many are
				# on screen vs. how many SHOULD be, and spawn the difference.
				var current_fruit_count = get_tree().get_nodes_in_group("fruits").size()
				var target_fruit_count = GameManager.max_fruits_on_screen
				var fruits_to_spawn = target_fruit_count - current_fruit_count
				
				print("Player bought More Mice! Spawning %s new fruit." % fruits_to_spawn)

				# This loop ensures that even if we spawn multiple fruits in the same frame,
				# they won't spawn on top of each other.
				var pending_positions = []
				for i in range(fruits_to_spawn):
					var new_pos = calculate_safe_spawn_position(pending_positions)
					var fruit = fruit_scene.instantiate()
					fruit.position = new_pos
					fruit.add_to_group("fruits")
					# Because we are in a UI callback, NOT a physics callback,
					# it's safe to use add_child() directly here.
					add_child(fruit) 
					pending_positions.append(new_pos)
				
				# Update the ghost fruit prediction now that the board has changed.
				update_fruit_prediction()
		#---golden seeds----#
	elif upgrade_name == "golden_seeds":
		if GameManager.golden_seeds_level < 4:
			GameManager.golden_seeds_level += 1
		#-----patient gardener----#
	elif upgrade_name == "patient_gardener":
		if GameManager.patient_gardener_level < 3:
			GameManager.patient_gardener_level += 1
		#----banana bounty---#
	elif upgrade_name == "banana_bounty":
		if GameManager.banana_bounty_level < 2:
			GameManager.banana_bounty_level += 1
			GameManager.banana_bounty_charges += 1
			print("Banana Bounty charge: +1! Now: ", GameManager.banana_bounty_level, " charge(s)")
		#-----the satchel------#
	elif upgrade_name == "the_satchel":
		if not GameManager.the_satchel_unlocked:
			GameManager.the_satchel_unlocked = true
	#------------ACROBAT---------------#
	elif upgrade_name == "Slither Sauce":
		if GameManager.slither_sauce_level < 10:
			GameManager.slither_sauce_level += 1
			apply_persistent_upgrades()
	elif upgrade_name == "Tenderizer":
		if GameManager.tenderizer_level < 3:
			GameManager.tenderizer_charges += 1
			GameManager.tenderizer_level += 1
	elif upgrade_name == "Juke & Jive":
		if not GameManager.juke_and_jive_unlocked:
			GameManager.juke_and_jive_unlocked = true
	elif upgrade_name == "Afterburner":
		if GameManager.afterburner_level < 3:
			GameManager.afterburner_level += 1
	elif upgrade_name == "Pop Rocks":
		if not GameManager.pop_rocks_unlocked:
			GameManager.pop_rocks_unlocked = true
	elif upgrade_name == "Autotomy":
		if not GameManager.autotomy_unlocked:
			GameManager.autotomy_unlocked = true
	# Increase Grid Size Upgrade Logic
	elif upgrade_name == "increase_grid_size":
		if GameManager.grid_size_level < 4:
			GameManager.grid_size_level += 1
			update_boundary_visuals()
			print("New grid size: (l x w): ", GameManager.grid_size_data[GameManager.grid_size_level])
	# Burrow Ability Upgrade Logic 
	elif upgrade_name == "increase_burrow_charges":
		GameManager.burrow_level += 1
		GameManager.burrow_charges += 1
		print("Burrow Charge + 1!")
	# Phase Shift Ability Upgrade Logic
	elif upgrade_name == "increase_phase_charges":
		GameManager.phase_shift_level += 1
		GameManager.phase_shift_charges += 1
		print("Phase Shift Charge + 1!")
	elif upgrade_name == "buy_extra_life":
		GameManager.extra_lives += 1
	#-----------THE PLANNER--------#
	elif upgrade_name == "diet_slith":
		if GameManager.diet_slith_level < 5:
			GameManager.diet_slith_level += 1
			head.move_timer.wait_time *= 1.1 
			print("SNAKE SLOWED! New wait time: ", head.move_timer.wait_time)
	elif upgrade_name == "fruit_foresight":
		if not GameManager.fruit_foresight_unlocked:
			GameManager.fruit_foresight_unlocked = true
			show_ghost_fruit()
	elif upgrade_name == "ghost_tail":
		if GameManager.ghost_tail_level < 3:
			GameManager.ghost_tail_level += 1
			print("Ghost Tail Upgraded! New ghost length: ", GameManager.ghost_tail_data[GameManager.ghost_tail_level])
	elif upgrade_name == "sovereign_trail":
		if GameManager.sovereign_trail_level < 2:
			GameManager.sovereign_trail_level += 1
			print("Sovereign Trail Upgraded 1 level!")
	elif upgrade_name == "meditative_state":
		if GameManager.meditative_state_level < 2:
			GameManager.meditative_state_level += 1
			GameManager.meditative_state_charges += 1
			print("Meditative State Upgraded. New pause time: ", GameManager.meditative_data[GameManager.meditative_state_level])
			print("Meditative State Upgraded. New pause charges: ", GameManager.meditative_state_charges)
	elif upgrade_name == "garden_weaver":
		if not GameManager.garden_weaver_unlocked:
			GameManager.garden_weaver_unlocked = true
			
			
		
	#_on_upgrade_menu_resume_game_pressed() #This is in case you want to get thrown in

func on_snake_ate_food(fruit):
	print("Snake ate food!")
	
	var segments_to_add = 0
	var sp_reward = 0
	
	var was_bounty_target = fruit.is_bounty_target
	
	# --- Check for all fruit states ---
	if was_bounty_target:
		# SUCCESS: You ate the correct fruit.
		print("BOUNTY COLLECTED!")
		segments_to_add = GameManager.max_fruits_on_screen * GameManager.fruit_reward
		GameManager.is_bounty_active = false
	elif GameManager.is_bounty_active:
		# FAILURE: You ate the wrong fruit. Cancel the bounty.
		print("Wrong fruit! Bounty cancelled.")
		GameManager.is_bounty_active = false
		for f in get_tree().get_nodes_in_group("fruits"):
			if f.is_bounty_target:
				# Reset the old target's visuals
				if is_instance_valid(f.active_tween): f.active_tween.kill()
				f.is_bounty_target = false
				f.scale = Vector2(1, 1)
				f.get_node("FillSprite").modulate = Color.GOLD if f is GoldenFruit else Color.RED
				break
		segments_to_add = GameManager.fruit_reward
	else:
		# If no bounty is active, calculate rewards normally.
		var growth_multiplier = 1
		if fruit is GoldenFruit:
			sp_reward = GameManager.golden_seeds_data[GameManager.golden_seeds_level]["reward"]
			if fruit.is_ripe:
				growth_multiplier = GameManager.patient_gardener_data[GameManager.patient_gardener_level]["multiplier"]
				sp_reward += 1
		elif fruit.has_method("ripen") and fruit.is_ripe:
			growth_multiplier = GameManager.patient_gardener_data[GameManager.patient_gardener_level]["multiplier"]
		segments_to_add = GameManager.fruit_reward * growth_multiplier

	# --- Apply rewards ---
	GameManager.skill_points += sp_reward
	grow_snake(segments_to_add)
	
	# --- Cleanup and Respawning ---
	if was_bounty_target:
		# --- THIS IS THE FIX ---
		# If it was a bounty, kill ALL tweens before clearing the board.
		for f in get_tree().get_nodes_in_group("fruits"):
			if is_instance_valid(f.active_tween):
				f.active_tween.kill()
			f.queue_free()
		# Now it's safe to respawn everything.
		for i in range(GameManager.max_fruits_on_screen):
			spawn_fruit()
	else:
		# Otherwise, just kill the tween on the one fruit that was eaten.
		if is_instance_valid(fruit.active_tween):
			fruit.active_tween.kill()
		fruit.queue_free()
		spawn_fruit()

	# --- Final updates ---
	update_fruit_prediction()
	update_progression()
	update_hud()
	
	if head.can_reverse:
		head.can_reverse = false


func calculate_safe_spawn_position(additional_unsafe_positions: Array = []) -> Vector2:
	var potential_position: Vector2
	var is_safe_position = false
	var trail_level = GameManager.sovereign_trail_level

	var attempt_counter = 0

	while not is_safe_position:
		attempt_counter += 1
		if attempt_counter > 5000:
			print_debug("ERROR: Could not find a safe spawn position. Grid is full.")
			return Vector2(-100, -100) #spawn off screen
		var random_grid_pos: Vector2i
		
		# --- Logic to pick a random spot (including trail bonus) ---
		if trail_level == 2 and not trail_pieces.is_empty() and randf() < 0.7:
			var random_trail_piece = trail_pieces.pick_random()
			var trail_grid_pos = Vector2i((random_trail_piece.node.position + tile_offset) / tile_size)
			var offset = Vector2i(randi_range(-2, 2), randi_range(-2, 2))
			var calculated_grid_pos = trail_grid_pos + offset
			random_grid_pos.x = clamp(calculated_grid_pos.x, 0, grid_width - 1)
			random_grid_pos.y = clamp(calculated_grid_pos.y, 0, grid_height - 1)
		else:
			random_grid_pos = Vector2i(randi() % grid_width, randi() % grid_height)

		potential_position = (Vector2(random_grid_pos) * tile_size) + tile_offset

		# --- Full Safety Check ---
		var is_on_snake = is_any_body_part_at(potential_position) or positions_are_equal(potential_position, head.global_position)
		
		var is_on_obstacle = false
		for obstacle in spawned_obstacles:
			if positions_are_equal(potential_position, obstacle.position):
				is_on_obstacle = true
				break
		
		var is_on_another_fruit = false
		for fruit in get_tree().get_nodes_in_group("fruits"):
			if positions_are_equal(potential_position, fruit.position):
				is_on_another_fruit = true
				break
		
		var is_on_trail = false
		if trail_level == 1:
			for piece in trail_pieces:
				if positions_are_equal(potential_position, piece.node.position + tile_offset):
					is_on_trail = true
					break
		
		var is_on_pending_spot = false
		for pos in additional_unsafe_positions:
			if positions_are_equal(potential_position, pos):
				is_on_pending_spot = true
				break
		
		# A spot is safe only if ALL checks are false.
		if not is_on_snake and not is_on_obstacle and not is_on_another_fruit and not is_on_trail and not is_on_pending_spot:
			is_safe_position = true
			
	return potential_position

func is_any_body_part_at(check_pos: Vector2) -> bool:
	# This function ignores ghost rules and just checks every segment.
	for segment in snake_body_segments:
		if positions_are_equal(segment.global_position, check_pos):
			return true # Found a body part here.
	return false # No parts found.

func add_body_segment_at(position: Vector2):
	var new_segment = create_colored_segment(position)
	add_child(new_segment)
	snake_body_segments.append(new_segment)
	
func game_over():
	if GameManager.extra_lives > 0:
		use_extra_life()
	else:
		is_game_over = true
		head.move_timer.stop()
		print("Game Over!")
		$UI/GameOverScreen.visible = true
		var final_score = snake_body_segments.size() + 1
		game_is_over.emit(final_score)

func use_extra_life():
	GameManager.has_died_this_garden = true
	print("Used an extra life!")
	
	# 1. Stop the snake and start the fade to black
	head.move_timer.stop()
	await SceneTransition.cover_screen()

	# 2. While the screen is black, safely reset everything
	GameManager.extra_lives -= 1
	update_hud()
	
	while snake_body_segments.size() > 0:
		var segment_to_remove = snake_body_segments.pop_back()
		segment_to_remove.queue_free()
	
	var start_grid_pos = Vector2(grid_width / 2, grid_height / 2)
	head.position = (start_grid_pos * tile_size) + tile_offset
	on_snake_head_moved(head.position)
	
	# 3. Give a moment of invincibility
	GameManager.is_phasing = true
	head.get_node("PhaseTimer").start()
	head.get_node("FillSprite").modulate = Color.GOLD
	
	# 4. Now that everything is reset, fade the screen back in
	await SceneTransition.uncover_screen()
	
	# 5. Start the countdown
	start_countdown()


func update_score_display():
	var score = (snake_body_segments.size() + 1)
	$UI/HUDContainer/BottomGrid/ScoreLabel.text = "Score: " + str(score)

	
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
	# Get how many segments at the end of the tail should be ghosts.
	var ghost_segment_count = GameManager.ghost_tail_data[GameManager.ghost_tail_level]
	var total_segments = snake_body_segments.size()
	
	# Calculate how many segments at the front are solid.
	var solid_segment_count = total_segments - ghost_segment_count
	
	# Only loop through the SOLID segments at the front of the snake.
	# The 'range()' function stops *before* the number, so this is correct.
	for i in range(solid_segment_count):
		var segment = snake_body_segments[i]
		if positions_are_equal(segment.global_position, check_pos):
			return true # We hit a solid part!
			
	# If the loop finishes, it means we only checked solid parts and found nothing.
	# Therefore, the position is safe (it's either empty or a ghost).
	return false

func is_position_out_of_bounds(check_pos: Vector2) -> bool:
	var grid_pos = (check_pos / tile_size).round()
	if grid_pos.x < 0 or grid_pos.x > grid_width or \
	   grid_pos.y < 0 or grid_pos.y > grid_height:
		return true
	return false

func start_countdown() -> void:
	var countdown = $UI/CountdownLabel
	countdown.visible = true
	# START THE COUNTDOWN
	countdown.text = "3"
	await get_tree().create_timer(1.0).timeout
	countdown.text = "2"
	await get_tree().create_timer(1.0).timeout
	countdown.text = "1"
	await get_tree().create_timer(1.0).timeout
	# GIVE THE GAME SOME PERSONALITY AND RANDOMNESS
	var go_messages = ["SNAKE OFF!", "GET GROWING", "FEED THE BEAST!"]
	countdown.text = go_messages.pick_random()
	await get_tree().create_timer(1.0).timeout
	# HIDE THE LABEL AND START THE GAME!
	countdown.visible = false
	if is_instance_valid(head) and head.move_timer:
		head.move_timer.start()
func _on_restart_pressed():
	GameManager.start_game()

func _on_transition_finished():
	print("Transition Finished, starting game!")
	if is_instance_valid(head) and head.move_timer:
		start_countdown()

func _on_garden_complete_continue_pressed() -> void:
	var garden_id = GameManager.current_garden
	var score = snake_body_segments.size() + 1
	if garden_id == 5 and score >= 666:
		SceneTransition.transition_to("res://Scenes/main_menu.tscn")
	elif garden_id == 5:
		SceneTransition.transition_to("res://Scenes/main_menu.tscn")
	else:
		GameManager.current_garden += 1
		SceneTransition.transition_to("res://Scenes/main.tscn")
		
	var p_class = GameManager.chosen_class
	
	# Check if we are a Zealot AND we haven't died this garden
	if p_class == "the_zealot" and not GameManager.has_died_this_garden:
		# If so, award the bonus SP
		var bonus_sp = GameManager.class_data[p_class]["sp_on_perfect_garden"]
		print("ZEALOT BONUS! +", bonus_sp, " SP for a perfect run!")
		GameManager.skill_points += bonus_sp

func update_boundary_visuals():
	var current_grid_size = GameManager.grid_size_data[GameManager.grid_size_level]
	grid_width = int(current_grid_size.x)
	grid_height = int(current_grid_size.y)
	
	var boundary_container = $BoundaryIndicator
	boundary_container.size = Vector2(grid_width * tile_size, grid_height * tile_size)

func update_tail_visuals():
	var ghost_segment_count = GameManager.ghost_tail_data[GameManager.ghost_tail_level]
	var total_segments = snake_body_segments.size()
	var ghost_color = Color("AFEEEE80") # transparent, pale turquoise

	# Loop through all segments and set their state
	for i in range(total_segments):
		var segment = snake_body_segments[i]
		# Get references to the nodes we need to change
		var fill_sprite = segment.get_node_or_null("FillSprite")
		var collision_shape = segment.get_node_or_null("CollisionShape2D")

		# This check is crucial to prevent crashes if a node is missing
		if not is_instance_valid(fill_sprite) or not is_instance_valid(collision_shape):
			continue

		# Check if this segment should be a ghost using the same logic as our collision check
		var is_ghost = (i >= total_segments - ghost_segment_count)
		
		if is_ghost:
			# --- GHOST STATE ---
			fill_sprite.modulate = ghost_color
			# Tell the physics engine to ignore this segment
			collision_shape.disabled = true
		else:
			# --- SOLID STATE ---
			# Restore its original color based on the consistent pattern
			# This must match your create_colored_segment function!
			if (i + 2) % 5 == 0:
				fill_sprite.modulate = Color("BA8E23") # Dark Yellow
			else:
				fill_sprite.modulate = Color("8A00C4") # Purple-neon
			# Tell the physics engine to make it solid again
			collision_shape.disabled = false

func perform_garden_weave():
	print("GARDEN WEAVER ACTIVATED!")
	
	GameManager.garden_weaver_used_this_garden = true
	update_hud()

	# 1. Get a list of all current fruit nodes.
	var fruit_nodes = get_tree().get_nodes_in_group("fruits")
	
	# 2. This array will keep track of the new positions we've chosen
	#    to prevent spawning two fruits in the same new spot.
	var new_positions = []

	# 3. Loop through each existing fruit and give it a new home.
	for fruit in fruit_nodes:
		# We find a new safe position, making sure to avoid spots
		# we've already assigned to other fruits in this same frame.
		var new_pos = calculate_safe_spawn_position(new_positions)
		fruit.position = new_pos
		new_positions.append(new_pos) # Add this spot to our list of claimed spots

	# 4. Now that all real fruit have been moved, update the ghost's prediction.
	update_fruit_prediction()

func activate_banana_bounty():
	var all_fruits = get_tree().get_nodes_in_group("fruits")
	if all_fruits.is_empty():
		return

	print("BANANA BOUNTY ACTIVATED!")
	GameManager.is_bounty_active = true
	GameManager.banana_bounty_charges -= 1
	update_hud()

	var target_fruit = all_fruits.pick_random()
	target_fruit.is_bounty_target = true
	
	# Before creating a new tween, kill any old one (like a ripen tween).
	if is_instance_valid(target_fruit.active_tween):
		target_fruit.active_tween.kill()

	# Create the new tween animation
	var tween = create_tween().set_loops()
	tween.tween_property(target_fruit, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(target_fruit, "scale", Vector2(1.0, 1.0), 0.3)
	target_fruit.get_node("FillSprite").modulate = Color.GOLD
	
	# Store a reference to this new tween
	target_fruit.active_tween = tween
