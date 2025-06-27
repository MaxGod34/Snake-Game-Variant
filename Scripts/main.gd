extends Node2D

@export var initial_snake_length: int = 1
@export var tile_size: int = 32


# Grid properties, including offset due to centering of the blocks
var tile_offset: Vector2
var grid_width: int
var grid_height: int


# Boolean Flags
var is_game_over: bool = false
var garden_complete_is_pending: bool = false
var upgrade_menu_is_pending: bool = false

var snake_body_segments: Array[Node2D] = []
var head: CharacterBody2D
var trail_pieces: Array = []

var growth_history: Array = []

var growth_progress: float = 0.0

var spawned_obstacles: Array = []
var next_fruit_position: Vector2
var ghost_fruit_instance = null


var time_since_last_fruit: float = 0.0
@onready var last_fruit_label = $UI/MarginContainer/HBoxContainer/InformationPanel.get_node("HBoxContainer/GardenDataContainer/FrenzyMeter/ComboWindowLabel")



var head_scene = preload("res://Scenes/Snake/snake_head.tscn")
var body_scene = preload("res://Scenes/Snake/snake_body.tscn")
var fruit_scene = preload("res://Scenes/Fruits/fruit.tscn")

var jumping_bean_scene = preload("res://Scenes/Fruits/jumping_bean.tscn")
var ghost_pepper_scene = preload("res://Scenes/Fruits/ghost_pepper.tscn")
var iron_cherry_scene = preload("res://Scenes/Fruits/iron_cherry.tscn")
var dragon_fruit_scene = preload("res://Scenes/Fruits/dragon_fruit.tscn")
var rock_scene = preload("res://Scenes/rock.tscn")
var pause_scene = preload("res://Scenes/Menus/pause_menu.tscn")
var trippy_grid_shader = preload("res://trippy_grid.gdshader")
var exclamation_scene = preload("res://Scenes/Snake/exclamation.tscn")
var ability_slot_scene = preload("res://Scenes/UI/ability_slot.tscn")


@onready var combo_timer = $ComboTimer
@onready var boundary_indicator = $BoundaryIndicator
@onready var background_rect = $"Background-Color-Rect" 
@onready var dividing_wall_tilemap = $DividingWallTileMap
@onready var camera = $Camera2D
var current_camera_quadrant: int = 0

@onready var iron_cherry_buff_timer = $IronCherryBuffTimer
@onready var dragon_fruit_buff_timer = $DragonFruitBuffTimer

@onready var ability_hotbar = $UI/MarginContainer/HBoxContainer/VBoxContainer/AbilityHotbar
@onready var player_banner = $UI/MarginContainer/HBoxContainer/VBoxContainer/PlayerBanner
@onready var information_panel = $UI/MarginContainer/HBoxContainer/InformationPanel

#-------SIGNALS--------#

signal game_is_over(score)

func _ready():
	 # --- GAME SETUP ---
	rebuild_world_layout()
	GameManager.generate_full_spawn_queue()
	
	var difficulty = GameManager.chosen_difficulty
	var p_class = GameManager.chosen_class
	var diff_data = GameManager.difficulty_data[difficulty]
	var class_data = GameManager.class_data[p_class]
	
	GameManager.has_died_this_garden = false
	GameManager.garden_weaver_used_this_garden = false
	GameManager.fruits_eaten_this_run = 0
	
	initial_snake_length = class_data["start_length"]
	var start_speed = class_data["start_speed"] * diff_data["speed_multiplier"]
	
	
	
	# Bounds and Tile Offset cuz center origin omfg i'll kms
	tile_offset = Vector2(tile_size / 2.0, tile_size / 2.0)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(64, 0)
	#ability_hotbar.add_child(spacer)
	# This loop will create our 10 ability slots dynamically.
	for i in range(10):
		var slot = ability_slot_scene.instantiate()
		slot.slot_index = i
		slot.activated.connect(_on_ability_slot_activated)
		ability_hotbar.add_child(slot)
		# Set the hotkey label text (1, 2, ..., 9, 0)
		slot.get_node("HotkeyLabel").text = str((i + 1) % 10)
	
	$UI/PulpsicleStand.main_game = self
	
	# --- CREATE HEAD ---
	head = head_scene.instantiate()
	head.move_speed = start_speed #  Apply the calculated speed to the real head instance.
	head.main = self
	add_child(head)
	
	
	#--POSITION HEAD AND BODY--#
	var start_quadrant_center = Vector2(7,7)
	head.position = (start_quadrant_center * tile_size) + tile_offset
	
	current_camera_quadrant = 0
	
	move_camera_to_quadrant(0)
	
	var behind_direction = -head.current_direction
	for i in range(initial_snake_length - 1):
		var grid_pos = (start_quadrant_center + (behind_direction * (i + 1)))
		var segment_pos = (grid_pos * tile_size) + tile_offset
		add_body_segment_at(segment_pos)
	
	spawned_obstacles.clear()
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
	$UI/UpgradeMenu.resume_game_pressed.connect(_on_upgrade_menu_resume_game_pressed)
	SceneTransition.transition_finished.connect(_on_transition_finished)
	$UI/MarginContainer/HBoxContainer/VBoxContainer/PlayerBanner.floating_text_container = $UI/FloatingTextContainer
	$UI/PulpsicleStand.skip_garden_pressed.connect(_on_skip_garden_pressed)
	$UI/PulpsicleStand.continue_to_next_garden.connect(_on_pulpsicle_stand_continue_pressed)
	# --- FINAL SETUP ---#
	#-----SET OBSTACLSE-----#
	setup_initial_obstacles()
	#------SPAWN FRUITS----#
	for i in range(get_effective_max_fruits()):
		update_fruit_prediction()
		spawn_fruit(next_fruit_position)
	
	update_fruit_prediction()
	
	time_since_last_fruit = 0.0
	
	combo_timer.timeout.connect(_on_combo_timer_timeout)
	$ZenithTimer.timeout.connect(_on_zenith_timer_timeout)
	$FruitFloodTickTimer.timeout.connect(_on_fruit_flood_tick_timer_timeout)
	$FruitFloodDurationTimer.timeout.connect(_on_fruit_flood_duration_timer_timeout)
	iron_cherry_buff_timer.timeout.connect(_on_iron_cherry_buff_timer_timeout)
	dragon_fruit_buff_timer.timeout.connect(_on_dragon_fruit_buff_timer_timeout)
	# --- FINAL SETUP & START ---
	update_hud()
	update_upgrade_prompt()
	apply_persistent_upgrades() # Removed head_timer.start() here
	apply_cosmetic_upgrades()
	pick_new_recipe()
	
func _process(delta):
	# First, check for a "hard pause". If the tree is paused, do nothing at all.
	if get_tree().paused or is_game_over:
		return

	# 1. The snake's movement timer is NOT stopped (i.e., we are actively playing).
	# 2. The upgrade menu is currently visible on screen.
	if not head.move_timer.is_stopped():
		
		# --- NEW PASSIVE GROWTH ---
		# 1. First, calculate our current total GPS from all sources.
		_calculate_passive_gps()
		
		# 2. Add this frame's worth of growth to our progress tracker.
		growth_progress += GameManager.passive_gps * delta
		
		# 3. If we've accumulated at least one full segment of growth...
		if growth_progress >= 1.0:
			# Grow the snake by one segment.
			grow_snake(1)
			# Subtract 1 from the progress, leaving the remainder for the next frame.
			growth_progress -= 1.0
			#NOW we check for garden completion
			check_for_garden_completion()
		
		
		# If either of those is true, the clock runs.
		GameManager.run_time += delta
		time_since_last_fruit += delta # Also increment our new timer
		
		update_hud()

		
		# --- NEW JUGGERNAUT COMBO TIMER LOGIC ---
	
	
	if GameManager.sugar_rush_unlocked and not combo_timer.is_stopped():
		last_fruit_label.visible = true
		
		# --- THIS IS THE NEW JUGGERNAUT LOGIC ---
		# First, check if the timer should be paused.
		if GameManager.juggernaut_unlocked and GameManager.combo_is_pure:
			combo_timer.paused = true
			last_fruit_label.text = "COMBO LOCKED!" # Give cool feedback
		else:
			# Otherwise, make sure it's running.
			combo_timer.paused = false
			last_fruit_label.text = "Combo Window: %.1f" % combo_timer.time_left
	else:
		last_fruit_label.visible = false
		

		

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
		tween.tween_property($UI/MarginContainer, "modulate:a", 1.0, 0.2)
	elif event.is_action_released("show_hud"):
		var tween = create_tween()
		tween.tween_property($UI/MarginContainer, "modulate:a", 0.1, 1.0)
	if event.is_action_pressed("open_upgrade_menu"):
	# Check if the player has SP and the game is in an active state
		if GameManager.juice > 0 and not get_tree().paused and not is_game_over:
			# Call new transition/show menu function
			open_upgrade_menu_with_transition()
	for i in range(10):
		if event.is_action_pressed("activate_slot_" + str(i + 1)):
			_on_ability_slot_activated(i)



func _on_ability_slot_activated(slot_index: int):
	# Check if there's actually an ability in this slot
	if slot_index >= GameManager.equipped_abilities.size(): return # Slot is empty, do nothing

	var ability_key = GameManager.equipped_abilities[slot_index]
	
	var ability_data = GameManager.ability_charges.get(ability_key)
	
	# Check if we have charges for this ability
	if ability_data and ability_data.current > 0:
		# Check the "current" charge count
		if ability_data.current > 0:
			if ability_key == "Tenderizer":
				ability_data.current = ability_data.current
			else:
				GameManager.abilities_used_this_garden += 1
				# Subtract from the "current" charge count
				ability_data.current -= 1
		
		
		# Use a match statement to call the correct helper function
		match ability_key:
			"Burrow": activate_burrow()
			"Phase Shift": head.activate_phase_shift(2.0) # Standard 2s duration
			"Blink": perform_blink()
			"Meditate": head.activate_meditate()
			"Banana Bounty": activate_banana_bounty()
			"Sacrificial Molt": perform_sacrificial_molt()
			"Mise en Place": perform_mise_en_place()
			"Tenderizer": activate_tenderizer()
			"Garden Weaver": perform_garden_weave()
			"Autotomy": head.activate_autotomy()
			"Pocket Garden": create_pocket_garden()
			"Zenith": activate_zenith()
			"Lasso Larry": perform_lasso_larry()
			"Juice Press": perform_juice_press()
		
		
		print("Ability used: ", ability_key)
		update_hud()





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

	# This function now calculates the final speed from base values every time.
	
	# 1. Get the base speed for the current class and difficulty.
	var difficulty = GameManager.chosen_difficulty
	var p_class = GameManager.chosen_class
	var base_speed = GameManager.class_data[p_class]["start_speed"] * GameManager.difficulty_data[difficulty]["speed_multiplier"]

	# 2. Get the modification values.
	var speed_up_mod = GameManager.class_data[p_class]["speed_upgrade_mod"]
	var speed_up_level = GameManager.slither_sauce_level
	var slow_down_level = GameManager.heavy_foundation_level + GameManager.diet_slith_level

	# 3. Calculate the final speed using the power function for both speed-ups and slow-downs.
	var final_speed = base_speed * pow(speed_up_mod, speed_up_level) * pow(1.1, slow_down_level)
	
	# 4. Set the timer's wait_time to the final calculated speed.
	# We add a clamp to ensure it never gets TOO fast.
	head.move_timer.wait_time = clamp(final_speed, 0.05, 1.0)
	print("Speed updated. New wait time: ", head.move_timer.wait_time)





func open_upgrade_menu_with_transition():
	# Stop the snake and block input
	head.move_timer.stop()
	GameManager.combo_is_pure = false
	$UI/InputBlocker.show()

	var tile_map = $UI/ShopTransitionTileMap
	var size = Vector2i(40, 30)
	var max_steps = size.x + size.y

	# --- COVER SCREEN ANIMATION ---
	for step in range(max_steps):
		for x in range(step + 1):
			var y = step - x
			if x < size.x and y < size.y:
				tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
		await get_tree().create_timer(0.01).timeout

	# --- SHOW THE FUNKY MESSAGE ---
	var welcome_to_shop_messages = [
		"shop shop shop", "he's/she's/they're doin' it!", 
		"My thought exaclty", "Way to get out of there!", 
		"The timer starts after you read this message!", 
		"Speed is overhated!", "Glutton is overrated!", 
		"Pick something new old timer!"
	]
	var random_welcome_int = randi() % welcome_to_shop_messages.size()
	var random_message = welcome_to_shop_messages[random_welcome_int]
	
	$UI/CountdownLabel.text = random_message
	$UI/CountdownLabel.visible = true
	await get_tree().create_timer(1.5).timeout
	$UI/CountdownLabel.visible = false

	# --- Prepare the menu for its animation ---
	var upgrade_menu = $UI/UpgradeMenu
	upgrade_menu.set_initial_state_and_update()
	
	# --- THIS IS THE FIX ---
	# Set its starting scale to be tiny, but NOT zero.
	upgrade_menu.scale = Vector2(0.001, 0.001)
	upgrade_menu.visible = true

	# Create the pop-up animation
	var menu_tween = create_tween()
	menu_tween.tween_property(upgrade_menu, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	await menu_tween.finished

	# Unblock input so the player can use the menu
	$UI/InputBlocker.hide()

func check_for_garden_completion():
	# If a garden is already complete, we don't need to check again.
	if garden_complete_is_pending:
		return

	var current_score = snake_body_segments.size() + 1
	var current_garden_id = GameManager.current_garden
	var current_goal = GameManager.garden_data[current_garden_id]["score_goal"]
	
	if current_score >= current_goal:
		print("Garden ", current_garden_id, " complete! Pending screen.")
		garden_complete_is_pending = true
		
		# Play our cool "!" animation
		var exclamation = exclamation_scene.instantiate()
		exclamation.global_position = head.global_position
		add_child(exclamation)




func _calculate_garden_bonuses(p_score: int) -> Dictionary:
	var bonuses = {"bonus_list": [], "total_pulp": 0}
	var bonus_data = GameManager.garden_bonus_data
	
	var pulp_multiplier = GameManager.principal_pulp_data[GameManager.principal_pulp_level]
	var final_score_pulp = floori(p_score * pulp_multiplier)
	# Base Score Bonus
	bonuses.total_pulp += final_score_pulp
	bonuses.bonus_list.append("Base Score: +%smg" % final_score_pulp)
	
	var bonus_multiplier = GameManager.golden_handshake_data[GameManager.golden_handshake_level]
	# Serpent's Coffer Interest
	var coffer_level = GameManager.serpents_coffer_level
	if coffer_level > 0:
		var interest_rate = GameManager.serpents_coffer_data[coffer_level]
		var interest_earned = floori(GameManager.pulp * interest_rate)
		if interest_earned > 0:
			bonuses.total_pulp += floori(interest_earned * bonus_multiplier)
			bonuses.bonus_list.append("Serpent's Coffer: +%smg" % interest_earned)
			
	# Par Time Bonus
	var garden_time = GameManager.run_time - GameManager.garden_start_time
	var par_time_rules = GameManager.garden_bonus_data["par_time"]
	if garden_time < par_time_rules["time_limit"]:
		var reward = floori(par_time_rules["base_reward"] * bonus_multiplier)
		bonuses.total_pulp += reward
		bonuses.bonus_list.append("Par Time: +%smg" % reward)
		
	if not GameManager.has_died_this_garden:
		var reward = floori(bonus_data["no_death"]["reward"] * bonus_multiplier)
		bonuses.total_pulp += reward
		bonuses.bonus_list.append("Flawless Bonus: +%smg" % reward)
	
	if GameManager.juice_spent_this_garden == 0:
		var reward = floori(bonus_data["ascetic"]["reward"] * bonus_multiplier)
		bonuses.total_pulp += reward
		bonuses.bonus_list.append("No Upgrade Bonus: + %smg" % reward)
		
	if GameManager.abilities_used_this_garden == 0:
		var reward = floori(bonus_data["pacifist"]["reward"] * bonus_multiplier)
		bonuses.total_pulp += reward
		bonuses.bonus_list.append("No Ability Bonus: + %smg" % reward)
		
	if GameManager.juice_spent_this_garden > 1:
		var reward = floori(bonus_data["engagement"]["reward"] * bonus_multiplier)
		bonuses.total_pulp += reward * GameManager.juice_spent_this_garden
		bonuses.bonus_list.append("Engagement Bonus + %smg" % reward)
	
	# Now, handle JUICE bonuses, which don't add to the Pulp total.
	if GameManager.chosen_class == "the_zealot" and not GameManager.has_died_this_garden:
		var bonus_juice = GameManager.class_data[GameManager.chosen_class]["juice_on_perfect_garden"]
		GameManager.juice += bonus_juice
		bonuses.bonus_list.append("Zealot's Purity: +%s oz of Juice!" % bonus_juice)
		
	if GameManager.geological_survey_unlocked:
		# Get the number of rocks left on the screen.
		var remaining_rocks = spawned_obstacles.size()
		
		# Define the reward. Let's say +1 SP for every 5 rocks left.
		var bonus_per_rock = 0.2 
		
		# Check for the synergy with our Geomancer keystone!
		if GameManager.calculated_risk_unlocked:
			bonus_per_rock *= 2.0 # Double the reward!
			print("CALCULATED RISK! Geological Survey bonus is doubled!")
			

		# Calculate the final SP reward, rounding down to the nearest whole number.
		var bonus_juice = floori(remaining_rocks * bonus_per_rock)
		
		if bonus_juice > 0:
			print("GEOLOGICAL SURVEY BONUS! +%s SP for leaving %s rocks." % [bonus_juice, remaining_rocks])
			GameManager.juice += floori(bonus_juice)
			bonuses.bonus_list.append("Geological Survey Bonus +% Juice for leaving %s rocks!" % [bonus_juice, remaining_rocks])
			
	return bonuses

	




func show_ghost_fruit():
	# Remove any old ghost
	if is_instance_valid(ghost_fruit_instance):
		ghost_fruit_instance.queue_free()
	
	# Check if we have the upgrade
	if GameManager.fruit_foresight_unlocked:
		ghost_fruit_instance = preload("res://Scenes/Fruits/ghost_fruit.tscn").instantiate()
		# Find a safe spot for the GHOST and place it there.
		ghost_fruit_instance.position = next_fruit_position
		call_deferred("add_child", ghost_fruit_instance)

func move_camera_to_quadrant(quadrant_index: int):
	var final_camera_pos: Vector2
	
	if not GameManager.shatter_reality_unlocked:
		# In single-garden mode, center the camera on the current (expanding) garden
		print("current grid width and height: ", grid_width, " x ", grid_height)
		var center_pos = Vector2(grid_width / 2.0, grid_height / 2.0)
		final_camera_pos = (center_pos * tile_size)
	else:
		# In shattered mode, jump between the fixed centers of the 40x30 quadrants
		var target_pos = Vector2.ZERO
		match quadrant_index:
			0: target_pos = Vector2(20, 15) # Center of top-left
			1: target_pos = Vector2(60, 15) # Center of top-right
			2: target_pos = Vector2(20, 45) # Center of bottom-left
			3: target_pos = Vector2(60, 45) # Center of bottom-right
		final_camera_pos = (target_pos * tile_size)
	
	# Use a tween to smoothly pan the camera to its new fixed point.
	var tween = create_tween()
	tween.tween_property(camera, "global_position", final_camera_pos, 0.2).set_trans(Tween.TRANS_SINE)

func update_camera_quadrant():
	# This function only does something if the world is shattered
	if not GameManager.shatter_reality_unlocked:
		return

	var head_grid_pos = Vector2i((head.position - tile_offset) / tile_size)
	var new_quadrant = -1

	# Determine which quadrant the head is currently in
	var in_right_half = head_grid_pos.x >= 40
	var in_bottom_half = head_grid_pos.y >= 30

	if not in_right_half and not in_bottom_half: new_quadrant = 0 # Top-Left
	elif in_right_half and not in_bottom_half: new_quadrant = 1  # Top-Right
	elif not in_right_half and in_bottom_half: new_quadrant = 2  # Bottom-Left
	else: new_quadrant = 3                                      # Bottom-Right

	# If the snake has moved to a new quadrant, move the camera
	if new_quadrant != current_camera_quadrant:
		print("Changing camera to quadrant: ", new_quadrant)
		current_camera_quadrant = new_quadrant
		move_camera_to_quadrant(current_camera_quadrant)

func handle_meta_upgrade_purchase(upgrade_key: String):
	print("Handling meta upgrade purchase: ", upgrade_key)

	# We use a match statement to apply the correct effect.
	match upgrade_key:
		"Synapse Slot":
			GameManager.max_ability_slots += 1
		"Serpent's Coffer":
			GameManager.serpents_coffer_level += 1
		"Geode Compass":
			GameManager.geomancers_compass_level += 1
		"Four Leaf Clover":
			GameManager.four_leaf_clover_level += 1
		"Chroma Scales":
			GameManager.chroma_scales_level += 1
		"Harvest Forecast":
			GameManager.harvest_forecast_level += 1
		"Lasso Larry":
			# It calls the same powerful helper that our Juice shop uses!
			_purchase_or_upgrade_ability("Lasso Larry")


func update_boundary_visuals():
	
	if GameManager.fold_space_unlocked:
		$BoundaryIndicator.visible = false
		return
	
	$BoundaryIndicator.visible = true
	
	# This function now resizes BOTH the boundary and the background.
	var world_size_pixels = Vector2(grid_width * tile_size, grid_height * tile_size)
	boundary_indicator.set_deferred("size", world_size_pixels)
	background_rect.set_deferred("size", world_size_pixels)
	
	# Ensure they are positioned at the top-left corner.
	boundary_indicator.position = Vector2.ZERO
	background_rect.position = Vector2.ZERO
	
func update_hud():
	# --- 1. GATHER ALL DATA ---
	var data = {} # Create an empty dictionary to hold all our info
	
	# Player Stats
	data["player_name"] = GameManager.chosen_class.capitalize()
	data["level"] = GameManager.player_level
	data["xp_value"] = snake_body_segments.size() + 1
	data["xp_max"] = GameManager.score_needed_for_next_level
	data["xp_min"] = GameManager.score_at_level_start
	data["juice"] = GameManager.juice
	data["pulp"] = GameManager.pulp
	# --- Gather Harvest Forecast Data ---
	var forecast_level = GameManager.harvest_forecast_level
	data["harvest_forecast_level"] = forecast_level
	if forecast_level > 0:
		# At level 4, we show the next 5 fruits of any type.
		var num_to_show = 5 if forecast_level >= 4 else forecast_level
		data["forecast_list"] = GameManager.full_spawn_queue.slice(0, num_to_show)
		
		# Calculate and add the current special fruit chance for the display
		var base_special_chance = 0.10
		if GameManager.exotic_seeds_level >= 5:
			base_special_chance = 0.20
			
		# We need the snake's next position to check for Border Czar.
		# We can get this from our existing next_fruit_position variable.
		if GameManager.border_czar_unlocked and is_on_border(next_fruit_position):
			base_special_chance += 0.40
			
		# Get the final chance, including the Four-Leaf Clover bonus.
		data["special_fruit_chance"] = GameManager.get_modified_chance(base_special_chance)
	
	# Timers & Performance
	var minutes = int(GameManager.run_time / 60)
	var seconds = int(GameManager.run_time) % 60
	var tenths = int(fmod(GameManager.run_time, 1.0) * 10)
	data["run_time_string"] = "%d:%02d.%d" % [minutes, seconds, tenths] if minutes > 0 else "%02d.%d" % [seconds, tenths]
	
	# Frenzy Stats
	data["sugar_rush_unlocked"] = GameManager.sugar_rush_unlocked
	data["combo_is_active"] = not $ComboTimer.is_stopped()
	data["combo_window_time"] = $ComboTimer.time_left
	data["combo_count"] = GameManager.current_combo
	data["active_recipe"] = GameManager.active_recipe
	data["recipe_progress"] = GameManager.recipe_progress
	
	# Garden Info
	data["garden_name"] = GameManager.garden_data[GameManager.current_garden]["name"]
	data["garden_number"] = GameManager.current_garden
	data["current_score"] = snake_body_segments.size() + 1
	data["garden_goal"] = GameManager.garden_data[GameManager.current_garden]["score_goal"]
	
	
	
	# --- NEW: Calculate GPS ---
	var five_seconds_ago = GameManager.run_time - 5.0
	var growth_in_last_5s = 0.0
	# Prune old data from our history array
	for i in range(growth_history.size() - 1, -1, -1):
		if growth_history[i].time < five_seconds_ago:
			growth_history.remove_at(i)
		else:
			growth_in_last_5s += growth_history[i].growth
	
	# Add the final calculated GPS to our data dictionary
	data["current_gps"] = growth_in_last_5s / 5.0
	
	
	# --- 2. SEND DATA TO UI ---
	# Now, we pass this big dictionary to our UI scenes.
	player_banner.update_display(data) # Assumes you create this function in player_banner.gd
	information_panel.update_display(data)
	update_ability_hotbar()

func update_ability_hotbar():
	# 1. First, calculate how many slots should be visible.
	var unlocked_slots = GameManager.max_ability_slots
	
	# --- THIS IS THE FIX ---
	# 2. Get the UNIFIED list of all abilities from our smart helper function.
	var equipped_abilities = GameManager.equipped_abilities
	
	# 3. Loop through all 10 slots in the hotbar.
	for i in range(10):
		var slot = ability_hotbar.get_child(i)
		
		# 4. Show or hide the slot based on how many are unlocked.
		if i < unlocked_slots:
			slot.visible = true
			
			# Check if this slot should have an ability in it.
			if i < equipped_abilities.size():
				# This slot is filled. Get the ability data and update the display.
				var ability_key = equipped_abilities[i]
				var charge_count = 0
				# Get the current charges from our unified dictionary
				if ability_key in GameManager.ability_charges:
					charge_count = GameManager.ability_charges[ability_key].current
				elif ability_key in GameManager.block_market_portfolio:
					charge_count = GameManager.block_market_portfolio[ability_key]
				slot.update_display(ability_key, charge_count)
			else:
				# This slot is unlocked but empty.
				slot.update_display("", 0)
		else:
			# This slot is still locked.
			slot.visible = false



func update_fruit_prediction():
	next_fruit_position = calculate_safe_spawn_position()
	show_ghost_fruit()

func _on_quit_to_menu_pressed():
	get_tree().paused = false
	SceneTransition.transition_to("res://Scenes/Menus/main_menu.tscn")

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
	update_camera_quadrant()
	
	if upgrade_menu_is_pending:
		upgrade_menu_is_pending = false # Reset the flag
		open_upgrade_menu_with_transition() # Show the menu
	elif garden_complete_is_pending:
		# If there's no upgrade pending, check if a garden is complete.
		garden_complete_is_pending = false # Reset the flag
		_start_end_of_garden_sequence()
	

func spawn_fruit(spawn_position: Vector2):
	var fruit_key = "" # This will be the final decision
	
	# --- The New "Priority" Spawning System ---
	
	# PRIORITY 1: Check for "Last Stand" override.
	if GameManager.last_stand_unlocked and GameManager.extra_lives == 0 and randf() < 0.4:
		print("LAST STAND! A glimmer of hope appears...")
		fruit_key = "GoldenFruit"
	else:
		# PRIORITY 2: If no override, draw the next fruit from our pre-generated queue.
		if GameManager.full_spawn_queue.is_empty():
			GameManager.generate_full_spawn_queue()
		
		# Safety check in case the queue is still empty.
		if GameManager.full_spawn_queue.is_empty():
			fruit_key = "Fruit"
		else:
			fruit_key = GameManager.full_spawn_queue.pop_front()

	# PRIORITY 3: Check for Border Czar synergy to potentially upgrade the draw.
	if GameManager.border_czar_unlocked and is_on_border(spawn_position) and fruit_key == "Fruit":
		var unlocked_specials = GameManager.get_unlocked_special_fruits()
		if not unlocked_specials.is_empty() and randf() < 0.5:
			print("BORDER CZAR! Upgrading the fruit spawn...")
			fruit_key = unlocked_specials.pick_random()
			
	# 3. Instantiate the correct fruit.
	var fruit = instantiate_fruit_from_key(fruit_key)
	
	# 4. Apply visuals and place the fruit at the position it was given.
	if GameManager.masters_blueprint_unlocked:
		fruit.get_node("FillSprite").modulate = Color("AFEEEE")
			
	fruit.add_to_group("fruits")
	fruit.position = spawn_position
	call_deferred("add_child", fruit)

func instantiate_fruit_from_key(key: String) -> Node2D:
	match key:
		"GoldenFruit": return preload("res://Scenes/Fruits/golden_fruit.tscn").instantiate()
		"JumpingBean": return jumping_bean_scene.instantiate()
		"GhostPepper": return ghost_pepper_scene.instantiate()
		"IronCherry": return iron_cherry_scene.instantiate()
		"DragonFruit": return dragon_fruit_scene.instantiate()	
		_: return fruit_scene.instantiate()



func destroy_obstacle(obstacle_node):
	# First, check if the obstacle is still valid (it might have already been destroyed by a shockwave)
	if not is_instance_valid(obstacle_node):
		return

	# Store the rock's position *before* we remove it.
	var rock_position = obstacle_node.position
	
	# Safely remove it from our tracking array.
	spawned_obstacles.erase(obstacle_node)
	
	# Play the shrinking animation and queue it for deletion.
	var tween = create_tween()
	tween.tween_property(obstacle_node, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(obstacle_node.queue_free)

	# After we've handled the first rock, check if we should trigger the shockwave.
	if GameManager.pop_rocks_unlocked:
		trigger_pop_rocks_shockwave(rock_position)

func trigger_pop_rocks_shockwave(origin_rock_pos: Vector2):
	# This array defines the 8 tiles surrounding a central point.
	var neighbor_offsets = [
		Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1),
		Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)
	]
	
	# We need a list of rocks to destroy so we don't modify the array while looping.
	var rocks_to_destroy = []

	# Loop through all the offsets to find the neighbors.
	for offset in neighbor_offsets:
		var neighbor_pos = origin_rock_pos + (offset * tile_size)
		# Now, loop through all spawned obstacles to see if one is at this position.
		for rock in spawned_obstacles:
			if positions_are_equal(rock.position, neighbor_pos):
				rocks_to_destroy.append(rock)
				
	# Now that we have our list, destroy them all.
	for rock in rocks_to_destroy:
		# We can call our existing destroy function! This creates a cool chain reaction.
		destroy_obstacle(rock)

func update_grid_dimensions():
	if GameManager.shatter_reality_unlocked:
		# If shattered, the world is a fixed super-grid.
		grid_width = 80
		grid_height = 60
	else:
		# Otherwise, the size is determined by the Edge Lord upgrade level.
		var current_size = GameManager.edge_lord_data[GameManager.edge_lord_level]
		grid_width = int(current_size.x)
		grid_height = int(current_size.y)

func rebuild_world_layout():
	# The order of these calls is CRITICAL.
	# 1. First, always calculate the correct grid dimensions.
	update_grid_dimensions()
	
	# 2. Then, draw the boundary to match those new dimensions.
	update_boundary_visuals()
	
	# 3. Finally, draw the dividing walls if necessary, using the new dimensions.
	setup_shattered_reality()
	
	# 4. Position the camera correctly.
	move_camera_to_quadrant(0)

func setup_initial_obstacles():
	spawned_obstacles.clear()
	
	# 1. Get the base number of rocks for the current garden.
	var base_obstacle_count = GameManager.garden_data[GameManager.current_garden]["obstacle_count"]
	
	# 2. Add the penalty from each of our Tier 1 Geomancer upgrades.
	var geomancer_penalty = (GameManager.fertile_ground_level * 5) + \
							(GameManager.mineral_rich_soil_level * 5) + \
							(GameManager.tectonic_shift_level * 5) + \
							(GameManager.heavy_foundation_level * 5)
							
	var total_rocks_before_reduction = base_obstacle_count + geomancer_penalty
	
	# --- GEODE COMPASS ---
	# 3. Get the reduction multiplier from our Geomancer's Compass upgrade.
	var compass_level = GameManager.geode_compass_level
	var reduction_multiplier = GameManager.geode_compass_data[compass_level]
	
	# 4. Calculate the final number of rocks to spawn, rounding to the nearest whole number.
	var final_obstacle_count = round(total_rocks_before_reduction * reduction_multiplier)
	
	print("This garden will have %s rocks." % final_obstacle_count)

	# 5. Now, loop for the final, correct number of times.
	if GameManager.zoning_ordinance_level < 4:
		for i in range(final_obstacle_count):
			spawn_rock()

func is_in_safe_zone(grid_pos: Vector2i) -> bool:
	var zone_level = GameManager.zoning_ordinance_level
	if zone_level <= 0:
		return false

	var half_width = grid_width / 2.0
	var half_height = grid_height / 2.0
	
	# Level 1 protects Top-Left
	if zone_level >= 1 and grid_pos.x < half_width and grid_pos.y < half_height:
		return true
	# Level 2 also protects Top-Right
	if zone_level >= 2 and grid_pos.x >= half_width and grid_pos.y < half_height:
		return true
	# Level 3 also protects Bottom-Left
	if zone_level >= 3 and grid_pos.x < half_width and grid_pos.y >= half_height:
		return true
	# Level 4 also protects Bottom-Right
	if zone_level >= 4 and grid_pos.x >= half_width and grid_pos.y >= half_height:
		return true
		
	return false

func spawn_rock():
	var rock = rock_scene.instantiate()
	var potential_pos: Vector2
	var is_valid_spawn = false
	var attempt_counter = 0

	while not is_valid_spawn:
		attempt_counter += 1
		if attempt_counter > 5000:
			print_debug("Could not find a valid spot for an obstacle.")
			return

		var random_grid_pos = Vector2i(randi() % grid_width, randi() % grid_height)
		
		# We now call our new, smarter function to check ALL protected zones.
		if is_in_safe_zone(random_grid_pos):
			continue # If it's a safe zone, re-roll immediately.
		
		potential_pos = (Vector2(random_grid_pos) * tile_size) + tile_offset
		
		# Check for collisions with other rocks and the snake
		var is_on_another_rock = false
		for r in spawned_obstacles:
			if positions_are_equal(potential_pos, r.position):
				is_on_another_rock = true
				break
		
		if not is_any_body_part_at(potential_pos) and not is_on_another_rock:
			is_valid_spawn = true

	# Once a valid spot is found, spawn the rock there.
	var gray_value = randf_range(0.4, 0.7)
	rock.get_node("FillSprite").modulate = Color(gray_value, gray_value, gray_value)
	rock.position = potential_pos
	spawned_obstacles.append(rock)
	add_child(rock)

func spawn_trail_piece(pos: Vector2):
	var trail_piece = ColorRect.new()
	trail_piece.color = Color("LIGHT_CYAN", 0.3)
	trail_piece.size = Vector2(tile_size, tile_size)
	# We subtract the offset because a ColorRect's origin is its top-left.
	trail_piece.position = pos - tile_offset
	
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
		
	
	growth_history.append({"growth": segments_to_add, "time": GameManager.run_time})	
	update_tail_visuals()

	# We only update the score display once at the very end.
	update_hud()

func is_position_on_dividing_wall(grid_pos: Vector2i) -> bool:
	# If Shatter Reality isn't unlocked, there are no dividing walls.
	if not GameManager.shatter_reality_unlocked:
		return false
		
	# get_cell_source_id returns -1 if the cell is empty.
	# So, if it's NOT -1, it means there's a wall tile there.
	return dividing_wall_tilemap.get_cell_source_id(0, grid_pos) != -1

func setup_shattered_reality():
	dividing_wall_tilemap.clear() # Clear any old walls

	if not GameManager.shatter_reality_unlocked:
		return # Do nothing if the upgrade isn't active

	var dividing_line_x = 40
	var dividing_line_y = 30
	var dash_pattern = 4 # Draw a tile every 4 spaces to create a dashed line
	
	# Draw the vertical dashed line
	for y in range(grid_height):
		if y % dash_pattern < dash_pattern / 2.0: # This creates the on/off pattern
			dividing_wall_tilemap.set_cell(0, Vector2i(dividing_line_x, y), 0, Vector2i(0,0))

	# Draw the horizontal dashed line
	for x in range(grid_width):
		if x % dash_pattern < dash_pattern / 2.0:
			dividing_wall_tilemap.set_cell(0, Vector2i(x, dividing_line_y), 0, Vector2i(0,0))

func _update_snake_after_teleport(new_position: Vector2):
	# Set the head's new position
	head.global_position = new_position
	# Now that the head has moved, we can safely update the body's position to follow it.
	on_snake_head_moved(new_position)

func update_upgrade_prompt():
	# Show the prompt only if the player has SP to spend.
	var prompt = $UI/MarginContainer/HBoxContainer/VBoxContainer/PlayerBanner.get_node("HBox/StatsContainer/HBoxContainer2/UpgradePromptLabel")
	var has_juice = GameManager.juice > 0
	prompt.visible = has_juice

func update_progression():
	
	var current_score = snake_body_segments.size() + 1

	
	while current_score >= GameManager.score_needed_for_next_level:
		print("Level Up! Score is: ", current_score)
		# Award level and skill point(s)
		level_up()
		# Set a flag to know we should show the menu at a "later" time
	check_for_garden_completion()


	
	# Garden Completion Check
	var current_garden_id = GameManager.current_garden
	var current_goal = GameManager.garden_data[current_garden_id]["score_goal"]
	if current_score >= current_goal:
		#Beat the garden
		print("Garden ", current_garden_id, " complete! Pending screen.")
		#Show garden function coming soon
		garden_complete_is_pending = true
		
		var exclamation = exclamation_scene.instantiate()
		# Position it right on top of the snake's head
		exclamation.global_position = head.global_position
		# Add it to the game world
		add_child(exclamation)

func level_up():
	print("Level up!")
	#Before we calculate the next goal, we need to save the current one
	GameManager.score_at_level_start = GameManager.score_needed_for_next_level
	
	GameManager.player_level += 1
	
	#SP SCALE
	if GameManager.chosen_class != "the_alchemist":
		var juice_to_add = 0
		if GameManager.player_level >= 10: juice_to_add = 3
		elif GameManager.player_level >= 5: juice_to_add = 2
		else: juice_to_add = 1
		
		#-----Liquid Assets (Path A Ledger)----
		juice_to_add += GameManager.liquid_assets_level
		
		# If prestige mode is active, double the reward!
		if GameManager.new_game_s_plus_active:
			juice_to_add *= 2
			print("NEW GAME S+ BONUS! Gained %s SP!" % juice_to_add)
			
		GameManager.juice += juice_to_add
		
	#EXP/Juice SCALE
	if GameManager.player_level >= 10:
		GameManager.score_needed_for_next_level += 15
	elif GameManager.player_level >= 5:
		GameManager.score_needed_for_next_level += 10
	else:
		GameManager.score_needed_for_next_level += 5



func _on_upgrade_menu_resume_game_pressed():
	# Block input for the transition out
	$UI/InputBlocker.show()
	var upgrade_menu = $UI/UpgradeMenu

	# Animate the menu shrinking out to a tiny, non-zero scale.
	var menu_tween = create_tween()
	menu_tween.tween_property(upgrade_menu, "scale", Vector2(0.001, 0.001), 0.2).set_trans(Tween.TRANS_SINE)
	await menu_tween.finished
	
	# Now that it's gone, make it officially invisible
	upgrade_menu.visible = false
	
	update_hud()
	
	var resume_game_from_shop_messages = \
	["You chose...poorly!", "Why...what balls!\nYou didn't even pick a good upgrade!",
	"Whatcha doin' around 5?", "Make 'em pay!", "EAAAAAAAAAT!", "Wow, never woulda guessed that pick!",
	"Back to the game!", "Back to our correspondant on the ground!", "Hint: you can only pull up the upgrade menu\nwith at least 1 oz of juice"]
	var messages_size = resume_game_from_shop_messages.size()
	var random_message = randi() % messages_size
	
	
	$UI/CountdownLabel.visible = true
	$UI/CountdownLabel.text = resume_game_from_shop_messages[random_message]
	
	await get_tree().create_timer(1.5).timeout
	
	$UI/CountdownLabel.visible = false
	$UI/CountdownLabel.text = ""
	
	
	
	# --- UNCOVER SCREEN ANIMATION ---
	var tile_map = $UI/ShopTransitionTileMap
	var size = Vector2i(40, 30)
	var max_steps = size.x + size.y
	for step in range(max_steps):
		for x in range(step + 1):
			var y = (size.y - 1) - (step - x)
			if x < size.x and y >= 0:
				tile_map.erase_cell(0, Vector2i(x, y))
		await get_tree().create_timer(0.01).timeout
	
	$UI/InputBlocker.hide()
	start_countdown()
	
	update_hud()

func _start_end_of_garden_sequence():
	# --- State 1: Game Paused & Bonuses Calculated ---
	head.move_timer.stop()
	
	$ComboTimer.stop()
	
	garden_complete_is_pending = false
	
	var score = snake_body_segments.size() + 1
	var bonus_data = _calculate_garden_bonuses(score)
	GameManager.pulp += bonus_data.total_pulp

	# --- State 2: Transition to Results Screen ---
	await SceneTransition.play_cover_animation("flakes")
	
	var results_screen = $UI/GardenCompleteScreen
	var garden_id = GameManager.current_garden
	var is_final_garden = (garden_id == 9)
	var is_final_win = (is_final_garden and score >= 666)
	
	results_screen.display_results(
		GameManager.garden_data[garden_id]["name"],
		bonus_data.bonus_list,
		bonus_data.total_pulp,
		is_final_garden,
		is_final_win
	)
	results_screen.visible = true
	
	await SceneTransition.uncover_screen("drip")

	# --- State 3: Wait for Player Input ---
	# The game now pauses here indefinitely until the player clicks "Continue".
	await results_screen.continue_pressed
	_transition_to_shop()

func _transition_to_shop():
	var garden_id = GameManager.current_garden
	if garden_id == 9:
		SceneTransition.transition_to("res://Scenes/Menus/main_menu.tscn")
		return
	
	# --- State 4: Transition to Pulp-sicle Stand ---
	await SceneTransition.play_cover_animation("drip")
	$UI/GardenCompleteScreen.visible = false
	
	var shop_screen = $UI/PulpsicleStand
	shop_screen.open_shop() # This just updates displays and makes it visible
	
	await SceneTransition.uncover_screen("drip")
	
	await shop_screen.animate_in() # Play the shop's slide-in animation

func _go_to_next_garden():
	var shop_screen = $UI/PulpsicleStand
	await shop_screen.animate_out() # Animate the shop sliding away
	await SceneTransition.play_cover_animation("random")
	
	# Now that the screen is covered, it is safe to reset stats.
	GameManager.has_died_this_garden = false
	GameManager.juice_spent_this_garden = 0
	GameManager.abilities_used_this_garden = 0
	GameManager.garden_start_time = GameManager.run_time
	GameManager.juice_press_used_this_garden = false
	GameManager.reset_for_new_garden()
	_recharge_all_abilities()
	GameManager.update_block_market()
	
	# Finally, tell the main SceneTransition to go to the next level.
	GameManager.current_garden += 1
	SceneTransition.transition_to("res://Scenes/main.tscn", "random")

func _on_garden_complete_continue_pressed():
	# This is called by the results screen button.
	# Note: It no longer needs to be async.
	pass # The master sequence is already waiting for the signal.
func _on_pulpsicle_stand_continue_pressed():
	_go_to_next_garden()


func _recharge_all_abilities():
	print("Recharging all abilities for the new garden!")
	# Loop through every ability the player owns.
	for ability_key in GameManager.ability_charges:
		var ability_data = GameManager.ability_charges[ability_key]
		# Set the current charges equal to the total purchased charges.
		ability_data.current = ability_data.total


func recharge_random_ability():
	print("CUSTOM CUISINE: Attempting to recharge a random ability...")
	
	# 1. Get the list of all abilities the player currently has equipped.
	var available_abilities = GameManager.equipped_abilities
	
	# 2. If they don't have any abilities, do nothing.
	if available_abilities.is_empty():
		return
		
	# 3. Pick a random ability from the list.
	var chosen_ability = available_abilities.pick_random()
	
	# 4. Check if this ability actually uses charges.
	if chosen_ability in GameManager.ability_charges:
		# 5. If yes, grant one charge.
		GameManager.ability_charges[chosen_ability] += 1
		print("Recharged 1 charge of " + chosen_ability)
		
		# 6. Update the HUD to show the new charge count.
		update_hud()


func _purchase_or_upgrade_ability(ability_key: String):
	# Check if we already own this ability.
	if not ability_key in GameManager.ability_charges:
		if GameManager.equipped_abilities.size() < GameManager.max_ability_slots:
			GameManager.equipped_abilities.append(ability_key)
			# Create the new entry with 1 charge.
			GameManager.ability_charges[ability_key] = {"current": 1, "total": 1}
	else:
		# If we already own it, just add to both current and total charges.
		GameManager.ability_charges[ability_key].current += 1
		GameManager.ability_charges[ability_key].total += 1

func activate_tenderizer():
	# Tenderizer is a passive "on-next-hit" ability, so it doesn't do anything
	# when you press the key. Its logic is handled entirely in the collision check.
	# We could play a small sound effect here to confirm the hotkey press.
	print("Tenderizer is ready!")


func _on_upgrade_menu_upgrade_selected(upgrade_name):
	var active_abilities = [
		"Burrow", "Phase Shift", "Blink", "Pocket Garden", "Banana Bounty", "Molt",\
		"Meditate", "Sacrificial Molt", "Mise en Place", "Zenith", "Autotomy",\
		"Tenderizer"
	]
	print("Player chose upgrade: ", upgrade_name)
	
	if upgrade_name in active_abilities:
		_purchase_or_upgrade_ability(upgrade_name)
			
	else:

#------Idle Path-----#
		if upgrade_name == "Snake Clicker":
			if GameManager.snake_clicker_level < 10:
				GameManager.snake_clicker_level += 1
		elif upgrade_name == "Get Rich Quick":
			if not GameManager.get_rich_quick_unlocked:
				GameManager.get_rich_quick_unlocked = true
		elif upgrade_name == "Custom Aftertaste":
			if not GameManager.custom_aftertaste_unlocked:
				GameManager.custom_aftertaste_unlocked = true
		elif upgrade_name == "Arcane Flow":
			if not GameManager.arcane_flow_unlocked:
				GameManager.arcane_flow_unlocked = true
		elif upgrade_name == "Pulp Reactor":
			if not GameManager.pulp_reactor_unlocked:
				GameManager.pulp_reactor_unlocked = true
		elif upgrade_name == "Unstable Metabolism":
			if not GameManager.unstable_metabolism_unlocked:
				GameManager.unstable_metabolism_unlocked = true
#---------THE PLANNER-------#
		elif upgrade_name == "Diet Slith":
			if GameManager.diet_slith_level < 5:
				GameManager.diet_slith_level += 1
				head.move_timer.wait_time *= 1.1 
				print("SNAKE SLOWED! New wait time: ", head.move_timer.wait_time)
		elif upgrade_name == "Fruit Foresight":
			if not GameManager.fruit_foresight_unlocked:
				GameManager.fruit_foresight_unlocked = true
				show_ghost_fruit()
		elif upgrade_name == "Geological Survey":
			if not GameManager.geological_survey_unlocked:
				GameManager.geological_survey_unlocked = true
		elif upgrade_name == "Sovereign Trail":
			if GameManager.sovereign_trail_level < 2:
				GameManager.sovereign_trail_level += 1
				print("Sovereign Trail Upgraded 1 level!")
		#----The Ledger Path----
		elif upgrade_name == "Liquid Assets":
			if GameManager.chosen_ledger_path == "" and GameManager.liquid_assets_level < 5:
				GameManager.chosen_ledger_path = "Liquid Assets"
				GameManager.liquid_assets_level += 1
			elif GameManager.liquid_assets_level < 5:
				GameManager.liquid_assets_level += 1
		elif upgrade_name == "Fast Track":
			if not GameManager.fast_track_unlocked:
				GameManager.fast_track_unlocked = true
		elif upgrade_name == "Gluttons Greed":
			if not GameManager.gluttons_greed_unlocked:
				var bonus = get_effective_max_fruits()
				GameManager.fruit_reward += bonus
				GameManager.gluttons_greed_unlocked = true
				print("GLUTTON'S GREED Fruit Reward permanently increased by %s!" % bonus)
		elif upgrade_name == "Market Crash":
			if GameManager.market_crash_level < 3:
				GameManager.market_crash_level += 1
		elif upgrade_name == "Principal Pulp":
			if GameManager.chosen_ledger_path == "" and GameManager.principal_pulp_level < 3:
				GameManager.chosen_ledger_path = "Principal Pulp"
				GameManager.principal_pulp_level += 1
			elif GameManager.principal_pulp_level < 3:
				GameManager.principal_pulp_level += 1
		elif upgrade_name == "Golden Handshake":
			if GameManager.golden_handshake_level < 3:
				GameManager.golden_handshake_level += 1
		elif upgrade_name == "Juice Press":
			_purchase_or_upgrade_ability("Juice Press")
		elif upgrade_name == "Liquidation":
			if not GameManager.liquidation_used:
				GameManager.liquidation_used = true
				GameManager.juice *= 2
				# Need to add a cool effect
#----------------------------Glutton-------------------------#
			#---ESP---#
		elif upgrade_name == "Elephant Sized Portions":
			GameManager.apply_esp_level_up()
			print("ESP bought! New Fruit Reward: ", get_effective_fruit_reward())
			#---More Mice---#
		elif upgrade_name == "More Mice":
				if GameManager.more_mice_level < 6: # Your max level
					GameManager.max_fruits_on_screen += 1
					GameManager.more_mice_level += 1
					
					# Instead of just spawning one fruit, we now check how many are
					# on screen vs. how many SHOULD be, and spawn the difference.
					var current_fruit_count = get_tree().get_nodes_in_group("fruits").size()
					var target_fruit_count = get_effective_max_fruits()
					var fruits_to_spawn = target_fruit_count - current_fruit_count
					
					print("Player bought More Mice! Spawning %s new fruit." % fruits_to_spawn)

					# This loop ensures that even if we spawn multiple fruits in the same frame,
					# they won't spawn on top of each other.
					var pending_positions = []
					for i in range(fruits_to_spawn):
						var new_pos = calculate_safe_spawn_position(pending_positions)
						spawn_fruit(new_pos)
						pending_positions.append(new_pos)
					
					# Update the ghost fruit prediction now that the board has changed.
					update_fruit_prediction()
		elif upgrade_name == "Golden Seeds":
			if GameManager.golden_seeds_level < 4:
				GameManager.golden_seeds_level += 1
		elif upgrade_name == "Patient Gardener":
			if GameManager.patient_gardener_level < 3:
				GameManager.patient_gardener_level += 1
		elif upgrade_name == "The Satchel":
			if not GameManager.the_satchel_unlocked:
				GameManager.the_satchel_unlocked = true
#------------------CHEF PATH------------------#
		elif upgrade_name == "Golden Seed Extract":
			if GameManager.golden_seed_extract_level < 3:
				GameManager.golden_seed_extract_level += 1
		elif upgrade_name == "Exotic Seeds":
			if GameManager.exotic_seeds_level < 5:
				GameManager.exotic_seeds_level += 1
		elif upgrade_name == "The Cookbook":
			if not GameManager.the_cookbook_unlocked:
				GameManager.the_cookbook_unlocked = true
				pick_new_recipe()
		elif upgrade_name == "Expanded Palate":
			if not GameManager.expanded_palate_unlocked:
				GameManager.expanded_palate_unlocked = true
				pick_new_recipe()
		elif upgrade_name == "Golden Glaze":
			if not GameManager.golden_glaze_unlocked:
				GameManager.golden_glaze_unlocked = true
		elif upgrade_name == "Custom Cuisine":
			if not GameManager.custom_cuisine_unlocked:
				GameManager.custom_cuisine_unlocked = true
# --- GEOMANCER PATH ---
		elif upgrade_name == "Fertile Ground":
			if GameManager.fertile_ground_level < 3:
				GameManager.fertile_ground_level += 1
				spawn_fruit(next_fruit_position)
				# The cost is adding more obstacles to the world!
		elif upgrade_name == "Mineral Rich Soil":
			if GameManager.mineral_rich_soil_level < 3:
				GameManager.mineral_rich_soil_level += 1
		elif upgrade_name == "Tectonic Shift":
			if GameManager.tectonic_shift_level < 3:
				GameManager.tectonic_shift_level += 1
				apply_persistent_upgrades()
		elif upgrade_name == "Heavy Foundation":
			if GameManager.heavy_foundation_level < 3:
				GameManager.heavy_foundation_level += 1
				apply_persistent_upgrades()
		# --- Rockeater Specialization ---
		# check if a type has already been chosen.
		elif upgrade_name in ["Rockmuncher", "Geode Cracker", "Kinetic Feast", "Stones Burden"]:
		# Check if a path has already been chosen. This is a safety check.
			if GameManager.rockeater_type == "":
				print("Geode path chosen: ", upgrade_name)
				# Set the chosen path in our global manager
				GameManager.rockeater_type = upgrade_name
		elif upgrade_name == "Rockmuncher":
			if GameManager.rockeater_type == "":
				GameManager.rockeater_type = "Rockmuncher"
			else:
				print("You have already chosen a Rockeater path!")
		elif upgrade_name == "Geode Cracker":
			if GameManager.rockeater_type == "":
				GameManager.rockeater_type = "Geode Cracker"
			else:
				print("You have already chosen a Rockeater path!")
		elif upgrade_name == "Kinetic Feast":
			if GameManager.rockeater_type == "":
				GameManager.rockeater_type = "Kinetic Feast"
			else:
				print("You have already chosen a Rockeater path!")
		elif upgrade_name == "Stones Burden":
			if GameManager.rockeater_type == "":
				GameManager.rockeater_type = "Stones Burden"
			else:
				print("You have already chosen a Rockeater path!")
		elif upgrade_name == "Calculated Risk":
			if not GameManager.calculated_risk_unlocked:
				GameManager.calculated_risk_unlocked = true		

#---------ACROBAT----------#
		elif upgrade_name == "Slither Sauce":
			if GameManager.slither_sauce_level < 10:
				GameManager.slither_sauce_level += 1
				apply_persistent_upgrades()
		elif upgrade_name == "Juke N Jive":
			if not GameManager.juke_and_jive_unlocked:
				GameManager.juke_and_jive_unlocked = true
		elif upgrade_name == "Afterburner":
			if GameManager.afterburner_level < 3:
				GameManager.afterburner_level += 1
		elif upgrade_name == "Pop Rocks":
			if not GameManager.pop_rocks_unlocked:
				GameManager.pop_rocks_unlocked = true
#---------FRENZY------------#
		elif upgrade_name == "Sugar Rush":
			if not GameManager.sugar_rush_unlocked:
				GameManager.sugar_rush_unlocked = true
				#information_panel.update_display(["sugar_rush_unlocked", true])
		elif upgrade_name == "Chain Reaction":
			if GameManager.chain_reaction_level < 3:
				GameManager.chain_reaction_level += 1
		elif upgrade_name == "Overdrive":
			if GameManager.overdrive_level < 2:
				GameManager.overdrive_level += 1
		elif upgrade_name == "Lingering Rush":
			if GameManager.lingering_rush_level < 5:
				GameManager.lingering_rush_level += 1
		elif upgrade_name == "Juggernaut":
			if not GameManager.juggernaut_unlocked:
				GameManager.juggernaut_unlocked = true
#--------SURVIVOR--------#
		elif upgrade_name == "Mulligan Munchie":
			if GameManager.extra_lives < 10 and not GameManager.extra_lives_are_capped:
				GameManager.extra_lives += 1
				print("Extra life added, thanks to ol' Mulligan!")
			elif GameManager.extra_lives_are_capped:
				print("Extra lives are capped! No can do!")
		elif upgrade_name == "Phoenix Dawn": 
			if not GameManager.phoenix_dawn_unlocked:
				GameManager.phoenix_dawn_unlocked = true
		elif upgrade_name == "Last Stand":
			if not GameManager.last_stand_unlocked:
				GameManager.last_stand_unlocked = true
		elif upgrade_name == "Death Defied": 
			if not GameManager.death_defied_unlocked:
				GameManager.death_defied_unlocked = true
		elif upgrade_name == "Martyrdom": 
			if not GameManager.martyrdom_unlocked:
				GameManager.martyrdom_unlocked = true
		elif upgrade_name == "New Game S Plus": 
			if not GameManager.new_game_s_plus_active:
				GameManager.new_game_s_plus_active = true
				GameManager.current_garden = 1
				SceneTransition.transition_to("res://Scenes/main.tscn")
#-------------------------------Architect--------------------------#
		elif upgrade_name == "Edge Lord":
			if GameManager.edge_lord_level < 5:
				GameManager.edge_lord_level += 1
				rebuild_world_layout()
		elif upgrade_name == "Zoning Ordinance":
			if GameManager.zoning_ordinance_level < 4:
				GameManager.zoning_ordinance_level += 1
		elif upgrade_name == "Border Czar":
			if not GameManager.border_czar_unlocked:
				GameManager.border_czar_unlocked = true
		elif upgrade_name == "Surveyed Land":
			if not GameManager.surveyed_land_unlocked:
				GameManager.surveyed_land_unlocked = true
		elif upgrade_name == "Fold Space":
			if not GameManager.fold_space_unlocked:
				GameManager.fold_space_unlocked = true
				update_boundary_visuals()
		elif upgrade_name == "Shatter Reality":
			if not GameManager.shatter_reality_unlocked:
				GameManager.shatter_reality_unlocked = true
				print("current: grid size pending...")
				rebuild_world_layout()
				print("currnet: grid size (w x h): ", grid_width, " x ", grid_height)
		elif upgrade_name == "Masters Blueprint":
			if not GameManager.masters_blueprint_unlocked:
				GameManager.masters_blueprint_unlocked = true
				apply_cosmetic_upgrades()
		#--------------------------ILLUSIONIST--------------------#
		elif upgrade_name == "Ghost Tail":
			if GameManager.ghost_tail_level < 5:
				GameManager.ghost_tail_level += 1
				print("Ghost Tail Upgraded! New ghost length: ", GameManager.ghost_tail_data[GameManager.ghost_tail_level])
		elif upgrade_name == "3 Card Monty":
			if not GameManager.three_card_monty_unlocked:
				GameManager.three_card_monty_unlocked = true
				print("3-Card Monty! Swindler's Discount! -1SP")
		elif upgrade_name == "Fractured Self":
			if not GameManager.fractured_self_unlocked:
				GameManager.fractured_self_unlocked = true
		elif upgrade_name == "Dazzle Pie":
			if not GameManager.dazzle_pie_unlocked and not GameManager.masters_blueprint_unlocked:
				GameManager.dazzle_pie_unlocked = true
				print("Dazzle Pie loading...yum")
				apply_cosmetic_upgrades()
		#------SnakeEyes Path----#
		elif upgrade_name == "Coin Flip Curious":
			if not GameManager.coin_flip_curious_unlocked:
				GameManager.coin_flip_curious_unlocked = true
		elif upgrade_name == "Passive Income":
			if not GameManager.passive_income_unlocked:
				GameManager.passive_income_unlocked = true
		#----------One last update HUD
		update_ability_hotbar()
		call_deferred("update_hud")


func _on_combo_timer_timeout():
	print("Combo Dropped!")
	GameManager.current_combo = 0
	update_hud()

func _on_zenith_timer_timeout():
	# When the timer is up, the effect ends.
	print("Zenith has ended.")
	GameManager.is_zenith_active = false
	GameManager.current_combo = 0 # Reset the combo
	head.reset_head_color() # A helper to safely reset the head's color
	update_hud()


func apply_recipe_buff(buff_data: Dictionary):
	match buff_data["type"]:
		"speed_boost":
			# This requires a new helper function in snake_head.gd
			head.activate_temporary_speed_boost(buff_data["value"], buff_data["duration"])
		"juice_boost":
			GameManager.juice += buff_data["value"]
			update_hud()
		"full_recharge":
			print("ABILITIES RECHARGED")
			#RECHARGE ABILITIES IF UNLOCKED
			if GameManager.burrow_level > 0:
				GameManager.burrow_charges = GameManager.burrow_level
			if GameManager.phase_shift_level > 0:
				GameManager.phase_shift_charges = GameManager.phase_shift_level
			if GameManager.meditate_level > 0:
				GameManager.meditate_charges = GameManager.meditate_level
			if GameManager.banana_bounty_level > 0:
				GameManager.banana_bounty_charges = GameManager.banana_bounty_level
			if GameManager.tenderizer_level > 0:
				GameManager.tenderizer_charges = GameManager.tenderizer_level
			if GameManager.pocket_garden_level > 0:
				GameManager.pocket_garden_charges = GameManager.pocket_garden_level
			if GameManager.blink_level > 0:
				GameManager.blink_charges = GameManager.blink_level
		"fruit_flood":
			# This requires a new timer and logic to spawn fruit rapidly
			start_fruit_flood(buff_data["duration"])


func update_combo_meter():
	# If the player hasn't unlocked the combo system, do nothing.
	if not GameManager.sugar_rush_unlocked:
		return

	# If the combo was at 0, this is a new chain. Reset the purity flag.
	if GameManager.current_combo == 0:
		GameManager.combo_is_pure = true
		
	# Increment the combo counter.
	GameManager.current_combo += 1
	
	# Cap the combo based on the Chain Reaction upgrade level.
	var max_combo = GameManager.chain_reaction_data[GameManager.chain_reaction_level]
	if GameManager.current_combo > max_combo:
		GameManager.current_combo = max_combo
		
	# Start the combo timer with the correct duration from the Lingering Rush upgrade.
	var combo_duration = GameManager.lingering_rush_data[GameManager.lingering_rush_level]
	$ComboTimer.start(combo_duration)

# --- CORRECTED ON_SNAKE_ATE_FOOD FUNCTION ---
func on_snake_ate_food(fruit):
	# 1a. First, update combo meter.
	update_combo_meter()
	# 1b. Next, check and update the cookbook progress.
	check_cookbook_progress(fruit)
	# 2. Next, calculate all the rewards from the fruit.
	var rewards = calculate_fruit_rewards(fruit)
	# 3. Apply rewards
	GameManager.juice += rewards.juice_reward
	grow_snake(rewards.segments_to_add)
	
	
	# 4. Handle run-specific stats.
	GameManager.fruits_eaten_this_run += 1
	time_since_last_fruit = 0.0
	head.check_for_afterburner()
	
	# 5. Handle cleanup and respawning.
	cleanup_and_respawn_fruit(fruit, rewards.was_bounty_target)
	
	# 6. Final UI and prediction updates.
	update_fruit_prediction()
	update_progression()
	update_hud()
	update_upgrade_prompt()
	
	if head.can_reverse:
		head.can_reverse = false
	
func calculate_fruit_rewards(fruit) -> Dictionary:
	# This function calculates all rewards and returns them in a dictionary.
	var rewards = {"segments_to_add": 0, "juice_reward": 0, "was_bounty_target": false}
	
	# First, check for the highest priority: a bounty.
	if fruit.is_bounty_target:
		rewards.segments_to_add = get_effective_max_fruits() * get_effective_fruit_reward()
		rewards.was_bounty_target = true
		GameManager.is_bounty_active = false
		return rewards
	
	# If a bounty was active but we ate the wrong fruit...
	if GameManager.is_bounty_active:
		GameManager.is_bounty_active = false
		# ...find and reset the real bounty target.
		for f in get_tree().get_nodes_in_group("fruits"):
			if f.is_bounty_target:
				f.reset_from_bounty() # We'll create this small helper in the fruit scripts
				break
				
	# --- Calculate Normal & Special Rewards ---
	var growth_multiplier = 1.0
	
	# Handle base effects and Custom Cuisine effects together
	if fruit is GoldenFruit:
		rewards.juice_reward += GameManager.golden_seeds_data[GameManager.golden_seeds_level]["reward"]
		if GameManager.custom_cuisine_unlocked:
			recharge_random_ability() 
			
	elif fruit is GhostPepper:
		if GameManager.custom_cuisine_unlocked:
			# Activate long-duration phase
			head.activate_phase_shift(10.0)
		else:
			head.activate_phase_shift(3.0) 

	elif fruit is IronCherry:
		if GameManager.custom_cuisine_unlocked:
		# Grant a temporary, massive max fruit boost
			GameManager.iron_cherry_buff_active = true
			$IronCherryBuffTimer.start(10.0) # 10-second duration
			# Spawn a bunch of new fruit immediately
			for i in range(5): spawn_fruit(next_fruit_position) 
		else:
			GameManager.max_fruits_on_screen += 1
		
	elif fruit is DragonFruit:
		# Grant a temporary, massive growth multiplier
		GameManager.dragon_fruit_buff_active = true
		$DragonFruitBuffTimer.start(10.0)
	


			
	# Handle Ripe property
	if fruit.has_method("ripen") and fruit.is_ripe:
		growth_multiplier = GameManager.patient_gardener_data[GameManager.patient_gardener_level]["multiplier"]
		if fruit is GoldenFruit:
			rewards.juice_reward += 1 # Bonus SP for a rare Ripe Golden Fruit
			
	#--------Coin Flip Curious--------#
	if GameManager.coin_flip_curious_unlocked:
		print("Coin Flip Curious active! Risking it all...")
		# Roll a 50/50 die.
		if randf() < 0.5:
			# On a win, double the growth multiplier!
			growth_multiplier *= 2.0
			print("WIN! Growth is doubled!")
		else:
			# On a loss, the multiplier becomes 0. No growth.
			growth_multiplier = 0.0
			print("LOSE! No growth this time.")
			
	# Reward calculation = Effective fruit reward * patient gardner * combo clamped at 1 cuz bugs at 0 lol
	rewards.segments_to_add = get_effective_fruit_reward() * growth_multiplier * max(1, GameManager.current_combo)
	return rewards
	
	
func cleanup_and_respawn_fruit(eaten_fruit, was_bounty: bool):
	# This function handles deleting old fruits and spawning new ones.
	if was_bounty:
		# If it was a bounty, clear the board and respawn everything.
		for f in get_tree().get_nodes_in_group("fruits"):
			if is_instance_valid(f.active_tween): f.active_tween.kill()
			f.queue_free()
		for i in range(get_effective_max_fruits()):
			spawn_fruit(next_fruit_position)
	else:
		# Otherwise, just replace the one fruit that was eaten.
		if is_instance_valid(eaten_fruit.active_tween): eaten_fruit.active_tween.kill()
		eaten_fruit.queue_free()
		spawn_fruit(next_fruit_position)
	
	
	
func check_cookbook_progress(eaten_fruit):
	if not GameManager.the_cookbook_unlocked or GameManager.active_recipe.is_empty():
		return

	var recipe = GameManager.active_recipe
	var progress = GameManager.recipe_progress
	var required_ingredient = recipe["sequence"][progress]
	
	var is_correct_type = (eaten_fruit.fruit_type == required_ingredient["type"])
	var properties_match = true
	if required_ingredient.has("properties"):
		for prop in required_ingredient["properties"]:
			if not eaten_fruit.has(prop) or eaten_fruit.get(prop) != required_ingredient["properties"][prop]:
				properties_match = false
				break
				
	var is_wildcard = (GameManager.golden_glaze_unlocked and eaten_fruit is GoldenFruit)

	if (is_correct_type and properties_match) or is_wildcard:
		GameManager.recipe_progress += 1
		if GameManager.recipe_progress >= recipe["sequence"].size():
			apply_recipe_buff(recipe["buff"])
			pick_new_recipe()
	else:
		GameManager.recipe_progress = 0
		pick_new_recipe() # Give the player a new recipe on failure
	



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
		
		# --- POCKET GARDEN CHECK --- #
		if GameManager.active_pocket_garden_rect != null and randf() < 0.9: # 90% chance
			# If yes, force the spawn to be inside it
			var pg_rect = GameManager.active_pocket_garden_rect
			var x_pos = randi_range(pg_rect.position.x, pg_rect.end.x)
			var y_pos = randi_range(pg_rect.position.y, pg_rect.end.y)
			random_grid_pos = Vector2i(Vector2(x_pos, y_pos) / tile_size)
		
		
		# --- Logic to pick a random spot (including trail bonus) ---
		elif trail_level == 2 and not trail_pieces.is_empty() and randf() < 0.7:
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

func draw_grid(grid_color: Color):
	var grid_tilemap = $BlueprintGridTileMap # We can reuse this TileMap node
	grid_tilemap.clear()
	
	for y in range(grid_height):
		for x in range(grid_width):
			grid_tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0,0))
			
	# Modulate the entire tilemap to set the color of the grid lines.
	grid_tilemap.modulate = grid_color

func apply_cosmetic_upgrades():
	# This is now the single source of truth for all visual styles.
	
	# PRIORITY 1: Master's Blueprint (The ultimate visual override)
	if GameManager.masters_blueprint_unlocked:
		apply_blueprint_visuals() # This helper handles all blueprint effects
		
	# PRIORITY 2: Dazzle Pie
	elif GameManager.dazzle_pie_unlocked:
		apply_dazzle_visuals() # This new helper handles the Dazzle effects
	
	# PRIORITY 3: Chroma Scales (The default customizable look)
	else:
		apply_chroma_scales_visuals() # This helper handles player-chosen colors

func update_snake_visuals_from_chroma():

	for i in range(snake_body_segments.size()):
		var segment = snake_body_segments[i]
		if GameManager.chroma_scales_level >= 1:
			var pattern_rate = GameManager.equipped_pattern_rate
			if (i + 2) % pattern_rate == 0:
				segment.get_node("FillSprite").modulate = GameManager.equipped_body_color_2
			else:
				segment.get_node("FillSprite").modulate = GameManager.equipped_body_color_1
		else:
			# Default single color if pattern is not activated
			segment.get_node("FillSprite").modulate = GameManager.equipped_body_color_1


func update_gps_graph():
	# --- Calculate GPS ---
	var five_seconds_ago = GameManager.run_time - 5.0
	var growth_in_last_5s = 0
	# Prune old data and calculate growth in the window
	for i in range(growth_history.size() - 1, -1, -1):
		if growth_history[i].time < five_seconds_ago:
			growth_history.remove_at(i)
		else:
			growth_in_last_5s += growth_history[i].growth

	var current_gps = growth_in_last_5s / 5.0

	# --- Update Visuals ---
	var graph = $UI/MarginContainer/HBoxContainer/InformationPanel/HBoxContainer/GardenDataContainer/GPSTracker/GraphLine
	
	# Add a new point to the end of the line graph
	graph.add_point(Vector2(graph.get_point_count() * 2, -current_gps * 10)) # We multiply to make the graph visible
	# If the graph is too long, remove the oldest point
	if graph.get_point_count() > 100:
		graph.remove_point(0)

	# We could add the color-changing shader logic here later!





func apply_dazzle_visuals():
	# This function handles the Dazzle Pie effect.
	
	# 1. Turn ON the Dazzle overlay for the chromatic aberration.
	$UI/DazzleOverlay.visible = true
	
	# 2. Ensure the background is in its default state (no shader).
	background_rect.material = null
	background_rect.color = Color("#222222")
	
	# 3. Draw a unique, subtle grid for the Dazzle effect.
	draw_grid(Color("FFFFFF", 0.1)) # A faint white grid
	
	# 4. Make sure the snake has its normal Chroma Scales colors.
	update_snake_visuals_from_chroma()

func apply_chroma_scales_visuals():
	# Turn off all keystone effects
	$UI/DazzleOverlay.visible = false
	background_rect.material = null
	# Check if the player has unlocked the basic grid via Chroma Scales
	if GameManager.chroma_scales_level >= 4: # Assuming level 4 unlocks the background
		$BlueprintGridTileMap.clear()
		draw_grid(Color("FFFFFF", 0.1)) # A very faint white grid
		background_rect.color = GameManager.equipped_background_color
	else:
		# If not, ensure the grid is clear and the background is default
		$BlueprintGridTileMap.clear()
		background_rect.color = Color("#222222")
		
	# Apply the normal snake colors
	update_snake_visuals_from_chroma()

func update_all_objects_to_blueprint_color():
	var blueprint_glow_color = Color("AFEEEE")
	head.get_node("FillSprite").modulate = blueprint_glow_color
	for segment in snake_body_segments:
		segment.get_node("FillSprite").modulate = blueprint_glow_color
	for fruit in get_tree().get_nodes_in_group("fruits"):
		fruit.get_node("FillSprite").modulate = blueprint_glow_color
	for rock in spawned_obstacles:
		rock.get_node("FillSprite").modulate = Color.BLACK # Your chosen rock color

func apply_blueprint_visuals():
	# Turn OFF other effects
	$UI/DazzleOverlay.visible = false
	
	# Set the unique background color
	background_rect.color = Color("0d1b2a")
	var mat = ShaderMaterial.new()
	mat.shader = trippy_grid_shader
	background_rect.material = mat

	# Call our helper to draw the blueprint grid
	draw_grid(Color("415a77", 0.2))
	
	# Apply the object colors
	update_all_objects_to_blueprint_color()

func is_any_body_part_at(check_pos: Vector2) -> bool:
	# This function ignores ghost rules and just checks every segment.
	for segment in snake_body_segments:
		if positions_are_equal(segment.global_position, check_pos):
			return true # Found a body part here.
	return false # No parts found.

func add_body_segment_at(spawn_pos: Vector2):
	var new_segment = create_colored_segment(spawn_pos)
	add_child(new_segment)
	snake_body_segments.append(new_segment)

func _start_game_over_sequence():
	var final_score = snake_body_segments.size() + 1
	# Check if the player has the martyrdom upgrade.
	if GameManager.martyrdom_unlocked:
		print("MARTYRDOM! A final, glorious harvest!")
		$UI/CountdownLabel.text = "MARTRYDOM! HARVEST OF " + str(get_effective_fruit_reward() * get_effective_max_fruits()) + "!"
		# Get a list of all fruit currently on the screen.
		var fruits_on_screen = get_tree().get_nodes_in_group("fruits")
		var segments_to_add = 0
		
		# For each fruit, calculate its value and add it to a total.
		for fruit in fruits_on_screen:
			if fruit is GoldenFruit:
				segments_to_add += 2
			elif fruit.has_method("ripen") and fruit.is_ripe:
				var multiplier = GameManager.patient_gardener_data[GameManager.patient_gardener_level]["multiplier"]
				segments_to_add += get_effective_fruit_reward() * multiplier
			else:
				segments_to_add += get_effective_fruit_reward()
			
		final_score += segments_to_add
		
		var last_pos = head.global_position
		if not snake_body_segments.is_empty():
			last_pos = snake_body_segments.back().global_position
			
		# Create a visual explosion of dummy segments
		for i in range(segments_to_add):
			var dummy_segment = body_scene.instantiate()
			# We don't add these to the main snake_body_segments array.
			# They are purely for show.
			dummy_segment.position = last_pos
			# Disable their collision so they don't cause issues
			dummy_segment.get_node("CollisionShape2D").disabled = true
			add_child(dummy_segment)
			
			# Create a tween to make them fly outwards and fade away
			var tween = create_tween()
			var end_pos = last_pos + Vector2(randf_range(-100, 100), randf_range(-100, 100))
			tween.tween_property(dummy_segment, "position", end_pos, 0.5)
			tween.parallel().tween_property(dummy_segment, "modulate:a", 0.0, 0.5)
			tween.tween_callback(dummy_segment.queue_free)

		# Update the score MANUALLY based on the martyrdom growth
		$UI/HUDContainer/BottomGrid/ScoreLabel.text = "Score: " + str(final_score)
		$UI/GameOverScreen.get_node("ScoreLabel").text = "Score: " + str(final_score)
		# Add a cool visual effect here, like a screen flash!
		play_screen_flash(Color.CRIMSON)
		
		# Wait for the visual effect to play out
		await get_tree().create_timer(0.7).timeout

	# Now, proceed with the normal game over sequence.
	print("Game Over!")
	
	await SceneTransition.play_cover_animation("spiral")
	$UI/GameOverScreen.visible = true
	game_is_over.emit(final_score)
	await SceneTransition.uncover_screen("spiral")

func game_over():
	if GameManager.extra_lives > 0:
		use_extra_life()
		GameManager.has_died_this_garden = true
		return
		
	is_game_over = true
	head.move_timer.stop()
		
	call_deferred("_start_game_over_sequence")

func get_effective_fruit_reward() -> int:
	var reward = GameManager.fruit_reward
	# If we have the upgrade, add the bonus from our death counter
	if GameManager.death_defied_unlocked:
		reward += GameManager.times_died_this_run
		
	if GameManager.dragon_fruit_buff_active:
		reward *= 3
		
	return reward

func get_effective_max_fruits() -> int:
	var max_fruits = GameManager.max_fruits_on_screen
	# If we have the upgrade, add the bonus from our death counter
	if GameManager.death_defied_unlocked:
		max_fruits += GameManager.times_died_this_run
		
	if GameManager.iron_cherry_buff_active:
		max_fruits += 5 # Add a flat bonus	
		
	return max_fruits

func use_extra_life():
	GameManager.times_died_this_run += 1
	GameManager.has_died_this_garden = true
	print("Used an extra life!")
	
	var segments_before_death = snake_body_segments.size()
	
	# 1. Stop the snake and start the fade to black
	head.move_timer.stop()
	await SceneTransition.cover_screen("diagonal")

	# 2. While the screen is black, safely reset everything
	GameManager.extra_lives -= 1
	update_hud()
	
	while snake_body_segments.size() > 0:
		var segment_to_remove = snake_body_segments.pop_back()
		segment_to_remove.queue_free()
	
	if GameManager.phoenix_dawn_unlocked:
		var segments_lost = segments_before_death - snake_body_segments.size()
		# Store 25% of the lost amount, rounded down
		GameManager.segments_to_restore = floor(segments_lost * 0.25)
		print("Phoenix Dawn active! %s segments will be restored." % GameManager.segments_to_restore)
	
	
	var start_grid_pos = Vector2(grid_width / 4.0, grid_height / 4.0)
	head.position = (start_grid_pos * tile_size) + tile_offset
	on_snake_head_moved(head.position)
	
	# After resetting the snake, check if we need to add more fruit
	# because of the Death Defied buff.
	var current_fruit_count = get_tree().get_nodes_in_group("fruits").size()
	var target_fruit_count = get_effective_max_fruits() # Use our smart helper
	var fruits_to_spawn = target_fruit_count - current_fruit_count
	
	if fruits_to_spawn > 0:
		print("Death Defied grants %s extra fruit!" % fruits_to_spawn)
		for i in range(fruits_to_spawn):
			spawn_fruit(next_fruit_position)
	
	
	# 3. Give a moment of invincibility
	GameManager.is_phasing = true
	head.get_node("PhaseTimer").start()
	head.get_node("FillSprite").modulate = Color.GOLD
	
	# 4. Now that everything is reset, fade the screen back in
	await SceneTransition.uncover_screen("diagonal")
	
	# 5. Start the countdown
	start_countdown()



func create_colored_segment(next_pos: Vector2) -> Node2D:
	var segment = body_scene.instantiate()
	segment.position = next_pos
	# It no longer sets the color itself.
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
	var grid_pos = (check_pos - tile_offset) / tile_size
	if grid_pos.x < 0 or grid_pos.x >= grid_width or \
	   grid_pos.y < 0 or grid_pos.y >= grid_height:
		return true
	return false

func start_countdown() -> void:
	var countdown = $UI/CountdownLabel
	countdown.visible = true
	# START THE COUNTDOWN
	countdown.text = "3"
	await get_tree().create_timer(0.5).timeout
	countdown.text = "2"
	await get_tree().create_timer(0.5).timeout
	countdown.text = "1"
	await get_tree().create_timer(0.5).timeout
	# GIVE THE GAME SOME PERSONALITY AND RANDOMNESS
	var go_messages = ["SNAKE OFF!", "GET GROWING", "FEED THE BEAST!", "MUNCHA MUNCHA", "FEEL THE BURN", "I CAN'T HEAR YOU", "0, -1, jk"]
	countdown.text = go_messages.pick_random()
	await get_tree().create_timer(0.5).timeout
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





func update_tail_visuals():
	var ghost_segment_count = GameManager.ghost_tail_data[GameManager.ghost_tail_level]
	var total_segments = snake_body_segments.size()
	var ghost_color = Color("AFEEEE60") # transparent, pale turquoise
	
	if GameManager.masters_blueprint_unlocked:
		var blueprint_glow_color = Color("AFEEEE")
		for segment in snake_body_segments:
			segment.get_node("FillSprite").modulate = blueprint_glow_color
		return # IMPORTANT: Stop here!
	
	else:
		update_snake_visuals_from_chroma()
		# Loop through all segments and set their state
		for i in range(total_segments):
			var segment = snake_body_segments[i]
			# Get references to the nodes we need to change
			var fill_sprite = segment.get_node_or_null("FillSprite")
			var collision_shape = segment.get_node_or_null("CollisionShape2D")

			# This check is crucial to prevent crashes if a node is missing
			if not is_instance_valid(fill_sprite) or not is_instance_valid(collision_shape):
				continue
			
			
			# --- FRACTURED SELF LOGIC ---
			# First, we check if we have the ultimate upgrade.
			if GameManager.fractured_self_unlocked:
				# "3 solid, 3 blank" idea.
				# We use integer division and the modulo operator to find the chunk number.
				var chunk_index = i / 3.0
				if chunk_index % 2 != 0: # Every other chunk is invisible
					segment.visible = false
					collision_shape.disabled = true
					continue # Skip the rest of the logic for this invisible segment
				else:
					# If it's part of a visible chunk, make sure it's enabled.
					segment.visible = true
					collision_shape.disabled = false
			
			
			
			# Check if this segment should be a ghost using the same logic as our collision check
			var is_ghost = (i >= total_segments - ghost_segment_count)
		
			if is_ghost:
				# --- GHOST STATE ---
				fill_sprite.modulate = ghost_color
				# FIX: Use set_deferred to safely disable the collision shape.
				collision_shape.set_deferred("disabled", true)
			else:
				# --- SOLID STATE ---
				# Restore original color based on your Chroma Scales settings.
				update_snake_visuals_from_chroma() # Assuming this helper exists and works
				# FIX: Use set_deferred to safely re-enable the collision shape.
				collision_shape.set_deferred("disabled", false)

func perform_garden_weave():
	print("GARDEN WEAVER ACTIVATED!")
	
	GameManager.garden_weaver_used_this_garden = true
	update_hud()

	# 1. Get a list of all current fruit nodes.
	var fruit_nodes = get_tree().get_nodes_in_group("fruits")
	
	# 2. This array will keep track of the new positions we've chosen
	#    to prevent spawning two fruits in the same new spot.
	var new_positions = []
	
	play_screen_flash(Color.RED)

	# 3. Loop through each existing fruit and give it a new home.
	for fruit in fruit_nodes:
		# We find a new safe position, making sure to avoid spots
		# we've already assigned to other fruits in this same frame.
		var new_pos = calculate_safe_spawn_position(new_positions)
		fruit.position = new_pos
		new_positions.append(new_pos) # Add this spot to our list of claimed spots

	# 4. Now that all real fruit have been moved, update the ghost's prediction.
	update_fruit_prediction()


func activate_zenith():
	print("ZENITH ACTIVATED!")
	
	# 1. Set the state
	GameManager.is_zenith_active = true
	GameManager.current_combo = 10 # Instantly set combo to 10
	
	update_hud()
	
	# 3. Stop any existing combo timer and start the new Zenith timer
	$ComboTimer.stop()
	$ZenithTimer.start(10.0) # 10-second duration
	
	# 4. Give some awesome visual feedback
	play_screen_flash(Color.MAGENTA)
	
	if snake_body_segments.size() + 1 >= GameManager.garden_data[GameManager.current_garden]["score_goal"]:
		$ZenithTimer.stop()


func activate_banana_bounty():
	var all_fruits = get_tree().get_nodes_in_group("fruits")
	if all_fruits.is_empty(): return

	print("BANANA BOUNTY ACTIVATED!")
	GameManager.is_bounty_active = true
	
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

func perform_mise_en_place():
	print("MISE EN PLACE! The garden transforms!")
	
	# Set the flag so it can't be used again this run
	GameManager.mise_en_place_used_this_run = true
	update_hud() # Update any UI that might show the ability is used

	# 1. First, build a list of all normal fruits and their positions.
	var normal_fruits_to_replace = []
	for fruit in get_tree().get_nodes_in_group("fruits"):
		# We only want to transform the basic "Fruit" type
		if fruit is Fruit:
			normal_fruits_to_replace.append(fruit)
			
	# 2. Build a "loot table" of all the special fruits the player has unlocked.
	var unlocked_special_fruits = []
	# Add Golden Apple if unlocked
	if GameManager.golden_seed_extract_level > 0:
		unlocked_special_fruits.append("golden_fruit")
	# Add all unlocked Exotic Seeds
	for i in range(1, GameManager.exotic_seeds_level + 1):
		unlocked_special_fruits.append(GameManager.exotic_seeds_data[i])
		
	# If there are no special fruits unlocked, we can't do anything.
	if unlocked_special_fruits.is_empty():
		return

	# 3. Now, loop through the fruits we need to replace.
	for old_fruit in normal_fruits_to_replace:
		var new_fruit_key = unlocked_special_fruits.pick_random()
		var new_fruit_instance = null
		
		# Instantiate the correct new fruit scene
		match new_fruit_key:
			"golden_fruit": new_fruit_instance = preload("res://Scenes/Fruits/golden_fruit.tscn").instantiate()
			"jumping_bean": new_fruit_instance = jumping_bean_scene.instantiate()
			"ghost_pepper": new_fruit_instance = ghost_pepper_scene.instantiate()
			"iron_cherry": new_fruit_instance = iron_cherry_scene.instantiate()
			"dragon_fruit": new_fruit_instance = dragon_fruit_scene.instantiate()
			
		if new_fruit_instance != null:
			# Position the new fruit exactly where the old one was
			new_fruit_instance.position = old_fruit.position
			new_fruit_instance.add_to_group("fruits")
			add_child(new_fruit_instance)
			
			# Destroy the old fruit
			old_fruit.queue_free()
			
	# Add a cool screen flash to signify the transformation!
	play_screen_flash(Color.WHITE)



func perform_autotomy(collided_segment):
	print("SEVERING TAIL!")
	# First, find the index of the segment we hit in our array
	var hit_index = snake_body_segments.find(collided_segment)
	
	# If for some reason we couldn't find it, stop to prevent a crash
	if hit_index == -1:
		return
		
	# Now, loop from the end of the array down to the segment we hit
	while snake_body_segments.size() > hit_index:
		# Remove the last segment from the array and delete it from the game
		var segment_to_remove = snake_body_segments.pop_back()
		segment_to_remove.queue_free()
		
	# Update the score and HUD to reflect the shorter snake
	update_hud()

func create_pocket_garden():
	var level = GameManager.pocket_garden_level
	var rules = GameManager.pocket_garden_data[level]
	var segment_cost = rules["cost"]
	
	if snake_body_segments.size() < segment_cost:
		print("Not enough segments!")
		return

	update_hud()
	for i in range(segment_cost):
		snake_body_segments.pop_back().queue_free()
	update_hud()

	var garden_size = Vector2(5 * tile_size, 5 * tile_size)
	var garden_pos = head.global_position - (garden_size / 2)
	var garden_rect = Rect2(garden_pos, garden_size)

	# --- edge case
	# Clear any obstacles or fruit that are inside the new garden's area
	for rock in get_tree().get_nodes_in_group("rocks"):
		if garden_rect.has_point(rock.position):
			rock.queue_free()
	for fruit in get_tree().get_nodes_in_group("fruits"):
		if garden_rect.has_point(fruit.position):
			fruit.queue_free()
	
	# Now create the visual and store the rect
	var garden_vis = ColorRect.new()
	garden_vis.color = Color("DARK_GREEN", 0.5)
	garden_vis.size = garden_size
	garden_vis.position = garden_pos
	$PocketGardenContainer.add_child(garden_vis)
	
	GameManager.active_pocket_garden_rect = garden_rect
	$PocketGardenTimer.start(rules["duration"])

func _on_pocket_garden_timer_timeout():
	print("Pocket Garden has faded.")
	# Reset the global variable
	GameManager.active_pocket_garden_rect = null
	for child in $PocketGardenContainer.get_children():
		child.queue_free()

func perform_juice_press():
	# This ability is once per garden. Let's check if it's been used.
	if GameManager.juice_press_used_this_garden:
		print("Juice Press already used this garden!")
		# Give the charge back since it failed
		GameManager.ability_charges["Juice Press"].current += 1
		return

	print("JUICE PRESS! Converting all Pulp to Juice.")
	GameManager.juice_press_used_this_garden = true

	# Calculate the conversion at a 5:1 ratio
	var juice_gained = floori(GameManager.pulp / 5.0)
	GameManager.juice += juice_gained

	# Reset Pulp to 0
	GameManager.pulp = 0

	play_screen_flash(Color.ORANGE)




func perform_sacrificial_molt():
	var current_body_length = snake_body_segments.size()
	
	# We need at least 2 body segments to be able to halve it.
	if current_body_length < 2:
		print("Molt failed: Snake is too short!")
		return

	print("SACRIFICIAL MOLT ACTIVATED!")
	
	# Set the flag so it can't be used again this run
	GameManager.sacrificial_molt_used_this_run = true
	
	# 1. Calculate how many segments to remove
	var segments_to_remove = floor(current_body_length / 2.0)
	
	# 2. Loop that many times, destroying the tail
	for i in range(segments_to_remove):
		# Make sure we don't try to remove from an empty array
		if not snake_body_segments.is_empty():
			snake_body_segments.pop_back().queue_free()

	# 3. Grant the reward
	GameManager.extra_lives += 1
	
	# 4. Update all UI to reflect the changes
	update_hud()
	
	# Optional: Add a cool visual/sound effect here!
	# --- NEW VISUAL FEEDBACK ---
	# Play our new screen flash effect
	play_screen_flash(Color.GOLD)
	
	# Also make the snake's head pulse with golden light
	var head_tween = create_tween()
	head_tween.tween_property(head, "modulate", Color.ORANGE_RED, 0.2)
	# After a short delay, fade it back to its normal color
	head_tween.tween_property(head, "modulate", head.head_color, 0.3).set_delay(0.2)
	

func activate_burrow():
	# This toggles the burrow state on and off
	GameManager.burrow_is_active = not GameManager.burrow_is_active
	head.reset_head_color()

func perform_blink():
	var blink_path = []
	for i in range(1, 4):
		var check_pos = head.global_position + (head.current_direction * (i * tile_size))
		blink_path.append(check_pos)

	for pos in blink_path:
		var grid_pos = Vector2i((pos - tile_offset) / tile_size)
		if is_position_out_of_bounds(pos) or is_position_on_dividing_wall(grid_pos) or is_position_occupied(pos):
			print("Blink failed: Path is blocked.")
			# Give the charge back because the ability failed.
			GameManager.ability_charges["Blink"] += 1
			return

	# If the path is clear, perform the teleport.
	var destination = blink_path.back()
	var old_positions = [head.global_position]
	for segment in snake_body_segments:
		old_positions.append(segment.global_position)
	
	head.global_position = destination
	for i in range(snake_body_segments.size()):
		snake_body_segments[i].global_position = old_positions[i]
		
	update_tail_visuals()
	play_screen_flash(Color.WHITE)
	
		
func is_on_border(world_pos: Vector2) -> bool:
	# First, convert the world position (like 320, 256) back to a grid coordinate (like 10, 8).
	# We subtract the tile_offset to get the top-left corner before dividing.
	var grid_pos = Vector2i((world_pos - tile_offset) / tile_size)
	
	# Now, check if the grid position is within 3 tiles of any edge.
	# The valid grid is from 0 to width-1 and 0 to height-1.
	if grid_pos.x < 3 or grid_pos.x >= grid_width - 3 or \
	   grid_pos.y < 3 or grid_pos.y >= grid_height - 3:
		return true # It's on the border!
		
	# If it's not near any edge, it's in the center.
	return false


func play_screen_flash(flash_color: Color):
	var flash_overlay = $UI/FlashOverlay
	
	# Set the color and make it semi-transparent
	flash_overlay.color = Color(flash_color.r, flash_color.g, flash_color.b, 0.4)
	flash_overlay.visible = true
	
	
	
	# Create an animation to fade it out quickly
	var tween = create_tween()
	tween.tween_property(flash_overlay, "color:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
	# When the animation finishes, hide the overlay again
	tween.tween_callback(flash_overlay.hide)

func destroy_body_segment(segment_node):
	# safely removes a single snake segment.
	
	# 1. Check if the segment is still valid and in our array.
	if is_instance_valid(segment_node) and segment_node in snake_body_segments:
		# 2. Remove it from our tracking array.
		snake_body_segments.erase(segment_node)
		
		# 3. Add a cool effect and delete it for good.
		var tween = create_tween()
		tween.tween_property(segment_node, "scale", Vector2.ZERO, 0.2)
		tween.tween_callback(segment_node.queue_free)
		
		# 4. Update the score to reflect the shorter snake.
		update_hud()


func pick_new_recipe():
	# This function only runs if the cookbook is unlocked.
	if not GameManager.the_cookbook_unlocked:
		return

	# Create a pool of available recipes
	var available_recipes = GameManager.basic_recipes
	# If the player has Expanded Palate, add the exotic recipes to the pool
	if GameManager.expanded_palate_unlocked:
		available_recipes += GameManager.exotic_recipes
		
	# Pick a random recipe from the pool
	GameManager.active_recipe = available_recipes.pick_random()
	# Reset the progress for the new recipe
	GameManager.recipe_progress = 0
	
	print("New Recipe: ", GameManager.active_recipe["name"])



# This function is called from apply_recipe_buff
func start_fruit_flood(duration: float):
	print("FRUIT FLOOD activated for %s seconds!" % duration)
	# Start both timers
	$FruitFloodTickTimer.start()
	$FruitFloodDurationTimer.start(duration)

# This runs every 1 second while the flood is active
func _on_fruit_flood_tick_timer_timeout():
	print("Fruit flood tick!")
	# Spawn one extra fruit
	spawn_fruit(next_fruit_position)
	update_fruit_prediction() # Update the ghost for the next spawn

# This runs when the total duration is over
func _on_fruit_flood_duration_timer_timeout():
	print("Fruit flood has ended.")
	# Stop the ticking timer
	$FruitFloodTickTimer.stop()



func _on_iron_cherry_buff_timer_timeout():
	GameManager.iron_cherry_buff_active = false
	print("Iron Cherry buff has expired.")

func _on_dragon_fruit_buff_timer_timeout():
	GameManager.dragon_fruit_buff_active = false
	print("Dragon Fruit buff has expired.")


func perform_lasso_larry():
	print("LASSO LARRY! YEEHAW!")
	
	var lasso_data = GameManager.ability_charges.get("Lasso Larry", {"total": 0})
	var fruits_to_pull = lasso_data.total
	var all_fruits = get_tree().get_nodes_in_group("fruits")
	
	# Sort all fruits by their distance to the snake's head
	all_fruits.sort_custom(func(a, b): return a.global_position.distance_to(head.global_position) < b.global_position.distance_to(head.global_position))
	
	var pending_positions = []
	
	# Loop through the closest fruits and move them
	for i in range(min(fruits_to_pull, all_fruits.size())):
		var fruit = all_fruits[i]
		
		# --- THIS IS THE FIX ---
		# We find a new safe spot, telling the function to avoid both the spots
		# we've already chosen AND the snake's head itself.
		var unsafe_spots = pending_positions + [head.global_position]
		var safe_spot = calculate_safe_spawn_position(unsafe_spots)
		
		# Move the fruit and add its new spot to our list
		fruit.position = safe_spot
		pending_positions.append(safe_spot)
			
	play_screen_flash(Color.SANDY_BROWN)

func _on_skip_garden_pressed():
	print("FAST-TRACK ACTIVATED!")

	# 1. Grant the bonus Juice
	GameManager.juice += 5
	GameManager.current_garden += 1 # Extra Fast Track increment

	# 2. Animate the shop sliding out
	await $UI/PulpsicleStand.animate_out()

	# 3. Call our existing function to transition to the next garden
	_go_to_next_garden()


func _calculate_passive_gps():
	# Start with the base value from Snake Clicker
	var total_gps = GameManager.snake_clicker_data[GameManager.snake_clicker_level]
	
	# Get Rich Quick (Acrobat)
	if GameManager.get_rich_quick_unlocked:
		var acrobat_upgrades = ["Slither Sauce", "Tenderizer", "Juke N Jive", "Afterburner", "Pop Rocks", "Autotomy"]
		var juice_spent = GameManager.get_total_juice_spent_in_path(acrobat_upgrades)
		total_gps += juice_spent * 0.1
		
	# Custom Aftertaste (Chef)
	if GameManager.custom_aftertaste_unlocked:
		var chef_upgrades = ["Golden Seed Extract", "Exotic Seeds", "The Cookbook", "Expanded Palate", "Golden Glaze", "Custom Cuisine", "Mise en Place"]
		var juice_spent = GameManager.get_total_juice_spent_in_path(chef_upgrades)
		total_gps += juice_spent * 0.1
		
	# Arcane Flow (Illusionist)
	if GameManager.arcane_flow_unlocked:
		var illusionist_upgrades = ["Ghost Tail", "Phase Shift", "Blink", "3 Card Monty", "Fractured Self", "Dazzle Pie"]
		var juice_spent = GameManager.get_total_juice_spent_in_path(illusionist_upgrades)
		total_gps += juice_spent * 0.1
	
	# --- NEW: Pulp Reactor Logic ---
	# Add the bonus from our Pulp reserves.
	if GameManager.pulp_reactor_unlocked:
		# We gain +1 GPS for every 100 Pulp we have.
		var pulp_bonus = floor(GameManager.pulp / 100.0)
		total_gps += pulp_bonus
		if pulp_bonus > 0:
			print("Pulp Bonus: ", pulp_bonus)
	
	
	# --- NEW: Unstable Metabolism Logic ---
	# Finally, check if we should double the total.
	#    This is applied last to make it as powerful as possible.
	if GameManager.unstable_metabolism_unlocked:
		total_gps *= 2.0
	
	
	# Store the final, calculated value in our global manager.
	GameManager.passive_gps = total_gps

func get_upgrade_rules(upgrade_key: String) -> Dictionary:
	for path_key in GameManager.upgrade_data:
		for sub_path_key in GameManager.upgrade_data[path_key]:
			var sub_path_data = GameManager.upgrade_data[path_key][sub_path_key]
			if sub_path_data.has(upgrade_key):
				var rules = sub_path_data[upgrade_key]
				rules["path"] = path_key
				rules["sub_path"] = sub_path_key
				return rules
	return {}

func check_prerequisites(upgrade_key: String) -> bool:
	var rules = get_upgrade_rules(upgrade_key)
	if not rules.has("prerequisite"): return true
	if rules.is_empty(): return false # Double check this line

	var prereq_data = rules["prerequisite"]
	if get_upgrade_level_from_key(prereq_data["upgrade"]) < prereq_data["level"]:
		return false
		
	if prereq_data.has("and") and get_upgrade_level_from_key(prereq_data["and"]) < prereq_data["and_level"]:
		return false
		
	return true

func calculate_upgrade_cost(upgrade_key: String) -> int:
	var rules = get_upgrade_rules(upgrade_key)
	var current_level = get_upgrade_level_from_key(upgrade_key)
	
	if current_level >= rules.max_level: return 999 # A high number for "unaffordable"
	
	var base_cost = rules.costs[current_level]
	var diff_mod = GameManager.difficulty_data[GameManager.chosen_difficulty]["juice_cost_modifier"]
	var class_mod = GameManager.class_data[GameManager.chosen_class]["cost_modifiers"][upgrade_key]
	var final_cost = base_cost + diff_mod + class_mod
	
	# Apply cost reduction upgrades
	if GameManager.three_card_monty_unlocked and upgrade_key != "3 Card Monty":
		final_cost -= 1
	if GameManager.market_crash_level > 0 and upgrade_key != "Market Crash":
		final_cost -= GameManager.market_crash_level
		
	return max(1, final_cost)



func get_upgrade_level_from_key(upgrade_key: String) -> int:
	if upgrade_key in GameManager.ability_charges:
		return GameManager.ability_charges[upgrade_key].total
	
	var var_name_level = upgrade_key.to_snake_case().replace(" ", "") + "_level"
	if var_name_level in GameManager:
		return GameManager.get(var_name_level)
		
	var var_name_unlocked = upgrade_key.to_snake_case().replace(" ", "") + "_unlocked"
	if var_name_unlocked in GameManager:
		return 1 if GameManager.get(var_name_unlocked) else 0

	return 0

func handle_upgrade_purchase(upgrade_key: String):
	# 1. Get all the necessary information using our other helpers.
	var rules = get_upgrade_rules(upgrade_key)
	var current_level = get_upgrade_level_from_key(upgrade_key)
	
	# 2. Check if the upgrade is already maxed out.
	if current_level >= rules.max_level:
		print("Cannot purchase, already at max level.")
		return
		
	# 3. Calculate the final cost.
	var cost = calculate_upgrade_cost(upgrade_key) # Assuming this helper exists and is correct
	
	# 4. Check if the player can afford it.
	if GameManager.juice >= cost and not current_level >= rules.max_level:
		print("Purchase successful: ", upgrade_key)
		# The purchase is valid! Subtract the cost.
		GameManager.juice -= cost
		GameManager.juice_spent_this_garden += cost
		
		# Tell the game to apply the upgrade's effect.
		_on_upgrade_menu_upgrade_selected(upgrade_key) # This function now ONLY applies the effect
		
		# After the purchase, refresh the entire upgrade menu UI.
		# It's important to do this AFTER the effect has been applied.
		$UI/UpgradeMenu.update_all_displays()
	else:
		#--T0-DO-- Add a rejection notification
		#--			Add a delay on the animation and rejection with a wanh
		print("Cannot afford upgrade: ", upgrade_key)
