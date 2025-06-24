extends CanvasLayer

# This signal tells main.gd that the player is ready to move on.
signal continue_pressed

# --- Node References ---
# Get direct references to the labels we need to update.
# Make sure these paths match your scene tree exactly!
@onready var title_label = $CenterContainer/PanelContainer/VBoxContainer/TitleLabel
@onready var stats_label = $CenterContainer/PanelContainer/VBoxContainer/StatsLabel
@onready var bonus_list_container = $CenterContainer/PanelContainer/VBoxContainer/BonusListContainer
@onready var total_pulp_label = $CenterContainer/PanelContainer/VBoxContainer/TotalPulpLabel
@onready var grand_total_label = $CenterContainer/PanelContainer/VBoxContainer/GrandTotalLabel
@onready var continue_button = $ContinueButton



# --- The Master "Setup" Function ---
# This one function now handles EVERYTHING.
func display_results(garden_name, bonus_list: Array, pulp_this_garden: int, is_final_garden: bool, is_final_win: bool):
	# --- Part 1: Handle the "Game Win" state ---
	# This is the logic from your old 'setup' function.
	bonus_list_container.visible = false
	total_pulp_label.visible = false
	grand_total_label.visible = false
	continue_button.visible = false
	

	if is_final_win:
		title_label.text = "YOU ARE A SNAKE GOD!"
		continue_button.text = "Return to Menu"
	elif is_final_garden:
		title_label.text = "Final Garden Complete!"
		continue_button.text = "Finish"
	else:
		title_label.text = "Garden Complete!"
		continue_button.text = "To the\nPulpsicle Stand!"
	
	stats_label.text = "You cleared %s!" % garden_name
	stats_label.visible = true
	await get_tree().create_timer(1.25).timeout

	# Now, make the bonus section visible and start the animation.
	bonus_list_container.visible = true
	

	# --- Part 2: Display the Bonuses ---
	# This is the logic from new 'display_results' function.
	
	# First, clear out any old bonus labels from the previous time.
	for child in bonus_list_container.get_children():
		child.queue_free()
		
		
		
		
	# Now, loop through the list of bonuses and create a new label for each one.
	for bonus_text in bonus_list:
		var new_label = Label.new()
		new_label.text = bonus_text
		
		

		# Load the font file (this works, but you can't set size at runtime)
		var font = load("res://Assets/Fonts/easvhs.ttf")  # <-- See note below!
		var color = Color("ffff00")
		var border_color = Color("8d0000")
		new_label.add_theme_font_override("font", font)
		new_label.add_theme_font_size_override("font_size", 28)
		new_label.add_theme_color_override("font_color", color)
		new_label.add_theme_color_override("font_outline_color", border_color)
		new_label.add_theme_constant_override("outline", 16)

		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		new_label.modulate.a = 0.0
		new_label.scale = Vector2.ZERO
		bonus_list_container.add_child(new_label)
		
		# Create a tween for the "bop" animation.
		var tween = create_tween()
		# Use TRANS_BACK for a satisfying, slightly bouncy effect.
		tween.tween_property(new_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		# Fade it in at the same time.
		tween.parallel().tween_property(new_label, "modulate:a", 1.0, 0.1)
		
		# Play a satisfying "tick" sound here if you have one.
		
		# Wait for the animation to finish before showing the next bonus.
		await tween.finished
		await get_tree().create_timer(0.1).timeout # A tiny extra pause

	# --- Part 3: The Final Totals ---
	await get_tree().create_timer(0.5).timeout # A dramatic pause

	# Make the total labels visible for their animation.
	total_pulp_label.visible = true
	
	total_pulp_label.scale = Vector2.ZERO
	

	# Animate the final totals popping in.
	total_pulp_label.text = "Total This Garden: +%s mgs of Pulp" % pulp_this_garden
	var tween1 = create_tween()
	tween1.tween_property(total_pulp_label, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(0.6).timeout  # Wait before showing the next label
	
	grand_total_label.modulate.a = 0.0
	grand_total_label.visible = true
	grand_total_label.scale = Vector2.ZERO
	grand_total_label.text = "New Grand Total: %s mgs of Pulp" % GameManager.pulp
	var tween2 = create_tween()
	tween2.tween_property(grand_total_label, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween2.parallel().tween_property(grand_total_label, "modulate:a", 1.0, 0.1)
	
	# Play a satisfying "cha-ching" sound here.
	await get_tree().create_timer(0.6).timeout
	
	var tween3 = create_tween()
	continue_button.scale = Vector2.ZERO
	tween3.tween_property(continue_button, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	continue_button.visible = true
# This function just sends the signal when the button is clicked.
func _on_continue_button_pressed():
	emit_signal("continue_pressed")
