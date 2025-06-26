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
@onready var juice_label = $BottomRowHbox/BottomJuiceLabel
@onready var pulp_label = $BottomRowHbox/BottomPulpLabel
@onready var resume_button = $BottomRowHbox/ResumeButton
#---Snake Eyes UI-------
@onready var snake_coin_wager_slider = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/SnakeCoinContainer/WagerInputRow/SnakeCoinSlider
@onready var snake_coin_heads_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/SnakeCoinContainer/WagerInputRow/CallHeadsButton
@onready var snake_coin_tails_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/SnakeCoinContainer/WagerInputRow/CallTailsButton
@onready var snake_coin_head_tail_label_on_coin = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/PanelContainer/CoinContainerControl/HeadTailLabel

@onready var dice_wager_slider = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/HouseSpecialContainer/HouseSpecialRow/HouseSpecialSlider
@onready var dice_roll_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/HouseSpecialContainer/HouseSpecialRow/RollDiceButton
@onready var dice_guess_label = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/HouseSpecialContainer/GuessRow/GuessLabel

@onready var hoard_count_slider = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/HoardCountContainer/HouseSpecialRow/HoardCountSlider
@onready var hoard_count_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/HoardCountContainer/HouseSpecialRow/StartHoardCountButton
@onready var hoard_count_guess_label = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/HoardCountContainer/GuessRow/GuessLabel
#----Block Market References---
@onready var orange_block_label = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/OrangeBlockRow/OrangeBlockLabel
@onready var buy_orange_block_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/OrangeBlockRow/BuyShareOrangeButton
@onready var sell_orange_block_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/OrangeBlockRow/SellShareOrangeButton
@onready var apple_block_label = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/AppleBlockRow/AppleBlockLabel
@onready var buy_apple_block_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/AppleBlockRow/BuyShareAppleButton
@onready var sell_apple_block_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/AppleBlockRow/SellShareAppleButton
@onready var light_pulp_block_label = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/LightPulpRow/LightPulpLabel
@onready var buy_light_block_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/LightPulpRow/BuyLightPulpShareButton
@onready var sell_light_block_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/LightPulpRow/SellShareLightButton
@onready var extra_pulp_block_label = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/ExtraPulpRow/ExtraPulpLabel
@onready var buy_extra_block_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/ExtraPulpRow/BuyExtraPulpShareButton
@onready var sell_extra_block_button = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/ExtraPulpRow/SellSharePulpButton
# We also need a variable to store the player's current dice guess
var current_dice_guess: int = 1
var die_faces: Array = [
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_1.png"),
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_2.png"),
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_3.png"),
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_4.png"),
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_5.png"),
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_6.png")
]

var current_hoard_guess: int = 1

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
	
	snake_coin_wager_slider.value_changed.connect(_on_snake_coin_slider_changed)
	snake_coin_heads_button.pressed.connect(_on_snake_coin_flip_pressed.bind("Heads"))
	snake_coin_tails_button.pressed.connect(_on_snake_coin_flip_pressed.bind("Tails"))
	dice_wager_slider.value_changed.connect(_on_dice_slider_changed)
	dice_roll_button.pressed.connect(_on_roll_dice_button_pressed)
	hoard_count_button.pressed.connect(_on_start_hoard_count_pressed)
	hoard_count_slider.value_changed.connect(_on_hoard_count_slider_changed)
	buy_apple_block_button.pressed.connect(_on_buy_stock_pressed.bind("Apple Block"))
	buy_extra_block_button.pressed.connect(_on_buy_stock_pressed.bind("Extra Block"))
	buy_light_block_button.pressed.connect(_on_buy_stock_pressed.bind("Light Block"))
	buy_orange_block_button.pressed.connect(_on_buy_stock_pressed.bind("Orange Block"))
	sell_apple_block_button.pressed.connect(_on_sell_stock_pressed.bind("Apple Block"))
	sell_extra_block_button.pressed.connect(_on_sell_stock_pressed.bind("Extra Block"))
	sell_light_block_button.pressed.connect(_on_sell_stock_pressed.bind("Light Block"))
	sell_orange_block_button.pressed.connect(_on_sell_stock_pressed.bind("Orange Block"))



	# --- Connect Dice Stepper Buttons ---
	$CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/HouseSpecialContainer/GuessRow/LeftArrowButton.pressed.connect(_on_dice_arrow_pressed.bind(-1))
	$CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/HouseSpecialContainer/GuessRow/RightArrowButton.pressed.connect(_on_dice_arrow_pressed.bind(1))
	# --- Connect Hoard Count Arrow Buttons
	$CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/HoardCountContainer/GuessRow/LeftArrowButton.pressed.connect(_on_hoard_count_arrow_pressed.bind(-1))
	$CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/LeftColumn/HoardCountContainer/GuessRow/RightArrowButton.pressed.connect(_on_hoard_count_arrow_pressed.bind(1))

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
	update_juice_and_pulp_label()
	# This powerful loop updates every single upgrade button automatically.
	for upgrade_key in GameManager.upgrade_data.keys():
		update_button_display(upgrade_key)
	update_snake_eyes_tab()
	
	
	var ng_plus_button = find_upgrade_button("New Game S+")
	if is_instance_valid(ng_plus_button):
		var can_prestige = (GameManager.current_garden == 5 and GameManager.times_died_this_run == 0)
		ng_plus_button.get_parent().visible = can_prestige
		if can_prestige:
			update_button_display("New Game S+")

# --- HELPER FUNCTIONS  ---

# This helper finds any button by its key, no matter which tab it's in.
func find_upgrade_button(upgrade_key: String):
	# We build the expected button name from the key.
	# e.g., "Edge Lord" -> "EdgeLordButton"
	var button_name = upgrade_key.replace(" ", "").to_pascal_case() + "Button"
	
	# find_child() is the correct recursive search function for Godot 4.
	var button = find_child(button_name, true, false)
	if not is_instance_valid(button):
		print_debug("Warning: Could not find button named '", button_name, "'")
	return button

# This helper gets the correct current level for any given upgrade.
func get_upgrade_level_from_key(upgrade_key):
	
	if upgrade_key in GameManager.ability_charges:
		return GameManager.ability_charges[upgrade_key]["total"]
	
	
	match upgrade_key:
		#-----Idle Path-----#
		"Snake Clicker": return GameManager.snake_clicker_level
		"Get Rich Quick": return 1 if GameManager.get_rich_quick_unlocked else 0
		"Custom Aftertaste": return 1 if GameManager.custom_aftertaste_unlocked else 0
		"Arcane Flow": return 1 if GameManager.arcane_flow_unlocked else 0
		"Pulp Reactor": return 1 if GameManager.pulp_reactor_unlocked else 0
		"Unstable Metabolism": return 1 if GameManager.unstable_metabolism_unlocked else 0
		#----SnakeEyes-----#
		"Coin Flip Curious": return 1 if GameManager.coin_flip_curious_unlocked else 0
		"Passive Income": return 1 if GameManager.passive_income_unlocked else 0
		#---The Ledger---#
		"Liquid Assets": return GameManager.liquid_assets_level
		"Principal Pulp": return GameManager.principal_pulp_level
		"Fast Track": return 1 if GameManager.fast_track_unlocked else 0
		"Gluttons Greed": return 1 if GameManager.gluttons_greed_unlocked else 0
		"Market Crash": return GameManager.market_crash_level
		"Golden Handshake": return GameManager.golden_handshake_level
		"Juice Press": return 1 if "Juice Press" in GameManager.ability_charges else 0
		"Liquidation": return 1 if GameManager.liquidation_used else 0
		#----Frenzy---#
		"Sugar Rush": return 1 if GameManager.sugar_rush_unlocked else 0
		"Chain Reaction": return GameManager.chain_reaction_level
		"Overdrive": return GameManager.overdrive_level
		"Lingering Rush": return GameManager.lingering_rush_level
		"Juggernaut": return 1 if GameManager.juggernaut_unlocked else 0
		#----Chef---#
		"Golden Seed Extract": return GameManager.golden_seed_extract_level
		"Exotic Seeds": return GameManager.exotic_seeds_level
		"The Cookbook": return 1 if GameManager.the_cookbook_unlocked else 0
		"Expanded Palate": return 1 if GameManager.expanded_palate_unlocked else 0
		"Golden Glaze": return 1 if GameManager.golden_glaze_unlocked else 0
		"Custom Cuisine": return 1 if GameManager.custom_cuisine_unlocked else 0
		#---Planner---#
		"Diet Slith": return GameManager.diet_slith_level
		"Fruit Foresight": return 1 if GameManager.fruit_foresight_unlocked else 0
		"Geological Survey": return 1 if GameManager.geological_survey_unlocked else 0
		"Sovereign Trail": return GameManager.sovereign_trail_level
		#-------Acrobat------#
		"Slither Sauce": return GameManager.slither_sauce_level
		"Juke N Jive": return 1 if GameManager.juke_and_jive_unlocked else 0
		"Afterburner": return GameManager.afterburner_level
		"Pop Rocks": return 1 if GameManager.pop_rocks_unlocked else 0
		#----------ARCHITECT------#
		"Edge Lord": return GameManager.edge_lord_level
		"Zoning Ordinance": return GameManager.zoning_ordinance_level
		"Border Czar": return 1 if GameManager.border_czar_unlocked else 0
		"Surveyed Land": return 1 if GameManager.surveyed_land_unlocked else 0
		"Fold Space": return 1 if GameManager.fold_space_unlocked else 0
		"Shatter Reality": return 1 if GameManager.shatter_reality_unlocked else 0
		"Master's Blueprint": return 1 if GameManager.masters_blueprint_unlocked else 0
		#------Glutton------#
		"Elephant Sized Portions": return GameManager.es_portions_level
		"More Mice": return GameManager.more_mice_level
		"Golden Seeds": return GameManager.golden_seeds_level
		"Patient Gardener": return GameManager.patient_gardener_level
		"The Satchel": return 1 if GameManager.the_satchel_unlocked else 0
		#-------SURVIVOR-------#
		"Mulligan Munchie": return GameManager.extra_lives
		"Phoenix Dawn": return 1 if GameManager.phoenix_dawn_unlocked else 0
		"Last Stand": return 1 if GameManager.last_stand_unlocked else 0
		"Death Defied": return 1 if GameManager.death_defied_unlocked else 0
		"Martyrdom": return 1 if GameManager.martyrdom_unlocked else 0
		"New Game S+": return 1 if GameManager.new_game_s_plus_active else 0
		#-----ILLUSIONIST-----#
		"Ghost Tail": return GameManager.ghost_tail_level
		"3 Card Monty": return 1 if GameManager.three_card_monty_unlocked else 0
		"Fractured Self": return 1 if GameManager.fractured_self_unlocked else 0
		"Dazzle Pie": return 1 if GameManager.dazzle_pie_unlocked else 0
		# --- Geomancer Path ---
		"Fertile Ground": return GameManager.fertile_ground_level
		"Mineral Rich Soil": return GameManager.mineral_rich_soil_level
		"Tectonic Shift": return GameManager.tectonic_shift_level
		"Heavy Foundation": return GameManager.heavy_foundation_level
		# For Rockeater upgrades, we check if it's the chosen type
		"Rockmuncher": return 1 if GameManager.rockeater_type == "Rockmuncher" else 0
		"Geode Cracker": return 1 if GameManager.rockeater_type == "Geode Cracker" else 0
		"Kinetic Feast": return 1 if GameManager.rockeater_type == "Kinetic Feast" else 0
		"Stones Burden": return 1 if GameManager.rockeater_type == "Stones Burden" else 0
		"Calculated Risk": return 1 if GameManager.calculated_risk_unlocked else 0
	return 0

# --- INDIVIDUAL UPDATE FUNCTIONS ---

func update_stats_tab():
	# Update the labels inside your stats panel
	if is_instance_valid(stats_panel):
		stats_panel.get_node("ClassLabel").text = "Class: " + GameManager.chosen_class.capitalize()
		stats_panel.get_node("DifficultyLabel").text = "Difficulty: " + GameManager.chosen_difficulty.capitalize()
		stats_panel.get_node("LevelLabel").text = "Level: " + str(GameManager.player_level)
		stats_panel.get_node("JuiceLabel").text = "JUICE: " + str(GameManager.juice) + " mL"
	#Check our other stats panel on the side
	if is_instance_valid(side_stats_panel):
		side_stats_panel.get_node("FruitRewardStatsLabel").text = "Growth/fruit: " + str(GameManager.fruit_reward)
		side_stats_panel.get_node("MaxFruitsStatsLabel").text = "Max Fruits: " + str(GameManager.max_fruits_on_screen)
		side_stats_panel.get_node("GridSizeStatsLabel").text = "%s X %s tiles (l X h)" % [20 + 4 * GameManager.edge_lord_level, 15 + 3 * GameManager.edge_lord_level]
		side_stats_panel.get_node("TotalFruitsStatsLabel").text = "Total Fruits this run: " + str(GameManager.fruits_eaten_this_run)
		side_stats_panel.get_node("TotalJuiceStatsLabel").text = "Total Juice this run: " + str(GameManager.total_juice_this_run) + " mL"
		side_stats_panel.get_node("AbilityIncrementStatsLabel").text = "Ability Activations this run: (fill) 0"

		side_stats_panel.get_node("NextGardenGoalLabel").text = "Next Garden Goal: " + str(GameManager.garden_data[min(GameManager.current_garden + 1, 5)]["score_goal"])
		side_stats_panel.get_node("NextGardenObstacles#Label").text = "# of obstacles next garden: " + str(GameManager.garden_data[min(GameManager.current_garden + 1, 5)]["obstacle_count"])
		if GameManager.current_garden == 5:
			side_stats_panel.get_node("NextGardenGoalLabel").visible = false
			side_stats_panel.get_node("NextGardenObstacles#Label").visible = false

func update_snake_eyes_tab():
	# Update the max value of the sliders
	snake_coin_wager_slider.max_value = GameManager.juice
	dice_wager_slider.max_value = GameManager.juice
	hoard_count_slider.max_value = GameManager.pulp

	
	# Reset the sliders to 0
	snake_coin_wager_slider.value = 0
	dice_wager_slider.value = 0
	hoard_count_slider.value = 0
	
	# --- THIS IS THE NEW PART ---
	# Reset the button text to its default state
	snake_coin_heads_button.text = "Call Heads\n(XXmL)"
	snake_coin_tails_button.text = "Call Tails\n(XXmL)"
	dice_roll_button.text = "Roll for Glory!\n(XXmg)"
	
	main_game.update_ability_hotbar()
	update_juice_and_pulp_label()
	update_block_market_display()



func update_juice_and_pulp_label():
	juice_label.text = "Juice: " + str(GameManager.juice) + " mL"
	pulp_label.text = "Pulp: " + str(GameManager.pulp) + "mg"

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
		if GameManager.chosen_ledger_path == exclusive_key:
			prereqs_met = false
		if get_upgrade_level_from_key(exclusive_key) > 0:
			prereqs_met = false
	
	button_node.disabled = not prereqs_met
	if not prereqs_met: return


	var rockeater_keys = ["Rockmuncher", "Geode Cracker", "Kinetic Feast", "Stones Burden"]
	# Check if the upgrade we are updating is one of the Rockeaters
	if upgrade_key in rockeater_keys:
		# Now, check if a choice has already been made
		if GameManager.rockeater_type != "" and GameManager.rockeater_type != upgrade_key:
			# If a choice was made and it wasn't THIS one, disable this button.
			button_node.disabled = true
			# Optional: Change the text to show it's locked.
			button_node.text = "Path Chosen"
			# We can return here to stop any further updates on this locked button.
			return


	# Cost and Text Update
	if current_level >= rules["max_level"]:
		button_node.text = rules["display_name"] + " (MAX)"
		button_node.disabled = true
	else:
		var base_cost = rules["costs"][current_level]
		var diff_mod = GameManager.difficulty_data[GameManager.chosen_difficulty]["juice_cost_modifier"]
		var class_mod = GameManager.class_data[GameManager.chosen_class]["cost_modifiers"][upgrade_key]
		var final_cost = max(1, base_cost + diff_mod + class_mod)
		
		if GameManager.three_card_monty_unlocked:
			if upgrade_key != "3 Card Monty":
				final_cost -= 1 if GameManager.three_card_monty_unlocked else 0
		if GameManager.market_crash_level > 0:
			final_cost -= GameManager.market_crash_level
		
		
		final_cost = max(1, final_cost)
		
		
		button_node.text = rules["display_name"] + "\n(" + str(final_cost) + " mL)"
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
		var diff_mod = GameManager.difficulty_data[GameManager.chosen_difficulty]["juice_cost_modifier"]
		var class_mod = GameManager.class_data[GameManager.chosen_class]["cost_modifiers"][upgrade_key]
		var final_cost = max(1, base_cost + diff_mod + class_mod)
		
		if GameManager.three_card_monty_unlocked:
			if upgrade_key != "3 Card Monty":
				final_cost -= 1 if GameManager.three_card_monty_unlocked else 0
			
		final_cost = max(1, final_cost)
		
		
		if GameManager.juice >= final_cost:
			GameManager.juice -= final_cost
			GameManager.juice_spent_this_garden += final_cost
			emit_signal("upgrade_selected", upgrade_key)
			button_node.release_focus()
			update_all_displays()

func _on_zone_button_pressed(quadrant_index):
	# We only allow changing the zone if we have enough levels.
	if GameManager.zoning_ordinance_level > quadrant_index:
		GameManager.zoned_quadrant = quadrant_index
		print("Safe zone set to quadrant: ", quadrant_index)
		# You could add visual feedback here to show which zone is selected


func _on_snake_coin_slider_changed(value: float):
	# This now updates BOTH buttons with the wager amount.
	var wager = floori(value)
	snake_coin_heads_button.text = "Call Heads\n(%s Juice)" % wager
	snake_coin_tails_button.text = "Call Tails\n(%s Juice)" % wager

func _on_dice_slider_changed(value: float):
	var wager = floori(value)
	dice_roll_button.text = "Roll for Glory!!\n(%s Juice)" % wager
	



func _on_dice_arrow_pressed(direction: int):
	# Add the direction (-1 or 1) to our guess
	
	if current_dice_guess == 1 and direction == -1:
		current_dice_guess = 6
	elif current_dice_guess == 6 and direction == 1:
		current_dice_guess = 1
	else:
		current_dice_guess += direction
		# Use clamp() to make sure the number stays between 1 and 6
		current_dice_guess = clamp(current_dice_guess, 1, 6)
	# Update the label
	dice_guess_label.text = str(current_dice_guess)


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


func _on_snake_coin_flip_pressed(player_choice: String):
	var wager = floori(snake_coin_wager_slider.value)
	
	# 1. First, check if the bet is valid.
	if wager <= 0 or wager > GameManager.juice:
		print("Invalid bet!")
		return

	print("Player bets %s Juice on %s" % [wager, player_choice])
	
	# 2. Disable all buttons during the animation.
	set_gambling_ui_disabled(true)
	
	# 3. Take the player's Juice.
	GameManager.juice -= wager
	# FIX: We now call main_game.update_hud() to instantly update the main UI.
		
	main_game.update_hud()
	update_juice_and_pulp_label()
	
	var outcome = "Heads" if randf() < 0.5 else "Tails"
	print("The result is... ", outcome)
	 #-----Set the text of the label on the coin
	if outcome == "Heads": snake_coin_head_tail_label_on_coin.text = "H"
	elif outcome == "Tails": snake_coin_head_tail_label_on_coin.text = "T"
	else: snake_coin_head_tail_label_on_coin.text = "ERROR!"
	
	# 4. Play the coin flip animation.
	var coin = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/PanelContainer/CoinContainerControl
	
	coin.visible = true
	var tween = create_tween()
	tween.tween_property(coin, "scale", Vector2(1.5, 0.1), 0.2)
	tween.tween_property(coin, "scale", Vector2(1.0, 1.0), 0.2)
	await tween.finished
	
	# 5. Determine the outcome.
	
	
	# 6. Check for a win and distribute rewards.
	if player_choice == outcome:
		print("WINNER!")
		GameManager.juice += (wager * 2)
		if GameManager.passive_income_unlocked:
			GameManager.correct_bets_this_run += 1
			GameManager.fruit_reward += 1
			await play_result_animation(true, "Correct!\nYou win +%smL" % [wager * 2])
		else:
			await play_result_animation(true, "Cash in!\n+%smL" % [wager * 2])
	else:
		print("You lose.")
		await play_result_animation(false, "Better luck next time!\nYou lose %smL" % [wager])
	# 7. Update all UI and re-enable everything.
	# Extra delay -> await get_tree().create_timer(1.5).timeout
	coin.visible = false
	
	# FIX: We now call update_snake_eyes_tab() AFTER the bet resolves
	# to correctly update the slider's max value and re-enable the buttons.
	update_snake_eyes_tab()
	# We also call main_game.update_hud() again to show the final winnings.
	main_game.update_hud()
	
	set_gambling_ui_disabled(false)
	
func set_gambling_ui_disabled(is_disabled: bool):
	snake_coin_heads_button.disabled = is_disabled
	snake_coin_tails_button.disabled = is_disabled
	dice_roll_button.disabled = is_disabled



func _on_roll_dice_button_pressed():
	var wager = floori(dice_wager_slider.value)
	
	# 1. Check if the bet is valid.
	if wager <= 0 or wager > GameManager.juice:
		print("Invalid bet!")
		return

	print("Player bets %s Juice on a %s" % [wager, current_dice_guess])
	
	# 2. Disable all buttons during the animation.
	set_gambling_ui_disabled(true)
	
	# 3. Take the player's Juice.
	GameManager.juice -= wager
	main_game.update_hud()
	update_juice_and_pulp_label()
	
	# 4. Play the dice roll animation.
	var die_sprite = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/PanelContainer/DieSprite
	die_sprite.visible = true
	# A quick "tumbling" effect
	for i in range(10):
		die_sprite.texture = die_faces.pick_random()
		await get_tree().create_timer(0.05).timeout
	
	# 5. Determine the outcome.
	var outcome = randi() % 6 + 1 # A random number from 1 to 6
	die_sprite.texture = die_faces[outcome - 1] # Set the final face
	print("The result is... ", outcome)
	
	# 6. Check for a win and distribute rewards.
	if current_dice_guess == outcome:
		print("WINNER! 6x PAYOUT!")
		GameManager.juice += (wager * 6)
		if GameManager.passive_income_unlocked:
			GameManager.correct_bets_this_run += 1
			GameManager.fruit_reward += 1
			await play_result_animation(true, "How did you do it?!\n+%smL" % [wager * 6])
		else:
			await play_result_animation(true, "YOU CALLED IT!\n+%smL" % [wager * 6])
	else:
		print("You lose.")
		await play_result_animation(false, "Next time, sorry!\n-%smL" % [wager])
		
	# 7. Update all UI and re-enable everything.
	# Extra pause await get_tree().create_timer(1.5).timeout # A longer dramatic pause
	die_sprite.visible = false
	update_snake_eyes_tab()
	main_game.update_hud()
	update_juice_and_pulp_label()
	set_gambling_ui_disabled(false)
	
func _on_hoard_count_slider_changed(value: float):
	var wager = floori(value)
	hoard_count_button.text = "Guess the Hoard!\n(%s Pulp)" % wager

func _on_hoard_count_arrow_pressed(direction: int):
	
	if current_hoard_guess == 1 and direction == -1:
		current_hoard_guess = 20
	elif current_hoard_guess == 20 and direction == 1:
		current_hoard_guess = 1
	else:
		current_hoard_guess += direction
		# Clamp the guess between 1 and 20
		current_hoard_guess = clamp(current_hoard_guess, 1, 20)
	hoard_count_guess_label.text = str(current_hoard_guess)

func _on_start_hoard_count_pressed():
	var wager = floori(hoard_count_slider.value)

	# 1. Check if the bet is valid.
	if wager <= 0 or wager > GameManager.pulp: return

	print("Player bets %s Pulp on the number %s" % [wager, current_hoard_guess])

	# 2. Disable UI and take the wager.
	set_gambling_ui_disabled(true)
	GameManager.pulp -= wager
	main_game.update_hud() # Assumes you have this connection
	update_juice_and_pulp_label()
	# 3. Play the animation (we'll need a new sprite for this)
	var basket_sprite = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/PanelContainer/BasketSprite
	basket_sprite.visible = true
	for i in range(6):
		
		var tween = create_tween()
		tween.tween_property(basket_sprite, "scale", Vector2(1.2, 0.8), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(basket_sprite, "scale", Vector2(1.0, 1.0), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		await tween.finished

	# 4. Determine the outcome.
	var outcome = randi() % 20 + 1 # A random number from 1 to 20
	print("The winning number is... ", outcome)
	# We could add a label to the basket sprite to show the winning number

	# 5. Check for a win and distribute rewards.
	if current_hoard_guess == outcome:
		print("JACKPOT! 20x PAYOUT!")
		GameManager.pulp += (wager * 20)
		if GameManager.passive_income_unlocked:
			GameManager.correct_bets_this_run += 1
			GameManager.fruit_reward += 1
			await play_result_animation(true, "Impossible!\nYou called it! +%s mg" % [wager * 20])
		else:
			await play_result_animation(true, "Impossible!\nYou called it! +%s mg" % [wager * 20])
	else:
		print("You lose.")
		await play_result_animation(false, "Sorry! You lost %s mg\nThe result was: %s" % [wager, outcome])

	# 6. Clean up and re-enable UI.
	await get_tree().create_timer(1.0).timeout
	basket_sprite.visible = false
	update_snake_eyes_tab()
	main_game.update_hud()
	set_gambling_ui_disabled(false)


func play_result_animation(is_win: bool, custom_message: String = ""):
	var result_label = $CenterContainer/PanelContainer/VBoxContainer/BottomTabs/SnakeEyes/MainContent/PanelContainer/ResultControl/ResultLabel
	
	# 1. Set the text and color based on the outcome.
	if is_win:
		var win_messages = ["WIN!", "Chicken Dinner!", "Lucky you!", "You win this time!"]
		result_label.text = win_messages.pick_random()
		result_label.modulate = Color.GOLD
	else:
		# Your great idea for random losing messages!
		var lose_messages = ["Oof.", "Tough Luck.", "Not this time...", "The House Wins."]
		result_label.text = lose_messages.pick_random()
		result_label.modulate = Color.GRAY
		
	# If a custom message was provided, use that instead.
	if custom_message != "":
		result_label.text = custom_message
		
	# 2. Prepare the label for its animation.
	result_label.pivot_offset = result_label.size / 2
	result_label.scale = Vector2.ZERO
	result_label.visible = true
	
	# 3. Play the "pop and fade" animation.
	var tween = create_tween()
	# Animate the scale up with a bouncy effect.
	tween.tween_property(result_label, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# After a delay, fade the label out.
	tween.tween_property(result_label, "modulate:a", 0.0, 0.5).set_delay(0.8)
	
	# Wait for the entire animation to finish.
	await tween.finished
	await get_tree().create_timer(0.25).timeout
	result_label.visible = false

func update_block_market_display():
	_update_stock_row("Orange Block", orange_block_label, buy_orange_block_button, sell_orange_block_button)
	_update_stock_row("Apple Block", apple_block_label, buy_apple_block_button, sell_apple_block_button)
	_update_stock_row("Light Block", light_pulp_block_label, buy_light_block_button, sell_light_block_button)
	_update_stock_row("Extra Block", extra_pulp_block_label, buy_extra_block_button, sell_extra_block_button)

func _update_stock_row(stock_key, info_label, buy_button, sell_button):
	var stock_data = GameManager.block_market_prices[stock_key]
	
	var price = stock_data.price
	var currency = stock_data.currency
	
	var shares_owned = GameManager.block_market_portfolio.get(stock_key, 0)
	# --- THIS IS THE NEW LOGIC ---
	# We combine all the info into one string for the main label.
	var display_text = "%s\nPrice: %s %s\nOwned: %s" % [stock_key, price, currency, shares_owned]
	info_label.text = display_text
	
	# Disable the buy button if you can't afford it
	var player_currency = GameManager.juice if currency == "Juice" else GameManager.pulp
	buy_button.disabled = (player_currency < price)
	
	# Disable the sell button if you don't own any shares
	sell_button.disabled = (shares_owned == 0)

func _on_buy_stock_pressed(stock_key: String):
	var stock_data = GameManager.block_market_prices[stock_key]
	var price = stock_data.price
	var currency = stock_data.currency
	
	# Check if we can afford it
	var can_afford = (GameManager.juice >= price) if currency == "Juice" else (GameManager.pulp >= price)
	if not can_afford: return

	# Check if we have an ability slot for a NEW investment
	var is_new_investment = not stock_key in GameManager.block_market_portfolio
	if is_new_investment and GameManager.equipped_abilities.size() >= GameManager.max_ability_slots:
		print("Not enough ability slots to make a new investment!")
		return
	
		
	# Process the transaction
	if currency == "Juice":
		GameManager.juice -= price
	else:
		GameManager.pulp -= price
		
	
	
	# If it was a new investment, add it to the hotbar
	if is_new_investment:
		GameManager.equipped_abilities.append(stock_key)
		
	GameManager.block_market_portfolio[stock_key] = GameManager.block_market_portfolio.get(stock_key, 0) + 1
		
	# Refresh everything
	update_all_displays()
	main_game.update_hud()
	update_juice_and_pulp_label()

func _on_sell_stock_pressed(stock_key: String):
	var shares_owned = GameManager.block_market_portfolio.get(stock_key, 0)
	if shares_owned <= 0: return

	var stock_data = GameManager.block_market_prices[stock_key]
	var price = stock_data.price
	var currency = stock_data.currency
	
	# Process the transaction
	if currency == "Juice":
		GameManager.juice += price
	else:
		GameManager.pulp += price
		
	GameManager.block_market_portfolio[stock_key] -= 1
	
	# If we just sold our last share, free up the ability slot
	if GameManager.block_market_portfolio.get(stock_key, 0) == 0:
		GameManager.block_market_portfolio.erase(stock_key)
		GameManager.equipped_abilities.erase(stock_key)
		
	# Refresh everything
	update_all_displays()
	main_game.update_hud()
	update_juice_and_pulp_label()
