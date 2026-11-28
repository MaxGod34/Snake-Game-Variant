extends Control

# --- NODE REFERENCES ---
# Make sure these paths are correct for this scene!
@onready var icon_display = $MarginC/PanelContainer/VboxMain/TopRow/IconPanel/IconDisplay
@onready var name_label = $MarginC/PanelContainer/VboxMain/TopRow/VBoxContainer/UpgradeNameLabel
@onready var tree_label = $MarginC/PanelContainer/VboxMain/TopRow/VBoxContainer/TreeLabel
@onready var level_label = $MarginC/PanelContainer/VboxMain/TopRow/VBoxContainer/CurrentLevelLabel
@onready var cost_label = $MarginC/PanelContainer/VboxMain/TopRow/VBoxContainer/CostLabel
@onready var description_label = $MarginC/PanelContainer/VboxMain/BottomRow/DescriptionLabel

@onready var prereq_section = $MarginC/PanelContainer/VboxMain/PrereqSection
@onready var prereq_label = $MarginC/PanelContainer/VboxMain/PrereqSection/PrereqLabel


const PULP_TIER_META: Dictionary = {
	PulpBundleData.Tier.COMMON: {"name": "Common", "hex": "#d9d9d9"},
	PulpBundleData.Tier.RARE: {"name": "Rare", "hex": "#4da6ff"},
	PulpBundleData.Tier.LEGENDARY: {"name": "Legendary", "hex": "#ffd700"},
	PulpBundleData.Tier.CURSE: {"name": "Curse", "hex": "#ff4d4d"},
}



func _ready():
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	custom_minimum_size = Vector2(448, 320)
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
		
		
	# Cool text modifiers for name
	name_label.text = "[center][pulse freq=1.5 color=#00ff00 ease=-2.0][wave amp=3.0 freq=2.0 connected=1]%s[/wave][/pulse][/center]" % title
	description_label.text = _get_prop(rules, "description", "No description available.")
	
	# Tree/Type
	var path_text: String = _get_prop(rules, "path", "")
	var sub_path_text: String = _get_prop(rules, "sub_path", "")
	if path_text != "":
		tree_label.text = "Tree: %s" % [sub_path_text]
	else:
		tree_label.text = "Type: %s" % _get_prop(rules, "type", "Unlockable")
	
	# Lvl Cost
	var max_level: int = _get_prop(rules, "max_level", 1)
	if current_level >= max_level and max_level > 0:
		level_label.text = "(MAX)"
		cost_label.text = "---"
	elif max_level > 1:
		level_label.text = "(Lvl %s/%s)" % [current_level, max_level]
		cost_label.text = "Cost: [tornado radius=5.0 freq=3.0 connected=1]%s %s[/tornado]" % [cost, currency_unit]
	else:
		level_label.text = "(One-Time)"
		cost_label.text = "Cost: [tornado radius=5.0 freq=3.0 connected=1]%s %s[/tornado]" % [cost, currency_unit]
	
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
	size = Vector2(max(size.x, 448.0), max(size.y, 320))


func _update_prerequisites(rules) -> void:
	if not is_instance_valid(prereq_section) or not is_instance_valid(prereq_label):
		return

	var prereqs = _get_prop(rules, "prerequisites", {})
	if not (prereqs is Dictionary) or prereqs.is_empty():
		prereq_section.visible = false
		return

	var lines: Array[String] = ["[b]Requires:[/b]"]
	for req_key in prereqs:
		if typeof(req_key) != TYPE_STRING:
			continue
		var req_level: int = int(prereqs[req_key])
		var owned_level: int = GameManager.get_upgrade_level_from_key(req_key)
		var met: bool = owned_level >= req_level
		var color_hex: String = "#69D2A3" if met else "#FF5555"
		var mark: String = "✓" if met else "✗"

		if req_level > 1:
			lines.append("[color=%s]%s %s (Lvl %d/%d)[/color]" % [color_hex, mark, req_key, mini(owned_level, req_level), req_level])
		else:
			lines.append("[color=%s]%s %s[/color]" % [color_hex, mark, req_key])

	prereq_label.text = "\n".join(lines)
	prereq_section.visible = (lines.size() > 1)



func show_simple_info(title: String, description: String, footer: String = "", icon_path: String = "", subtitle: String = "") -> void:
	name_label.text = "[center]%s[/center]" % title
	description_label.text = description

	tree_label.text = subtitle
	tree_label.visible = (subtitle != "")

	level_label.visible = false
	cost_label.text = footer
	cost_label.visible = (footer != "")

	if is_instance_valid(prereq_section):
		prereq_section.visible = false

	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon_display.texture = load(icon_path)
		icon_display.modulate = Color.WHITE
	else:
		icon_display.texture = null

	set_anchors_preset(Control.PRESET_TOP_LEFT)
	reset_size()
	size = Vector2(max(size.x, 448.0), max(size.y, 260.0))


func show_pulp_bundle(bundle: PulpBundleData, status_text: String = "") -> void:
	if bundle == null:
		return

	var meta: Dictionary = PULP_TIER_META.get(bundle.tier, {"name": "Pulp Item", "hex": "#ffffff"})
	var hex: String = meta["hex"]

	name_label.text = "[center][color=%s]%s[/color][/center]" % [hex, bundle.display_name]
	description_label.text = bundle.description

	tree_label.visible = true
	tree_label.text = "[color=%s]%s[/color]" % [hex, meta["name"]]

	level_label.visible = false

	cost_label.visible = true
	cost_label.text = status_text if status_text != "" else "FREE.99!"

	if is_instance_valid(prereq_section):
		prereq_section.visible = false

	icon_display.texture = bundle.icon
	icon_display.modulate = Color.WHITE
	

	set_anchors_preset(Control.PRESET_TOP_LEFT)
	reset_size()
	size = Vector2(max(size.x, 448.0), max(size.y, 260.0))

func show_custom_info(title: String, desc: String, footer_text: String, accent_color: Color, icon_tex: Texture2D = null) -> void:
	var hex: String = "#" + accent_color.to_html(false)

	name_label.text = "[center][color=%s][b]%s[/b][/color][/center]" % [hex, title]
	description_label.text = desc

	tree_label.visible = true
	tree_label.text = "[color=%s]Pulp Stand[/color]" % hex

	level_label.visible = false

	cost_label.visible = true
	cost_label.text = footer_text

	if is_instance_valid(prereq_section):
		prereq_section.visible = false

	icon_display.texture = icon_tex
	icon_display.modulate = Color.WHITE

	set_anchors_preset(Control.PRESET_TOP_LEFT)
	reset_size()
	size = Vector2(max(size.x, 448.0), max(size.y, 260.0))
