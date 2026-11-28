extends CanvasLayer

# === Signals ===
signal resume_game_pressed


# === Core References ===
var main_game
var hovered_upgrade_key: String = ""
var hovered_pulp_bundle: PulpBundleData = null
var is_switching_tabs: bool = false


# === Gameplay State ===
var current_dice_guess: int = 1
var current_hoard_guess: int = 1


# === UI References ===
# -- Top-Level UI --
@onready var top_tabs = $CenterContainer/PanelContainer/VBoxContainer/TopTabs
@onready var description_label = $DescriptionText
@onready var description_panel = $PanelControl/DescriptionPanel
@onready var juice_label = $BottomPanel/BottomRowHBox/BottomJuiceLabel
@onready var pulp_label = $BottomPanel/BottomRowHBox/BottomPulpLabel
@onready var resume_button = $BottomPanel/BottomRowHBox/ResumeButton
@onready var description_delay_timer = $DescriptionDelayTimer

# -- Stats Panel --
@onready var stats_panel = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/Stats/VBoxContainer/StatsHBox
@onready var side_stats_panel = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/Stats/VBoxContainer/MainRow/LevelUpStatsContainer/VBoxStats
@onready var pulp_loot_grid: GridContainer = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/Stats/VBoxContainer/MainRow/ScrollContainer/PulpLootGrid

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
var headlines = [ # Add pools for defcon 1-5 with 5 being base
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
## Pulp Container Stuff
const PULP_TIER_BORDERS: Dictionary = {
	PulpBundleData.Tier.COMMON: Color("#b0b0b0"),
	PulpBundleData.Tier.RARE: Color("#4da6ff"),
	PulpBundleData.Tier.LEGENDARY: Color("#ffd700"),
	PulpBundleData.Tier.CURSE: Color("#ff4d4d"),
}



func _ready():
	await get_tree().process_frame
	description_panel.hide()

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
	all_upgrade_nodes.clear()
	for upgrade_key in GameManager.upgrades:
		var clean_key = upgrade_key.replace(" ", "").replace("'", "").replace("-", "")
		var node_name = clean_key.to_pascal_case() + "Node"
		var matches: Array = []

		var main_node = find_child(node_name, true, false)
		if is_instance_valid(main_node):
			matches.append(main_node)
		else:
			print_debug("Warning: Could not find node %s for upgrade ID %s" % [node_name, upgrade_key])

		var essential_node = find_child("Essential" + node_name, true, false)
		if is_instance_valid(essential_node):
			matches.append(essential_node)

		if not matches.is_empty():
			all_upgrade_nodes[upgrade_key] = matches


# This is our master function for setting up all connections.
func _connect_all_signals():
	# Connect signals for tabs and the main resume button.
	top_tabs.tab_selected.connect(_on_tab_selected)
	resume_button.pressed.connect(_on_resume_button_pressed)
	description_delay_timer.timeout.connect(_on_description_delay_timer_timeout)
	
	# Now, connect the signals from every single UpgradeNode we found.
	for upgrade_key in all_upgrade_nodes:
		for node in all_upgrade_nodes[upgrade_key]:
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
		var rules = GameManager.get_upgrade_rules(upgrade_key)
		if not rules: 
			continue

		var current_level = GameManager.get_upgrade_level_from_key(upgrade_key)
		var prereqs_met = GameManager.check_prerequisites(upgrade_key)
		var theme_colors = get_theme_colors(rules)
		var path_disabled = (rules.path in disabled_paths) or (rules.sub_path in disabled_paths)
			
		for node in all_upgrade_nodes[upgrade_key]:
			node.visible = not path_disabled
			node.update_display(upgrade_key, current_level, rules.max_level, prereqs_met, theme_colors.main, theme_colors.accent, "Default")
	
	
	update_snake_eyes_tab()
	
func get_theme_colors(rules: UpgradeData) -> Dictionary:
	var colors = {"main": Color.WHITE, "accent": Color.GRAY}
	# This helper returns a unique color for each skill tree theme.
	match rules.path:
		"The Core": colors.main = Color("42AEE0")
		"The Harvest": colors.main = Color("7ED321")
		"The Redline": colors.main = Color("D0021B")
		"The Ssscale": colors.main = Color("BD10E2")
		"Snake Eyes": colors.main = Color("8B572A")
		
	match rules.sub_path:
		"Idle": colors.accent = Color("69D2A3")
		"Planner": colors.accent = Color("E5E5E5")
		"Ledger": colors.accent = Color("F5A623")
		"Glutton": colors.accent = Color("F37A23")
		"Wrangler": colors.accent = Color("F8E71C")
		"Geode": colors.accent = Color("8B572A")
		"Acrobat": colors.accent = Color("F8E71C")
		"Frenzy": colors.accent = Color("FF00FF")
		"Survivor": colors.accent = Color("8E8E93")
		"Illusionist": colors.accent = Color("50E3C2")
		"Architect": colors.accent = Color("4A90E2")
		"Gamba": colors.accent = Color("f5a623")
		
	return colors


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
	hovered_pulp_bundle = null
	description_delay_timer.start()

func _on_any_node_mouse_exited():
	description_delay_timer.stop()
	description_panel.visible = false
	hovered_upgrade_key = ""
	hovered_pulp_bundle = null

func _on_description_delay_timer_timeout():
	if hovered_pulp_bundle != null:
		var count: int = GameManager.claimed_pulp_bundles.get(hovered_pulp_bundle.id, 1)
		var status: String = "Owned (x%d)" % count if count > 1 else "Owned"
		description_panel.show_pulp_bundle(hovered_pulp_bundle, status)
	elif hovered_upgrade_key != "":
		var rules = GameManager.get_upgrade_rules(hovered_upgrade_key)
		if not rules:
			return
		var cost = GameManager.calculate_upgrade_cost(hovered_upgrade_key)
		var current_level = GameManager.get_upgrade_level_from_key(hovered_upgrade_key)
		description_panel.show_info(rules, current_level, cost, "L")
	else:
		return
	
	#Quadrant spacing
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_position = get_viewport().get_mouse_position()

	if mouse_position.x < viewport_size.x / 2.0:
		description_panel.position.x = mouse_position.x + 32
	else:
		description_panel.position.x = mouse_position.x - description_panel.size.x - 32
	
	if mouse_position.y < viewport_size.y / 2.0:
		description_panel.position.y = mouse_position.y - 64
	else:
		description_panel.position.y = mouse_position.y - description_panel.size.y
	#description_panel.position.y = clamp(
		#mouse_position.y - (description_panel.size.y/2.0),
		#20,
		#viewport_size.y - description_panel.size.y - 20
	#)
	description_panel.visible = true



# --- INDIVIDUAL UPDATE FUNCTIONS ---

func update_stats_tab():
	# Update the labels inside stats panel
	if is_instance_valid(stats_panel):
		stats_panel.get_node("ClassLabel").text = "Class: " + GameManager.chosen_class.capitalize()
		stats_panel.get_node("DifficultyLabel").text = "Difficulty: " + GameManager.chosen_difficulty.capitalize()
		stats_panel.get_node("LevelLabel").text = "Level: " + str(GameManager.player_level)
	#Check our other stats panel on the side
	if is_instance_valid(side_stats_panel):
		side_stats_panel.get_node("FruitRewardStatsLabel").text = "Growth/fruit: " + str(main_game.get_effective_fruit_reward())
		side_stats_panel.get_node("MaxFruitsStatsLabel").text = "Max Fruits: " + str(GameManager.max_fruits_on_screen)
		side_stats_panel.get_node("GridSizeStatsLabel").text = "%s X %s tiles (l X h)" % [main_game.grid_width, main_game.grid_height]
		side_stats_panel.get_node("TotalFruitsStatsLabel").text = "Fruits eaten this run: " + str(GameManager.fruits_eaten_this_run)
		side_stats_panel.get_node("TotalJuiceStatsLabel").text = "Juice squeezed this run: " + str(GameManager.total_juice_earned_this_run) + " L"
		side_stats_panel.get_node("TotalPulpStatsLabel").text = "Pulp gathered this run: " + str(GameManager.total_pulp_earned_this_run) + " mg"
		side_stats_panel.get_node("NextGardenGoalLabel").text = "Next Garden Goal: " + str(GameManager.get_effective_garden_goal(min(GameManager.current_garden + 1, 9)))
	
	_refresh_pulp_loot_grid()

func update_snake_eyes_tab():
	# Update the max value of the sliders
	snake_coin_wager_slider.max_value = GameManager.juice
	dice_wager_slider.max_value = GameManager.juice


	
	# Reset the sliders
	snake_coin_wager_slider.value = 0
	dice_wager_slider.value = 0

	
	# --- THIS IS THE NEW PART ---
	# Reset the button text to its default state
	snake_coin_heads_button.text = "Call Heads\n(XXL)"
	snake_coin_tails_button.text = "Call Tails\n(XXL)"
	dice_roll_button.text = "Roll for Glory!\n(XXL)"
	
	main_game.update_ability_hotbar()
	update_juice_and_pulp_label()
	update_block_market_display()

func update_juice_and_pulp_label():
	juice_label.text = str(GameManager.juice) + " L"
	pulp_label.text = str(GameManager.pulp) + " mg"


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
		
	main_game.update_hud()
	update_juice_and_pulp_label()
	
	# --- Gambit Modifier ---
	var gambit = GameManager.meta_upgrades.get("The Gambit") as MetaUpgradeData
	var heads_chance = gambit.get_value_at_level(GameManager.the_gambit_level, 0.5) if gambit else 0.5
	
	var outcome = "Heads" if randf() < heads_chance else "Tails"
	print("The result is... ", outcome)

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
		if GameManager.current_garden == 2 and not GameManager.ascension_steps_completed.has("garden_2"):
			print("EASTER EGG STEP 2 COMPLETE!")
			GameManager.ascension_steps_completed["garden_2"] = true
			main_game._apply_easter_egg_boon(2)
		print("WINNER!")
		GameManager.juice += (wager * 2)
		if GameManager.passive_income_unlocked:
			GameManager.correct_bets_this_run += 1
			GameManager.fruit_reward += 1
			await play_result_animation(true, "Correct!\nYou win +%sL" % [wager * 2])
		else:
			await play_result_animation(true, "Cash in!\n+%sL" % [wager * 2])
	else:
		print("You lose.")
		await play_result_animation(false, "Better luck next time!\nYou lose %sL" % [wager])
	# 7. Update all UI and re-enable everything.
	# Extra delay -> await get_tree().create_timer(1.5).timeout
	coin.visible = false
	
	# HOT-FIX: call update_snake_eyes_tab() AFTER the bet resolves to correctly update the slider's max value and re-enable the buttons.
	update_snake_eyes_tab()
	# also call main_game.update_hud() again to show the final winnings.
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
		if GameManager.current_garden == 6 and not GameManager.ascension_steps_completed.has("garden_6"):
			print("EASTER EGG STEP 6 COMPLETE!")
			GameManager.ascension_steps_completed["garden_6"] = true
			main_game._apply_easter_egg_boon(6)
		GameManager.juice += (wager * 6)
		if GameManager.passive_income_unlocked:
			GameManager.correct_bets_this_run += 1
			GameManager.fruit_reward += 1
			await play_result_animation(true, "How did you do it?!\n+%sL" % [wager * 6])
		else:
			await play_result_animation(true, "YOU CALLED IT!\n+%sL" % [wager * 6])
	else:
		print("You lose.")
		await play_result_animation(false, "Next time, sorry!\n-%sL" % [wager])
		
	# 7. Update all UI and re-enable everything.
	# Extra pause await get_tree().create_timer(1.5).timeout # A longer dramatic pause
	die_sprite.visible = false
	update_snake_eyes_tab()
	main_game.update_hud()
	update_juice_and_pulp_label()
	set_gambling_ui_disabled(false)



func play_result_animation(is_win: bool, custom_message: String = ""):
	var result_label = $CenterContainer/PanelContainer/VBoxContainer/TopTabs/SnakeEyes/MainContent/PanelContainer/ResultControl/ResultLabel
	
	# 1. Set the text and color based on the outcome.
	if is_win:
		var win_messages = ["WIN!", "Chicken Dinner!", "Lucky you!", "You win this time!"]
		result_label.text = win_messages.pick_random()
		result_label.modulate = Color.GOLD
	else:
		# Random losing messages!
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
		GameManager.total_juice_earned_this_run += price
	else:
		GameManager.pulp += price
		GameManager.total_pulp_earned_this_run += price
		
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
			"JUICE: %s L" % GameManager.juice,
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
			"NUMBER OF OBSTACLES NEXT GARDEN: %s" % [(GameManager.garden_data[min(9, GameManager.current_garden + 1)])["obstacle_count"]],
			"ORANGE BLOCK: %s L/share" % GameManager.block_market_prices["Orange Block"]["price"],
			"APPLE BLOCK: %s L/share" % GameManager.block_market_prices["Apple Block"]["price"],
			"LIGHT BLOCK: %s mg/share" % GameManager.block_market_prices["Light Block"]["price"],
			"EXTRA BLOCK: %s mg/share" % GameManager.block_market_prices["Extra Block"]["price"]
		]
		stats.shuffle()
		return "  •••  ".join(stats)
	else: # This is our headline ticker
		return text_pool.pick_random()


func _refresh_pulp_loot_grid() -> void:
	if not is_instance_valid(pulp_loot_grid):
		return

	for child in pulp_loot_grid.get_children():
		child.queue_free()

	# Preserve order of first acquisition while stacking repeats (e.g., multiple One Bites)
	var seen_ids: Dictionary = {}
	for bundle: PulpBundleData in GameManager.pulp_bundle_history:
		if seen_ids.has(bundle.id):
			continue
		seen_ids[bundle.id] = true

		var count: int = GameManager.claimed_pulp_bundles.get(bundle.id, 1)
		pulp_loot_grid.add_child(_create_pulp_loot_tile(bundle, count))

func _create_pulp_loot_tile(bundle: PulpBundleData, count: int) -> PanelContainer:
	var tile := PanelContainer.new()
	tile.custom_minimum_size = Vector2(56, 56)
	tile.mouse_filter = Control.MOUSE_FILTER_STOP
	tile.mouse_entered.connect(_on_pulp_loot_mouse_entered.bind(bundle))
	tile.mouse_exited.connect(_on_any_node_mouse_exited)

	var style := StyleBoxFlat.new()
	style.bg_color = Color("#1e1e1e")
	style.border_color = PULP_TIER_BORDERS.get(bundle.tier, Color.WHITE)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(4)
	tile.add_theme_stylebox_override("panel", style)

	var tex := TextureRect.new()
	tex.texture = bundle.icon
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(tex)

	if count > 1:
		var badge := Label.new()
		badge.text = "x%d" % count
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		badge.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		badge.add_theme_font_size_override("font_size", 12)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(badge)

	return tile


func _on_pulp_loot_mouse_entered(bundle: PulpBundleData) -> void:
	hovered_upgrade_key = ""
	hovered_pulp_bundle = bundle
	description_delay_timer.start()
