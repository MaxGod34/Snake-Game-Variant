extends CanvasLayer

# === Signals ===
signal resume_game_pressed


# === Core References ===
var main_game
var hovered_upgrade_key: String = ""
var is_switching_tabs: bool = false


# === Gameplay State ===
var current_dice_guess: int = 1
var current_hoard_guess: int = 1


# === UI References ===
# -- Top-Level UI --
@onready var top_tabs = $CenterContainer/PanelContainer/VBoxContainer/TopTabs
@onready var description_label = $DescriptionText
@onready var description_panel = $DescriptionPanel
@onready var juice_label = $BottomPanel/BottomRowHBox/BottomJuiceLabel
@onready var pulp_label = $BottomPanel/BottomRowHBox/BottomPulpLabel
@onready var resume_button = $BottomPanel/BottomRowHBox/ResumeButton
@onready var description_delay_timer = $DescriptionDelayTimer

# -- Stats Panel --
@onready var stats_panel = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/Stats/StatsHBox
@onready var side_stats_panel = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/Stats/LevelUpStatsContainer

# -- Ticker Labels --
@onready var headline_label_a = $TickerPanel/TickerContainer/HeadlineStage/TopTickerLabelA
@onready var headline_label_b = $TickerPanel/TickerContainer/HeadlineStage/TopTickerLabelB
@onready var stats_label_a = $TickerPanel/TickerContainer/StatsStage/BottomTickerLabelA
@onready var stats_label_b = $TickerPanel/TickerContainer/StatsStage/BottomTickerLabelB


# === Snake Eyes UI ===
# -- Snake Coin Wager --
@onready var snake_coin_wager_slider = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/SnakeCoinContainer/WagerInputRow2/SnakeCoinSlider
@onready var snake_coin_heads_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/SnakeCoinContainer/WagerInputRow/CallHeadsButton
@onready var snake_coin_tails_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/SnakeCoinContainer/WagerInputRow/CallTailsButton

# -- Dice Wager --
@onready var dice_wager_slider = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/HouseSpecialContainer/HouseSpecialRow/HouseSpecialSlider
@onready var dice_roll_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/HouseSpecialContainer/GuessRow/RollDiceButton
@onready var dice_guess_label = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/HouseSpecialContainer/GuessRow/GuessLabel

# -- Hoard Count --
@onready var hoard_count_slider = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/HoardCountContainer/HouseSpecialRow/HoardCountSlider
@onready var hoard_count_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/HoardCountContainer/GuessRow/StartHoardCountButton
@onready var hoard_count_guess_label = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/HoardCountContainer/GuessRow/GuessLabel


# === Block Market UI ===
@onready var orange_block_label = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/OrangeBlockRow/OrangeBlockLabel
@onready var buy_orange_block_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/OrangeBlockRow/BuyShareOrangeButton
@onready var sell_orange_block_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/OrangeBlockRow/SellShareOrangeButton

@onready var apple_block_label = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/AppleBlockRow/AppleBlockLabel
@onready var buy_apple_block_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/AppleBlockRow/BuyShareAppleButton
@onready var sell_apple_block_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/AppleBlockRow/SellShareAppleButton

@onready var light_pulp_block_label = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/LightPulpRow/LightPulpLabel
@onready var buy_light_block_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/LightPulpRow/BuyLightPulpShareButton
@onready var sell_light_block_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/LightPulpRow/SellShareLightButton

@onready var extra_pulp_block_label = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/ExtraPulpRow/ExtraPulpLabel
@onready var buy_extra_block_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/ExtraPulpRow/BuyExtraPulpShareButton
@onready var sell_extra_block_button = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/RightColumn/BlockMarketContainer/ExtraPulpRow/SellSharePulpButton


# === Data: Upgrade UI & Tabs ===
var all_upgrade_nodes: Dictionary = {} # Upgrade buttons (built in _ready)
var tab_controllers: Dictionary = {}  # Tab logic
var player_stats_for_ticker = []


# === Assets ===
var die_faces: Array = [
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_1.png"),
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_2.png"),
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_3.png"),
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_4.png"),
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_5.png"),
	preload("res://Assets/PNGs/Dice/snake_dice_128_dice_6.png")
]
# === FLAVOR TEXT ===
var headlines = [
	"BREAKING: Local snake discovers 'left' turn, revolutionizes movement.",
	"The Pulp-sicle Stand reports record profits for the third garden in a row.",
	"OP-ED: Are 'Extra Lives' making our snakes soft? Overpaid blogger says so...",
	"Weather forecast: Partly cloudy with a 30% chance of Ghost Peppers.",
	"Anarchists claim responsibility for latest rock slide in Garden 6.",
	"The Snake Cup was claimed last night by the Cincinatti Slith marking back-to-back SnakeBall championships.",
	"Block Market futures slip on shaky jobs report. Plum Block collapse may have ripple effects. More next...",
	"Oil at an all time low, AI scams are better than Snake Oil; new study shows.",
	"Garden 7 under construction still, do not, I repeat, do NOT go in there!",
	"Loading Round 2...It's not round 2 Larry, we use GARDENS, GARDENS, got it?!",
	"Gimme, Gimme, Gimme a man after Slithnight, why'd somebody let me go and type for so long.",
	"Loading Round 1...I mean...Garden 1...I mean...Wait what garden are they on Larry?!",
	"Glutton breaks newest patch with latest ECON updates. BUY ORANGE STOCK NOW!",
	"SBC: Pulp inflation hits 3-year low. AI analysts blame Juice being too lucrative.",
	"Chef upgrade button mental stability update: touch starvation is making me crack...",
	"SnakeCoin hits all-time low, bagholders say HODL. AI says get out before the subpoena",
	"New patch takes out old meta. Players furious. Developer says, \"bite me\"",
	"Statistics show lucky players are currently online! So watch out, they may out roll you",
	"EsoSoft shifts primary focus to B2B cloud-based solutions. Investors cheer, gamers fear...",
	"Research confirms, easter egg clue one is in the fang fund...you didn't see anything, get your stats up",
	"OMG look at these trash stats Larry! Bahahaha can you believe they're even still alive?!",
	"Snake bites own tail, judge's decision could set a new precedent for autotomy law for decades to come",
	"Study finds upgrades do very little. Developer considering further constriction...",
	"How many apples does it take to feed a snake? Put your guess in the comments below and don't forget to LIKE and SUBSCRIBE!",
	"Snake McDoogle has passed away at 95 weeks of age. He was a good one, but...oh...nvm he's still good. BUY SOMETHING"
]


func initialize(p_main_game):
	# When the menu first loads, we find and connect everything once.
	self.main_game = p_main_game
	_build_node_dictionary()
	_connect_all_signals()
	var buy_icon = preload("res://Assets/PNGs/GambleSprites/PlusOne.png")
	var sell_icon = preload("res://Assets/PNGs/GambleSprites/MinusOne.png")
	buy_orange_block_button.icon = buy_icon
	sell_orange_block_button.icon = sell_icon
	buy_apple_block_button.icon = buy_icon
	sell_apple_block_button.icon = sell_icon
	buy_light_block_button.icon = buy_icon
	sell_light_block_button.icon = sell_icon
	buy_extra_block_button.icon = buy_icon
	sell_extra_block_button.icon = sell_icon

func _process(delta):
	# We only scroll if the upgrade menu is visible.
	if not self.visible:
		return
		
	_scroll_ticker(headline_label_a, headline_label_b, headlines, 50.0, delta) # Slower
	_scroll_ticker(stats_label_a, stats_label_b,[], 80.0, delta) # Faster


func _build_node_dictionary():
	all_upgrade_nodes.clear() # Clear it out for safety
	# We loop through our master data source in GameManager.
	for path_key in GameManager.upgrade_data:
		# We need to handle the nested structure of our new data.
		for sub_path_key in GameManager.upgrade_data[path_key]:
			for upgrade_key in GameManager.upgrade_data[path_key][sub_path_key]:
				# We build the node name from the key (e.g., "Liquid Assets" -> "LiquidAssetsNode")
				var node_name = upgrade_key.replace(" ", "").replace("'", "").to_pascal_case() + "Node"
				var node = find_child(node_name, true, false)
				if is_instance_valid(node):
					all_upgrade_nodes[upgrade_key] = node
				else:
					# This warning is very helpful for debugging any naming mismatches!
					print_debug("Warning: Could not find upgrade node named: ", node_name)


# This is our master function for setting up all connections.
func _connect_all_signals():
	# Connect signals for tabs and the main resume button.
	top_tabs.tab_selected.connect(_on_tab_selected)
	resume_button.pressed.connect(_on_resume_button_pressed)
	description_delay_timer.timeout.connect(_on_description_delay_timer_timeout)
	
	# Now, connect the signals from every single UpgradeNode we found.
	for upgrade_key in all_upgrade_nodes:
		var node = all_upgrade_nodes[upgrade_key]
		# We connect the button's own 'pressed' signal, not a custom one.
		node.pressed.connect(_on_any_node_pressed.bind(upgrade_key))
		node.mouse_entered.connect(_on_any_node_mouse_entered.bind(upgrade_key))
		node.mouse_exited.connect(_on_any_node_mouse_exited)
	#---CONNECT ALL SNAKEEYES WAGER STUFF---
	snake_coin_wager_slider.value_changed.connect(_on_snake_coin_slider_changed)
	snake_coin_heads_button.pressed.connect(_on_snake_coin_flip_pressed.bind("Heads"))
	snake_coin_tails_button.pressed.connect(_on_snake_coin_flip_pressed.bind("Tails"))
	dice_wager_slider.value_changed.connect(_on_dice_slider_changed)
	dice_roll_button.pressed.connect(_on_roll_dice_button_pressed)
	hoard_count_button.pressed.connect(_on_start_hoard_count_pressed)
	hoard_count_slider.value_changed.connect(_on_hoard_count_slider_changed)
	#---CONNECT ALL BLOCK/STOCK MARKET BUTTONS
	buy_apple_block_button.pressed.connect(_on_buy_stock_pressed.bind("Apple Block"))
	buy_extra_block_button.pressed.connect(_on_buy_stock_pressed.bind("Extra Block"))
	buy_light_block_button.pressed.connect(_on_buy_stock_pressed.bind("Light Block"))
	buy_orange_block_button.pressed.connect(_on_buy_stock_pressed.bind("Orange Block"))
	sell_apple_block_button.pressed.connect(_on_sell_stock_pressed.bind("Apple Block"))
	sell_extra_block_button.pressed.connect(_on_sell_stock_pressed.bind("Extra Block"))
	sell_light_block_button.pressed.connect(_on_sell_stock_pressed.bind("Light Block"))
	sell_orange_block_button.pressed.connect(_on_sell_stock_pressed.bind("Orange Block"))

	# --- Connect Dice Stepper Buttons ---
	$CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/HouseSpecialContainer/GuessRow/LeftArrowButton.pressed.connect(_on_dice_arrow_pressed.bind(-1))
	$CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/HouseSpecialContainer/GuessRow/RightArrowButton.pressed.connect(_on_dice_arrow_pressed.bind(1))
	# --- Connect Hoard Count Arrow Buttons
	$CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/HoardCountContainer/GuessRow/LeftArrowButton.pressed.connect(_on_hoard_count_arrow_pressed.bind(-1))
	$CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/LeftColumn/HoardCountContainer/GuessRow/RightArrowButton.pressed.connect(_on_hoard_count_arrow_pressed.bind(1))

# This function is called from main.gd right before the menu appears.
func set_initial_state_and_update():
	top_tabs.current_tab = 0 # Default to the first tab
	update_all_displays()

# This function refreshes every piece of information in the menu.
func update_all_displays():
	update_juice_and_pulp_label()
	update_stats_tab()
	
	var disabled_paths = GameManager.disabled_paths
	
	# This one loop now updates every single upgrade node in the game.
	for i in range(top_tabs.get_tab_count()):
		var tab_title = top_tabs.get_tab_title(i)
		if tab_title in disabled_paths or (tab_title == "Snake Eyes" and GameManager.gambling_disabled):
			top_tabs.set_tab_hidden(i, true)
		else:
			top_tabs.set_tab_hidden(i, false)
			
	for upgrade_key in all_upgrade_nodes:
		var node = all_upgrade_nodes[upgrade_key]
		var rules = GameManager.get_upgrade_rules(upgrade_key)
		
		if rules.is_empty(): continue
		
		if node.is_visible_in_tree():
			var current_level = GameManager.get_upgrade_level_from_key(upgrade_key)
			var prereqs_met = main_game.check_prerequisites(upgrade_key)
			var theme_colors = get_theme_colors(rules)
			
			node.update_display(upgrade_key, current_level, rules.max_level, prereqs_met, theme_colors.main, theme_colors.accent, "Default")
	var current_tab_index = top_tabs.current_tab
	var current_tab_name = top_tabs.get_tab_title(current_tab_index)
	if current_tab_name == "Snake Eyes":
		update_snake_eyes_tab()
	
func get_theme_colors(rules: Dictionary) -> Dictionary:
	var colors = {"main": Color.WHITE, "accent": Color.GRAY}
	# This helper returns a unique color for each skill tree theme.
	match rules.get("path", ""):
		"The Core": colors.main = Color("42AEE0")
		"The Harvest": colors.main = Color("7ED321")
		"The Redline": colors.main = Color("D0021B")
		"The Ssscale": colors.main = Color("BD10E2")
		"Snake Eyes": colors.main = Color("fdf5e6")
		
	match rules.get("sub_path", ""):
		"Idle": colors.accent = Color("69D2A3")
		"Planner": colors.accent = Color("E5E5E5")
		"Ledger": colors.accent = Color("F5A623")
		"Glutton": colors.accent = Color("F37A23")
		"Chef": colors.accent = Color("F8E71C")
		"Geode": colors.accent = Color("8B572A")
		"Acrobat": colors.accent = Color("F8E71C")
		"Frenzy": colors.accent = Color("FF00FF")
		"Survivor": colors.accent = Color("8E8E93")
		"Illusionist": colors.accent = Color("50E3C2")
		"Architect": colors.accent = Color("4A90E2")
		"Passives": colors.accent = Color("ffffff")
		
	return colors
	
	#var ng_plus_button = find_upgrade_button("New Game S+")
	#if is_instance_valid(ng_plus_button):
		#var can_prestige = (GameManager.current_garden == 5 and GameManager.times_died_this_run == 0)
		#ng_plus_button.get_parent().visible = can_prestige
		#if can_prestige:
			#update_button_display("New Game S+")

# --- HELPER FUNCTIONS  ---


func find_upgrade_button(upgrade_key: String):
	# We build the expected button name from the key.
	# e.g., "Edge Lord" -> "EdgeLordButton"
	var button_name = upgrade_key.replace(" ", "").to_pascal_case() + "Button"
	
	# find_child() is the correct recursive search function for Godot 4.
	var button = find_child(button_name, true, false)
	if not is_instance_valid(button):
		print_debug("Warning: Could not find button named '", button_name, "'")
	return button



func _on_any_node_pressed(upgrade_key: String):
	main_game.handle_upgrade_purchase(upgrade_key)

func _on_any_node_mouse_entered(upgrade_key: String):
	# Instead of showing the panel, we store the key and start the timer.
	hovered_upgrade_key = upgrade_key
	description_delay_timer.start()

func _on_any_node_mouse_exited():
	# If the mouse leaves, we stop the timer and hide the panel.
	description_delay_timer.stop()
	description_panel.visible = false
	hovered_upgrade_key = ""

func _on_description_delay_timer_timeout():
	# This function runs ONLY if the mouse has hovered for 0.2 seconds.
	
	# 1. Safety check: If we aren't hovering anything, do nothing.
	if hovered_upgrade_key == "":
		return

	# 2. Get the rules and cost for the hovered upgrade using our helpers.
	var rules = GameManager.get_upgrade_rules(hovered_upgrade_key)
	# Another safety check in case the key was somehow invalid.
	if rules.is_empty():
		return
		
	var cost = main_game.calculate_upgrade_cost(hovered_upgrade_key)
	# We get the display name directly from the rules dictionary.
	var display_name = rules.get("display_name", hovered_upgrade_key)
	var description = rules.get("description", "No description available.")
	
	# --- THIS IS THE NEW POSITIONING LOGIC ---
	
	# 3. Get the size of the screen (the viewport) and the mouse position.
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_position = get_viewport().get_mouse_position()
	# 4. Create a new Vector2 to hold the panel's final position.
	var panel_size = description_panel.size
	var vertical_center = mouse_position.y - panel_size.y / 2

	if mouse_position.x < viewport_size.x / 2.0:
		# Simulate Center Right (panel appears to the right of cursor)
		description_panel.position = mouse_position + Vector2(60, 0)
		description_panel.position.y = vertical_center
	else:
		# Simulate Center Left (panel appears to the left of cursor)
		description_panel.position = mouse_position - Vector2(panel_size.x + 60, 0)
		description_panel.position.y = vertical_center
	#CLAMP
	description_panel.position = description_panel.position.clamp(Vector2.ZERO, viewport_size - panel_size)
	
	
	var current_level = main_game.get_upgrade_level_from_key(hovered_upgrade_key)
	# 8. show it with all the correct info.
	description_panel.show_info(
		hovered_upgrade_key,
		display_name, description,
		cost,
		current_level,
		rules.max_level,
		"mL" # currency
	)

# --- INDIVIDUAL UPDATE FUNCTIONS ---

func update_stats_tab():
	# Update the labels inside stats panel
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

	
	# Reset the sliders
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


# --- SIGNAL HANDLER FUNCTIONS ---

func _on_zone_button_pressed(quadrant_index):
	# We only allow changing the zone if we have enough levels.
	if GameManager.zoning_ordinance_level > quadrant_index:
		GameManager.zoned_quadrant = quadrant_index
		print("Safe zone set to quadrant: ", quadrant_index)
		# could add visual feedback here to show which zone is selected

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

func _on_tab_selected(_tab_index):
	# When we switch tabs, we just need to update all the displays again.
	update_all_displays()

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
	

	
	# 4. Play the coin flip animation.
	var coin = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/PanelContainer/CoinContainerControl
	var coin_sprite = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/PanelContainer/CoinContainerControl/CoinSprite
	var head_texture = preload("res://Assets/PNGs/GambleSprites/snake_poker_chip_heads - Copy.png")
	var tails_texture = preload("res://Assets/PNGs/GambleSprites/snake_poker_chip_tails.png")
	coin.visible = true
	for i in range(10):
		var loop_bank = [head_texture, tails_texture]
		var rand_choice = loop_bank.pick_random()
		coin_sprite.texture = rand_choice
		await get_tree().create_timer(0.02).timeout
		
	if outcome == "Heads": coin_sprite.texture = head_texture
	elif outcome == "Tails": coin_sprite.texture = tails_texture
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
	var die_sprite = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/PanelContainer/DieSprite
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
	var basket_sprite = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/PanelContainer/BasketSprite
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
	var result_label = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/PanelContainer/ResultControl/ResultLabel
	
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


func _setup_ticker(label_a: Label, label_b: Label, text_pool: Array):
	# This helper function prepares a ticker for its very first scroll.
	label_a.text = _get_new_ticker_text(text_pool)
	label_b.text = _get_new_ticker_text(text_pool)
	
	label_a.position.x = 0
	label_b.position.x = label_a.get_minimum_size().x


func start_tickers():
	# We get a reference to the labels here.
	
	# Now, kick off the animation loop for each ticker.
	_setup_ticker(headline_label_a, headline_label_b, headlines)
	_setup_ticker(stats_label_a, stats_label_b, [])


func _scroll_ticker(label_a: Label, label_b: Label, text_pool: Array, speed: float, delta: float):
	# Move both labels to the left every frame.
	label_a.position.x -= speed * delta
	label_b.position.x -= speed * delta
	
	# This is the "leapfrog" logic.
	# If a label has moved completely off-screen to the left...
	if label_a.position.x < -label_a.get_minimum_size().x:
		# ...we give it new text...
		label_a.text = _get_new_ticker_text(text_pool)
		# ...and teleport it to the end of the other label.
		label_a.position.x = label_b.position.x + label_b.get_minimum_size().x
		
	if label_b.position.x < -label_b.get_minimum_size().x:
		label_b.text = _get_new_ticker_text(text_pool)
		label_b.position.x = label_a.position.x + label_a.get_minimum_size().x
		
func _get_new_ticker_text(text_pool: Array) -> String:
	if text_pool.is_empty(): # This is our stats ticker
		var stats = [
			"JUICE: %s mL" % GameManager.juice,
			"PULP: %s mg" % GameManager.pulp,
			"LENGTH: %s" % (main_game.snake_body_segments.size() + 1),
			"LEVEL: %s" % GameManager.player_level,
			"EXTRA LIVES: %s" % GameManager.extra_lives,
			"COMBO: x%s" % GameManager.current_combo,
			"CURRENT GARDEN: %s / 9" % GameManager.current_garden,
			"GARDEN NAME: %s" % GameManager.garden_data[GameManager.current_garden]["name"],
			"FRUIT REWARD: %s" % main_game.get_effective_fruit_reward(),
			"MAX FRUITS: %s" % GameManager.max_fruits_on_screen,
			"ABILITY SLOTS STILL LOCKED: %s" % [(10 - GameManager.max_ability_slots)],
			"NUMBER OF OBSTACLES NEXT GARDEN: %s" % [(GameManager.garden_data[max(9, GameManager.current_garden + 1)])["obstacle_count"]],
			"ORANGE BLOCK: %s mL/share" % GameManager.block_market_prices["Orange Block"]["price"],
			"APPLE BLOCK: %s mL/share" % GameManager.block_market_prices["Apple Block"]["price"],
			"LIGHT BLOCK: %s mg/share" % GameManager.block_market_prices["Light Block"]["price"],
			"EXTRA BLOCK: %s mg/share" % GameManager.block_market_prices["Extra Block"]["price"]
		]
		stats.shuffle()
		return "  •••  ".join(stats)
	else: # This is our headline ticker
		return text_pool.pick_random()
