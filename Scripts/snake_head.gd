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
			main.activate_banana_bounty()
	
	if event.is_action_pressed("activate_ability_burrow"):
		if GameManager.burrow_level > 0 and GameManager.burrow_charges > 0 and not GameManager.burrow_is_active:
			GameManager.burrow_is_active = true
			GameManager.burrow_charges -= 1
			get_node("FillSprite").modulate = Color.WHITE
			if GameManager.chosen_class == "sidewinder" and randi() % 100 < 25:
				GameManager.burrow_charges += 1
			main.update_hud()
			
	if event.is_action_pressed("activate_phase_shift"):
		if GameManager.phase_shift_level > 0 and GameManager.phase_shift_charges > 0 and not GameManager.is_phasing:
			GameManager.is_phasing = true
			GameManager.phase_shift_charges -= 1
			phase_timer.start()
			get_node("FillSprite").modulate = Color.MEDIUM_VIOLET_RED
			if GameManager.chosen_class == "sidewinder" and randi() % 100 < 25:
				GameManager.phase_shift_charges += 1
			main.update_hud()
			
	if event.is_action_pressed("activate_meditation"):
		if GameManager.meditative_state_level > 0 and GameManager.meditative_state_charges > 0:
			GameManager.meditative_state_charges -= 1
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
			$AutotomyTimer.start(2.0) # Start the 2-second window
			# Visual Feedback
			get_node("FillSprite").modulate = Color.ORANGE_RED
			
	if event.is_action_pressed("activate_pocket_garden"):
		if GameManager.pocket_garden_charges > 0:
			main.create_pocket_garden()
			

# --- GAME LOGIC & MOVEMENT ---
func on_move_timer_timeout():
	var next_position = global_position + (current_direction * tile_size)
	var next_grid_pos = Vector2i((next_position - main.tile_offset) / main.tile_size)
	
	
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
	if area is Fruit or area is GoldenFruit:
		emit_signal("ate_fruit", area)
		return
	
	if area.is_in_group("dividng_walls"):
		emit_signal("hit_self")
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
	
		
	if area is Rock:
		if GameManager.tenderizer_charges > 0:
			GameManager.tenderizer_charges -= 1
			main.update_hud()
			main.destroy_obstacle(area)
		else:
			emit_signal("hit_self")
		return

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
	if not GameManager.is_phasing and not juke_and_jive_is_active and not GameManager.burrow_is_active and not GameManager.autotomy_is_active:
		get_node("FillSprite").modulate = head_color
