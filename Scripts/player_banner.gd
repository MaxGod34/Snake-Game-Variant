extends PanelContainer

# --- NODE REFERENCES ---
@onready var player_name_label = $HBox/StatsContainer/HBoxContainer/PlayerNameLabel
@onready var level_label = $HBox/StatsContainer/HBoxContainer/LevelLabel
@onready var xp_bar = $HBox/StatsContainer/XPProgressBar
@onready var score_label = $HBox/StatsContainer/ScoreRow/ScoreLabel
@onready var juice_label = $HBox/StatsContainer/ScoreRow/JuiceLabel
@onready var upgrade_prompt_label = $HBox/StatsContainer/HBoxContainer2/UpgradePromptLabel
@onready var pulp_label = $HBox/StatsContainer/HBoxContainer2/PulpLabel

var current_displayed_score = 0
var floating_text_container: Node

# This is the master function that main.gd will call.
func update_display(data: Dictionary):
	# Update all the simple text labels
	player_name_label.text = data["player_name"]
	level_label.text = "Level: " + str(data["level"])
	juice_label.text = "Juice: %smL" % data["juice"]
	pulp_label.text = "Pulp: %smg" % data["pulp"]
	upgrade_prompt_label.visible = (data["juice"] > 0)
	
	# Update the XP Bar's properties
	xp_bar.max_value = data["xp_max"]
	xp_bar.min_value = data["xp_min"] # We'll need to add this to our data dictionary
	xp_bar.value = data["xp_value"]
	
	# --- Animated Score Counter ---
	var new_score = data["xp_value"]
	if current_displayed_score == 0:
		score_label.text = "Score: " + str(new_score)
		current_displayed_score = new_score
	
	elif new_score > current_displayed_score:
		animate_score_change(new_score)
	else:
		# If score hasn't changed, just make sure the label is correct
		score_label.text = "Score: " + str(new_score)

func animate_score_change(target_score: int):
	var score_to_add = target_score - current_displayed_score
	score_label.text = "Score: " + str(target_score)
	current_displayed_score = target_score
	
	var spawn_position = score_label.get_global_position()
	

	for i in range(score_to_add):
		var point_label = Label.new()
		point_label.text = "+1"
		point_label.add_theme_color_override("font_color", Color.GOLD)
		point_label.add_theme_font_size_override("font_size", 32)
		point_label.add_theme_font_override("font", load("res://Assets/Fonts/easvhs.ttf"))
		if is_instance_valid(floating_text_container):
			floating_text_container.add_child(point_label)
		
		# We still position it relative to the score label
		point_label.global_position = spawn_position + Vector2(randf_range(-10, 10), 10) + Vector2(128, 0)
		
		# Animate its movement and fade
		var tween = create_tween()
		var end_pos = point_label.global_position + Vector2(randf_range(-30, 30), -70)
		tween.tween_property(point_label, "global_position", end_pos, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(point_label, "modulate:a", 0.0, 0.9).set_delay(0.2)
		tween.tween_callback(point_label.queue_free)

		# Add a tiny delay between each "+1" to create the "ticking" effect
		await get_tree().create_timer(0.05).timeout

	
