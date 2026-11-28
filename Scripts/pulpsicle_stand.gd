extends CanvasLayer

# This signal tells main.gd that the player is ready to move on.
signal continue_to_next_garden
signal skip_garden_pressed


@export var ng_plus_data: MetaUpgradeData
# --- NODE REFERENCES ---
# Get references to all the UI elements we need to update.
@onready var current_pulp_label = $AnimationContainer/MainContainer/VBox/BottomPanel/BottomHBox/CurrentPulpLabel
@onready var current_juice_label = $AnimationContainer/MainContainer/VBox/BottomPanel/BottomHBox/CurrentJuiceLabel

@onready var synapse_node = $AnimationContainer/MainContainer/VBox/SynapseRow/SynapseSlotNode
@onready var chroma_scales_node = $AnimationContainer/MainContainer/VBox/PillarsContainer/ChromaScalesNode
@onready var themed_tickers_node = $AnimationContainer/MainContainer/VBox/PillarsContainer/ThemedTickersNode
@onready var the_gambit_node = $AnimationContainer/MainContainer/VBox/PillarsContainer/TheGambitNode
@onready var four_leaf_node = $AnimationContainer/MainContainer/VBox/PillarsContainer/FourLeafCloverNode
@onready var compound_interest_node = $AnimationContainer/MainContainer/VBox/PillarsContainer/CompoundInterestNode

@onready var continue_button = $AnimationContainer/MainContainer/VBox/BottomPanel/BottomHBox/ContinueButton
@onready var skip_garden_button = $AnimationContainer/MainContainer/VBox/RouletteContainer/RotatingItemRow/SkipGardenButton
@onready var new_game_s_plus_button = $AnimationContainer/MainContainer/VBox/RouletteContainer/RotatingItemRow/NewGameSPlusButton


@onready var animation_container = $AnimationContainer

@onready var description_panel = $PanelControl/DescriptionPanel
@onready var description_delay_timer = $DescriptionDelayTimer

enum StandState { HIDDEN, REVEALED, CURSED, CLAIMED }

## Rotating Item
const TIER_COLORS: Dictionary = {
	PulpBundleData.Tier.COMMON: Color("#b0b0b0"),
	PulpBundleData.Tier.RARE: Color.DODGER_BLUE,
	PulpBundleData.Tier.LEGENDARY: Color.GOLD,
	PulpBundleData.Tier.CURSE: Color("#ff4d4d"),
}


@onready var reroll_cost_label = $AnimationContainer/MainContainer/VBox/RouletteContainer/RotatingItemRow/VBoxContainer/RerollCostLabel
@onready var rotating_item_node = $AnimationContainer/MainContainer/VBox/RouletteContainer/RotatingItemRow/RotatingItemNode
@onready var reroll_button: Button = $AnimationContainer/MainContainer/VBox/RouletteContainer/RotatingItemRow/VBoxContainer/RerollButton
@export var mystery_question_icon: Texture2D
@export var base_reroll_cost: int = 10
@export var reroll_multiplier: float = 10.0
var rolls_this_visit: int = 0

var pool := PulpStandPool.new()
var stand_state: StandState = StandState.HIDDEN
var current_bundle: PulpBundleData = null


var pillar_nodes: Dictionary = {}
var hovered_item_key: String = ""
var main_game: Node2D


func _ready() -> void:
	main_game = get_tree().current_scene
	_build_node_dictionary()
	_connect_all_signals()
	pool.load_all_bundles()
	await get_tree().process_frame
	description_panel.hide()



func _build_node_dictionary():
	pillar_nodes = {
		"Synapse Slot": synapse_node,
		"Chroma Scales": chroma_scales_node,
		"Themed Tickers": themed_tickers_node,
		"The Gambit": the_gambit_node,
		"Four Leaf Clover": four_leaf_node,
		"Compound Interest": compound_interest_node
	}

	

func _connect_all_signals():
	# Loop through our dictionary to connect all the pillar nodes.
	for upgrade_key in pillar_nodes:
		var node = pillar_nodes[upgrade_key]
		if is_instance_valid(node):
			# We now connect to the button's built-in "pressed" signal,
			# not our old custom one. We use .bind() to tell the handler
			# which upgrade was clicked. This will correctly send only ONE argument.
			node.pressed.connect(_on_pillar_node_pressed.bind(upgrade_key))
			
			# We do the same for the hover effects.
			node.mouse_entered.connect(_on_any_node_mouse_entered.bind(upgrade_key))
			node.mouse_exited.connect(_on_any_node_mouse_exited.bind(upgrade_key))
			
	description_delay_timer.timeout.connect(_on_description_delay_timer_timeout)
	# Connect the other buttons
	continue_button.pressed.connect(_on_continue_button_pressed)
	skip_garden_button.pressed.connect(_on_skip_garden_button_pressed)
	reroll_button.pressed.connect(_on_reroll_button_pressed)
	
	rotating_item_node.pressed.connect(_on_rotating_item_pressed)
	rotating_item_node.mouse_entered.connect(_on_any_node_mouse_entered.bind("rotating_item"))
	rotating_item_node.mouse_exited.connect(_on_any_node_mouse_exited.bind("rotating_item"))

	new_game_s_plus_button.mouse_entered.connect(_on_any_node_mouse_entered.bind("ng_plus"))
	new_game_s_plus_button.mouse_exited.connect(_on_any_node_mouse_exited.bind("ng_plus"))
	new_game_s_plus_button.pressed.connect(_on_new_game_s_plus_pressed)


# This is the master function that main.gd will call.
func open_shop():
	current_bundle = null
	stand_state = StandState.HIDDEN
	rolls_this_visit = 0
	animation_container.visible = false
	update_all_displays()
	self.visible = true
	

# This function refreshes every piece of information in the shop.
func update_all_displays():
	update_pulp_label()
	for upgrade_key in pillar_nodes:
		_update_pillar_node(upgrade_key)
	update_rotating_item_display()
	# --- NEW: Show/Hide the Skip Button ---
	skip_garden_button.visible = (GameManager.fast_track_unlocked and GameManager.current_garden < 8)
	new_game_s_plus_button.visible = (GameManager.current_garden == 8 and GameManager.times_died_this_run == 0)

# --- UPDATE FUNCTIONS ---

func update_pulp_label():
	current_pulp_label.text = "%s mg" % GameManager.pulp
	current_juice_label.text = "%s L" % GameManager.juice


# This is our new, reusable helper function. It can update ANY pillar button.
func _update_pillar_node(upgrade_key: String):
	var node = pillar_nodes.get(upgrade_key)
	var rules = GameManager.meta_upgrades.get(upgrade_key) as MetaUpgradeData
	if not is_instance_valid(node): 
		return

	var current_level = main_game.get_meta_upgrade_level(upgrade_key)

	# Pass all the data to the node's own update function.
	node.update_display(
		upgrade_key, 
		current_level, 
		rules.max_level, 
		true, 
		Color("a3d5ff"), 
		Color.GOLD, 
		"Frosty"
	)


func update_rotating_item_display():
	var node = rotating_item_node
	match stand_state:
		StandState.HIDDEN:
			node.disabled = false
			node.modulate = Color.WHITE
			node.display_pulp_item(mystery_question_icon, Color("a3d5ff"), Color.WHITE, "Frosty")
			reroll_cost_label.text = "Roll: FREE"
			reroll_button.disabled = false

		StandState.REVEALED:
			var tier_color: Color = TIER_COLORS.get(current_bundle.tier, Color.GRAY)
			var next_cost := _get_current_reroll_cost()
			node.disabled = false
			node.modulate = Color.WHITE
			node.display_pulp_item(current_bundle.icon, tier_color, tier_color, "Frosty")
			reroll_cost_label.text = "Reroll: %d mg" % next_cost
			reroll_button.disabled = GameManager.pulp < next_cost

		StandState.CURSED:
			var curse_color: Color = TIER_COLORS[PulpBundleData.Tier.CURSE]
			node.disabled = true
			node.modulate = Color.WHITE
			node.display_pulp_item(current_bundle.icon, curse_color, curse_color, "Frosty")
			reroll_cost_label.text = "Rerolls Locked!"
			reroll_button.disabled = true

		StandState.CLAIMED:
			var next_cost := _get_current_reroll_cost()
			node.disabled = true
			node.modulate = Color.GRAY
			reroll_cost_label.text = "Reroll: %d mg" % next_cost
			reroll_button.disabled = GameManager.pulp < next_cost


# --- SIGNAL HANDLERS ---

func _on_continue_button_pressed():
	# Hide the shop and tell the main game to proceed.
	emit_signal("continue_to_next_garden")



func _on_pillar_node_pressed(upgrade_key: String):
	var rules = GameManager.meta_upgrades.get(upgrade_key) as MetaUpgradeData
	if not rules:
		return

	var current_level = main_game.get_meta_upgrade_level(upgrade_key)
	if current_level < rules.max_level:
		var cost_index = GameManager.max_ability_slots if upgrade_key == "Synapse Slot" else current_level
		if cost_index >= rules.costs.size():
			return
		var cost = rules.costs[cost_index]
		if GameManager.pulp >= cost:
			GameManager.pulp -= cost
			main_game.handle_meta_upgrade_purchase(upgrade_key)
			update_all_displays()





# This function will animate the shop sliding IN from the bottom of the screen.
func animate_in():
	# 1. Get the screen size so we know where to start.
	var screen_size = get_viewport().get_visible_rect().size
	
	# 2. Set the container's initial position to be just off-screen at the bottom.
	animation_container.position.y = screen_size.y * 1.5
	animation_container.visible = true # We still make the whole layer visible
	
	# 3. Create a tween to animate the container's position.
	var tween = create_tween()
	tween.tween_property(animation_container, "position:y", 0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Wait for the animation to finish before the game continues.
	await tween.finished

# This function will animate the shop sliding OUT at the top of the screen.
func animate_out():
	var screen_size = get_viewport().get_visible_rect().size
	
	# Create a tween to animate the container's position.
	var tween = create_tween()
	tween.tween_property(animation_container, "position:y", -screen_size.y, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	await tween.finished
	# After it's off-screen, make the whole layer invisible again.
	animation_container.visible = false


func _on_any_node_mouse_entered(upgrade_key: String):
	hovered_item_key = upgrade_key
	description_delay_timer.start()

func _on_any_node_mouse_exited(upgrade_key: String):
	# We only act if the mouse is exiting the currently hovered item.
	if hovered_item_key == upgrade_key:
		description_delay_timer.stop()
		description_panel.visible = false
		hovered_item_key = ""

func _on_skip_garden_button_pressed():
	# When this button is pressed, it just sends out the signal.
	# main.gd will be listening and will handle the actual logic.
	emit_signal("skip_garden_pressed")

func _on_description_delay_timer_timeout():
	if hovered_item_key == "":
		return

	if hovered_item_key == "rotating_item":
		match stand_state:
			StandState.HIDDEN:
				description_panel.show_custom_info(
					"Mystery Pulp Roll",
					"Click to roll for free!\nCould be Common, Rare, Legendary... or a Curse.",
					"FREE",
					Color("a3d5ff"),
					mystery_question_icon
				)
			StandState.REVEALED:
				description_panel.show_pulp_bundle(current_bundle, "FREE — Click to Claim")
			StandState.CURSED:
				description_panel.show_pulp_bundle(current_bundle, "CURSED — Reroll Locked")
			StandState.CLAIMED:
				if current_bundle != null:
					description_panel.show_pulp_bundle(current_bundle, "CLAIMED")
				else:
					return
	elif hovered_item_key == "ng_plus":
		description_panel.show_info(ng_plus_data, 0, 0, "mg")
	else:
		var rules = GameManager.meta_upgrades.get(hovered_item_key)
		if not rules:
			return
		var current_level = main_game.get_meta_upgrade_level(hovered_item_key)
		var cost_index = GameManager.max_ability_slots if hovered_item_key == "Synapse Slot" else current_level
		var cost = rules.costs[cost_index] if cost_index < rules.costs.size() else 999
		description_panel.show_info(rules, current_level, cost, "mg")

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
	description_panel.visible = true

func _on_new_game_s_plus_pressed():
	# We just need to tell the GameManager to start a prestige run.
	GameManager.start_new_game_s_plus()


func _on_rotating_item_pressed():
	match stand_state:
		StandState.HIDDEN:
			_do_roll()
		StandState.REVEALED:
			var claimed := current_bundle
			stand_state = StandState.CLAIMED
			_apply_bundle(claimed)
			update_all_displays()
			if hovered_item_key == "rotating_item":
				_on_description_delay_timer_timeout()
				
func _do_roll(exclude_id: StringName = &"", cost: int = 0):
	var rolled := pool.roll_bundle(GameManager, exclude_id)
	if rolled == null:
		push_warning("PulpsicleStand: No eligible PulpBundleData found in pool.")
		return

	if cost > 0:
		GameManager.spend_pulp(cost)

	current_bundle = rolled
	rolls_this_visit += 1

	if current_bundle.tier == PulpBundleData.Tier.CURSE:
		stand_state = StandState.CURSED
		_apply_bundle(current_bundle)
	else:
		stand_state = StandState.REVEALED

	update_all_displays()

	if hovered_item_key == "rotating_item":
		description_delay_timer.stop()
		_on_description_delay_timer_timeout()

func _apply_bundle(bundle: PulpBundleData):
	GameManager.record_pulp_bundle_for_stats_tab(bundle)

	for upg_key in bundle.upgrade_deltas:
		GameManager.add_upgrade_level(upg_key, bundle.upgrade_deltas[upg_key])

	for upg_key in bundle.unlocks:
		GameManager.unlock_upgrade(upg_key)

	for upg_key in bundle.max_out_upgrades:
		GameManager.max_out_upgrade(upg_key)

	if bundle.ability_slot_delta != 0:
		GameManager.modify_ability_slots(bundle.ability_slot_delta)

	match bundle.special_effect:
		PulpBundleData.SpecialEffect.JUICE_EQUAL_GARDEN:
			GameManager.add_juice(GameManager.current_garden)
		PulpBundleData.SpecialEffect.GO_BACK_GARDEN:
			reroll_button.disabled = true
			GameManager.travel_back_one_garden_immediately()
		PulpBundleData.SpecialEffect.DOUBLE_JUICE:
			GameManager.add_juice(GameManager.juice)
		PulpBundleData.SpecialEffect.REVERSE_CONTROLS:
			GameManager.apply_reverse_controls()
		PulpBundleData.SpecialEffect.BLOCK_MARKET_RECESSION:
			GameManager.trigger_market_recession()
		PulpBundleData.SpecialEffect.DISABLE_CHROMA_SCALES:
			GameManager.chroma_scales_enabled = false

func _on_reroll_button_pressed():
	if stand_state == StandState.CURSED:
		return

	var cost := _get_current_reroll_cost()
	if cost > 0 and GameManager.pulp < cost:
		return

	var exclude_id: StringName = current_bundle.id if current_bundle != null else &""
	_do_roll(exclude_id, cost)


func _get_current_reroll_cost() -> int:
	if rolls_this_visit == 0:
		return 0
	return roundi(base_reroll_cost * pow(reroll_multiplier, rolls_this_visit - 1))
