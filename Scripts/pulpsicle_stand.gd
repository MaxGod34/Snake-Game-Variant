extends CanvasLayer

# This signal tells main.gd that the player is ready to move on.
signal continue_to_next_garden

# --- NODE REFERENCES ---
# Get references to all the UI elements we need to update.
@onready var current_pulp_label = $AnimationContainer/MainContainer/VBoxContainer/CurrentPulpLabel
@onready var synapse_button = $AnimationContainer/MainContainer/VBoxContainer/SynapseRow/Synapse_Button
@onready var chroma_scales_button = $AnimationContainer/MainContainer/VBoxContainer/PillarsContainer/Pillar1/Pillar1_Button
@onready var serpents_coffer_button = $AnimationContainer/MainContainer/VBoxContainer/PillarsContainer/Pillar2/Pillar2_Button
@onready var geode_compass_button = $AnimationContainer/MainContainer/VBoxContainer/PillarsContainer/Pillar3/Pillar3_Button
@onready var four_leaf_button = $AnimationContainer/MainContainer/VBoxContainer/PillarsContainer/Pillar4/Pillar4_Button
@onready var rand_item_button = $AnimationContainer/MainContainer/VBoxContainer/RouletteContainer/RotatingItemRow/RotatingItemButton
@onready var rand_item_description = $AnimationContainer/MainContainer/VBoxContainer/RouletteContainer/RotatingItemRow/RotatingItemDescription
@onready var continue_button = $AnimationContainer/MainContainer/VBoxContainer/ContinueButton
@onready var animation_container = $AnimationContainer
@onready var description_label = $AnimationContainer/MainContainer/DescriptionLabel

# This dictionary will store a reference to every single pillar button.
var pillar_buttons: Dictionary = {}

var current_rotating_item: Dictionary = {}

func _ready() -> void:
	_connect_all_signals()
	
	# Also, build our dictionary of pillar buttons.
	pillar_buttons = {
		"Synapse Slot": synapse_button,
		"Serpent's Coffer": serpents_coffer_button,
		"Geode Compass": geode_compass_button,
		"Four Leaf Clover": four_leaf_button,
		"Chroma Scales": chroma_scales_button
	}

func _connect_all_signals():
	# Loop through our button dictionary to connect everything cleanly.
	for upgrade_key in pillar_buttons:
		var button = pillar_buttons[upgrade_key]
		if is_instance_valid(button):
			button.pressed.connect(_on_pillar_button_pressed.bind(upgrade_key))
			button.mouse_entered.connect(_on_pillar_mouse_entered.bind(upgrade_key))
			button.mouse_exited.connect(_on_pillar_mouse_exited)
			
	# Connect the other buttons
	continue_button.pressed.connect(_on_continue_button_pressed)
	rand_item_button.pressed.connect(_on_rotating_item_button_pressed)


# This is the master function that main.gd will call.
func open_shop():
	animation_container.visible = false
	
	
	update_all_displays()
	self.visible = true
	

# This function refreshes every piece of information in the shop.
func update_all_displays():
	update_pulp_label()
	for upgrade_key in pillar_buttons:
		_update_pillar_button(upgrade_key)
	pick_and_display_rotating_item()

# --- UPDATE FUNCTIONS ---

func update_pulp_label():
	current_pulp_label.text = "Pulp: %smg" % GameManager.pulp


# This is our new, reusable helper function. It can update ANY pillar button.
func _update_pillar_button(upgrade_key: String):
	var button_node = pillar_buttons.get(upgrade_key)
	if not is_instance_valid(button_node): return

	var rules = GameManager.meta_upgrade_data[upgrade_key]
	var current_level = 0
	var cost_index = 0
	
	# Get the current level for the specific upgrade.
	match upgrade_key:
		"Synapse Slot":
			current_level = GameManager.max_ability_slots
			cost_index = GameManager.max_ability_slots
		"Serpent's Coffer":
			current_level = GameManager.serpents_coffer_level
			cost_index = current_level
		"Geode Compass":
			current_level = GameManager.geode_compass_level
			cost_index = current_level
		"Four Leaf Clover":
			current_level = GameManager.four_leaf_clover_level
			cost_index = current_level
		"Chroma Scales":
			current_level = GameManager.chroma_scales_level
			cost_index = current_level

	# Update the button's text and state.
	if current_level >= rules["max_level"]:
		button_node.text = upgrade_key + "\n(MAX)"
		button_node.disabled = true
	else:
		var cost = rules["costs"][cost_index]
		button_node.text = upgrade_key + "\n(%s Pulp)" % cost
		button_node.disabled = (GameManager.pulp < cost)
		
	# Update the Indicator Blocks.
	var indicator_container = button_node.get_parent().get_node("IndicatorContainer")
	for i in range(1, indicator_container.get_child_count() + 1):
		var block = indicator_container.get_node("Block" + str(i))
		if block:
			block.visible = (i <= rules["max_level"])
			if block.visible:
				block.color = Color.GOLD if i <= current_level else Color.GRAY

func pick_and_display_rotating_item():
	# This is where the magic happens!
	
	# 1. First, build the loot table based on rarity.
	var loot_table = []
	var roll = randf() # A random number between 0.0 and 1.0
	
	if roll < 0.05: # 5% chance for a Legendary item
		loot_table = GameManager.legendary_items 
	elif roll < 0.30: # 25% chance for a Rare/Cursed item
		loot_table = GameManager.rare_items
	else: # 70% chance for a Common item
		loot_table = GameManager.common_items
		
	# 2. Pick a random item from the chosen table.
	current_rotating_item = loot_table.pick_random()
	
	# 3. Display the item's info on the UI.
	var button = $AnimationContainer/MainContainer/VBoxContainer/RouletteContainer/RotatingItemRow/RotatingItemButton
	var description = $AnimationContainer/MainContainer/VBoxContainer/RouletteContainer/RotatingItemRow/RotatingItemDescription
	
	button.text = "%s (%smg)" % [current_rotating_item["name"], current_rotating_item["cost"]]
	description.text = current_rotating_item["description"]
	
	# Disable the button if we can't afford it.
	if GameManager.pulp < current_rotating_item["cost"]:
		button.disabled = true
	else:
		button.disabled = false

# --- SIGNAL HANDLERS ---

func _on_continue_button_pressed():
	# Hide the shop and tell the main game to proceed.
	emit_signal("continue_to_next_garden")

func _on_rotating_item_button_pressed():
	if GameManager.pulp >= current_rotating_item["cost"]:
		# Subtract the cost
		GameManager.pulp -= current_rotating_item["cost"]
		
		# Apply the buff/debuff
		# We would have a big match statement here in GameManager to apply the effect.
		GameManager.apply_meta_upgrade(current_rotating_item["id"])
		
		# Update the shop display to reflect the new Pulp total
		update_all_displays()
		
		# Disable this button since you can only buy one
		$AnimationContainer/MainContainer/VBoxContainer/RouletteContainer/RotatingItemRow/RotatingItemButton.disabled = true


func _on_pillar_button_pressed(upgrade_key: String):
	var rules = GameManager.meta_upgrade_data[upgrade_key]
	
	var current_level = 0
	
	match upgrade_key:
		"Synapse Slot": current_level = GameManager.max_ability_slots
		"Serpent's Coffer": current_level = GameManager.serpents_coffer_level
		"Geode Compass": current_level = GameManager.geode_compass_level
		"Four Leaf Clover": current_level = GameManager.four_leaf_clover_level
		"Chroma Scales": current_level = GameManager.chroma_scales_level

	if current_level < rules["max_level"]:
		var cost = rules["costs"][current_level]
		if GameManager.pulp >= cost:
			GameManager.pulp -= cost
			
			# Apply the correct upgrade
			match upgrade_key:
				"Synapse Slot": GameManager.max_ability_slots += 1
				"Serpent's Coffer": GameManager.serpents_coffer_level += 1
				"Geode Compass": GameManager.geode_compass_level += 1
				"Four Leaf Clover": GameManager.four_leaf_clover_level += 1
				"Chroma Scales": GameManager.chroma_scales_level += 1

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


func _on_pillar_mouse_entered(upgrade_key: String):
	var rules = GameManager.meta_upgrade_data[upgrade_key]
	description_label.text = rules["description"]
	description_label.visible = true

func _on_pillar_mouse_exited():
	description_label.visible = false
