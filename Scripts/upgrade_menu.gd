extends CanvasLayer

signal upgrade_selected(upgrade_name)
signal resume_game_pressed

@onready var main_vbox = $CenterContainer/PanelContainer/VBoxContainer
@onready var top_tabs = main_vbox.get_node("TopTabs")
@onready var bottom_tabs = main_vbox.get_node("BottomTabs")

var is_switching_tabs: bool = false

func _ready():
	# --- CONNECT ALL BUTTONS ---
	# We use our helper function for every single button to ensure
	# pressed, mouse_entered, and mouse_exited are all connected.
	
	# --- Top Row ---
	connect_upgrade_button(top_tabs, "Acrobat/SpeedUpgradeRow/SpeedUpgradeButton", "increase_speed")
	connect_upgrade_button(top_tabs, "Glutton/FruitUpgradeRow/FruitRewardUpgradeButton", "increase_fruit_reward")
	connect_upgrade_button(top_tabs, "Glutton/MaxFruitsUpgradeRow/MaxFruitsButton", "increase_max_fruits")
	connect_upgrade_button(top_tabs, "Architect/PerimeterUpgradeRow/PerimeterUpgradeButton", "increase_grid_size")
	connect_upgrade_button(top_tabs, "Standalone/H/BurrowAbilityRow/BurrowButton", "increase_burrow_charges")
	connect_upgrade_button(top_tabs, "Standalone/H/PhaseShiftAbilityRow/PhaseShiftButton", "increase_phase_charges")
	connect_upgrade_button(top_tabs, "Survivor/H2/ExtraLifeRow/ExtraLifeButton", "buy_extra_life")

	# --- Bottom Row ---
	connect_upgrade_button(bottom_tabs, "Planner/DietSlithRow/DietSlithButton", "decrease_speed")
	connect_upgrade_button(bottom_tabs, "Planner/FruitForesightRow/FruitForesightButton", "fruit_foresight")
	connect_upgrade_button(bottom_tabs, "Planner/GhostTailRow/GhostTailButton", "ghost_tail")
	connect_upgrade_button(bottom_tabs, "Planner/SovereignTrailRow/SovereignTrailButton", "sovereign_trail")
	connect_upgrade_button(bottom_tabs, "Planner/MeditativeStateRow/MeditativeStateButton", "meditative_state")
	connect_upgrade_button(bottom_tabs, "Planner/GardenWeaverRow/GardenWeaverButton", "garden_weaver")
	
	# --- Other Connections ---
	$BottomRowHbox/ResumeButton.pressed.connect(_on_resume_button_pressed)
	top_tabs.tab_selected.connect(_on_top_tabs_tab_selected)
	bottom_tabs.tab_selected.connect(_on_bottom_tabs_tab_selected)

func update_all_displays():
		
	# Now that the initial state is set, open the gate for user clicks.
	is_switching_tabs = false
	#-----ALL DISPLAYS TO UPDATE-----#
	update_skill_points_label()
	update_stats_tab()
	update_button_display("increase_speed", top_tabs.get_node("Acrobat/SpeedUpgradeRow/SpeedUpgradeButton"), GameManager.speed_upgrade_level)
	update_button_display("increase_fruit_reward", top_tabs.get_node("Glutton/FruitUpgradeRow/FruitRewardUpgradeButton"), GameManager.fruit_reward - 1)
	update_button_display("increase_max_fruits", top_tabs.get_node("Glutton/MaxFruitsUpgradeRow/MaxFruitsButton"), GameManager.max_fruits_on_screen - 1)
	update_button_display("increase_grid_size",top_tabs.get_node("Architect/PerimeterUpgradeRow/PerimeterUpgradeButton"), GameManager.grid_size_level)
	update_button_display("increase_burrow_charges", top_tabs.get_node("Standalone/H/BurrowAbilityRow/BurrowButton"), GameManager.burrow_level)
	update_button_display("increase_phase_charges", top_tabs.get_node("Standalone/H/PhaseShiftAbilityRow/PhaseShiftButton"), GameManager.phase_shift_level)
	update_button_display("buy_extra_life", top_tabs.get_node("Survivor/H2/ExtraLifeRow/ExtraLifeButton"), GameManager.extra_lives)
	#--------The Planner--------#
	update_button_display("decrease_speed", bottom_tabs.get_node("Planner/DietSlithRow/DietSlithButton"), GameManager.diet_slith_level)
	var foresight_level = 1 if GameManager.fruit_foresight_unlocked else 0
	update_button_display("fruit_foresight", bottom_tabs.get_node("Planner/FruitForesightRow/FruitForesightButton"), foresight_level)
	update_button_display("ghost_tail", bottom_tabs.get_node("Planner/GhostTailRow/GhostTailButton"), GameManager.ghost_tail_level)
	update_button_display("sovereign_trail", bottom_tabs.get_node("Planner/SovereignTrailRow/SovereignTrailButton"), GameManager.sovereign_trail_level)
	update_button_display("meditative_state", bottom_tabs.get_node("Planner/MeditativeStateRow/MeditativeStateButton"), GameManager.meditative_state_level)
	var garden_weaver_level = 1 if GameManager.garden_weaver_unlocked else 0
	update_button_display("garden_weaver", bottom_tabs.get_node("Planner/GardenWeaverRow/GardenWeaverButton"), garden_weaver_level)
	#-------CLASS SPECIFIC DISABLES-------#
	var extra_life_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/Survivor/H2/ExtraLifeRow/ExtraLifeButton
	# Check if the current class is The Zealot
	if GameManager.chosen_class == "the_zealot":
		# If yes, make the button invisible.
		extra_life_button.disabled = true
	else:
		# If it's any other class, make sure the button is visible.
		extra_life_button.disabled = false
		
	

# A single, powerful function to update any upgrade row
func update_button_display(upgrade_key, button_node, current_level):
	var rules = GameManager.upgrade_data[upgrade_key]
	var display_name = rules["display_name"]
	var indicator_container = button_node.get_parent().get_node("IndicatorContainer")
	# --- NEW PREREQUISITE LOGIC ---
	var prerequisites_met = true
	if rules.has("prerequisite"):
		var prereq_key = rules["prerequisite"]["upgrade"]
		var required_level = rules["prerequisite"]["level"]
		
		# Get the current level of the prerequisite upgrade
		var prereq_current_level = get_upgrade_level_from_key(prereq_key)

		if prereq_current_level < required_level:
			prerequisites_met = false
			
	# If prerequisites aren't met, hide the button and stop.
	button_node.disabled = not prerequisites_met
	if not prerequisites_met:
		return



	if current_level >= rules["max_level"]:
		button_node.text = display_name + " (MAX)"
		button_node.disabled = true
	else:
		var base_cost = rules["costs"][current_level]
		var difficulty_mod = GameManager.difficulty_data[GameManager.chosen_difficulty]["sp_cost_modifier"]
		var class_mod = GameManager.class_data[GameManager.chosen_class]["cost_modifiers"][upgrade_key]
		var cost = max(1, base_cost + difficulty_mod + class_mod)
		button_node.text = display_name + " (" + str(cost) + " SP)"
		button_node.disabled = false

	# Update indicator blocks
	# Ensure your max_level in the data dictionary matches the number of blocks you have.
	var max_indicator_blocks = indicator_container.get_child_count()
	for i in range(1, max_indicator_blocks + 1):
		var block = indicator_container.get_node("Block" + str(i))
		block.visible = (i <= rules["max_level"])
		if block.visible:
			block.color = Color.GOLD if i <= current_level else Color.GRAY


func update_stats_tab():
	var stats_panel = main_vbox.get_node("TopTabs/Stats/StatsHBox")
	# Update the labels inside your stats panel
	if is_instance_valid(stats_panel):
		stats_panel.get_node("ClassLabel").text = "Class: " + GameManager.chosen_class.capitalize()
		stats_panel.get_node("DifficultyLabel").text = "Difficulty: " + GameManager.chosen_difficulty.capitalize()
		stats_panel.get_node("LevelLabel").text = "Level: " + str(GameManager.player_level)
		stats_panel.get_node("SPLabel").text = "Snake Points: " + str(GameManager.skill_points)
	var side_stats_panel = main_vbox.get_node("TopTabs/Stats/LevelUpStatsContainer")
	#Check our other stats panel on the side
	if is_instance_valid(side_stats_panel):
		side_stats_panel.get_node("FruitRewardStatsLabel").text = str(GameManager.fruit_reward)
		side_stats_panel.get_node("MaxFruitsStatsLabel").text = str(GameManager.max_fruits_on_screen)
		side_stats_panel.get_node("GridSizeStatsLabel").text = "%s X %s tiles (length X height)" % [GameManager.grid_size_data[GameManager.grid_size_level].x, GameManager.grid_size_data[GameManager.grid_size_level].y]
		side_stats_panel.get_node("TotalFruitsStatsLabel").text = "Total Fruits this run: (fill)"
		side_stats_panel.get_node("TotalSPStatsLabel").text = "Total SP this run: (fill)"
		side_stats_panel.get_node("AbilityIncrementStatsLabel").text = "Ability Activations this run: (fill)"
		side_stats_panel.get_node("NextGardenGoalLabel").text = "Next Garden Goal: (fill)"
		side_stats_panel.get_node("NextGardenObstacles#Label").text = "# of obstacles next garden: (fill)"
		side_stats_panel.get_node("RunTimeStatsLabel").text = "Run Time: 4.2s (fill)"

func update_skill_points_label():
	# Make sure this path is correct for your scene!
	$BottomRowHbox/BottomSPLabel.text = "Snake Points Available: " + str(GameManager.skill_points)

func _on_resume_button_pressed():
	emit_signal("resume_game_pressed")

# A single, powerful function to handle any button press
func _on_upgrade_button_pressed(upgrade_key, button_node):
	var current_level # Get the correct level to check against
	if upgrade_key == "increase_fruit_reward": current_level = GameManager.fruit_reward - 1
	elif upgrade_key == "increase_max_fruits": current_level = GameManager.max_fruits_on_screen - 1
	elif upgrade_key == "increase_grid_size": current_level = GameManager.grid_size_level
	elif upgrade_key == "increase_burrow_charges": current_level = GameManager.burrow_level
	elif upgrade_key == "increase_phase_charges": current_level = GameManager.phase_shift_level
	elif upgrade_key == "buy_extra_life": current_level = GameManager.extra_lives
	elif upgrade_key == "decrease_speed": current_level = GameManager.diet_slith_level
	elif upgrade_key == "fruit_foresight": current_level = 1 if GameManager.fruit_foresight_unlocked else 0
	elif upgrade_key == "ghost_tail": current_level = GameManager.ghost_tail_level
	elif upgrade_key == "sovereign_trail": current_level = GameManager.sovereign_trail_level
	elif upgrade_key == "meditative_state": current_level = GameManager.meditative_state_level
	elif upgrade_key == "garden_weaver": current_level = 1 if GameManager.garden_weaver_unlocked else 0
	else: current_level = GameManager.speed_upgrade_level

	var rules = GameManager.upgrade_data[upgrade_key]
	if current_level < rules["max_level"]:
		var base_cost = rules["costs"][current_level]
		var difficulty_mod = GameManager.difficulty_data[GameManager.chosen_difficulty]["sp_cost_modifier"]
		var class_mod = GameManager.class_data[GameManager.chosen_class]["cost_modifiers"][upgrade_key]
		var cost = max(1, base_cost + difficulty_mod + class_mod)
		if GameManager.skill_points >= cost:
			GameManager.skill_points -= cost
			emit_signal("upgrade_selected", upgrade_key)
			if is_instance_valid(button_node):
				button_node.release_focus()
			update_all_displays() # Refresh UI immediately after purchase

func get_upgrade_level_from_key(upgrade_key):
	# This function now correctly includes all new upgrades
	if upgrade_key == "increase_speed": return GameManager.speed_upgrade_level
	if upgrade_key == "decrease_speed": return GameManager.diet_slith_level
	if upgrade_key == "increase_grid_size": return GameManager.grid_size_level
	if upgrade_key == "buy_extra_life": return GameManager.extra_lives
	if upgrade_key == "fruit_foresight": return 1 if GameManager.fruit_foresight_unlocked else 0
	if upgrade_key == "ghost_tail": return GameManager.ghost_tail_level
	if upgrade_key == "sovereign_trail": return GameManager.sovereign_trail_level
	if upgrade_key == "meditative_state": return GameManager.meditative_state_level
	if upgrade_key == "garden_weaver": return 1 if GameManager.garden_weaver_unlocked else 0
	return 0 # Default
func set_initial_state():
	is_switching_tabs = true
	if is_instance_valid(top_tabs):
		top_tabs.current_tab = 0 # Default to "Stats"
	if is_instance_valid(bottom_tabs):
		bottom_tabs.current_tab = -1
	is_switching_tabs = false

func _on_top_tabs_tab_selected(_tab_index):
	if is_switching_tabs:
		return
	is_switching_tabs = true
	if is_instance_valid(bottom_tabs):
		bottom_tabs.current_tab = -1
	is_switching_tabs = false

func _on_bottom_tabs_tab_selected(_tab_index):
	if is_switching_tabs:
		return
	is_switching_tabs = true
	if is_instance_valid(top_tabs):
		top_tabs.current_tab = -1
	is_switching_tabs = false


func _on_any_upgrade_mouse_entered(upgrade_key):
	# Get the description text from our global data dictionary
	var description_text = GameManager.upgrade_data[upgrade_key]["description"]
	
	# Find our label, set its text, and make it visible
	$DescriptionText.text = description_text
	$DescriptionText.visible = true

func _on_any_upgrade_mouse_exited():
	# When the mouse leaves, just hide the label
	$DescriptionText.visible = false

func connect_upgrade_button(tab_group, path_to_button, upgrade_key):
	var button = tab_group.get_node(path_to_button)
	if is_instance_valid(button):
		# The existing connection for clicking
		button.pressed.connect(_on_upgrade_button_pressed.bind(upgrade_key, button))
		
		# Connect the hover signals, also binding the upgrade_key
		button.mouse_entered.connect(_on_any_upgrade_mouse_entered.bind(upgrade_key))
		button.mouse_exited.connect(_on_any_upgrade_mouse_exited)
