extends Control

# --- NODE REFERENCES ---
@onready var back_btn = $VBoxContainer/HBoxContainer/BackButton
@onready var class_unlock_grid = $"VBoxContainer/TabContainer/Class Acquisitions/ClassUnlockGrid"
@onready var debug_panel = $DebugPanel
@onready var description_panel = $DescriptionPanel
@onready var confirmation_modal = $ConfirmationModal
@onready var description_delay_timer = $DescriptionDelayTimer
@onready var fangs_label = $VBoxContainer/HBoxContainer/FangsLabel
@onready var color_grid = $"VBoxContainer/TabContainer/Chroma Lab/ChromaHbox/PigmentsVbox/ColorGrid"
@onready var pattern_grid = $"VBoxContainer/TabContainer/Chroma Lab/ChromaHbox/PatternsVbox/PatternGrid"
@onready var background_grid = $"VBoxContainer/TabContainer/Chroma Lab/ChromaHbox/EnvironmentsVbox/BackgroundGrid"
@onready var avatar_grid = $"VBoxContainer/TabContainer/Serpent's Sigil/SerpentsSigilHbox/AvatarVbox/AvatarGrid"
@onready var frame_grid = $"VBoxContainer/TabContainer/Serpent's Sigil/SerpentsSigilHbox/FrameVbox/FrameGrid"

var cosmetic_nodes: Dictionary = {}
var class_nodes: Dictionary = {}
var hovered_item_key: String = ""
var pending_purchase_key: String = ""
var cosmetic_key_to_type: Dictionary = {}

var current_category: String = "Colors"

func _ready():
	_build_node_dictionaries()
	_connect_all_signals()
	update_all_displays()

func _unhandled_input(event: InputEvent):
	# We'll use F2 as our secret debug key for this menu.
	if event.is_action_pressed("ui_F1"): # You may need to add "ui_f2" in your Input Map
		debug_panel.visible = not debug_panel.visible


func _build_node_dictionaries():
	# This function now just builds the class node dictionary.
	for class_key in GameManager.class_data:
		var node_name = class_key.to_pascal_case() + "Node"
		var node = class_unlock_grid.find_child(node_name, false)
		if is_instance_valid(node):
			class_nodes[class_key] = node

func _connect_all_signals():
	
	_setup_cosmetic_grid("Colors", color_grid)
	_setup_cosmetic_grid("Patterns", pattern_grid)
	_setup_cosmetic_grid("Backgrounds", background_grid)
	_setup_cosmetic_grid("Avatars", avatar_grid)
	_setup_cosmetic_grid("Frames", frame_grid)
	
	# This loop connects the signals from each class node.
	for class_key in class_nodes:
		var node = class_nodes[class_key]
		if is_instance_valid(node):
			node.pressed.connect(_on_class_unlock_pressed.bind(class_key))
			node.mouse_entered.connect(_on_any_node_mouse_entered.bind(class_key))
			node.mouse_exited.connect(_on_any_node_mouse_exited.bind(class_key))
			
	debug_panel.get_node("AddFangsButton").pressed.connect(_on_debug_add_fangs_pressed)
	description_delay_timer.timeout.connect(_on_description_delay_timer_timeout)
	confirmation_modal.confirmed.connect(_on_unlock_confirmed)
	confirmation_modal.cancelled.connect(func(): confirmation_modal.visible = false)
	back_btn.pressed.connect(func(): SceneTransition.transition_to("res://Scenes/Menus/main_menu.tscn"))

func _setup_cosmetic_grid(type_key: String, grid_node: GridContainer):
	if not is_instance_valid(grid_node):
		print_debug("ERROR: Could not find grid node for type: ", type_key)
		return
		
	var data_dict = GameManager.cosmetic_data[type_key]
	for item_key in data_dict:
		var node = preload("res://Scenes/UI/upgrade_node.tscn").instantiate()
		node.name = item_key.to_pascal_case() + "Node"
		cosmetic_nodes[item_key] = node
		cosmetic_key_to_type[item_key] = type_key
		grid_node.add_child(node)
		
		# Connect signals immediately after creating the node.
		node.pressed.connect(_on_cosmetic_node_pressed.bind(item_key))
		node.mouse_entered.connect(_on_any_node_mouse_entered.bind(item_key))
		node.mouse_exited.connect(_on_any_node_mouse_exited.bind(item_key))

# --- MASTER UPDATE FUNCTION ---
func update_all_displays():
	update_fang_label()
	update_class_unlock_grid()
	update_cosmetic_grids()

func update_fang_label():
	fangs_label.text = "Fangs: %s" % SaveManager.save_data.serpent_fangs

func update_class_unlock_grid():
	# This function updates the visuals for each class icon.
	for class_key in class_nodes:
		var node = class_nodes[class_key]
		var class_data = GameManager.class_data[class_key]
		var is_unlocked = class_key in SaveManager.save_data.unlocked_classes
		
		# We can use our UpgradeNode's update function for this!
		# We'll pass placeholder values for level, since these are one-time unlocks.
		node.update_display(class_key, 1 if is_unlocked else 0, 1, true, Color.WHITE, Color.GOLD)
		
		# Dim the icon and disable the button if the class is already unlocked.
		node.disabled = is_unlocked
		if is_unlocked:
			node.modulate = Color(0.5, 0.5, 0.5, 0.5)
			node.text = "UNLOCKED"
		else:
			# If it's locked, show the cost in Fangs.
			node.modulate = Color.WHITE
			node.text = "%s\n(%s Fangs)" % [class_data.display_name, class_data.fang_cost]

# --- SIGNAL HANDLER ---
func _on_class_unlock_pressed(class_key: String):
	pending_purchase_key = class_key
	var class_data = GameManager.class_data[class_key]
	var cost = class_data.fang_cost
	
	if SaveManager.save_data.serpent_fangs >= cost:
		var message = "Unlock %s for %s Fangs?" % [class_data.display_name, cost]
		confirmation_modal.show_confirmation(message)
	else:
		# We can add a "not enough funds" animation here later
		print("Not enough Fangs!")

func _on_unlock_confirmed():
	confirmation_modal.visible = false
	if pending_purchase_key == "": return

	# We now have a clear separation of logic.
	
	# 1. First, check if the pending item is a CLASS.
	if pending_purchase_key in GameManager.class_data:
		var class_key = pending_purchase_key
		var class_data = GameManager.class_data[class_key]
		var cost = class_data.fang_cost
		
		if SaveManager.save_data.serpent_fangs >= cost:
			SaveManager.save_data.serpent_fangs -= cost
			SaveManager.save_data.unlocked_classes.append(class_key)
			SaveManager.save_game()
			update_all_displays()
			
	# 2. If not, check if it's a COSMETIC.
	elif pending_purchase_key in cosmetic_key_to_type:
		var item_key = pending_purchase_key
		var item_type = cosmetic_key_to_type[item_key]
		var rules = GameManager.cosmetic_data[item_type][item_key]
		var cost = rules.fang_cost
		
		if SaveManager.save_data.serpent_fangs >= cost:
			SaveManager.save_data.serpent_fangs -= cost
			SaveManager.save_data.unlocked_cosmetics[item_type.to_lower()].append(item_key)
			SaveManager.save_game()
			update_all_displays()
			
	# 3. Reset the pending key.
	pending_purchase_key = ""


func _on_debug_add_fangs_pressed():
	# 1. We directly access our SaveManager's data and add the currency.
	SaveManager.save_data.serpent_fangs += 100
	
	# 2. Save the change to the file to make it permanent.
	SaveManager.save_game()
	
	# 3. And immediately update the UI to show the new total.
	update_all_displays()
	
	print("DEBUG: Added 100 Serpent Fangs.")

func _on_any_node_mouse_entered(item_key: String):
	hovered_item_key = item_key
	description_delay_timer.start()

# This function now stops the timer and hides the panel.
func _on_any_node_mouse_exited(item_key: String):
	# We only act if the mouse is exiting the currently hovered item.
	if hovered_item_key == item_key:
		description_delay_timer.stop()
		description_panel.visible = false
		hovered_item_key = ""

func _on_description_delay_timer_timeout():
	if hovered_item_key == "": return

	var rules: Dictionary
	var cost: int
	var current_level: int
	var currency_unit: String = "mL"
	
	# We now gather all the data needed by the new show_info function.
	
	if hovered_item_key in GameManager.class_data:
		rules = GameManager.class_data[hovered_item_key]
		cost = rules.get("fang_cost", 9999)
		current_level = 1 if hovered_item_key in SaveManager.save_data.unlocked_classes else 0
		
	else:
		var item_type = cosmetic_key_to_type.get(hovered_item_key)
		if item_type:
			rules = GameManager.cosmetic_data[item_type][hovered_item_key]
			cost = rules.get("fang_cost", 9999)
			if hovered_item_key in SaveManager.save_data.unlocked_cosmetics[item_type.to_lower()]:
				current_level = 1
	
	if rules.is_empty(): return

	# --- DYNAMIC POSITIONING LOGIC ---
	var viewport_size = get_viewport_rect().size
	var mouse_position = get_global_mouse_position()
	
	if mouse_position.x < viewport_size.x / 2.0:
		description_panel.position.x = mouse_position.x + 40
	else:
		description_panel.position.x = mouse_position.x - description_panel.size.x - 40
		
	description_panel.position.y = mouse_position.y - (description_panel.size.y / 2.0)
	description_panel.position.y = clamp(description_panel.position.y, 20, viewport_size.y - description_panel.size.y - 20)
	
	# Now that it's in the right place, show it with all the correct info.
	description_panel.show_info(rules, current_level, cost, currency_unit)



func update_cosmetic_grids():
	for item_key in cosmetic_nodes:
		var node = cosmetic_nodes[item_key]
		var item_type = cosmetic_key_to_type[item_key]
		var rules = GameManager.cosmetic_data[item_type][item_key]
		
		var is_unlocked = item_key in SaveManager.save_data.unlocked_cosmetics[item_type.to_lower()]
		
		node.update_display(item_key, 1 if is_unlocked else 0, 1, true, Color.WHITE, Color.GOLD)

		if rules.has("hex_code"):
			node.icon = preload("res://Assets/Icons/white_swatch.png")
			# We modulate the node itself, not a child.
			node.modulate = Color(rules.hex_code) if not is_unlocked else Color(rules["hex_code"]).darkened(0.5)
		else:
			var icon_path = rules.get("icon_path", "")
			if ResourceLoader.exists(icon_path):
				node.icon = load(icon_path)
			node.modulate = Color.WHITE if not is_unlocked else Color(0.5, 0.5, 0.5)

		node.disabled = is_unlocked
		if is_unlocked:
			node.text = "UNLOCKED"
		else:
			node.text = "%s\n(%s Fangs)" % [item_key, rules.fang_cost]



func _on_cosmetic_node_pressed(item_key: String):
	# This is the master handler for purchasing any cosmetic.
	var item_type = cosmetic_key_to_type[item_key]
	var rules = GameManager.cosmetic_data[item_type][item_key]
	var cost = rules.fang_cost
	
	# Check if the player can afford it.
	if SaveManager.save_data.serpent_fangs >= cost:
		pending_purchase_key = item_key # Store for confirmation
		var message = "Unlock '%s' for %s Fangs?" % [item_key, cost]
		confirmation_modal.show_confirmation(message)
	else:
		print("Not enough Fangs!")
