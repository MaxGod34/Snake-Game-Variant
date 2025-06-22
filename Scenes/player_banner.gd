extends PanelContainer

# --- NODE REFERENCES ---
@onready var player_name_label = $HBox/StatsContainer/PlayerNameLabel
@onready var level_label = $HBox/StatsContainer/LevelLabel
@onready var xp_bar = $HBox/StatsContainer/XPProgressBar
@onready var next_level_at_label = $HBox/StatsContainer/NextLevelAtLabel
@onready var score_label = $HBox/StatsContainer/ScoreLabel
@onready var juice_label = $HBox/StatsContainer/JuiceLabel
@onready var upgrade_prompt_label = $HBox/StatsContainer/UpgradePromptLabel

var current_displayed_score = 0

# This is the master function that main.gd will call.
func update_display(data: Dictionary):
	# Update all the simple text labels
	player_name_label.text = data["player_name"]
	level_label.text = "Level: " + str(data["level"])
	next_level_at_label.text = "Next Level at: " + str(data["xp_max"])
	juice_label.text = "Juice: %smL" % data["juice"]
	upgrade_prompt_label.visible = (data["juice"] > 0)
	
	# Update the XP Bar's properties
	xp_bar.max_value = data["xp_max"]
	xp_bar.min_value = data["xp_min"] # We'll need to add this to our data dictionary
	xp_bar.value = data["xp_value"]
	
	# --- Animated Score Counter ---
	var new_score = data["xp_value"]
	# We only run the animation if the score has actually increased
	if new_score > current_displayed_score:
		animate_score_change(new_score)
	else:
		score_label.text = "Score: " + str(new_score)

func animate_score_change(target_score: int):
	var score_to_add = target_score - current_displayed_score
	current_displayed_score = target_score
	
	# This loop creates the "CoD Zombies" effect
	for i in range(score_to_add):
		var point_label = Label.new()
		point_label.text = "+1"
		# Style it to look good (you'll want to create a Theme for this)
		point_label.add_theme_color_override("font_color", Color.GOLD)
		point_label.add_theme_font_size_override("font_size", 24)
		
		# Add it to the main scene tree so it can float over the UI
		get_tree().current_scene.add_child(point_label)
		point_label.global_position = score_label.global_position
		
		# Animate its movement and fade
		var tween = create_tween()
		var end_pos = point_label.global_position + Vector2(randf_range(-20, 20), -60)
		tween.tween_property(point_label, "global_position", end_pos, 0.7).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(point_label, "modulate:a", 0.0, 0.7)
		tween.tween_callback(point_label.queue_free)

	# Finally, update the main score label after a short delay
	await get_tree().create_timer(0.2).timeout
	score_label.text = str(target_score)
