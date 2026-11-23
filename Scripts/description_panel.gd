extends Control

# --- NODE REFERENCES ---
# Make sure these paths are correct for this scene!
@onready var icon_display = $MarginC/GridContainer/IconPanel/IconDisplay
@onready var name_label = $MarginC/GridContainer/UpgradeNameLabel
@onready var description_label = $MarginC/GridContainer/DescriptionLabel
@onready var cost_label = $MarginC/GridContainer/CostLabel
@onready var level_label = $MarginC/GridContainer/CurrentLevelLabel
@onready var tree_label = $MarginC/GridContainer/TreeLabel

func _ready():
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom_minimum_size = Vector2(540, 496)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	

func _get_prop(source, prop_name: String, default_val = null):
	if source == null:
		return default_val
	if source is Dictionary:
		return source.get(prop_name, default_val)
	var val = source.get(prop_name)
	return val if val != null else default_val


# This is the master function that main.gd will call.
func show_info(rules, current_level: int, cost: int, currency_unit: String) -> void:
	if rules == null: return
	
	# Text Lbls
	var title: String = _get_prop(rules, "display_name", "")
	if title == "":
		title = _get_prop(rules, "name", _get_prop(rules, "id", "Unknown Item"))
	name_label.text = title
	description_label.text = _get_prop(rules, "description", "No description available.")
	
	# Tree/Type
	var path_text: String = _get_prop(rules, "path", "")
	var sub_path_text: String = _get_prop(rules, "sub_path", "")
	if path_text != "":
		tree_label.text = "Tree: %s (%s)" % [path_text, sub_path_text]
	else:
		tree_label.text = "Type: %s" % _get_prop(rules, "type", "Unlockable")
	
	# Lvl Cost
	var max_level: int = _get_prop(rules, "max_level", 1)
	if current_level >= max_level and max_level > 0:
		level_label.text = "(MAX)"
		cost_label.text = "---"
	elif max_level > 1:
		level_label.text = "(Lvl %s/%s)" % [current_level, max_level]
		cost_label.text = "Cost: %s %s" % [cost, currency_unit]
	else:
		level_label.text = "(One-Time)"
		cost_label.text = "Cost: %s %s" % [cost, currency_unit]
	
	# Icon
	var hex_code: String = _get_prop(rules, "hex_code", "")
	var icon_tex = _get_prop(rules, "icon", null)
	var icon_path: String = _get_prop(rules, "icon_path", "")
	
	if hex_code != "":
		icon_display.texture = preload("res://Assets/Icons/white_swatch.png")
		icon_display.modulate = Color(hex_code)
	elif icon_tex is Texture2D:
		icon_display.texture = icon_tex
		icon_display.modulate = Color.WHITE
	elif icon_path != "" and ResourceLoader.exists(icon_path):
		icon_display.texture = load(icon_path)
		icon_display.modulate = Color.WHITE
	else:
		icon_display.texture = null
		icon_display.modulate = Color.WHITE
	
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	reset_size()
	size = Vector2(max(size.x, 540.0), max(size.y, 496))
	
