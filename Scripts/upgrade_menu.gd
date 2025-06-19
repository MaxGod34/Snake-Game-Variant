extends CanvasLayer

# These signals are how this menu communicates with the main game.
signal upgrade_selected(upgrade_name)
signal resume_game_pressed

# --- NODE REFERENCES ---
# We get direct references to important nodes when the scene is ready.
# This is faster and safer than using long paths like $.../.../... every time.
@onready var top_tabs = $CenterContainer/PanelContainer/VBoxContainer/TopTabs
@onready var bottom_tabs = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs
@onready var stats_panel = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/Stats/StatsHBox
@onready var side_stats_panel = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/Stats/LevelUpStatsContainer
@onready var description_label = $DescriptionText
@onready var sp_label = $BottomRowHbox/BottomSPLabel
@onready var resume_button = $ResumeButton


# This dictionary will store a reference to every single upgrade button.
# We will build this dictionary once in _ready() to make updating them easier later.
var upgrade_buttons: Dictionary = {}

# A "gatekeeper" flag to prevent infinite loops when switching tabs.
var is_switching_tabs: bool = false
var main_game 

func _ready():
	# When the menu is ready, connect all signals one time.
	connect_all_signals()

# This is our master function for setting up all connections.
func connect_all_signals():
	# --- Connect Tab Switching ---
	top_tabs.tab_selected.connect(_on_top_tabs_tab_selected)
	bottom_tabs.tab_selected.connect(_on_bottom_tabs_tab_selected)
	
	# --- Connect Resume Button ---
	resume_button.pressed.connect(_on_resume_button_pressed)


	# --- Connect All Upgrade Buttons ---
	# This loop is very powerful. It goes through every upgrade defined in your GameManager.
	for upgrade_key in GameManager.upgrade_data.keys():
		# We find the button using our helper function.
		var button = find_upgrade_button(upgrade_key)
		if is_instance_valid(button):
			# Store the button in our dictionary for later use.
			upgrade_buttons[upgrade_key] = button
			# Connect all three signals (click, mouse enter, mouse exit).
			button.pressed.connect(_on_upgrade_button_pressed.bind(upgrade_key, button))
			button.mouse_entered.connect(_on_any_upgrade_mouse_entered.bind(upgrade_key))
			button.mouse_exited.connect(_on_any_upgrade_mouse_exited)

# --- MASTER UI UPDATE FUNCTION ---

# This function is called from main.gd right before the menu appears.
func set_initial_state_and_update():
	# First, reset the tabs to their default state.
	is_switching_tabs = true
	top_tabs.current_tab = 0 # Default to "Stats"
	bottom_tabs.current_tab = -1
	is_switching_tabs = false
	
	# Now, update all the information on the screen.
	update_all_displays()

# This function refreshes every piece of information in the menu.
func update_all_displays():
	update_stats_tab()
	update_skill_points_label()
	# This powerful loop updates every single upgrade button automatically.
	for upgrade_key in GameManager.upgrade_data.keys():
		update_button_display(upgrade_key)

# --- HELPER FUNCTIONS  ---

# This helper finds any button by its key, no matter which tab it's in.
func find_upgrade_button(upgrade_key: String):
	# We build the expected button name from the key.
	# e.g., "increase_speed" -> "IncreaseSpeedButton"
	var button_name = upgrade_key.to_pascal_case() + "Button"
	
	# find_child() is good
	var button = find_child(button_name, true, false)
	return button

# This helper gets the correct current level for any given upgrade.
func get_upgrade_level_from_key(upgrade_key):
	match upgrade_key:
		"increase_phase_charges": return GameManager.phase_shift_level
		"buy_extra_life": return GameManager.extra_lives
		#---Planner---#
		"diet_slith": return GameManager.diet_slith_level
		"fruit_foresight": return 1 if GameManager.fruit_foresight_unlocked else 0
		"ghost_tail": return GameManager.ghost_tail_level
		"sovereign_trail": return GameManager.sovereign_trail_level
		"meditative_state": return GameManager.meditative_state_level
		"garden_weaver": return 1 if GameManager.garden_weaver_unlocked else 0
		#-------Acrobat------#
		"Slither Sauce": return GameManager.slither_sauce_level
		"Tenderizer": return GameManager.tenderizer_level
		"Juke & Jive": return 1 if GameManager.juke_and_jive_unlocked else 0
		"Afterburner": return GameManager.afterburner_level
		"Pop Rocks": return 1 if GameManager.pop_rocks_unlocked else 0
		"Autotomy": return 1 if GameManager.autotomy_unlocked else 0
		#----------ARCHITECT------#
		"Edge Lord": return GameManager.edge_lord_level
		"Zoning Ordinance": return GameManager.zoning_ordinance_level
		"Border Czar": return 1 if GameManager.border_czar_unlocked else 0
		"Surveyed Land": return 1 if GameManager.surveyed_land_unlocked else 0
		"Burrow": return GameManager.burrow_level
		"Pocket Garden": return GameManager.pocket_garden_level
		"Fold Space": return 1 if GameManager.fold_space_unlocked else 0
		"Shatter Reality": return 1 if GameManager.shatter_reality_unlocked else 0
		"Master's Blueprint": return 1 if GameManager.masters_blueprint_unlocked else 0
		"Four Corner Cobra": return 1 if GameManager.four_corner_cobra_unlocked else 0
		#------Glutton------#
		"elephant_sized_portions": return GameManager.es_portions_level
		"more_mice": return GameManager.more_mice_level
		"golden_seeds": return GameManager.golden_seeds_level
		"patient_gardener": return GameManager.patient_gardener_level
		"banana_bounty": return GameManager.banana_bounty_level
		"the_satchel": return 1 if GameManager.the_satchel_unlocked else 0
	return 0

# --- INDIVIDUAL UPDATE FUNCTIONS ---

func update_stats_tab():
	# Update the labels inside your stats panel
	if is_instance_valid(stats_panel):
		stats_panel.get_node("ClassLabel").text = "Class: " + GameManager.chosen_class.capitalize()
		stats_panel.get_node("DifficultyLabel").text = "Difficulty: " + GameManager.chosen_difficulty.capitalize()
		stats_panel.get_node("LevelLabel").text = "Level: " + str(GameManager.player_level)
		stats_panel.get_node("SPLabel").text = "Snake Points: " + str(GameManager.skill_points)
	#Check our other stats panel on the side
	if is_instance_valid(side_stats_panel):
		side_stats_panel.get_node("FruitRewardStatsLabel").text = "Growth/fruit: " + str(GameManager.fruit_reward)
		side_stats_panel.get_node("MaxFruitsStatsLabel").text = "Max Fruits: " + str(GameManager.max_fruits_on_screen)
		side_stats_panel.get_node("GridSizeStatsLabel").text = "%s X %s tiles (l X h)" % [20 + 4 * GameManager.edge_lord_level, 15 + 3 * GameManager.edge_lord_level]
		side_stats_panel.get_node("TotalFruitsStatsLabel").text = "Total Fruits this run: " + str(GameManager.fruits_eaten_this_run)
		side_stats_panel.get_node("TotalSPStatsLabel").text = "Total SP this run: " + str(GameManager.total_sp_this_run) + " SP"
		side_stats_panel.get_node("AbilityIncrementStatsLabel").text = "Ability Activations this run: (fill) 0"
		side_stats_panel.get_node("NextGardenGoalLabel").text = "Next Garden Goal: " + str(GameManager.garden_data[GameManager.current_garden + 1]["score_goal"])
		side_stats_panel.get_node("NextGardenObstacles#Label").text = "# of obstacles next garden: " + str(GameManager.garden_data[GameManager.current_garden + 1]["obstacle_count"])
		

func update_skill_points_label():
	sp_label.text = "Skill Points: " + str(GameManager.skill_points)

# This is our powerful, generic function for updating any button.
func update_button_display(upgrade_key):
	var button_node = upgrade_buttons.get(upgrade_key)
	if not is_instance_valid(button_node): return

	var rules = GameManager.upgrade_data[upgrade_key]
	var current_level = get_upgrade_level_from_key(upgrade_key)
	
	# Prerequisite Check
	var prereqs_met = true
	if rules.has("prerequisite"):
		var prereq_key = rules["prerequisite"]["upgrade"]
		var req_level = rules["prerequisite"]["level"]
		if get_upgrade_level_from_key(prereq_key) < req_level:
			prereqs_met = false
		if rules["prerequisite"].has("and"):
			var prereq_key_2 = rules["prerequisite"]["and"]
			var req_level_2 = rules["prerequisite"]["and_level"]
			if get_upgrade_level_from_key(prereq_key_2) < req_level_2:
				prereqs_met = false
	
	if rules.has("exclusive_with"):
		var exclusive_key = rules["exclusive_with"]
		if get_upgrade_level_from_key(exclusive_key) > 0:
			prereqs_met = false
	
	button_node.disabled = not prereqs_met
	if not prereqs_met: return

	# Cost and Text Update
	if current_level >= rules["max_level"]:
		button_node.text = rules["display_name"] + " (MAX)"
		button_node.disabled = true
	else:
		var base_cost = rules["costs"][current_level]
		var diff_mod = GameManager.difficulty_data[GameManager.chosen_difficulty]["sp_cost_modifier"]
		var class_mod = GameManager.class_data[GameManager.chosen_class]["cost_modifiers"][upgrade_key]
		var final_cost = max(1, base_cost + diff_mod + class_mod)
		button_node.text = rules["display_name"] + "\n(" + str(final_cost) + " SP)"
		button_node.disabled = false
	
	# Indicator Block Update
	var indicator_container = button_node.get_parent().get_node("IndicatorContainer")
	for i in range(1, indicator_container.get_child_count() + 1):
		var block = indicator_container.get_node("Block" + str(i))
		block.visible = (i <= rules["max_level"])
		if block.visible:
			block.color = Color.GOLD if i <= current_level else Color.DARK_CYAN
			

# --- SIGNAL HANDLER FUNCTIONS ---

func _on_upgrade_button_pressed(upgrade_key, button_node):
	var current_level = get_upgrade_level_from_key(upgrade_key)
	var rules = GameManager.upgrade_data[upgrade_key]
	
	if current_level < rules["max_level"]:
		# --- THIS IS THE FIX ---
		# We put the full cost calculation here as well to ensure it's correct.
		var base_cost = rules["costs"][current_level]
		var diff_mod = GameManager.difficulty_data[GameManager.chosen_difficulty]["sp_cost_modifier"]
		var class_mod = GameManager.class_data[GameManager.chosen_class]["cost_modifiers"][upgrade_key]
		var final_cost = max(1, base_cost + diff_mod + class_mod)
		
		if GameManager.skill_points >= final_cost:
			GameManager.skill_points -= final_cost
			emit_signal("upgrade_selected", upgrade_key)
			button_node.release_focus()
			update_all_displays()

func _on_zone_button_pressed(quadrant_index):
	# We only allow changing the zone if we have enough levels.
	if GameManager.zoning_ordinance_level > quadrant_index:
		GameManager.zoned_quadrant = quadrant_index
		print("Safe zone set to quadrant: ", quadrant_index)
		# You could add visual feedback here to show which zone is selected


func _on_resume_button_pressed():
	emit_signal("resume_game_pressed")

func _on_any_upgrade_mouse_entered(upgrade_key):
	description_label.text = GameManager.upgrade_data[upgrade_key]["description"]
	description_label.visible = true

func _on_any_upgrade_mouse_exited():
	description_label.visible = false

func _on_top_tabs_tab_selected(_tab_index):
	if is_switching_tabs: return
	is_switching_tabs = true
	if is_instance_valid(bottom_tabs): bottom_tabs.current_tab = -1
	is_switching_tabs = false

func _on_bottom_tabs_tab_selected(_tab_index):
	if is_switching_tabs: return
	is_switching_tabs = true
	if is_instance_valid(top_tabs): top_tabs.current_tab = -1
	is_switching_tabs = false
