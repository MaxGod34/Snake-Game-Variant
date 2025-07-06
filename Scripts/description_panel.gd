extends PanelContainer

# --- NODE REFERENCES ---
# Make sure these paths are correct for this scene!
@onready var icon_display = $MarginC/GridContainer/IconPanel/IconDisplay
@onready var name_label = $MarginC/GridContainer/UpgradeNameLabel
@onready var description_label = $MarginC/GridContainer/DescriptionLabel
@onready var cost_label = $MarginC/GridContainer/CostLabel
@onready var level_label = $MarginC/GridContainer/CurrentLevelLabel
@onready var tree_label = $MarginC/GridContainer/TreeLabel

func _ready():
	# Force layout to initialize with dummy content
	var dummy_rules = {
		"display_name": "Loading...",
		"description": "Initializing layout to prevent flicker.",
		"path": "Dummy",
		"sub_path": "Test",
		"type": "DummyType",
		"max_level": 1,
		"fang_cost": 0,
		"icon_path": ""
	}

	self.visible = true
	self.size = Vector2(540, 496)
	self.custom_minimum_size = Vector2(540, 496)

	await get_tree().process_frame
	await show_info(dummy_rules, 0, 0, "fangs")

	# Immediately hide it again until real usage
	await get_tree().process_frame
	self.visible = false

# This is the master function that main.gd will call.
func show_info(rules: Dictionary, current_level: int, cost: int, currency_unit: String):
	# --- PREVENT RESIZE FLICKER FIRST ---
	self.visible = false
	self.size = Vector2(540, 496)
	self.custom_minimum_size = Vector2(540, 496)

	await get_tree().process_frame # Let layout update first

	# --- Set all the text labels ---
	name_label.text = rules.get("display_name", rules.get("name", "Unknown Item"))
	description_label.text = rules.get("description", "No description available.")

	# --- Set the Tree/Type Label ---
	var path_text = rules.get("path", "")
	var sub_path_text = rules.get("sub_path", "")
	if path_text != "":
		tree_label.text = "Tree: %s (%s)" % [path_text, sub_path_text]
	else:
		tree_label.text = "Type: %s" % rules.get("type", "Unlockable")

	# --- Set the Level Display ---
	var max_level = rules.get("max_level", 1)
	if current_level >= max_level and max_level > 0:
		level_label.text = "(MAX)"
		cost_label.text = "---"
	elif max_level > 1:
		level_label.text = "(Lvl %s/%s)" % [current_level, max_level]
		cost_label.text = "Cost: %s %s" % [cost, currency_unit]
	else:
		level_label.text = "(One-Time)"
		cost_label.text = "Cost: %s %s" % [cost, currency_unit]

	# --- Set the Icon ---
	var icon_path = rules.get("icon_path", "")
	if rules.has("hex_code"):
		icon_display.texture = preload("res://Assets/Icons/white_swatch.png")
		icon_display.modulate = Color(rules.hex_code)
	elif ResourceLoader.exists(icon_path):
		icon_display.texture = load(icon_path)
		icon_display.modulate = Color.WHITE
	else:
		icon_display.texture = null
		icon_display.modulate = Color.WHITE

	# Just in case something tried to change the size again
	await get_tree().process_frame
	self.size = Vector2(540, 496)

	self.visible = true
