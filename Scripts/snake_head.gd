extends CharacterBody2D

signal moved(previous_position: Vector2)
signal ate_fruit(fruit)
signal hit_self

# --- Properties ---
@export var head_color: Color = Color.LIME_GREEN

var normal_move_speed: float = 0.0

var move_speed: float = 0.25 # This will be set by main.gd
var current_direction: Vector2 = Vector2.RIGHT
var can_change_direction: bool = true
var can_reverse: bool = true
var main: Node2D # A reference to the main game script
var tile_size = 32

# --- Juke & Jive Properties ---
var juke_inputs: int = 0
var juke_and_jive_is_active: bool = false

# --- NODE REFERENCES ---
@onready var move_timer: Timer = $MoveTimer
@onready var head_area: Area2D = $HeadArea
@onready var juke_timer: Timer = $JukeTimer
@onready var juke_duration_timer: Timer = $JukeDurationTimer
@onready var phase_timer: Timer = $PhaseTimer
@onready var meditative_state_timer: Timer = $MeditativeStateTimer
@onready var afterburner_timer: Timer = $AfterburnerTimer
@onready var autotomy_timer: Timer = $AutotomyTimer 
#------Overdrive--------
@onready var overdrive_particles = $OverdriveParticles
var is_overdrive_active = false
#--------THE ROCKEATERS--------#
@onready var kinetic_feast_timer: Timer = $KineticFeastTimer
@onready var stones_burden_timer: Timer = $StonesBurdenTimer

@onready var temp_speed_boost_timer: Timer = $TempSpeedBoostTimer

# --- GODOT'S BUILT-IN FUNCTIONS ---

func _ready():
	get_node("FillSprite").modulate = head_color
	
	# Connect all timers to their respective functions
	move_timer.timeout.connect(on_move_timer_timeout)
	afterburner_timer.timeout.connect(_on_afterburner_timer_timeout)
	juke_timer.timeout.connect(_on_juke_timer_timeout)
	juke_duration_timer.timeout.connect(_on_juke_duration_timer_timeout)
	phase_timer.timeout.connect(_on_phase_timer_timeout)
	meditative_state_timer.timeout.connect(_on_meditative_state_timer_timeout)
	autotomy_timer.timeout.connect(_on_autotomy_timer_timeout)
	kinetic_feast_timer.timeout.connect(_on_kinetic_feast_timer_timeout)
	stones_burden_timer.timeout.connect(_on_stones_burden_timer_timeout)
	temp_speed_boost_timer.timeout.connect(_on_temp_speed_boost_timer_timeout)


func _process(_delta):

	# This ability only works if the player has unlocked it and has an active combo.
	if GameManager.overdrive_level == 0 or GameManager.current_combo == 0:
		# If the conditions aren't met, make sure Overdrive is turned off.
		if is_overdrive_active:
			deactivate_overdrive()
		return

	# Check if the player is holding the key for their current direction of travel.
	var is_holding_key = Input.is_action_pressed(get_direction_action(current_direction))

	if is_holding_key and not is_overdrive_active:
		# If they are holding the key and the boost isn't active yet, turn it on.
		activate_overdrive()
	elif not is_holding_key and is_overdrive_active:
		# If they release the key and the boost is active, turn it off.
		deactivate_overdrive()
		
		#---jug--------------------------------------
	

# new helper function to get the action name ("ui_up", etc.) from a Vector2
func get_direction_action(direction: Vector2) -> String:
	if direction == Vector2.UP: return "up"
	if direction == Vector2.DOWN: return "down"
	if direction == Vector2.LEFT: return "left"
	if direction == Vector2.RIGHT: return "right"
	return ""




func _unhandled_input(event: InputEvent):
	if not can_change_direction:
		return

	# --- Directional Input Logic ---
	var new_direction = current_direction
	if can_reverse:
		if event.is_action_pressed("up"): new_direction = Vector2.UP
		elif event.is_action_pressed("down"): new_direction = Vector2.DOWN
		elif event.is_action_pressed("left"): new_direction = Vector2.LEFT
		elif event.is_action_pressed("right"): new_direction = Vector2.RIGHT
	else:
		if event.is_action_pressed("up") and current_direction != Vector2.DOWN: new_direction = Vector2.UP
		elif event.is_action_pressed("down") and current_direction != Vector2.UP: new_direction = Vector2.DOWN
		elif event.is_action_pressed("left") and current_direction != Vector2.RIGHT: new_direction = Vector2.LEFT
		elif event.is_action_pressed("right") and current_direction != Vector2.LEFT: new_direction = Vector2.RIGHT
	
	if new_direction != current_direction:
		current_direction = new_direction
		can_change_direction = false
		handle_juke_and_jive()

	# --- Ability Activation Logic ---
	if event.is_action_pressed("activate_bounty"):
		if GameManager.banana_bounty_charges > 0 and not GameManager.is_bounty_active:
			GameManager.abilities_used_this_garden += 1
			main.activate_banana_bounty()
	
	if event.is_action_pressed("activate_ability_burrow"):
		if GameManager.burrow_level > 0 and GameManager.burrow_charges > 0 and not GameManager.burrow_is_active:
			GameManager.burrow_is_active = true
			GameManager.burrow_charges -= 1
			GameManager.abilities_used_this_garden += 1
			get_node("FillSprite").modulate = Color.WHITE
			if GameManager.chosen_class == "sidewinder" and randi() % 100 < 25:
				GameManager.burrow_charges += 1
			main.update_hud()
			
	if event.is_action_pressed("activate_phase_shift"):
		if GameManager.phase_shift_level > 0 and GameManager.phase_shift_charges > 0 and not GameManager.is_phasing:
			GameManager.is_phasing = true
			GameManager.phase_shift_charges -= 1
			GameManager.abilities_used_this_garden += 1
			activate_phase_shift(2.0)
			if GameManager.chosen_class == "sidewinder" and randi() % 100 < 25:
				GameManager.phase_shift_charges += 1
			main.update_hud()
			
	if event.is_action_pressed("activate_meditation"):
		if GameManager.meditative_state_level > 0 and GameManager.meditative_state_charges > 0:
			GameManager.meditative_state_charges -= 1
			GameManager.abilities_used_this_garden += 1
			main.update_hud()
			move_timer.stop()
			var duration = GameManager.meditative_state_data[GameManager.meditative_state_level]
			meditative_state_timer.wait_time = duration
			meditative_state_timer.start()
			get_node("FillSprite").modulate = Color.DEEP_SKY_BLUE
	
	if event.is_action_pressed("activate_autotomy"):
	# Check if the ability is unlocked, hasn't been used this garden, and isn't already active
		if GameManager.autotomy_unlocked and not GameManager.autotomy_used_this_garden and not GameManager.autotomy_is_active:
			print("AUTOTOMY ACTIVATED! You have 2 seconds to sever your tail.")
			GameManager.autotomy_is_active = true
			GameManager.abilities_used_this_garden += 1
			$AutotomyTimer.start(2.0) # Start the 2-second window
			# Visual Feedback
			get_node("FillSprite").modulate = Color.ORANGE_RED
			
	if event.is_action_pressed("activate_pocket_garden"):
		if GameManager.pocket_garden_charges > 0:
			GameManager.abilities_used_this_garden += 1
			main.create_pocket_garden()
			
	if event.is_action_pressed("activate_molt"):
		# Check all conditions before allowing the ability to fire
		if GameManager.sacrificial_molt_unlocked and not GameManager.sacrificial_molt_used_this_run:
			GameManager.abilities_used_this_garden += 1
			main.perform_sacrificial_molt()
			
	if event.is_action_pressed("activate_blink"):
		if GameManager.blink_charges > 0:
			GameManager.abilities_used_this_garden += 1
			main.perform_blink()
			
	if event.is_action_pressed("activate_zenith"):
		# Check if we have charges and the ability isn't already active
		if GameManager.zenith_charges > 0 and not GameManager.is_zenith_active:
			GameManager.abilities_used_this_garden += 1
			main.activate_zenith()
			
	if event.is_action_released("activate_mise_en_place"):
		if GameManager.mise_en_place_unlocked and not GameManager.mise_en_place_used_this_run:
			GameManager.abilities_used_this_garden += 1
			main.perform_mise_en_place()
			

# --- GAME LOGIC & MOVEMENT ---
func on_move_timer_timeout():
	var next_position = global_position + (current_direction * tile_size)

	
	
	# --- Collision Checks ---


	if not GameManager.is_phasing and not juke_and_jive_is_active and main.is_position_occupied(next_position):
		emit_signal("hit_self")
		return
	
	
	if main.is_position_out_of_bounds(next_position):
		if GameManager.fold_space_unlocked:
			var grid_pos = (next_position - main.tile_offset) / main.tile_size
			if grid_pos.x < 0: grid_pos.x = main.grid_width - 1
			if grid_pos.x >= main.grid_width: grid_pos.x = 0
			if grid_pos.y < 0: grid_pos.y = main.grid_height - 1
			if grid_pos.y >= main.grid_height: grid_pos.y = 0
			next_position = (grid_pos * tile_size) + main.tile_offset
		
		elif GameManager.burrow_is_active:
			var grid_pos = (next_position / tile_size).round()
			if grid_pos.x < 0: grid_pos.x = main.grid_width - 1
			if grid_pos.x >= main.grid_width: grid_pos.x = 0
			if grid_pos.y < 0: grid_pos.y = main.grid_height - 1
			if grid_pos.y >= main.grid_height: grid_pos.y = 0
			next_position = (grid_pos * tile_size) + main.tile_offset
			GameManager.burrow_is_active = false
			main.update_hud()
			reset_head_color()
		else:
			emit_signal("hit_self")
			return

	# If all checks pass, it's safe to move.
	var previous_position = global_position
	global_position = next_position
	moved.emit(previous_position)
	can_change_direction = true

# --- SIGNAL HANDLERS ---
func _on_head_area_area_entered(area):
	
	if main.is_game_over:
		return
	
	if area is Fruit or area is GoldenFruit or area is JumpingBean or area is GhostPepper or area is IronCherry or area is DragonFruit:
		emit_signal("ate_fruit", area)
		return
	
	
	
	if area is SnakeBody:
		# Check all invulnerability states
		if not GameManager.is_phasing and not juke_and_jive_is_active:
				
			if GameManager.autotomy_is_active:
				main.perform_autotomy(area)
				GameManager.autotomy_is_active = false
				GameManager.autotomy_used_this_garden = true
				$AutotomyTimer.stop()
				reset_head_color()

			
			else:
				emit_signal("hit_self")
				return
	
	if area.is_in_group("dividng_walls"):
		emit_signal("hit_self")
		return
		
	if area is Rock:
		var chosen_path = GameManager.rockeater_type
		
		if chosen_path != "":
			main.destroy_obstacle(area)
			
			match chosen_path:
				"Rockmuncher":
					print("ROCKMUNCHER! Gained +2 growth")
					main.grow_snake(2)
				"Geode Cracker":
					print("GEODE CRACKER! Gained + 1 SP")
				"Kinetic Feast":
					activate_kinetic_feast()
				"Stones Burden":
					activate_stones_burden()
		
		elif GameManager.tenderizer_charges > 0:
			GameManager.tenderizer_charges -= 1
			main.update_hud()
			main.destroy_obstacle(area)
		else:
			emit_signal("hit_self")
		return

func activate_stones_burden():
	print("STONE'S BURDEN! Slow down and phase activated.")
	GameManager.is_phasing = true # Become intangible to self
	$FillSprite.modulate = Color.DARK_SLATE_GRAY
	# Temporarily make the move timer much slower.
	move_timer.wait_time *= 1.5 # 50% slower
	# Start a timer to turn it off.
	$StonesBurdenTimer.start(4.0)


func activate_kinetic_feast():
	print("KINETIC FEAST! Speed boost activated.")
	# Temporarily make the move timer faster.
	move_timer.wait_time *= 0.5 # 50% faster
	# Start a timer to turn it off.
	$KineticFeastTimer.start(3.0)

func activate_phase_shift(duration: float):
	# This function can now be called from anywhere to start a phase shift.
	
	# Don't do anything if we are already phasing, to prevent bugs.
	if GameManager.is_phasing:
		return
	
	
	print("PHASE SHIFTING for ", duration, " seconds!")
	GameManager.is_phasing = true
	$FillSprite.modulate = Color.DARK_MAGENTA
	# We set the timer's duration directly here before starting it.
	phase_timer.wait_time = duration
	phase_timer.start()


func activate_overdrive():
	print("OVERDRIVE ENGAGED!")
	is_overdrive_active = true
	# We temporarily make the move timer faster.
	move_timer.wait_time *= 0.5 # 50% faster

	# If we have level 2, turn on the cool particle effect!
	if GameManager.overdrive_level >= 2:
		overdrive_particles.emitting = true
		
func deactivate_overdrive():
	print("Overdrive disengaged.")
	is_overdrive_active = false
	# We restore the move timer to its normal speed.
	main.apply_persistent_upgrades()
	
	# Always turn off the particles when the boost ends.
	overdrive_particles.emitting = false



#------AFTERBURNER-----#
func check_for_afterburner():
	# Do nothing if the player doesn't have the upgrade.
	if GameManager.afterburner_level == 0:
		return
		
	# If the ability isn't already active, start it.
	if afterburner_timer.is_stopped():
		activate_afterburner()

# This function applies the speed boost.
func activate_afterburner():
	print("AFTERBURNER ACTIVATED!")
	normal_move_speed = move_timer.wait_time
	
	# Get the rules for our current level
	var current_level = GameManager.afterburner_level
	var rules = GameManager.afterburner_data[current_level]
	
	# Apply the correct boost and duration
	var boosted_speed = normal_move_speed * rules["boost"]
	move_timer.wait_time = boosted_speed
	afterburner_timer.start(rules["duration"])

# This function runs when the AfterburnerTimer finishes.
func _on_afterburner_timer_timeout():
	print("Afterburner finished.")
	# Restore the snake's speed to what it was before the boost.
	move_timer.wait_time = normal_move_speed



# --- JUKE & JIVE ---
func handle_juke_and_jive():
	if not GameManager.juke_and_jive_unlocked or juke_and_jive_is_active:
		return
	juke_timer.wait_time = move_speed * 3
	if juke_timer.is_stopped():
		juke_timer.start()
		juke_inputs = 1
	else:
		juke_inputs += 1
	if juke_inputs >= 4:
		juke_and_jive_is_active = true
		juke_duration_timer.start(move_speed * 5)
		get_node("FillSprite").modulate = Color.DEEP_SKY_BLUE
		juke_timer.stop()
		juke_inputs = 0

func _on_juke_timer_timeout():
	juke_inputs = 0

func _on_juke_duration_timer_timeout():
	juke_and_jive_is_active = false
	reset_head_color()

# --- OTHER ABILITY TIMEOUTS ---
func _on_phase_timer_timeout():
	GameManager.is_phasing = false
	reset_head_color()

func _on_meditative_state_timer_timeout():
	move_timer.start()
	reset_head_color()

func _on_autotomy_timer_timeout():
	GameManager.autotomy_is_active = false
	reset_head_color()

# helper function to safely reset the head color
func reset_head_color():
	
	# Only reset if no other ability is currently giving a color
	if not GameManager.is_phasing and not juke_and_jive_is_active and \
	not GameManager.burrow_is_active and not GameManager.autotomy_is_active:
		
		get_node("FillSprite").modulate = head_color


func _on_kinetic_feast_timer_timeout() -> void:
	print("Kinetic Feast has ended")
	main.apply_persistent_upgrades()


func _on_stones_burden_timer_timeout() -> void:
	GameManager.is_phasing = false
	reset_head_color()
	main.apply_persistent_upgrades()
	
	
func activate_temporary_speed_boost(speed_multiplier: float, duration: float):
	print("Recipe buff: SPEED BOOST for %s seconds!" % duration)
	
	# We apply the multiplier directly to the current wait_time
	move_timer.wait_time *= speed_multiplier
	
	# Start the timer to turn the effect off
	temp_speed_boost_timer.start(duration)

# This runs when the timer is up
func _on_temp_speed_boost_timer_timeout():
	print("Speed boost has ended.")
	# Restore the snake's speed to its normal, upgraded value
	main.apply_persistent_upgrades()
