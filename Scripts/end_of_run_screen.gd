extends CanvasLayer

signal restart_pressed
signal quit_pressed

@onready var xp_gained_label = $CenterContainer/PanelContainer/VBoxContainer/ClearGardenLabel
@onready var rank_label = $CenterContainer/PanelContainer/VBoxContainer/XPDisplayRow/CurrentLevelLabel
@onready var xp_bar = $CenterContainer/PanelContainer/VBoxContainer/XPDisplayRow/RankProgressBar
@onready var prestige_label = $CenterContainer/PanelContainer/VBoxContainer/XPDisplayRow/PrestigeRankLabel
@onready var milestone_grid = $CenterContainer/PanelContainer/VBoxContainer/MilestoneGrid
@onready var restart_button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/NewRunButton
@onready var quit_button = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/ExitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart_button.pressed.connect(func(): emit_signal("restart_pressed"))
	quit_button.pressed.connect(func(): emit_signal("quit_pressed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_results(start_level: int, start_xp: int, xp_gained: int, milestones_unlocked: Array):
	self.visible = true
	
	# --- 1. Set Initial State ---
	var current_level = start_level
	var current_xp = start_xp
	var remaining_xp_to_add = xp_gained
	xp_gained_label.text = "XP extracted: %s" % xp_gained
	
	# --- 2. The Animation Loop ---
	# This loop will continue until all the gained XP has been "animated".
	while remaining_xp_to_add > 0:
		var xp_for_next_level = SaveManager.get_xp_for_level(current_level + 1)
		xp_bar.max_value = xp_for_next_level
		xp_bar.value = current_xp
		rank_label.text = "Lvl: %s" % current_level
		
		var xp_needed = xp_for_next_level - current_xp
		var xp_to_animate_this_level = min(remaining_xp_to_add, xp_needed)
		
		var target_xp = current_xp + xp_to_animate_this_level
		
		# Animate the bar filling up for this level
		var tween = create_tween()
		tween.tween_property(xp_bar, "value", target_xp, 0.2 + (xp_to_animate_this_level * 0.005)).set_trans(Tween.TRANS_SINE)
		await tween.finished
		
		remaining_xp_to_add -= xp_to_animate_this_level
		current_xp = target_xp
		
		# Check if we leveled up
		if current_xp >= xp_for_next_level:
			xp_gained_label.text += " *FANGS AWARDED -- see fund*"
			current_level += 1
			current_xp = 0 # Reset for the new level
			
			# Add a cool "Level Up!" animation
			var level_up_tween = create_tween()
			level_up_tween.tween_property(rank_label, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_BACK)
			level_up_tween.tween_property(rank_label, "scale", Vector2.ONE, 0.2)
			# You could play a "level up" sound effect here!
			await level_up_tween.finished

	# --- 3. Final State & Milestones ---
	# After the animation, ensure the UI shows the final, correct values from SaveManager.
	rank_label.text = "Rank: %s" % SaveManager.save_data.player_level
	prestige_label.text = "(GM %s)" % SaveManager.save_data.garden_master_rank if SaveManager.save_data.garden_master_rank > 0 else ""
	xp_bar.max_value = SaveManager.get_xp_for_level(SaveManager.save_data.player_level + 1)
	xp_bar.value = SaveManager.save_data.player_xp

	# Populate the milestone grid.
	for milestone_key in milestones_unlocked:
		var milestone_icon = TextureRect.new()
		# milestone_icon.texture = preload(...)
		milestone_grid.add_child(milestone_icon)
