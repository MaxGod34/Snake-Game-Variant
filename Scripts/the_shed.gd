extends Control

# --- NODE REFERENCES ---
# We get direct references to our main containers and buttons.
# Please double-check that these paths are a perfect match for your scene tree.
@onready var category_list_vbox = $MarginContainer/VBoxContainer/ShedTabs/Customization/CategoryListPanel/VBoxContainer
@onready var item_grid = $MarginContainer/VBoxContainer/ShedTabs/Customization/SelectionPanel/ScrollContainer/VBoxContainer/ItemGrid
@onready var back_button = $MarginContainer/VBoxContainer/BottomHUDRow/BackButton
@onready var equipped_color_node = $MarginContainer/VBoxContainer/ShedTabs/Customization/SelectionPanel/ScrollContainer/VBoxContainer/EquippedCosmeticsRow/EquippedColor
@onready var equipped_pattern_node = $MarginContainer/VBoxContainer/ShedTabs/Customization/SelectionPanel/ScrollContainer/VBoxContainer/EquippedCosmeticsRow/EquippedPattern
@onready var equipped_background_node = $MarginContainer/VBoxContainer/ShedTabs/Customization/SelectionPanel/ScrollContainer/VBoxContainer/EquippedCosmeticsRow/EquippedBackground
@onready var equipped_avatar_node = $MarginContainer/VBoxContainer/ShedTabs/Customization/SelectionPanel/ScrollContainer/VBoxContainer/EquippedCosmeticsRow/EquippedAvatar
@onready var equipped_frame_node = $MarginContainer/VBoxContainer/ShedTabs/Customization/SelectionPanel/ScrollContainer/VBoxContainer/EquippedCosmeticsRow/EquippedFrame

# This variable will store which category is currently being displayed.
var current_category: String = "Colors" # Default to the first category

func _ready():
	# When the screen is ready, we connect all the signals.
	_connect_all_signals()
	update_customization_tab()

func _connect_all_signals():
	# Connect the back button to go back to the main menu.
	back_button.pressed.connect(func(): SceneTransition.transition_to("res://Scenes/Menus/main_menu.tscn"))
	
	# Loop through all the category buttons and connect them.
	for button in category_list_vbox.get_children():
		if button is Button:
			# We can get the category name from the button's text.
			# Assumes your buttons are named "Pigments", "Patterns", etc.
			var category_name = button.text
			button.pressed.connect(_on_category_button_pressed.bind(category_name))

func populate_item_grid():
	# 1. First, clear out any old items from the grid.
	for child in item_grid.get_children():
		child.queue_free()
		
	# 2. Get the list of items the player has unlocked for the current category.
	var unlocked_items = SaveManager.save_data.unlocked_cosmetics.get(current_category.to_lower(), [])
	
	# 3. Get the full data for this category from GameManager.
	var all_item_data = GameManager.cosmetic_data.get(current_category, {})
	
	# 4. Loop through ALL available items and create a node for each one.
	for item_key in all_item_data:
		var node = preload("res://Scenes/UI/upgrade_node.tscn").instantiate()
		var rules = all_item_data[item_key]
		
		var is_unlocked = item_key in unlocked_items
		var is_equipped = (SaveManager.save_data.equipped_cosmetics.get(current_category.to_lower()) == item_key)
		node.text = item_key
		# --- Set the Icon and Color ---
		if rules.has("hex_code"):
			node.icon = preload("res://Assets/Icons/white_swatch.png")
			node.modulate = Color(rules.hex_code)
		else:
			var icon_path = rules.get("icon_path", "")
			if ResourceLoader.exists(icon_path):
				node.icon = load(icon_path)
			node.modulate = Color.WHITE

		# --- Set the Border Style ---
		var stylebox = StyleBoxFlat.new()
		stylebox.set_border_width_all(4)
		stylebox.bg_color = Color(0,0,0,0.3)
		stylebox.border_color = Color.GOLD if is_equipped else Color.TRANSPARENT
		node.add_theme_stylebox_override("normal", stylebox)
		node.add_theme_stylebox_override("hover", stylebox)
		# --- Set the Disabled State ---
		node.disabled = not is_unlocked
		if not is_unlocked:
			node.modulate = Color(node.modulate.r, node.modulate.g, node.modulate.b, 0.2)
		
		# We only connect the signal if the item is unlocked and can be equipped.
		if is_unlocked:
			node.pressed.connect(_on_equip_item_pressed.bind(current_category, item_key))
		
		
		
		node.update_minimum_size()
		item_grid.add_child(node)
		node.update_minimum_size()

		
func _on_category_button_pressed(category_name: String):
	# When a new category is selected, we update our state and repopulate the grid.
	current_category = category_name
	populate_item_grid()

func _on_equip_item_pressed(category: String, item_key: String):
	# This is where we update the player's loadout in the save file.
	print("Equipping %s for category %s" % [item_key, category])
	
	# We use .to_lower() to match the keys in our save_data ("colors", "patterns", etc.)
	var category_save_key = category.to_lower()
	
	# Update the equipped item in our save data.
	SaveManager.save_data.equipped_cosmetics[category_save_key] = item_key
	
	# Save the change to the file to make it permanent.
	SaveManager.save_game()
	

	update_customization_tab()
	
	
func update_customization_tab():
	# This function now updates BOTH parts of our UI.
	update_equipped_display()
	populate_item_grid()

func update_equipped_display():
	# This function gets the player's current loadout and updates the display nodes.
	var loadout = SaveManager.save_data.equipped_cosmetics
	
	# We'll create a helper to avoid repeating code.
	_update_single_equipped_node(equipped_color_node, "Colors", loadout.get("colors", "Default"))
	_update_single_equipped_node(equipped_pattern_node, "Patterns", loadout.get("patterns", "Default"))
	_update_single_equipped_node(equipped_background_node, "Backgrounds", loadout.get("backgrounds", "Default"))
	_update_single_equipped_node(equipped_avatar_node, "Avatars", loadout.get("avatars", "Default"))
	_update_single_equipped_node(equipped_frame_node, "Frames", loadout.get("frames", "Default"))

# This is our new, smart helper for updating any of the equipped nodes.
func _update_single_equipped_node(node: Button, category_key: String, item_key: String):
	# Get the rules for the equipped item.
	var rules = GameManager.cosmetic_data[category_key].get(item_key)
	if not rules:
		node.icon = null # Clear the icon if no item is equipped or found
		return
		
	# --- Set the Icon and Color ---
	if rules.has("hex_code"):
		# For colors, we set the icon to a white swatch and modulate the button itself.
		node.icon = preload("res://Assets/Icons/white_swatch.png")
		node.modulate = Color(rules.hex_code)
	else:
		# For other cosmetics, we load the icon from its path.
		var icon_path = rules.get("icon_path", "")
		if ResourceLoader.exists(icon_path):
			node.icon = load(icon_path)
		# Make sure to reset the modulate for non-color items!
		node.modulate = Color.WHITE
	node.text = category_key + "\n" + item_key
	node.update_minimum_size()
