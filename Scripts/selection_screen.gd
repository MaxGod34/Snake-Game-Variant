extends Control

@export var placeholder_icon: Texture2D
#--- DEBUGGING ---
@onready var debug_panel = $DebugPanel

@onready var tooltip_panel = $DescriptionPanel
@onready var tooltip_timer: Timer = $TooltipTimer

var hovered_type: String = ""
var hovered_key: String = ""

# --- NODE REFERENCES ---
# We'll get references to our main panels and the "Begin Run" button.
@onready var loadout_display_panel = $MarginContainer/MainLayout/LoadoutDisplayPanel
@onready var begin_run_button = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/ButtonRow/BeginRunButton
@onready var exit_button = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/ButtonRow/ExitButton
@onready var class_artwork = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/ClassTopRow/ClassInfoCol/ClassArtwork
@onready var class_name_label = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/ClassTopRow/ClassInfoCol/ClassNameLabel
@onready var class_description_label = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/ClassTopRow/ClassDescriptionLabel
@onready var difficulty_name_label = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/DifficultyNameLabel
@onready var difficulty_description_label = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/DifficultyDescriptionLabel


# This dictionary will store a reference to every single class node.
var class_nodes: Dictionary = {}

var difficulty_nodes: Dictionary = {}


# These variables will store the player's current choices.
var selected_class_key: String = ""
var selected_difficulty_key: String = ""

func _ready():
	# When the screen is ready, we build our node dictionary and connect the signals.
	_build_class_node_dictionary()
	_connect_all_class_nodes()
	_build_difficulty_node_dictionary()
	_connect_all_difficulty_nodes()
	begin_run_button.pressed.connect(_on_begin_run_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	#---debug panel---
	debug_panel.get_node("VBoxContainer/UnlockNextTierButton").pressed.connect(_on_debug_unlock_next_pact)
	debug_panel.get_node("VBoxContainer/ResetSaveButton").pressed.connect(_on_debug_reset_save)
	# We'll also want to update the display to its initial state.
	update_all_displays()
	tooltip_panel.visible = false
	tooltip_timer.timeout.connect(_on_tooltip_timer_timeout)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_F1"):
		debug_panel.visible = not debug_panel.visible


func _build_difficulty_node_dictionary():
	difficulty_nodes.clear()
	var diff_row = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/TierRow
	for i in range(0, 10):
		var tier_key = "Tier %d" % i
		var node = diff_row.find_child("Tier%dNode" % i, true, false)
		if is_instance_valid(node):
			difficulty_nodes[tier_key] = node
		else:
			print_debug("Warning: Could not find difficulty node: Tier%dNode" % i)
		
	
func _connect_all_difficulty_nodes():
	for pact_key in difficulty_nodes:
		var node = difficulty_nodes[pact_key]
		if is_instance_valid(node):
			node.pressed.connect(_on_difficulty_node_pressed.bind(pact_key))



func _build_class_node_dictionary():
	# It assumes nodes are named like "MulliganNode", "GlutsNode", etc.
	var grid = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/ClassGrid
	for class_key in GameManager.class_data.keys():
		var node_name = class_key.to_pascal_case() + "Node"
		var node = grid.find_child(node_name, false) # Set recursive to false for performance
		
		if is_instance_valid(node):
			class_nodes[class_key] = node
		else:
			# This warning is very helpful for debugging
			print_debug("Warning: Could not find class node named: ", node_name)

func _connect_all_class_nodes():
	for class_key in class_nodes:
		var node = class_nodes[class_key]
		if is_instance_valid(node):
			node.pressed.connect(_on_class_node_pressed.bind(class_key))
			node.mouse_entered.connect(_on_node_mouse_entered.bind("class", class_key))
			node.mouse_exited.connect(_on_node_mouse_exited)


func update_all_displays():
	update_class_roster()
	update_difficulty_pacts()
	update_loadout_display()
	begin_run_button.disabled = (selected_class_key == "" or selected_difficulty_key == "")

func update_class_roster():
	for class_key in class_nodes:
		var node = class_nodes[class_key]
		var class_data = GameManager.class_data[class_key]
		var is_unlocked = class_key in SaveManager.save_data.unlocked_classes

		# We now get the icon path directly from the data.
		if ResourceLoader.exists(class_data.icon_path):
			node.icon = load(class_data.icon_path)
		var dot_container = node.get_node_or_null("IndicatorContainer")
		dot_container.visible = false
		# We can use our UpgradeNode's update function for this!
		# We'll use a special theme color to show selection.
		var stylebox = StyleBoxFlat.new()
		stylebox.set_border_width_all(4)
		stylebox.bg_color = Color(0, 0, 0, 0)
		if class_key == selected_class_key:
			stylebox.border_color = Color.DEEP_SKY_BLUE
		else:
			stylebox.border_color = Color.TRANSPARENT # No border if not selected
		node.add_theme_stylebox_override("normal", stylebox)
		
		# Dim the icon if it's locked
		node.disabled = not is_unlocked
		if not is_unlocked:
			node.modulate = Color.DARK_GRAY
		else:
			node.modulate = Color.WHITE

func _on_class_node_pressed(class_key: String):
	print("Player selected class: ", class_key)
	# Set the new selected class.
	selected_class_key = class_key
	selected_difficulty_key = ""
	# And immediately update all the displays to reflect the change.
	update_all_displays()

func update_loadout_display():
	if selected_class_key == "":
		class_name_label.text = "Select a Class"
		class_description_label.text = "Choose your path for this run."
		class_artwork.texture = placeholder_icon
		difficulty_name_label.text = "Select a Tier"
		difficulty_description_label.text = "Choose a class first."
		return

	var class_data = GameManager.class_data.get(selected_class_key)
	if class_data:
		class_name_label.text = class_data.display_name
		class_description_label.text = _format_class_loadout(class_data)

		# Use custom artwork if it exists, otherwise fall back to the class icon
		if class_data.artwork_path != "" and ResourceLoader.exists(class_data.artwork_path):
			class_artwork.texture = load(class_data.artwork_path)
		elif class_data.icon_path != "" and ResourceLoader.exists(class_data.icon_path):
			class_artwork.texture = load(class_data.icon_path)
		else:
			class_artwork.texture = placeholder_icon

	if selected_difficulty_key == "":
		difficulty_name_label.text = "Select a Tier"
		difficulty_description_label.text = "Choose your challenge for this run."
	else:
		var diff_data = GameManager.difficulty_data.get(selected_difficulty_key)
		if diff_data:
			difficulty_name_label.text = "T%d: %s" % [diff_data.tier, diff_data.display_name]
			difficulty_description_label.text = _format_stacked_modifiers(diff_data.tier)
			

func _format_stacked_modifiers(max_tier: int) -> String:
	if max_tier == 0:
		var t0 = GameManager.difficulty_data.get("Tier 0")
		return t0.description if (t0 and t0.description != "") else "Base Difficulty. Have fun!"

	var lines: Array[String] = []
	for i in range(1, max_tier + 1):
		var tier_data = GameManager.difficulty_data.get("Tier %d" % i)
		if tier_data and tier_data.description != "":
			lines.append("| [T%d] %s |" % [i, tier_data.description])
	return "\n".join(lines)

func _format_class_loadout(class_data) -> String:
	var lines: Array[String] = []

	# 1. Starting Upgrades
	if not class_data.start_upgrades.is_empty():
		lines.append("Starting Upgrades:")
		for upgrade_key in class_data.start_upgrades:
			var lvl: int = int(class_data.start_upgrades[upgrade_key])
			lines.append("| %s (Lvl %d) |" % [upgrade_key, lvl] if lvl > 1 else "| %s |" % upgrade_key)

	# 2. Special Class Rules / Stats (mirrors GameManager.start_game)
	var rule_lines: Array[String] = []
	for stat_key in class_data.start_stats:
		var val = class_data.start_stats[stat_key]
		match stat_key:
			"extra_lives": rule_lines.append("| +%d Extra Lives |" % int(val))
			"max_fruits": rule_lines.append("| Starts with %d Max Fruits |" % int(val))
			"max_fruits_cap": rule_lines.append("| Max Fruits capped at %d |" % int(val))
			"fruit_reward_multiplier": rule_lines.append("| x%s Fruit Growth" % str(val))
			"juice_tax_rate": rule_lines.append("| -%d%% Juice Tax between gardens |" % int(round(val * 100)))
			"max_esp_level": rule_lines.append("| ESP capped at Lvl %d |" % int(val))
			"global_juice_cost_multiplier": rule_lines.append("| Upgrade Costs x%s |" % str(val))
			"speed_multiplier": rule_lines.append("| Move Speed x%s |" % str(val))
			"obstacle_modifier": rule_lines.append("| Rocks x%s |" % str(val))
			"disabled_paths": rule_lines.append("| Locked: %s |" % ", ".join(val))
			"juice_on_level_up_disabled": rule_lines.append("| No Juice from leveling up |")
			"juice_chance_on_eat": rule_lines.append("| %d%% chance for +1 Juice per fruit |" % int(round(val * 100)))
			"geological_survey_multiplies": rule_lines.append("| Geological Survey scales exponentially |")
			"all_fruits_special": rule_lines.append("| All fruits spawn Golden |")
			"speed_on_loss": rule_lines.append("| Speed increases on lost bets |")
			"speed_increase_on_eat": rule_lines.append("| Speed ramps up per fruit eaten |")
			"dynamic_max_fruits": rule_lines.append("| Max Fruits scales with Pulp |")
			"dynamic_fruit_reward": rule_lines.append("| Fruit Growth scales with Juice |")
			"gambling_disabled": rule_lines.append("| Snake Eyes disabled |")
			"juice_menu_disabled": rule_lines.append("| Upgrade Menu disabled (Rotating Items only) |")
			"pulp_gain_disabled": rule_lines.append("| Pulp gain disabled |")

	if not rule_lines.is_empty():
		if not lines.is_empty():
			lines.append("")
		lines.append("Class Rules:")
		lines.append_array(rule_lines)

	return "\n".join(lines) if not lines.is_empty() else "Standard Run"



func update_difficulty_pacts():
	var progress = { "cleared_tiers": [] }
	if selected_class_key != "":
		progress = SaveManager.get_progress_for_class(selected_class_key)

	var cleared_tiers: Array = progress.get("cleared_tiers", [])

	for tier_key in difficulty_nodes:
		var node = difficulty_nodes[tier_key]
		var rules = GameManager.difficulty_data.get(tier_key)
		if not rules:
			continue

		var tier_num: int = rules.tier
		var is_completed: bool = (tier_num in cleared_tiers)
		# Tier 0 is always unlocked once a class is picked; Tier N unlocks after clearing Tier N-1
		var is_locked: bool = (selected_class_key == "") or\
			 					(tier_num > 0 and not ((tier_num - 1) in cleared_tiers))

		if ResourceLoader.exists(rules.icon_path):
			node.icon = load(rules.icon_path)

		var stylebox = StyleBoxFlat.new()
		stylebox.set_border_width_all(4)
		stylebox.bg_color = Color(0, 0, 0, 0)
		if tier_key == selected_difficulty_key:
			stylebox.border_color = Color.DEEP_SKY_BLUE
		elif is_completed:
			stylebox.border_color = Color.GOLD
		else:
			stylebox.border_color = Color.TRANSPARENT

		node.add_theme_stylebox_override("normal", stylebox)
		node.disabled = is_locked
		node.modulate = Color.WHITE if not is_locked else Color.DARK_GRAY
	
func _on_difficulty_node_pressed(pact_key: String):
	print("Player selected difficulty: ", pact_key)
	selected_difficulty_key = pact_key
	update_all_displays()

func _on_exit_button_pressed():
	SceneTransition.transition_to("res://Scenes/Menus/main_menu.tscn")

func _on_begin_run_button_pressed():
	# safety check to make sure both a class and difficulty are selected.
	if selected_class_key == "" or selected_difficulty_key == "":
		print("ERROR: Cannot start run without a class and difficulty selected.")
		print("-1 FOCUS!")
		return

	print("Starting run with Class: %s and Difficulty: %s" % [selected_class_key, selected_difficulty_key])
	
	# --- THIS IS THE MOST IMPORTANT PART ---
	# set the chosen class and difficulty in GameManager
	GameManager.chosen_class = selected_class_key
	GameManager.chosen_difficulty = selected_difficulty_key
	GameManager.start_game()
	#    Now that the choices are locked in, we call the master start_game function.
	#    GameManager will handle the rest, including applying all the modifiers
	#    and transitioning to the main game scene.
	

func _on_debug_unlock_next_pact():
	if selected_class_key == "": return
	var progress = SaveManager.get_progress_for_class(selected_class_key)
	var cleared: Array = progress.get("cleared_tiers", [])
	for t in range(0, 10):
		if not (t in cleared):
			cleared.append(t)
			break
	progress["cleared_tiers"] = cleared
	SaveManager.save_game()
	update_all_displays()

func _on_debug_complete_seals():
	if selected_class_key == "": return
	var progress = SaveManager.get_progress_for_class(selected_class_key)
	progress.seals_broken = ["Trial of the Harvest", "Trial of the Core", "Trial of the Redline"]
	SaveManager.save_game()
	update_all_displays()

func _on_debug_unlock_next_cursed_pact():
	if selected_class_key == "": return
	var progress = SaveManager.get_progress_for_class(selected_class_key)
	progress.highest_cursed_pact_completed += 1
	SaveManager.save_game()
	update_all_displays()

func _on_debug_reset_save():
	SaveManager.reset_save_data()
	get_tree().reload_current_scene()

func _on_node_mouse_entered(item_type: String, key: String) -> void:
	hovered_type = item_type
	hovered_key = key
	tooltip_timer.start()

func _on_node_mouse_exited() -> void:
	tooltip_timer.stop()
	tooltip_panel.visible = false
	hovered_type = ""
	hovered_key = ""

func _on_tooltip_timer_timeout() -> void:
	if hovered_key == "":
		return

	if hovered_type == "class":
		var data = GameManager.class_data.get(hovered_key)
		if not data:
			return
		var unlocked = hovered_key in SaveManager.save_data.unlocked_classes
		var footer = "Click to Select" if unlocked else "Locked"
		tooltip_panel.show_simple_info(data.display_name, data.description, footer, data.icon_path, "Class Bio")
	
	

	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_position = get_viewport().get_mouse_position()
	if mouse_position.x < viewport_size.x / 2.5:
		tooltip_panel.position.x = mouse_position.x + 32
	else:
		tooltip_panel.position.x = mouse_position.x - tooltip_panel.size.x - 32
	if mouse_position.y < viewport_size.y / 2.0:
		tooltip_panel.position.y = mouse_position.y - 64
	else:
		tooltip_panel.position.y = mouse_position.y - tooltip_panel.size.y
	#description_panel.position.y = clamp(
		#mouse_position.y - (description_panel.size.y/2.0),
		#20,
		#viewport_size.y - description_panel.size.y - 20
	#)description_panel.visible = true
	tooltip_panel.visible = true
