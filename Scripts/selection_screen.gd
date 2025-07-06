extends Control

#--- DEBUGGING ---
@onready var debug_panel = $DebugPanel


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
@onready var cursed_pact_1_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer2/CursedPact1Node
@onready var cursed_pact_2_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer2/CursedPact2Node
@onready var cursed_pact_3_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer2/CursedPact3Node
@onready var cursed_pact_4_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer4/CursedPact4Node
@onready var cursed_pact_5_node = $MarginContainer/MainLayout/DifficultyPactPanel/VBoxContainer/HBoxContainer4/CursedPact5Node

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
	#---debug panel---
	debug_panel.get_node("VBoxContainer/UnlockNextPactButton").pressed.connect(_on_debug_unlock_next_pact)
	debug_panel.get_node("VBoxContainer/CompleteSealsButton").pressed.connect(_on_debug_complete_seals)
	debug_panel.get_node("VBoxContainer/UnlockNextCursedPactButton").pressed.connect(_on_debug_unlock_next_cursed_pact)
	debug_panel.get_node("VBoxContainer/ResetSaveButton").pressed.connect(_on_debug_reset_save)
	# We'll also want to update the display to its initial state.
	update_all_displays()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_F1"):
		debug_panel.visible = not debug_panel.visible


func _build_difficulty_node_dictionary():
	difficulty_nodes = {
		"Pact 1": pact_1_node, "Pact 2": pact_2_node, "Pact 3": pact_3_node,
		"Pact 4": pact_4_node, "Pact 5": pact_5_node,
		"Trial of the Harvest": seal_harvest_node,
		"Trial of the Core": seal_core_node,
		"Trial of the Redline": seal_redline_node,
		"Cursed Pact 1": cursed_pact_1_node, "Cursed Pact 2": cursed_pact_2_node,
		"Cursed Pact 3": cursed_pact_3_node, "Cursed Pact 4": cursed_pact_4_node,
		"Cursed Pact 5": cursed_pact_5_node
	}
	
func _connect_all_difficulty_nodes():
	for pact_key in difficulty_nodes:
		var node = difficulty_nodes[pact_key]
		if is_instance_valid(node):
			node.pressed.connect(_on_difficulty_node_pressed.bind(pact_key))
			print("%s node connected - selection_screen.gd" % node)

func _build_class_node_dictionary():
	# This powerful loop finds every single class node in the scene.
	# It assumes nodes are named like "MulliganNode", "GlutsNode", etc.
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
	for class_key in class_nodes:
		var node = class_nodes[class_key]
		var class_data = GameManager.class_data[class_key]
		var is_unlocked = class_key in SaveManager.save_data.unlocked_classes

		# We now get the icon path directly from the data.
		var icon_path = class_data.get("icon_path", "")
		if ResourceLoader.exists(icon_path):
			node.icon = load(icon_path)
		# We can use our UpgradeNode's update function for this!
		# We'll use a special theme color to show selection.
		var stylebox = StyleBoxFlat.new()
		stylebox.set_border_width_all(4)
		stylebox.bg_color = Color(0, 0, 0, 0)
		if class_key == selected_class_key:
			stylebox.border_color = Color.DEEP_SKY_BLUE
		else:
			stylebox.border_color = Color.TRANSPARENT # No border if not selected
		node.add_theme_stylebox_override("normal", stylebox)
		
		# Dim the icon if it's locked
		node.disabled = not is_unlocked
		if not is_unlocked:
			node.modulate = Color.DARK_GRAY
		else:
			node.modulate = Color.WHITE

func _on_class_node_pressed(class_key: String):
	print("Player selected class: ", class_key)
	# Set the new selected class.
	selected_class_key = class_key
	selected_difficulty_key = ""
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
			class_name_label.text = class_data.get("display_name", "Unknown Class")
			class_description_label.text = class_data.get("description", "")
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
			difficulty_name_label.text = diff_data.get("display_name", "Unknown Pact")
			difficulty_description_label.text = diff_data.get("description", "")
	
func update_difficulty_pacts():
	var progress = { "highest_pact_completed": -1, "seals_broken": [], "highest_cursed_pact_completed": -1 }
	if selected_class_key != "":
		progress = SaveManager.get_progress_for_class(selected_class_key)
		# Loop through and disable all pact nodes here.

	for pact_key in difficulty_nodes:
		var node = difficulty_nodes[pact_key]
		var rules = GameManager.difficulty_data.get(pact_key)
		if not rules: continue

		var is_locked = true
		var is_completed = false
		
		# --- This logic now correctly reads from the PER-CLASS progress data ---
		if pact_key.begins_with("Pact"):
			var pact_number = int(pact_key.split(" ")[1])
			if pact_number <= progress.highest_pact_completed + 1: is_locked = false
			if pact_number <= progress.highest_pact_completed: is_completed = true
		elif pact_key.begins_with("Trial"):
			if progress.highest_pact_completed >= 5: is_locked = false
			if pact_key in progress.seals_broken: is_completed = true
		elif pact_key.begins_with("Cursed"):
			if progress.seals_broken.size() == 3:
				var cursed_pact_number = int(pact_key.split(" ")[2])
				if cursed_pact_number <= progress.highest_cursed_pact_completed + 1: is_locked = false
				if cursed_pact_number <= progress.highest_cursed_pact_completed: is_completed = true
		
		var icon_path = rules.get("icon_path", "")
		if ResourceLoader.exists(icon_path):
			node.icon = load(icon_path)
		# --- Apply Visuals ---
		var stylebox = StyleBoxFlat.new()
		stylebox.set_border_width_all(4)
		stylebox.bg_color = Color(0,0,0,0)
		
		if pact_key == selected_difficulty_key:
			stylebox.border_color = Color.DEEP_SKY_BLUE
		elif is_completed:
			stylebox.border_color = Color.GOLD # A clear "completed" color
		else:
			stylebox.border_color = Color.TRANSPARENT
			
		node.add_theme_stylebox_override("normal", stylebox)
		
		node.disabled = is_locked
		node.modulate = Color.WHITE if not is_locked else Color.DARK_GRAY
	
func _on_difficulty_node_pressed(pact_key: String):
	print("Player selected difficulty: ", pact_key)
	selected_difficulty_key = pact_key
	update_all_displays()


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

func _on_debug_unlock_next_pact():
	if selected_class_key == "": return
	# Get the progress for the SELECTED class.
	var progress = SaveManager.get_progress_for_class(selected_class_key)
	progress.highest_pact_completed += 1
	SaveManager.save_game()
	update_all_displays()

func _on_debug_complete_seals():
	if selected_class_key == "": return
	var progress = SaveManager.get_progress_for_class(selected_class_key)
	progress.seals_broken = ["Trial of the Harvest", "Trial of the Core", "Trial of the Redline"]
	SaveManager.save_game()
	update_all_displays()

func _on_debug_unlock_next_cursed_pact():
	if selected_class_key == "": return
	var progress = SaveManager.get_progress_for_class(selected_class_key)
	progress.highest_cursed_pact_completed += 1
	SaveManager.save_game()
	update_all_displays()

func _on_debug_reset_save():
	# We'll need to create this new helper function in our SaveManager.
	SaveManager.reset_save_data()
	# After resetting, we reload the entire scene to get a fresh start.
	get_tree().reload_current_scene()
