extends CanvasLayer

# This signal tells main.gd that the player is ready to move on.
signal continue_to_next_garden
signal skip_garden_pressed

# --- NODE REFERENCES ---
# Get references to all the UI elements we need to update.
@onready var current_pulp_label = $AnimationContainer/MainContainer/VBoxContainer/BottomPanel/BottomHBox/CurrentPulpLabel
@onready var current_juice_label = $AnimationContainer/MainContainer/VBoxContainer/BottomPanel/BottomHBox/CurrentJuiceLabel
@onready var synapse_node = $AnimationContainer/MainContainer/VBoxContainer/SynapseRow/SynapseSlotNode
@onready var chroma_scales_node = $AnimationContainer/MainContainer/VBoxContainer/PillarsContainer/ChromaScalesNode
@onready var serpents_coffer_node = $AnimationContainer/MainContainer/VBoxContainer/PillarsContainer/SerpentsCofferNode
@onready var geode_compass_node = $AnimationContainer/MainContainer/VBoxContainer/PillarsContainer/GeodeCompassNode
@onready var four_leaf_node = $AnimationContainer/MainContainer/VBoxContainer/PillarsContainer/FourLeafCloverNode
@onready var rotating_item_node = $AnimationContainer/MainContainer/VBoxContainer/RouletteContainer/RotatingItemRow/RotatingItemNode
@onready var lasso_node = $AnimationContainer/MainContainer/VBoxContainer/PillarsContainer/LassoLarryNode
@onready var harvest_forecast_node = $AnimationContainer/MainContainer/VBoxContainer/PillarsContainer/HarvestForecastNode
@onready var continue_button = $AnimationContainer/MainContainer/VBoxContainer/BottomPanel/BottomHBox/ContinueButton
@onready var animation_container = $AnimationContainer
@onready var skip_garden_button = $AnimationContainer/MainContainer/VBoxContainer/RouletteContainer/RotatingItemRow/SkipGardenButton
@onready var description_panel = $AnimationContainer/DescriptionPanel
@onready var description_delay_timer = $DescriptionDelayTimer
# This dictionary will store a reference to every single pillar button.
var pillar_nodes: Dictionary = {}
var hovered_item_key: String = ""

var current_rotating_item: Dictionary = {}
var rotating_item_purchased_this_visit: bool = false

var main_game: Node2D


func _ready() -> void:
	main_game = get_tree().current_scene
	_build_node_dictionary()
	_connect_all_signals()


func _build_node_dictionary():
	# We build a dictionary of our pillar nodes for easy access.
	# FIX: The keys now perfectly match the keys in GameManager.meta_upgrade_data.
	pillar_nodes = {
		"Synapse Slot": synapse_node,
		"Serpents Coffer": serpents_coffer_node,
		"Geode Compass": geode_compass_node,
		"Four Leaf Clover": four_leaf_node,
		"Chroma Scales": chroma_scales_node,
		"Lasso Larry": lasso_node,
		"Harvest Forecast": harvest_forecast_node
	}

	

func _connect_all_signals():
	# Loop through our dictionary to connect all the pillar nodes.
	for upgrade_key in pillar_nodes:
		var node = pillar_nodes[upgrade_key]
		if is_instance_valid(node):
			# --- THIS IS THE FIX ---
			# We now connect to the button's built-in "pressed" signal,
			# not our old custom one. We use .bind() to tell the handler
			# which upgrade was clicked. This will correctly send only ONE argument.
			node.pressed.connect(_on_pillar_node_pressed.bind(upgrade_key))
			
			# We do the same for the hover effects.
			node.mouse_entered.connect(_on_any_node_mouse_entered.bind(upgrade_key))
			node.mouse_exited.connect(_on_any_node_mouse_exited.bind(upgrade_key))
			
	rotating_item_node.pressed.connect(_on_rotating_item_pressed)
	rotating_item_node.mouse_entered.connect(_on_any_node_mouse_entered.bind("rotating_item"))
	rotating_item_node.mouse_exited.connect(_on_any_node_mouse_exited.bind("rotating_item"))
	description_delay_timer.timeout.connect(_on_description_delay_timer_timeout)
			
			
	# Connect the other buttons
	continue_button.pressed.connect(_on_continue_button_pressed)

	skip_garden_button.pressed.connect(_on_skip_garden_button_pressed)


# This is the master function that main.gd will call.
func open_shop():
	rotating_item_purchased_this_visit = false
	pick_new_rotating_item()
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
	var skip_button = $AnimationContainer/MainContainer/VBoxContainer/RouletteContainer/RotatingItemRow/SkipGardenButton
	skip_button.visible = (GameManager.fast_track_unlocked and GameManager.current_garden < 8)

# --- UPDATE FUNCTIONS ---

func update_pulp_label():
	current_pulp_label.text = "Pulp: %smg" % GameManager.pulp
	current_juice_label.text = "Juice: %smL" % GameManager.juice


# This is our new, reusable helper function. It can update ANY pillar button.
func _update_pillar_node(upgrade_key: String):
	var node = pillar_nodes.get(upgrade_key)
	if not is_instance_valid(node): return

	var rules = GameManager.meta_upgrade_data[upgrade_key]
	var current_level = main_game.get_meta_upgrade_level(upgrade_key)
	
	# Pass all the data to the node's own update function.
	node.update_display(upgrade_key, current_level, rules.max_level, true, Color("a3d5ff"), Color.GOLD, "Frosty")





func pick_new_rotating_item():
	# This is where the magic happens baby
	
	var potential_pool = []
	var roll = randf()
	if roll < 0.05:
		potential_pool = GameManager.legendary_items
	elif roll < 0.30:
		potential_pool = GameManager.rare_items
	else:
		potential_pool = GameManager.common_items
		
	# 2. Now, create a final, "valid" pool by filtering out invalid items.
	var valid_pool = []
	for item_data in potential_pool:
		var item_id = item_data["id"]
		var is_valid = true
		
		# --- Filter out seen legendaries ---
		if item_data.get("rarity") == "Legendary" and item_id in GameManager.legendary_items_seen_this_run:
			is_valid = false
			
		# --- Filter out items for maxed-out upgrades ---
		# We add a new key, "targets_upgrade", to our item data for this.
		if item_data.has("targets_upgrade"):
			var target_key = item_data["targets_upgrade"]
			var target_rules = main_game.get_upgrade_rules(target_key)
			var target_level = main_game.get_upgrade_level_from_key(target_key)
			if target_level >= target_rules.max_level:
				is_valid = false
		
		#------------Handicap Item------------
		if item_id == "handicap" and GameManager.max_ability_slots >= 10:
			is_valid = false
		
		
		if is_valid:
			valid_pool.append(item_data)
			
	# 3. If the valid pool is empty, pick from the common items as a fallback.
	if valid_pool.is_empty():
		# To be extra safe, check the common pool as well.
		for item_data in GameManager.common_items:
		 	# Add a check here too if any common items can become invalid.
			valid_pool.append(item_data)
		# If it's still empty, we have a bigger problem! But this is a good safeguard.
		if valid_pool.is_empty():
			print_debug("ERROR: No valid items found in any loot pool!")
			return
		
	# 4. Pick a random item from the final, valid pool.
	current_rotating_item = valid_pool.pick_random()
	
	# Add this to our "seen" list so it doesn't appear again.
	if current_rotating_item.get("rarity") == "Legendary":
		GameManager.legendary_items_seen_this_run.append(current_rotating_item.id)
		
	# Finally, update the UI.
	update_rotating_item_display()



func _on_rotating_item_mouse_entered():
	if not rotating_item_purchased_this_visit and not current_rotating_item.is_empty():
		# We call the same show_info function, but pass it the data from our rotating item.
		description_panel.show_info(
			current_rotating_item.name,
			current_rotating_item.description,
			current_rotating_item.cost
		)




func update_rotating_item_display():
	# This is our new, dedicated update function for the rotating item.
	var node = rotating_item_node	
	# If an item has been purchased this visit, lock the button.
	if rotating_item_purchased_this_visit:
		node.disabled = true
		node.modulate = Color.GRAY
		# Since we're not calling update_display, let's clear the text
		node.text = "Purchased!"
		return
	if current_rotating_item.is_empty():
		return
		
	var rules = current_rotating_item
	
	# --- THIS IS THE NEW RARITY LOGIC ---
	var rarity_color = Color.GRAY # Default to Common
	if rules.rarity == "Rare":
		rarity_color = Color.DODGER_BLUE
	elif rules.rarity == "Legendary":
		rarity_color = Color.GOLD
		
	# We now pass the correct rarity color to the node.
	node.update_display(rules.id, 0, 1, true, rarity_color, rarity_color, "Frosty")
	node.disabled = (GameManager.pulp < rules.cost)

# --- SIGNAL HANDLERS ---

func _on_continue_button_pressed():
	# Hide the shop and tell the main game to proceed.
	emit_signal("continue_to_next_garden")

func _on_rotating_item_pressed():
	if rotating_item_purchased_this_visit: return
	if GameManager.pulp >= current_rotating_item["cost"]:
		# Subtract the cost
		GameManager.pulp -= current_rotating_item["cost"]
		
		# Apply the buff/debuff
		# We would have a big match statement here in GameManager to apply the effect.
		GameManager.apply_meta_upgrade(current_rotating_item["id"])
		
		rotating_item_purchased_this_visit = true
		# Update the shop display to reflect the new Pulp total
		update_all_displays()
		
		# Disable this button since you can only buy one
		rotating_item_node.disabled = true


func _on_pillar_node_pressed(upgrade_key: String):
	# It gets all the info it needs from the helper function.
	var current_level = main_game.get_meta_upgrade_level(upgrade_key)
	var rules = GameManager.meta_upgrade_data[upgrade_key]

	if current_level < rules["max_level"]:
		var cost_index = current_level
		if upgrade_key == "Synapse Slot":
			cost_index = GameManager.max_ability_slots

		var cost = rules["costs"][cost_index]
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
	if hovered_item_key == "": return

	var rules: Dictionary
	var cost: int
	var display_name: String
	var item_id_for_icon: String # The key we pass to the description panel
	var current_level: int
	# --- THIS IS THE FIX ---
	# We now handle the two different item types separately.
	
	if hovered_item_key == "rotating_item":
		# It's the rotating item. Get its data from current_rotating_item.
		rules = current_rotating_item
		if rules.is_empty(): return
		
		display_name = rules.get("name", "Unknown Item")
		cost = rules.get("cost", 0)
		# We get the item's specific ID to find the correct icon.
		item_id_for_icon = rules.get("id", "")
		current_level = 0 #Double check this line ----------------
	else:
		# It's a pillar upgrade. Get its data from meta_upgrade_data.
		rules = GameManager.meta_upgrade_data.get(hovered_item_key)
		if rules.is_empty(): return
		
		display_name = rules.get("display_name", hovered_item_key)
		# For pillars, the key IS the ID for the icon.
		item_id_for_icon = hovered_item_key
		
		current_level = main_game.get_meta_upgrade_level(hovered_item_key)
		cost = rules.costs[current_level] if current_level < rules.costs.size() else 999
		# --- THIS IS THE DYNAMIC POSITIONING LOGIC ---
		var viewport_size = get_viewport().get_visible_rect().size
		var mouse_position = get_viewport().get_mouse_position()
		
		# We position the panel on the opposite side of the screen from the mouse.
		if mouse_position.x < viewport_size.x / 2.0:
			description_panel.position.x = (viewport_size.x / 2.0) + 20
		else:
			description_panel.position.x = (viewport_size.x / 2.0) - description_panel.size.x - 20
			
		# We also vertically center it relative to the mouse.
		description_panel.position.y = mouse_position.y - (description_panel.size.y / 2.0)
		description_panel.position.y = clamp(description_panel.position.y, 20, viewport_size.y - description_panel.size.y)
	# Now that we have the correct data, we can safely show the info.
	# We pass the specific item_id_for_icon to the show_info function.
	description_panel.show_info(
		item_id_for_icon,
		display_name,
		rules.description,
		cost,
		current_level,
		rules.max_level)
