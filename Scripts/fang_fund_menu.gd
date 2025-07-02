extends Control

# --- NODE REFERENCES ---
@onready var back_btn = $VBoxContainer/HBoxContainer/BackButton
@onready var class_unlock_grid = $"VBoxContainer/TabContainer/Class Acquisitions/ClassUnlockGrid"
@onready var debug_panel = $DebugPanel
@onready var description_panel = $DescriptionPanel
@onready var confirmation_modal = $ConfirmationModal
@onready var description_delay_timer = $DescriptionDelayTimer

var class_nodes: Dictionary = {}
var hovered_class_key: String = ""
var pending_purchase_key: String = ""

func _ready():
	_build_class_node_dictionary()
	_connect_all_class_nodes()
	update_all_displays()

func _unhandled_input(event: InputEvent):
	# We'll use F2 as our secret debug key for this menu.
	if event.is_action_pressed("ui_F1"): # You may need to add "ui_f2" in your Input Map
		debug_panel.visible = not debug_panel.visible


func _build_class_node_dictionary():
	# This loop finds all the class nodes in our new grid.
	for class_key in GameManager.class_data:
		var node_name = class_key.to_pascal_case() + "Node"
		var node = class_unlock_grid.find_child(node_name, false)
		if is_instance_valid(node):
			class_nodes[class_key] = node

func _connect_all_class_nodes():
	# This loop connects the signals from each class node.
	for class_key in class_nodes:
		var node = class_nodes[class_key]
		if is_instance_valid(node):
			node.pressed.connect(_on_class_unlock_pressed.bind(class_key))
			node.mouse_entered.connect(_on_class_node_mouse_entered.bind(class_key))
			node.mouse_exited.connect(_on_class_node_mouse_exited)
			
	debug_panel.get_node("AddFangsButton").pressed.connect(_on_debug_add_fangs_pressed)
	description_delay_timer.timeout.connect(_on_description_delay_timer_timeout)
	confirmation_modal.confirmed.connect(_on_unlock_confirmed)
	confirmation_modal.cancelled.connect(func(): confirmation_modal.visible = false)
	back_btn.pressed.connect(func(): SceneTransition.transition_to("res://Scenes/Menus/main_menu.tscn"))

# --- MASTER UPDATE FUNCTION ---
func update_all_displays():
	# ... (update fangs label later)
	update_class_unlock_grid()

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
			node.text = "%s\n(%s Fangs)" % [class_data.name, class_data.fang_cost]

# --- SIGNAL HANDLER ---
func _on_class_unlock_pressed(class_key: String):
	pending_purchase_key = class_key
	var class_data = GameManager.class_data[class_key]
	var cost = class_data.fang_cost
	
	if SaveManager.save_data.serpent_fangs >= cost:
		var message = "Unlock %s for %s Fangs?" % [class_data.name, cost]
		confirmation_modal.show_confirmation(message)
	else:
		# We can add a "not enough funds" animation here later
		print("Not enough Fangs!")

func _on_unlock_confirmed():
	confirmation_modal.visible = false
	if pending_purchase_key == "": return
	
	var class_key = pending_purchase_key
	var class_data = GameManager.class_data[class_key]
	var cost = class_data.fang_cost
	
	# Double-check affordability just in case
	if SaveManager.save_data.serpent_fangs >= cost:
		SaveManager.save_data.serpent_fangs -= cost
		SaveManager.save_data.unlocked_classes.append(class_key)
		SaveManager.save_game()
		update_all_displays()
		
	pending_purchase_key = ""


func _on_debug_add_fangs_pressed():
	# 1. We directly access our SaveManager's data and add the currency.
	SaveManager.save_data.serpent_fangs += 100
	
	# 2. Save the change to the file to make it permanent.
	SaveManager.save_game()
	
	# 3. And immediately update the UI to show the new total.
	update_all_displays()
	
	print("DEBUG: Added 100 Serpent Fangs.")

func _on_class_node_mouse_entered(class_key: String):
	hovered_class_key = class_key
	description_delay_timer.start()

func _on_class_node_mouse_exited():
	description_delay_timer.stop()
	description_panel.visible = false
	hovered_class_key = ""

func _on_description_delay_timer_timeout():
	if hovered_class_key != "":
		var class_data = GameManager.class_data[hovered_class_key]
		# We pass placeholder levels since these are one-time unlocks
		description_panel.show_info(hovered_class_key, class_data.name, class_data.description, class_data.fang_cost, 0, 1, "Fangs")
