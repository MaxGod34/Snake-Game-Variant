extends PanelContainer

# --- NODE REFERENCES ---
@onready var player_name_label = $HBox/StatsContainer/HBoxContainer/PlayerNameLabel
@onready var level_label = $HBox/StatsContainer/HBoxContainer/LevelLabel
@onready var xp_bar = $HBox/StatsContainer/XPProgressBar
@onready var score_label = $HBox/StatsContainer/ScoreRow/HBoxContainer/ScoreLabel
@onready var juice_label = $HBox/StatsContainer/ScoreRow/HBoxContainer/JuiceLabel
@onready var upgrade_prompt_label = $HBox/StatsContainer/HBoxContainer2/UpgradePromptLabel
@onready var pulp_label = $HBox/StatsContainer/HBoxContainer2/PulpLabel

@onready var avatar_texture_rect = $HBox/Panel/ProfilePicture
@onready var frame_panel = $HBox/Panel

var actual_score: int = 0
var displayed_score_float: float = 0.0
var floating_text_container: Node
const POPUP_FONT = preload("res://Assets/Fonts/easvhs.ttf")
var pending_popup_score: int = 0
var popup_cooldown: float = 0.0

func _process(delta: float) -> void:
	# 1. Batch and spawn floating "+X" popups
	if popup_cooldown > 0.0:
		popup_cooldown -= delta
	elif pending_popup_score > 0:
		_spawn_batched_popup(pending_popup_score)
		pending_popup_score = 0
		popup_cooldown = 0.15

	# 2. Smoothly roll the main Score label up to actual_score
	if roundi(displayed_score_float) < actual_score:
		var roll_speed = max(20.0, (actual_score - displayed_score_float) * 8.0)
		displayed_score_float = move_toward(displayed_score_float, float(actual_score), roll_speed * delta)
		score_label.text = "Score: %d" % roundi(displayed_score_float)



func update_cosmetics(loadout: Dictionary):
	# --- Update Avatar ---
	var avatar_key = loadout.get("avatar", "Default")
	var avatar_rules = GameManager.cosmetic_data.Avatars.get(avatar_key)
	if avatar_rules and avatar_rules.has("icon_path"):
		var icon_path = avatar_rules.icon_path
		if ResourceLoader.exists(icon_path):
			avatar_texture_rect.texture = load(icon_path)
			
	# --- Update Frame ---
	var frame_key = loadout.get("frame", "Default")
	var frame_rules = GameManager.cosmetic_data.Frames.get(frame_key)
	if frame_rules:
		var new_stylebox: StyleBox
		if frame_rules.type == "texture":
			var style_tex = StyleBoxTexture.new()
			style_tex.texture = load(frame_rules.texture_path)
			# You can set margins here to control how the texture tiles
			new_stylebox = style_tex
		else: # Default to "flat" style
			var style_flat = StyleBoxFlat.new()
			style_flat.bg_color = Color.TRANSPARENT # Make the panel itself clear
			style_flat.border_width_bottom = 2
			style_flat.border_width_top = 2
			style_flat.border_width_left = 2
			style_flat.border_width_right = 2
			style_flat.border_color = Color(frame_rules.color)
			new_stylebox = style_flat
			
		# Apply the new style to the frame panel.
		frame_panel.add_theme_stylebox_override("panel", new_stylebox)



# This is the master function that main.gd will call.
func update_display(data: Dictionary):
	# Update all the simple text labels
	player_name_label.text = data["player_name"]
	level_label.text = "Level: " + str(data["level"])
	juice_label.text = "%s L" % data["juice"]
	pulp_label.text = "%s mg" % data["pulp"]
	upgrade_prompt_label.visible = true
	
	# Update the XP Bar's properties
	xp_bar.max_value = data["xp_max"]
	xp_bar.min_value = data["xp_min"] # We'll need to add this to our data dictionary
	xp_bar.value = data["xp_value"]
	
	# --- Animated Score Counter ---
	var new_score: int = data["xp_value"]
	if actual_score == 0:
		actual_score = new_score
		displayed_score_float = float(new_score)
		score_label.text = "Score: %d" % new_score
	
	elif new_score > actual_score:
		pending_popup_score += (new_score - actual_score)
		actual_score = new_score
	elif new_score < actual_score:
		actual_score = new_score
		displayed_score_float = float(new_score)
		score_label.text = "Score: %d" % new_score



func _spawn_batched_popup(amount:int):
	if not is_instance_valid(floating_text_container): return
	
	var point_label = Label.new()
	point_label.text = "+%d" % amount
	point_label.z_index = 10
	point_label.top_level = true
	point_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	point_label.add_theme_color_override("font_color", Color.GOLD)
	point_label.add_theme_font_size_override("font_size", 48)
	point_label.add_theme_font_override("font", POPUP_FONT)
	floating_text_container.add_child(point_label)

	# Spawn just to the right of ScoreLabel and drift slightly down/out into open space
	var base_pos = score_label.get_global_position() + Vector2(128.0, 0.0)
	point_label.global_position = base_pos + Vector2(randf_range(-6.0, 6.0), randf_range(-4.0, 4.0))

	var tween = create_tween()
	var end_pos = point_label.global_position + Vector2(randf_range(10.0, 25.0), -256.0)
	tween.tween_property(point_label, "global_position", end_pos, 1.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(point_label, "modulate:a", 0.0, 1.7).set_delay(0.15)
	tween.tween_callback(point_label.queue_free)

	
