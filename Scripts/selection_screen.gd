extends Control

# --- NODE REFERENCES ---
# We'll get references to our main panels and the "Begin Run" button.
@onready var loadout_display_panel = $MarginContainer/MainLayout/LoadoutDisplayPanel
@onready var begin_run_button = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/BeginRunButton
@onready var class_artwork = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/ClassArtwork
@onready var class_name_label = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/ClassNameLabel
@onready var class_description_label = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/ClassDescriptionLabel
@onready var difficulty_name_label = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/DifficultyNameLabel
@onready var difficulty_description_label = $MarginContainer/MainLayout/LoadoutDisplayPanel/VBoxContainer/DifficultyDescriptionLabel





# This dictionary will store a reference to every single class node.
var class_nodes: Dictionary = {}

var difficulty_nodes: Dictionary = {}
@onready var pact_1_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/BasePactRow/Pact1Node
@onready var pact_2_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/BasePactRow/Pact2Node
@onready var pact_3_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/BasePactRow/Pact3Node
@onready var pact_4_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer3/Pact4Node
@onready var pact_5_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer3/Pact5Node
@onready var seal_harvest_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer/TrialoftheHarvestNode
@onready var seal_core_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer/TrialoftheCoreNode
@onready var seal_redline_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer/TrialoftheRedlineNode
@onready var cursed_pact_1_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer2/CursedPactINode
@onready var cursed_pact_2_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer2/CursedPactIINode
@onready var cursed_pact_3_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer2/CursedPactIIINode
@onready var cursed_pact_4_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer4/CursedPactIVNode
@onready var cursed_pact_5_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer4/CursedPactVNode

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
	# We'll also want to update the display to its initial state.
	update_all_displays()


func _build_difficulty_node_dictionary():
	difficulty_nodes = {
		"Pact 1": pact_1_node, "Pact 2": pact_2_node, "Pact 3": pact_3_node,
		"Pact 4": pact_4_node, "Pact 5": pact_5_node,
		"Trial of the Harvest": seal_harvest_node,
		"Trial of the Core": seal_core_node,
		"Trial of the Redline": seal_redline_node,
		"Cursed Pact I": cursed_pact_1_node, "Cursed Pact II": cursed_pact_2_node,
		"Cursed Pact III": cursed_pact_3_node, "Cursed Pact IV": cursed_pact_4_node,
		"Cursed Pact V": cursed_pact_5_node
	}
	
func _connect_all_difficulty_nodes():
	for pact_key in difficulty_nodes:
		var node = difficulty_nodes[pact_key]
		if is_instance_valid(node):
			node.pressed.connect(_on_difficulty_node_pressed.bind(pact_key))
			print("%s node connected - selection_screen.gd" % node)

func _build_class_node_dictionary():
	# This powerful loop finds every single class node in the scene.
	# It assumes your nodes are named like "MulliganNode", "GlutsNode", etc.
	var grid = $MarginContainer/MainLayout/ClassRosterPanel/ClassGrid
	for class_key in GameManager.class_data.keys():
		# We now use the robust to_pascal_case() function to build the node name.
		# This correctly handles all multi-word names.
		var node_name = class_key.to_pascal_case() + "Node"
		
		# We then use find_child to search for a node with that exact name.
		var node = grid.find_child(node_name, false) # Set recursive to false for performance
		
		if is_instance_valid(node):
			class_nodes[class_key] = node
		else:
			# This warning is very helpful for debugging any naming mismatches!
			print_debug("Warning: Could not find class node named: ", node_name)

func _connect_all_class_nodes():
	# Now, we loop through our new dictionary and connect the signals.
	for class_key in class_nodes:
		var node = class_nodes[class_key]
		if is_instance_valid(node):
			# We connect the button's built-in "pressed" signal.
			# We use .bind() to tell our handler function WHICH class was clicked.
			node.pressed.connect(_on_class_node_pressed.bind(class_key))


func update_all_displays():
	update_class_roster()
	update_difficulty_pacts()
	update_loadout_display()
	begin_run_button.disabled = (selected_class_key == "" or selected_difficulty_key == "")

func update_class_roster():
	# This loop updates the visuals for every single class icon.
	for class_key in class_nodes:
		#var node = class_nodes[class_key]
		# We can create a helper in GameManager to get class data later.
		# For now, we'll just set the icon.
		# node.icon = preload("res://path/to/" + class_key + "_icon.png")
		
		# Add a border if this class is the currently selected one.
		if class_key == selected_class_key:
			# We can create a StyleBox to add a golden border here.
			pass
		else:
			# Remove the border if it's not selected.
			pass

func _on_class_node_pressed(class_key: String):
	print("Player selected class: ", class_key)
	# Set the new selected class.
	selected_class_key = class_key
	# And immediately update all the displays to reflect the change.
	update_all_displays()

func update_loadout_display():
	# First, check if a class has actually been selected.
	if selected_class_key == "":
		# If not, show a default "prompt" state.
		class_name_label.text = "Select a Class"
		class_description_label.text = "Choose your path for this run."
		class_artwork.texture = null # Or a default "question mark" icon
		return
	else:
		# If a class IS selected, get its data.
		var class_data = GameManager.class_data.get(selected_class_key)
		if class_data:
			class_name_label.text = class_data.get("name", "Unknown Class")
			class_description_label.text = class_data.get("description", "")
		
		# Update the UI elements with the data.
		class_name_label.text = class_data.name
		class_description_label.text = class_data.description
		
		var diff_data = GameManager.difficulty_data.get(selected_difficulty_key)
			# Update a new label in your LoadoutDisplayPanel with this info.
		if diff_data:
			difficulty_name_label.text = diff_data.get("name", "Unknown Pact")
			difficulty_description_label.text = diff_data.get("description", "")
		
		# Load and set the artwork texture.
		if class_data.has("artwork_path") and ResourceLoader.exists(class_data.artwork_path):
			class_artwork.texture = load(class_data.artwork_path)
		else:
			class_artwork.texture = null # Fallback if no art is found
		
	# --- Update Difficulty Display ---
	if selected_difficulty_key == "":
		difficulty_name_label.text = "Select a Pact"
		difficulty_description_label.text = "Choose the challenge for this run."
	else:
		var diff_data = GameManager.difficulty_data.get(selected_difficulty_key)
		if diff_data:
			difficulty_name_label.text = diff_data.get("name", "Unknown Pact")
			difficulty_description_label.text = diff_data.get("description", "")
	
func update_difficulty_pacts():
	# This function updates the visuals for every difficulty icon.
	for pact_key in difficulty_nodes:
		var node = difficulty_nodes[pact_key]
		var rules = GameManager.difficulty_data.get(pact_key) # Use .get() for safety
		if not rules: continue # Skip if the key is somehow wrong

		var is_locked = true
		var is_completed = false
		
		# --- This is the new, robust logic for checking the state ---
		if pact_key.begins_with("Pact"):
			var pact_number = int(pact_key.split(" ")[1])
			if pact_number <= GameManager.highest_pact_completed + 1: is_locked = false
			if pact_number <= GameManager.highest_pact_completed: is_completed = true
		elif pact_key.begins_with("Trial"):
			if GameManager.highest_pact_completed >= 5: is_locked = false
			if pact_key in GameManager.seals_broken: is_completed = true
		elif pact_key.begins_with("Cursed"):
			if GameManager.seals_broken.size() == 3: is_locked = false
			var cursed_pact_number = roman_to_int(pact_key.split(" ")[2])
			if cursed_pact_number <= GameManager.highest_cursed_pact_completed + 1: is_locked = false
			if cursed_pact_number <= GameManager.highest_cursed_pact_completed: is_completed = true
		
		# --- Apply Visuals ---
		var theme_color = Color.DARK_SLATE_GRAY
		if is_completed: theme_color = Color.GOLD
		elif not is_locked: theme_color = Color.WHITE
		
		# We now call a new helper function to get the correct icon for each pact.
		node.icon = get_icon_for_pact(pact_key)
		
		var current_level_for_display = 1 if is_completed else 0
		
		# We can still use our UpgradeNode's update function for the border and disabled state.
		node.update_display(pact_key, current_level_for_display, 1, not is_locked, theme_color, theme_color)
		
		# Add a padlock icon if the node is locked
		var padlock = node.get_node_or_null("PadlockIcon")
		if is_instance_valid(padlock):
			padlock.visible = is_locked
	
func _on_difficulty_node_pressed(pact_key: String):
	print("Player selected difficulty: ", pact_key)
	selected_difficulty_key = pact_key
	update_all_displays()
func roman_to_int(roman: String) -> int:
	var roman_map = {"I": 1, "i": 1, "V": 5} # Can expand this later
	if roman in roman_map: return roman_map[roman]
	return 0

func _on_begin_run_button_pressed():
	# 1. First, do a safety check to make sure both a class and difficulty are selected.
	#    The button should already be disabled, but this is a good extra safeguard.
	if selected_class_key == "" or selected_difficulty_key == "":
		print("ERROR: Cannot start run without a class and difficulty selected.")
		return

	print("Starting run with Class: %s and Difficulty: %s" % [selected_class_key, selected_difficulty_key])
	
	# --- THIS IS THE MOST IMPORTANT PART ---
	# 2. We now set the chosen class and difficulty in our global GameManager.
	GameManager.chosen_class = selected_class_key
	GameManager.chosen_difficulty = selected_difficulty_key
	
	# 3. Now that the choices are locked in, we call the master start_game function.
	#    GameManager will handle the rest, including applying all the modifiers
	#    and transitioning to the main game scene.
	GameManager.start_game()

func get_icon_for_pact(pact_key: String) -> Texture2D:
	# This function returns the correct icon for each difficulty.
	# You will need to create these icons and update the paths!
	match pact_key:
		"Pact 1": return preload("res://Assets/PNGs/Dice/snake_dice_128_dice_1.png")
		"Pact 2": return preload("res://Assets/PNGs/Dice/snake_dice_128_dice_2.png")
		"Pact 3": return preload("res://Assets/PNGs/Dice/snake_dice_128_dice_3.png")
		"Pact 4": return preload("res://Assets/PNGs/Dice/snake_dice_128_dice_4.png")
		"Pact 5": return preload("res://Assets/PNGs/Dice/snake_dice_128_dice_5.png")
		"Trial of the Harvest": return preload("res://Assets/PNGs/UpgradeIcons/ESPortionsIcon.png")
		"Trial of the Core": return preload("res://Assets/PNGs/UpgradeIcons/SnakeClickerIcon.png")
		"Trial of the Redline": return preload("res://Assets/PNGs/UpgradeIcons/SugarRushIcon.png")
		"Cursed Pact I": return preload("res://Assets/PNGs/Dice/snake_dice_128_dice_1.png")
		"Cursed Pact II": return preload("res://Assets/PNGs/Dice/snake_dice_128_dice_2.png")
		"Cursed Pact III": return preload("res://Assets/PNGs/Dice/snake_dice_128_dice_3.png")
		"Cursed Pact IV": return preload("res://Assets/PNGs/Dice/snake_dice_128_dice_4.png")
		"Cursed Pact V": return preload("res://Assets/PNGs/Dice/snake_dice_128_dice_6.png")
		_: return null # Default case
